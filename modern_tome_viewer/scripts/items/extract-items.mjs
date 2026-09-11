/**
 * Item extraction: ego affixes and fixed artifacts.
 *
 * Built on `lua-entities.mjs` (the item-side scanner) plus the shared tokenizer
 * and literal helpers from the monster pipeline. Nothing here executes Lua:
 * every value is classified as literal, parameterised resolver, or runtime
 * function, and the three are kept apart all the way to the JSON so the UI can
 * show a real number, a range, or a sentence instead of a guess.
 *
 * The property vocabulary is derived from the game's own tooltip code by
 * `field-map.mjs`, which is what makes the `field -> 中文标签 -> 生效方式`
 * mapping maintainable rather than hand-copied.
 */

import fs from 'node:fs';
import path from 'node:path';

import { literalOf, keyName } from '../monsters/lua-table.mjs';
import { scanItemFile, ITEM_SOURCES } from './lua-entities.mjs';
import { loadFieldMap, AREA_LABELS } from './field-map.mjs';

// ---------------------------------------------------------------------------
// Classification vocabulary
// ---------------------------------------------------------------------------

/**
 * `type` values that belong to monsters. A `unique = true` block resolving to
 * one of these is an NPC definition (a boss with a fixed name), not an item.
 * There are 84 of them and they live in `npcs.lua` files alongside real items,
 * so they have to be filtered by resolved type rather than by file path.
 */
export const NPC_TYPES = new Set([
  'humanoid', 'giant', 'undead', 'dragon', 'demon', 'spiderkin', 'horror',
  'elemental', 'insect', 'vermin', 'animal', 'aquatic', 'plant', 'construct',
  'immovable', 'immortal', 'reptile', 'feline', 'canine', 'rodent', 'snake',
  'jelly', 'mold', 'molds', 'ooze', 'wight', 'vampire', 'lich', 'ghoul',
  'skeleton', 'treant', 'titan', 'yeti', 'naga', 'orc', 'elf', 'dwarf',
  'halfling', 'shalore', 'thalore', 'yeek', 'drem', 'krog', 'xorn', 'mummy',
  'swarm', 'maggot', 'blob', 'golem', 'boss', 'critter', 'mech', 'weird',
  'god', 'flesh', 'corpse', 'horror/eldritch',
]);

/** Item types that a player can equip, wear, wield or actively use. */
export const EQUIP_TYPES = new Set(['weapon', 'armor', 'jewelry', 'lite', 'tool', 'ammo', 'charm', 'orb', 'tinker']);

/**
 * Every item type that is a real fixed artifact but not equipment. These stay
 * in the dataset with an explicit status so they can be filtered and counted,
 * rather than being dropped without a trace.
 */
export const NON_EQUIP_ITEM_TYPES = new Set(['gem', 'scroll', 'potion', 'tome', 'lore', 'misc', 'chest', 'flesh', 'corpse']);

/** Slot names shown in the UI, matching the engine's inventory slot ids. */
export const SLOT_LABELS = {
  MAINHAND: '主手',
  OFFHAND: '副手',
  BODY: '躯干',
  HEAD: '头部',
  HANDS: '手部',
  FEET: '脚部',
  CLOAK: '斗篷',
  BELT: '腰带',
  LITE: '光源',
  TOOL: '工具',
  QUIVER: '箭袋',
  FINGER: '手指',
  NECK: '颈部',
  AMMO: '弹药',
};

/** The property areas the game's `getTextualDesc` renders, in display order. */
export const AREA_KEYS = new Set(['wielder', 'combat', 'special_combat', 'carrier', 'imbue_powers']);

/** Display order for the areas, so every item reads the same way. */
export const AREA_ORDER = ['combat', 'special_combat', 'wielder', 'carrier', 'imbue_powers'];

// ---------------------------------------------------------------------------
// Value classification
// ---------------------------------------------------------------------------

/**
 * Classify one AST value node.
 *
 * The distinction this function draws is the whole point of the dataset:
 *
 *   - `literal`  — a fixed number/string; safe to render as-is.
 *   - `resolver` — a `resolvers.*` call. `range`/`min`/`max` are filled only
 *                  when the arguments are literals and the helper's meaning is
 *                  known; `text` always carries the source expression so the UI
 *                  can explain instead of inventing a number.
 *   - `computed` — anything else (arithmetic on a variable, a function call to
 *                  something unknown). Never zero, never guessed.
 *   - `function` — a runtime callback or `use_power.name`. Rendered as prose.
 *
 * `scale` is the field's tooltip multiplier (`fieldMeta[key].scale`): the game
 * prints `raw * scale`, so every number this function reports is already in the
 * units the player sees. Neither the transform nor the scale is ever skipped —
 * they are what make `resolvers.mbonus_material(30, 20, function(e, v) v=v/100
 * end)` print as `20%` rather than `20`.
 */
