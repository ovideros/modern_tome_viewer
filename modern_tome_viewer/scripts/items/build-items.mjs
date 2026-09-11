/**
 * Build the item datasets for the two encyclopedia pages.
 *
 * Reads the ToME 1.7.6 Lua sources (base game + three DLCs) and writes:
 *
 *   public/data/egos.json        equipment ego affixes (#/egos)
 *   public/data/artifacts.json   fixed artifacts       (#/artifacts)
 *   public/data/items-report.json coverage / diagnostics
 *   public/img/object/**         only the artifact icons actually referenced
 *
 * No Lua is executed and no value is simulated: every property is carried as a
 * literal, a resolver with a recoverable range, a runtime function, or an
 * explicit "unknown" that the report accounts for.
 *
 * Run:  node scripts/items/build-items.mjs [--root <workspace>] [--out public]
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { keyName, literalOf } from '../monsters/lua-table.mjs';
import { literalOfTranslationCall } from '../monsters/extract.mjs';
import { readLocaleSnapshot } from '../monsters/locale-snapshot.mjs';
import { translate, translateEntityWord } from '../monsters/locale.mjs';
import { copyArtifactImages } from './images.mjs';
import {
  AREA_KEYS, AREA_ORDER, EQUIP_TYPES, NPC_TYPES, NON_EQUIP_ITEM_TYPES, SLOT_LABELS,
  extractProps, findField, itemFileList, normalizeEgoPath, resolveEgoPools, scanItems,
  stripFormatColors,
} from './extract-items.mjs';
import { egoNotes } from './summary.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..', '..');

function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith('--')) continue;
    const key = token.slice(2);
    const next = argv[i + 1];
    if (next === undefined || next.startsWith('--')) args[key] = true;
    else { args[key] = next; i += 1; }
  }
  return args;
}

const args = parseArgs(process.argv.slice(2));
const workspaceRoot = path.resolve(args.root || path.dirname(projectRoot));
const outDir = path.resolve(projectRoot, args.out || 'public');
const quiet = Boolean(args.quiet);
const log = (...parts) => { if (!quiet) console.log('[items]', ...parts); };

/** `type`/`subtype`/`slot` come from the base template, so they need resolving. */
const INHERITED = ['type', 'subtype', 'slot', 'offslot', 'image', 'display', 'moddable_tile', 'material_level', 'encumber', 'require', 'metallic'];

function readField(record, key) {
  return findField({ fields: record.ast }, key);
}

/**
 * Read a structural field (`type`, `subtype`, `slot`, `base`, ...) literally.
 *
 * These are engine identifiers, not display text: they are written bare
 * (`type = "weapon"`) and must never be unwrapped from a `_t` call.
 */
function literalField(record, key) {
  const value = literalOf(readField(record, key));
  return value === undefined ? null : value;
}

/** Fields whose value is display text and may be wrapped in `_t`. */
const TEXT_FIELDS = new Set(['name', 'desc', 'unided_name', 'special_desc', 'unided_name']);

/**
 * Read a display-text field, seeing through the game's `_t` wrapper.
 *
 * ToME writes long text as `desc = _t[[...]]` and short text as
 * `name = _t"..."`, so `literalOf` alone misses every translated field. The
 * unwrapper comes from the monster pipeline rather than being reimplemented.
 * Using it on structural fields would be wrong: it would turn a `_t`-wrapped
 * identifier into prose and break type/slot resolution.
 */
function textField(record, key) {
  const node = readField(record, key);
  if (!node) return null;
  const direct = literalOf(node);
  if (direct !== undefined) return direct;
  const wrapped = literalOfTranslationCall(node);
  return wrapped === undefined ? null : wrapped;
}

/** Walk `base` links collecting inherited scalar fields. */
function resolveRecord(record, byDefineAs, seen = new Set()) {
  const own = {};
  for (const key of INHERITED) {
    const value = literalOf(readField(record, key));
    if (value !== undefined) own[key] = value;
  }
  const base = literalField(record, 'base');
  if (!base || seen.has(record.defineAs ?? `${record.file}:${record.line}`)) {
    return { fields: own, chain: [], missingBase: null };
  }
  const parent = byDefineAs.get(base);
  if (!parent || parent === record) {
    return { fields: own, chain: [], missingBase: base };
  }
  seen.add(record.defineAs ?? `${record.file}:${record.line}`);
  const resolved = resolveRecord(parent, byDefineAs, seen);
  const fields = { ...resolved.fields, ...own };
  return { fields, chain: [base, ...resolved.chain], missingBase: resolved.missingBase };
}

// ---------------------------------------------------------------------------
// Localisation
// ---------------------------------------------------------------------------

/**
 * Wrap the locale snapshot in the two lookups the item build needs.
 *
 * `translate` takes the flat `en -> zh` map while `translateEntityWord` takes
 * the whole snapshot plus the engine's context name; both shapes come from the
 * monster pipeline and are reused rather than re-derived.
 */
function makeLocale(snapshot) {
  /** Chinese text for a game `_t` string, or null when untranslated. */
  const text = (value) => {
    if (typeof value !== 'string' || !value) return null;
    const hit = translate(snapshot.map, value);
    return hit.status === 'exact' ? hit.text : null;
  };
  /** Chinese name for an entity `type` / `subtype`, via the engine's context. */
  const entityWord = (kind, value) => {
    if (!value) return null;
    const hit = translateEntityWord(snapshot, kind, value);
    return hit.status === 'exact' ? hit.text : null;
  };
  return { text, entityWord, size: snapshot.map.size };
}

