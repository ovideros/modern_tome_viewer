/**
 * Monster encyclopedia data loading and search.
 *
 * `public/data/monsters.json` is produced by scripts/monsters/build-monsters.mjs.
 * It is loaded lazily by the monster page so it never slows down the talent
 * home page, and the inverted talent index is built once on first use.
 */

import { assetUrl } from './data';
import { stripMarkup } from './data';

export interface MonsterTalentGrowth {
  base: number | null;
  every: number | null;
  max: number | null;
  last: number | null;
}

export interface MonsterTalentRef {
  id: string;
  /** Fixed level, when the definition uses a plain number. */
  level: number | null;
  /** `{base, every, max, last}` when the definition describes level growth. */
  growth: MonsterTalentGrowth | null;
  /** `declared` (this template) or `override` (inherited then redefined). */
  origin?: 'declared' | 'override';
}

export interface MonsterRngPool {
  /** How many of the pool are picked, when the source states it. */
  count: number | null;
  talents: MonsterTalentRef[];
}

export type MonsterCategory = 'normal' | 'elite' | 'unique' | 'boss' | 'elite_boss' | 'god' | 'critter';

export interface MonsterImageLayer {
  file: string;
  display_h: number | null;
  display_w: number | null;
  display_x: number | null;
  display_y: number | null;
}

export interface MonsterClassRef {
  raw: string;
  name: string | null;
}

export interface Monster {
  id: string;
  defineAs: string | null;
  /** Set when this row shares a `define_as` with an earlier template. */
  variantOf: string | null;
  name: string;
  nameZh: string | null;
  nameStatus: 'exact' | 'native' | 'missing';
  type: string | null;
  subtype: string | null;
  /** Engine rank: 1 critter, 2 normal, 3 elite, 3.2 rare, 3.5 unique, 4 boss, 5 elite boss, >=10 god. */
  rank: number | null;
  rankKey: string | null;
  category: MonsterCategory;
  categoryLabel: string;
  unique: boolean;
  randboss: boolean;
  /** `no_difficulty_random_class`: opt out of the difficulty-added random class. */
  noDifficultyRandomClass: boolean;
  rarity: number | null;
  levelRange: [number | null, number | null] | null;
  lifeRating: number | null;
  sizeCategory: number | null;
  expWorth: number | null;
  canMultiply: number | null;
  faction: string | null;
  autoClasses: MonsterClassRef[] | null;
  desc: string | null;
  descZh: string | null;
  descStatus: string;
  image: string | null;
  imageKind: 'explicit' | 'auto' | 'auto-fuzzy' | 'layered' | 'missing';
  imageMatch: string | null;
  imageCandidate: string | null;
  layers: MonsterImageLayer[] | null;
  tall: boolean | null;
  wide: boolean | null;
  talents: MonsterTalentRef[];
  rngPools: MonsterRngPool[];
  rngSets: MonsterTalentRef[][];
  inheritance: string[] | null;
  source: string;
  file: string;
  line: number;
  zone: string | null;
  unresolved: { base: string; reason: string }[] | null;
}

export interface MonsterSource {
  id: string;
  label: string;
  en: string;
  dir: string;
  version: string;
  files: number;
  templates: number;
  hash: string | null;
}

export interface MonsterCensus {
  templates: number;
  abstract: number;
  concrete: number;
  distinctNames: number;
  byCategory: Record<string, number>;
  bySource: Record<string, number>;
  bySourceCategory: Record<string, Record<string, number>>;
  fixedBosses: number;
  uniqueFlagged: number;
  randomBossCapable: number;
  noDifficultyRandomClass: number;
  withTalents: number;
  withRandomGroups: number;
  withImage: number;
  withChineseName: number;
}

export interface MonsterDataset {
  version: number;
  gameVersion: string;
  builtAt: string;
  sources: MonsterSource[];
  categoryLabels: Record<string, string>;
  categories: { key: string; label: string; count: number }[];
  census: MonsterCensus;
  monsters: Monster[];
}

