/**
 * Property field map, derived from the game's own tooltip code.
 *
 * The authoritative source for `field -> label -> format` is
 * `mod/class/Object.lua`: `desc_wielder` and `descCombat` are the functions that
 * render every property of an item, and each line of them is a
 * `compare_fields(w, compare_with, field, "<key>", "<format>", _t"<label>", ...)`
 * call. Reading that map out of the source means:
 *
 *   - labels stay correct when the game data is updated, instead of drifting
 *     from a hand-copied table;
 *   - Chinese labels come from the same `_t` lookups the game itself uses, so
 *     terminology matches in-game tooltips;
 *   - a field that exists in the data but has no entry here can be reported as
 *     an unmapped gap rather than silently rendered as nothing.
 *
 * This is the same information the Modified Item Descriptions addon reorganises
 * for display; see `docs/item-pipeline.md` for the attribution.
 */

import fs from 'node:fs';
import path from 'node:path';

/** Files that define the tooltip field vocabulary. */
export const FIELD_MAP_SOURCES = [
  { id: 'tome', file: 'tome-src-full/mod/class/Object.lua' },
];

/** Where each property area is rendered, so the UI can group it. */
export const AREA_LABELS = {
  combat: '装备本体',
  special_combat: '装备本体',
  wielder: '穿戴效果',
  carrier: '穿戴效果',
  imbue_powers: '镶嵌效果',
};

/**
 * Split a Lua argument list on top-level commas.
 *
 * Arguments routinely contain nested calls and parentheses
 * (`_t"%+d #LAST#(%+d eff.)", ...`), so a naive `split(',')` corrupts them.
 */
function splitTopLevelArgs(text) {
  const args = [];
  let depth = 0;
  let current = '';
  let quote = null;
  for (let i = 0; i < text.length; i += 1) {
    const c = text[i];
    if (quote) {
      current += c;
      if (c === '\\') { current += text[i + 1] ?? ''; i += 1; continue; }
      if (c === quote) quote = null;
      continue;
    }
    if (c === '"' || c === "'") { quote = c; current += c; continue; }
    if (c === '(' || c === '{') depth += 1;
    if (c === ')' || c === '}') depth -= 1;
    if (c === ',' && depth === 0) { args.push(current.trim()); current = ''; continue; }
    current += c;
  }
  if (current.trim()) args.push(current.trim());
  return args;
}

/** Find every `name(` call in a source string and hand back its raw argument text. */
function findCalls(source, names) {
  const calls = [];
  const pattern = new RegExp(`\\b(${names.join('|')})\\s*\\(`, 'g');
  let match;
  while ((match = pattern.exec(source)) !== null) {
    const open = match.index + match[0].length - 1;
    let depth = 0;
    let quote = null;
    let end = -1;
    for (let i = open; i < source.length; i += 1) {
      const c = source[i];
      if (quote) {
        if (c === '\\') { i += 1; continue; }
        if (c === quote) quote = null;
        continue;
      }
      if (c === '"' || c === "'") { quote = c; continue; }
      if (c === '(') depth += 1;
      else if (c === ')') {
        depth -= 1;
        if (depth === 0) { end = i; break; }
      }
    }
    if (end === -1) continue;
    calls.push({ name: match[1], args: splitTopLevelArgs(source.slice(open + 1, end)) });
    pattern.lastIndex = end;
  }
  return calls;
}

/**
 * Slice out the body of a named Lua function.
 *
 * `desc_wielder` is a **local closure** (`local desc_wielder = function(w, ...)`)
 * declared inside `getTextualDesc`, while `descCombat` is a method
 * (`function _M:descCombat(...)`). Both shapes have to be matched, and the
 * `function` keyword is required so a call site such as
 * `self:desc_wielder(...)` cannot be mistaken for a definition — getting that
 * wrong silently mixes the combat field list into the wielder list, so the
 * boundaries are asserted by tests.
 */
