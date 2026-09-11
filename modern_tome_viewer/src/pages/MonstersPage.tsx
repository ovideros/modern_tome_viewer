import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { stripMarkup } from '../lib/data';
import { writeHash } from '../lib/filters';
import { useMediaQuery } from '../hooks/useMediaQuery';
import {
  CATEGORY_ORDER,
  filterMonsters,
  loadMonsterData,
  monsterDisplayName,
  monsterTypeTree,
  parseMonsterQuery,
  type Monster,
  type MonsterCategory,
  type MonsterData,
  type MonsterFilters,
} from '../lib/monsters';
import type { LoadedData } from '../lib/data';
import type { TalentEntry } from '../lib/types';
import { Highlight } from '../components/Highlight';
import { MonsterArtwork, CategoryBadge, TypeChip } from '../components/MonsterBits';
import { MonsterTypeTree } from '../components/MonsterTypeTree';
import { MonsterDetail } from '../components/MonsterDetail';
import { TalentDetail } from '../components/TalentDetail';

interface MonstersPageProps {
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
 * Wrap a plain `Talent` as a `TalentEntry` for the shared detail panel.
 *
 * The panel wants the tree/category labels for its breadcrumb; those are read
 * from the dataset here rather than from the monster, which does not know them.
 */
function asEntry(talent: TalentEntry, treeName: string, categoryName: string): TalentEntry {
  return { ...talent, treeName, treePlainName: treeName, category: talent.category, categoryName };
}

function paramsToFilters(params: URLSearchParams): MonsterFilters {
  const category = params.get('cat');
  const source = params.get('src');
  // A subtype is only meaningful inside a type: the sidebar shows subtypes of
  // the selected type, so `?sub=orc` on its own has nothing to display as
  // active and would silently filter without any visible reason.
  const type = params.get('type') ?? 'all';
  return {
    query: params.get('q') ?? '',
    category: category && CATEGORY_ORDER.includes(category as MonsterCategory) ? (category as MonsterCategory) : 'all',
    type,
    subtype: type === 'all' ? 'all' : params.get('sub') ?? 'all',
    source: source ?? 'all',
    onlyRandomGroups: params.get('rng') === '1',
  };
}

function filtersToParams(filters: MonsterFilters, monsterId: string | null): URLSearchParams {
  const next = new URLSearchParams();
  if (filters.query.trim()) next.set('q', filters.query.trim());
  if (filters.category !== 'all') next.set('cat', filters.category);
  if (filters.type !== 'all') {
    next.set('type', filters.type);
    if (filters.subtype !== 'all') next.set('sub', filters.subtype);
  }
  if (filters.source !== 'all') next.set('src', filters.source);
  if (filters.onlyRandomGroups) next.set('rng', '1');
  if (monsterId) next.set('m', monsterId);
  return next;
}

/** Search terms for highlighting; the same parser the filter uses. */
function termsOf(query: string): string[] {
  return parseMonsterQuery(query).map(({ term }) => term);
}

export function MonstersPage({
  data,
  params,
  onParamsChange,
  favoriteHas,
  onToggleFavorite,
  compareHas,
  onToggleCompare,
  compareFull,
}: MonstersPageProps) {
  // Where the talent opens:
  //  - `xl` (1280px) and up: a third column, beside the monster panel. The
  //    third column is paid for by the list, not by the viewport: while a
  //    talent is open the list's card columns follow the list's *own* width
  //    (container query), so it drops to one column whenever three panes would
  //    squeeze it, and goes back to two as soon as there is room. The two side
  //    panels also give 20px each back to the list.
  //  - below `xl`: a bottom sheet, sharing one slot with the monster sheet.
  //
  // Below `xl` the talent sheet takes the same slot as the monster sheet, so the
  // monster sheet is suppressed while a talent is open and its close button
  // reads 返回怪物. That keeps the phone layout to one focused sheet at a time
  // instead of stacking two drawers on top of each other.
  // Only the *bottom sheet* variant needs the JS answer; the side columns stay
  // CSS-driven (`xl:block`). `fallback: true` means an environment without
  // `matchMedia` keeps the desktop layout rather than losing a panel.
  const narrowViewport = !useMediaQuery('(min-width: 1280px)', true);

  const [monsterData, setMonsterData] = useState<MonsterData | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState<MonsterFilters>(() => paramsToFilters(params));
  const [selectedId, setSelectedId] = useState<string | null>(() => params.get('m'));
  // The talent opened from a monster's skill list. Kept in page state so
  // reading a skill never navigates away from the monster.
  const [selectedTalentId, setSelectedTalentId] = useState<string | null>(null);
  const [showFilters, setShowFilters] = useState(false);
  const listRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    let alive = true;
    loadMonsterData()
      .then((loaded) => alive && setMonsterData(loaded))
      .catch((err: unknown) => alive && setError(err instanceof Error ? err.message : String(err)));
    return () => {
      alive = false;
    };
  }, []);

  // Two effects keep the URL and the page state in step:
  //
  //  - the page publishes its state to the hash, so the view is shareable;
  //  - an incoming hash (a pasted link, Back/Forward, another route) is
  //    adopted into the state.
  //
  // Each records the string it last *synced with* — the publish effect the hash
  // it wrote, the adopt effect the hash it read. A hash is only treated as
  // incoming when it is neither, which is what stops the two from fighting each
  // other. (An earlier version used a "local state is ahead" flag, and that
  // flag was consumed by the wrong render: a link arriving right after a skill
  // click was silently discarded.)
  //
  // The refs start as `undefined`, not `''`: "no filters" is a perfectly valid
  // hash (`#/monsters`), and using `''` as the "nothing synced yet" sentinel
  // made the publish effect treat a cleared filter set as already published —
  // the URL kept the filters the reader had just removed.
  const publishedHash = useRef<string | undefined>(undefined);
  const adoptedHash = useRef<string | undefined>(undefined);
  const [notFound, setNotFound] = useState<string | null>(null);

  useEffect(() => {
    const hash = params.toString();
    if (hash === publishedHash.current || hash === adoptedHash.current) return;
    adoptedHash.current = hash;
    setFilters(paramsToFilters(params));
    const nextId = params.get('m');
    setSelectedId(nextId);
    setNotFound(nextId && monsterData && !monsterData.byId.has(nextId) ? nextId : null);
    // `params` is recreated by the router on every hash change; the serialized
    // string is the stable dependency.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [params.toString(), monsterData]);

  useEffect(() => {
    const next = filtersToParams(filters, selectedId).toString();
    // Only the *published* hash is compared here: an adopted one is still
    // written back (identical hashes are a no-op in `writeHash`), which is what
    // normalises a hand-written link into the canonical order.
    if (next === publishedHash.current) return;
    publishedHash.current = next;
    onParamsChange(new URLSearchParams(next));
    // The other pages write their own hash too; without this the monster view
    // was shareable only in the direction "link -> page", never "page -> link",
    // and a reload dropped the type/category the reader had picked.
    writeHash('monsters', new URLSearchParams(next));
  }, [filters, selectedId, onParamsChange]);

  const results = useMemo(() => (monsterData ? filterMonsters(monsterData, filters) : []), [monsterData, filters]);
  const terms = useMemo(() => termsOf(filters.query), [filters.query]);
  // The type tree is built from the whole encyclopedia, not from the current
  // result set, so its counts stay stable while the query changes.
  const typeTree = useMemo(() => (monsterData ? monsterTypeTree(monsterData.dataset.monsters) : []), [monsterData]);
  const subtypeOptions = useMemo(
    () => typeTree.find((option) => option.type === filters.type)?.subtypes ?? [],
    [typeTree, filters.type],
  );
  const activeTypeLabel = filters.type === 'all' ? null : typeTree.find((option) => option.type === filters.type)?.label ?? filters.type;
  const activeSubtypeLabel =
    filters.subtype === 'all' ? null : subtypeOptions.find((option) => option.subtype === filters.subtype)?.label ?? filters.subtype;

  /** Selecting a type resets the subtype; `all` clears both. */
  const selectType = (type: string | 'all', subtype: string | 'all') => {
    setFilters((current) => ({ ...current, type, subtype: type === 'all' ? 'all' : subtype }));
  };
  const selected = selectedId && monsterData ? monsterData.byId.get(selectedId) ?? null : null;
  // A link can name a template that is not in the encyclopedia (an abstract
  // BASE, or a typo). Say so instead of silently showing nothing.
  const missingSelection = selectedId && monsterData && !selected ? selectedId : notFound && !selected ? notFound : null;

  const talentOf = useMemo(() => (id: string) => data.byId.get(id), [data.byId]);

  const selectMonster = (monster: Monster) => {
    setSelectedId(monster.id);
    // A talent from the previous monster must not linger in the side panel.
    setSelectedTalentId(null);
  };

  const selectTalent = useCallback((talent: TalentEntry) => {
    // Tapping the open talent again closes the panel.
    setSelectedTalentId((current) => (current === talent.id ? null : talent.id));
  }, []);

  const selectedTalent = useMemo(() => {
    if (!selectedTalentId) return null;
    const entry = data.byId.get(selectedTalentId);
    if (!entry) return null;
    const tree = data.byTree.get(entry.tree);
    return asEntry(entry, tree?.plainName ?? entry.treeName, tree?.category ?? entry.category);
  }, [selectedTalentId, data.byId, data.byTree]);

  if (error) {
    return (
      <div className="panel mx-auto mt-12 max-w-lg px-6 py-8 text-center">
        <h2 className="mb-2 text-[15px] font-semibold">怪物数据加载失败</h2>
        <p className="mb-3 text-[12.5px] text-muted">{error}</p>
        <p className="text-[12px] text-subtle">
          请先运行 <code className="rounded bg-chip px-1">npm run data</code> 生成{' '}
          <code className="rounded bg-chip px-1">public/data/monsters.json</code>。
        </p>
      </div>
    );
  }

  if (!monsterData) {
    return (
      <div className="flex min-h-[50vh] items-center justify-center">
        <p className="text-[13px] text-subtle">正在加载怪物数据…</p>
      </div>
    );
  }

  const census = monsterData.dataset.census;
  const sources = monsterData.dataset.sources;

  return (
    <div className="mx-auto max-w-[1600px] px-4 py-3">
      {/* Census headline: the counts the encyclopedia is built from, with the
          exact inclusion rule stated so the numbers are reproducible. */}
      <div className="panel mb-3 px-3 py-2">
        <div className="flex flex-wrap items-baseline gap-x-3 gap-y-1">
          <h1 className="text-[15px] font-bold">怪物图鉴</h1>
          <span className="text-[11.5px] text-subtle">
            游戏版本 {monsterData.dataset.gameVersion} · 共收录 {census.concrete} 个可遇怪物模板
          </span>
        </div>
        <p className="mt-1 text-[11.5px] text-muted">
          {CATEGORY_ORDER.filter((key) => (census.byCategory[key] ?? 0) > 0)
            .map((key) => `${monsterData.dataset.categoryLabels[key] ?? key} ${census.byCategory[key]}`)
            .join(' · ')}
          {census.distinctTypes ? ` · ${census.distinctTypes} 个大类 / ${census.distinctSubtypes ?? 0} 个亚类` : ''}
        </p>
        <p className="mt-0.5 text-[10.5px] text-subtle">
          口径：源码 {census.templates} 个 newEntity 模板中，{census.abstract} 个是只用于继承的抽象 BASE 模板，其余{' '}
          {census.concrete} 个带名称的实体计入图鉴；rank ≥ 3.5 的固定 Boss {census.fixedBosses} 个，其中{' '}
          {census.randomBossCapable} 个会在更高难度下被追加随机职业（其余 {census.noDifficultyRandomClass}{' '}
          个用 no_difficulty_random_class 关闭）。同一模板被多个区域引用只计一次。
        </p>
      </div>

      <div className="flex gap-3">
        <aside className="hidden w-[236px] shrink-0 lg:block">
          <div className="panel sticky top-[calc(var(--header-h)+2px)] flex max-h-[calc(100vh-var(--header-h)-12px)] flex-col overflow-hidden">
            <div className="border-b border-line p-2.5">
              <input
                className="input"
                placeholder="搜索名称 / 技能 / 类型…"
                value={filters.query}
                onChange={(event) => setFilters({ ...filters, query: event.target.value })}
              />
            </div>
            <div className="min-h-0 flex-1 overflow-y-auto py-1">
              {/* Below the search box: the engine's own type / subtype pair, as a
                  two-level picker (the rarity rows keep their own section). */}
              <MonsterTypeTree
                options={typeTree}
                total={census.concrete}
                activeType={filters.type}
                activeSubtype={filters.subtype}
                onSelect={selectType}
              />
              <div className="mt-2 border-t border-line pt-1">
                <h3 className="px-2.5 pt-1 pb-0.5 text-[11px] font-semibold text-subtle">稀有度</h3>
                <CategoryRow
                  label="全部"
                  count={census.concrete}
                  active={filters.category === 'all'}
                  onClick={() => setFilters({ ...filters, category: 'all' })}
                />
                {CATEGORY_ORDER.map((key) => (
                  <CategoryRow
                    key={key}
                    label={monsterData.dataset.categoryLabels[key] ?? key}
                    count={census.byCategory[key] ?? 0}
                    active={filters.category === key}
                    onClick={() => setFilters({ ...filters, category: key })}
                  />
                ))}
              </div>
              <div className="mt-2 border-t border-line px-2.5 py-2">
                <h3 className="mb-1 text-[11px] font-semibold text-subtle">来源包</h3>
                <div className="flex flex-wrap gap-1">
                  <button
                    type="button"
                    className="btn px-2 py-0.5 text-[11px]"
                    aria-pressed={filters.source === 'all'}
                    onClick={() => setFilters({ ...filters, source: 'all' })}
                  >
                    全部
                  </button>
                  {sources.map((source) => (
                    <button
                      key={source.id}
                      type="button"
                      className="btn px-2 py-0.5 text-[11px]"
                      aria-pressed={filters.source === source.id}
                      onClick={() => setFilters({ ...filters, source: source.id })}
                      title={`${source.en} · ${source.files} 个文件 / ${source.templates} 个模板`}
                    >
                      {source.label} {census.bySource[source.id] ?? 0}
                    </button>
                  ))}
                </div>
                <label className="mt-2 flex items-center gap-1.5 text-[11.5px] text-muted">
                  <input
                    type="checkbox"
                    checked={filters.onlyRandomGroups}
                    onChange={(event) => setFilters({ ...filters, onlyRandomGroups: event.target.checked })}
                  />
                  只看有随机技能组的
                </label>
              </div>
            </div>
          </div>
        </aside>

        <main className="@container min-w-0 flex-1">
          {/* Mobile: filters collapse into a toggle so the list keeps the space. */}
          <div className="mb-2 flex items-center gap-2 lg:hidden">
            <input
              className="input flex-1"
              placeholder="搜索名称 / 技能…"
              value={filters.query}
              onChange={(event) => setFilters({ ...filters, query: event.target.value })}
            />
            <button type="button" className="btn" onClick={() => setShowFilters((v) => !v)} aria-expanded={showFilters}>
              分类
            </button>
          </div>
          {showFilters && (
            <div className="panel mb-2 flex flex-wrap gap-1 p-2 lg:hidden">
              {/* The desktop tree does not fit a phone, so the same two levels
                  are exposed as selects. */}
              <div className="mb-1 flex w-full flex-wrap items-center gap-1" data-testid="monster-type-selects">
                <label className="sr-only" htmlFor="monster-type-select">
                  怪物大类
                </label>
                <select
                  id="monster-type-select"
                  className="input min-w-[140px] flex-1"
                  value={filters.type}
                  aria-label="怪物大类"
                  onChange={(event) => selectType(event.target.value, 'all')}
                >
                  <option value="all">全部类别</option>
                  {typeTree.map((option) => (
                    <option key={option.type} value={option.type}>
                      {option.label}（{option.count}）
                    </option>
                  ))}
                </select>
                {subtypeOptions.length > 0 && (
                  <>
                    <label className="sr-only" htmlFor="monster-subtype-select">
                      怪物亚类
                    </label>
                    <select
                      id="monster-subtype-select"
                      className="input min-w-[140px] flex-1"
                      value={filters.subtype}
                      aria-label="怪物亚类"
                      onChange={(event) => selectType(filters.type, event.target.value)}
                    >
                      <option value="all">全部亚类</option>
                      {subtypeOptions.map((option) => (
                        <option key={option.subtype} value={option.subtype}>
                          {option.label}（{option.count}）
                        </option>
                      ))}
                    </select>
                  </>
                )}
              </div>
              <button
                type="button"
                className="btn px-2 py-0.5 text-[11px]"
                aria-pressed={filters.category === 'all'}
                onClick={() => setFilters({ ...filters, category: 'all' })}
              >
                全部 {census.concrete}
              </button>
              {CATEGORY_ORDER.map((key) => (
                <button
                  key={key}
                  type="button"
                  className="btn px-2 py-0.5 text-[11px]"
                  aria-pressed={filters.category === key}
                  onClick={() => setFilters({ ...filters, category: key })}
                >
                  {monsterData.dataset.categoryLabels[key] ?? key} {census.byCategory[key] ?? 0}
                </button>
              ))}
            </div>
          )}

          <div ref={listRef} className="flex flex-wrap items-baseline gap-2 px-1 pb-1.5">
            <span className="text-[12px] font-semibold">{results.length} 个结果</span>
            {filters.query && <span className="text-[11.5px] text-subtle">关键词“{filters.query}”</span>}
            {activeTypeLabel && (
              <span className="text-[11.5px] text-subtle" data-testid="monster-type-filter">
                类别“{activeTypeLabel}”
                {activeSubtypeLabel ? ` / “${activeSubtypeLabel}”` : ''}
              </span>
            )}
            {missingSelection && (
              <span className="text-[11.5px] text-amber-600 dark:text-amber-400">
                未找到怪物 <code className="rounded bg-chip px-1">{missingSelection}</code>
                （可能是抽象模板或链接有误）
              </span>
            )}
          </div>

          {results.length ? (
            // One card per row while the skill panel squeezes the list; two as
            // soon as the list itself is wide enough for them.
            <div className={`grid gap-2 ${selectedTalent ? '@min-[560px]:grid-cols-2' : 'sm:grid-cols-2'}`}>
              {results.map((monster) => (
                <MonsterCard
                  key={monster.id}
                  monster={monster}
                  terms={terms}
                  selected={monster.id === selectedId}
                  onSelect={() => selectMonster(monster)}
                />
              ))}
            </div>
          ) : (
            <p className="panel px-4 py-8 text-center text-[13px] text-subtle">
              没有匹配的怪物。试试清除关键词或切换分类。
            </p>
          )}
        </main>

        {selected && (
          // While the skill column is open the monster column hands 20px back
          // to the list — the difference between "three panes fit at 1280px"
          // and "the list collapses to a sliver".
          <div className={`hidden shrink-0 xl:block ${selectedTalent ? 'w-[340px]' : 'w-[360px]'}`}>
            <div className="sticky top-[calc(var(--header-h)+2px)] h-[calc(100vh-var(--header-h)-12px)]">
              <MonsterDetail
                monster={selected}
                talentOf={talentOf}
                terms={terms}
                onClose={() => {
                  setSelectedId(null);
                  setSelectedTalentId(null);
                }}
                onSelectTalent={selectTalent}
                selectedTalentId={selectedTalentId}
              />
            </div>
          </div>
        )}

        {/* From `xl` up the talent opens in its own column beside the monster
            instead of replacing it — the monster's skill list stays visible, so
            comparing its skills does not need a round trip through the search
            page. This used to need 1800px; the list giving up its second column
            (and the narrower panels above) is what pays for it. */}
        {selected && selectedTalent && (
          <div className="animate-fade-in hidden w-[340px] shrink-0 xl:block" data-testid="monster-talent-column">
            <div className="sticky top-[calc(var(--header-h)+2px)] h-[calc(100vh-var(--header-h)-12px)]">
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
          </div>
        )}
      </div>

      {/*
        Below `xl` both details are bottom sheets, and they share one slot. While
        a talent is open the monster sheet is therefore not rendered at all —
        toggling a `hidden` class instead would lose to `xl:hidden` on
        specificity and leave the monster sheet permanently hidden after the
        talent closed.
      */}
      {selected && !(narrowViewport && selectedTalent) && (
        // A bottom sheet must be a bounded *flex column* (`flex min-h-0
        // flex-col` + `overflow-hidden`), not just a `max-h` box: the panel
        // inside has to be shrunk to the sheet height so its own body becomes
        // the scroll container. With only `max-h` the panel grows to its content
        // and is clipped — the sheet looks unscrollable and a drag scrolls the
        // list behind it (see docs/HANDOVER.md §0.6).
        <div className="fixed inset-x-0 bottom-0 z-40 flex max-h-[75vh] flex-col xl:hidden" data-testid="monster-detail-sheet">
          <div className="animate-fade-in mx-2 mb-2 flex max-h-[75vh] min-h-0 flex-col overflow-hidden">
            <MonsterDetail
              monster={selected}
              talentOf={talentOf}
              terms={terms}
              onClose={() => {
                setSelectedId(null);
                setSelectedTalentId(null);
              }}
              onSelectTalent={selectTalent}
              selectedTalentId={selectedTalentId}
              compact
            />
          </div>
        </div>
      )}

      {selected && selectedTalent && (
        <div className="fixed inset-x-0 bottom-0 z-50 flex max-h-[85vh] flex-col xl:hidden" data-testid="monster-talent-sheet">
          <div className="animate-fade-in mx-2 mb-2 flex max-h-[85vh] min-h-0 flex-col overflow-hidden">
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
              closeLabel={narrowViewport ? '返回怪物' : '关闭'}
            />
          </div>
        </div>
      )}
    </div>
  );
}

function CategoryRow({
  label,
  count,
  active,
  onClick,
}: {
  label: string;
  count: number;
  active: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={active}
      className={`flex w-full items-center justify-between gap-2 px-2.5 py-1.5 text-left text-[12.5px] hover:bg-hover ${
        active ? 'bg-accent-soft font-semibold text-accent-strong' : ''
      }`}
    >
      <span className="truncate">{label}</span>
      <span className="shrink-0 text-[11px] font-normal text-subtle">{count}</span>
    </button>
  );
}

function MonsterCard({
  monster,
  terms,
  selected,
  onSelect,
}: {
  monster: Monster;
  terms: string[];
  selected: boolean;
  onSelect: () => void;
}) {
  const display = monsterDisplayName(monster);
  const talentCount = monster.talents.length;
  const randomCount = monster.rngPools.reduce((n, pool) => n + pool.talents.length, 0) + monster.rngSets.reduce((n, set) => n + set.length, 0);
  const summary = stripMarkup(monster.descZh ?? monster.desc ?? '').slice(0, 90);

  return (
    <button
      type="button"
      onClick={onSelect}
      aria-pressed={selected}
      className={`panel flex items-start gap-2.5 p-2.5 text-left transition-colors hover:bg-hover ${
        selected ? 'ring-1 ring-accent' : ''
      }`}
    >
      <MonsterArtwork monster={monster} size={56} />
      <span className="min-w-0 flex-1">
        <span className="flex flex-wrap items-baseline gap-x-1.5">
          <span className="text-[13px] font-semibold">
            <Highlight text={display.primary} terms={terms} />
          </span>
          {display.secondary && (
            <span className="truncate text-[11px] text-subtle">
              <Highlight text={display.secondary} terms={terms} />
            </span>
          )}
        </span>
        <span className="mt-1 flex flex-wrap gap-1">
          <CategoryBadge category={monster.category} label={monster.categoryLabel} />
          <TypeChip monster={monster} />
          {talentCount > 0 && <span className="chip" title="固定技能数">技能 {talentCount}</span>}
          {randomCount > 0 && (
            <span className="chip bg-amber-500/15 text-amber-600 dark:text-amber-400" title="互斥随机技能候选数">
              随机 {randomCount}
            </span>
          )}
        </span>
        {summary && <span className="mt-1 line-clamp-2 block text-[11px] leading-snug text-subtle">{summary}…</span>}
      </span>
    </button>
  );
}
