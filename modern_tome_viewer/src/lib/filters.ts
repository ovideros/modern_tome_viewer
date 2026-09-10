/**
 * Faceted filtering for talent search.
 *
 * The filter state is the single source of truth for the results list, and it
 * round-trips through the URL hash so any search can be shared or bookmarked.
 */

import type { TalentEntry, TallyEntry } from './types';

export interface FilterState {
  /** Free-text query, parsed by the search index. */
  query: string;
  /** Fields used for bare (unqualified) terms. */
  fields: string[];
  modes: string[];
  useSpeeds: string[];
  rangeKinds: string[];
  resources: string[];
  costKinds: string[];
  flags: string[];
  categories: string[];
  trees: string[];
  /** Class id — matches every tree the class can learn. */
  classId: string | null;
  /** null means "no bound applied". */
  cooldown: { min: number | null; max: number | null };
  range: { min: number | null; max: number | null };
  requireLevel: { min: number | null; max: number | null };
  /** Show talents that have no cooldown at all (passives, sustains). */
  includeNoCooldown: boolean;
}

export function emptyFilters(): FilterState {
  return {
    query: '',
    fields: ['name', 'tree', 'category', 'text'],
    modes: [],
    useSpeeds: [],
    rangeKinds: [],
    resources: [],
    costKinds: [],
    flags: [],
    categories: [],
    trees: [],
    classId: null,
    cooldown: { min: null, max: null },
    range: { min: null, max: null },
    requireLevel: { min: null, max: null },
    includeNoCooldown: true,
  };
}

export function activeFilterCount(filters: FilterState): number {
  let count = 0;
  const arrays: (readonly unknown[])[] = [
    filters.modes,
    filters.useSpeeds,
    filters.rangeKinds,
    filters.resources,
    filters.costKinds,
    filters.flags,
    filters.categories,
    filters.trees,
  ];
  for (const array of arrays) count += array.length;
  if (filters.classId) count += 1;
  if (filters.cooldown.min !== null || filters.cooldown.max !== null) count += 1;
  if (filters.range.min !== null || filters.range.max !== null) count += 1;
  if (filters.requireLevel.min !== null || filters.requireLevel.max !== null) count += 1;
  return count;
}

/** Does a numeric ladder overlap the requested [min, max] window? */
function overlaps(values: number[], min: number | null, max: number | null): boolean {
  if (min === null && max === null) return true;
  if (!values.length) return false;
  const low = min ?? -Infinity;
  const high = max ?? Infinity;
  return values.some((value) => value >= low && value <= high);
}

export interface TalentPredicate {
  (talent: TalentEntry): boolean;
  /** Precomputed tree set for the active class filter, if any. */
  classTrees?: Set<string>;
}

/**
 * Compile a filter state into a reusable predicate.
 *
 * Multi-select values become Sets so the inner loop stays O(1) per field
 * instead of O(options) — this matters because the predicate runs for every
 * talent on every keystroke.
 */
export function compileFilters(filters: FilterState, classTrees?: Set<string>): TalentPredicate {
  const modes = filters.modes.length ? new Set(filters.modes) : null;
  const useSpeeds = filters.useSpeeds.length ? new Set(filters.useSpeeds) : null;
  const rangeKinds = filters.rangeKinds.length ? new Set(filters.rangeKinds) : null;
  const resources = filters.resources.length ? new Set(filters.resources) : null;
  const costKinds = filters.costKinds.length ? new Set(filters.costKinds) : null;
  const categories = filters.categories.length ? new Set(filters.categories) : null;
  const trees = filters.trees.length ? new Set(filters.trees) : null;
  const flags = filters.flags;

  const { min: cdMin, max: cdMax } = filters.cooldown;
  const hasCooldownFilter = cdMin !== null || cdMax !== null;
  const { min: rMin, max: rMax } = filters.range;
  const hasRangeFilter = rMin !== null || rMax !== null;
  const { min: lMin, max: lMax } = filters.requireLevel;
  const hasLevelFilter = lMin !== null || lMax !== null;

  const predicate = ((talent: TalentEntry): boolean => {
    if (filters.classId && (!classTrees || !classTrees.has(talent.tree))) return false;
    if (categories && !categories.has(talent.category)) return false;
    if (trees && !trees.has(talent.tree)) return false;
    if (modes && !modes.has(talent.mode)) return false;
    if (useSpeeds && !useSpeeds.has(talent.useSpeed)) return false;
    if (rangeKinds && !rangeKinds.has(talent.range.kind)) return false;
    if (resources && !resources.has(talent.cost.resource ?? '')) return false;
    if (costKinds && !costKinds.has(talent.cost.kind ?? '')) return false;
    for (let i = 0; i < flags.length; i += 1) {
      if (talent.flags[flags[i]] !== true) return false;
    }

    if (hasCooldownFilter) {
      if (!talent.cooldown.values.length) {
        if (!filters.includeNoCooldown) return false;
      } else if (!overlaps(talent.cooldown.values, cdMin, cdMax)) {
        return false;
      }
    }

    if (hasRangeFilter) {
      if (talent.range.max === null) return false;
      if (!overlaps([talent.range.min ?? talent.range.max], rMin, rMax)) return false;
    }

    if (hasLevelFilter) {
      let ok = false;
      for (const requirement of talent.require) {
        const level = requirement.level;
        if (level !== null && (lMin === null || level >= lMin) && (lMax === null || level <= lMax)) {
          ok = true;
          break;
        }
      }
      if (!ok) return false;
    }

    return true;
  }) as TalentPredicate;

  predicate.classTrees = classTrees;
  return predicate;
}

