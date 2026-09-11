import { useCallback, useState } from 'react';
import { CompareBar } from './components/CompareBar';
import { Header } from './components/Header';
import { useDataset } from './hooks/useDataset';
import { useHeaderHeight } from './hooks/useHeaderHeight';
import { useHashRoute, navigate } from './hooks/useHashRoute';
import { COMPARE_KEY, COMPARE_LIMIT, FAVORITES_KEY, useIdList } from './hooks/useIdList';
import { useTheme } from './hooks/useTheme';
import { emptyFilters, filtersToParams } from './lib/filters';
import { ClassesPage } from './pages/ClassesPage';
import { ComparePage } from './pages/ComparePage';
import { FavoritesPage } from './pages/FavoritesPage';
import { ArtifactsPage } from './pages/ArtifactsPage';
import { EgosPage } from './pages/EgosPage';
import { MonstersPage } from './pages/MonstersPage';
import { RacesPage } from './pages/RacesPage';
import { SearchPage } from './pages/SearchPage';
import type { Talent, TalentEntry } from './lib/types';

const ROUTES = ['search', 'classes', 'races', 'monsters', 'egos', 'artifacts', 'favorites', 'compare'] as const;
type RouteName = (typeof ROUTES)[number];

function Loading({ progress, building }: { progress: number; building: boolean }) {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center gap-3">
      <p className="text-[14px] font-semibold">{building ? '正在建立搜索索引…' : '正在加载技能数据…'}</p>
      <div className="h-1.5 w-64 overflow-hidden rounded-full bg-chip">
        <div className="h-full rounded-full bg-accent transition-all" style={{ width: `${progress}%` }} />
      </div>
      <p className="text-[11.5px] text-subtle">首次加载需要读取约 2.6 MB 数据</p>
    </div>
  );
}

function ErrorState({ message }: { message: string }) {
  return (
    <div className="panel mx-auto mt-12 max-w-lg px-6 py-8 text-center">
      <h2 className="mb-2 text-[15px] font-semibold">数据加载失败</h2>
      <p className="mb-3 text-[12.5px] text-muted">{message}</p>
      <p className="text-[12px] text-subtle">
        请先运行 <code className="rounded bg-chip px-1">npm run data</code> 生成{' '}
        <code className="rounded bg-chip px-1">public/data/talents.json</code>，或检查是否通过 HTTP 打开页面。
      </p>
    </div>
  );
}

