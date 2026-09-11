/**
 * Item encyclopedia data: equipment ego affixes and fixed artifacts.
 *
 * Both datasets are produced by `scripts/items/build-items.mjs` and are loaded
 * lazily by their own page, so the talent home page never waits for them. Two
 * conventions in the wire format are worth knowing before reading a row:
 *
 *  - `file` fields are **indexes** into `report.files`, not paths, and
 *    `properties`/`areas` store only row-specific facts: a property's Chinese
 *    label, unit and display area live once in `fieldMeta[key]`.
 *  - a value is never a bare number when the game did not write one. `kind`
 *    says whether the number is a literal, a resolver with a recoverable range,
 *    or a runtime computation that must be described in words instead of
 *    rendered as a digit. Treating every value as a number is the mistake this
 *    model exists to prevent.
 */

import { assetUrl } from './data';

/** How a value was written in the source, which decides how it may be shown. */
export type ItemValueKind = 'literal' | 'resolver' | 'computed' | 'function' | 'table' | 'ref' | 'empty' | 'special' | 'flag' | 'scalar' | 'nested' | 'unknown';

/** One cell of a grouped property, e.g. `火焰 +20%` inside `抗性改变`. */
export interface ItemPropItem {
  key: string | null;
  /** Damage-type code (`FIRE`) or stat code (`STAT_MAG`), when the key was a reference. */
  code: string | null;
  ref: string | null;
  kind: ItemValueKind;
  value?: number | string | boolean;
  /** Recoverable static range at the widest material level. */
  range?: [number, number] | null;
  /**
   * One range per material level 1–5, in the units the tooltip prints; null
   * when the value ignores the material level.
   *
   * This is what the ego page's material-level selector indexes. It comes from
   * `resolvers.mbonus_material(max, add, fct)`, whose range at level `ml` is
   * `add ~ add + ceil(max * ml / 5)`, after `fct` and the field's tooltip scale
   * have been applied.
   */
  materialRanges?: [number, number][] | null;
  /** Chinese explanation of how the number varies, e.g. `随材料等级变化`. */
  meaning?: string | null;
  resolver?: string | null;
  /** Source expression, shown when no range can be recovered. */
  text?: string | null;
  line?: number;
}

/** A property row such as `抗性改变` or `震慑免疫`. */
export interface ItemProp {
  key: string;
  kind: ItemValueKind;
  separator: string;
  /** Set when the property was written more than once (a child overriding its base). */
  overridden?: boolean;
  /** Set when the game's own label had no Chinese translation. */
  untranslatedLabel?: boolean;
  source: { file: number; line: number };
  items?: ItemPropItem[];
  value?: number | string | boolean;
  range?: [number, number] | null;
  /** One range per material level 1–5; null when the value ignores it. */
  materialRanges?: [number, number][] | null;
  meaning?: string | null;
  resolver?: string | null;
  text?: string | null;
  ref?: string | null;
}

/** Label vocabulary shared by every row, keyed by property key. */
export interface ItemFieldMeta {
  area: string;
  kind: ItemValueKind;
  label: string;
  labelZh: string;
  format: string | null;
  unit: string | null;
  /**
   * Multiplier the engine's tooltip applies before printing (`raw * scale`).
   * Immunities and movement speed are stored as fractions and printed with
   * `scale = 100`; values in the datasets already include it.
   */
  scale?: number;
  manualMapping?: boolean;
  note?: string;
}

export interface ItemPropertyGroup {
  area: string;
  props: ItemProp[];
}

export interface ItemApplicability {
  pool: string;
  type: string | null;
  typeZh: string | null;
  subtype: string | null;
  subtypeZh: string | null;
  slot: string | null;
  slotZh: string | null;
  /** `own` when the ego lives in this pool, `shared` when it is loaded into it. */
  via: 'own' | 'shared';
  example: string | null;
}

export interface EgoName {
  raw: string | null;
  clean: string;
  zh: string | null;
  /** Name placeholders the engine fills at generation time (`RESIST`, ...). */
  tokens: string[];
}

/**
 * One value a note's text interpolates.
 *
 * Same shape as a property value, so the material-level selector moves a charm
 * proc's "heal for N" exactly as it moves a resistance row. `range === null`
 * means the value is computed at use time from the wielder, not from the item:
 * the page prints `?` rather than a made-up number.
 */