function functionBody(source, name) {
  const patterns = [
    new RegExp(`function\\s+_M:${name}\\s*\\(`),
    new RegExp(`local\\s+${name}\\s*=\\s*function\\s*\\(`),
  ];
  let match = null;
  for (const pattern of patterns) {
    match = pattern.exec(source);
    if (match) break;
  }
  if (!match) return null;
  const start = match.index;

  let depth = 1;
  let quote = null;
  let lineComment = false;
  let longBracket = null;
  let i = source.indexOf('(', start);
  // Skip the parameter list itself before body scanning starts.
  {
    let paren = 0;
    for (; i < source.length; i += 1) {
      if (source[i] === '(') paren += 1;
      else if (source[i] === ')') { paren -= 1; if (paren === 0) { i += 1; break; } }
    }
  }
  for (; i < source.length && depth > 0; i += 1) {
    const c = source[i];
    if (lineComment) { if (c === '\n') lineComment = false; continue; }
    if (longBracket) {
      if (source.startsWith(longBracket, i)) { i += longBracket.length - 1; longBracket = null; }
      continue;
    }
    if (quote) {
      if (c === '\\') { i += 1; continue; }
      if (c === quote) quote = null;
      continue;
    }
    if (c === '-' && source[i + 1] === '-') {
      const long = /^--\[(=*)\[/.exec(source.slice(i, i + 12));
      if (long) { longBracket = `]${long[1]}]`; i += long[0].length - 1; }
      else { lineComment = true; i += 1; }
      continue;
    }
    if (c === '[') {
      const long = /^\[(=*)\[/.exec(source.slice(i, i + 12));
      if (long) { longBracket = `]${long[1]}]`; i += long[0].length - 1; continue; }
    }
    if (c === '"' || c === "'") { quote = c; continue; }
    const word = /^(function|if|for|while|do)\b/.exec(source.slice(i));
    if (word) { depth += 1; i += word[0].length - 1; continue; }
    if (source.startsWith('end', i) && !/[A-Za-z0-9_]/.test(source[i + 3] ?? '')) {
      depth -= 1;
      i += 2;
      continue;
    }
  }
  return source.slice(start, i);
}

/** Read the literal text out of `_t"..."`, `_t'...'` or a plain string arg. */
function stringLiteral(arg) {
  if (!arg) return null;
  const tCall = /^_t\s*(\("|"|')([\s\S]*?)\1\)?$/.exec(arg.trim());
  if (tCall) return tCall[2];
  const plain = /^("|')([\s\S]*)\1$/.exec(arg.trim());
  if (plain) return plain[2];
  return null;
}

/** True when the argument is a `_t"..."` call rather than a bare literal. */
function isTranslationCall(arg) {
  return /^_t\s*(\(|"|')/.test((arg ?? '').trim());
}

/** Read a plain numeric literal argument (`100`), or null. */
function numberLiteral(arg) {
  if (arg === undefined || arg === null) return null;
  const match = /^-?\d+(?:\.\d+)?$/.exec(String(arg).trim());
  return match ? Number(match[0]) : null;
}

/**
 * Fields the tooltip renders with hand-written branches rather than the generic
 * comparison helpers, so `extractFieldMap` cannot see them mechanically.
 *
 * Kept in one explicit table — with the source function each comes from — so the
 * remaining hand-maintained surface is small, visible, and reviewable. The
 * `zh` values are the game's own translations of the corresponding `_t` string
 * (checked against `data/locales/zh_hans.lua`); `extraFields` in
 * `build-items.mjs` fails loudly if one of these keys stops being translated.
 */
export const MANUAL_FIELDS = [
  // --- descCombat: the weapon body itself -----------------------------------
  // `descCombat` renders these with hand-written arithmetic ("Base power: %.1f -
  // %.1f", stat-scaled damage modifiers, damage-type conversion) rather than
  // `compare_fields`, so no mechanical scan can reach them. The `zh` values are
  // the game's own translations of the corresponding `_t` strings.
  { key: 'dam', area: 'combat', kind: 'scalar', label: 'Base power: ', zh: '基础伤害：' },
  { key: 'dammod', area: 'combat', kind: 'table', label: 'Damage modifier', zh: '伤害属性系数' },
  { key: 'damrange', area: 'combat', kind: 'scalar', label: 'Damage range', zh: '伤害浮动范围' },
  { key: 'damtype', area: 'combat', kind: 'ref', label: 'Damage type', zh: '伤害类型' },
  { key: 'convert_damage', area: 'combat', kind: 'table', label: 'Damage conversion: ', zh: '伤害类型转换：' },
  { key: 'melee_project', area: 'combat', kind: 'table', label: 'Damage (Melee): ', zh: '近战附加伤害：' },
  { key: 'ranged_project', area: 'combat', kind: 'table', label: 'Damage (Ranged): ', zh: '远程附加伤害：' },
  { key: 'special_on_hit', area: 'combat', kind: 'special', label: 'On hit', zh: '命中时触发' },
  { key: 'special_on_crit', area: 'combat', kind: 'special', label: 'On crit', zh: '暴击时触发' },
  { key: 'special_on_kill', area: 'combat', kind: 'special', label: 'On kill', zh: '击杀时触发' },
  { key: 'talent_on_hit', area: 'combat', kind: 'special', label: 'When this weapon hits: ', zh: '当该武器击中：' },
  { key: 'talent_on_crit', area: 'combat', kind: 'special', label: 'When this weapon crits: ', zh: '当该武器暴击：' },
  { key: 'burst_on_hit', area: 'combat', kind: 'table', label: 'Burst on hit', zh: '命中时爆裂' },
  { key: 'burst_on_crit', area: 'combat', kind: 'table', label: 'Burst on crit', zh: '暴击时爆裂' },
  { key: 'accuracy_effect', area: 'combat', kind: 'scalar', label: 'Accuracy effect', zh: '命中系数类型' },
  { key: 'accuracy_effect_scale', area: 'combat', kind: 'scalar', label: 'Accuracy effect scale', zh: '命中效果倍率：', note: '命中后附加效果的倍率；0.5 表示按 50% 计算。' },
  { key: 'talented', area: 'combat', kind: 'scalar', label: 'Talent category', zh: '关联技能系' },
  { key: 'is_greater', area: 'combat', kind: 'flag', label: 'Greater ego weapon', zh: '高级词缀武器' },
  { key: 'use_resources', area: 'combat', kind: 'table', label: 'Use resources', zh: '使用消耗' },
  { key: 'ammo_regen', area: 'combat', kind: 'scalar', label: 'Ammo regeneration', zh: '弹药回复' },
  { key: 'element', area: 'combat', kind: 'ref', label: 'Element', zh: '元素类型' },
  { key: 'lifesteal', area: 'combat', kind: 'scalar', label: 'Life leech: ', zh: '吸血：' },
  // --- Orcs DLC (Embers of Rage): steam stats -------------------------------
  { key: 'combat_steampower', area: 'combat', kind: 'scalar', label: 'Steampower: ', zh: '蒸汽强度：' },
  { key: 'combat_steamcrit', area: 'combat', kind: 'scalar', label: 'Steam crit. chance: ', zh: '蒸汽暴击几率：' },
  { key: 'max_steam', area: 'wielder', kind: 'scalar', label: 'Maximum steam: ', zh: '蒸汽上限：' },
  { key: 'steam_boots_on_move', area: 'wielder', kind: 'scalar', label: 'Steam on movement: ', zh: '移动时蒸汽回复：' },

  // --- desc_wielder: telepathy (esp / esp_all), computed per actor-type key ---
  { key: 'esp', area: 'wielder', kind: 'table', label: 'Grants telepathy: ', zh: '获得心灵感应：' },
  { key: 'esp_all', area: 'wielder', kind: 'scalar', label: 'Grants telepathy: ', zh: '获得心灵感应：' },
  { key: 'esp_range', area: 'wielder', kind: 'scalar', label: 'Change telepathy range by : ', zh: '心灵感应范围改变：' },
  // desc_wielder: talent category mastery, rendered as "Talent mastery: ".
  { key: 'talents_types_mastery', area: 'wielder', kind: 'table', label: 'Talent mastery: ', zh: '技能树加成：' },
  { key: 'talent_cd_reduction', area: 'wielder', kind: 'table', label: 'Talent cooldown: ', zh: '技能冷却：' },
  { key: 'learn_talent', area: 'wielder', kind: 'table', label: 'Talent granted: ', zh: '获得技能：' },
  // desc_wielder: `can_breath` prints a sentence listing the environments.
  { key: 'can_breath', area: 'wielder', kind: 'table', label: 'Allows you to breathe in: ', zh: '允许你在以下环境中呼吸：' },
  // desc_wielder: integer flags that print a fixed sentence when > 0.
  { key: 'undead', area: 'wielder', kind: 'flag', label: 'The wearer is treated as an undead.', zh: '佩戴者被视为亡灵。' },
  { key: 'demon', area: 'wielder', kind: 'flag', label: 'The wearer is treated as a demon.', zh: '佩戴者被视为恶魔。' },
  { key: 'blind', area: 'wielder', kind: 'flag', label: 'The wearer is blinded.', zh: '佩戴者失明。' },
  { key: 'sleep', area: 'wielder', kind: 'flag', label: 'The wearer is asleep.', zh: '佩戴者处于睡眠。' },
  { key: 'blind_fight', area: 'wielder', kind: 'flag', label: 'Blind-Fight: ', zh: '盲斗：', note: '允许攻击看不见的目标而无惩罚。' },
  { key: 'lucid_dreamer', area: 'wielder', kind: 'flag', label: 'Lucid Dreamer: ', zh: '清醒梦者：', note: '允许在睡眠中行动。' },
  { key: 'no_breath', area: 'wielder', kind: 'flag', label: 'The wearer no longer has to breathe.', zh: '佩戴者不再需要呼吸。' },
  { key: 'quick_weapon_swap', area: 'wielder', kind: 'flag', label: 'Quick Weapon Swap:', zh: '快速换武器：', note: '切换副武器不消耗回合。' },
  { key: 'avoid_pressure_traps', area: 'wielder', kind: 'flag', label: 'Avoid Pressure Traps: ', zh: '避开压力陷阱：', note: '佩戴者永不触发需要压力的陷阱。' },
  { key: 'speaks_shertul', area: 'wielder', kind: 'flag', label: 'Allows you to speak and read the old Sher\'Tul language.', zh: '允许你读写古夏·图尔语。' },
  { key: 'no_teleport', area: 'wielder', kind: 'flag', label: 'It can not be teleported to.', zh: '无法被传送到。' },
];

function addManualFields(fields) {
  for (const manual of MANUAL_FIELDS) {
    if (fields.has(manual.key)) {
      // The mechanical scan already found it; keep that (richer) entry but mark
      // it so the report knows it needed no hand maintenance.
      continue;
    }
    fields.set(manual.key, {
      key: manual.key,
      area: manual.area,
      kind: manual.kind,
      label: manual.label,
      labelZhManual: manual.zh,
      note: manual.note ?? null,
      manual: true,
    });
  }
}

/** Parse the field vocabulary out of one `Object.lua`.
 *
 * Returns `{ fields: Map<key, entry>, areas: Map<area, string[]>, stats: [...] }`
 * where each entry is
 * `{ key, label, labelZh, format, area, kind, argIndex }`.
 */
export function extractFieldMap(source) {
  const fields = new Map();
  const areas = new Map();

  const wielder = functionBody(source, 'desc_wielder');
  const combat = functionBody(source, 'descCombat');

  const record = (body, area, kind) => {
    if (!body) return;
    for (const call of findCalls(body, ['compare_fields', 'compare_table_fields', 'compare_scaled'])) {
      // `compare_scaled` takes the format and the label in extra argument slots
      // (`scaled, compare_with, field, key, {fn}, format, label`), so the label
      // position differs from `compare_fields`/`compare_table_fields`
      // (`item, compare_with, field, key, format, label`).
      const keyIndex = 3;
      const formatIndex = call.name === 'compare_scaled' ? 5 : 4;
      const labelIndex = call.name === 'compare_scaled' ? 6 : 5;
      // `mod` is the multiplier the tooltip applies to the raw value. It sits
      // after the format/label pair in every shape: `compare_fields(item, items,
      // infield, key, format, label, mod)` and `compare_scaled(item, items,
      // infield, change_field, results, format, label, included, mod)`.
      const modIndex = call.name === 'compare_scaled' ? 8 : 6;
      const name = stringLiteral(call.args[keyIndex]);
      if (!name) continue;
      const label = call.args[labelIndex];
      const entry = {
        key: name,
        // The label is a `_t` lookup in the source; the Chinese text is
        // resolved from the locale snapshot later.
        label: stringLiteral(label),
        labelIsTranslated: isTranslationCall(label ?? ''),
        format: stringLiteral(call.args[formatIndex]) ?? null,
        // The engine's comparison helpers multiply the raw field by `mod`
        // before formatting (`resvalue = (item[field] + ...) * mod`, see
        // `Moddable:compareFields`). Immunities are stored as fractions and
        // printed with `mod = 100`, movement speed likewise, while most fields
        // carry the default of 1. Dropping this factor is how `disarm_immune`
        // ends up printed as `0` instead of `20%`.
        scale: numberLiteral(call.args[modIndex]) ?? 1,
        area,
        kind,
        call: call.name,
      };
      // A key can legitimately appear in more than one area (`resists` lives in
      // `wielder`, while `dam`/`apr` live in `combat`), and both `desc_wielder`
      // and `descCombat` are scanned. Record the primary area from the first
      // scan and remember every area the key was seen in.
      const existing = fields.get(name);
      if (!existing) {
        fields.set(name, entry);
      } else {
        existing.areas = [...new Set([...(existing.areas ?? [existing.area]), area])];
      }
    }
  };

  // `desc_wielder` runs first so that a key present in both defines its primary
  // area as the wearer side; `descCombat` only adds the combat alternative.
  record(wielder, 'wielder', 'nested');
  record(combat, 'combat', 'combat');

  // Non-numeric properties rendered by hand-written branches rather than
  // compare_fields; these are booleans/flags the tooltip prints as a sentence.
  const flagPattern = /if\s+w\.([a-z_]+)\s+and\s+w\.\1\s*>\s*0\s+then([\s\S]*?)end/g;
  if (wielder) {
    let match;
    while ((match = flagPattern.exec(wielder)) !== null) {
      const name = match[1];
      const sentences = [...match[2].matchAll(/_t"([^"]*)"/g)].map((m) => m[1]);
      if (!fields.has(name)) {
        fields.set(name, {
          key: name,
          flag: true,
          area: 'wielder',
          kind: 'flag',
          sentences,
        });
      }
    }
  }

  for (const entry of fields.values()) {
    const list = areas.get(entry.area) ?? [];
    list.push(entry.key);
    areas.set(entry.area, list);
  }

  addManualFields(fields);
  for (const entry of fields.values()) {
    const list = areas.get(entry.area) ?? [];
    if (!list.includes(entry.key)) {
      list.push(entry.key);
      areas.set(entry.area, list);
    }
  }

  return { fields, areas };
}

/** `type = "FIRE"` -> `"fire"`, the string the locale table is keyed by. */
export function damageTypeKeys(source) {
  const out = new Map();
  const pattern = /name\s*=\s*_t\(\s*"([^"]+)"\s*,\s*"damage type"\s*\)\s*,\s*type\s*=\s*"([A-Z0-9_]+)"/g;
  let match;
  while ((match = pattern.exec(source)) !== null) {
    out.set(match[2], { localeKey: match[1], code: match[2] });
  }
  return out;
}

/** Load the map from a workspace root (base game only; items do not extend it). */
export function loadFieldMap(workspaceRoot) {
  const source = FIELD_MAP_SOURCES.find((s) => fs.existsSync(path.join(workspaceRoot, s.file)));
  if (!source) {
    throw new Error('mod/class/Object.lua not found; the item field vocabulary cannot be derived');
  }
  const text = fs.readFileSync(path.join(workspaceRoot, source.file), 'utf8');
  const map = extractFieldMap(text);
  const damageTypes = damageTypeKeys(
    fs.readFileSync(path.join(workspaceRoot, 'tome-src-full/data/damage_types.lua'), 'utf8'),
  );
  return { ...map, damageTypes, file: source.file };
}
