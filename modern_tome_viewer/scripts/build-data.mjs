#!/usr/bin/env node
/**
 * Build pipeline for modern_tome_viewer.
 *
 * Reads the raw ToME data exported by the `tometips` project and produces a
 * normalized, enriched, search-ready dataset for the web client:
 *
 *   public/data/talents.json   talent trees + talents (display + normalized values)
 *   public/data/meta.json      categories, classes, races, facet vocabularies
 *   public/data/manifest.json  build metadata (counts, source hash, timestamp)
 *   public/img/talents/<size>/ talent icons copied from the source
 *
 * Usage:
 *   node scripts/build-data.mjs [--source <dir>] [--icon-size 48] [--out public]
 *
 * JSON defaults to ./data/raw/master (a verbatim copy of the upstream
 * tometips master export, committed to this repository so the build is
 * self-contained). Icons are read from the cloned reference checkout
 * (../starsapphirex.github.io/tometips) unless --icon-source is given.
 */

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { parseAcronyms, fitCoefficients } from '../src/lib/scaling-core.js';

import { buildLuaIndex } from './extract-lua-coefficients.mjs';
import { matchLuaFormula, resolveIntegerRounding, checkHandExpression, declaredInputs, consumedInputs, uncoveredInputs, ladderAxis } from './lua-scaling.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..');

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------

function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (!arg.startsWith('--')) continue;
    const key = arg.slice(2);
    const value = argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[++i] : 'true';
    out[key] = value;
  }
  return out;
}

const args = parseArgs(process.argv.slice(2));
// JSON source: verbatim raw export committed in ./data/raw (self-contained build).
const dataDir = path.resolve(projectRoot, args.data || 'data/raw');
const masterDir = path.join(dataDir, 'master');
// Icon source: the cloned reference checkout (icons are ~9 MB per size and are
// copied into public/ during the build rather than committed twice).
const iconSourceDir = path.resolve(
  projectRoot,
  args['icon-source'] ||
    process.env.TOME_ICON_DIR ||
    path.join(projectRoot, '..', 'starsapphirex.github.io', 'tometips', 'img', 'talents'),
);
const outDir = path.resolve(projectRoot, args.out || 'public');
const iconSize = String(args['icon-size'] || 48);

const luaIndexPath = path.join(projectRoot, 'data/lua-coefficients.json');
let luaIndex = args['no-lua'] ? null : fs.existsSync(luaIndexPath) ? JSON.parse(fs.readFileSync(luaIndexPath, 'utf8')) : null;
const luaWorkspace = path.resolve(args['lua-workspace'] || path.dirname(projectRoot));
const hasLocalLua = fs.existsSync(path.join(luaWorkspace, 'tome-src-full/data/talents'));
if (!args['no-lua'] && hasLocalLua) {
  const fresh = buildLuaIndex({ workspace: luaWorkspace, rawDir: masterDir });
  if (fresh.missing.length) throw new Error(`Incomplete local Lua sources: ${fresh.missing.join(', ')}; use --no-lua for legacy fallback`);
  luaIndex = fresh;
  fs.writeFileSync(luaIndexPath, JSON.stringify(luaIndex, null, 2) + '\n');
}
console.log('[build-data] Lua index', args['no-lua'] ? 'disabled' : hasLocalLua ? 'fresh local extraction' : luaIndex ? 'bundled snapshot (local game sources absent)' : 'unavailable; legacy fallback');
if (luaIndex && luaIndex.version !== 1) throw new Error('Unsupported Lua index version; run npm run data:lua');
if (luaIndex) {
  const rawHash = crypto.createHash('sha256');
  for (const name of fs.readdirSync(masterDir).filter(n => /^talents\..*-1\.5\.json$/.test(n)).sort()) rawHash.update(name).update(fs.readFileSync(path.join(masterDir, name)));
  if (luaIndex.rawHash !== rawHash.digest('hex')) throw new Error('Lua index does not match raw data; run npm run data:lua');
}
const scalingStats = { total: 0, source: 0, estimated: 0, reference: 0, full: 0, partial: 0, none: 0, reasons: {} };

// ---------------------------------------------------------------------------
// Hand-written expression overlay (data/lua-expressions.json)
//
// The overlay is a candidate list, never an authority: every entry is re-checked
// here with the same gate the extractor's candidates go through, plus the full
// three-rendering ladder it was written against. An entry that fails is dropped
// and reported instead of being trusted.
// ---------------------------------------------------------------------------
const VARIANT_NAMES = ['1', '1.3', '1.5'];
const overlayPath = path.join(projectRoot, args.overlay || 'data/lua-expressions.json');
const overlay = fs.existsSync(overlayPath) ? JSON.parse(fs.readFileSync(overlayPath, 'utf8')) : [];
const overlayByTalent = new Map();
for (const entry of overlay) {
  if (!overlayByTalent.has(entry.talent)) overlayByTalent.set(entry.talent, new Map());
  overlayByTalent.get(entry.talent).set(entry.acronym, entry);
}

