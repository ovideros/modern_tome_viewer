import { useEffect, useMemo, useRef, useState } from 'react';
import type { LoadedData } from '../lib/data';
import {
  compileFilters,
  emptyFilters,
  filtersToParams,
  paramsToFilters,
  writeHash,
  type FilterState,
} from '../lib/filters';
import { TalentSearchIndex } from '../lib/search';
import type { TalentEntry } from '../lib/types';
import { FilterPanel } from '../components/FilterPanel';
import { ResultsList } from '../components/ResultsList';
import { SearchBar } from '../components/SearchBar';
import { TalentDetail } from '../components/TalentDetail';

interface SearchPageProps {
  data: LoadedData;
  index: TalentSearchIndex | null;
  building: boolean;
  params: URLSearchParams;
  onParamsChange: (params: URLSearchParams) => void;
  favoriteHas: (id: string) => boolean;
  onToggleFavorite: (id: string) => void;
  compareHas: (id: string) => boolean;
  onToggleCompare: (id: string) => void;
  compareFull: boolean;
}

/** Tree ids a class can learn, resolved from the class/subclass mappings. */
function classTreeSet(data: LoadedData, classId: string | null): Set<string> | undefined {
  if (!classId) return undefined;
  const set = new Set<string>();
  const cls = data.meta.classes.find((c) => c.id === classId);
  if (!cls) return set;
  for (const tree of data.trees) {
    if (tree.classes.includes(classId)) set.add(tree.id);
  }
  return set;
}