export function classifyValue(node, scale = 1) {
  if (!node) return { kind: 'empty' };

  if (node.kind === 'call') {
    const callee = node.path.join('.');
    // `_t"..."` / `_t("...")` is a localisation lookup, not a computation.
    if (callee === '_t' || callee === 't') {
      const literal = literalOf(node.args?.[0]);
      if (typeof literal === 'string') return { kind: 'literal', value: literal };
    }
    return classifyResolver(callee, node, scale);
  }

  const literal = literalOf(node);
  if (literal !== undefined) {
    return { kind: 'literal', value: typeof literal === 'number' ? scaled(literal, scale) : literal };
  }

  if (node.kind === 'function') return { kind: 'function' };
  if (node.kind === 'ref') return { kind: 'computed', ref: node.path.join('.') };
  if (node.kind === 'table') return { kind: 'table' };
  return { kind: 'computed', node: node.kind };
}

/**
 * Read the value transform a `resolvers.mbonus_material` price function applies.
 *
 * The third argument is not a price in most ego definitions — it rewrites the
 * rolled value before it is stored. Only four shapes occur in the whole item
 * corpus, and each one is a real difference in what the affix does:
 *
 *   `v=v/100 return 0, v`   immunities, movement speed, resistances: a fraction
 *   `v=v/10  return 0, v`   regeneration per turn, talent mastery
 *   `return 0, -v`          fatigue: a reduction
 *   `return 0, v` / `v*1`   identity (a price-only hook)
 *
 * A body that matches none of them is reported as `unknown` and the value is
 * then shown as an expression, never as a number that might be wrong.
 */
export function valueTransformOf(node) {
  if (!node || node.kind !== 'function') return null;
  if (typeof node.bodyText !== 'string') return { kind: 'unknown', text: null };
  const text = node.bodyText.replace(/\s+/g, ' ').trim();
  // Every pattern is anchored on the closing `end`: without it, `return 0, v *
  // e.material_level` matches "return 0, v" and the unknown transform is
  // misread as the identity.
  const divided = /v\s*=\s*v\s*\/\s*(\d+)/.exec(text) ?? /return\s+0\s*,\s*v\s*\/\s*(\d+)\s*end/.exec(text);
  if (divided) return { kind: 'divide', divisor: Number(divided[1]), text };
  if (/return\s+0\s*,\s*-v\s*end/.test(text)) return { kind: 'negate', text };
  if (/return\s+0\s*,\s*v\s*end/.test(text) || /return\s+v\s*\*\s*1\s*end/.test(text)) {
    return { kind: 'identity', text };
  }
  return { kind: 'unknown', text };
}

/** Apply a transform to one number. `null` transform means "unchanged". */
function applyTransform(value, transform) {
  if (!transform) return value;
  switch (transform.kind) {
    case 'divide': return value / transform.divisor;
    case 'negate': return -value;
    case 'identity': return value;
    default: return null;
  }
}

/** Multiply by the field's tooltip scale and drop floating-point noise. */
function scaled(value, scale) {
  if (!Number.isFinite(value)) return value;
  return Math.round(value * scale * 1e6) / 1e6;
}

/**
 * Interpret the resolver helpers that carry a recoverable static range.
 *
 * `mbonus_material(max, add)` is **not** `add + material_level * max`. The
 * engine's own code (`resolvers.calc.mbonus_material`) is
 *
 *   v = ceil(rng.mbonus(max, current_level, 90) * ml / 5) + add
 *
 * so `max` is the value the roll can reach and `add` is a flat offset that is
 * always present. Reading the two arguments the other way round — as an offset
 * plus a per-material-level step — is how `balanced` (really `5~15` accuracy and
 * defence) was displayed as `15~35`. The community spreadsheet lists the same
 * affix as `5-15命中闪避/20-50缴械免疫`, which is the check that settled it.
 *
 * `range` spans what the roll can produce at material level 5 (the widest case);
 * `materialRanges[ml - 1]` narrows it to one material level, which is what the
 * ego page's material-level selector shows.
 */
