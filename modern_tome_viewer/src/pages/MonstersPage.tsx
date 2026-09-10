import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { stripMarkup } from '../lib/data';
import { useMediaQuery } from '../hooks/useMediaQuery';
import {
  CATEGORY_ORDER,
  filterMonsters,
  loadMonsterData,
  monsterDisplayName,
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
  return {
    query: params.get('q') ?? '',
    category: category && CATEGORY_ORDER.includes(category as MonsterCategory) ? (category as MonsterCategory) : 'all',
    source: source ?? 'all',
    onlyRandomGroups: params.get('rng') === '1',
  };
}

function filtersToParams(filters: MonsterFilters, monsterId: string | null): URLSearchParams {
  const next = new URLSearchParams();
  if (filters.query.trim()) next.set('q', filters.query.trim());
  if (filters.category !== 'all') next.set('cat', filters.category);
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
  //  - `xxl` (1800px) and up: a third column, beside the monster panel;
  //  - below that: an overlay, matched to whichever monster presentation the
  //    viewport uses — a column under `xl`, a bottom sheet below it.
  //
  // Below `xl` the talent sheet takes the same slot as the monster sheet, so the
  // monster sheet is suppressed while a talent is open and its close button
  // reads 返回怪物. That keeps the phone layout to one focused sheet at a time
  // instead of stacking two drawers on top of each other.
  // Only the *bottom sheet* variant needs the JS answer; the side columns stay
  // CSS-driven (`xl:block` / `xxl:block`). `fallback: true` means an environment
  // without `matchMedia` keeps the desktop layout rather than losing a panel.
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
  const publishedHash = useRef('');
  const adoptedHash = useRef('');
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
    if (next === publishedHash.current || next === adoptedHash.current) return;
    publishedHash.current = next;
    onParamsChange(new URLSearchParams(next));
  }, [filters, selectedId, onParamsChange]);

  const results = useMemo(() => (monsterData ? filterMonsters(monsterData, filters) : []), [monsterData, filters]);
  const terms = useMemo(() => termsOf(filters.query), [filters.query]);
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
        </p>
        <p className="mt-0.5 text-[10.5px] text-subtle">
          口径：源码 {census.templates} 个 newEntity 模板中，{census.abstract} 个是只用于继承的抽象 BASE 模板，其余{' '}
          {census.concrete} 个带名称的实体计入图鉴；rank ≥ 3.5 的固定 Boss {census.fixedBosses} 个，其中{' '}
          {census.randomBossCapable} 个会在更高难度下被追加随机职业（其余 {census.noDifficultyRandomClass}{' '}
          个用 no_difficulty_random_class 关闭）。同一模板被多个区域引用只计一次。
        </p>
      </div>

      <div className="flex gap-3">
        <aside className="hidden w-[210px] shrink-0 lg:block">
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

        <main className="min-w-0 flex-1">
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
            {missingSelection && (
              <span className="text-[11.5px] text-amber-600 dark:text-amber-400">
                未找到怪物 <code className="rounded bg-chip px-1">{missingSelection}</code>
                （可能是抽象模板或链接有误）
              </span>
            )}
          </div>

          {results.length ? (
            <div className="grid gap-2 sm:grid-cols-2">
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
          <div className="hidden w-[360px] shrink-0 xl:block">
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

        {/* When the viewport can hold it, the talent opens in its own column
            beside the monster instead of replacing it — the monster's skill
            list stays visible, so comparing its skills does not need a round
            trip through the search page. */}
        {selected && selectedTalent && (
          <div className="animate-fade-in hidden w-[360px] shrink-0 xxl:block" data-testid="monster-talent-column">
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
        <div className="fixed inset-x-0 bottom-0 z-40 max-h-[75vh] xl:hidden" data-testid="monster-detail-sheet">
          <div className="animate-fade-in mx-2 mb-2 max-h-[75vh] overflow-hidden">
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
        <div className="fixed inset-x-0 bottom-0 z-50 max-h-[85vh] xxl:hidden" data-testid="monster-talent-sheet">
          <div className="animate-fade-in mx-2 mb-2 max-h-[85vh] overflow-hidden">
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
