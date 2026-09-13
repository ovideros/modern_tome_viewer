/**
 * Build the monster encyclopedia dataset.
 *
 * Reads the ToME 1.7.6 Lua sources (base game + three DLCs), resolves NPC
 * inheritance and talent resolvers, matches Chinese localisation and Shockbolt
 * art, and writes:
 *
 *   public/data/monsters.json          the encyclopedia dataset
 *   public/data/monsters-report.json   coverage / diagnostics report
 *   public/img/npc/*.png               only the referenced art
 *
 * Run:  node scripts/monsters/build-monsters.mjs [--root <workspace>] [--out public]
 * It is wired into `npm run data` so a normal build refreshes it.
 */

import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

import { collectTemplates, resolveEntity, resolveTalents, resolveImage, classifyRank, RANKS, CATEGORY_LABELS, SOURCES } from './extract.mjs';
import { buildImageIndex, buildArtLookup, copyImages } from './images.mjs';
import { readLocale, mergeLocales, translate, translateEntityWord } from './locale.mjs';
import { loadLocales, readLocaleSnapshot } from './locale-snapshot.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..', '..');

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token.startsWith('--')) {
      const key = token.slice(2);
      const next = argv[i + 1];
      if (next === undefined || next.startsWith('--')) args[key] = true;
      else { args[key] = next; i += 1; }
    }
  }
  return args;
}

const args = parseArgs(process.argv.slice(2));
const workspaceRoot = path.resolve(args.root || path.dirname(projectRoot));
const outDir = path.resolve(projectRoot, args.out || 'public');
const quiet = Boolean(args.quiet);

const log = (...parts) => { if (!quiet) console.log('[monsters]', ...parts); };

// ---------------------------------------------------------------------------
// Talent reference vocabulary
// ---------------------------------------------------------------------------

/** Known talent ids, taken from the built talent dataset so references resolve. */
function loadTalentIndex() {
  const file = path.join(outDir, 'data', 'talents.json');
  if (!fs.existsSync(file)) {
    log('talents.json not found; talent names will fall back to raw ids');
    return { ids: new Set(), names: new Map() };
  }
  const wire = JSON.parse(fs.readFileSync(file, 'utf8'));
  const ids = new Set();
  const names = new Map();
  for (const tree of wire.trees ?? []) {
    for (const talent of tree.talents ?? []) {
      if (!talent?.id) continue;
      ids.add(talent.id);
      names.set(talent.id, { name: talent.name, tree: tree.id, treeName: tree.name });
    }
  }
  return { ids, names };
}

/** Engine class id -> display name, from the built metadata. */
function loadClassNames() {
  const file = path.join(outDir, 'data', 'meta.json');
  if (!fs.existsSync(file)) return new Map();
  const meta = JSON.parse(fs.readFileSync(file, 'utf8'));
  const map = new Map();
  for (const cls of meta.classes ?? []) map.set(cls.id, cls.name);
  return map;
}

/**
 * Class ids live in `mod/class/<File>.lua`; `auto_classes` entries name a Lua
 * file, not a class id. This maps the ones that actually appear in NPC data.
 */
