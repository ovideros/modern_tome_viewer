/**
 * Data loading and normalization.
 *
 * The JSON written by scripts/build-data.mjs is intentionally compact; this
 * module expands it back into the rich shapes the UI works with, and builds the
 * lookup maps (by id, by tree, flat list) that search and filtering need.
 */

import type { Acronym, ScalingParam } from './scaling';
import { axisSiblings } from './scaling';
import type {
  BuildManifest,
  ClassMeta,
  Cooldown,
  CostKind,
  DatasetMeta,
  RangeKind,
  Talent,
  TalentCost,
  TalentEntry,
  TalentRange,
  TalentRequirement,
  TalentTree,
} from './types';

export interface LoadedData {
  meta: DatasetMeta;
  manifest: BuildManifest;
  trees: TalentTree[];
  /** Flat list of every talent, annotated with its tree/category names. */
  talents: TalentEntry[];
  byId: Map<string, TalentEntry>;
  byTree: Map<string, TalentTree>;
  categoryName: Map<string, string>;
  className: Map<string, string>;
}

/** Wire shapes emitted by the build script. */
interface WireTalent {
  id: string;
  name: string;
  shortName?: string;
  image?: string | null;
  tree: string;
  index: number;
  mode?: string;
  points?: number;
  cd?: number | string | null;
  /** `fixed_cooldown = true`: no effect may change this cooldown. */
  fixedCd?: boolean;
  range?: string | null;
  rangeKind?: RangeKind;
  cost?: string | null;
  costResource?: string | null;
  costAmount?: number | null;
  costKind?: CostKind | null;
  useSpeed?: string;
  require?: string[];
  text?: string;
  plain?: string;
  flags?: Record<string, true>;
  source?: string | null;
  /** Compact acronym objects written by the build (see expandAcronym). */
  acronyms?: WireAcronym[];
}

interface WireAcronym {
  c: string;
  d: number[];
  s: string;
  /** Text the export wraps around the numbers: a leading sign, a trailing unit. */
  pre?: string;
  tail?: string;
  f: Acronym['family'];
  b: number | null;
  m: number | null;
  t: number;
  p: unknown[];
  l?: Acronym['lua'];
}

/** Expand one compact acronym object into the shape the UI works with. */
function expandAcronym(raw: unknown): Acronym | null {
  if (!raw || typeof raw !== 'object') return null;
  const wire = raw as WireAcronym;
  if (!wire.f) return null;
  const { c: className, d: displayed, s: suffix, pre: prefix, tail, f: family, b: base, m: max, t: mastery, p: params } = wire;
  const expanded: ScalingParam[] = Array.isArray(params)
    ? params.map((entry) => {
        const [label, kind, value, ladder] = entry as [string, ScalingParam['kind'], number | null, number[]];
        return {
          label,
          kind,
          value: value ?? null,
          ladder: Array.isArray(ladder) ? ladder : [],
          editable: kind === 'coefficient' || kind === 'power' || kind === 'stat',
          ...(kind === 'coefficient'
            ? { min: 0.1, max: 5, step: 0.1 }
            : kind === 'power'
              ? { min: 0, max: 500, step: 1 }
              : kind === 'stat'
                ? { min: 0, max: 1000, step: 1 }
                : {}),
        };
      })
    : [];
  // The wire format drops `axisLabel` and lets the reader re-derive it. A title
  // can carry several identical parameter ladders (the export writes a whole
  // tooltip's parameter union into each acronym), and those ride the axis
  // together, so record the whole group rather than just the first.
  const riders = axisSiblings({ params: expanded });
  return {
    className,
    displayed: Array.isArray(displayed) ? displayed : [],
    suffix: suffix ?? '',
    prefix: prefix ?? '',
    tail: tail ?? '',
    family,
    base: base ?? null,
    max: max ?? null,
    mastery: typeof mastery === 'number' ? mastery : 1,
    ...(wire.l ? { lua: wire.l } : {}),
    ...(riders.length ? { axisLabel: riders[0].label, axisLabels: riders.map((p) => p.label) } : {}),
    params: expanded,
  };
}

