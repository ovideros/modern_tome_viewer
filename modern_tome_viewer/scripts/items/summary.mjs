/**
 * Affix effect notes: the part of an ego that is not a property table.
 *
 * Most affixes describe themselves: `wielder = { resists = {...} }` becomes a
 * property row, and the ego page renders it without any prose. A minority do
 * not — a charm's proc, a shield's on-block shrapnel, a staff's "imbued" spell —
 * because the effect lives in a callback that runs at use time. Those affixes
 * used to reach the page as "效果写在运行时回调里，打开详情查看", which is exactly the
 * "you have to open it to find out what it does" problem the list is supposed to
 * solve.
 *
 * Two sources are used, and each note records which one it came from so the page
 * can label it honestly:
 *
 *   `game`   — the callback's own description string. ToME's `charm_on_use` and
 *              `on_block` tables carry a `desc` function whose literal text is
 *              the line the game prints (`("heal for %d"):tformat(...)`). That
 *              text is translated by the same locale table the tooltips use, so
 *              the wording is the game's, not ours. The `%d` placeholders are
 *              tied to the affix's own resolvers, which is the "fix the values"
 *              half of the job: the game fills them from the finished item, the
 *              page fills them from the roll's range.
 *   `source` — a hand-written note for the few callbacks that have no
 *              description string at all (the numeric charm modifiers, the
 *              masteries, the "imbued" spell roll). Each entry quotes the
 *              expression it came from in `from`.
 *
 * Nothing here simulates a roll. A placeholder becomes `{n}`, resolved by the UI
 * against the same value model the property tables use — including the material
 * level selector — and a placeholder with no statically recoverable value stays
 * a visible `?` instead of a guessed number.
 */

import { keyName } from '../monsters/lua-table.mjs';
import { classifyValue, stripFormatColors } from './extract-items.mjs';

/**
 * Callback effects that carry no description string, written out by hand.
 *
 * Every note states the source expression it summarises, because a hand-written
 * sentence is only trustworthy if a reader can check it. `values` mirrors the
 * resolver arguments one-for-one (`mbonus_material(max, add, transform)`), so
 * the numbers stay tied to the source instead of being typed twice.
 */
/**
 * The explicit weighted pool used by `staves.lua` for the `imbued` ego.
 *
 * This is intentionally kept as data rather than only mentioning "random" in
 * prose: the game builds a ticket list (one entry repeated `weight` times) and
 * samples that list once per proc.  The current 1.7.6 source contains 29
 * distinct talents and 155 tickets; it is neither a 22-item nor an equal-
 * probability pool.
 */
export const RANDOM_TALENT_POOLS = {
  'tome:staves:imbued': [
    { talentId: 'T_FLAME', weight: 10 },
    { talentId: 'T_LIGHTNING', weight: 10 },
    { talentId: 'T_MANATHRUST', weight: 10 },
    { talentId: 'T_GLACIAL_VAPOUR', weight: 10 },
    { talentId: 'T_MOONLIGHT_RAY', weight: 10 },
    { talentId: 'T_SUN_BEAM', weight: 10 },
    { talentId: 'T_EARTHEN_MISSILES', weight: 10 },
    { talentId: 'T_SOUL_ROT', weight: 8 },
    { talentId: 'T_DRAIN', weight: 8 },
    { talentId: 'T_TEMPORAL_BOLT', weight: 6 },
    { talentId: 'T_DUST_TO_DUST', weight: 6 },
    { talentId: 'T_RETHREAD', weight: 6 },
    { talentId: 'T_EPIDEMIC', weight: 5 },
    { talentId: 'T_ICE_SHARDS', weight: 5 },
    { talentId: 'T_CHAIN_LIGHTNING', weight: 5 },
    { talentId: 'T_FIREFLASH', weight: 5 },
    { talentId: 'T_ARCANE_VORTEX', weight: 5 },
    { talentId: 'T_CURSE_OF_DEFENSELESSNESS', weight: 3 },
    { talentId: 'T_CURSE_OF_IMPOTENCE', weight: 3 },
    { talentId: 'T_CURSE_OF_DEATH', weight: 3 },
    { talentId: 'T_CURSE_OF_VULNERABILITY', weight: 3 },
    { talentId: 'T_IMPENDING_DOOM', weight: 3 },
    { talentId: 'T_FREEZE', weight: 3 },
    { talentId: 'T_DISPLACEMENT_SHIELD', weight: 3 },
    { talentId: 'T_SUNCLOAK', weight: 1 },
    { talentId: 'T_BONE_SPEAR', weight: 1 },
    { talentId: 'T_CHANNEL_STAFF', weight: 1 },
    { talentId: 'T_EARTHQUAKE', weight: 1 },
    { talentId: 'T_ENTROPY', weight: 1 },
  ],
};

