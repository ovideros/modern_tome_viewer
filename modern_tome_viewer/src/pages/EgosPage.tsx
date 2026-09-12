/**
 * Equipment ego affix encyclopedia (`#/egos`).
 *
 * Layout mirrors the monster page — filter rail, compact list, detail panel —
 * because ego affixes are read comparatively: the reader is asking "which of
 * these can roll on a shield", not admiring one entry. Egos get no artwork;
 * the game has none for them, and inventing icons would misrepresent the data.
 *
 * Filters and the selection live in the hash query so a view is shareable and
 * survives Back/Forward; the sync pattern (publish + adopt with remembered
 * hashes) is the same one the monster page uses and for the same reason.
 */

import { useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { Highlight } from '../components/Highlight';
import { EgoDetail } from '../components/EgoDetail';
import { TalentDetail } from '../components/TalentDetail';
import { writeHash } from '../lib/filters';
import {
  loadEgoData,
  normalizeSearchText,
  searchTerms,
  type Ego,
  type LoadedEgos,
} from '../lib/items';
import { egoSummaryLines } from '../lib/ego-facts';
import { makeCodeLabeler } from '../lib/item-labels';
import type { LoadedData } from '../lib/data';
import type { TalentEntry } from '../lib/types';

interface EgosPageProps {
  data: LoadedData;
  params: URLSearchParams;
  onParamsChange: (params: URLSearchParams) => void;
  favoriteHas: (id: string) => boolean;
  onToggleFavorite: (id: string) => void;
  compareHas: (id: string) => boolean;
  onToggleCompare: (id: string) => void;
  compareFull: boolean;
}

/**
 * Every facet is a list of toggles rather than a single-choice dropdown.
 *
 * The advanced-search panel already works this way and for the same reason: a
 * reader usually wants "shields or off-hand, prefix only" and should not have to
 * re-open a select for each axis. An empty list means "no restriction", so the
 * default state and the cleared state are the same thing.
 */
interface EgoFilters {
  query: string;
  /** Column-specific text filters; the general query remains an all-fields search. */
  nameQuery: string;
  effectQuery: string;
  noteQuery: string;
  /** Slot group ids from `EGO_SLOT_GROUPS`. */
  slots: string[];
  positions: ('prefix' | 'suffix')[];
  /** `normal` / `greater`; empty means both tiers. */
  tiers: ('normal' | 'greater')[];
  sources: string[];
  /** Effect tags derived from the structured properties, not from prose. */
  tags: string[];
  rarityMin: number | null;
  rarityMax: number | null;
  recommendations: number[];
  /**
   * Item material level (1–5), or null for "every level".
   *
   * This is **not** a filter: it does not change which affixes match. It changes
   * what number is printed, because `resolvers.mbonus_material(max, add)` scales
   * with the item's tier — an affix that reads `5~15` across all tiers reads
   * `5~15` on a voratun item but `5~7` on an iron one. Single choice by design:
   * "the range on two tiers at once" is not a thing a player can hold.
   */
  materialLevel: number | null;
}

const EMPTY_FILTERS: EgoFilters = {
  query: '',
  nameQuery: '',
  effectQuery: '',
  noteQuery: '',
  slots: [],
  positions: [],
  tiers: [],
  sources: [],
  tags: [],
  rarityMin: null,
  rarityMax: null,
  recommendations: [],
  materialLevel: null,
};

/** Material-level choices, offered as single-choice tags. */
export const MATERIAL_LEVELS = [1, 2, 3, 4, 5] as const;

/** Read a comma-separated multi-value facet, tolerating the old single value. */
function readList(params: URLSearchParams, key: string): string[] {
  const raw = params.get(key);
  if (!raw) return [];
  return raw.split(',').map((part) => part.trim()).filter(Boolean);
}

/**
 * Effect tags, expressed as predicates over the structured properties.
 *
 * Tags come from the parsed property keys rather than from searching the
 * description text, which is what keeps "gives stun immunity" and "its trigger
 * has to beat stun immunity" from being filed together: only the `*_immune`
 * fields — the ones the game actually grants — produce the immunity tags.
 */
const EFFECT_TAGS: { id: string; label: string; test: (ego: Ego) => boolean }[] = [
  {
    id: 'stun-immune',
    label: '震慑免疫',
    test: (ego) => hasKey(ego, 'stun_immune'),
  },
  {
    id: 'confusion-immune',
    label: '混乱免疫',
    test: (ego) => hasKey(ego, 'confusion_immune'),
  },
  {
    id: 'any-immune',
    label: '任意状态免疫',
    test: (ego) => ego.areas.some((area) => area.props.some((prop) => prop.key.endsWith('_immune'))),
  },
  {
    id: 'crit-power',
    label: '暴击伤害',
    test: (ego) => hasKey(ego, 'combat_critical_power'),
  },
  {
    id: 'damage',
    label: '伤害加成',
    test: (ego) => hasKey(ego, 'inc_damage'),
  },
  {
    id: 'resist-pen',
    label: '抗性穿透',
    test: (ego) => hasKey(ego, 'resists_pen'),
  },
  {
    id: 'life',
    label: '生命',
    test: (ego) => hasKey(ego, 'max_life'),
  },
  {
    id: 'healing',
    label: '治疗系数',
    test: (ego) => hasKey(ego, 'healing_factor'),
  },
  {
    id: 'resist',
    label: '抗性',
    test: (ego) => hasKey(ego, 'resists'),
  },
  {
    id: 'on-hit',
    label: '命中触发',
    test: (ego) => hasKey(ego, 'talent_on_hit') || hasKey(ego, 'special_on_hit'),
  },
  {
    id: 'on-crit',
    label: '暴击触发',
    test: (ego) => hasKey(ego, 'special_on_crit') || hasKey(ego, 'talent_on_crit'),
  },
  {
    id: 'stats',
    label: '属性加值',
    test: (ego) => hasKey(ego, 'inc_stats'),
  },
  {
    id: 'speed',
    label: '速度',
    test: (ego) => hasKey(ego, 'movement_speed') || hasKey(ego, 'global_speed_add') || hasKey(ego, 'combat_physspeed'),
  },
  {
    id: 'lite',
    label: '光照',
    test: (ego) => hasKey(ego, 'lite'),
  },
  {
    id: 'save',
    label: '豁免',
    test: (ego) => hasKey(ego, 'combat_physresist') || hasKey(ego, 'combat_spellresist') || hasKey(ego, 'combat_mentalresist'),
  },
  {
    id: 'armor',
    label: '护甲与闪避',
    test: (ego) => hasKey(ego, 'combat_armor') || hasKey(ego, 'combat_def'),
  },
];

function hasKey(ego: Ego, key: string): boolean {
  return ego.areas.some((area) => area.props.some((prop) => prop.key === key));
}

function paramsToFilters(params: URLSearchParams): EgoFilters {
  const rawLevel = Number(params.get('ml'));
  const readNumber = (key: string): number | null => {
    const raw = params.get(key);
    if (raw === null || raw.trim() === '') return null;
    const value = Number(raw);
    return Number.isFinite(value) ? value : null;
  };
  return {
    query: params.get('q') ?? '',
    nameQuery: params.get('nq') ?? '',
    effectQuery: params.get('eq') ?? '',
    noteQuery: params.get('noteq') ?? '',
    slots: readList(params, 'slot'),
    positions: readList(params, 'pos').filter((value): value is 'prefix' | 'suffix' => value === 'prefix' || value === 'suffix'),
    tiers: readList(params, 'tier').filter((value): value is 'normal' | 'greater' => value === 'normal' || value === 'greater'),
    sources: readList(params, 'src'),
    tags: readList(params, 'tags').filter((tag) => EFFECT_TAGS.some((spec) => spec.id === tag)),
    rarityMin: readNumber('rmin'),
    rarityMax: readNumber('rmax'),
    recommendations: readList(params, 'rec')
      .map((value) => Number(value))
      .filter((value) => Number.isInteger(value) && value >= 1 && value <= 5),
    // A level outside 1–5 (a stale link) is treated as "not chosen" rather than
    // as an error, which keeps the page usable.
    materialLevel: (MATERIAL_LEVELS as readonly number[]).includes(rawLevel) ? rawLevel : null,
  };
}

function filtersToParams(filters: EgoFilters, egoId: string | null): URLSearchParams {
  const next = new URLSearchParams();
  if (filters.query.trim()) next.set('q', filters.query.trim());
  if (filters.nameQuery.trim()) next.set('nq', filters.nameQuery.trim());
  if (filters.effectQuery.trim()) next.set('eq', filters.effectQuery.trim());
  if (filters.noteQuery.trim()) next.set('noteq', filters.noteQuery.trim());
  if (filters.slots.length) next.set('slot', filters.slots.join(','));
  if (filters.positions.length) next.set('pos', filters.positions.join(','));
  if (filters.tiers.length) next.set('tier', filters.tiers.join(','));
  if (filters.sources.length) next.set('src', filters.sources.join(','));
  if (filters.tags.length) next.set('tags', filters.tags.join(','));
  if (filters.rarityMin !== null) next.set('rmin', String(filters.rarityMin));
  if (filters.rarityMax !== null) next.set('rmax', String(filters.rarityMax));
  if (filters.recommendations.length) next.set('rec', filters.recommendations.join(','));
  if (filters.materialLevel !== null) next.set('ml', String(filters.materialLevel));
  if (egoId) next.set('e', egoId);
  return next;
}

/** Toggle one value inside a facet list; an empty list means "no restriction". */
function toggleIn<T extends string>(list: T[], value: T): T[] {
  return list.includes(value) ? list.filter((item) => item !== value) : [...list, value];
}

function queryMatches(text: string, query: string): boolean {
  const terms = searchTerms(query);
  if (!terms.length) return true;
  const haystack = normalizeSearchText(text);
  return terms.every((term) => haystack.includes(term));
}

function parseOptionalNumber(value: string): number | null {
  if (value.trim() === '') return null;
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

/**
 * Filter and order the affix list.
 *
 * Ordering is two-level and deliberate:
 *   1. the normal tier before the greater tier, so the reader meets the
 *      common affix first and the advanced variant right after it;
 *   2. inside each tier, the community recommendation descending, which is the
 *      only quality signal a reader has without opening each entry.
 *
 * Community data decides ordering but never inclusion: an affix the spreadsheet
 * never covered sorts to the end of its tier instead of disappearing.
 */
function filterEgos(loaded: LoadedEgos, filters: EgoFilters): Ego[] {
  const terms = searchTerms(filters.query);
  const selectedSlotPools = new Set(
    filters.slots.flatMap((id) => loaded.slots.find((slot) => slot.id === id)?.pools ?? []),
  );
  const tagTests = EFFECT_TAGS.filter((spec) => filters.tags.includes(spec.id)).map((spec) => spec.test);

  const out: Ego[] = [];
  for (const ego of loaded.dataset.egos) {
    // Within a facet the values are alternatives (OR); between facets they
    // narrow (AND).
    if (selectedSlotPools.size && !ego.pools.some((pool) => selectedSlotPools.has(pool))) continue;
    if (filters.positions.length && !filters.positions.includes(ego.position as 'prefix' | 'suffix')) continue;
    if (filters.tiers.length) {
      const tier = ego.greater ? 'greater' : 'normal';
      if (!filters.tiers.includes(tier)) continue;
    }
    if (filters.sources.length && !filters.sources.includes(ego.source)) continue;
    if (tagTests.length && !tagTests.every((test) => test(ego))) continue;
    if (terms.length) {
      const text = loaded.haystack.get(ego.id) ?? '';
      if (!terms.every((term) => text.includes(term))) continue;
    }
    out.push(ego);
  }

  const rank = (ego: Ego) => loaded.recommendations.get(ego.id) ?? -1;
  return out.sort((a, b) => {
    if (a.greater !== b.greater) return a.greater ? 1 : -1;
    const byRecommend = rank(b) - rank(a);
    if (byRecommend !== 0) return byRecommend;
    return (a.name.clean || '').localeCompare(b.name.clean || '') || a.id.localeCompare(b.id);
  });
}

/**
 * Collapsible filter section.
 *
 * `defaultOpen` is set on the facets a reader reaches for first (适用部位,
 * 效果标签) so the common path is one click, not two.
 */
function Section({
  title,
  hint,
  activeCount = 0,
  defaultOpen = false,
  children,
}: {
  title: string;
  hint?: string;
  activeCount?: number;
  defaultOpen?: boolean;
  children: ReactNode;
}) {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <div className="border-b border-line last:border-b-0">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="flex w-full items-center justify-between gap-2 py-2 text-left hover:opacity-80"
      >
        <span className="flex items-center gap-2">
          <span className="text-[12.5px] font-semibold">{title}</span>
          {activeCount > 0 && (
            <span className="rounded-full bg-accent-soft px-1.5 text-[10.5px] font-semibold text-accent-strong">
              {activeCount}
            </span>
          )}
        </span>
        <span className="flex items-center gap-2">
          {hint && <span className="text-[10.5px] text-subtle">{hint}</span>}
          <svg viewBox="0 0 20 20" className={`h-3 w-3 text-subtle transition-transform ${open ? 'rotate-90' : ''}`} fill="currentColor">
            <path d="M7 4l6 6-6 6V4z" />
          </svg>
        </span>
      </button>
      {open && <div className="pb-3">{children}</div>}
    </div>
  );
}

/** One toggleable tag; `aria-pressed` is what `styles.css` styles as active. */
function TagButton({
  label,
  count,
  pressed,
  onClick,
  title,
  tone,
}: {
  label: string;
  count?: number;
  pressed: boolean;
  onClick: () => void;
  title?: string;
  tone?: 'greater';
}) {
  return (
    <button
      type="button"
      className={`btn px-1.5 py-0.5 text-[11px] ${tone === 'greater' ? 'text-amber-800 dark:text-amber-300' : ''}`}
      aria-pressed={pressed}
      onClick={onClick}
      title={title}
    >
      {label}
      {count !== undefined && <span className="text-[10px] opacity-60">{count}</span>}
    </button>
  );
}

/** Shared style for the 高级词缀 marker wherever it appears. */
export const GREATER_TAG_CLASS =
  'inline-flex items-center rounded-full border border-amber-500/50 bg-amber-500/15 px-1.5 text-[10.5px] font-semibold text-amber-800 dark:text-amber-300';

type EgoColumn = 'name' | 'slot' | 'position' | 'tier' | 'effect' | 'rarity' | 'recommendation' | 'note';

const EGO_COLUMN_LABELS: Record<EgoColumn, string> = {
  name: '词缀名',
  slot: '适用部位',
  position: '前 / 后缀',
  tier: '普通 / 高级',
  effect: '效果',
  rarity: '稀有度',
  recommendation: '推荐度',
  note: '备注',
};

const EGO_COLUMNS: EgoColumn[] = ['name', 'slot', 'position', 'tier', 'effect', 'rarity', 'recommendation', 'note'];

function ColumnHeader({
  column,
  active,
  open,
  onClick,
}: {
  column: EgoColumn;
  active: boolean;
  open: boolean;
  onClick: () => void;
}) {
  return (
    <div className="flex items-center justify-between gap-2">
      <span>{EGO_COLUMN_LABELS[column]}</span>
      <button
        type="button"
        className={`rounded px-1.5 py-0.5 text-[11px] ${active ? 'bg-accent-soft text-accent-strong' : 'text-subtle hover:bg-hover'}`}
        aria-label={`筛选${EGO_COLUMN_LABELS[column]}`}
        aria-expanded={open}
        aria-pressed={active}
        data-testid={`ego-column-filter-${column}`}
        onClick={onClick}
        title={`筛选${EGO_COLUMN_LABELS[column]}`}
      >
        {active ? '●' : '▽'}
      </button>
    </div>
  );
}

function ColumnChoice({
  label,
  checked,
  onChange,
}: {
  label: string;
  checked: boolean;
  onChange: () => void;
}) {
  return (
    <label className="flex cursor-pointer items-center gap-2 rounded px-1.5 py-1 text-[12px] hover:bg-hover">
      <input type="checkbox" className="accent-[var(--accent)]" checked={checked} onChange={onChange} />
      <span className="truncate">{label}</span>
    </label>
  );
}

function columnFilterActive(column: EgoColumn, filters: EgoFilters): boolean {
  switch (column) {
    case 'name':
      return Boolean(filters.nameQuery.trim());
    case 'slot':
      return filters.slots.length > 0;
    case 'position':
      return filters.positions.length > 0;
    case 'tier':
      return filters.tiers.length > 0;
    case 'effect':
      return Boolean(filters.effectQuery.trim()) || filters.tags.length > 0;
    case 'rarity':
      return filters.rarityMin !== null || filters.rarityMax !== null;
    case 'recommendation':
      return filters.recommendations.length > 0;
    case 'note':
      return Boolean(filters.noteQuery.trim());
  }
}

interface EgoTableRow {
  ego: Ego;
  recommendation: number | undefined;
  community: import('../lib/items').CommunityRow | null;
  effect: string[];
  slots: string[];
  nameText: string;
  effectText: string;
  noteText: string;
}

interface EgoTableProps {
  loaded: LoadedEgos;
  rows: EgoTableRow[];
  filters: EgoFilters;
  openColumn: EgoColumn | null;
  onOpenColumn: (column: EgoColumn | null) => void;
  setFilters: (update: (current: EgoFilters) => EgoFilters) => void;
  clearColumnFilter: (column: EgoColumn) => void;
  toggleTag: (id: string) => void;
  toggleSlot: (id: string) => void;
  togglePosition: (value: 'prefix' | 'suffix') => void;
  toggleTier: (value: 'normal' | 'greater') => void;
  toggleRecommendation: (value: number) => void;
  selectedId: string | null;
  onSelect: (id: string) => void;
}

function EgoTable({
  loaded,
  rows,
  filters,
  openColumn,
  onOpenColumn,
  setFilters,
  clearColumnFilter,
  toggleTag,
  toggleSlot,
  togglePosition,
  toggleTier,
  toggleRecommendation,
  selectedId,
  onSelect,
}: EgoTableProps) {
  return (
    <>
      <div className="mb-2 flex flex-wrap items-center gap-1.5">
        <span className="mr-1 text-[11.5px] text-subtle">列筛选：</span>
        {EGO_COLUMNS.map((column) => (
          <button
            key={column}
            type="button"
            className={`btn px-2 py-0.5 text-[11px] ${columnFilterActive(column, filters) ? 'border-accent text-accent-strong' : ''}`}
            aria-pressed={openColumn === column}
            onClick={() => onOpenColumn(openColumn === column ? null : column)}
          >
            {EGO_COLUMN_LABELS[column]}
            {columnFilterActive(column, filters) && <span className="text-accent-strong">●</span>}
          </button>
        ))}
      </div>

      {openColumn && (
        <div className="panel mb-2 max-w-2xl p-2.5" data-testid="ego-column-filter-panel">
          <div className="mb-2 flex items-center justify-between gap-2">
            <h3 className="text-[12.5px] font-semibold">筛选{EGO_COLUMN_LABELS[openColumn]}</h3>
            <button type="button" className="btn px-2 py-0.5 text-[11px]" onClick={() => clearColumnFilter(openColumn)}>
              清除本列
            </button>
          </div>

          {openColumn === 'name' && (
            <input
              autoFocus
              className="input max-w-md"
              placeholder="中文名 / 英文名 / ID"
              value={filters.nameQuery}
              onChange={(event) => setFilters((current) => ({ ...current, nameQuery: event.target.value }))}
            />
          )}

          {openColumn === 'slot' && (
            <div className="grid max-h-52 grid-cols-2 gap-0.5 overflow-y-auto sm:grid-cols-3">
              {loaded.slots.map((slot) => (
                <ColumnChoice
                  key={slot.id}
                  label={`${slot.label} (${slot.count})`}
                  checked={filters.slots.includes(slot.id)}
                  onChange={() => toggleSlot(slot.id)}
                />
              ))}
            </div>
          )}

          {openColumn === 'position' && (
            <div className="flex flex-wrap gap-1">
              <ColumnChoice
                label="前缀"
                checked={filters.positions.includes('prefix')}
                onChange={() => togglePosition('prefix')}
              />
              <ColumnChoice
                label="后缀"
                checked={filters.positions.includes('suffix')}
                onChange={() => togglePosition('suffix')}
              />
            </div>
          )}

          {openColumn === 'tier' && (
            <div className="flex flex-wrap gap-1">
              <ColumnChoice
                label="普通"
                checked={filters.tiers.includes('normal')}
                onChange={() => toggleTier('normal')}
              />
              <ColumnChoice
                label="高级"
                checked={filters.tiers.includes('greater')}
                onChange={() => toggleTier('greater')}
              />
            </div>
          )}

          {openColumn === 'effect' && (
            <div className="space-y-2">
              <input
                autoFocus
                className="input max-w-md"
                placeholder="搜索效果文字，例如 震慑免疫"
                value={filters.effectQuery}
                onChange={(event) => setFilters((current) => ({ ...current, effectQuery: event.target.value }))}
              />
              <div className="flex flex-wrap gap-1">
                {EFFECT_TAGS.map((tag) => (
                  <TagButton
                    key={tag.id}
                    label={tag.label}
                    pressed={filters.tags.includes(tag.id)}
                    onClick={() => toggleTag(tag.id)}
                  />
                ))}
              </div>
            </div>
          )}

          {openColumn === 'rarity' && (
            <div className="flex max-w-md items-center gap-2">
              <input
                type="number"
                className="input"
                placeholder="最小"
                value={filters.rarityMin ?? ''}
                onChange={(event) => setFilters((current) => ({ ...current, rarityMin: parseOptionalNumber(event.target.value) }))}
                aria-label="稀有度下限"
              />
              <span className="text-subtle">–</span>
              <input
                type="number"
                className="input"
                placeholder="最大"
                value={filters.rarityMax ?? ''}
                onChange={(event) => setFilters((current) => ({ ...current, rarityMax: parseOptionalNumber(event.target.value) }))}
                aria-label="稀有度上限"
              />
            </div>
          )}

          {openColumn === 'recommendation' && (
            <div className="flex flex-wrap gap-1">
              {[1, 2, 3, 4, 5].map((value) => (
                <ColumnChoice
                  key={value}
                  label={`${value} 分`}
                  checked={filters.recommendations.includes(value)}
                  onChange={() => toggleRecommendation(value)}
                />
              ))}
            </div>
          )}

          {openColumn === 'note' && (
            <input
              autoFocus
              className="input max-w-md"
              placeholder="搜索社区备注"
              value={filters.noteQuery}
              onChange={(event) => setFilters((current) => ({ ...current, noteQuery: event.target.value }))}
            />
          )}
        </div>
      )}

      <div className="overflow-x-auto rounded-lg border border-line bg-surface" data-testid="ego-table">
        <table className="w-full min-w-[1080px] border-collapse text-left text-[12px]">
          <thead className="bg-surface-raised text-[11.5px] text-muted">
            <tr>
              {EGO_COLUMNS.map((column) => (
                <th
                  key={column}
                  className={`border-b border-line px-2.5 py-2 font-semibold ${
                    column === 'name' ? 'min-w-[160px]' : column === 'effect' ? 'min-w-[390px]' : 'min-w-[100px]'
                  }`}
                >
                  <ColumnHeader
                    column={column}
                    active={columnFilterActive(column, filters)}
                    open={openColumn === column}
                    onClick={() => onOpenColumn(openColumn === column ? null : column)}
                  />
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => {
              const { ego, recommendation, effect, slots, noteText } = row;
              const selectEgo = () => onSelect(ego.id);
              return (
                <tr
                  key={ego.id}
                  data-testid="ego-row"
                  aria-selected={selectedId === ego.id}
                  onClick={selectEgo}
                  className={`scroll-mt-[calc(var(--header-h)+12px)] border-b border-line/70 align-top last:border-b-0 ${
                    selectedId === ego.id ? 'bg-accent-soft' : 'hover:bg-hover/70'
                  }`}
                >
                  <td className="px-2.5 py-2">
                    <button
                      type="button"
                      data-testid="ego-card"
                      className="w-full text-left"
                      aria-pressed={selectedId === ego.id}
                      onClick={(event) => {
                        event.stopPropagation();
                        selectEgo();
                      }}
                    >
                      <span className="block font-medium">
                        <Highlight text={ego.name.zh ?? ego.name.clean} terms={searchTerms(filters.query)} />
                      </span>
                      <span className="mt-0.5 block text-[10.5px] text-subtle">{ego.name.clean}</span>
                    </button>
                  </td>
                  <td className="whitespace-nowrap px-2.5 py-2 text-muted">{slots.length ? slots.join('、') : '—'}</td>
                  <td className="whitespace-nowrap px-2.5 py-2">
                    {ego.position === 'prefix' ? '前缀' : ego.position === 'suffix' ? '后缀' : '—'}
                  </td>
                  <td className="whitespace-nowrap px-2.5 py-2">
                    {ego.greater ? <span className={GREATER_TAG_CLASS}>高级词缀</span> : '普通'}
                  </td>
                  <td className="px-2.5 py-2" data-testid="ego-effect">
                    <div className="max-w-[48rem] space-y-0.5">
                      {effect.length > 0 ? (
                        effect.map((line) => (
                          <p key={line} className="line-clamp-2 leading-snug text-muted">
                            {line}
                          </p>
                        ))
                      ) : (
                        <p className="leading-snug text-subtle">源码回调效果，暂无可静态读取的数值。</p>
                      )}
                      {filters.materialLevel !== null && (
                        <span className="chip" title="数值按该材料等级换算">材料 {filters.materialLevel} 级</span>
                      )}
                    </div>
                  </td>
                  <td className="whitespace-nowrap px-2.5 py-2 tabular-nums text-muted">{ego.rarity ?? '—'}</td>
                  <td className="whitespace-nowrap px-2.5 py-2 tabular-nums text-muted">{recommendation ?? '—'}</td>
                  <td className="min-w-[200px] px-2.5 py-2 leading-snug text-muted">{noteText || '—'}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </>
  );
}

export function EgosPage({
  data,
  params,
  onParamsChange,
  favoriteHas,
  onToggleFavorite,
  compareHas,
  onToggleCompare,
  compareFull,
}: EgosPageProps) {
  const [loaded, setLoaded] = useState<LoadedEgos | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState<EgoFilters>(() => paramsToFilters(params));
  const [selectedId, setSelectedId] = useState<string | null>(() => params.get('e'));
  const [selectedTalentId, setSelectedTalentId] = useState<string | null>(null);
  const [showFilters, setShowFilters] = useState(false);
  const [openColumn, setOpenColumn] = useState<EgoColumn | null>(null);

  useEffect(() => {
    let alive = true;
    loadEgoData()
      .then((next) => alive && setLoaded(next))
      .catch((err: unknown) => alive && setError(err instanceof Error ? err.message : String(err)));
    return () => {
      alive = false;
    };
  }, []);

  const publishedHash = useRef<string | undefined>(undefined);
  const adoptedHash = useRef<string | undefined>(undefined);

  useEffect(() => {
    const hash = params.toString();
    if (hash === publishedHash.current || hash === adoptedHash.current) return;
    adoptedHash.current = hash;
    setFilters(paramsToFilters(params));
    setSelectedId(params.get('e'));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [params.toString()]);

  useEffect(() => {
    const next = filtersToParams(filters, selectedId).toString();
    if (next === publishedHash.current) return;
    publishedHash.current = next;
    onParamsChange(new URLSearchParams(next));
    writeHash('egos', new URLSearchParams(next));
  }, [filters, selectedId, onParamsChange]);

  const baseResults = useMemo(() => (loaded ? filterEgos(loaded, filters) : []), [loaded, filters]);
  const selected = selectedId && loaded ? loaded.byId.get(selectedId) ?? null : null;
  const missingSelection = selectedId && loaded && !selected ? selectedId : null;

  /**
   * Damage-type code -> Chinese. Shipped on the dataset's label block and taken
   * from the engine's own `"damage type"` locale context, so `FIRE` reads 火焰.
   */
  const damageTypes = useMemo(() => loaded?.dataset.labels.damageTypes ?? {}, [loaded]);

  /**
   * Turns the codes a property can carry into Chinese.
   *
   * `learn_talent = { [Talents.T_WARD] = 3 }`, `talents_types_mastery =
   * { ['wild-gift/fungus'] = 0.1 }` and `inc_damage_type = { living = 20 }` all
   * store engine identifiers; the talent data is already loaded for the talent
   * panel, so those names cost nothing extra.
   */
  const labelOf = useMemo(() => makeCodeLabeler({
    actorTypes: loaded?.dataset.labels.actorTypes,
    talent: (code) => data.byId.get(code)?.plainName ?? null,
    tree: (id) => data.byTree.get(id)?.plainName ?? null,
  }), [loaded, data.byId, data.byTree]);

  /**
   * Community lookup. The supplement is optional, so everything degrades to
   * "no community data" rather than failing.
   */
  const communityOf = (egoId: string) => loaded?.community?.byEgoId[egoId] ?? null;
  const communityLeadsOf = (egoId: string) => {
    const ego = loaded?.byId.get(egoId);
    if (!ego || !loaded?.community) return [];
    const name = ego.name.clean.toLowerCase();
    return loaded.community.extra.filter((row) => {
      const raw = row.rawName.replace(/[（(].*$/, '').trim().toLowerCase();
      return raw.length >= 2 && (name.includes(raw) || raw.includes(name));
    });
  };

  /**
   * Slot group id -> label, and the pools behind it.
   *
   * This replaces the old "first applicable item subtype" derivation, which
   * labelled the whole `charms` pool 项圈 because one of its item subtypes is
   * `torque` — the pool actually serves torque, totem and wand alike.
   */
  const poolLabels = useMemo(() => {
    const out: Record<string, string> = {};
    for (const slot of loaded?.slots ?? []) {
      for (const pool of slot.pools) out[pool] = slot.label;
    }
    return out;
  }, [loaded]);

  const results = useMemo(() => {
    if (!loaded) return [];
    return baseResults
      .map((ego) => {
        const recommendation = loaded.recommendations.get(ego.id);
        const community = loaded.community?.byEgoId[ego.id] ?? null;
        const effect = egoSummaryLines(
          ego,
          loaded.dataset.fieldMeta,
          damageTypes,
          filters.materialLevel,
          labelOf,
          6,
        );
        const slots = [...new Set(ego.pools.map((pool) => poolLabels[pool] ?? pool))];
        return {
          ego,
          recommendation,
          community,
          effect,
          slots,
          nameText: [ego.name.zh, ego.name.clean, ego.id, ego.keyword].filter(Boolean).join(' '),
          effectText: [...effect, ego.desc ?? ''].join(' '),
          noteText: community?.note ?? '',
        };
      })
      .filter((row) => {
        if (!queryMatches(row.nameText, filters.nameQuery)) return false;
        if (!queryMatches(row.effectText, filters.effectQuery)) return false;
        if (!queryMatches(row.noteText, filters.noteQuery)) return false;
        if (filters.rarityMin !== null && (row.ego.rarity === null || row.ego.rarity < filters.rarityMin)) return false;
        if (filters.rarityMax !== null && (row.ego.rarity === null || row.ego.rarity > filters.rarityMax)) return false;
        if (
          filters.recommendations.length &&
          (row.recommendation === undefined || !filters.recommendations.includes(row.recommendation))
        ) return false;
        return true;
      });
  }, [baseResults, damageTypes, filters, labelOf, loaded, poolLabels]);

  const selectedTalent = useMemo(() => {
    if (!selectedTalentId) return null;
    const entry = data.byId.get(selectedTalentId);
    if (!entry) return null;
    const tree = data.byTree.get(entry.tree);
    return { ...entry, treeName: tree?.plainName ?? entry.treeName, categoryName: tree?.category ?? entry.category } as TalentEntry;
  }, [selectedTalentId, data.byId, data.byTree]);

  const toggleTag = (id: string) =>
    setFilters((current) => ({ ...current, tags: toggleIn(current.tags, id) }));
  const toggleSlot = (id: string) =>
    setFilters((current) => ({ ...current, slots: toggleIn(current.slots, id) }));
  const togglePosition = (value: 'prefix' | 'suffix') =>
    setFilters((current) => ({ ...current, positions: toggleIn(current.positions, value) }));
  const toggleTier = (value: 'normal' | 'greater') =>
    setFilters((current) => ({ ...current, tiers: toggleIn(current.tiers, value) }));
  const toggleSource = (value: string) =>
    setFilters((current) => ({ ...current, sources: toggleIn(current.sources, value) }));
  /** Single choice; clicking the active level again clears it back to "全部等级". */
  const toggleMaterialLevel = (level: number) =>
    setFilters((current) => ({ ...current, materialLevel: current.materialLevel === level ? null : level }));
  const toggleRecommendation = (value: number) =>
    setFilters((current) => ({
      ...current,
      recommendations: current.recommendations.includes(value)
        ? current.recommendations.filter((item) => item !== value)
        : [...current.recommendations, value],
    }));

  const clearColumnFilter = (column: EgoColumn) => {
    setFilters((current) => {
      switch (column) {
        case 'name':
          return { ...current, nameQuery: '' };
        case 'slot':
          return { ...current, slots: [] };
        case 'position':
          return { ...current, positions: [] };
        case 'tier':
          return { ...current, tiers: [] };
        case 'effect':
          return { ...current, effectQuery: '', tags: [] };
        case 'rarity':
          return { ...current, rarityMin: null, rarityMax: null };
        case 'recommendation':
          return { ...current, recommendations: [] };
        case 'note':
          return { ...current, noteQuery: '' };
      }
    });
    setOpenColumn(null);
  };

  /**
   * Filter the list down to the slot groups a pool belongs to.
   *
   * The detail panel offers the raw pool name, which is not a filter value: the
   * rail is keyed by curated slot group (`charms` shows as 护符（项圈 / 图腾 /
   * 魔杖）). Writing `slot: pool` into the filter object did nothing at all —
   * the field is `slots`, an array — so the click was silently inert.
   */
  const selectPool = (pool: string) => {
    const slots = (loaded?.slots ?? []).filter((slot) => slot.pools.includes(pool)).map((slot) => slot.id);
    if (!slots.length) return;
    setFilters((current) => ({ ...current, slots }));
  };

  const clearFilters = () => setFilters(EMPTY_FILTERS);

  if (error) {
    return (
      <div className="panel mx-auto mt-12 max-w-lg px-6 py-8 text-center">
        <h2 className="mb-2 text-[15px] font-semibold">词缀数据加载失败</h2>
        <p className="mb-3 text-[12.5px] text-muted">{error}</p>
        <p className="text-[12px] text-subtle">
          请先运行 <code className="rounded bg-chip px-1">npm run data:items</code> 生成{' '}
          <code className="rounded bg-chip px-1">public/data/egos.json</code>。
        </p>
      </div>
    );
  }

  if (!loaded) {
    return (
      <div className="flex min-h-[50vh] items-center justify-center">
        <p className="text-[13px] text-subtle">正在加载词缀数据…</p>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-[1600px] px-4 py-4">
      <header className="mb-3">
        <h1 className="text-[18px] font-semibold">装备词缀</h1>
        <p className="mt-0.5 text-[12.5px] text-muted">
          共 <span className="font-semibold tabular-nums">{loaded.dataset.egos.length}</span> 条词缀，
          归入 <span className="font-semibold tabular-nums">{loaded.slots.length}</span> 个装备分类 · 数据来自游戏源码，未做数值模拟
        </p>
      </header>

      <div className="grid grid-cols-1 gap-4 xl:grid-cols-[16rem_minmax(0,1fr)]">
        {/* --- Filter rail: tag toggles, matching the advanced-search panel --- */}
        <aside className={`${showFilters ? 'block' : 'hidden'} xl:block`}>
          <div className="panel divide-y divide-line px-3">
            <div className="py-2.5">
              <label className="mb-1 block text-[12.5px] font-semibold" htmlFor="ego-query">
                搜索词缀
              </label>
              <input
                id="ego-query"
                className="input"
                placeholder="中文 / 英文 / 词缀 ID"
                value={filters.query}
                onChange={(event) => setFilters((current) => ({ ...current, query: event.target.value }))}
              />
              <p className="mt-1 text-[10.5px] text-subtle">用引号括起可搜索短语，例如 "stun immune"</p>
            </div>

            {/*
              Open by default: choosing a slot is the most common first action,
              and a collapsed section would cost an extra click for it.
            */}
            <Section title="适用部位" defaultOpen activeCount={filters.slots.length} hint={`${loaded.slots.length} 类`}>
              <div className="flex flex-wrap gap-1">
                {loaded.slots.map((slot) => (
                  <TagButton
                    key={slot.id}
                    label={slot.label}
                    count={slot.count}
                    pressed={filters.slots.includes(slot.id)}
                    onClick={() => toggleSlot(slot.id)}
                    title={
                      slot.pools.length > 1
                        ? `包含共享词缀池：${slot.pools.join('、')}`
                        : `词缀池：${slot.pools.join('、')}`
                    }
                  />
                ))}
              </div>
              <p className="mt-1.5 text-[10.5px] leading-relaxed text-subtle">
                按玩家词缀表的分类列出。链锯、蒸汽枪等共享词缀池的装备已并入「近战武器 / 远程武器」；
                护甲共享池已并入三种护甲；不产生玩家装备词缀的内部池（充能攻击、药水、卷轴、符文）不列出。
              </p>
            </Section>

            <Section title="效果标签" defaultOpen activeCount={filters.tags.length} hint="可多选">
              <div className="flex flex-wrap gap-1">
                {EFFECT_TAGS.map((tag) => (
                  <TagButton
                    key={tag.id}
                    label={tag.label}
                    pressed={filters.tags.includes(tag.id)}
                    onClick={() => toggleTag(tag.id)}
                  />
                ))}
              </div>
              <p className="mt-1.5 text-[10.5px] leading-relaxed text-subtle">
                标签由结构化属性产生。「震慑免疫」只匹配真正给予免疫的字段，不会把需要判定免疫的触发效果算进来。
              </p>
            </Section>

            {/*
              Material level changes the numbers, not the results, so it is
              deliberately not filed with the match filters. Single choice:
              "the range on tiers 2 and 5 at once" is not something an item can
              have, and the null state has to stay reachable so the reader can
              get back to the full 1–5 span.
            */}
            <Section
              title="材料等级"
              defaultOpen
              activeCount={filters.materialLevel === null ? 0 : 1}
              hint={filters.materialLevel === null ? '全部等级' : `等级 ${filters.materialLevel}`}
            >
              <div className="flex flex-wrap gap-1">
                {MATERIAL_LEVELS.map((level) => (
                  <TagButton
                    key={level}
                    label={`${level} 级`}
                    pressed={filters.materialLevel === level}
                    onClick={() => toggleMaterialLevel(level)}
                    title="物品品阶，不是装备需求等级"
                  />
                ))}
              </div>
              <p className="mt-1.5 text-[10.5px] leading-relaxed text-subtle">
                只改变数值显示，不过滤词缀。选中后，「随材料等级变化」的属性显示该等级自己的区间；
                不选时显示 1–5 级的最大区间（与玩家词缀表的写法一致）。再点一次可取消。
              </p>
            </Section>

            <Section title="前后缀" activeCount={filters.positions.length}>
              <div className="flex flex-wrap gap-1">
                <TagButton
                  label="前缀"
                  count={loaded.dataset.egos.filter((ego) => ego.position === 'prefix').length}
                  pressed={filters.positions.includes('prefix')}
                  onClick={() => togglePosition('prefix')}
                />
                <TagButton
                  label="后缀"
                  count={loaded.dataset.egos.filter((ego) => ego.position === 'suffix').length}
                  pressed={filters.positions.includes('suffix')}
                  onClick={() => togglePosition('suffix')}
                />
              </div>
            </Section>

            <Section title="普通 / 高级" activeCount={filters.tiers.length}>
              <div className="flex flex-wrap gap-1">
                <TagButton
                  label="普通"
                  count={loaded.dataset.egos.filter((ego) => !ego.greater).length}
                  pressed={filters.tiers.includes('normal')}
                  onClick={() => toggleTier('normal')}
                />
                <TagButton
                  label="高级"
                  count={loaded.dataset.egos.filter((ego) => ego.greater).length}
                  pressed={filters.tiers.includes('greater')}
                  onClick={() => toggleTier('greater')}
                  title="greater_ego：同一词缀的高级档，游戏内以更高的生成权重出现"
                  tone="greater"
                />
              </div>
            </Section>

            <Section title="来源" activeCount={filters.sources.length}>
              <div className="flex flex-wrap gap-1">
                {loaded.dataset.sources.map((source) => {
                  const count = loaded.dataset.egos.filter((ego) => ego.source === source.id).length;
                  return (
                    <TagButton
                      key={source.id}
                      label={`${source.label} ${source.version}`}
                      count={count}
                      pressed={filters.sources.includes(source.id)}
                      onClick={() => toggleSource(source.id)}
                    />
                  );
                })}
              </div>
            </Section>

            <div className="py-2.5">
              <button type="button" className="btn w-full justify-center" onClick={clearFilters}>
                清空全部条件
              </button>
            </div>
          </div>
        </aside>

        {/* --- Results --- */}
        <div className="min-w-0">
          <div className="mb-2 flex flex-wrap items-center gap-2">
            <button type="button" className="btn xl:hidden" onClick={() => setShowFilters((v) => !v)}>
              {showFilters ? '收起筛选' : '筛选'}
            </button>
            <span className="text-[12px] text-muted">
              匹配 <span className="font-semibold tabular-nums">{results.length}</span> 条
            </span>
            {filters.tags.map((tag) => (
              <button key={tag} type="button" className="chip" onClick={() => toggleTag(tag)}>
                {EFFECT_TAGS.find((spec) => spec.id === tag)?.label ?? tag} ✕
              </button>
            ))}
          </div>

          <EgoTable
            loaded={loaded}
            rows={results}
            filters={filters}
            openColumn={openColumn}
            onOpenColumn={setOpenColumn}
            setFilters={setFilters}
            clearColumnFilter={clearColumnFilter}
            toggleTag={toggleTag}
            toggleSlot={toggleSlot}
            togglePosition={togglePosition}
            toggleTier={toggleTier}
            toggleRecommendation={toggleRecommendation}
            selectedId={selectedId}
            onSelect={(id) => {
              setSelectedId(id);
              setSelectedTalentId(null);
            }}
          />
          {results.length === 0 && (
            <div className="panel mt-2 px-4 py-8 text-center">
              <p className="text-[13px] font-medium">没有匹配的词缀</p>
              <p className="mt-1 text-[12px] text-subtle">试试减少筛选条件，或清空全部条件。</p>
              <button type="button" className="btn mt-3" onClick={clearFilters}>
                清空全部条件
              </button>
            </div>
          )}
        </div>
      </div>

      {/* --- Detail: side panel on wide screens, sheet below --- */}
      {selected && (
        <>
          <div className="mt-4 xl:hidden">
            <div className="panel p-3">
              <EgoDetail
                ego={selected}
                dataset={loaded.dataset}
                report={loaded.report}
                terms={searchTerms(filters.query)}
                damageTypes={damageTypes}
                poolLabels={poolLabels}
                community={communityOf(selected.id)}
                recommendation={loaded.recommendations.get(selected.id)}
                communityLeads={communityLeadsOf(selected.id)}
                materialLevel={filters.materialLevel}
                labelResolver={labelOf}
                onSelectPool={selectPool}
                onClose={() => setSelectedId(null)}
              />
            </div>
          </div>
          {/*
            The panel is pinned to the *viewport*, so it must start below the
            sticky header, not at `top: 0`: the header is a later sibling with a
            higher z-index and used to cover the item's name and its close
            button, which made the top of every detail unreadable. `--header-h`
            is kept in sync with the real header height by `useHeaderHeight`,
            because the header wraps to two rows on narrow viewports.
          */}
          <div className="pointer-events-none fixed bottom-0 right-0 top-[calc(var(--header-h)+2px)] z-20 hidden w-[26rem] p-3 xl:block">
            {/* `pb-16` keeps the last row out from under the compare tray, which
                is fixed to the viewport bottom at a higher z-index. */}
            <div className="pointer-events-auto panel h-full overflow-y-auto p-3 pb-16">
              <EgoDetail
                ego={selected}
                dataset={loaded.dataset}
                report={loaded.report}
                terms={searchTerms(filters.query)}
                damageTypes={damageTypes}
                poolLabels={poolLabels}
                community={communityOf(selected.id)}
                recommendation={loaded.recommendations.get(selected.id)}
                communityLeads={communityLeadsOf(selected.id)}
                materialLevel={filters.materialLevel}
                labelResolver={labelOf}
                onSelectPool={selectPool}
                onClose={() => setSelectedId(null)}
              />
            </div>
          </div>
        </>
      )}

      {selectedTalent && (
        <div className="panel mt-4 p-3">
          <TalentDetail
            talent={selectedTalent}
            tree={data.byTree.get(selectedTalent.tree)}
            meta={data.meta}
            terms={[]}
            onClose={() => setSelectedTalentId(null)}
            onJumpToTree={() => undefined}
            onAddFlag={() => undefined}
            onSelectClass={() => undefined}
            favorite={favoriteHas(selectedTalent.id)}
            onToggleFavorite={onToggleFavorite}
            inCompare={compareHas(selectedTalent.id)}
            onToggleCompare={onToggleCompare}
            compareFull={compareFull}
            compact
            embedded
          />
        </div>
      )}

      {missingSelection && (
        <div className="panel mt-4 px-4 py-6 text-center">
          <p className="text-[13px] font-medium">找不到词缀 {missingSelection}</p>
          <p className="mt-1 text-[12px] text-subtle">链接里的词缀 ID 不在当前数据集中，可能已被重命名或删除。</p>
        </div>
      )}
    </div>
  );
}