interface WireTree {
  id: string;
  category: string;
  name: string;
  description: string;
  classes: string[];
  talentCount: number;
  talents: WireTalent[];
}

interface WireDataset {
  trees: WireTree[];
}

// ---------------------------------------------------------------------------
// Display helpers shared across the UI
// ---------------------------------------------------------------------------

/** Strip HTML tags and decode the few entities that appear in game text. */
export function stripMarkup(html: string): string {
  if (!html) return '';
  return html
    .replace(/<br\s*\/?>/gi, ' ')
    .replace(/<\/?[^>]+>/g, '')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/#[A-Z_]{2,}#/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function numbersFrom(value: number | string | null | undefined): number[] {
  if (value === null || value === undefined) return [];
  if (typeof value === 'number') return [value];
  const text = value.replace(/<[^>]*>/g, ' ').replace(/#[A-Z_]{2,}#/g, ' ');
  const found = text.match(/-?\d+(?:\.\d+)?/g);
  return found ? found.map(Number) : [];
}

export function expandCooldown(value: number | string | null | undefined, fixed = false): Cooldown {
  const values = numbersFrom(value);
  if (!values.length) {
    return { display: value === null || value === undefined ? null : String(value), min: null, max: null, values: [], fixed };
  }
  return {
    display: typeof value === 'number' ? String(value) : stripMarkup(String(value)),
    min: Math.min(...values),
    max: Math.max(...values),
    values,
    fixed,
  };
}

export function expandRange(display: string | null | undefined, kind?: RangeKind): TalentRange {
  const values = numbersFrom(display);
  return {
    display: display ?? null,
    kind: kind ?? (values.length ? 'distance' : 'other'),
    min: values.length ? Math.min(...values) : null,
    max: values.length ? Math.max(...values) : null,
  };
}

export function expandCost(wire: WireTalent): TalentCost {
  return {
    display: wire.cost ?? null,
    resource: wire.costResource ?? null,
    resourceLabel: RESOURCE_LABELS[wire.costResource ?? ''] ?? null,
    amount: wire.costAmount ?? null,
    kind: wire.costKind ?? null,
  };
}

export const RESOURCE_LABELS: Record<string, string> = {
  stamina: '体力',
  mana: '法力',
  equilibrium: '失衡',
  steam: '蒸汽',
  psi: '灵能',
  vim: '活力',
  paradox: '紊乱',
  positive: '正能量',
  negative: '负能量',
  insanity: '疯狂',
  hate: '仇恨',
  soul: '灵魂',
};

export const RANGE_KIND_LABELS: Record<RangeKind, string> = {
  melee: '近战',
  bow: '弓箭',
  distance: '远程',
  other: '其他',
};

export const COST_KIND_LABELS: Record<CostKind, string> = {
  cost: '消耗',
  sustain: '持续消耗',
  gain: '获得',
  drain: '吸收',
};

export const FLAG_LABELS: Record<string, string> = {
  is_spell: '法术',
  is_mind: '精神',
  is_nature: '自然',
  is_steam: '蒸汽',
  is_melee: '近战',
  is_necromancy: '亡灵法术',
  is_teleport: '传送',
  is_heal: '治疗',
  is_summon: '召唤',
  is_inscription: '纹身/符文',
  is_antimagic: '反魔',
  requires_target: '需要目标',
  direct_hit: '直接命中',
  no_energy: '不消耗回合',
  no_silence: '无法沉默',
  generic: '通用技能',
  uber: '觉醒技',
  innate: '天生',
  is_unarmed: '徒手',
  is_curse: '诅咒',
  is_hex: '咒术',
  is_psyshot: '灵能射击',
  is_technomancy: '科技魔法',
  hide: '隐藏',
  not_listed: '未列出',
  multi_require: '多级需求',
};

export function flagLabel(flag: string): string {
  return FLAG_LABELS[flag] ?? flag;
}

export function parseRequire(display: string): TalentRequirement {
  const level = display.match(/等级\s*([\d.]+)/);
  const stat = display.match(/,\s*([^,\d]+?)\s*([\d.]+)\s*$/);
  return {
    display,
    level: level ? Number(level[1]) : null,
    stat: stat ? stat[1].trim() : null,
    statValue: stat ? Number(stat[2]) : null,
  };
}

// ---------------------------------------------------------------------------
// Loading
// ---------------------------------------------------------------------------

function expandTalent(wire: WireTalent, tree: WireTree): Talent {
  return {
    id: wire.id,
    name: wire.name,
    plainName: stripMarkup(wire.name),
    shortName: wire.shortName ?? '',
    image: wire.image ?? null,
    tree: wire.tree ?? tree.id,
    index: wire.index ?? 0,
    mode: wire.mode ?? '',
    points: wire.points ?? 0,
    cooldown: expandCooldown(wire.cd, wire.fixedCd === true),
    range: expandRange(wire.range, wire.rangeKind),
    cost: expandCost(wire),
    useSpeed: wire.useSpeed ?? '',
    require: (wire.require ?? []).map(parseRequire),
    text: wire.text ?? '',
    acronyms: (wire.acronyms ?? []).map(expandAcronym).filter((a): a is Acronym => a !== null),
    plain: wire.plain ?? stripMarkup(wire.text ?? ''),
    flags: wire.flags ?? {},
    source: wire.source ?? null,
  };
}

export function normalizeDataset(wire: WireDataset, meta: DatasetMeta): {
  trees: TalentTree[];
  talents: TalentEntry[];
} {
  const categoryName = new Map(meta.categories.map((c) => [c.id, c.name]));
  const trees: TalentTree[] = [];
  const talents: TalentEntry[] = [];

  for (const wireTree of wire.trees) {
    const category = wireTree.category;
    const categoryLabel = categoryName.get(category) ?? category;
    const tree: TalentTree = {
      id: wireTree.id,
      category,
      name: wireTree.name,
      plainName: stripMarkup(wireTree.name),
      description: wireTree.description,
      plainDescription: stripMarkup(wireTree.description),
      classes: wireTree.classes ?? [],
      talentCount: wireTree.talents?.length ?? 0,
      talents: [],
    };

    for (const wireTalent of wireTree.talents ?? []) {
      const talent = expandTalent(wireTalent, wireTree);
      tree.talents.push(talent);
      talents.push({
        ...talent,
        treeName: tree.name,
        treePlainName: tree.plainName,
        category,
        categoryName: categoryLabel,
      });
    }
    trees.push(tree);
  }

  return { trees, talents };
}

async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url, { cache: 'no-cache' });
  if (!response.ok) throw new Error(`加载 ${url} 失败（HTTP ${response.status}）`);
  return (await response.json()) as T;
}

/** Resolve a public asset path that respects Vite's configured base. */
export function assetUrl(relative: string): string {
  const base = import.meta.env.BASE_URL || './';
  return `${base.replace(/\/$/, '')}/${relative.replace(/^\//, '')}`;
}

export async function loadDataset(): Promise<LoadedData> {
  const [wire, meta, manifest] = await Promise.all([
    fetchJson<WireDataset>(assetUrl('data/talents.json')),
    fetchJson<DatasetMeta>(assetUrl('data/meta.json')),
    fetchJson<BuildManifest>(assetUrl('data/manifest.json')),
  ]);

  const { trees, talents } = normalizeDataset(wire, meta);

  return {
    meta,
    manifest,
    trees,
    talents,
    byId: new Map(talents.map((t) => [t.id, t])),
    byTree: new Map(trees.map((t) => [t.id, t])),
    categoryName: new Map(meta.categories.map((c) => [c.id, c.name])),
    className: new Map(meta.classes.map((c: ClassMeta) => [c.id, c.name])),
  };
}