function classDisplayName(raw, classNames) {
  if (!raw) return null;
  const id = String(raw).replace(/\.lua$/, '').toLowerCase().replace(/[^a-z0-9]+/g, '_');
  return classNames.get(id) ?? classNames.get(id.replace(/^class_/, '')) ?? null;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const started = Date.now();

  // Prefer the live locale files from a full checkout; fall back to the
  // committed normalized snapshot so a clean clone still gets Chinese names.
  const snapshotPath = path.join(projectRoot, 'data/raw/locales/zh_hans.json');
  const live = loadLocales(workspaceRoot);
  let locale;
  if (live.entries > 0) {
    locale = live;
    log(`locale: ${locale.map.size} entries from ${live.available}/${live.expected} live locale files`);
    // Keep the committed snapshot in step with the sources it was built from.
    const { writeLocaleSnapshot } = await import('./locale-snapshot.mjs');
    writeLocaleSnapshot(snapshotPath, locale);
  } else {
    locale = readLocaleSnapshot(snapshotPath);
    if (!locale) throw new Error('no locale files and no data/raw/locales/zh_hans.json snapshot; run npm run data:locale with the game sources present');
    log(`locale: ${locale.map.size} entries from committed snapshot (${path.relative(projectRoot, snapshotPath)})`);
  }

  const talentIndex = loadTalentIndex();
  const classNames = loadClassNames();

  const { records, byDefineAs, diagnostics, fileStats } = collectTemplates(workspaceRoot);
  log(`parsed ${records.length} templates from ${fileStats.reduce((n, s) => n + s.files, 0)} files`);

  const { index: imageIndex, archives, missing: missingArt } = buildImageIndex(workspaceRoot, {
    dlcSources: SOURCES.filter((s) => s.id !== 'tome').map((s) => ({ id: s.id, dir: s.dir })),
  });
  const artLookup = buildArtLookup(imageIndex);
  log(`art index: ${imageIndex.size} images${missingArt.length ? ` (missing art sources: ${missingArt.join(', ')})` : ''}`);
  if (missingArt.length) {
    // The gfx pack and the DLC art are large vendored binaries that the
    // repository does not track, so a clean clone legitimately has no art. The
    // page degrades to a placeholder; say so rather than failing the build.
    log('some art sources are absent; monster images will be reported as gaps');
  }

  const monsters = [];
  const abstractTemplates = [];
  const unknownTalentRefs = new Map();
  const missingTranslation = new Map();
  const missingTypeLabels = new Map();
  const imageGaps = [];
  const unresolved = [];
  const usedImages = new Set();
  const sourceFileHashes = {};

  /**
   * Chinese label from the engine's own context table.
   *
   * `type` / `subtype` are displayed by the game through
   * `_t(self.type, "entity type")` (mod/class/Actor.lua), so the context table
   * is authoritative and the flat map is only a fallback. `null` means "no
   * translation", which the page renders as the English word.
   */
  const labelOf = (kind, value) => {
    if (!value) return null;
    const hit = translateEntityWord(locale, kind, value);
    if (hit.status === 'exact') return hit.text;
    missingTypeLabels.set(`${kind}: ${value}`, (missingTypeLabels.get(`${kind}: ${value}`) ?? 0) + 1);
    return null;
  };

  for (const record of records) {
    const resolved = resolveEntity(record, byDefineAs);
    const fields = resolved.fields;

    if (resolved.missing.length) {
      for (const miss of resolved.missing) {
        unresolved.push({ id: record.id, file: record.file, line: record.line, reason: miss.reason, base: miss.base });
      }
    }

    const hasName = typeof fields.name === 'string' && fields.name.length > 0;
    const isAbstract = /^BASE_/.test(record.defineAs ?? '') || !hasName;
    const rank = typeof fields.rank === 'number' ? fields.rank : null;
    const category = classifyRank(rank);
    const rankMeta = RANKS[rank] ?? null;

    if (isAbstract) {
      abstractTemplates.push({
        id: record.id,
        defineAs: record.defineAs,
        name: hasName ? fields.name : null,
        source: record.source,
        file: record.file,
        line: record.line,
        childCount: 0,
      });
      continue;
    }

    const talentConfig = resolveTalents(resolved.talentSources);
    const seenRefs = new Set();
    const noteTalent = (id, kind) => {
      if (talentIndex.ids.has(id)) return;
      const key = `${id}`;
      const entry = unknownTalentRefs.get(key) ?? { id, kinds: new Set(), monsters: new Set() };
      entry.kinds.add(kind);
      entry.monsters.add(record.id);
      unknownTalentRefs.set(key, entry);
      seenRefs.add(id);
    };
    for (const talent of talentConfig.fixed) noteTalent(talent.id, 'fixed');
    for (const pool of talentConfig.rngPools) for (const talent of pool.talents) noteTalent(talent.id, 'rngtalents');
    for (const set of talentConfig.rngSets) for (const talent of set) noteTalent(talent.id, 'rngtalentsets');

    const nameZh = translate(locale.map, fields.name);
    if (nameZh.status === 'missing') {
      missingTranslation.set(fields.name, (missingTranslation.get(fields.name) ?? 0) + 1);
    }
    const descRaw = typeof fields.desc === 'string' ? fields.desc : null;
    const descZh = descRaw ? translate(locale.map, descRaw) : null;

    const image = resolveImage(fields, imageIndex, artLookup);
    if (image.image) usedImages.add(image.image);
    if (!image.image) {
      imageGaps.push({ id: record.id, name: fields.name, candidate: image.candidate, file: record.file, kind: image.kind });
    }

    const levelRange = Array.isArray(fields.level_range?.__array)
      ? fields.level_range.__array
      : fields.level_range && typeof fields.level_range === 'object'
        ? [fields.level_range['1'] ?? fields.level_range[1] ?? null, fields.level_range['2'] ?? fields.level_range[2] ?? null]
        : null;

    monsters.push({
      id: record.id,
      defineAs: record.defineAs,
      variantOf: record.variantOf ?? null,
      name: fields.name,
      nameZh: nameZh.status === 'missing' ? null : nameZh.text,
      nameStatus: nameZh.status,
      type: fields.type ?? null,
      // Chinese for the two game words, from the entity context tables. The
      // English stays alongside it: the filter tree and the detail panel show
      // both, and the page falls back to English when nothing translates it.
      typeZh: labelOf('entity type', fields.type),
      subtype: fields.subtype ?? null,
      subtypeZh: labelOf('entity subtype', fields.subtype),
      rank,
      rankKey: rankMeta?.key ?? null,
      category,
      categoryLabel: CATEGORY_LABELS[category],
      unique: fields.unique === true,
      randboss: fields.randboss === true,
      noDifficultyRandomClass: fields.no_difficulty_random_class === true,
      rarity: typeof fields.rarity === 'number' ? fields.rarity : null,
      levelRange,
      lifeRating: typeof fields.life_rating === 'number' ? fields.life_rating : null,
      sizeCategory: typeof fields.size_category === 'number' ? fields.size_category : null,
      expWorth: typeof fields.exp_worth === 'number' ? fields.exp_worth : null,
      canMultiply: typeof fields.can_multiply === 'number' ? fields.can_multiply : null,
      faction: typeof fields.faction === 'string' ? fields.faction : null,
      // These are the resolved template multipliers. A missing field means
      // the engine default of 1.0 (100%); keeping null here lets the UI say
      // which speeds are actually declared or inherited by the template.
      speed: {
        global: typeof fields.global_speed_base === 'number' ? fields.global_speed_base : null,
        movement: typeof fields.movement_speed === 'number' ? fields.movement_speed : null,
        combat: typeof fields.combat_physspeed === 'number' ? fields.combat_physspeed : null,
        spell: typeof fields.combat_spellspeed === 'number' ? fields.combat_spellspeed : null,
        mind: typeof fields.combat_mindspeed === 'number' ? fields.combat_mindspeed : null,
      },
      autoClasses: normalizeAutoClasses(fields.auto_classes, classNames),
      desc: descRaw,
      descZh: descZh && descZh.status !== 'missing' ? descZh.text : null,
      descStatus: descZh?.status ?? 'none',
      image: image.image,
      imageKind: image.kind,
      imageMatch: image.match ?? null,
      imageCandidate: image.candidate ?? null,
      layers: image.layerMeta?.length ? image.layerMeta : null,
      tall: image.tall || null,
      wide: image.wide || null,
      talents: talentConfig.fixed.map((t) => ({
        id: t.id,
        level: t.level ?? null,
        growth: t.growth ?? null,
        origin: t.origin,
      })),
      rngPools: talentConfig.rngPools.map((pool) => ({
        count: pool.count,
        talents: pool.talents.map((t) => ({ id: t.id, level: t.level ?? null, growth: t.growth ?? null })),
      })),
      rngSets: talentConfig.rngSets.map((set) => set.map((t) => ({ id: t.id, level: t.level ?? null, growth: t.growth ?? null }))),
      inheritance: resolved.chain.length ? resolved.chain : null,
      source: record.source,
      file: record.file,
      line: record.line,
      zone: record.zone,
      unresolved: resolved.missing.length ? resolved.missing : null,
    });
  }

  // Count how many concrete templates inherit from each abstract one.
  const childCounts = new Map();
  for (const monster of monsters) {
    for (const parent of monster.inheritance ?? []) {
      childCounts.set(parent, (childCounts.get(parent) ?? 0) + 1);
    }
  }
  for (const template of abstractTemplates) {
    template.childCount = childCounts.get(template.defineAs) ?? childCounts.get(template.id) ?? 0;
  }

  // -------------------------------------------------------------------------
  // Census
  // -------------------------------------------------------------------------

  const allIds = new Set(records.map((r) => r.id));
  const duplicateIds = new Set();
  const seenIds = new Set();
  for (const record of records) {
    if (seenIds.has(record.id)) duplicateIds.add(record.id);
    seenIds.add(record.id);
  }

  const census = {
    templates: records.length,
    abstract: abstractTemplates.length,
    concrete: monsters.length,
    distinctNames: new Set(monsters.map((m) => m.name)).size,
    duplicateDefineAs: [...duplicateIds].map((id) => ({ id })),
    byCategory: {},
    bySource: {},
    bySourceCategory: {},
    fixedBosses: monsters.filter((m) => m.rank !== null && m.rank >= 3.5).length,
    uniqueFlagged: monsters.filter((m) => m.unique).length,
    /**
     * Fixed bosses that are *not* opted out of the difficulty-added random
     * class. `NPC:addedToLevel` gives `rank >= 3.5` bosses a random class on
     * Nightmare+ unless `no_difficulty_random_class` is set, which is the
     * mechanism the handover asks about; `randboss` is the separate flag for
     * procedurally generated bosses and is not set on any fixed template.
     */
    randomBossCapable: monsters.filter((m) => m.rank !== null && m.rank >= 3.5 && !m.noDifficultyRandomClass).length,
    noDifficultyRandomClass: monsters.filter((m) => m.noDifficultyRandomClass).length,
    withTalents: monsters.filter((m) => m.talents.length > 0).length,
    withRandomGroups: monsters.filter((m) => m.rngPools.length > 0 || m.rngSets.length > 0).length,
    withImage: monsters.filter((m) => m.image).length,
    withChineseName: monsters.filter((m) => m.nameStatus === 'exact').length,
    // Type/subtype translation coverage: the filter tree is built from these
    // words, so a missing label would show untranslated English in the sidebar.
    distinctTypes: new Set(monsters.map((m) => m.type).filter(Boolean)).size,
    distinctSubtypes: new Set(monsters.map((m) => m.subtype).filter(Boolean)).size,
    withChineseType: monsters.filter((m) => m.typeZh).length,
    withChineseSubtype: monsters.filter((m) => m.subtypeZh).length,
    withSubtype: monsters.filter((m) => m.subtype).length,
    withSpeed: monsters.filter((m) => Object.values(m.speed).some((value) => value !== null)).length,
    namedLikeBase: monsters.filter((m) => /^BASE_/.test(m.defineAs ?? '')).length,
  };
  for (const monster of monsters) {
    census.byCategory[monster.category] = (census.byCategory[monster.category] ?? 0) + 1;
    census.bySource[monster.source] = (census.bySource[monster.source] ?? 0) + 1;
    const bucket = (census.bySourceCategory[monster.source] ??= {});
    bucket[monster.category] = (bucket[monster.category] ?? 0) + 1;
  }

  // -------------------------------------------------------------------------
  // Art
  // -------------------------------------------------------------------------

  const imageResult = copyImages({ index: imageIndex, archives }, [...usedImages].sort(), outDir);
  const missingArtSources = missingArt;
  log(`art copied: ${imageResult.copied.length}, missing: ${imageResult.missing.length}`);

  for (const source of SOURCES) {
    const root = path.join(workspaceRoot, source.dir);
    if (!fs.existsSync(root)) continue;
    const hash = crypto.createHash('sha256');
    const files = [];
    const walk = (dir) => {
      for (const entry of fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
        const full = path.join(dir, entry.name);
        if (entry.isDirectory()) walk(full);
        else if (entry.name.endsWith('.lua') && (full.includes('/npcs/') || path.basename(full) === 'npcs.lua')) files.push(full);
      }
    };
    walk(root);
    for (const file of files) hash.update(path.relative(workspaceRoot, file)).update(fs.readFileSync(file));
    sourceFileHashes[source.id] = hash.digest('hex').slice(0, 16);
  }

  const dataset = {
    version: 1,
    gameVersion: '1.7.6',
    builtAt: new Date().toISOString(),
    sources: SOURCES.map((s) => ({ ...s, files: fileStats.find((f) => f.id === s.id)?.files ?? 0, templates: fileStats.find((f) => f.id === s.id)?.entities ?? 0, hash: sourceFileHashes[s.id] ?? null })),
    categoryLabels: CATEGORY_LABELS,
    categories: Object.keys(CATEGORY_LABELS).map((key) => ({ key, label: CATEGORY_LABELS[key], count: census.byCategory[key] ?? 0 })),
    census,
    monsters: monsters.sort((a, b) => (a.nameZh ?? a.name).localeCompare(b.nameZh ?? b.name, 'zh-Hans-CN')),
  };

  const report = {
    builtAt: dataset.builtAt,
    census,
    files: fileStats,
    diagnostics,
    unresolved,
    imageGaps,
    imageCopied: imageResult.copied.length,
    imageMissing: imageResult.missing,
    missingArtSources: missingArtSources ?? [],
    unknownTalentRefs: [...unknownTalentRefs.values()].map((entry) => ({
      id: entry.id,
      kinds: [...entry.kinds],
      monsterCount: entry.monsters.size,
      examples: [...entry.monsters].slice(0, 5),
    })),
    missingTranslations: [...missingTranslation.entries()].map(([name, count]) => ({ name, count })).sort((a, b) => b.count - a.count),
    /** `type` / `subtype` words with no Chinese entry, so the tree stays English. */
    missingTypeLabels: [...missingTypeLabels.entries()].map(([name, count]) => ({ name, count })).sort((a, b) => b.count - a.count),
    abstractTemplates: abstractTemplates.sort((a, b) => b.childCount - a.childCount),
    elapsedMs: Date.now() - started,
  };

  fs.mkdirSync(path.join(outDir, 'data'), { recursive: true });
  fs.writeFileSync(path.join(outDir, 'data', 'monsters.json'), JSON.stringify(dataset));
  fs.writeFileSync(path.join(outDir, 'data', 'monsters-report.json'), JSON.stringify(report, null, 2));

  const size = fs.statSync(path.join(outDir, 'data', 'monsters.json')).size;
  log(`wrote monsters.json (${(size / 1024).toFixed(0)} KB) in ${report.elapsedMs} ms`);
  log(`census: ${census.concrete} concrete (${Object.entries(census.byCategory).map(([k, v]) => `${CATEGORY_LABELS[k] ?? k} ${v}`).join(' / ')}), ${census.abstract} abstract templates`);
  log(`coverage: image ${census.withImage}/${census.concrete}, chinese name ${census.withChineseName}/${census.concrete}, talents ${census.withTalents}/${census.concrete}`);
  log(
    `type labels: ${census.withChineseType}/${census.concrete} types, ` +
      `${census.withChineseSubtype}/${census.withSubtype} subtypes (${census.distinctTypes} / ${census.distinctSubtypes} distinct)` +
      (report.missingTypeLabels.length ? ` — missing: ${report.missingTypeLabels.map((e) => e.name).join(', ')}` : ''),
  );
  if (report.unknownTalentRefs.length) {
    log(`unknown talent refs: ${report.unknownTalentRefs.map((e) => e.id).join(', ')}`);
  }
}

/** `auto_classes` may be a string, a list, or a table of class definitions. */
function normalizeAutoClasses(raw, classNames) {
  if (!raw) return null;
  const list = [];
  const visit = (value) => {
    if (typeof value === 'string') list.push(value);
    else if (Array.isArray(value)) value.forEach(visit);
    else if (value && typeof value === 'object') {
      for (const [key, entry] of Object.entries(value)) {
        if (typeof entry === 'string') list.push(entry);
        else if (entry && typeof entry === 'object') {
          if (typeof entry.class === 'string') list.push(entry.class);
          else list.push(key);
        } else list.push(key);
      }
    }
  };
  visit(raw);
  const unique = [...new Set(list.filter((v) => typeof v === 'string' && v))];
  if (!unique.length) return null;
  return unique.map((entry) => ({ raw: entry, name: classDisplayName(entry, classNames) }));
}

await main();
