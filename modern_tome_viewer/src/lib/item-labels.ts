/**
 * The item property vocabulary, shared by the tooltip renderer and the one-line
 * summaries on the list cards.
 *
 * These tables used to live inside `ItemProperties.tsx`. They moved here because
 * the ego list needs the *same* words as the detail panel: a card that says
 * `FIRE +10` while the panel says `火焰 +10%` is a bug the reader cannot
 * reconcile, and two copies of the vocabulary drift apart the moment one is
 * updated.
 */

/** Display groups, in the order the game's own tooltip presents them. */
export const GROUP_ORDER = ['offense', 'defense', 'utility'] as const;
export type GroupKey = (typeof GROUP_ORDER)[number];

export const GROUP_LABELS: Record<GroupKey, string> = {
  offense: '进攻',
  defense: '防御',
  utility: '资源与其他',
};

/**
 * Field key -> display group.
 *
 * Attribution follows the game's own tooltip order in `desc_wielder`: offence
 * first (accuracy, power, crit, penetration), then defence (armour, saves,
 * resistances, immunities, life), then everything else. Keys absent from this
 * table land in `utility` and are reported as unmapped by the build, so a new
 * field shows up in the interface instead of disappearing.
 */
export const FIELD_GROUP: Record<string, GroupKey> = {
  // --- Offence ---
  combat_atk: 'offense',
  combat_apr: 'offense',
  combat_dam: 'offense',
  combat_physcrit: 'offense',
  combat_critical_power: 'offense',
  combat_spellpower: 'offense',
  combat_spellcrit: 'offense',
  combat_mindpower: 'offense',
  combat_mindcrit: 'offense',
  combat_steampower: 'offense',
  combat_steamcrit: 'offense',
  combat_physspeed: 'offense',
  combat_spellspeed: 'offense',
  combat_mindspeed: 'offense',
  inc_damage: 'offense',
  inc_damage_actor_type: 'offense',
  resists_pen: 'offense',
  damage_shield_penetrate: 'offense',
  iceblock_pierce: 'offense',
  melee_project: 'offense',
  ranged_project: 'offense',
  on_melee_hit: 'offense',
  lifesteal: 'offense',
  life_leech_chance: 'offense',
  life_leech_value: 'offense',
  resource_leech_chance: 'offense',
  resource_leech_value: 'offense',
  spellsurge_on_crit: 'offense',
  talent_on_hit: 'offense',
  talent_on_crit: 'offense',
  special_on_hit: 'offense',
  special_on_crit: 'offense',
  special_on_kill: 'offense',
  burst_on_hit: 'offense',
  burst_on_crit: 'offense',
  inc_stats: 'offense',
  blinding_speed: 'offense',

  // --- Defence ---
  combat_armor: 'defense',
  combat_armor_hardiness: 'defense',
  combat_def: 'defense',
  combat_def_ranged: 'defense',
  fatigue: 'defense',
  resists: 'defense',
  resists_cap: 'defense',
  resists_actor_type: 'defense',
  damage_affinity: 'defense',
  flat_damage_armor: 'defense',
  wards: 'defense',
  combat_physresist: 'defense',
  combat_spellresist: 'defense',
  combat_mentalresist: 'defense',
  max_life: 'defense',
  life_regen: 'defense',
  healing_factor: 'defense',
  die_at: 'defense',
  evasion: 'defense',
  projectile_evasion: 'defense',
  cancel_damage_chance: 'defense',
  ignore_direct_crits: 'defense',
  combat_crit_reduction: 'defense',
  resist_unseen: 'defense',
  damage_resonance: 'defense',
  damage_backfire: 'defense',
  shield_dur: 'defense',
  shield_factor: 'defense',
  shield_windwall: 'defense',
  slow_projectiles: 'defense',
  // Status immunities share one group; each is still listed separately.
  blind_immune: 'defense',
  poison_immune: 'defense',
  disease_immune: 'defense',
  cut_immune: 'defense',
  silence_immune: 'defense',
  disarm_immune: 'defense',
  confusion_immune: 'defense',
  sleep_immune: 'defense',
  pin_immune: 'defense',
  stun_immune: 'defense',
  fear_immune: 'defense',
  knockback_immune: 'defense',
  instakill_immune: 'defense',
  teleport_immune: 'defense',
};