export interface MonsterData {
  dataset: MonsterDataset;
  byId: Map<string, Monster>;
  /** Talent id -> monsters that always have it. */
  byFixedTalent: Map<string, Monster[]>;
  /** Talent id -> monsters that can roll it from an exclusive random group. */
  byRandomTalent: Map<string, Monster[]>;
  /** Every talent id any monster references. */
  talentIds: Set<string>;
  /** Precomputed lowercase haystacks for free-text search. */
  haystack: Map<string, string>;
}

let cached: Promise<MonsterData> | null = null;

/** Load the monster dataset once per session. */
export function loadMonsterData(): Promise<MonsterData> {
  cached ??= fetchMonsterData();
  return cached;
}

export function resetMonsterDataCache() {
  cached = null;
}

async function fetchMonsterData(): Promise<MonsterData> {
  const response = await fetch(assetUrl('data/monsters.json'), { cache: 'no-cache' });
  if (!response.ok) throw new Error(`加载怪物数据失败（HTTP ${response.status}）`);
  const dataset = (await response.json()) as MonsterDataset;
  return buildMonsterData(dataset);
}

/** Build the lookup maps and search haystacks for a loaded dataset. */
export function buildMonsterData(dataset: MonsterDataset): MonsterData {
  const byId = new Map<string, Monster>();
  const byFixedTalent = new Map<string, Monster[]>();
  const byRandomTalent = new Map<string, Monster[]>();
  const talentIds = new Set<string>();
  const haystack = new Map<string, string>();

  const addTalent = (map: Map<string, Monster[]>, id: string, monster: Monster) => {
    talentIds.add(id);
    const list = map.get(id);
    if (list) list.push(monster);
    else map.set(id, [monster]);
  };

  for (const monster of dataset.monsters) {
    byId.set(monster.id, monster);
    for (const talent of monster.talents) addTalent(byFixedTalent, talent.id, monster);
    for (const pool of monster.rngPools) for (const talent of pool.talents) addTalent(byRandomTalent, talent.id, monster);
    for (const set of monster.rngSets) for (const talent of set) addTalent(byRandomTalent, talent.id, monster);
    haystack.set(
      monster.id,
      [
        monster.name,
        monster.nameZh,
        monster.type,
        monster.subtype,
        monster.descZh,
        monster.desc,
        monster.defineAs,
        monster.file,
        monster.zone,
        // Every talent the monster can ever have — fixed *and* random-group.
        // Omitting the random ones makes a search for a group talent silently
        // miss the monsters that can roll it.
        ...new Set([
          ...monster.talents.map((talent) => talent.id),
          ...monster.rngPools.flatMap((pool) => pool.talents.map((talent) => talent.id)),
          ...monster.rngSets.flatMap((set) => set.map((talent) => talent.id)),
        ]),
      ]
        .filter(Boolean)
        .join(' ')
        .toLowerCase(),
    );
  }

  return { dataset, byId, byFixedTalent, byRandomTalent, talentIds, haystack };
}

// ---------------------------------------------------------------------------
// Search / filter
// ---------------------------------------------------------------------------

export interface MonsterFilters {
  query: string;
  category: MonsterCategory | 'all';
  source: string | 'all';
  /** Only monsters that teach a talent from an exclusive random group. */
  onlyRandomGroups: boolean;
}

export const emptyMonsterFilters: MonsterFilters = {
  query: '',
  category: 'all',
  source: 'all',
  onlyRandomGroups: false,
};

/**
 * Split a query into search terms.
 *
 * Supported syntax matches the talent search: `"quoted phrase"` keeps spaces,
 * and a leading `-` excludes. Underscores are kept inside a term so that a
 * talent id like `T_CALL_OF_THE_CRYPT` is searched as one string instead of
 * being split into words that any monster matches.
 */