export interface EgoNoteValue {
  range: [number, number] | null;
  materialRanges: [number, number][] | null;
  expression: string | null;
}

/**
 * An effect that is not a property table.
 *
 * `basis: 'game'` is the game's own description string (translated by the same
 * locale table the tooltips use), with `%d` placeholders turned into `{0}`,
 * `{1}`. `basis: 'source'` is a hand-written note for a callback that has no
 * description string; `from` quotes the expression it summarises.
 */
export interface EgoNote {
  text: string;
  /** The English original of a `game` note, kept for cross-checking. */
  en: string | null;
  basis: 'game' | 'source';
  values: Record<string, EgoNoteValue>;
  from?: string;
  refs?: string[];
}

export interface Ego {
  id: string;
  source: string;
  file: number;
  line: number;
  pool: string;
  pools: string[];
  position: 'prefix' | 'suffix' | 'unknown';
  greater: boolean;
  variantOf: string | null;
  uniqueEgoTag: string | null;
  rarity: number | null;
  levelRange: number[] | null;
  cost: number | null;
  powerSources: string[];
  name: EgoName;
  keyword: string;
  keywords: string[];
  desc: string | null;
  applicable: ItemApplicability[];
  areas: ItemPropertyGroup[];
  /** Effects with no property table: charm procs, on-block effects, imbued spells. */
  notes?: EgoNote[];
  /** Property keys with no field-map entry; surfaced, never hidden. */
  unmapped: string[];
  definitions: { file: number; line: number }[];
}

export interface ArtifactRequirementStat {
  key: string | null;
  amount: number | null;
}

export interface ArtifactRequirement {
  kind: string | null;
  amount?: number;
  stats?: ArtifactRequirementStat[];
}

export interface ArtifactUseTalent {
  talentId: string;
  talentRef: string | null;
  level: number | null;
  power: number | null;
}

export interface ArtifactUsePower {
  name: string | null;
  nameIsFunction: boolean;
  nameZh: string | null;
  power: number | null;
  cooldown: number | null;
}

export interface ArtifactSpecialDesc {
  en: string | null;
  zh: string | null;
  /** Set when the text is assembled at runtime rather than being a literal. */
  computed?: boolean;
}

export interface Artifact {
  id: string;
  source: string;
  file: number;
  line: number;
  defineAs: string | null;
  base: string | null;
  chain: string[];
  missingBase: string | null;
  name: string;
  nameZh: string | null;
  unidedName: string | null;
  desc: string | null;
  descZh: string | null;
  type: string | null;
  typeZh: string | null;
  subtype: string | null;
  subtypeZh: string | null;
  slot: string | null;
  slotZh: string | null;
  offslot: string | null;
  tier: number | null;
  rarity: number | null;
  levelRange: number[] | null;
  cost: number | null;
  encumber: number | null;
  metallic: boolean | null;
  image: string | null;
  imagePath?: string;
  imageMatch?: string;
  quest: boolean;
  powerSources: string[];
  require: ArtifactRequirement[] | null;
  useTalent: ArtifactUseTalent | null;
  usePower: ArtifactUsePower | null;
  specialDesc: ArtifactSpecialDesc | null;
  properties: ItemPropertyGroup[];
  unlidded: string[];
  sets: string | null;
  status: 'included' | 'non-equipment';
  inclusionReason: string;
  definitions: { file: number; line: number; zone: string | null }[];
  variantNote?: string;
}

export interface ItemLabels {
  areas: Record<string, string>;
  slots: Record<string, string>;
  nameTokens: Record<string, { zh: string; note: string }>;
  /** Engine damage-type code -> Chinese, e.g. `FIRE` -> 火焰. */
  damageTypes: Record<string, string>;
  /**
   * Engine actor-type code -> Chinese, e.g. `living` -> 生命.
   *
   * `inc_damage_type = { living = 20 }` and `resists_actor_type = { summoned = 30 }`
   * key a bonus by actor type; without this the page would print the raw code.
   */
  actorTypes?: Record<string, string>;
}

export interface ItemSourceMeta {
  id: string;
  label: string;
  version: string;
}

export interface ItemSemantics {
  rarity: string;
  levelRange: string;
  mbonusMaterial: string;
}