function classifyResolver(callee, node, scale = 1) {
  const args = node.args ?? [];
  const nums = args.map((a) => literalOf(a));
  const numArgs = nums.filter((n) => typeof n === 'number');
  const base = { kind: 'resolver', resolver: callee, args: numArgs, text: describeCall(callee, args) };

  switch (callee) {
    case 'resolvers.rngrange':
      if (numArgs.length >= 2) {
        return { ...base, range: [scaled(numArgs[0], scale), scaled(numArgs[1], scale)], meaning: '生成时随机取值' };
      }
      break;
    case 'resolvers.rngavg':
      if (numArgs.length >= 2) {
        return { ...base, range: [scaled(numArgs[0], scale), scaled(numArgs[1], scale)], meaning: '生成时随机取值' };
      }
      break;
    case 'resolvers.mbonus_material': {
      if (numArgs.length < 2) break;
      const [max, add] = numArgs;
      const transform = valueTransformOf(args[2]);
      if (transform?.kind === 'unknown') {
        // A transform we cannot read makes the number unknowable; say so.
        return { ...base, meaning: '随材料等级变化的数值（变换函数未识别）', formula: null };
      }
      const materialRanges = [];
      for (let ml = 1; ml <= 5; ml += 1) {
        // `rng.mbonus` is clamped to `[0, max]`, so the roll at this material
        // level lands anywhere in `[add, add + ceil(max * ml / 5)]`.
        const lo = applyTransform(add, transform);
        const hi = applyTransform(add + Math.ceil((max * ml) / 5), transform);
        materialRanges.push([scaled(Math.min(lo, hi), scale), scaled(Math.max(lo, hi), scale)]);
      }
      return {
        ...base,
        meaning: '随材料等级变化',
        formula: {
          kind: 'material',
          max,
          add,
          transform: transform?.kind ?? null,
          divisor: transform?.divisor ?? null,
          materialLevelRange: [1, 5],
        },
        range: materialRanges[4],
        materialRanges,
      };
    }
    case 'resolvers.mbonus':
      if (numArgs.length >= 2) {
        // `mbonus(max, add)` rolls on the generation level instead of the
        // material level: the same `[add, add + max]` span, no per-tier split.
        const [max, add] = numArgs;
        return {
          ...base,
          meaning: '随生成等级变化',
          formula: { kind: 'level', max, add, materialLevelRange: null },
          range: [scaled(add, scale), scaled(add + max, scale)],
        };
      }
      break;
    case 'resolvers.randartmax':
      if (numArgs.length >= 2) {
        return { ...base, range: [scaled(numArgs[0], scale), scaled(numArgs[1], scale)], meaning: '随机神器上限' };
      }
      break;
    default:
      break;
  }
  return base;
}


/** A readable stand-in for a call, used when no range can be recovered. */
function describeCall(callee, args) {
  const parts = args.map((a) => {
    const literal = literalOf(a);
    if (literal !== undefined) return typeof literal === 'string' ? JSON.stringify(literal) : String(literal);
    if (a.kind === 'function') return 'function';
    if (a.kind === 'ref') return a.path.join('.');
    if (a.kind === 'table') return '{...}';
    return a.kind;
  });
  const short = callee.split('.').pop();
  return `${short}(${parts.join(', ')})`;
}

// ---------------------------------------------------------------------------
// Field-map application
// ---------------------------------------------------------------------------

/**
 * Strip the engine's colour codes from a format string.
 *
 * Tooltip formats are written as `"%+d #LAST#(%+d eff.)"`, where `#LAST#` ends
 * the current colour. Only the number format survives; the colour is applied by
 * CSS in the web UI.
 */