// The export ships the same talents rendered at three tooltip coefficients; only
// the canonical one is committed under data/raw, the others live beside the icon
// checkout. Validation falls back to the canonical rendering alone when absent.
const variantsDir = path.resolve(
  projectRoot,
  args['variants-source'] ||
    process.env.TOME_VARIANTS_DIR ||
    path.join(projectRoot, '..', 'starsapphirex.github.io', 'tometips', 'data', 'master'),
);
const variantAcronyms = new Map();
function variant(name) {
  if (!variantAcronyms.has(name)) {
    const map = new Map();
    const files = fs.existsSync(variantsDir)
      ? fs.readdirSync(variantsDir).filter(n => n.endsWith(`-${name}.json`))
      : [];
    for (const file of files) {
      for (const group of JSON.parse(fs.readFileSync(path.join(variantsDir, file), 'utf8'))) {
        for (const talent of group.talents || []) map.set(talent.id, parseAcronyms(talent.info_text || '', { fit: false }));
      }
    }
    variantAcronyms.set(name, map);
  }
  return variantAcronyms.get(name);
}
const overlayStats = { total: overlay.length, accepted: 0, rejected: [], superset: [], variants: 0 };
overlayStats.variants = VARIANT_NAMES.filter((name) => variant(name).size > 0).length;

/**
 * null when the entry reproduces every available rendering and reads only inputs
 * the title declares. With the off-repo renderings absent the ladder check falls
 * to `matchLuaFormula` on the canonical acronym further down.
 */
function overlayVerdict(entry, acronym) {
  if (overlayStats.variants) {
    for (const name of VARIANT_NAMES) {
      const ref = variant(name).get(entry.talent)?.[entry.acronym];
      if (!ref) return `variant ${name}: acronym not found`;
      const check = checkHandExpression(ref, entry.expr, entry.conditions ?? null);
      if (check.error) return `variant ${name}: no single varying axis`;
      if (!check.ok) {
        const bad = check.points.filter((p) => !p.ok)
          .map((p) => `${p.axis}->${p.displayed}≠${Number.isFinite(p.predicted) ? p.predicted.toFixed(4) : '—'}`);
        return `variant ${name}: ladder mismatch at ${bad.slice(0, 3).join(', ')}`;
      }
    }
  }
  const axis = ladderAxis(acronym);
  if (!axis) return 'no single varying axis';
  const declared = declaredInputs(acronym, axis);
  const consumed = consumedInputs(entry.expr, axis.label);
  const missing = uncoveredInputs(declared, consumed);
  if (missing.length) return `reads undeclared input(s): ${missing.join(', ')}`;
  // Declaring more than the formula reads is legitimate (the export writes a
  // whole tooltip's parameter union into every acronym title), but it is also
  // the shape a dropped slider takes when the export pins that input — so count
  // it instead of accepting it silently.
  const unused = declared.filter((label) => !consumed.includes(label));
  if (unused.length) overlayStats.superset.push(`${entry.talent}#${entry.acronym} (${unused.join(',')})`);
  return null;
}

function talentAcronyms(talent) {
  const result = parseAcronyms(talent.info_text || '', { fit: false });
  const hand = overlayByTalent.get(talent.id);
  result.forEach((acronym, index) => {
    scalingStats.total++;
    const record = luaIndex?.talents[talent.id];
    const entry = hand?.get(index);
    let candidates = record?.candidates;
    let provenance = record;
    if (entry) {
      const verdict = overlayVerdict(entry, acronym);
      if (!verdict) {
        // A hand-written formula replaces the extracted candidates for this value
        // so the two can never both match and be rejected as ambiguous.
        const line = Number(String(entry.source).match(/:(\d+)$/)?.[1] ?? 0);
        provenance = { ...(record ?? {}), file: String(entry.source).replace(/:\d+$/, ''), line, candidates: [{ expr: entry.expr, argument: index + 1 }] };
        candidates = provenance.candidates;
        overlayStats.accepted++;
      } else {
        overlayStats.rejected.push(`${entry.talent}#${entry.acronym}: ${verdict}`);
      }
    }
    const match = candidates
      ? matchLuaFormula(acronym, provenance ?? { candidates })
      : { reason: 'source unavailable' };
    if (match.formula) {
      Object.assign(acronym, match.formula);
      scalingStats.source++;
    } else {
      Object.assign(acronym, fitCoefficients(acronym));
      scalingStats[acronym.base === null ? 'reference' : 'estimated']++;
      scalingStats.reasons[match.reason] = (scalingStats.reasons[match.reason] || 0) + 1;
    }
  });
  if (result.length) {
    // Values printed by one `tformat` call share a format string, so the
    // integer reading one of them proves settles its siblings.
    resolveIntegerRounding(result);
    const solved = result.filter(a => a.lua || a.base !== null).length;
    scalingStats[solved === result.length ? 'full' : solved ? 'partial' : 'none']++;
  }
  return result;
}

// The three exported variants only differ in the tooltip "skill coefficient"
// (1.00 / 1.30 / 1.50 = game difficulty). We keep the highest as canonical.
const DATA_VARIANT = args.variant || '1.5';