interface ItemDatasetBase {
  generatedAt: string;
  labels: ItemLabels;
  sources: ItemSourceMeta[];
  semantics: ItemSemantics;
  fieldMeta: Record<string, ItemFieldMeta>;
}

export interface EgoDataset extends ItemDatasetBase {
  counts: { egos: number };
  egos: Ego[];
}

export interface ArtifactDataset extends ItemDatasetBase {
  counts: { fields: number; egos: number; artifacts: number };
  artifacts: Artifact[];
}

/** Source paths, indexed by the `file` ids stored on rows. */
export interface ItemsReport {
  generatedAt: string;
  files: string[];
  counts: Record<string, number>;
  skipped: { reason: string; count: number }[];
  unmappedPropertyKeys: { key: string; count: number }[];
  untranslatedLabels: { label: string; count: number }[];
  duplicateDefinitions: { id: string; kept: string; also: string }[];
  imageMatchKinds?: Record<string, number>;
  resolverGeneratedImages?: { id: string; name: string | null; image: string; reason: string }[];
  missingTranslations: { id: string; name: string | null; kind: string }[];
  missingImages: { id: string; name: string | null; image: string | null; reason: string }[];
  pools: { pool: string; source: string; file: string; loads: string[]; egoCount: number; baseItems: { defineAs: string | null; name: string | null; type: string | null; subtype: string | null; slot: string | null }[] }[];
  semantics: ItemSemantics;
  [key: string]: unknown;
}

/**
 * Extra search terms for properties whose in-game label differs from the terms
 * readers use, and for grouped rows whose shared label lives outside any single
 * property (`抗性` covers `resists`, which is labelled `抗性改变`).
 */
const GROUP_SEARCH_ALIASES: Record<string, string> = {
  resists: '抗性 抗性改变',
  resists_cap: '抗性上限',
  resists_pen: '抗性穿透',
  damage_affinity: '伤害亲和 伤害吸收',
  stun_immune: '震慑免疫 冰冻免疫 眩晕免疫',
  confusion_immune: '混乱免疫',
  blind_immune: '致盲免疫',
  poison_immune: '毒素免疫',
  disease_immune: '疾病免疫',
  cut_immune: '流血免疫',
  silence_immune: '沉默免疫',
  disarm_immune: '缴械免疫',
  sleep_immune: '睡眠免疫',
  pin_immune: '定身免疫',
  fear_immune: '恐惧免疫',
  knockback_immune: '击退免疫',
  instakill_immune: '即死免疫',
  teleport_immune: '传送免疫',
  inc_damage: '伤害加成',
  inc_stats: '属性加值',
  talents_types_mastery: '技能树加成',
  combat_critical_power: '暴击伤害',
  healing_factor: '治疗系数',
  max_life: '生命上限',
  lite: '光照',
};

/**
 * The community supplement layer.
 *
 * Rows come from the user-provided spreadsheet and are matched to ego ids with
 * their worksheet and row preserved, so any value here can be traced back to a
 * cell. Community ratings and remarks are **opinion**, kept apart from the
 * game-derived data everywhere they are shown; the source value always wins a
 * disagreement (`conflicts` records those, it never overwrites).
 */
export interface CommunityRow {
  sheet: string;
  row: number;
  rawName: string;
  greater: string;
  effect: string;
  rarity: string;
  recommend: string;
  note: string;
  match: string;
  confidence: string;
  updated: boolean;
}

export interface CommunityUnmatched extends Omit<CommunityRow, 'updated' | 'match' | 'confidence'> {
  pool: string;
  allowedPools: string[];
  crossPool: { id: string; pool: string; pools: string[] }[];
}

export interface CommunityConflict {
  sheet: string;
  row: number;
  rawName: string;
  egoId: string;
  excelRarity: string;
  sourceRarity: number | null;
  match: string;
  confidence: string;
}

export interface CommunityDataset {
  generatedAt: string;
  source: { file: string; sheetCount: number; rowCount: number };
  byEgoId: Record<string, CommunityRow>;
  extra: CommunityUnmatched[];
  conflicts: CommunityConflict[];
}

// ---------------------------------------------------------------------------
// Loading
// ---------------------------------------------------------------------------

let egoCache: Promise<LoadedEgos> | null = null;
let artifactCache: Promise<LoadedArtifacts> | null = null;

