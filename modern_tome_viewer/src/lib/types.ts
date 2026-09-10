/**
 * ToME4 talent viewer — shared data types.
 *
 * These mirror the shapes emitted by scripts/build-data.mjs into public/data.
 */

export interface Cooldown {
  /** Display string as shown in game (may be a level-scaled ladder). */
  display: string | null;
  min: number | null;
  max: number | null;
  /** Every value in the ladder, in level order. */
  values: number[];
  /**
   * `fixed_cooldown = true`: no effect may change this cooldown
   * (`Actor.lua:6872` — "Can not touch this cooldown"). The in-game character
   * sheet prints it as "Fixed Cooldown: N".
   */
  fixed: boolean;
}

export type RangeKind = 'melee' | 'bow' | 'distance' | 'other';

export interface TalentRange {
  display: string | null;
  kind: RangeKind;
  min: number | null;
  max: number | null;
}

export type CostKind = 'cost' | 'sustain' | 'gain' | 'drain';

export interface TalentCost {
  display: string | null;
  /** Stable resource key, e.g. "mana", "stamina", or null when unknown. */
  resource: string | null;
  /** Chinese label, e.g. "法力". */
  resourceLabel: string | null;
  amount: number | null;
  kind: CostKind | null;
}

export interface TalentRequirement {
  display: string;
  level: number | null;
  stat: string | null;
  statValue: number | null;
}

export type TalentFlags = Record<string, true>;

export interface Talent {
  id: string;
  /** Display name, may contain <span style="color:…"> markup. */
  name: string;
  plainName: string;
  shortName: string;
  image: string | null;
  /** Tree id, e.g. "spell/fire". */
  tree: string;
  /** Position inside the tree (1-based in game terms). */
  index: number;
  mode: string;
  points: number;
  cooldown: Cooldown;
  range: TalentRange;
  cost: TalentCost;
  useSpeed: string;
  require: TalentRequirement[];
  /** Rich HTML for display, colour markup already converted to spans. */
  text: string;
  /** Scaling metadata for every computed value in `text` (precomputed). */
  acronyms: import('./scaling').Acronym[];
  /** Markup-stripped text used for full-text search. */
  plain: string;
  flags: TalentFlags;
  source: string | null;
}

export interface TalentTree {
  id: string;
  category: string;
  name: string;
  plainName: string;
  description: string;
  plainDescription: string;
  /** Class ids that can learn this tree. */
  classes: string[];
  talentCount: number;
  talents: Talent[];
}

export interface TalentDataset {
  trees: TalentTree[];
}

export interface TallyEntry {
  value: string;
  count: number;
}

export interface CategoryMeta {
  id: string;
  name: string;
  treeCount: number;
  talentCount: number;
}

export interface TreeRef {
  id: string;
  name: string;
  /** Category mastery multiplier (0.9 – 1.3). */
  mastery: number;
  /**
   * False when the category is locked and needs a category point to unlock.
   * Upstream stores the inverse ("unlocked"); the build script normalizes it.
   */
  unlocked: boolean;
  talentCount: number;
}

/** A portrait asset referenced by a class or race record. */
export interface PortraitRef {
  /** Path relative to public/img, e.g. "class-icons/bulwark_128_bg.png". */
  file: string;
  width: number | null;
  height: number | null;
}

export interface SubclassMeta {
  id: string;
  name: string;
  englishName: string;
  description: string;
  plainDescription: string;
  locked: boolean;
  images: PortraitRef[];
  /** Attribute modifiers keyed by str/dex/con/mag/wil/cun. */
  stats: Record<string, number>;
  lifeRating: number | null;
  extraTalentPoints: number | null;
  extraGenericPoints: number | null;
  extraTreePoints: number | null;
  /** Talent ids the subclass starts with, e.g. ["T_BERSERKER_RAGE"]. */
  startingTalents: string[];
  classTrees: TreeRef[];
  genericTrees: TreeRef[];
}

export interface ClassMeta {
  id: string;
  name: string;
  englishName: string;
  description: string;
  plainDescription: string;
  subclasses: SubclassMeta[];
}

export interface SubraceMeta {
  id: string;
  name: string;
  englishName: string;
  description: string;
  plainDescription: string;
  images: PortraitRef[];
  stats: Record<string, number>;
  lifeRating: number | null;
  experience: number | null;
  size: string | null;
  trees: TreeRef[];
}

export interface RaceMeta {
  id: string;
  name: string;
  englishName: string;
  description: string;
  plainDescription: string;
  subraces: SubraceMeta[];
}

export interface TreeMeta {
  id: string;
  name: string;
  category: string;
  talentCount: number;
}

export interface DatasetMeta {
  gameVersion: string;
  dataVariant: string;
  categories: CategoryMeta[];
  treeNames: TreeMeta[];
  classList: { id: string; name: string }[];
  raceList: { id: string; name: string }[];
  classes: ClassMeta[];
  races: RaceMeta[];
  facets: {
    mode: TallyEntry[];
    useSpeed: TallyEntry[];
    rangeKind: TallyEntry[];
    resource: TallyEntry[];
    costKind: TallyEntry[];
    flag: TallyEntry[];
  };
  bounds: {
    cooldown: { min: number; max: number };
    range: { min: number; max: number };
  };
  iconSize: number;
  iconDir: string;
}

export interface BuildManifest {
  builtAt: string;
  gameVersion: string;
  dataVariant: string;
  source: string;
  counts: { trees: number; talents: number; icons: number; classes: number; races: number };
  missingIcons: number;
  sizeBytes: { talents: number; meta: number };
  hash: string;
}

/** A talent paired with the tree it belongs to, for flat list rendering. */
export interface TalentEntry extends Talent {
  treeName: string;
  treePlainName: string;
  category: string;
  categoryName: string;
}