export function stripFormatColors(format) {
  if (!format) return null;
  return format.replace(/#[A-Z_]+#/g, '').trim() || null;
}

/**
 * Decide what unit a format implies, so the UI can append it without guessing.
 */
function unitOf(format, label) {
  if (!format) return null;
  if (format.includes('%%')) return '%';
  if (/life|life$/.test(label ?? '')) return null;
  return null;
}

// ---------------------------------------------------------------------------
// Reference collection
// ---------------------------------------------------------------------------

/**
 * Walk a value node and record every `DamageType.*`, `Stats.*` and `Talents.*`
 * reference. These drive the Chinese damage-type names and the talent links.
 */
function collectRefs(node, refs) {
  if (!node || typeof node !== 'object') return;
  if (node.kind === 'ref') {
    const joined = node.path.join('.');
    if (joined.startsWith('DamageType.')) refs.damageTypes.add(joined.slice('DamageType.'.length));
    else if (joined.startsWith('Stats.')) refs.stats.add(joined.slice('Stats.'.length));
    else if (joined.startsWith('Talents.')) refs.talents.add(joined.slice('Talents.'.length));
  }
  if (node.kind === 'call') {
    // `Talents.T_FOO` reaches here as a ref argument; the `require`/`_t` callee
    // itself is not a talent reference.
    const joined = node.path.join('.');
    if (joined.startsWith('Talents.')) refs.talents.add(joined.slice('Talents.'.length));
  }
  for (const entry of node.map ?? []) {
    const key = keyName(entry.key);
    // `[DamageType.FIRE] = 20` keys the table by a damage type reference.
    if (entry.key?.kind === 'ref') {
      const joined = entry.key.path.join('.');
      if (joined.startsWith('DamageType.')) refs.damageTypes.add(joined.slice('DamageType.'.length));
      else if (joined.startsWith('Stats.')) refs.stats.add(joined.slice('Stats.'.length));
    }
    refs.tableKeys.push(key);
    collectRefs(entry.value, refs);
  }
  for (const item of node.array ?? []) collectRefs(item, refs);
  for (const arg of node.args ?? []) collectRefs(arg, refs);
  collectRefs(node.of, refs);
  collectRefs(node.left, refs);
  collectRefs(node.right, refs);
}

function emptyRefs() {
  return { damageTypes: new Set(), stats: new Set(), talents: new Set(), tableKeys: [] };
}

// ---------------------------------------------------------------------------
// Property extraction
// ---------------------------------------------------------------------------

/**
 * Build one property card for a `key = value` pair, or null when the key has no
 * meaning for players.
 *
 * `entries` are the as-written entries; a key can be written more than once
 * (a child overriding its base), and the last write wins — matching Lua.
 */
export function makeProp(key, entries, fieldMap, context) {
  const meta = fieldMap.fields.get(key);
  const last = entries[entries.length - 1];
  const value = last.value;
  const refs = emptyRefs();
  collectRefs(value, refs);
  // The tooltip multiplies the raw field by this factor before printing it
  // (`Moddable:compareFields`); immunities and movement speed are stored as
  // fractions and printed with `scale = 100`.
  const scale = meta?.scale ?? 1;

  const base = {
    key,
    area: meta?.area ?? 'unknown',
    kind: meta?.kind ?? 'unknown',
    label: meta?.label ?? key,
    labelZhManual: meta?.labelZhManual ?? null,
    manualMapping: Boolean(meta?.manual),
    format: stripFormatColors(meta?.format),
    formatRaw: meta?.format ?? null,
    unit: unitOf(meta?.format, meta?.label),
    scale,
    // `file` is a dictionary id (see build-items.mjs), not a path.
    sourceRef: { file: context.fileId ?? context.file, line: last.line ?? context.line },
    // Written more than once (child overriding base, or a repeated key).
    overridden: entries.length > 1,
    valueCount: entries.length,
  };

  if (value.kind === 'table') {
    const items = [];
    for (const entry of value.map ?? []) {
      const itemKey = keyName(entry.key);
      const classified = classifyValue(entry.value, scale);
      const refName = entry.key?.kind === 'ref' ? entry.key.path.join('.') : null;
      items.push({
        key: itemKey,
        ref: refName,
        // `DamageType.FIRE` -> `FIRE`, so the damage-type table can be looked up.
        code: refName?.startsWith('DamageType.') ? refName.slice('DamageType.'.length) : null,
        statCode: refName?.startsWith('Stats.') ? refName.slice('Stats.'.length) : null,
        ...classified,
        line: entry.line ?? last.line ?? context.line,
      });
    }
    for (const item of value.array ?? []) {
      items.push({ key: null, ...classifyValue(item, scale), line: item.line ?? last.line ?? context.line });
    }
    return { ...base, kind: 'table', items, refs: serializeRefs(refs) };
  }

  const classified = classifyValue(value, scale);
  return {
    ...base,
    ...classified,
    refs: serializeRefs(refs),
  };
}

function serializeRefs(refs) {
  return {
    damageTypes: [...refs.damageTypes].sort(),
    stats: [...refs.stats].sort(),
    talents: [...refs.talents].sort(),
  };
}

/**
 * Extract every property area (`wielder`, `combat`, `special_combat`, ...) from
 * one entity's resolved field map.
 *
 * `fieldsTable` is the raw AST `fields` table (`{ map: [...] }`), because
 * resolvers and functions must keep their structure — folding them to literals
 * would silently turn an unknown into a zero.
 */
export function extractProps(fieldsTable, fieldMap, context) {
  const byArea = new Map();
  const unmapped = new Map();

  // Two passes, because an area can contain another area: `wielder = { combat =
  // { melee_project = ... } }` is the engine's way of saying "these are weapon
  // fields on a wearer item" (33 egos do it), and treating `combat` as a
  // property produced a row literally labelled `combat` whose members were
  // listed as `melee_project`/`burst_on_crit` — field keys shown as values, in
  // the wrong section.
  const own = new Map();
  const nested = new Map();
  const lines = new Map();

  const bucketFor = (map, area, key) => {
    if (!map.has(area)) map.set(area, new Map());
    const areaMap = map.get(area);
    if (!areaMap.has(key)) areaMap.set(key, []);
    return areaMap.get(key);
  };

  for (const entry of fieldsTable.map ?? []) {
    const areaKey = keyName(entry.key);
    if (!AREA_KEYS.has(areaKey)) continue;
    if (entry.value?.kind !== 'table') continue;
    // The area itself is declared here, even when its only content is a nested
    // area, so the target section exists even if it comes later in the table.
    if (!lines.has(areaKey)) lines.set(areaKey, entry.line);

    for (const inner of entry.value.map ?? []) {
      const innerKey = keyName(inner.key);
      if (!innerKey) continue;
      if (AREA_KEYS.has(innerKey) && inner.value?.kind === 'table') {
        for (const deep of inner.value.map ?? []) {
          const deepKey = keyName(deep.key);
          if (!deepKey) continue;
          bucketFor(nested, innerKey, deepKey).push(deep);
        }
        if (!lines.has(innerKey)) lines.set(innerKey, inner.line ?? entry.line);
        continue;
      }
      bucketFor(own, areaKey, innerKey).push(inner);
    }
  }

  for (const areaKey of [...new Set([...own.keys(), ...nested.keys()])]) {
    // Own fields first, then fields borrowed from a nested area table; a key
    // written in both keeps its own definition last, matching Lua's last-write
    // rule closely enough for the few items where it happens.
    const grouped = new Map([...(nested.get(areaKey) ?? new Map()), ...(own.get(areaKey) ?? new Map())]);
    const list = [];
    for (const [innerKey, entries] of grouped) {
      const prop = makeProp(innerKey, entries, fieldMap, { ...context, line: lines.get(areaKey) });
      if (!fieldMap.fields.has(innerKey)) unmapped.set(innerKey, prop);
      list.push(prop);
    }
    byArea.set(areaKey, { area: areaKey, props: list, line: lines.get(areaKey) });
  }

  return { byArea, unmapped };
}

// ---------------------------------------------------------------------------
// Inheritance
// ---------------------------------------------------------------------------

export function mergeFields(parent, child) {
  const merged = { ...child };
  for (const [key, value] of Object.entries(parent)) {
    if (merged[key] === undefined) merged[key] = value;
    else if (isPlainObject(value) && isPlainObject(merged[key])) merged[key] = { ...value, ...merged[key] };
  }
  return merged;
}

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

// ---------------------------------------------------------------------------
// File walking
// ---------------------------------------------------------------------------

/** Recursively collect `.lua` files, sorted for determinism. */
export function collectLuaFiles(dir, options = {}) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  const walk = (current) => {
    for (const entry of fs.readdirSync(current, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) walk(full);
      else if (entry.name.endsWith('.lua') && (!options.filter || options.filter(full))) out.push(full);
    }
  };
  walk(dir);
  return out;
}