export interface LoadedEgos {
  dataset: EgoDataset;
  report: ItemsReport;
  /** Community rows keyed by ego id, or null when the supplement is absent. */
  community: CommunityDataset | null;
  byId: Map<string, Ego>;
  /** `pool -> egos`, so a slot filter is a lookup rather than a scan. */
  byPool: Map<string, Ego[]>;
  /** Search haystack per ego id, built once. */
  haystack: Map<string, string>;
  /** A `byPool` key list in display order (see `EGO_SLOT_GROUPS`). */
  pools: string[];
  /**
   * Pool id -> Chinese label and the ego count behind it.
   *
   * Derived from the curated `EGO_SLOT_GROUPS` table rather than from an item
   * subtype: one ego pool serves several subtypes (`charms` covers torque,
   * totem and wand), so picking the first applicable subtype labelled the pool
   * 项圈 and made it look like a duplicate of the torque entry.
   */
  slots: { id: string; label: string; count: number; pools: string[] }[];
  /** Ego id -> community recommendation (1–5), for sorting and display. */
  recommendations: Map<string, number>;
}

/**
 * Equipment categories offered as slot filters.
 *
 * The list mirrors the columns of the community spreadsheet's 20 worksheets,
 * because that is the classification a reader already knows. Pools the
 * spreadsheet does not cover are deliberately absent:
 *
 *  - `charged-attack` / `charged-defensive` / `charged-utility` are NPC-only
 *    ego files (`is_greater` attack types), not player equipment;
 *  - `potions`, `scrolls` and `infusions` are consumables and inscriptions,
 *    not equipment affixes;
 *  - `*-powers` files are loaded by the corresponding base pool, so their
 *    affixes already appear under 项圈 / 图腾 / 魔杖;
 *  - `armor` is the shared pool loaded by all three armour types, so its
 *    affixes are reachable from 重甲 / 板甲 / 轻甲.
 *
 * `steamgun` / `steamsaw` are not separate rows either: the spreadsheet has no
 * steam column, and the DLC gear draws on the same ranged and weapon pools.
 * They stay reachable through the 远程武器 / 近战武器 tags, whose label lists
 * them explicitly.
 */
export const EGO_SLOT_GROUPS: { id: string; label: string; pools: string[] }[] = [
  { id: 'weapon', label: '近战武器', pools: ['weapon'] },
  { id: 'ranged', label: '远程武器', pools: ['ranged', 'bow', 'sling', 'steamgun'] },
  { id: 'ammo', label: '弹药', pools: ['ammo'] },
  { id: 'staves', label: '法杖', pools: ['staves'] },
  { id: 'mindstars', label: '灵晶', pools: ['mindstars'] },
  { id: 'shield', label: '盾牌', pools: ['shield'] },
  { id: 'charm', label: '护符（项圈 / 图腾 / 魔杖）', pools: ['charms', 'wands'] },
  { id: 'amulets', label: '项链', pools: ['amulets'] },
  { id: 'cloak', label: '披风', pools: ['cloak'] },
  { id: 'belt', label: '腰带', pools: ['belt'] },
  { id: 'boots', label: '鞋子', pools: ['boots'] },
  { id: 'gloves', label: '手套', pools: ['gloves'] },
  { id: 'robe', label: '法袍', pools: ['robe'] },
  { id: 'armor-heavy', label: '重甲', pools: ['heavy-armor'] },
  { id: 'armor-massive', label: '板甲', pools: ['massive-armor'] },
  { id: 'armor-light', label: '轻甲', pools: ['light-armor'] },
  { id: 'helm', label: '头盔', pools: ['helm'] },
  { id: 'wizard-hat', label: '法师帽', pools: ['wizard-hat'] },
  { id: 'lite', label: '灯具', pools: ['lite'] },
  { id: 'rings', label: '戒指', pools: ['rings'] },
  { id: 'digger', label: '锄头', pools: ['digger'] },
];

export interface LoadedArtifacts {
  dataset: ArtifactDataset;
  report: ItemsReport;
  byId: Map<string, Artifact>;
  haystack: Map<string, string>;
  types: string[];
  sources: string[];
}

async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url, { cache: 'no-cache' });
  if (!response.ok) throw new Error(`加载失败（HTTP ${response.status}）：${url}`);
  return (await response.json()) as T;
}