export function talentMatches(talent: TalentEntry, filters: FilterState, classTrees?: Set<string>): boolean {
  return compileFilters(filters, classTrees)(talent);
}

export interface FilterResult {
  entries: TalentEntry[];
  /** Total matches before any pagination. */
  total: number;
}

export function applyFilters(
  talents: TalentEntry[],
  filters: FilterState,
  classTrees?: Set<string>,
): TalentEntry[] {
  const predicate = compileFilters(filters, classTrees);
  return talents.filter(predicate);
}

/**
 * Facet counts for a dropdown, computed against every *other* active filter so
 * the numbers answer "how many results would this option add?".
 */
export function facetCounts(
  talents: TalentEntry[],
  filters: FilterState,
  key: keyof FilterState,
  classTrees?: Set<string>,
): TallyEntry[] {
  const relaxed: FilterState = { ...filters, [key]: [] } as FilterState;
  if (key === 'trees' && filters.classId) relaxed.trees = [];
  const counts = new Map<string, number>();
  for (const talent of talents) {
    if (!talentMatches(talent, relaxed, classTrees)) continue;
    const value = facetValue(talent, key);
    if (value === null || value === undefined || value === '') continue;
    counts.set(value, (counts.get(value) ?? 0) + 1);
  }
  return [...counts.entries()]
    .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
    .map(([value, count]) => ({ value, count }));
}

function facetValue(talent: TalentEntry, key: keyof FilterState): string | null {
  switch (key) {
    case 'modes':
      return talent.mode;
    case 'useSpeeds':
      return talent.useSpeed;
    case 'rangeKinds':
      return talent.range.kind;
    case 'resources':
      return talent.cost.resource;
    case 'costKinds':
      return talent.cost.kind;
    case 'categories':
      return talent.category;
    case 'trees':
      return talent.tree;
    default:
      return null;
  }
}

// ---------------------------------------------------------------------------
// URL hash serialization
// ---------------------------------------------------------------------------

const ARRAY_KEYS: (keyof FilterState)[] = [
  'modes', 'useSpeeds', 'rangeKinds', 'resources', 'costKinds', 'flags', 'categories', 'trees',
];

export function filtersToParams(filters: FilterState): URLSearchParams {
  const params = new URLSearchParams();
  if (filters.query) params.set('q', filters.query);
  const defaults = emptyFilters().fields.join(',');
  if (filters.fields.join(',') !== defaults) params.set('f', filters.fields.join(','));
  for (const key of ARRAY_KEYS) {
    const values = filters[key] as string[];
    if (values.length) params.set(key, values.join('\u0001'));
  }
  if (filters.classId) params.set('class', filters.classId);
  if (filters.cooldown.min !== null) params.set('cdMin', String(filters.cooldown.min));
  if (filters.cooldown.max !== null) params.set('cdMax', String(filters.cooldown.max));
  if (filters.range.min !== null) params.set('rMin', String(filters.range.min));
  if (filters.range.max !== null) params.set('rMax', String(filters.range.max));
  if (filters.requireLevel.min !== null) params.set('lvMin', String(filters.requireLevel.min));
  if (filters.requireLevel.max !== null) params.set('lvMax', String(filters.requireLevel.max));
  if (!filters.includeNoCooldown) params.set('noCd', '0');
  return params;
}

export function paramsToFilters(params: URLSearchParams): FilterState {
  const filters = emptyFilters();
  const query = params.get('q');
  if (query) filters.query = query;

  const fields = params.get('f');
  if (fields) {
    const parsed = fields.split(',').filter(Boolean);
    if (parsed.length) filters.fields = parsed;
  }

  for (const key of ARRAY_KEYS) {
    const raw = params.get(key);
    if (raw) (filters[key] as string[]) = raw.split('\u0001').filter(Boolean);
  }

  const classId = params.get('class');
  if (classId) filters.classId = classId;

  const num = (key: string): number | null => {
    const raw = params.get(key);
    if (raw === null || raw === '') return null;
    const value = Number(raw);
    return Number.isFinite(value) ? value : null;
  };

  filters.cooldown = { min: num('cdMin'), max: num('cdMax') };
  filters.range = { min: num('rMin'), max: num('rMax') };
  filters.requireLevel = { min: num('lvMin'), max: num('lvMax') };
  filters.includeNoCooldown = params.get('noCd') !== '0';
  return filters;
}

/** Read filters from the current location hash (form "#/search?q=…"). */
export function readHash(): { route: string; params: URLSearchParams } {
  const raw = window.location.hash.replace(/^#\/?/, '');
  const [route, search] = raw.split('?');
  return { route: route || 'search', params: new URLSearchParams(search ?? '') };
}

export function writeHash(route: string, params: URLSearchParams, replace = true): void {
  const search = params.toString();
  const hash = `#/${route}${search ? `?${search}` : ''}`;
  if (window.location.hash === hash) return;
  if (replace) window.history.replaceState(null, '', hash);
  else window.history.pushState(null, '', hash);
}