if (!fs.existsSync(masterDir)) {
  console.error(`[build-data] JSON source not found: ${masterDir}`);
  console.error('[build-data] pass --data <dir> or set up data/raw/master');
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Text helpers
// ---------------------------------------------------------------------------

// ToME's classic colour codes -> hex. Only a handful appear in the data.
const COLOR_CODES = {
  WHITE: '#ffffff',
  BLACK: '#000000',
  RED: '#ff0000',
  LIGHT_RED: '#ff6060',
  DARK_RED: '#7f0000',
  GREEN: '#00ff00',
  LIGHT_GREEN: '#90ee90',
  DARK_GREEN: '#007f00',
  BLUE: '#0000ff',
  LIGHT_BLUE: '#51ddff',
  LIGHT_STEEL_BLUE: '#b0c4de',
  STEEL_BLUE: '#4682b4',
  DARK_BLUE: '#00007f',
  YELLOW: '#ffff00',
  GOLD: '#ffd700',
  ORANGE: '#ffa500',
  VIOLET: '#ee82ee',
  PURPLE: '#a020f0',
  CRIMSON: '#dc143c',
  SALMON: '#fa8072',
  ORCHID: '#da70d6',
  AQUAMARINE: '#7fffd4',
  GREY: '#808080',
  GRAY: '#808080',
  DARK_GREY: '#404040',
  SANDY_BROWN: '#f4a460',
  CHOCOLATE: '#d2691e',
  PINK: '#ffc0cb',
  SLATE: '#708090',
  UMBER: '#8b4513',
};

const ENTITIES = {
  '&nbsp;': ' ', '&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"',
  '&#39;': "'", '&apos;': "'", '&mdash;': '—', '&ndash;': '–', '&hellip;': '…',
};

function decodeEntities(text) {
  return text
    .replace(/&#x([0-9a-f]+);/gi, (_, hex) => String.fromCodePoint(parseInt(hex, 16)))
    .replace(/&#(\d+);/g, (_, dec) => String.fromCodePoint(Number(dec)))
    .replace(/&[a-z]+;/gi, (m) => ENTITIES[m.toLowerCase()] ?? m);
}

/** Convert game colour markup (#GOLD#text#LAST#) into <span style="color:...">. */
function colorMarkupToHtml(input) {
  if (!input) return '';
  let html = input;
  const open = [];
  html = html.replace(/#([A-Z_]{2,})#/g, (match, code) => {
    if (code === 'LAST') {
      return open.pop() ?? '';
    }
    const hex = COLOR_CODES[code];
    if (!hex) return match;
    open.push('</span>');
    return `<span style="color:${hex}">`;
  });
  // close anything left dangling
  while (open.length) html += open.pop();
  return html;
}

/** Strip all markup from an HTML fragment and return searchable plain text. */
function htmlToPlainText(html) {
  if (!html) return '';
  let text = html;
  text = text.replace(/<br\s*\/?>/gi, ' ');
  text = text.replace(/<\/(p|li|ul|ol|div|h[1-6]|tr|td)>/gi, ' ');
  text = text.replace(/<[^>]+>/g, '');
  text = decodeEntities(text);
  text = text.replace(/#[A-Z_]{2,}#/g, ' ');
  text = text.replace(/\s+/g, ' ').trim();
  return text;
}

/** Display-safe HTML: normalize colour codes and drop unsupported wrappers. */
function normalizeDisplayHtml(html) {
  if (!html) return '';
  let out = colorMarkupToHtml(html);
  out = out.replace(/<p>\s*<\/p>/gi, '');
  return out.trim();
}

/**
 * Collapse redundant `<span style="color:…"><span class="tstr-color-X">` pairs
 * into a single class-based span. Class descriptions carry hundreds of these;
 * the client styles the tstr-* classes in CSS, so the inline styles are pure
 * duplication (~40% of the description payload).
 */
function compactDisplayHtml(html) {
  if (!html) return '';
  let out = normalizeDisplayHtml(html);
  // <span style="…"><span class="tstr-…">text</span></span> -> <span class="tstr-…">text</span>
  out = out.replace(
    /<span style="[^"]*"><span class="(tstr-[a-zA-Z0-9-]+)">([\s\S]*?)<\/span><\/span>/g,
    (_match, cls, text) => `<span class="${cls}">${text}</span>`,
  );
  // Any remaining style-only span (no tstr class) -> plain span.
  out = out.replace(/<span style="[^"]*">/g, '<span>');
  out = out.replace(/<span>\s*<\/span>/g, '');
  return balanceSpans(out);
}

/**
 * Upstream descriptions are occasionally malformed (e.g. POSSESSOR ships 14
 * opening and 16 closing spans). Drop unmatched closers so the browser never
 * has to guess at the structure.
 */
function balanceSpans(html) {
  let depth = 0;
  return html.replace(/<span[^>]*>|<\/span>/g, (tag) => {
    if (tag === '</span>') {
      if (depth === 0) return '';
      depth -= 1;
      return tag;
    }
    depth += 1;
    return tag;
  }) + '</span>'.repeat(0);
}

/** Pull the numeric ladder out of a value like "<acronym ...>41, 32, 27</acronym>".
 *
 * Only the element *text* is inspected — the acronym title contains prose such
 * as "技能等级 1-5" whose "1-5" would otherwise be misread as the number -5.
 */
function extractNumbers(value) {
  if (value === null || value === undefined) return [];
  if (typeof value === 'number') return [value];
  const text = String(value)
    .replace(/<[^>]*>/g, ' ')
    .replace(/#[A-Z_]{2,}#/g, ' ');
  const numbers = text.match(/-?\d+(?:\.\d+)?/g);
  return numbers ? numbers.map(Number) : [];
}

// ---------------------------------------------------------------------------
// Value normalization
// ---------------------------------------------------------------------------

function normalizeCooldown(raw) {
  if (raw === null || raw === undefined || raw === '') {
    return { display: null, min: null, max: null, values: [] };
  }
  const values = extractNumbers(raw);
  if (!values.length) return { display: htmlToPlainText(String(raw)) || null, min: null, max: null, values: [] };
  const display = typeof raw === 'number' ? String(raw) : htmlToPlainText(String(raw));
  return { display, min: Math.min(...values), max: Math.max(...values), values };
}

/**
 * Wire format trims fields the client can derive, to keep the JSON small:
 * a numeric cooldown is just its number, and "ladder" values keep only the
 * rendered text ("49, 39, 34, 31, 29") instead of duplicating min/max/values.
 */
function compactCooldown(cooldown) {
  if (cooldown.display === null) return null;
  if (cooldown.values.length === 1) return cooldown.values[0];
  return cooldown.display;
}

function normalizeRange(raw) {
  const text = htmlToPlainText(String(raw ?? ''));
  const values = extractNumbers(raw);
  const numeric = values.filter((n) => Number.isFinite(n));
  // "近战/单体" (melee) and "弓箭" (bow) carry no distance at all.
  const kind = /近战/.test(text) ? 'melee' : /弓箭|弓/.test(text) ? 'bow' : numeric.length ? 'distance' : 'other';
  return {
    display: text || null,
    kind,
    min: numeric.length ? Math.min(...numeric) : null,
    max: numeric.length ? Math.max(...numeric) : null,
  };
}

const RESOURCE_NAMES = [
  ['体力值', 'stamina', '体力'],
  ['法力值', 'mana', '法力'],
  ['失衡值', 'equilibrium', '失衡'],
  ['蒸汽', 'steam', '蒸汽'],
  ['灵能值', 'psi', '灵能'],
  ['活力值', 'vim', '活力'],
  ['紊乱值', 'paradox', '紊乱'],
  ['正能量', 'positive', '正能量'],
  ['负能量', 'negative', '负能量'],
  ['疯狂值', 'insanity', '疯狂'],
  ['仇恨值', 'hate', '仇恨'],
  ['灵魂', 'soul', '灵魂'],
];

function parseCost(raw) {
  const text = htmlToPlainText(String(raw ?? ''));
  if (!text) return { display: null, resource: null, resourceLabel: null, amount: null, kind: null };

  const resource = RESOURCE_NAMES.find(([needle]) => text.includes(needle));
  const amountMatch = text.match(/([\d.]+)/);
  let kind = null;
  if (/持续/.test(text)) kind = 'sustain';
  else if (/获得/.test(text)) kind = 'gain';
  else if (/吸收/.test(text)) kind = 'drain';
  else kind = 'cost';

  return {
    display: text,
    resource: resource ? resource[1] : null,
    resourceLabel: resource ? resource[2] : null,
    amount: amountMatch ? Number(amountMatch[1]) : null,
    kind,
  };
}

function parseRequire(list) {
  if (!Array.isArray(list)) return [];
  return list.map((entry) => {
    const text = htmlToPlainText(String(entry));
    const level = text.match(/等级\s*([\d.]+)/);
    const stat = text.match(/,\s*([^,\d]+?)\s*([\d.]+)\s*$/);
    return {
      display: text,
      level: level ? Number(level[1]) : null,
      stat: stat ? stat[1].trim() : null,
      statValue: stat ? Number(stat[2]) : null,
    };
  });
}

/** Interesting boolean-ish flags worth exposing as facets. */
const FACET_FLAGS = [
  'is_spell', 'is_mind', 'is_nature', 'is_steam', 'is_melee', 'is_necromancy',
  'is_teleport', 'is_heal', 'is_summon', 'is_inscription', 'is_antimagic',
  'requires_target', 'direct_hit', 'no_energy', 'no_silence', 'generic',
  'uber', 'innate', 'is_unarmed', 'is_curse', 'is_hex', 'is_psyshot',
  'is_technomancy', 'hide', 'not_listed', 'multi_require',
];

function collectFlags(talent) {
  const flags = {};
  for (const key of FACET_FLAGS) {
    if (talent[key]) flags[key] = true;
  }
  return flags;
}

// ---------------------------------------------------------------------------
// Load source
// ---------------------------------------------------------------------------

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, 'utf8'));
}