export function loadEgoData(): Promise<LoadedEgos> {
  egoCache ??= (async () => {
    const [dataset, report] = await Promise.all([
      fetchJson<EgoDataset>(assetUrl('data/egos.json')),
      fetchJson<ItemsReport>(assetUrl('data/items-report.json')),
    ]);
    // The community supplement is optional: a checkout without the spreadsheet
    // still builds and the page simply omits the community block.
    const community = await fetchJson<CommunityDataset>(assetUrl('data/ego-community.json'))
      .catch(() => null);
    return buildEgoData(dataset, report, community);
  })();
  return egoCache;
}

export function loadArtifactData(): Promise<LoadedArtifacts> {
  artifactCache ??= (async () => {
    const [dataset, report] = await Promise.all([
      fetchJson<ArtifactDataset>(assetUrl('data/artifacts.json')),
      fetchJson<ItemsReport>(assetUrl('data/items-report.json')),
    ]);
    return buildArtifactData(dataset, report);
  })();
  return artifactCache;
}

export function resetItemCaches() {
  egoCache = null;
  artifactCache = null;
}

/**
 * Searchable text for an ego.
 *
 * English names are indexed alongside Chinese so a reader who knows the game's
 * English terminology can still find an affix, and the stable id is included so
 * `tome:weapon:acidic` resolves.
 */
function egoHaystack(
  ego: Ego,
  labels: ItemLabels,
  fieldMeta: Record<string, ItemFieldMeta>,
  community: CommunityRow | null,
): string {
  const parts = [
    ego.name.clean, ego.name.zh, ego.name.raw, ego.id, ego.keyword,
    ego.keywords.join(' '), ego.pool, ego.desc,
    ego.position === 'prefix' ? '前缀' : ego.position === 'suffix' ? '后缀' : '',
    ego.greater ? '高级词缀 greater' : '',
    ego.powerSources.join(' '),
    ...ego.applicable.flatMap((a) => [a.subtype, a.subtypeZh, a.typeZh, a.slotZh, a.example]),
    // Property labels and damage-type names make "which ego grants stun immunity"
    // answerable from the search box.
    ...ego.areas.flatMap((group) => group.props.flatMap((prop) => [
      prop.key,
      // The Chinese label is what a reader actually types ("震慑免疫"), so it
      // must be indexed; the raw field key alone would only match
      // `stun_immune`.
      fieldMeta[prop.key]?.labelZh,
      fieldMeta[prop.key]?.label,
      labels.areas[group.area] ?? group.area,
      GROUP_SEARCH_ALIASES[prop.key],
      ...(prop.items ?? []).map((item) => item.code ?? item.key ?? ''),
    ])),
    // Community wording and nicknames are indexed so a player's own term finds
    // the affix, but they never outrank the game data in the interface.
    community?.effect,
    community?.note,
    community?.rawName,
  ];
  return normalizeSearchText(parts.filter(Boolean).join(' '));
}

function artifactHaystack(artifact: Artifact, labels: ItemLabels, fieldMeta: Record<string, ItemFieldMeta>): string {
  const parts = [
    artifact.name, artifact.nameZh, artifact.defineAs, artifact.id,
    artifact.type, artifact.typeZh, artifact.subtype, artifact.subtypeZh, artifact.slotZh,
    artifact.desc, artifact.descZh, artifact.unidedName,
    artifact.specialDesc?.en, artifact.specialDesc?.zh,
    artifact.usePower?.name, artifact.usePower?.nameZh,
    artifact.useTalent?.talentId,
    ...artifact.chain,
    ...artifact.powerSources,
    ...artifact.properties.flatMap((group) => group.props.flatMap((prop) => [
      prop.key,
      fieldMeta[prop.key]?.labelZh,
      fieldMeta[prop.key]?.label,
      labels.areas[group.area] ?? group.area,
      GROUP_SEARCH_ALIASES[prop.key],
      ...(prop.items ?? []).map((item) => item.code ?? item.key ?? ''),
    ])),
  ];
  return normalizeSearchText(parts.filter(Boolean).join(' '));
}