/**
 * Files that may define items.
 *
 * `data/general/objects/` covers the bulk. Zone directories contribute
 * `<zone>/objects.lua` (zone-specific items), `npcs.lua` (boss equipment, which
 * is where the `random_art_replace` associations live) and `grids.lua` is
 * deliberately excluded because it only ever holds terrain.
 */
export function itemFileList(workspaceRoot) {
  const files = [];
  for (const source of ITEM_SOURCES) {
    const dataDir = path.join(workspaceRoot, source.dir, 'data');
    if (!fs.existsSync(dataDir)) continue;
    for (const file of collectLuaFiles(path.join(dataDir, 'general', 'objects'))) files.push({ source: source.id, file });
    const zonesDir = path.join(dataDir, 'zones');
    for (const file of collectLuaFiles(zonesDir, { filter: (f) => ['objects.lua', 'npcs.lua'].includes(path.basename(f)) })) {
      files.push({ source: source.id, file });
    }
  }
  return files;
}

// ---------------------------------------------------------------------------
// Ego applicability
// ---------------------------------------------------------------------------

/**
 * Resolve the ego pools an item type uses.
 *
 * An item declares `egos = "/data/general/objects/egos/weapon.lua"`, and that
 * ego file may `load()` further pools. The chain is transitive and is the only
 * correct way to answer "which egos can this slot roll?" — a steamsaw loads
 * both `weapon.lua` and `shield.lua`, and light/heavy/massive armour all load
 * the shared `armor.lua`, none of which is visible from the file names alone.
 */