export function SearchPage({
  data,
  index,
  building,
  params,
  onParamsChange,
  favoriteHas,
  onToggleFavorite,
  compareHas,
  onToggleCompare,
  compareFull,
}: SearchPageProps) {
  const [filters, setFilters] = useState<FilterState>(() => paramsToFilters(params));
  const [selected, setSelected] = useState<TalentEntry | null>(null);
  const [showFilters, setShowFilters] = useState(false);
  const barRef = useRef<HTMLDivElement>(null);

  // Publish the sticky search bar's height so the columns below can offset by
  // it; otherwise their top edge slides underneath the bar when scrolling.
  useEffect(() => {
    const element = barRef.current;
    if (!element) return;
    const apply = () =>
      document.documentElement.style.setProperty('--searchbar-h', `${Math.round(element.getBoundingClientRect().height)}px`);
    apply();
    const observer = typeof ResizeObserver === 'function' ? new ResizeObserver(apply) : null;
    observer?.observe(element);
    window.addEventListener('resize', apply);
    return () => {
      observer?.disconnect();
      window.removeEventListener('resize', apply);
    };
  }, []);

  // Keep the URL hash in sync so searches are shareable/bookmarkable.
  useEffect(() => {
    onParamsChange(filtersToParams(filters));
  }, [filters, onParamsChange]);

  // Deep link support: #/search?...&talent=T_FIRE opens the detail panel.
  useEffect(() => {
    const talentId = params.get('talent');
    if (!talentId) return;
    const found = data.byId.get(talentId);
    if (found) setSelected(found);
    // Only react to the id itself; the rest of the hash is driven by filters.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [params.get('talent'), data.byId]);

  const classTrees = useMemo(() => classTreeSet(data, filters.classId), [data, filters.classId]);
  const predicate = useMemo(() => compileFilters(filters, classTrees), [filters, classTrees]);

  /** Search hits restricted by the structured filters, best score first. */
  const matched = useMemo(() => {
    const query = filters.query.trim();
    if (query && index) {
      const hits = index.search(query, {
        limit: 4000,
        defaultFields: filters.fields as never,
      });
      const out: TalentEntry[] = [];
      for (const hit of hits) {
        const talent = data.talents[hit.index];
        if (talent && predicate(talent)) out.push(talent);
      }
      return out;
    }
    return data.talents.filter(predicate);
  }, [filters.query, filters.fields, index, data.talents, predicate]);

  /** Highlight terms: bare words from the query, without field prefixes. */
  const terms = useMemo(() => {
    const parsed = TalentSearchIndex.parseQuery(filters.query);
    return parsed.filter((t) => !t.negated).map((t) => t.value);
  }, [filters.query]);

  const setFiltersAndHash = (next: FilterState) => {
    setFilters(next);
    writeHash('search', filtersToParams(next));
  };

  const openTalent = (talent: TalentEntry) => {
    setSelected(talent);
    const next = filtersToParams(filters);
    next.set('talent', talent.id);
    writeHash('search', next);
  };

  const closeTalent = () => {
    setSelected(null);
    const next = filtersToParams(filters);
    next.delete('talent');
    writeHash('search', next);
  };

  /** Narrow the search to a single tree (the browse page was removed). */
  const jumpToTree = (treeId: string) => {
    setFiltersAndHash({ ...emptyFilters(), trees: [treeId] });
    setSelected(null);
  };

  const addFlag = (flag: string) => {
    setFiltersAndHash({ ...filters, flags: filters.flags.includes(flag) ? filters.flags : [...filters.flags, flag] });
  };

  const selectClass = (classId: string) => {
    setFiltersAndHash({ ...filters, classId });
    setSelected(null);
  };

  return (
    <div className="mx-auto max-w-[1600px] px-4 py-3">
      <div
        ref={barRef}
        className="sticky top-[calc(var(--header-h)+2px)] z-20 -mx-1 mb-3 bg-sunken px-1 pb-2 pt-1"
      >
        <SearchBar
          filters={filters}
          onChange={setFiltersAndHash}
          matchCount={matched.length}
          building={building}
          onToggleFilters={() => setShowFilters((v) => !v)}
        />
      </div>

      <div className="flex gap-3">
        <div className={`${showFilters ? 'block' : 'hidden'} w-full shrink-0 lg:block lg:w-[300px]`}>
          <div
            className="sticky h-[calc(100vh-var(--header-h)-var(--searchbar-h)-20px)]"
            style={{ top: 'calc(var(--header-h) + var(--searchbar-h) + 8px)' }}
          >
            <FilterPanel
              meta={data.meta}
              talents={data.talents}
              filters={filters}
              onChange={setFiltersAndHash}
              classTrees={classTrees}
              matchCount={matched.length}
              totalCount={data.talents.length}
              onClose={() => setShowFilters(false)}
            />
          </div>
        </div>

        <div className="min-w-0 flex-1">
          <ResultsList
            entries={matched}
            terms={terms}
            iconSize={data.meta.iconSize}
            selectedId={selected?.id ?? null}
            onSelect={openTalent}
            favoriteHas={favoriteHas}
            onToggleFavorite={onToggleFavorite}
            compareHas={compareHas}
            onToggleCompare={onToggleCompare}
            compareFull={compareFull}
          />
        </div>

        {selected && (
          <div className="animate-fade-in hidden w-[380px] shrink-0 xl:block">
            <div
              className="sticky h-[calc(100vh-var(--header-h)-var(--searchbar-h)-20px)]"
              style={{ top: 'calc(var(--header-h) + var(--searchbar-h) + 8px)' }}
            >
              <TalentDetail
                talent={selected}
                tree={data.byTree.get(selected.tree)}
                meta={data.meta}
                terms={terms}
                onClose={closeTalent}
                onJumpToTree={jumpToTree}
                onAddFlag={addFlag}
                onSelectClass={selectClass}
                favorite={favoriteHas(selected.id)}
                onToggleFavorite={onToggleFavorite}
                inCompare={compareHas(selected.id)}
                onToggleCompare={onToggleCompare}
                compareFull={compareFull}
              />
            </div>
          </div>
        )}
      </div>

      {/* On narrow screens the detail panel becomes a bottom sheet. */}
      {selected && (
        <div className="fixed inset-x-0 bottom-0 z-40 max-h-[70vh] xl:hidden">
          <div className="animate-fade-in mx-2 mb-2 max-h-[70vh] overflow-hidden">
            <TalentDetail
              talent={selected}
              tree={data.byTree.get(selected.tree)}
              meta={data.meta}
              terms={terms}
              onClose={closeTalent}
              onJumpToTree={jumpToTree}
              onAddFlag={addFlag}
              onSelectClass={selectClass}
              favorite={favoriteHas(selected.id)}
              onToggleFavorite={onToggleFavorite}
              inCompare={compareHas(selected.id)}
              onToggleCompare={onToggleCompare}
              compareFull={compareFull}
            />
          </div>
        </div>
      )}
    </div>
  );
}