export function egoRandomOptions(egoId) {
  const baseId = egoId.replace(/:greater$/, '');
  return RANDOM_TALENT_POOLS[baseId]?.map((entry) => ({ ...entry })) ?? [];
}

export const CALLBACK_NOTES = {
  // --- charms: the `_modify_charm` numeric modifiers -------------------------
  // `rng.float` multipliers applied to the charm's own power/cooldown, so the
  // absolute numbers cannot be known without the charm they land on.
  'tome:charms:charm_proc_quick': {
    text: '使用该护符时，威力变为原来的 60%~80%，充能消耗变为 60%~90%',
    from: 'charms.lua: use_power.power * rng.float(0.6, 0.8), charm_power * rng.float(0.6, 0.9)',
  },
  'tome:charms:charm_proc_supercharged': {
    text: '使用该护符时，威力变为原来的 110%~130%，充能消耗变为 130%~150%',
    from: 'charms.lua: use_power.power * rng.float(1.1, 1.3), charm_power * rng.float(1.3, 1.5)',
  },
  'tome:charms:charm_proc_overpowered': {
    text: '使用该护符时，威力变为原来的 120%~150%，充能消耗变为 160%~190%',
    from: 'charms.lua: use_power.power * rng.float(1.2, 1.5), charm_power * rng.float(1.6, 1.9)',
  },
  // --- amulets: a mastery in one or two random talent trees ------------------
  // The tree is picked from the trees the player knows, so the page cannot name
  // it; the coefficient is `(10 + rng.mbonus(ceil(30 * ml / 5), level, 50)) / 100`.
  'tome:amulets:mastery': {
    text: '随机一系已掌握技能树的加成系数 +{0}（生成时随机选择，改造该物品会重新选择）',
    values: { 0: { max: 30, add: 10, transform: 'divide', divisor: 100, expression: 'talents_types_mastery[tt] = (10 + rng.mbonus(ceil(30 * ml / 5), level, 50)) / 100' } },
    from: 'amulets.lua: one random known talent type',
  },
  'tome:amulets:perfection:greater': {
    text: '随机两系已掌握技能树的加成系数各 +{0}（生成时随机选择，改造该物品会重新选择）',
    values: { 0: { max: 30, add: 10, transform: 'divide', divisor: 100, expression: 'talents_types_mastery[tt] = (10 + rng.mbonus(ceil(30 * ml / 5), level, 50)) / 100' } },
    from: 'amulets.lua: two random known talent types',
  },
  // --- staves: the "imbued" spell roll ---------------------------------------
  'tome:staves:imbued': {
    text: '法术造成伤害时 10% 概率触发一项法术（从 29 项候选中按权重随机抽取），触发等级 {0}',
    values: { 0: { max: 5, add: 1, transform: null, expression: 'imbued_talent_level = resolvers.mbonus_material(5, 1)' } },
    from: 'staves.lua: talent_on_spell = {{chance=10, talent=<random>, level=e.imbued_talent_level}}',
  },
  // --- shields: on-block shrapnel -------------------------------------------
  'tome:shield:shrapnel': {
    text: '格挡时使 6 格范围内的敌人流血，5 回合内持续造成物理伤害（伤害由物理强度与物理暴击算出，源码未给出固定值）',
    from: 'shield.lua: on_block → shield_shrapnel(who), ball radius 6, DamageType.BLEED',
  },
  // --- staves: `resolvers.command_staff()` -----------------------------------
  // The marker fields (`combat.of_protection = true`) are legacy flags; the real
  // effect is `Object:commandStaff()`, which rewrites the staff's damage type to
  // the flavour's element and adds a share of the staff's own power. The share
  // is `staff_power * mult + add` and `staff_power` is the staff's base damage,
  // so the amount cannot be derived from the ego alone.
  'tome:staves:potent': {
    text: '改造成命令法杖：伤害类型转为该元素，数值按法杖自身强度换算（源码 commandStaff）',
    from: 'staves.lua: resolvers.command_staff() → Object:commandStaff()',
  },
  'tome:staves:greater': {
    text: '改造成命令法杖（高级档）：同时套用该元素类型的全部效果，数值按法杖自身强度换算',
    from: 'staves.lua: combat.is_greater = true, resolvers.command_staff()',
  },
  'tome:staves:warding': {
    text: '改造成命令法杖：护盾充能上限 +（法杖强度 × 0 + 2）',
    from: 'staves.lua: command_staff = {of_warding = {add=2, mult=0, "wards"}}',
  },
  'tome:staves:g. warding': {
    text: '改造成命令法杖（高级档）：护盾充能上限 +（法杖强度 × 0 + 3），并套用全部元素效果',
    from: 'staves.lua: command_staff = {of_greater_warding = {add=3, mult=0, "wards"}}',
  },
  'tome:staves:breaching': {
    text: '改造成命令法杖：获得法杖强度 50% 的全抗性穿透',
    from: 'staves.lua: command_staff = {resists_pen = 0.5} → power = staff_power * 0.5',
  },
  'tome:staves:protection': {
    text: '改造成命令法杖：获得法杖强度 50% 的全抗性',
    from: 'staves.lua: command_staff = {resists = 0.5} → power = staff_power * 0.5',
  },
  // --- weapon / ammo: a random curse on hit ---------------------------------
  'tome:ammo:corruption': {
    text: '命中时 20% 几率触发一项随机诅咒系技能（从 4 项中随机抽取），触发等级 {0}',
    values: { 0: { max: 5, add: 1, transform: null, expression: 'level = e.material_level' } },
    from: 'ammo.lua: talent_on_hit = resolvers.generic(... {chance=20} ...), level = material_level',
  },
  'tome:weapon:corruption': {
    text: '命中时 20% 几率触发一项随机诅咒系技能（从 4 项中随机抽取），触发等级 {0}',
    values: { 0: { max: 5, add: 1, transform: null, expression: 'level = e.material_level' } },
    from: 'weapon.lua: talent_on_hit = resolvers.generic(... {chance=20} ...), level = material_level',
  },
  // --- potions / scrolls / charged (kept: they are still in the dataset) -----
  'tome:potions:acid_proof': { text: '药水效果不会被酸液破坏', from: 'potions.lua: acid_proof = true' },
  'tome:scrolls:fire_proof': { text: '卷轴不会被火焰烧毁', from: 'scrolls.lua: fire_proof = true' },
  'tome:potions:giant': {
    text: '充能次数 +{0}',
    values: { 0: { max: 4, add: 2, transform: null, expression: 'multicharge = resolvers.mbonus(4, 2)' } },
    from: 'potions.lua: multicharge = resolvers.mbonus(4, 2)',
  },
  'tome:scrolls:long': {
    text: '充能次数 +{0}',
    values: { 0: { max: 4, add: 2, transform: null, expression: 'multicharge = resolvers.mbonus(4, 2)' } },
    from: 'scrolls.lua: multicharge = resolvers.mbonus(4, 2)',
  },
  'tome:charged-attack:charged_use_talent': {
    text: '使用该物品时触发一项随机攻击类技能，最大充能 +{0}',
    values: { 0: { max: 6, add: 2, transform: null, expression: 'max_power = resolvers.mbonus_material(6, 2)' } },
    from: 'charged-attack.lua: use_talent = resolvers.random_use_talent({"attack"}, 1)',
  },
  'tome:charged-defensive:charged_use_talent': {
    text: '使用该物品时触发一项随机防御类技能，最大充能 +{0}',
    values: { 0: { max: 6, add: 2, transform: null, expression: 'max_power = resolvers.mbonus_material(6, 2)' } },
    from: 'charged-defensive.lua: use_talent = resolvers.random_use_talent({"defensive"}, 1)',
  },
  'tome:charged-utility:charged_use_talent': {
    text: '使用该物品时触发一项随机辅助类技能，最大充能 +{0}',
    values: { 0: { max: 6, add: 2, transform: null, expression: 'max_power = resolvers.mbonus_material(6, 2)' } },
    from: 'charged-utility.lua: use_talent = resolvers.random_use_talent({"utility"}, 1)',
  },
  // --- infusions: which stat the inscription scales with --------------------
  'tome:infusions:of_the_warrior': { text: '该符文的数值以力量计算', from: 'infusions.lua: inscription_data = { use_stat = "str" }' },
  'tome:infusions:of_the_duelist': { text: '该符文的数值以敏捷计算', from: 'infusions.lua: inscription_data = { use_stat = "dex" }' },
  'tome:infusions:of_the_wizard': { text: '该符文的数值以魔法计算', from: 'infusions.lua: inscription_data = { use_stat = "mag" }' },
  'tome:infusions:of_the_psychic': { text: '该符文的数值以意志计算', from: 'infusions.lua: inscription_data = { use_stat = "wil" }' },
  'tome:infusions:of_the_sneak': { text: '该符文的数值以灵巧计算', from: 'infusions.lua: inscription_data = { use_stat = "cun" }' },
  'tome:infusions:of_the_titan': { text: '该符文的数值以体质计算', from: 'infusions.lua: inscription_data = { use_stat = "con" }' },
};