export function resolveEgoPools(poolsByPath, entryPath, seen = new Set()) {
  const normalized = normalizeEgoPath(entryPath);
  if (!normalized || seen.has(normalized)) return [];
  seen.add(normalized);
  const entry = poolsByPath.get(normalized);
  const out = [normalized];
  for (const loaded of entry?.loads ?? []) {
    out.push(...resolveEgoPools(poolsByPath, loaded, seen));
  }
  return [...new Set(out)];
}

/**
 * Reduce an ego path to its pool name.
 *
 * `/data-orcs/general/objects/egos/steamsaw.lua`, `/data/general/objects/egos/
 * weapon.lua` and a bare `weapon` all mean the same pool, so both the full path
 * and an already-normalised name are accepted. Callers that resolve a `load()`
 * chain hand back names, and the chain walk must keep working.
 */
export function normalizeEgoPath(raw) {
  if (typeof raw !== 'string') return null;
  const match = /(?:\/|^)([a-z0-9-]+)\.lua$/i.exec(raw);
  if (match) return match[1];
  return /^[a-z0-9-]+$/i.test(raw) ? raw : null;
}

// ---------------------------------------------------------------------------
// Top-level scan
// ---------------------------------------------------------------------------

/**
 * Scan every item file once and return the raw material both pages build on.
 *
 * Returns entity records with their resolved inheritance, the ego pool graph,
 * and diagnostics. No classification or translation happens here — that is the
 * build script's job, so this function stays testable on synthetic input.
 */
export function scanItems(workspaceRoot) {
  const fieldMap = loadFieldMap(workspaceRoot);
  const files = itemFileList(workspaceRoot);
  const diagnostics = [];
  const fileStats = [];
  const records = [];
  const poolsByPath = new Map();

  for (const { source, file } of files) {
    const rel = path.relative(workspaceRoot, file);
    let scanned;
    try {
      scanned = scanItemFile(fs.readFileSync(file, 'utf8'), rel);
    } catch (error) {
      diagnostics.push({ file: rel, line: 0, message: `读取失败：${error.message}`, severity: 'error', source });
      continue;
    }
    for (const diagnostic of scanned.diagnostics) {
      // The fragment reader reports tokens it could not model inside an
      // expression; those are informational, the table itself still parsed.
      diagnostics.push({ ...diagnostic, severity: 'info', source });
    }

    // Ego pools are declared by `load()` inside an ego file.
    if (/\/egos\//.test(file)) {
      const pool = normalizeEgoPath(file);
      if (pool) {
        poolsByPath.set(pool, {
          pool,
          file: rel,
          source,
          loads: scanned.loads.map((l) => normalizeEgoPath(l.path)).filter(Boolean),
        });
      }
    }

    let count = 0;
    for (const entity of scanned.entities) {
      const defineAs = literalOf(findField(entity, 'define_as'));
      records.push({
        source,
        file: rel,
        line: entity.line,
        endLine: entity.endLine,
        defineAs: typeof defineAs === 'string' ? defineAs : null,
        ast: entity.fields,
        isZone: rel.includes('/data/zones/'),
        isNpcFile: path.basename(rel) === 'npcs.lua',
      });
      count += 1;
    }
    if (count) fileStats.push({ source, file: rel, entities: count });
  }

  return { fieldMap, records, poolsByPath, diagnostics, fileStats, fileCount: files.length };
}

/** Find one key's value node in an entity AST. */
export function findField(entity, key) {
  for (const entry of entity.fields?.map ?? []) {
    if (keyName(entry.key) === key) return entry.value;
  }
  return null;
}

/** Collect all values written for a key (parents + child). */
export function findFields(entity, key) {
  return (entity.fields?.map ?? []).filter((entry) => keyName(entry.key) === key).map((entry) => entry.value);
}

export { AREA_LABELS };
