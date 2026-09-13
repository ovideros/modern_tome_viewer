/**
 * Monster / NPC extraction from the ToME 1.7.6 Lua sources.
 *
 * This is the pipeline behind `public/data/monsters.json`. It reads the base
 * game and the three DLCs, parses every `newEntity{...}` in the general and
 * zone NPC files, resolves the `base =` inheritance chains, and classifies each
 * template so the web UI can present normal monsters, elites and fixed bosses
 * separately from abstract BASE templates, non-combat NPCs and summons.
 *
 * Design rules (see docs/monster-pipeline.md):
 *  - never silently drop a template; anything unresolved is reported
 *  - `base` inheritance uses the engine's `importBase` merge semantics, not a
 *    plain object spread
 *  - talent resolvers keep their structure (fixed / rngtalent / rngtalentsets),
 *    because flattening them would claim a monster always has every talent
 *  - the classifier follows `Actor:textRank` (rank 1 critter … 5 elite boss)
 */

import fs from 'node:fs';
import path from 'node:path';
import { parseLuaFile, literalOf, keyName, findTalentAliases } from './lua-table.mjs';
import { lookupArt } from './images.mjs';

// ---------------------------------------------------------------------------
// Rank semantics — engine/interface/Actor.lua `textRank`
// ---------------------------------------------------------------------------

/**
 * rank -> display metadata. `Actor:textRank` maps the engine ranks to these
 * labels; the Chinese labels come from `data/locales/zh_hans.lua`.
 */
export const RANKS = {
  1: { key: 'critter', en: 'critter', zh: '小怪' },
  2: { key: 'normal', en: 'normal', zh: '普通' },
  3: { key: 'elite', en: 'elite', zh: '精英' },
  3.2: { key: 'rare', en: 'rare', zh: '稀有' },
  3.5: { key: 'unique', en: 'unique', zh: '史诗' },
  4: { key: 'boss', en: 'boss', zh: 'Boss' },
  5: { key: 'elite_boss', en: 'elite boss', zh: '精英Boss' },
  10: { key: 'god', en: 'god', zh: '神' },
  11: { key: 'godslayer', en: 'godslayer', zh: '弑神者' },
};

/**
 * Coarse bucket used by the UI.
 *
 * `normal` = rank 1-2 (critters and ordinary monsters), `elite` = rank 3-3.2
 * (elite/rare, the randomly generated "精英怪"), `unique` = rank 3.5,
 * `boss` = rank 4, `elite_boss` = rank 5, `god` = rank >= 10.
 */
export function classifyRank(rank) {
  if (rank === null || rank === undefined) return 'normal';
  if (rank <= 2) return 'normal';
  if (rank <= 3.2) return 'elite';
  if (rank < 4) return 'unique';
  if (rank === 4) return 'boss';
  if (rank < 10) return 'elite_boss';
  return 'god';
}

export const CATEGORY_LABELS = {
  critter: '小怪',
  normal: '普通怪物',
  elite: '精英',
  unique: '史诗',
  boss: '固定Boss',
  elite_boss: '精英Boss',
  god: '神级',
};

// ---------------------------------------------------------------------------
// Source packages
// ---------------------------------------------------------------------------

/** Base game first, then DLCs in the order the game loads them. */
export const SOURCES = [
  { id: 'tome', label: '本体', en: 'Base game', dir: 'tome-src-full', version: '1.7.6' },
  { id: 'orcs', label: '兽人 DLC', en: "Embers of Rage", dir: 'dlc-src/orcs/tome-orcs', version: '1.7.6' },
  { id: 'ashes', label: '灰烬 DLC', en: 'Ashes of Urh\'Rok', dir: 'dlc-src/ashes-urhrok/tome-ashes-urhrok', version: '1.7.4' },
  { id: 'cults', label: '邪教 DLC', en: 'Forbidden Cults', dir: 'dlc-src/cults/tome-cults', version: '1.7.6' },
];