export function buildEgoData(dataset: EgoDataset, report: ItemsReport, community: CommunityDataset | null = null): LoadedEgos {
  const recommendations = new Map<string, number>();
  for (const [id, row] of Object.entries(community?.byEgoId ?? {})) {
    const value = Number(row.recommend);
    if (Number.isFinite(value)) recommendations.set(id, value);
  }
  const byId = new Map<string, Ego>();
  const byPool = new Map<string, Ego[]>();
  const haystack = new Map<string, string>();
  for (const ego of dataset.egos) {
    byId.set(ego.id, ego);
    for (const pool of ego.pools) {
      const list = byPool.get(pool);
      if (list) list.push(ego);
      else byPool.set(pool, [ego]);
    }
    haystack.set(ego.id, egoHaystack(ego, dataset.labels, dataset.fieldMeta, community?.byEgoId[ego.id] ?? null));
  }
  // Only the curated equipment categories are offered, in spreadsheet order.
  // A category is dropped when nothing in the data matches it, so an empty tag
  // is never rendered.
  const slots = EGO_SLOT_GROUPS
    .map((group) => {
      const present = group.pools.filter((pool) => byPool.has(pool));
      const count = new Set(present.flatMap((pool) => byPool.get(pool)?.map((ego) => ego.id) ?? [])).size;
      return { id: group.id, label: group.label, count, pools: present };
    })
    .filter((slot) => slot.count > 0);
  const pools = slots.flatMap((slot) => slot.pools);
  return { dataset, report, community, byId, byPool, haystack, pools, slots, recommendations };
}

export function buildArtifactData(dataset: ArtifactDataset, report: ItemsReport): LoadedArtifacts {
  const byId = new Map<string, Artifact>();
  const haystack = new Map<string, string>();
  const types = new Set<string>();
  const sources = new Set<string>();
  for (const artifact of dataset.artifacts) {
    byId.set(artifact.id, artifact);
    haystack.set(artifact.id, artifactHaystack(artifact, dataset.labels, dataset.fieldMeta));
    if (artifact.type) types.add(artifact.type);
    sources.add(artifact.source);
  }
  return {
    dataset,
    report,
    byId,
    haystack,
    types: [...types].sort(),
    sources: [...sources].sort(),
  };
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/** Resolve a `file` id back to its source path for the "source" disclosure. */
export function sourcePath(report: ItemsReport, id: number | null | undefined): string | null {
  if (id === null || id === undefined) return null;
  return report.files?.[id] ?? null;
}

/**
 * Normalise text for searching.
 *
 * Property labels contain separators the reader does not type: the stun
 * immunity property is 震慑/冰冻免疫, so a search for 震慑免疫 found nothing.
 * Separators are dropped on both sides of the comparison, and the composition
 * marks are stripped so an accented English name (`Dúathedlen`) matches its
 * plain spelling.
 */
export function normalizeSearchText(text: string): string {
  return text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[\/\\|·・、,，;；:：()（）\[\]【】"'"'']/g, '')
    .replace(/\s+/g, ' ');
}

/** Split a user query into normalised terms; quoted phrases stay together. */
export function searchTerms(query: string): string[] {
  const parts = query.match(/"([^"]+)"|(\S+)/g) ?? [];
  return parts
    .map((part) => normalizeSearchText(part.replace(/^"|"$/g, '').trim()))
    .filter(Boolean);
}

export function sourceLabel(dataset: { sources: ItemSourceMeta[] }, id: string): string {
  return dataset.sources.find((source) => source.id === id)?.label ?? id;
}

/**
 * Render one property value the way the field map says it should be shown.
 *
 * The important behaviour is the `resolver` branch: when a value varies with the
 * item's generation the page shows the range or the source expression, never a
 * single number, and when nothing is statically known it says so instead of
 * printing `0`.
 */
export function formatPropValue(
  meta: ItemFieldMeta | undefined,
  value: number | string | boolean | null | undefined,
): string {
  if (value === null || value === undefined) return '—';
  if (typeof value === 'boolean') return value ? '是' : '否';
  if (typeof value === 'string') return value;
  const format = meta?.format ?? null;
  const sign = format?.includes('+') ?? false;
  const decimals = /\.(\d+)f/.test(format ?? '') ? Number(/\.(\d+)f/.exec(format ?? '')?.[1] ?? 0) : null;
  const body = decimals === null ? String(value) : value.toFixed(decimals);
  const withUnit = meta?.unit === '%' ? `${body}%` : body;
  if (value > 0 && sign && !withUnit.startsWith('+')) return `+${withUnit}`;
  return withUnit;
}