export default function App() {
  const { data, index, error, progress, building } = useDataset();
  const { theme, toggle } = useTheme();
  useHeaderHeight();
  const route = useHashRoute();
  const [params, setParams] = useState<URLSearchParams>(() => route.params);

  const favorites = useIdList(FAVORITES_KEY, data);
  const compare = useIdList(COMPARE_KEY, data, COMPARE_LIMIT);

  // Pages own the hash for their own route; the hook keeps this copy in sync
  // when the user navigates with the browser buttons.
  const updateParams = useCallback((next: URLSearchParams) => {
    setParams(new URLSearchParams(next));
  }, []);

  /** Open a talent's detail panel on the search page. */
  const openTalent = useCallback((talent: Talent | TalentEntry) => {
    const next = filtersToParams(emptyFilters());
    next.set('talent', talent.id);
    navigate('search', next);
  }, []);

  /** Filter the search page down to a single talent tree. */
  const openTree = useCallback((treeId: string) => {
    const next = filtersToParams(emptyFilters());
    next.set('trees', treeId);
    navigate('search', next);
  }, []);

  /** Filter the search page by class. */
  const searchClass = useCallback((classId: string) => {
    const next = filtersToParams(emptyFilters());
    next.set('class', classId);
    navigate('search', next);
  }, []);

  /** Filter the search page down to a set of trees (used for race talents). */
  const searchTrees = useCallback((treeIds: string[]) => {
    const next = filtersToParams(emptyFilters());
    if (treeIds.length) next.set('trees', treeIds.join('\u0001'));
    navigate('search', next);
  }, []);

  const routeName: RouteName = (ROUTES as readonly string[]).includes(route.name)
    ? (route.name as RouteName)
    : 'search';
  const effectiveParams = params.toString() === route.params.toString() ? params : route.params;

  return (
    <div className="min-h-screen pb-20">
      <Header
        route={routeName}
        theme={theme}
        onToggleTheme={toggle}
        manifest={data?.manifest ?? null}
        favoriteCount={favorites.ids.length}
        compareCount={compare.ids.length}
      />

      {error ? (
        <ErrorState message={error} />
      ) : !data ? (
        <Loading progress={progress} building={building} />
      ) : routeName === 'classes' ? (
        <ClassesPage
          data={data}
          params={effectiveParams}
          onParamsChange={updateParams}
          onOpenTree={openTree}
          onSearchClass={searchClass}
          onOpenTalent={openTalent}
        />
      ) : routeName === 'races' ? (
        <RacesPage
          data={data}
          params={effectiveParams}
          onParamsChange={updateParams}
          onOpenTree={openTree}
          onSearchRace={searchTrees}
          onOpenTalent={openTalent}
        />
      ) : routeName === 'monsters' ? (
        <MonstersPage
          data={data}
          params={effectiveParams}
          onParamsChange={updateParams}
          favoriteHas={favorites.has}
          onToggleFavorite={favorites.toggle}
          compareHas={compare.has}
          onToggleCompare={compare.toggle}
          compareFull={compare.full}
        />
      ) : routeName === 'egos' ? (
        <EgosPage
          data={data}
          params={effectiveParams}
          onParamsChange={updateParams}
          favoriteHas={favorites.has}
          onToggleFavorite={favorites.toggle}
          compareHas={compare.has}
          onToggleCompare={compare.toggle}
          compareFull={compare.full}
        />
      ) : routeName === 'artifacts' ? (
        <ArtifactsPage
          data={data}
          params={effectiveParams}
          onParamsChange={updateParams}
          favoriteHas={favorites.has}
          onToggleFavorite={favorites.toggle}
          compareHas={compare.has}
          onToggleCompare={compare.toggle}
          compareFull={compare.full}
        />
      ) : routeName === 'favorites' ? (
        <FavoritesPage
          entries={favorites.entries}
          meta={data.meta}
          onRemove={favorites.remove}
          onClear={favorites.clear}
          onOpen={openTalent}
          onCompare={compare.toggle}
          onBack={() => navigate('search')}
          compareHas={compare.has}
        />
      ) : routeName === 'compare' ? (
        <ComparePage
          entries={compare.entries}
          meta={data.meta}
          onRemove={compare.remove}
          onClear={compare.clear}
          onBack={() => navigate('search')}
        />
      ) : (
        <SearchPage
          data={data}
          index={index}
          building={building}
          params={effectiveParams}
          onParamsChange={updateParams}
          favoriteHas={favorites.has}
          onToggleFavorite={favorites.toggle}
          compareHas={compare.has}
          onToggleCompare={compare.toggle}
          compareFull={compare.full}
        />
      )}

      {routeName !== 'compare' && (
        <CompareBar
          entries={compare.entries}
          onRemove={compare.remove}
          onClear={compare.clear}
          onOpen={() => navigate('compare')}
          limitReached={compare.limitReached}
        />
      )}

      <footer className="mx-auto max-w-[1600px] px-4 py-6 text-center text-[11px] text-subtle">
        数据来自 Tales of Maj'Eyal / tometips 导出，游戏版本 {data?.manifest.gameVersion ?? '—'} · 构建{' '}
        {data?.manifest.builtAt?.slice(0, 10) ?? '—'} · 共 {data?.manifest.counts.talents ?? 0} 个技能、
        {data?.manifest.counts.trees ?? 0} 个技能大系
      </footer>
    </div>
  );
}