/**
 * Chinese label for a property, with its separator.
 *
 * Mechanical entries carry the raw `_t` label from `Object.lua`; the snapshot is
 * keyed by that exact string. Manual entries already hold Chinese. The label's
 * trailing separator is preserved (`护甲值：` vs `护甲值`) so the UI can put the
 * value on the other side of it.
 */
function labelFor(prop, locale, missingLabels) {
  if (prop.labelZhManual) return splitSeparator(prop.labelZhManual);
  const zh = prop.label ? locale.text(prop.label) : null;
  if (zh) return splitSeparator(zh);
  if (prop.label) missingLabels.set(prop.label, (missingLabels.get(prop.label) ?? 0) + 1);
  return { text: prop.label ?? prop.key, separator: '', untranslated: Boolean(prop.label) };
}

function splitSeparator(text) {
  const trimmed = String(text).trim();
  const match = /^(.*?)([：:]\s*|\s*[：:])$/.exec(trimmed);
  if (match) return { text: match[1], separator: '：' };
  return { text: trimmed.replace(/[：:]\s*$/, ''), separator: '' };
}

// ---------------------------------------------------------------------------
// Base items -> ego pools
// ---------------------------------------------------------------------------

/**
 * Map every base item template to the ego pools it can roll.
 *
 * The link is the base template's own `egos = "<path>"` field. `BASE_GREATMAUL`
 * and `BASE_LONGSWORD` both point at `weapon.lua`, so the two map to the same
 * pool without any name-based guessing.
 */
function buildBaseIndex(records, byDefineAs) {
  const baseItems = [];
  const byPool = new Map();
  for (const record of records) {
    const egosPath = literalField(record, 'egos');
    if (typeof egosPath !== 'string') continue;
    const pool = normalizeEgoPath(egosPath);
    if (!pool) continue;
    const resolved = resolveRecord(record, byDefineAs);
    const item = {
      defineAs: record.defineAs,
      name: literalField(record, 'name'),
      pool,
      type: resolved.fields.type ?? null,
      subtype: resolved.fields.subtype ?? null,
      slot: resolved.fields.slot ?? null,
      source: record.source,
      file: record.file,
      line: record.line,
    };
    baseItems.push(item);
    const list = byPool.get(pool) ?? [];
    list.push(item);
    byPool.set(pool, list);
  }
  return { baseItems, byPool };
}

// ---------------------------------------------------------------------------
// Ego extraction
// ---------------------------------------------------------------------------

/**
 * True when two definitions of the same identity are the same item.
 *
 * Several artifacts are declared verbatim in more than one zone file
 * (`RUNE_RIFT` in `daikara` and `temporal-rift`, `VOID_STAR` in
 * `abashed-expanse` and `unhallowed-morass`). Those are one item reachable from
 * several places, so they collapse into one entry that lists every location.
 * A same-`define_as` pair that actually differs is a real variant and must stay
 * separate, which is why the comparison is on the parsed definition itself and
 * not on the identifier.
 */
function sameDefinition(a, b) {
  return JSON.stringify(normalizeAst(a)) === JSON.stringify(normalizeAst(b));
}

function normalizeAst(record) {
  return {
    base: literalField(record, 'base'),
    name: literalField(record, 'name'),
    type: literalField(record, 'type'),
    subtype: literalField(record, 'subtype'),
    // Source positions are stripped: the AST carries a `line` on every node, so
    // two identical definitions in different files would otherwise compare as
    // different purely because they sit at different offsets.
    fields: stripPositions(record.ast.map ?? []),
  };
}

/** Deep-copy an AST fragment without its `line` annotations. */
function stripPositions(node) {
  if (Array.isArray(node)) return node.map(stripPositions);
  if (!node || typeof node !== 'object') return node;
  const out = {};
  for (const [key, value] of Object.entries(node)) {
    if (key === 'line' || key === 'file') continue;
    out[key] = stripPositions(value);
  }
  return out;
}

/**
 * Stable ego identity.
 *
 * `keywords` is the engine's own ego key, but the charm egos define a normal
 * and a `greater_ego` version under the same name and keyword. Those are two
 * distinct affixes, so the greater tier is part of the id rather than a reason
 * to drop one of them. `unique_ego` (a string) is the engine's unique tag for
 * charm procs and is preferred when present.
 */
function egoKey(record, fieldMapUnused) {
  const keywords = readField(record, 'keywords');
  let key = null;
  if (keywords?.kind === 'table') {
    const first = keywords.map?.[0];
    key = keyName(first?.key);
  }
  if (!key) {
    const name = literalField(record, 'name');
    key = typeof name === 'string' && name.trim()
      ? name.trim().replace(/[^a-z0-9]+/gi, '_').replace(/^_+|_+$/g, '').toLowerCase()
      : `anon_${record.line}`;
  }
  return key;
}

/** The `greater_ego` / `unique_ego` variant marker, or null for the base tier. */
function egoVariant(record) {
  if (literalField(record, 'greater_ego') === 1 || readField(record, 'greater_ego')?.value === true) return 'greater';
  return null;
}

/**
 * Names that the engine completes at generation time.
 *
 * `" of fire (#RESIST#)"` renders as "of fire (+15%)": `#RESIST#` is filled from
 * the ego's own resistance value (see `descAttribute` in `mod/class/Object.lua`).
 * The damage type is fixed per definition — this is *not* a random variant — so
 * the placeholder is surfaced as a named token rather than expanded into a
 * number the site cannot know.
 */
export const NAME_TOKENS = {
  RESIST: { zh: '抗性数值', note: '由该词缀自身提供的抗性数值填充' },
  STATBONUS: { zh: '属性加值', note: '由该词缀提供的属性加值填充' },
  MASTERY: { zh: '技能树加成', note: '由该词缀提供的技能树加值填充' },
  REGEN: { zh: '回复数值', note: '由该词缀提供的回复数值填充' },
  USE_TALENT: { zh: '技能名', note: '由该词缀触发的技能名填充' },
};