/** Recursively collect Lua files under `dir` (missing dirs are skipped). */
function collectLua(dir, options = {}) {
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

// ---------------------------------------------------------------------------
// Talent identifier resolution
// ---------------------------------------------------------------------------

/**
 * Resolve a talent reference from the parsed AST to its game talent id.
 *
 * Sources write `[Talents.T_FOO]` (the alias almost always being `Talents`, but
 * files also use `local T = require("engine.interface.ActorTalents")`), and a
 * handful use the bare string id. Anything else stays unresolved.
 */
export function talentIdOf(node, aliases) {
  if (!node) return null;
  if (node.kind === 'string') return node.value.startsWith('T_') ? node.value : null;
  if (node.kind !== 'ref') return null;
  const path = node.path;
  if (path.length === 2 && aliases.has(path[0])) return path[1];
  if (path.length === 1 && path[0].startsWith('T_')) return path[0];
  return null;
}

/**
 * Read a talent config value node into `{ level }` or `{ growth }`.
 *
 * `[Talents.T_X] = 3`        -> fixed level 3
 * `[Talents.T_X] = { base, every, max, last }` -> level rules
 * `resolvers.talents{ ... }` may also carry numeric array entries.
 */
export function talentConfigOf(node) {
  if (!node) return null;
  if (node.kind === 'number') return { level: node.value };
  if (node.kind === 'call' && node.path?.join('.') === 'resolvers.talents') return null;
  if (node.kind === 'table') {
    const map = {};
    for (const entry of node.map) {
      const key = keyName(entry.key);
      if (!key) continue;
      const value = literalOf(entry.value);
      if (value !== undefined) map[key] = value;
    }
    if (map.base === undefined && map.every === undefined && map.max === undefined && map.last === undefined) return null;
    return {
      growth: {
        base: typeof map.base === 'number' ? map.base : null,
        every: typeof map.every === 'number' ? map.every : null,
        max: typeof map.max === 'number' ? map.max : null,
        last: typeof map.last === 'number' ? map.last : null,
      },
    };
  }
  return null;
}

// ---------------------------------------------------------------------------
// Entity extraction
// ---------------------------------------------------------------------------

/**
 * Read the literal out of a translation wrapper such as `_t[[...]]`,
 * `_t("...")` or `t("...")`.
 *
 * `_t` is the game's `_t` helper; the parser sees it as an ordinary call, so the
 * string it wraps is one level down. Returns `undefined` for anything else.
 */
export function literalOfTranslationCall(node) {
  if (!node || node.kind !== 'call') return undefined;
  const callee = node.path?.[node.path.length - 1];
  if (callee !== '_t' && callee !== 't' && callee !== 'tformat') return undefined;
  const first = node.args?.[0];
  if (first?.kind === 'string') return first.value;
  return undefined;
}

const LITERAL_FIELD_KEYS = new Set([
  // `base` must be read here: it is what drives the whole inheritance chain.
  'base', 'define_as', 'name', 'type', 'subtype', 'rank', 'unique', 'rarity', 'desc',
  'level_range', 'exp_worth', 'life_rating', 'size_category', 'faction',
  'image', 'add_mos', 'display', 'color', 'ai', 'autolevel', 'auto_classes',
  'can_multiply', 'summon_time', 'on_die', 'on_acquire', 'no_drops', 'female',
  'male', 'never_move', 'immovable', 'fixed_rating', 'max_life', 'tall', 'wide',
  'nice_tile', 'randboss', 'no_difficulty_random_class', 'body', 'resists',
  // Actor speed fields. These are literal template properties, so they can be
  // safely inherited and displayed without trying to execute Lua callbacks.
  'global_speed_base', 'movement_speed', 'combat_physspeed', 'combat_spellspeed',
  'combat_mindspeed',
]);

/**
 * Extract one `newEntity{...}` block into a flat record.
 *
 * Literal scalar fields are read eagerly; talent resolvers keep their call
 * structure so the merge stage can reproduce the engine's array-append
 * behaviour; everything else is summarised into `rawFields` for diagnostics.
 */
export function extractEntity(entityNode, ctx) {
  const fields = {};
  const rawFields = {};
  const talentSources = [];
  const unparsed = [];

  for (const entry of entityNode.fields.map) {
    const key = keyName(entry.key);
    if (key === null) {
      unparsed.push({ reason: 'unknown key', line: entry.line });
      continue;
    }
    if (LITERAL_FIELD_KEYS.has(key)) {
      // Many fields are wrapped in the game's translation call
      // (`desc = _t[[...]]`, `name = _t("...")`), so a literal string can also
      // hide one call deep. Reading the call's own literal is what makes the
      // Chinese locale lookup possible at all.
      const value = literalOf(entry.value) ?? literalOfTranslationCall(entry.value);
      if (value !== undefined) fields[key] = value;
      else if (entry.value.kind === 'function') rawFields[key] = { kind: 'function' };
      else rawFields[key] = { kind: entry.value.kind };
      continue;
    }
    // Uninteresting getters/resolvers; keep a note so nothing is silently lost.
    rawFields[key] = { kind: entry.value?.kind ?? 'unknown' };
  }

  for (const entry of entityNode.fields.array) {
    if (entry?.kind !== 'call') continue;
    const callee = entry.path.join('.');
    if (callee === 'resolvers.talents') {
      const table = entry.args?.[0];
      if (!table || table.kind !== 'table') continue;
      const talents = [];
      for (const item of table.map) {
        const id = talentIdOf(item.key, ctx.aliases);
        const config = talentConfigOf(item.value);
        if (!id || !config) {
          unparsed.push({ reason: 'talent entry', line: item.line, key: literalOf(item.key) });
          continue;
        }
        talents.push({ id, ...config, source: 'fixed' });
      }
      if (talents.length) talentSources.push({ kind: 'talents', talents });
      continue;
    }
    if (callee === 'resolvers.rngtalents') {
      // `resolvers.rngtalents(3, {...})` or `resolvers.rngtalents{...}`
      const flat = [];
      for (const arg of entry.args ?? []) {
        const table = arg?.args?.[0]?.kind === 'table' ? arg.args[0] : arg;
        const collect = (t) => {
          if (!t || t.kind !== 'table') return;
          for (const item of t.map) {
            const id = talentIdOf(item.key, ctx.aliases);
            const config = talentConfigOf(item.value);
            if (id && config) flat.push({ id, ...config });
          }
          for (const child of t.array) collect(child);
        };
        collect(table);
      }
      // The leading numeric argument is how many are picked.
      const count = entry.args?.find((a) => a?.kind === 'number')?.value ?? null;
      if (flat.length) talentSources.push({ kind: 'rngtalents', count, talents: flat });
      continue;
    }
    if (callee === 'resolvers.rngtalentsets') {
      const table = entry.args?.[0];
      if (!table || table.kind !== 'table') continue;
      const sets = [];
      for (const setNode of table.array) {
        if (setNode?.kind !== 'table') continue;
        const set = [];
        for (const item of setNode.map) {
          const id = talentIdOf(item.key, ctx.aliases);
          const config = talentConfigOf(item.value);
          if (id && config) set.push({ id, ...config });
        }
        if (set.length) sets.push(set);
      }
      if (sets.length) talentSources.push({ kind: 'rngtalentsets', sets });
      continue;
    }
    if (callee === 'resolvers.nice_tile') {
      const table = entry.args?.[0];
      rawFields.nice_tile = table ? literalOf(table) : {};
      if (table?.kind === 'table') {
        for (const item of table.map) {
          const k = keyName(item.key);
          if (k === 'image') fields.image = literalOf(item.value);
          if (k === 'tall') fields.tall = literalOf(item.value);
          if (k === 'wide') fields.wide = literalOf(item.value);
          if (k === 'add_mos') fields.add_mos = literalOf(item.value);
        }
      }
      continue;
    }
  }

  return { fields, rawFields, talentSources, unparsed };
}

// ---------------------------------------------------------------------------
// Inheritance
// ---------------------------------------------------------------------------

/**
 * Merge a parent record with a child record the way `Entity:importBase` does.
 *
 * `importBase` clones the base, then `table.mergeAppendArray(temp, t, true)`:
 * scalars from the child win, nested maps merge recursively, and array parts
 * append. Talent resolver lists therefore *accumulate* down the chain and are
 * resolved separately in `resolveTalents`.
 */
export function mergeEntity(parent, child) {
  const merged = { ...child };
  for (const [key, value] of Object.entries(parent)) {
    if (merged[key] === undefined) {
      merged[key] = value;
    } else if (isPlainObject(value) && isPlainObject(merged[key])) {
      merged[key] = { ...value, ...merged[key] };
    }
  }
  return merged;
}

function isPlainObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

/**
 * Resolve the full inheritance chain for one template.
 *
 * Returns the merged scalar fields, the ordered talent source list (parent
 * first, so a child's later `resolvers.talents` entry overrides the parent's
 * definition of the same talent), and any missing parents.
 */
export function resolveEntity(record, byDefineAs, seen = new Set()) {
  const missing = [];
  if (!record.fields.base) {
    return { fields: { ...record.fields }, talentSources: [...record.talentSources], chain: [], missing };
  }
  if (seen.has(record.id)) {
    return { fields: { ...record.fields }, talentSources: [...record.talentSources], chain: [], missing: [{ base: record.id, reason: 'inheritance cycle' }] };
  }
  seen.add(record.id);

  const parent = byDefineAs.get(record.fields.base);
  if (!parent) {
    return {
      fields: { ...record.fields },
      talentSources: [...record.talentSources],
      chain: [],
      missing: [{ base: record.fields.base, reason: 'parent template not found' }],
    };
  }
  const resolvedParent = resolveEntity(parent, byDefineAs, seen);
  return {
    fields: mergeEntity(resolvedParent.fields, record.fields),
    // Child resolvers run after the parent's, so they append.
    talentSources: [...resolvedParent.talentSources, ...record.talentSources],
    chain: [parent.id, ...resolvedParent.chain],
    missing: [...resolvedParent.missing, ...missing],
  };
}

/**
 * Fold an ordered talent-source list into the final, de-duplicated config.
 *
 * The engine learns talents one resolver at a time, so a later entry for the
 * same talent overwrites the earlier level/growth. Random groups are kept
 * separate: they are alternatives, not additional talents.
 */
export function resolveTalents(talentSources) {
  const fixed = new Map();
  const rngPools = [];
  const rngSets = [];

  for (const source of talentSources) {
    if (source.kind === 'talents') {
      for (const talent of source.talents) {
        const existing = fixed.get(talent.id);
        fixed.set(talent.id, {
          ...talent,
          origin: existing ? 'override' : 'declared',
        });
      }
    } else if (source.kind === 'rngtalents') {
      rngPools.push({ count: source.count, talents: source.talents.map((t) => ({ ...t })) });
    } else if (source.kind === 'rngtalentsets') {
      for (const set of source.sets) rngSets.push(set.map((t) => ({ ...t })));
    }
  }

  return { fixed: [...fixed.values()], rngPools, rngSets };
}

// ---------------------------------------------------------------------------
// Image resolution
// ---------------------------------------------------------------------------

/** `NPC:init` default image name: `npc/<type>_<subtype>_<name>.png` lowercased. */
export function autoImageName(fields) {
  if (!fields.name) return null;
  const slug = (value) => String(value ?? 'unknown').toLowerCase().replace(/[^a-z0-9]/g, '_');
  return `npc/${slug(fields.type)}_${slug(fields.subtype)}_${slug(fields.name)}.png`;
}

/**
 * Decide which art a template uses.
 *
 * Mirrors the resolution order that matters for the encyclopedia:
 *  1. an explicit `image` that is not the invisible multi-layer container
 *  2. `resolvers.nice_tile{ image = "invis.png", add_mos = {...} }` overlays
 *  3. `NPC:init`'s automatic `npc/<type>_<subtype>_<name>.png` name
 *
 * `invis.png` is only a container for layered art, so it is never reported as
 * the monster's picture.
 */
export function resolveImage(fields, availableImages, artLookup = null) {
  const layers = [];
  const mos = fields.add_mos;
  if (mos && typeof mos === 'object') {
    const list = Array.isArray(mos.__array) ? mos.__array : Object.values(mos);
    for (const layer of list) {
      if (layer && typeof layer === 'object' && typeof layer.image === 'string') {
        layers.push({
          file: layer.image,
          display_h: layer.display_h ?? null,
          display_w: layer.display_w ?? null,
          display_x: layer.display_x ?? null,
          display_y: layer.display_y ?? null,
        });
      }
    }
  }

  const explicit = typeof fields.image === 'string' ? fields.image : null;
  const usableExplicit = explicit && !/(^|\/)invis\.png$/i.test(explicit) ? explicit : null;

  // A layered tile lists its real art in `add_mos`; prefer that over the
  // container image.
  if (layers.length && !usableExplicit) {
    const main = layers.find((l) => !/(^|\/)invis\.png$/i.test(l.file)) ?? layers[0];
    return {
      image: main.file,
      layers: layers.map((l) => l.file),
      layerMeta: layers,
      kind: 'layered',
      tall: Boolean(fields.tall),
      wide: Boolean(fields.wide),
    };
  }

  if (usableExplicit) {
    return {
      image: usableExplicit,
      layers: layers.map((l) => l.file),
      layerMeta: layers,
      kind: layers.length ? 'layered' : 'explicit',
      tall: Boolean(fields.tall),
      wide: Boolean(fields.wide),
    };
  }

  const auto = autoImageName(fields);
  if (auto && availableImages?.has(auto)) {
    return { image: auto, layers: [], layerMeta: [], kind: 'auto', tall: Boolean(fields.tall), wide: Boolean(fields.wide) };
  }
  if (auto && artLookup) {
    const match = lookupArt(artLookup, fields, auto);
    if (match) {
      return {
        image: match.key,
        layers: [],
        layerMeta: [],
        kind: 'auto-fuzzy',
        match: match.how,
        candidate: auto,
        tall: Boolean(fields.tall),
        wide: Boolean(fields.wide),
      };
    }
  }

  if (layers.length) {
    const main = layers.find((l) => !/(^|\/)invis\.png$/i.test(l.file)) ?? layers[0];
    return {
      image: main.file,
      layers: layers.map((l) => l.file),
      layerMeta: layers,
      kind: 'layered',
      tall: Boolean(fields.tall),
      wide: Boolean(fields.wide),
    };
  }

  return { image: null, layers: [], layerMeta: [], kind: 'missing', candidate: auto, tall: Boolean(fields.tall), wide: Boolean(fields.wide) };
}

// ---------------------------------------------------------------------------
// Whole-dataset extraction
// ---------------------------------------------------------------------------

/** Does this template represent something the player can meet as a monster? */
function isConcrete(fields) {
  return typeof fields.name === 'string' && fields.name.length > 0;
}

/** Abstract/base templates exist only to be inherited from. */
function isAbstract(record, fields) {
  if (/^BASE_/.test(record.defineAs ?? '')) return true;
  // A template with no own name and no inherited name is a base by definition.
  return !isConcrete(fields);
}

/**
 * Read every NPC source and return the raw template records plus the zone
 * references, before classification.
 */
export function collectTemplates(rootDir) {
  const records = [];
  const diagnostics = [];
  const byDefineAs = new Map();
  const fileStats = [];

  for (const source of SOURCES) {
    const sourceRoot = path.join(rootDir, source.dir);
    if (!fs.existsSync(sourceRoot)) {
      diagnostics.push({ file: source.dir, line: 0, message: 'source package missing', severity: 'error' });
      continue;
    }
    const files = [
      ...collectLua(path.join(sourceRoot, 'data/general/npcs')),
      ...collectLua(path.join(sourceRoot, 'data/zones'), { filter: (f) => path.basename(f) === 'npcs.lua' }),
    ];
    let entityCount = 0;
    for (const file of files) {
      const rel = path.relative(rootDir, file);
      const parsed = parseLuaFile(fs.readFileSync(file, 'utf8'), rel);
      const aliases = findTalentAliases(parsed.assignments);
      for (const diagnostic of parsed.diagnostics) {
        diagnostics.push({ ...diagnostic, severity: 'warn', source: source.id });
      }
      for (const entityNode of parsed.entities) {
        const extracted = extractEntity(entityNode, { aliases, source });
        for (const item of extracted.unparsed) {
          diagnostics.push({
            file: rel,
            line: item.line ?? entityNode.line,
            message: `unparsed ${item.reason}`,
            severity: 'info',
            source: source.id,
          });
        }
        const fields = extracted.fields;
        const defineAs = fields.define_as ?? null;
        // Build the record first, then assign a globally unique id in a second
        // pass. A `define_as` is only unique *within one load context*, and the
        // game legitimately re-declares the same one in several zone files
        // (ELANDAR, GLADIATOR, BASE_NPC_NAGA, ...). Those variants must stay
        // separate rows, but they also must not collide as React keys.
        const record = {
          id: defineAs ?? `anon:${rel}:${entityNode.line}`,
          idBase: defineAs ?? `anon:${rel}:${entityNode.line}`,
          defineAs,
          source: source.id,
          file: rel,
          line: entityNode.line,
          fields,
          rawFields: extracted.rawFields,
          talentSources: extracted.talentSources,
          zone: rel.includes('/data/zones/') ? path.basename(path.dirname(rel)) : null,
        };
        records.push(record);
        entityCount += 1;
        if (defineAs) {
          if (byDefineAs.has(defineAs)) {
            diagnostics.push({
              file: rel,
              line: entityNode.line,
              message: `duplicate define_as ${defineAs} (also in ${byDefineAs.get(defineAs).file})`,
              severity: 'warn',
              source: source.id,
            });
          } else {
            byDefineAs.set(defineAs, record);
          }
        }
      }
    }
    fileStats.push({ id: source.id, label: source.label, files: files.length, entities: entityCount });
  }

  // Second pass: make every id unique while keeping the first spelling intact,
  // so existing ids stay stable and duplicates get a readable suffix.
  const idUse = new Map();
  for (const record of records) {
    const base = record.idBase;
    const seen = (idUse.get(base) ?? 0) + 1;
    idUse.set(base, seen);
    record.id = seen === 1 ? base : `${base}#${seen}`;
    if (seen > 1) record.variantOf = base;
  }

  return { records, byDefineAs, diagnostics, fileStats };
}