function listTalentFiles(variant) {
  return fs
    .readdirSync(masterDir)
    .filter((f) => f.startsWith('talents.') && f.endsWith(`-${variant}.json`))
    .sort();
}

const tome = readJson(path.join(masterDir, 'tome.json'));
const classesFile = readJson(path.join(masterDir, 'classes.json'));
const racesFile = readJson(path.join(masterDir, 'races.json'));
const searchTypes = readJson(path.join(masterDir, 'search.talents-types.json'));

const classes = classesFile.classes || {};
const subclasses = classesFile.subclasses || {};
const races = racesFile.races || {};
const subraces = racesFile.subraces || {};

// class id -> set of talent-tree ids (class + generic trees, from all subclasses)
const treeToClasses = new Map();
for (const [classId, cls] of Object.entries(classes)) {
  for (const subId of cls.subclass_list || []) {
    const sub = subclasses[subId];
    if (!sub) continue;
    for (const bucket of [sub.talents_types_class, sub.talents_types_generic]) {
      if (!bucket || typeof bucket !== 'object') continue;
      for (const treeId of Object.keys(bucket)) {
        if (!treeToClasses.has(treeId)) treeToClasses.set(treeId, new Set());
        treeToClasses.get(treeId).add(classId);
      }
    }
  }
}