export function parseMonsterQuery(query: string): { term: string; exclude: boolean }[] {
  const source = query.trim().toLowerCase();
  if (!source) return [];
  const terms: { term: string; exclude: boolean }[] = [];
  const pattern = /(-?)"([^"]+)"|(-?)(\S+)/g;
  let match: RegExpExecArray | null;
  while ((match = pattern.exec(source)) !== null) {
    const exclude = (match[1] ?? match[3]) === '-';
    const term = (match[2] ?? match[4]).trim();
    if (term) terms.push({ term, exclude });
  }
  return terms;
}

/**
 * Filter monsters for the list view.
 *
 * The query matches Chinese name, English name, type/subtype and every talent
 * the monster can have — fixed or from a random group — so "T_MULTIPLY" finds
 * the worm masses and "T_CALL_OF_THE_CRYPT" finds the orc necromancer.
 */
export function filterMonsters(data: MonsterData, filters: MonsterFilters): Monster[] {
  const terms = parseMonsterQuery(filters.query);
  return data.dataset.monsters.filter((monster) => {
    if (filters.category !== 'all' && monster.category !== filters.category) return false;
    if (filters.source !== 'all' && monster.source !== filters.source) return false;
    if (filters.onlyRandomGroups && monster.rngPools.length === 0 && monster.rngSets.length === 0) return false;
    if (!terms.length) return true;
    const hay = data.haystack.get(monster.id) ?? '';
    return terms.every(({ term, exclude }) => (exclude ? !hay.includes(term) : hay.includes(term)));
  });
}

/** Display name with the Chinese name preferred, English kept as a subtitle. */
export function monsterDisplayName(monster: Monster): { primary: string; secondary: string | null } {
  if (monster.nameZh && monster.nameZh !== monster.name) return { primary: monster.nameZh, secondary: monster.name };
  return { primary: monster.name, secondary: null };
}

/** Plain-text description, preferring Chinese. */
export function monsterPlainDescription(monster: Monster): string {
  const source = monster.descZh ?? monster.desc ?? '';
  return stripMarkup(source);
}

// ---------------------------------------------------------------------------
// Talent level rules
// ---------------------------------------------------------------------------

export interface TalentLevelInfo {
  /** Level at the first character level the talent applies, when known. */
  base: number | null;
  every: number | null;
  max: number | null;
  last: number | null;
}

/** Normalise a talent reference into its level rule for display. */
export function talentLevelRule(talent: MonsterTalentRef): TalentLevelInfo {
  if (talent.growth) {
    return { base: talent.growth.base, every: talent.growth.every, max: talent.growth.max, last: talent.growth.last };
  }
  return { base: talent.level, every: null, max: null, last: null };
}

/**
 * Chinese explanation of a talent level rule.
 *
 * `base` is the level at the first level the rule applies (see
 * `Actor:resolveLevelTalents`); `every` adds one level per N character levels;
 * `max` caps the raw level; `last` is the highest character level the talent is
 * learned at all. The engine also relaxes `max` above level 50, which is not a
 * per-monster property, so it is not folded in here.
 */
export function describeTalentRule(talent: MonsterTalentRef): string {
  if (talent.growth) {
    const { base, every, max, last } = talent.growth;
    if (base === null && every === null && max === null && last === null) return '条件成长（源码未给出数值）';
    const parts: string[] = [];
    if (base !== null) parts.push(base === 0 ? '初始 0 级（升级后获得）' : `初始 ${base} 级`);
    if (every !== null) parts.push(`每 ${every} 级 +1`);
    if (max !== null) parts.push(`上限 ${max} 级`);
    if (last !== null) parts.push(`${last} 级后不再提升`);
    return parts.join('，');
  }
  if (talent.level !== null) return `固定 ${talent.level} 级`;
  return '等级未在源码声明';
}

/** Category display order for the sidebar. */
export const CATEGORY_ORDER: MonsterCategory[] = ['normal', 'elite', 'unique', 'boss', 'elite_boss', 'god'];

/** Human-readable English rank name, for the detail panel. */
export const RANK_NAMES: Record<number, string> = {
  1: 'critter',
  2: 'normal',
  3: 'elite',
  3.2: 'rare',
  3.5: 'unique',
  4: 'boss',
  5: 'elite boss',
  10: 'god',
};