/** Labels whose values belong on one shared row, with their short tag. */
export const ROW_GROUPS: { id: string; label: string; keys: string[] }[] = [
  { id: 'resist', label: '抗性', keys: ['resists'] },
  { id: 'resist-cap', label: '抗性上限', keys: ['resists_cap'] },
  { id: 'resist-pen', label: '抗性穿透', keys: ['resists_pen'] },
  { id: 'affinity', label: '伤害亲和（治疗）', keys: ['damage_affinity'] },
  { id: 'flat-armor', label: '固定减伤', keys: ['flat_damage_armor'] },
  { id: 'wards', label: '护盾充能上限', keys: ['wards'] },
  {
    id: 'immune',
    label: '状态免疫',
    keys: [
      'blind_immune', 'poison_immune', 'disease_immune', 'cut_immune', 'silence_immune',
      'disarm_immune', 'confusion_immune', 'sleep_immune', 'pin_immune', 'stun_immune',
      'fear_immune', 'knockback_immune', 'instakill_immune', 'teleport_immune',
    ],
  },
  { id: 'stats', label: '属性', keys: ['inc_stats'] },
  { id: 'damage', label: '伤害加成', keys: ['inc_damage'] },
  { id: 'melee-project', label: '近战附加伤害', keys: ['melee_project'] },
  { id: 'ranged-project', label: '远程附加伤害', keys: ['ranged_project'] },
  { id: 'on-hit', label: '被近战击中时', keys: ['on_melee_hit'] },
  { id: 'dmg-type', label: '伤害类型', keys: ['damage_affinity', 'inc_damage_actor_type'] },
];

/** Short Chinese tags for the status immunities, which all share one row. */
export const IMMUNITY_TAGS: Record<string, string> = {
  blind_immune: '致盲',
  poison_immune: '毒素',
  disease_immune: '疾病',
  cut_immune: '流血',
  silence_immune: '沉默',
  disarm_immune: '缴械',
  confusion_immune: '混乱',
  sleep_immune: '睡眠',
  pin_immune: '定身',
  stun_immune: '震慑/冰冻',
  fear_immune: '恐惧',
  knockback_immune: '击退',
  instakill_immune: '即死',
  teleport_immune: '传送',
};

/** Chinese names for stats, keyed by the engine's `Stats.STAT_*` name. */
export const STAT_TAGS: Record<string, string> = {
  STAT_STR: '力量',
  STAT_DEX: '敏捷',
  STAT_CON: '体质',
  STAT_MAG: '魔法',
  STAT_WIL: '意志',
  STAT_CUN: '灵巧',
  STAT_LCK: '幸运',
};

/** Area heading: what the effect applies to, kept separate from the groups. */
export const AREA_HEADINGS: Record<string, { title: string; note: string | null }> = {
  combat: { title: '装备本体属性', note: '这件武器/弹药自身的数值，不是穿戴者获得的属性' },
  special_combat: { title: '盾击与副手攻击', note: '使用盾击类技能时生效' },
  wielder: { title: '穿戴时生效', note: null },
  carrier: { title: '携带时生效', note: null },
  imbue_powers: { title: '镶嵌时生效', note: null },
};

/** Chinese label for one damage-type code, falling back to the code itself. */
export function damageTag(code: string | null, damageTypes: Record<string, string>): string | null {
  if (!code) return null;
  return damageTypes[code] ?? STAT_TAGS[code] ?? code;
}

/**
 * Labels for the bare-key values a property row can carry.
 *
 * `inc_damage_actor_type = { living = 20 }`, `talents_types_mastery =
 * { ['wild-gift/fungus'] = 0.1 }` and a granted talent (`learn_talent` /
 * `talent_on_hit`) all store a code where a display name belongs. Without this
 * the page shows `living`, `wild-gift/fungus` and `Talents.T_WARD` — engine
 * identifiers, printed as if they were the effect.
 *
 * `actorTypes` comes from the dataset (the build resolves it through the
 * engine's own "actor type" locale context); talents and trees come from the
 * talent data the page has already loaded, so no extra fetch is needed.
 */
export function makeCodeLabeler(sources: {
  actorTypes?: Record<string, string>;
  /** Engine talent code (`T_WARD`) -> Chinese name. */
  talent?: (code: string) => string | null;
  /** Talent tree id (`wild-gift/fungus`) -> Chinese name. */
  tree?: (id: string) => string | null;
}): (code: string) => string | null {
  return (code: string) => {
    if (!code) return null;
    // `Talents.T_WARD` is written as a reference; the code alone is the name.
    const bare = code.startsWith('Talents.') ? code.slice('Talents.'.length) : code;
    if (bare === 'all') return '全部';
    if (sources.actorTypes?.[bare]) return sources.actorTypes[bare];
    // A tree id always has the `category/subcategory` shape.
    if (bare.includes('/')) return sources.tree?.(bare) ?? null;
    if (bare.startsWith('T_')) return sources.talent?.(bare) ?? null;
    return null;
  };
}