export function nameTokenKeys(rawName) {
  if (typeof rawName !== 'string') return [];
  return [...rawName.matchAll(/#([A-Z_]+)#/g)].map((m) => m[1]).filter((key) => NAME_TOKENS[key]);
}

/** The name without the `#TOKEN#` markers and without the engine's colour codes. */
export function cleanEgoName(rawName) {
  if (typeof rawName !== 'string') return '';
  return rawName.replace(/#[A-Z_]+#/g, '').replace(/\s+/g, ' ').trim();
}

function buildEgo(record, context) {
  const { fieldMap, poolsByPath, baseIndex, locale, missingLabels, unmappedKeys } = context;
  const pool = normalizeEgoPath(record.file);
  const prefix = literalField(record, 'prefix') === true;
  const suffix = literalField(record, 'suffix') === true;
  const rawName = textField(record, 'name');
  const levelRange = readField(record, 'level_range');
  const levelValues = (levelRange?.array ?? []).map((n) => literalOf(n)).filter((n) => typeof n === 'number');

  const keyword = egoKey(record);
  const variant = egoVariant(record);
  const uniqueTag = literalField(record, 'unique_ego');
  const id = [record.source, pool ?? 'none', typeof uniqueTag === 'string' ? uniqueTag : keyword, variant]
    .filter(Boolean).join(':');

  // Which ego pools this definition is reachable from: its own pool plus every
  // pool that `load()`s it (steamsaw loads weapon + shield, armour shares
  // armor.lua, and so on).
  const reachable = new Set([pool]);
  for (const candidate of poolsByPath.values()) {
    if (candidate.loads.includes(pool)) {
      reachable.add(candidate.pool);
      for (const transitive of resolveEgoPools(poolsByPath, candidate.pool)) reachable.add(transitive);
    }
  }
  if (pool) {
    for (const transitive of resolveEgoPools(poolsByPath, pool)) reachable.add(transitive);
  }

  const applicable = [];
  const seenItems = new Set();
  for (const candidatePool of reachable) {
    for (const item of baseIndex.byPool.get(candidatePool) ?? []) {
      const marker = `${item.type ?? ''}/${item.subtype ?? ''}`;
      if (seenItems.has(marker)) continue;
      seenItems.add(marker);
      applicable.push({
        pool: candidatePool,
        type: item.type,
        typeZh: locale.entityWord('type', item.type),
        subtype: item.subtype,
        subtypeZh: locale.entityWord('subtype', item.subtype),
        slot: item.slot,
        slotZh: item.slot ? SLOT_LABELS[item.slot] ?? item.slot : null,
        via: candidatePool === pool ? 'own' : 'shared',
        example: item.name,
      });
    }
  }
  applicable.sort((a, b) => String(a.subtype).localeCompare(String(b.subtype)));

  const props = extractProps(record.ast, fieldMap, { file: record.file, fileId: record.fileId, line: record.line });
  for (const key of props.unmapped.keys()) unmappedKeys.set(key, (unmappedKeys.get(key) ?? 0) + 1);

  const areas = [];
  for (const areaKey of AREA_ORDER) {
    const group = props.byArea.get(areaKey);
    if (!group || group.props.length === 0) continue;
    areas.push({
      area: areaKey,
      props: group.props.map((prop) => renderProp(prop, locale, missingLabels)),
    });
  }

  const cleanedName = cleanEgoName(rawName);
  const nameZh = locale.text(rawName) ?? locale.text(` ${cleanedName}`) ?? locale.text(cleanedName);
  const keywordKey = keyword;
  // The part of the effect that is not a property table: a charm's proc, a
  // shield's on-block effect, a staff's imbued spell. Carried as prose because
  // there is no number to carry, and it is what lets the list show an effect
  // without the reader opening each row.
  const notes = egoNotes(id, record, locale).notes;

  return {
    id,
    source: record.source,
    file: record.fileId,
    line: record.line,
    pool: pool ?? 'none',
    pools: [...reachable].sort(),
    position: prefix ? 'prefix' : suffix ? 'suffix' : 'unknown',
    // `greater_ego` marks the "greater" tier; `unique_ego` means the ego is
    // itself unique and must not be treated as a fixed-artifact marker.
    greater: variant === 'greater',
    // The non-greater ego this one is the advanced tier of, so the page can
    // show the pair together instead of as two unrelated rows.
    variantOf: variant ? `${record.source}:${pool ?? 'none'}:${keyword}` : null,
    uniqueEgoTag: typeof uniqueTag === 'string' ? uniqueTag : null,
    rarity: literalField(record, 'rarity'),
    levelRange: levelValues.length >= 2 ? [levelValues[0], levelValues[1]] : levelValues,
    cost: literalOf(readField(record, 'cost')),
    powerSources: powerSourcesOf(record),
    name: { raw: rawName ?? null, clean: cleanedName, zh: nameZh, tokens: nameTokenKeys(rawName) },
    keyword: keywordKey,
    keywords: keywordList(record),
    desc: textField(record, 'desc'),
    applicable,
    areas,
    notes,
    unmapped: [...new Set([...props.unmapped.keys()])],
  };
}

function powerSourcesOf(record) {
  const node = readField(record, 'power_source');
  if (node?.kind !== 'table') return [];
  return (node.map ?? []).map((entry) => keyName(entry.key)).filter(Boolean);
}

function keywordList(record) {
  const node = readField(record, 'keywords');
  if (node?.kind !== 'table') return [];
  return (node.map ?? []).map((entry) => keyName(entry.key)).filter(Boolean);
}

/**
 * Turn one extracted property into the wire shape the UI renders.
 *
 * The extractor also produces a `formula` (`max`, `add`, the transform, the
 * material span) for tests and reports, but it is **not** shipped: every value
 * that needs it already carries `materialRanges`, and the recipe would add
 * ~150 KB of repeated key names to `egos.json` for information the 属性出处 panel
 * states in prose.
 *
 * The `labelZh` / `separator` split lets the page align labels in a grid while
 * keeping the game's own term. `unit` and `sign` carry the formatting the
 * engine's format string implied, so the front end never has to guess whether
 * `8` means `8` or `8%`.
 */
function renderProp(prop, locale, missingLabels) {
  const label = labelFor(prop, locale, missingLabels);
  const out = {
    key: prop.key,
    kind: prop.kind,
    // `area`, `label`, `format` and `unit` come from the dataset's `fieldMeta`
    // table, keyed by `key`; only row-specific facts are stored here.
    separator: label.separator,
    untranslatedLabel: Boolean(label.untranslated) || undefined,
    overridden: prop.overridden === true || undefined,
    source: prop.sourceRef,
  };
  if (prop.kind === 'table' && prop.items) {
    out.items = prop.items.map((item) => ({
      key: item.key,
      code: item.code ?? item.statCode ?? null,
      ref: item.ref ?? null,
      kind: item.kind,
      value: item.value,
      range: item.range ?? null,
      materialRanges: item.materialRanges ?? null,
      meaning: item.meaning ?? null,
      resolver: item.resolver ?? null,
      text: item.text ?? null,
      line: item.line,
    }));
  } else {
    out.kind = prop.kind;
    out.value = prop.value;
    out.range = prop.range ?? null;
    out.materialRanges = prop.materialRanges ?? null;
    out.meaning = prop.meaning ?? null;
    out.resolver = prop.resolver ?? null;
    out.text = prop.text ?? null;
    out.ref = prop.ref ?? null;
  }
  if (prop.manualMapping) out.manualMapping = true;
  return out;
}

// ---------------------------------------------------------------------------
// Artifact extraction
// ---------------------------------------------------------------------------

/** Type-and-slot based inclusion verdict, with the reason recorded either way. */
export function classifyArtifact(record, resolved) {
  const type = resolved.fields.type ?? null;
  const name = literalField(record, 'name');
  const quest = literalField(record, 'quest') === true;

  if (!literalField(record, 'unique')) return { include: false, reason: 'not-unique' };
  if (!name) return { include: false, reason: 'no-name' };
  if (!type) return { include: false, reason: 'no-type' };
  if (NPC_TYPES.has(type)) return { include: false, reason: 'npc-definition' };
  if (quest) return { include: false, reason: 'quest-item' };
  if (EQUIP_TYPES.has(type)) return { include: true, reason: 'equipment' };
  if (NON_EQUIP_ITEM_TYPES.has(type)) return { include: true, reason: 'non-equipment-item', nonEquipment: true };
  return { include: false, reason: `unclassified-type:${type}` };
}

function buildArtifact(record, resolved, context) {
  const { fieldMap, locale, missingLabels, unmappedKeys } = context;
  const props = extractProps(record.ast, fieldMap, { file: record.file, fileId: record.fileId, line: record.line });
  for (const key of props.unmapped.keys()) unmappedKeys.set(key, (unmappedKeys.get(key) ?? 0) + 1);

  const areas = [];
  for (const areaKey of AREA_ORDER) {
    const group = props.byArea.get(areaKey);
    if (!group || group.props.length === 0) continue;
    areas.push({
      area: areaKey,
      props: group.props.map((prop) => renderProp(prop, locale, missingLabels)),
    });
  }

  const type = resolved.fields.type ?? null;
  const subtype = resolved.fields.subtype ?? null;
  const rawName = textField(record, 'name');
  const nameZh = locale.text(rawName);
  const desc = textField(record, 'desc');
  const flavorZh = desc ? locale.text(desc) : null;
  const require = readField(record, 'require');
  const levelRange = (readField(record, 'level_range')?.array ?? []).map((n) => literalOf(n));

  return {
    id: artifactId(record),
    source: record.source,
    file: record.fileId,
    line: record.line,
    defineAs: record.defineAs,
    base: literalField(record, 'base'),
    chain: resolved.chain,
    missingBase: resolved.missingBase,
    name: rawName,
    nameZh,
    unidedName: textField(record, 'unided_name'),
    // English is kept for search and cross-checking even when Chinese exists.
    desc,
    descZh: flavorZh,
    type,
    typeZh: locale.entityWord('type', type),
    subtype,
    subtypeZh: locale.entityWord('subtype', subtype),
    slot: resolved.fields.slot ?? null,
    slotZh: resolved.fields.slot ? SLOT_LABELS[resolved.fields.slot] ?? resolved.fields.slot : null,
    offslot: resolved.fields.offslot ?? null,
    tier: literalField(record, 'material_level'),
    // `rarity` is a *relative generation weight*, not a drop chance; the page
    // must never render it as a percentage. `level_range` is the level band the
    // item can generate in, not the level needed to equip it.
    rarity: literalField(record, 'rarity'),
    levelRange: levelRange.length >= 2 ? [levelRange[0], levelRange[1]] : levelRange,
    cost: literalOf(readField(record, 'cost')),
    encumber: resolved.fields.encumber ?? null,
    metallic: resolved.fields.metallic ?? null,
    image: resolved.fields.image ?? null,
    quest: literalField(record, 'quest') === true,
    powerSources: powerSourcesOf(record),
    require: require ? requirementOf(require) : null,
    useTalent: useTalentOf(record),
    usePower: usePowerOf(record, locale),
    specialDesc: specialDescOf(record, locale),
    properties: areas,
    unlidded: [...new Set([...props.unmapped.keys()])],
    sets: literalField(record, 'set_list') ?? null,
  };
}

/** `tome-src-full/data/zones/dreadfell/objects.lua` -> `dreadfell`. */
function zoneOf(file) {
  const match = /\/data\/zones\/([^/]+)\//.exec(file ?? '');
  return match ? match[1] : null;
}

/**
 * Stable artifact identity.
 *
 * `define_as` is unique only within one load context — the game legitimately
 * re-declares some names in several zone files — so the source package is part
 * of the id. Definitions without a `define_as` fall back to their file and line,
 * which is reproducible as long as the source tree is unchanged.
 */
function artifactId(record) {
  if (record.defineAs) return `${record.source}:${record.defineAs}`;
  const slug = record.file.replace(/^.*\/data\//, '').replace(/\.lua$/, '').replace(/\//g, '-');
  return `${record.source}:${slug}:${record.line}`;
}

/** `require = { stat = {...}, level = 10, talent = {...} }` -> readable rows. */
function requirementOf(node) {
  if (node.kind !== 'table') return null;
  const out = [];
  for (const entry of node.map ?? []) {
    const key = keyName(entry.key);
    const value = entry.value;
    if (value?.kind === 'number') {
      out.push({ kind: key, amount: value.value });
    } else if (value?.kind === 'table') {
      const stats = (value.map ?? []).map((inner) => ({
        key: keyName(inner.key),
        amount: literalOf(inner.value),
      }));
      out.push({ kind: key, stats });
    }
  }
  return out.length ? out : null;
}

/** `use_talent = { id = Talents.T_X, level = 2, power = 20 }`. */
function useTalentOf(record) {
  const node = readField(record, 'use_talent');
  if (node?.kind !== 'table') return null;
  const id = readField(record, 'use_talent')?.map?.find((m) => keyName(m.key) === 'id')?.value;
  const talentId = id?.kind === 'ref' ? id.path[id.path.length - 1] : literalOf(id);
  if (!talentId) return null;
  const level = node.map.find((m) => keyName(m.key) === 'level');
  const power = node.map.find((m) => keyName(m.key) === 'power');
  return {
    talentId,
    talentRef: id?.kind === 'ref' ? id.path.join('.') : null,
    level: level ? literalOf(level.value) : null,
    power: power ? literalOf(power.value) : null,
  };
}

/**
 * `use_power` describes an actively triggered ability.
 *
 * Its `name` is usually a function of the wielder (`litepower(self, who)`), so
 * it cannot be rendered as a fixed number. The source text is kept verbatim and
 * flagged, which is exactly the "explain, do not simulate" case.
 */
function usePowerOf(record, locale) {
  const node = readField(record, 'use_power');
  if (node?.kind !== 'table') return null;
  const getName = node.map.find((m) => keyName(m.key) === 'name');
  const raw = literalOf(getName?.value) ?? literalOfTranslationCall(getName?.value);
  const isFunction = getName?.value?.kind === 'function';
  const description = isFunction ? extractFunctionString(getName.value) : raw;
  return {
    name: description ?? null,
    nameIsFunction: isFunction,
    nameZh: description ? locale.text(description) : null,
    power: literalOf(node.map.find((m) => keyName(m.key) === 'power')?.value) ?? null,
    cooldown: literalOf(node.map.find((m) => keyName(m.key) === 'cooldown')?.value) ?? null,
  };
}

/**
 * Pull the literal tooltip text out of a small `function(self, who) return _t"..."
 * end`. Only a single literal return is understood; anything more complex is
 * reported as a function so the page can say "computed at use time".
 */
function extractFunctionString(node) {
  // The shared parser keeps the first literal `return` of a function body on
  // `infoText` (see `skipBlockStatement2`), which is exactly the display text of
  // a `desc`/`name` callback. Anything more complex stays unresolved rather than
  // being guessed at, and is reported as `computed`.
  if (typeof node.infoText === 'string') return node.infoText;
  return null;
}

/** `special_desc` is a function returning the item's special rule as text. */
function specialDescOf(record, locale) {
  const node = readField(record, 'special_desc');
  if (!node) return null;
  if (node.kind === 'string') {
    return { en: node.value, zh: locale.text(node.value) };
  }
  if (node.kind === 'function') {
    const text = extractFunctionString(node);
    return text ? { en: text, zh: locale.text(text), computed: true } : { computed: true, en: null, zh: null };
  }
  return null;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main() {
  const started = Date.now();
  const snapshotPath = path.join(projectRoot, 'data/raw/locales/zh_hans.json');
  const snapshot = readLocaleSnapshot(snapshotPath);
  if (!snapshot) throw new Error('data/raw/locales/zh_hans.json is missing; run npm run data:locale with the game sources present');
  const locale = makeLocale(snapshot);
  log(`locale: ${snapshot.map.size} entries`);

  const scan = scanItems(workspaceRoot);
  log(`scanned ${scan.fileCount} files, ${scan.records.length} definitions, ${scan.poolsByPath.size} ego pools, ${scan.fieldMap.fields.size} mapped fields`);
  if (scan.fieldMap.fields.size === 0) throw new Error('field map is empty; mod/class/Object.lua was not read');

  // Source paths are interned into a dictionary. Every definition, property and
  // `source` reference then stores a short id instead of repeating a ~70 character
  // path hundreds of times per item, which is the bulk of the dataset size.
  const fileIds = new Map();
  const filePaths = [];
  const fileIdOf = (file) => {
    let id = fileIds.get(file);
    if (id === undefined) {
      id = filePaths.length;
      fileIds.set(file, id);
      filePaths.push(file);
    }
    return id;
  };
  for (const record of scan.records) record.fileId = fileIdOf(record.file);

  // A global `define_as` index is required to resolve `base` links, which is
  // what decides an item's real type/slot (most definitions declare neither).
  const byDefineAs = new Map();
  for (const record of scan.records) {
    if (record.defineAs && !byDefineAs.has(record.defineAs)) byDefineAs.set(record.defineAs, record);
  }

  const baseIndex = buildBaseIndex(scan.records, byDefineAs);
  log(`base item templates with ego pools: ${baseIndex.baseItems.length}`);

  const missingLabels = new Map();
  const unmappedKeys = new Map();
  const missingTranslations = [];
  const missingImages = [];
  // Locations that collapse into one row because the definition is identical.
  const duplicateDefinitions = [];
  const skipped = new Map();

  const egos = [];
  const artifacts = [];
  const seenEgoIds = new Map();
  const seenArtifactIds = new Map();
  const egoContext = { fieldMap: scan.fieldMap, poolsByPath: scan.poolsByPath, baseIndex, locale, missingLabels, unmappedKeys };

  for (const record of scan.records) {
    const resolved = resolveRecord(record, byDefineAs);
    const type = resolved.fields.type ?? null;
    const isEgoFile = /\/egos\//.test(record.file);
    const isNpcDefinition = type && NPC_TYPES.has(type);

    if (isEgoFile) {
      // Ego files only hold affixes; anything without a name is a helper.
      if (!literalField(record, 'name')) { skipped.set('ego:no-name', (skipped.get('ego:no-name') ?? 0) + 1); continue; }
      const ego = buildEgo(record, egoContext);
      const previousEgo = seenEgoIds.get(ego.id);
      if (previousEgo) {
        if (sameDefinition(previousEgo.record, record)) {
          previousEgo.ego.definitions.push({ file: record.fileId, line: ego.line });
          duplicateDefinitions.push({ kind: 'ego', id: ego.id, kept: previousEgo.ego.file, also: record.fileId });
          continue;
        }
        ego.variantNote = `与 ${previousEgo.ego.file}:${previousEgo.ego.line} 同名不同定义`;
        ego.id = `${ego.id}#${ego.line}`;
        skipped.set('ego:variant-same-key', (skipped.get('ego:variant-same-key') ?? 0) + 1);
      }
      ego.definitions = [{ file: record.fileId, line: ego.line }];
      seenEgoIds.set(ego.id, { ego, record });
      egos.push(ego);
      continue;
    }

    if (isNpcDefinition) { skipped.set('npc-definition', (skipped.get('npc-definition') ?? 0) + 1); continue; }

    const verdict = classifyArtifact(record, resolved);
    if (!verdict.include) {
      skipped.set(verdict.reason, (skipped.get(verdict.reason) ?? 0) + 1);
      continue;
    }

    const artifact = buildArtifact(record, resolved, { fieldMap: scan.fieldMap, locale, missingLabels, unmappedKeys });
    artifact.status = verdict.nonEquipment ? 'non-equipment' : 'included';
    artifact.inclusionReason = verdict.reason;
    artifact.definitions = artifact.definitions ?? [{ file: record.fileId, line: artifact.line, zone: zoneOf(record.file) }];

    const previous = seenArtifactIds.get(artifact.id);
    if (previous) {
      if (sameDefinition(previous.record, record)) {
        // The same item declared in more than one zone file: keep one row and
        // record every location, so the coverage report accounts for both.
        previous.artifact.definitions.push({ file: record.fileId, line: artifact.line, zone: zoneOf(record.file) });
        duplicateDefinitions.push({ kind: 'artifact', id: artifact.id, kept: previous.artifact.file, also: record.fileId });
        continue;
      }
      // Same identifier, different content: a genuine variant. Disambiguate by
      // source location rather than silently dropping one of them.
      artifact.variantNote = `与 ${previous.artifact.file}:${previous.artifact.line} 同名不同定义`;
      artifact.id = `${artifact.id}#${artifact.line}`;
      skipped.set('artifact:variant-same-define-as', (skipped.get('artifact:variant-same-define-as') ?? 0) + 1);
    }

    seenArtifactIds.set(artifact.id, { artifact, record });
    if (!artifact.nameZh) missingTranslations.push({ id: artifact.id, name: artifact.name, kind: 'artifact-name' });
    if (!artifact.image) missingImages.push({ id: artifact.id, name: artifact.name, reason: 'no-image-field' });
    artifacts.push(artifact);
  }

  for (const ego of egos) {
    if (!ego.name.raw) continue;
    if (!ego.name.zh) missingTranslations.push({ id: ego.id, name: ego.name.raw, kind: 'ego-name' });
  }

  egos.sort((a, b) => (a.name.clean || '').localeCompare(b.name.clean || '') || a.id.localeCompare(b.id));
  artifacts.sort((a, b) => (a.name || '').localeCompare(b.name || '') || a.id.localeCompare(b.id));

  const sourceCounts = {};
  for (const ego of egos) sourceCounts[ego.source] = (sourceCounts[ego.source] ?? 0) + 1;
  const artifactSourceCounts = {};
  for (const artifact of artifacts) artifactSourceCounts[artifact.source] = (artifactSourceCounts[artifact.source] ?? 0) + 1;

  // -------------------------------------------------------------------------
  // Reports
  // -------------------------------------------------------------------------
  const unmappedReport = [...unmappedKeys.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([key, count]) => ({ key, count }));
  const untranslatedLabels = [...missingLabels.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([label, count]) => ({ label, count }));

  // Coverage of the "does the list show what this affix does" question. An affix
  // with neither properties nor a note renders as "nothing readable", which is
  // exactly the case the page must account for rather than hide.
  const effectCoverage = {
    withProperties: egos.filter((ego) => ego.areas.length > 0).length,
    callbackTemplates: egos.filter((ego) => ego.notes.some((note) => note.basis === 'game')).length,
    curatedNotes: egos.filter((ego) => ego.notes.some((note) => note.basis === 'source')).length,
    partialNotes: egos.filter((ego) => ego.notes.some((note) => Object.values(note.values).some((v) => v.range === null))).length,
    withoutEffect: egos.filter((ego) => ego.areas.length === 0 && ego.notes.length === 0).map((ego) => ego.id),
  };

  const report = {
    generatedAt: new Date().toISOString(),
    // `files[i]` is `filePaths[i]`; every `file` field in the datasets is an index
    // into this list.
    files: filePaths,
    workspace: path.relative(projectRoot, workspaceRoot) || '.',
    fieldMapFile: scan.fieldMap.file,
    scannedFiles: scan.fileCount,
    scannedDefinitions: scan.records.length,
    egoPools: scan.poolsByPath.size,
    counts: {
      egos: egos.length,
      artifacts: artifacts.length,
      artifactsIncluded: artifacts.filter((a) => a.status === 'included').length,
      artifactsNonEquipment: artifacts.filter((a) => a.status === 'non-equipment').length,
    },
    sourceCounts,
    artifactSourceCounts,
    // `rarity`, `level_range` and generation helpers are performance weights and
    // spawn bands. They are carried verbatim and must not be presented as
    // drop rates or equip requirements.
    semantics: {
      rarity: '相对生成权重，不是掉落概率',
      levelRange: '该物品可生成的等级区间，不是装备需求等级',
      mbonusMaterial: '基础值 + 材料等级 × 每级增量；本站给出材料等级 1–5 的范围',
    },
    skipped: [...skipped.entries()].sort((a, b) => b[1] - a[1]).map(([reason, count]) => ({ reason, count })),
    // Same definition, several source locations (zone files re-declare items).
    // Paths are resolved here because the dictionary is defined above.
    duplicateDefinitions: duplicateDefinitions.map((entry) => ({
      ...entry,
      kept: filePaths[entry.kept] ?? entry.kept,
      also: filePaths[entry.also] ?? entry.also,
    })),
    unmappedPropertyKeys: unmappedReport,
    untranslatedLabels,
    effectCoverage,
    missingTranslations,
    missingImages,
    egoNameTokens: [...new Set(egos.flatMap((e) => e.name.tokens))].map((token) => ({ token, ...NAME_TOKENS[token] })),
    pools: [...scan.poolsByPath.values()].map((pool) => ({
      ...pool,
      egoCount: egos.filter((e) => e.pool === pool.pool).length,
      baseItems: (baseIndex.byPool.get(pool.pool) ?? []).map((b) => ({ defineAs: b.defineAs, name: b.name, type: b.type, subtype: b.subtype, slot: b.slot })),
    })).sort((a, b) => a.pool.localeCompare(b.pool)),
    diagnostics: scan.diagnostics.filter((d) => d.severity !== 'info'),
    diagnosticCount: scan.diagnostics.length,
  };

  const master = {
    counts: {
      fields: scan.fieldMap.fields.size,
      egos: egos.length,
      artifacts: artifacts.length,
    },
    sources: [
      { id: 'tome', label: '本体', version: '1.7.6' },
      { id: 'orcs', label: '兽人 DLC', version: '1.7.6' },
      { id: 'ashes', label: '灰烬 DLC', version: '1.7.4' },
      { id: 'cults', label: '邪教 DLC', version: '1.7.6' },
    ],
    labels: {
      areas: { combat: '装备本体', special_combat: '盾击/副手攻击', wielder: '穿戴效果', carrier: '携带效果', imbue_powers: '镶嵌效果' },
      slots: SLOT_LABELS,
      nameTokens: NAME_TOKENS,
      // Damage-type names come from the engine's own `"damage type"` context
      // table, so `DamageType.FIRE` renders as 火焰 rather than a raw code.
      damageTypes: damageTypeLabels(scan.fieldMap, locale),
      // `inc_damage_type = { living = 20 }` keys a bonus by actor type. The
      // codes are the engine's actor types, resolved through the same locale
      // machinery with the engine's own context name.
      actorTypes: actorTypeLabels([...egos, ...artifacts], locale),
    },
    semantics: report.semantics,
  };

  const dataDir = path.join(outDir, 'data');
  fs.mkdirSync(dataDir, { recursive: true });

  // -------------------------------------------------------------------------
  // Image copy: only the icons the dataset actually references.
  //
  // This must run *before* the datasets are serialised: it annotates each
  // artifact with its resolved `imagePath`, and writing the JSON first would
  // ship a dataset whose icons all look unresolved.
  // -------------------------------------------------------------------------
  const imageResult = copyArtifactImages({ workspaceRoot, outDir, artifacts });

  report.imageIndexSize = imageResult.indexSize;
  report.imagesCopied = imageResult.copied.length;
  report.counts.artifactsWithImage = artifacts.filter((a) => a.imagePath).length;
  report.counts.artifactsResolverImage = imageResult.resolverGenerated.length;
  report.counts.artifactsWithoutImage = artifacts.filter((a) => !a.imagePath).length;
  report.missingImages = imageResult.missing;
  report.resolverGeneratedImages = imageResult.resolverGenerated;
  report.imageSourcesMissing = imageResult.missingSources;
  report.imageMatchKinds = countBy(artifacts.map((a) => a.imageMatch).filter(Boolean));

  // The field vocabulary is identical for every row, so it is emitted once as a
  // keyed table instead of repeating the label, format and area per property.
  const fieldMeta = buildFieldTable(scan.fieldMap, locale, missingLabels);

  writeJson(path.join(dataDir, 'egos.json'), {
    generatedAt: report.generatedAt,
    counts: { egos: egos.length },
    labels: master.labels,
    sources: master.sources,
    semantics: master.semantics,
    fieldMeta,
    egos,
  });
  writeJson(path.join(dataDir, 'artifacts.json'), {
    generatedAt: report.generatedAt,
    counts: master.counts,
    labels: master.labels,
    sources: master.sources,
    semantics: master.semantics,
    fieldMeta,
    artifacts,
  });
  writeJson(path.join(dataDir, 'items-report.json'), report);

  log(`egos: ${egos.length} (${Object.entries(sourceCounts).map(([k, v]) => `${k}=${v}`).join(' ')})`);
  log(`artifacts: ${artifacts.length} (${Object.entries(artifactSourceCounts).map(([k, v]) => `${k}=${v}`).join(' ')})`);
  log(`skipped: ${report.skipped.map((s) => `${s.reason}=${s.count}`).join(' ')}`);
  log(`unmapped property keys: ${unmappedReport.length}; untranslated labels: ${untranslatedLabels.length}`);
  log(`effects: ${effectCoverage.withProperties} with properties, ${effectCoverage.callbackTemplates} from callback text, ${effectCoverage.curatedNotes} hand-written; ${effectCoverage.withoutEffect.length} without any readable effect`);
  log(`images: ${imageResult.copied.length} copied, ${imageResult.missing.length} missing`);

  // The community supplement is part of `npm run data:items`, not a manual
  // afterthought: a regeneration that silently leaves `ego-community.json`
  // stale would make the page disagree with the spreadsheet it cites. It is
  // skipped with a notice when the spreadsheet is absent, so a deployment
  // checkout without it still builds.
  if (args['skip-community']) {
    log('community supplement: skipped by --skip-community');
  } else {
    try {
      const { main: buildCommunity } = await import('./community.mjs');
      buildCommunity(['--quiet']);
    } catch (error) {
      log(`community supplement: skipped (${error instanceof Error ? error.message : String(error)})`);
    }
  }

  log(`done in ${Date.now() - started}ms`);
}

/**
 * Chinese name for every damage type the engine defines.
 *
 * `data/damage_types.lua` pairs each code with the `_t` key the locale table
 * uses, and the snapshot has a dedicated `damage type` context for exactly this
 * lookup. Falling back to the code keeps an unmapped type visible instead of
 * blank.
 */
function damageTypeLabels(fieldMap, locale) {
  const out = {};
  for (const [code, meta] of fieldMap.damageTypes) {
    out[code] = locale.text(meta.localeKey) ?? locale.text(meta.localeKey.toLowerCase()) ?? code;
  }
  return out;
}

/**
 * Chinese names for the actor-type codes a property can be keyed by.
 *
 * `inc_damage_type = { living = 20 }` and `resists_actor_type = { summoned = 30 }`
 * store an engine actor-type code where a display name belongs. The engine's zh
 * table has an `"actor type"` context for exactly this, so the page can print
 * 生命 instead of `living`. A code without a translation stays visible as its
 * own code rather than disappearing.
 */
function actorTypeLabels(records, locale) {
  const codes = new Set();
  for (const record of records) {
    const groups = record.areas ?? record.properties ?? [];
    for (const group of groups) {
      for (const prop of group.props) {
        if (!/_actor_type$|_type$/.test(prop.key)) continue;
        for (const item of prop.items ?? []) {
          const key = item.key ?? null;
          // Only bare engine codes; damage types arrive as `DamageType.*` refs.
          if (key && !key.includes('.') && !key.includes('/')) codes.add(key);
        }
      }
    }
  }
  const out = {};
  for (const code of [...codes].sort()) {
    const hit = locale.entityWord('actor type', code);
    if (hit) out[code] = hit;
  }
  return out;
}

/**
 * Emit the property vocabulary once per dataset.
 *
 * Every artifact writes `combat_armor`, `resists` and friends with the same
 * label, format and unit, so those live here under `fieldMeta[key]`. Rows keep
 * only what differs between items.
 */
function buildFieldTable(fieldMap, locale, missingLabels) {
  const table = {};
  for (const [key, meta] of fieldMap.fields) {
    const label = labelFor({ ...meta, labelZhManual: meta.labelZhManual }, locale, missingLabels);
    const format = stripFormatColors(meta.format);
    table[key] = {
      area: meta.area,
      kind: meta.kind,
      label: meta.label ?? key,
      labelZh: label.text,
      format: format ?? null,
      unit: format?.includes('%%') ? '%' : null,
      // The engine prints `raw * scale`; values in the datasets are already
      // multiplied by it, and the factor is kept so the UI can explain a
      // fraction that reads as a percentage.
      scale: meta.scale ?? 1,
      manualMapping: meta.manual ? true : undefined,
      note: meta.note ?? undefined,
    };
  }
  return table;
}

/** Tally a list of strings into `{ value: count }`. */
function countBy(values) {
  const out = {};
  for (const value of values) out[value] = (out[value] ?? 0) + 1;
  return out;
}

function writeJson(file, value) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, `${JSON.stringify(value, null, 1)}\n`);
}

// `main` runs unless imported by a test.
if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main();
}

export { main, labelFor, splitSeparator };