/**
 * One format token: either the `%%` escape or a `%d` / `%s` / `%.1f` specifier.
 *
 * The escape has to be part of the same pattern, not filtered out afterwards:
 * matching `%(?!%)[-+ #0-9.]*[dsf]` alone against `... by %d%% for 2 turns`
 * skips the first `%` of the pair, then matches the second `%` together with the
 * ` f` of `for` and turns the sentence into `by {0}%?or 2 turns`.
 */
const FORMAT_TOKEN = /%%|%(?!%)[-+ #0-9.]*[dsf]/g;

/** Every `function` node in an entity AST, in document order. */
function functionsOf(root) {
  const out = [];
  (function walk(node, depth) {
    if (!node || typeof node !== 'object' || depth > 40) return;
    if (node.kind === 'function') out.push(node);
    for (const entry of node.map ?? []) walk(entry.value, depth + 1);
    for (const item of node.array ?? []) walk(item, depth + 1);
    for (const arg of node.args ?? []) walk(arg, depth + 1);
    walk(node.of, depth + 1);
    walk(node.left, depth + 1);
    walk(node.right, depth + 1);
  }(root, 0));
  return out;
}

/** The argument text of `tformat(...)`, honouring nested parentheses. */
function tformatArgs(bodyText) {
  const at = bodyText.indexOf('tformat(');
  if (at < 0) return null;
  const open = at + 'tformat('.length - 1;
  let depth = 0;
  for (let i = open; i < bodyText.length; i += 1) {
    const c = bodyText[i];
    if (c === '(') depth += 1;
    else if (c === ')') {
      depth -= 1;
      if (depth === 0) return bodyText.slice(open + 1, i);
    }
  }
  return null;
}

/**
 * Effect tables whose `desc` string is the game's own wording for the callback
 * next to it. Restricting the scan to these parents is what keeps flavour text
 * and unrelated nested entities out of the effect list.
 */
const EFFECT_CONTAINERS = new Set([
  'special_on_hit', 'special_on_crit', 'special_on_kill',
  'on_block', 'on_melee_hit', 'on_hit', 'on_crit',
  'burst_on_hit', 'burst_on_crit', 'charm_on_use', 'use_power',
]);

/**
 * Description strings declared as data rather than inside a callback.
 *
 * Two shapes occur, and both are the game's own wording for a callback effect:
 *
 *   `special_on_hit = { desc = _t"20% chance to stun ... for 3 turns", fct = ... }`
 *     — the description is a plain string next to the function that implements
 *     it, so scanning only `function` nodes misses every one of these. Many have
 *     no placeholder at all, which is why "contains a `%d`" cannot be the filter
 *     here.
 *   `resolvers.charm(_t"setup a psionic shield, reducing all damage taken by
 *     %d for 5 turns", 25, fct, ...)`
 *     — the text is the resolver's first argument; `%d` is filled by
 *     `self:getCharmPower(who)`, which depends on the charm the ego lands on.
 *
 * Only *nested* `desc` keys under an effect table count: the entity's own
 * top-level `desc` is flavour text, not an effect.
 */
function declaredTemplates(root) {
  const out = [];
  const stringOf = (node) => {
    if (!node) return null;
    if (node.kind === 'string') return node.value;
    if (node.kind === 'call' && ['_t', 't'].includes(node.path?.join('.'))) {
      const arg = node.args?.[0];
      return arg?.kind === 'string' ? arg.value : null;
    }
    return null;
  };

  (function walk(node, depth, parentKey) {
    if (!node || typeof node !== 'object' || depth > 40) return;
    if (node.kind === 'call' && (node.path?.join('.') ?? '').endsWith('charm')) {
      const literal = stringOf(node.args?.[0]);
      if (literal && specCount(literal) > 0) out.push(literal);
    }
    for (const entry of node.map ?? []) {
      const key = entry.key?.kind === 'string' ? entry.key.value : null;
      // `depth === 0` is the entity table itself, whose `desc` is flavour text.
      if (depth > 0 && key === 'desc' && EFFECT_CONTAINERS.has(parentKey) && entry.value?.kind !== 'function') {
        const literal = stringOf(entry.value);
        if (literal && looksLikeDescription(literal)) out.push(literal);
      }
      walk(entry.value, depth + 1, key);
    }
    for (const item of node.array ?? []) walk(item, depth + 1, parentKey);
    for (const arg of node.args ?? []) walk(arg, depth + 1, parentKey);
    walk(node.of, depth + 1, parentKey);
    walk(node.left, depth + 1, parentKey);
    walk(node.right, depth + 1, parentKey);
  }(root, 0, null));
  return out;
}

/** A one-line sentence, not an identifier or an empty placeholder. */
function looksLikeDescription(text) {
  const clean = (stripFormatColors(text) ?? text).trim();
  return clean.length >= 12 && /\s/.test(clean) && !/^[a-z0-9_]+$/.test(clean);
}

/**
 * Top-level numeric fields of an entity, as value descriptors.
 *
 * Charm procs keep their rolled amount in a plain field next to the callback
 * (`evasive_chance = resolvers.mbonus_material(30, 10)`) rather than inside a
 * `wielder` table, so the property extractor never sees them. They are exactly
 * what the description template interpolates, hence this second pass.
 */
function entityValues(record) {
  const out = new Map();
  for (const entry of record.ast.map ?? []) {
    const key = keyName(entry.key);
    if (!key || out.has(key)) continue;
    if (entry.value?.kind !== 'call') continue;
    const callee = entry.value.path?.join('.') ?? '';
    if (!callee.startsWith('resolvers.')) continue;
    const classified = classifyValue(entry.value, 1);
    if (classified.kind !== 'resolver') continue;
    out.set(key, {
      range: classified.range ?? null,
      materialRanges: classified.materialRanges ?? null,
      expression: classified.text ?? null,
    });
  }
  return out;
}

/** Count the value placeholders in a template (the `%%` escape does not count). */
function specCount(text) {
  return [...String(text).matchAll(FORMAT_TOKEN)].filter((match) => match[0] !== '%%').length;
}

/**
 * Turn `%d` specifiers into `{0}`, `{1}`, ... placeholders.
 *
 * `%%` is unescaped last: ToME writes `50%%%%` in these templates, which the
 * engine itself prints as `%%`.
 */
function placeholderize(template) {
  let index = 0;
  // The escape is parked on a sentinel so the later `%%` -> `%` pass cannot
  // touch a placeholder, and so `50%%%%` (which the engine prints as `%%`)
  // collapses exactly once.
  const text = String(template).replace(FORMAT_TOKEN, (match) => (match === '%%' ? '\u0000' : `{${index++}}`));
  return { text: text.replace(/\u0000/g, '%'), count: index };
}

/**
 * Build the notes for one ego.
 *
 * `locale` is the `makeLocale` wrapper from `build-items.mjs`. Returns
 * `{ notes }`, where a `game` note is the game's own line with its placeholders
 * preserved and a `source` note is hand-written; both carry `values`, indexed by
 * placeholder number.
 */
export function egoNotes(egoId, record, locale) {
  const notes = [];
  const known = entityValues(record);

  // 1. The game's own description callbacks.
  for (const fn of functionsOf(record.ast)) {
    const template = typeof fn.infoText === 'string' ? fn.infoText : null;
    if (!template || specCount(template) === 0) continue;
    const englishClean = stripFormatColors(template) ?? template;
    const body = typeof fn.bodyText === 'string' ? fn.bodyText : '';
    const args = tformatArgs(body) ?? '';
    // `self.evasive_chance` -> `evasive_chance`; a local (`dam`) has no field
    // behind it and stays a visible `?` by design.
    const refs = [...args.matchAll(/self\.([A-Za-z_][A-Za-z0-9_]*)/g)].map((m) => m[1]);

    const english = placeholderize(englishClean);
    // The locale table is keyed by the string *with* the engine's colour codes
    // (`#VIOLET#%d#LAST#`); looking the stripped text up would miss every one of
    // these lines. Translate first, strip the codes second.
    const translatedRaw = locale.text(template) ?? template;
    const translated = stripFormatColors(translatedRaw) ?? translatedRaw;
    // A translation that changed the number of placeholders is not usable.
    const zh = specCount(translated) === english.count ? placeholderize(translated).text : english.text;
    const values = {};
    for (let i = 0; i < english.count; i += 1) {
      const value = refs[i] ? known.get(refs[i]) : null;
      values[i] = value ?? {
        range: null,
        materialRanges: null,
        // The placeholder is filled by the callback from the wielder or from a
        // local, so there is no item property behind it to resolve.
        expression: refs[i] ? `${refs[i]}（运行时计算）` : '由回调在运行时计算',
      };
    }
    const note = {
      text: zh,
      en: english.text,
      basis: 'game',
      values,
      refs,
    };
    if (!notes.some((entry) => entry.basis === 'game' && entry.en === note.en)) notes.push(note);
  }

  // 2. Description strings declared as data (`desc = _t"..."` beside the
  // callback, or the first argument of `resolvers.charm`).
  for (const template of declaredTemplates(record.ast)) {
    const english = placeholderize(stripFormatColors(template) ?? template);
    const translatedRaw = locale.text(template) ?? template;
    const translated = stripFormatColors(translatedRaw) ?? translatedRaw;
    const zh = specCount(translated) === english.count ? placeholderize(translated).text : english.text;
    const values = {};
    for (let i = 0; i < english.count; i += 1) {
      values[i] = {
        range: null,
        materialRanges: null,
        // `getCharmPower` is `add + charm_power * max / 100`, and `charm_power`
        // belongs to the base charm, not to the ego.
        expression: 'self:getCharmPower(who)（由具体护符的充能威力决定）',
      };
    }
    const note = { text: zh, en: english.text, basis: 'game', values, refs: [] };
    if (!notes.some((entry) => entry.basis === 'game' && entry.en === note.en)) notes.push(note);
  }

  // 3. Hand-written notes for the callbacks that have no description string.
  const curated = CALLBACK_NOTES[egoId] ?? CALLBACK_NOTES[egoId.replace(/:greater$/, '')];
  if (curated) {
    const values = {};
    for (const [index, spec] of Object.entries(curated.values ?? {})) {
      values[index] = {
        range: rangeForSpec(spec),
        materialRanges: materialRangesForSpec(spec),
        expression: spec.expression ?? null,
      };
    }
    // A hand-written note describes the same effect more completely than a
    // template whose numbers are computed at use time (`on_block`'s shrapnel
    // damage comes from the wielder, not from the item). Keeping both would say
    // the same thing twice, once with a `?` in it.
    const kept = notes.filter((note) => note.basis !== 'game' || isComplete(note));
    notes.length = 0;
    notes.push(...kept, { text: curated.text, en: null, basis: 'source', values, from: curated.from, refs: [] });
  }

  return { notes };
}

/** True when every placeholder in a note has a statically recoverable value. */
function isComplete(note) {
  return Object.values(note.values).every((value) => value.range !== null || value.materialRanges !== null);
}

const applyDivisor = (value, spec) => (spec.transform === 'divide' ? value / (spec.divisor ?? 100) : value);
const round = (value) => Math.round(value * 1e6) / 1e6;

/** The widest range a curated note's value can take (material level 5). */
function rangeForSpec(spec) {
  const lo = applyDivisor(spec.add, spec);
  const hi = applyDivisor(spec.add + spec.max, spec);
  return [round(Math.min(lo, hi)), round(Math.max(lo, hi))];
}

/** `materialRanges[level - 1]`, or null when the value ignores the material level. */
function materialRangesForSpec(spec) {
  if (spec.materialLevelRange === null) return null;
  const out = [];
  for (let ml = 1; ml <= 5; ml += 1) {
    const lo = applyDivisor(spec.add, spec);
    const hi = applyDivisor(spec.add + Math.ceil((spec.max * ml) / 5), spec);
    out.push([round(Math.min(lo, hi)), round(Math.max(lo, hi))]);
  }
  return out;
}

/** Whether an ego has a description callback that carries the effect as text. */
export function hasCallbackTemplate(record) {
  return functionsOf(record.ast).some((fn) => typeof fn.infoText === 'string' && specCount(fn.infoText) > 0);
}

export { placeholderize, rangeForSpec, tformatArgs, functionsOf, specCount, declaredTemplates };