const treeDescription = new Map();
for (const entry of searchTypes) {
  if (!entry || !entry.href) continue;
  const id = entry.href.replace(/^talents\//, '');
  treeDescription.set(id, entry.desc || '');
}

// ---------------------------------------------------------------------------
// Build trees + talents
// ---------------------------------------------------------------------------

const trees = [];
const seenTalents = new Map();
const flagVocabulary = new Set();
let talentCount = 0;
const missingImages = new Set();
const presentImages = new Set();

const talentFiles = listTalentFiles(DATA_VARIANT);
for (const file of talentFiles) {
  const raw = readJson(path.join(masterDir, file));
  if (!Array.isArray(raw)) continue;

  for (const tree of raw) {
    const treeId = String(tree.type || '').replace(/^talents\//, '');
    if (!treeId) continue;

    const category = treeId.split('/')[0];
    const talents = [];

    for (const [index, talent] of (tree.talents || []).entries()) {
      talentCount += 1;
      const cooldown = normalizeCooldown(talent.cooldown);
      const range = normalizeRange(talent.range);
      const cost = parseCost(talent.cost);
      const displayName = colorMarkupToHtml(talent.name || '');
      const plainName = htmlToPlainText(displayName);
      const flags = collectFlags(talent);
      for (const key of Object.keys(flags)) flagVocabulary.add(key);

      const image = talent.image || null;
      if (image) presentImages.add(image);

      const record = {
        id: talent.id,
        name: displayName,
        shortName: talent.short_name || '',
        image,
        tree: treeId,
        index,
        mode: talent.mode || '',
        points: typeof talent.points === 'number' ? talent.points : Number(talent.points) || 0,
        // Compact wire format: number for a plain cooldown, string for a ladder.
        cd: compactCooldown(cooldown),
        // `fixed_cooldown = true` (27 talents): the game refuses to let any
        // effect change this cooldown — `Actor.lua:6872` reads
        // `if t.fixed_cooldown or base then return cd end` under the comment
        // "Can not touch this cooldown". Worth keeping: 超越永恒 works by
        // *shortening other talents' remaining cooldowns* and skips these.
        ...(talent.fixed_cooldown ? { fixedCd: true } : {}),
        range: range.display,
        rangeKind: range.kind,
        cost: cost.display,
        costResource: cost.resource,
        costAmount: cost.amount,
        costKind: cost.kind,
        useSpeed: talent.use_speed || '',
        require: parseRequire(talent.require).map((entry) => entry.display),
        text: normalizeDisplayHtml(talent.info_text || ''),
        plain: htmlToPlainText(talent.info_text || ''),
        // Precomputed scaling fits so the browser never has to solve them.
        acronyms: talentAcronyms(talent).map((a) => ({
          c: a.className,
          d: a.displayed,
          s: a.suffix,
          ...(a.prefix ? { pre: a.prefix } : {}),
          ...(a.tail ? { tail: a.tail } : {}),
          f: a.family,
          b: a.base,
          m: a.max,
          t: a.mastery,
          ...(a.lua ? { l: a.lua } : {}),
          p: a.params.map((p) => [p.label, p.kind, p.value, p.ladder]),
        })),
        flags,
        source: Array.isArray(talent.source_code) ? talent.source_code[0] : null,
      };
      talents.push(record);
      seenTalents.set(record.id, record);
    }

    trees.push({
      id: treeId,
      category,
      name: colorMarkupToHtml(tree.name || treeId),
      description: normalizeDisplayHtml(tree.description || treeDescription.get(treeId) || ''),
      classes: Array.from(treeToClasses.get(treeId) || []).sort(),
      talentCount: talents.length,
      talents,
    });
  }
}

trees.sort((a, b) => a.id.localeCompare(b.id));

// ---------------------------------------------------------------------------
// Supplemental talents (monster-only gaps in the upstream export)
// ---------------------------------------------------------------------------
//
// The upstream export is a 1.5-era snapshot and never emitted a handful of
// talents that the 1.7.6 monster templates reference (for example `T_HEAT`,
// which the Phoenix, Tannen and Walrog define). `data/talent-supplement.json`
// is generated from the local Lua sources by
// `scripts/monsters/talent-supplement.mjs`, and merging it here is what makes
// those monster skill entries click through to a real detail panel instead of
// showing up as unresolved references.
const supplementPath = path.join(projectRoot, args.supplement || 'data/talent-supplement.json');
const supplementStats = { merged: 0, skipped: 0, ids: [] };
if (fs.existsSync(supplementPath)) {
  const supplement = JSON.parse(fs.readFileSync(supplementPath, 'utf8'));
  for (const entry of supplement.talents || []) {
    if (!entry?.id || seenTalents.has(entry.id)) {
      supplementStats.skipped += 1;
      continue;
    }
    const treeId = (entry.tree || 'misc/supplement').replace(/^talents\//, '');
    const category = treeId.split('/')[0];
    // `info` may be plain game text with `%d`-style placeholders and colour
    // markup; normalize exactly like the exported talents so the same renderer
    // and scaling pipeline handle it.
    const infoText = entry.info || '';
    const flags = {};
    if (entry.mode === 'passive') flags.generic = true;
    const record = {
      id: entry.id,
      name: colorMarkupToHtml(entry.name || entry.id),
      shortName: '',
      image: null,
      tree: treeId,
      index: 0,
      mode: entry.mode || '',
      points: typeof entry.points === 'number' ? entry.points : 0,
      cd: typeof entry.cooldown === 'number' ? entry.cooldown : null,
      range: null,
      rangeKind: 'other',
      cost: null,
      costResource: null,
      costAmount: null,
      costKind: null,
      useSpeed: '',
      require: [],
      text: normalizeDisplayHtml(infoText),
      plain: htmlToPlainText(infoText),
      acronyms: [],
      flags,
      source: entry.file || null,
      // Marks the entry as coming from the supplement rather than the export,
      // so the report can tell the two apart.
      supplemental: true,
    };
    seenTalents.set(record.id, record);
    let tree = trees.find((candidate) => candidate.id === treeId);
    if (!tree) {
      tree = {
        id: treeId,
        category,
        name: category,
        description: '',
        classes: [],
        talentCount: 0,
        talents: [],
      };
      trees.push(tree);
    }
    tree.talents.push(record);
    tree.talentCount = tree.talents.length;
    supplementStats.merged += 1;
    supplementStats.ids.push(record.id);
    // Keep the manifest/summary count in step with what was actually written.
    talentCount += 1;
  }
}
if (supplementStats.merged || supplementStats.skipped) {
  console.log(
    `[build-data] 补充技能 ${supplementStats.merged} 条（${supplementStats.ids.join(', ')}）` +
      (supplementStats.skipped ? `，跳过 ${supplementStats.skipped} 条已收录` : ''),
  );
}

// Collect the counts now that trees may have gained a synthetic tree.

// Icon inventory: only keep the icons actually referenced.
const sourceIconDir = path.join(iconSourceDir, iconSize);
const outIconDir = path.join(outDir, 'img', 'talents', iconSize);
let copiedIcons = 0;
if (fs.existsSync(sourceIconDir)) {
  fs.mkdirSync(outIconDir, { recursive: true });
  for (const file of fs.readdirSync(sourceIconDir)) {
    if (!presentImages.has(file)) continue;
    fs.copyFileSync(path.join(sourceIconDir, file), path.join(outIconDir, file));
    copiedIcons += 1;
  }
} else {
  console.warn(`[build-data] icon dir missing: ${sourceIconDir}`);
}
for (const file of presentImages) {
  if (!fs.existsSync(path.join(outIconDir, file))) missingImages.add(file);
}

// Portrait assets for the class/race pages: copy exactly the files referenced.
let copiedPortraits = 0;
function copyPortraits(files) {
  for (const relative of files) {
    const source = path.join(iconSourceDir, '..', relative);
    const target = path.join(outDir, 'img', relative);
    if (!fs.existsSync(source)) continue;
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.copyFileSync(source, target);
    copiedPortraits += 1;
  }
}

// ---------------------------------------------------------------------------
// Facet vocabularies for the filter UI
// ---------------------------------------------------------------------------

function tally(values) {
  const map = new Map();
  for (const value of values) {
    if (value === null || value === undefined || value === '') continue;
    map.set(value, (map.get(value) || 0) + 1);
  }
  return [...map.entries()]
    .sort((a, b) => b[1] - a[1] || String(a[0]).localeCompare(String(b[0])))
    .map(([value, count]) => ({ value, count }));
}

const allTalents = [...seenTalents.values()];

const categories = (tome.talent_categories || []).map((id) => ({
  id,
  name: (tome.talent_categories_names || {})[id] || id,
  treeCount: trees.filter((t) => t.category === id).length,
  talentCount: trees.filter((t) => t.category === id).reduce((n, t) => n + t.talentCount, 0),
}));

// ---------------------------------------------------------------------------
// Classes and races (full records for the class/race pages)
// ---------------------------------------------------------------------------

const treeById = new Map(trees.map((tree) => [tree.id, tree]));

/**
 * A talent tree reference with its mastery and availability.
 *
 * Upstream encodes the first tuple element as "unlocked": the original
 * tometips template adds its `locked` class only when the flag is falsy
 * (e.g. Bulwark's three generic trees are all `true` and shown unlocked).
 */
function treeRef(treeId, entry) {
  const tree = treeById.get(treeId);
  const [unlocked, mastery, label] = Array.isArray(entry) ? entry : [true, 1, treeId];
  return {
    id: treeId,
    name: label || tree?.name || treeId,
    mastery: typeof mastery === 'number' ? mastery : 1,
    unlocked: unlocked !== false,
    talentCount: tree?.talentCount ?? 0,
  };
}

function treeRefs(bucket) {
  if (!bucket || typeof bucket !== 'object') return [];
  return Object.entries(bucket)
    .map(([id, entry]) => treeRef(id, entry))
    .sort((a, b) => Number(b.unlocked) - Number(a.unlocked) || a.name.localeCompare(b.name));
}

// ---------------------------------------------------------------------------
// Portrait assets (class icons, NPC art, race sprites)
// ---------------------------------------------------------------------------

const iconAssets = { classIcons: new Set(), npc: new Set(), player: new Set() };

/** Subclass portrait: the 128px class icon, plus any NPC art the export names. */
function subclassImages(subId, raw) {
  const slug = subId.toLowerCase();
  const icon = `class-icons/${slug}_128_bg.png`;
  const images = [{ file: icon, width: 128, height: 128 }];
  iconAssets.classIcons.add(icon);

  for (const entry of raw?.images ?? []) {
    if (!entry?.file) continue;
    images.push({ file: entry.file, width: entry.width ?? null, height: entry.height ?? null });
    iconAssets.npc.add(entry.file);
  }
  return images;
}

/** Subrace portrait: gendered player sprites when they exist, else NPC art. */
function subraceImages(subId, raw, sourceIconRoot) {
  const slug = subId.toLowerCase();
  const images = [];
  for (const gender of ['male', 'female']) {
    const file = `player/${slug}_${gender}.png`;
    if (fs.existsSync(path.join(sourceIconRoot, '..', file))) {
      images.push({ file, width: 64, height: 64 });
      iconAssets.player.add(file);
    }
  }
  for (const entry of raw?.images ?? []) {
    if (!entry?.file) continue;
    images.push({ file: entry.file, width: entry.width ?? null, height: entry.height ?? null });
    iconAssets.npc.add(entry.file);
  }
  return images;
}

const classRecords = (classesFile.class_list || Object.keys(classes))
  .map((classId) => {
    const cls = classes[classId];
    if (!cls) return null;
    return {
      id: classId,
      name: cls.display_name || cls.name || classId,
      englishName: cls.name || classId,
      description: compactDisplayHtml(cls.desc || ''),
      plainDescription: htmlToPlainText(cls.desc || ''),
      subclasses: (cls.subclass_list || [])
        .map((subId) => {
          const sub = subclasses[subId];
          if (!sub) return null;
          const copy = sub.copy_add || sub.copy || {};
          return {
            id: subId,
            name: sub.display_name || sub.name || subId,
            englishName: sub.name || subId,
            description: compactDisplayHtml(sub.desc || ''),
            plainDescription: htmlToPlainText(sub.desc || ''),
            locked: Boolean(sub.locked_desc && !sub.desc),
            images: subclassImages(subId, sub),
            stats: sub.stats || {},
            lifeRating: typeof copy.life_rating === 'number' ? copy.life_rating : null,
            extraTalentPoints: copy.unused_talents ?? null,
            extraGenericPoints: copy.unused_generics ?? null,
            extraTreePoints: copy.unused_talents_types ?? null,
            startingTalents: Object.keys(sub.talents || {}),
            classTrees: treeRefs(sub.talents_types_class),
            genericTrees: treeRefs(sub.talents_types_generic),
          };
        })
        .filter(Boolean),
    };
  })
  .filter(Boolean);

// Some subraces ship no art at all (DREM, KROG). Fall back to the sibling art
// of the same race so the card still shows a portrait.
function raceFallbackImages(raceId, race) {
  for (const subId of race.subrace_list || []) {
    const images = subraceImages(subId, subraces[subId], iconSourceDir);
    if (images.length) return images;
  }
  return [];
}

const raceRecords = (racesFile.race_list || Object.keys(races))
  .map((raceId) => {
    const race = races[raceId];
    if (!race) return null;
    return {
      id: raceId,
      name: race.display_name || race.name || raceId,
      englishName: race.name || raceId,
      description: compactDisplayHtml(race.desc || ''),
      plainDescription: htmlToPlainText(race.desc || ''),
      subraces: (race.subrace_list || [])
        .map((subId) => {
          const sub = subraces[subId];
          if (!sub) return null;
          const copy = sub.copy || {};
          return {
            id: subId,
            name: sub.display_name || sub.name || subId,
            englishName: sub.name || subId,
            description: compactDisplayHtml(sub.desc || ''),
            plainDescription: htmlToPlainText(sub.desc || ''),
            images: subraceImages(subId, sub, iconSourceDir).length
              ? subraceImages(subId, sub, iconSourceDir)
              : raceFallbackImages(raceId, race),
            stats: sub.stats || {},
            lifeRating: typeof copy.life_rating === 'number' ? copy.life_rating : null,
            experience: sub.experience ?? null,
            size: sub.size || copy.size || null,
            trees: treeRefs(sub.talents_types),
          };
        })
        .filter(Boolean),
    };
  })
  .filter(Boolean);

const meta = {
  gameVersion: tome.version || 'master',
  dataVariant: DATA_VARIANT,
  categories,
  /** Lightweight tree directory so the filter panel can label ids. */
  treeNames: trees.map((tree) => ({
    id: tree.id,
    name: htmlToPlainText(tree.name),
    category: tree.category,
    talentCount: tree.talentCount,
  })),
  classList: classRecords.map((cls) => ({ id: cls.id, name: cls.name })),
  raceList: raceRecords.map((race) => ({ id: race.id, name: race.name })),
  classes: classRecords,
  races: raceRecords,
  facets: {
    mode: tally(allTalents.map((t) => t.mode)),
    useSpeed: tally(allTalents.map((t) => t.useSpeed)),
    rangeKind: tally(allTalents.map((t) => t.rangeKind)),
    resource: tally(allTalents.map((t) => t.costResource)),
    costKind: tally(allTalents.map((t) => t.costKind)),
    flag: tally(allTalents.flatMap((t) => Object.keys(t.flags))),
  },
  bounds: (() => {
    const cdNumbers = allTalents.flatMap((t) => (t.cd === null ? [] : extractNumbers(t.cd)));
    const rangeNumbers = allTalents.flatMap((t) => extractNumbers(t.range));
    const span = (numbers) =>
      numbers.length ? { min: Math.min(...numbers), max: Math.max(...numbers) } : { min: 0, max: 0 };
    return { cooldown: span(cdNumbers), range: span(rangeNumbers) };
  })(),
  iconSize: Number(iconSize),
  iconDir: `img/talents/${iconSize}`,
};

// Copy the portraits referenced by the class/race records.
copyPortraits([...iconAssets.classIcons, ...iconAssets.npc, ...iconAssets.player]);

// ---------------------------------------------------------------------------
// Write output
// ---------------------------------------------------------------------------

fs.mkdirSync(path.join(outDir, 'data'), { recursive: true });
const payload = { trees };
const talentsPath = path.join(outDir, 'data', 'talents.json');
fs.writeFileSync(talentsPath, JSON.stringify(payload));

const metaPath = path.join(outDir, 'data', 'meta.json');
fs.writeFileSync(metaPath, JSON.stringify(meta));

const hash = crypto.createHash('sha1');
hash.update(fs.readFileSync(talentsPath));
hash.update(fs.readFileSync(metaPath));

const manifest = {
  builtAt: new Date().toISOString(),
  gameVersion: meta.gameVersion,
  dataVariant: DATA_VARIANT,
  source: path.relative(projectRoot, dataDir),
  counts: {
    trees: trees.length,
    talents: talentCount,
    icons: copiedIcons,
    portraits: copiedPortraits,
    classes: meta.classList.length,
    races: meta.races.length,
  },
  missingIcons: missingImages.size,
  sizeBytes: { talents: fs.statSync(talentsPath).size, meta: fs.statSync(metaPath).size },
  hash: hash.digest('hex').slice(0, 12),
};
manifest.scaling = scalingStats;
manifest.luaSourceHash = luaIndex?.sourceHash ?? null;
manifest.overlay = {
  file: path.relative(projectRoot, overlayPath),
  entries: overlayStats.total,
  accepted: overlayStats.accepted,
  rejected: overlayStats.rejected.length,
  superset: overlayStats.superset.length,
  supersetSample: overlayStats.superset.slice(0, 8),
  validatedAgainst: overlayStats.variants || 1,
};
fs.writeFileSync(path.join(outDir, 'data', 'scaling-report.json'), JSON.stringify(scalingStats, null, 2));
console.log('[build-data] scaling', JSON.stringify(scalingStats));
console.log(
  `[build-data] overlay ${overlayStats.accepted}/${overlayStats.total} accepted` +
  ` (re-validated against ${overlayStats.variants || 1} rendering(s))` +
  (overlayStats.superset.length ? `; ${overlayStats.superset.length} declare an input the formula does not read (audited in docs/overlay-reports/audit-superset-*.md)` : '') +
  (overlayStats.rejected.length ? `; dropped: ${overlayStats.rejected.slice(0, 5).join(' | ')}${overlayStats.rejected.length > 5 ? ` … +${overlayStats.rejected.length - 5}` : ''}` : ''),
);
fs.writeFileSync(path.join(outDir, 'data', 'manifest.json'), JSON.stringify(manifest, null, 2));

const kb = (n) => `${(n / 1024).toFixed(0)} KB`;
console.log(`[build-data] source       ${path.relative(projectRoot, dataDir)}`);
console.log(`[build-data] variant      ${DATA_VARIANT} (game ${meta.gameVersion})`);
console.log(`[build-data] trees        ${trees.length}`);
console.log(`[build-data] talents      ${talentCount}`);
console.log(`[build-data] categories   ${meta.categories.length}`);
console.log(`[build-data] icons        ${copiedIcons} copied${missingImages.size ? `, ${missingImages.size} missing` : ''}`);
console.log(`[build-data] portraits    ${copiedPortraits} copied`);
console.log(`[build-data] talents.json ${kb(manifest.sizeBytes.talents)}`);
console.log(`[build-data] meta.json    ${kb(manifest.sizeBytes.meta)}`);
console.log(`[build-data] hash         ${manifest.hash}`);
if (missingImages.size) {
  console.log(`[build-data] missing icons sample: ${[...missingImages].slice(0, 5).join(', ')}`);
}
