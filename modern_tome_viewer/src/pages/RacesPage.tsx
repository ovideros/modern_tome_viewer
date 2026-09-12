import { useEffect, useMemo, useState } from 'react';
import type { LoadedData } from '../lib/data';
import { writeHash } from '../lib/filters';
import type { SubraceMeta, Talent, TalentEntry } from '../lib/types';
import { GameText } from '../components/Highlight';
import { PortraitStrip, StatChips, TalentTreePanel } from '../components/ClassBits';
import { MobileBrowsePicker } from '../components/MobileBrowsePicker';
import { MobileSheet } from '../components/MobileSheet';
import { TalentDetail } from '../components/TalentDetail';

interface RacesPageProps {
  data: LoadedData;
  params: URLSearchParams;
  onParamsChange: (params: URLSearchParams) => void;
  onOpenTree: (treeId: string) => void;
  onSearchRace: (treeIds: string[]) => void;
  onOpenTalent: (talent: Talent) => void;
}

export function RacesPage({
  data,
  params,
  onParamsChange,
  onOpenTree,
  onSearchRace,
  onOpenTalent,
}: RacesPageProps) {
  const { races } = data.meta;
  const initial = params.get('race') ?? races[0]?.id ?? '';
  const [raceId, setRaceId] = useState(initial);
  const [filter, setFilter] = useState('');
  const [selected, setSelected] = useState<{ talent: Talent; treeName: string; mastery: number } | null>(null);
  const [showPicker, setShowPicker] = useState(false);

  useEffect(() => {
    const fromHash = params.get('race');
    if (fromHash && races.some((r) => r.id === fromHash) && fromHash !== raceId) setRaceId(fromHash);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [params.get('race')]);

  const selectRace = (id: string) => {
    setRaceId(id);
    setSelected(null);
    window.scrollTo({ top: 0, behavior: 'auto' });
    const next = new URLSearchParams(params);
    next.set('race', id);
    onParamsChange(next);
    writeHash('races', next);
  };

  const visible = useMemo(() => {
    const needle = filter.trim().toLowerCase();
    if (!needle) return races;
    return races
      .map((race) => {
        const matchesRace = `${race.name} ${race.englishName} ${race.plainDescription}`.toLowerCase().includes(needle);
        const subraces = race.subraces.filter((sub) =>
          `${sub.name} ${sub.englishName} ${sub.plainDescription}`.toLowerCase().includes(needle),
        );
        if (matchesRace) return race;
        if (subraces.length) return { ...race, subraces };
        return null;
      })
      .filter((race): race is (typeof races)[number] => Boolean(race));
  }, [races, filter]);

  const race = races.find((r) => r.id === raceId) ?? races[0];
  const pickerGroups = useMemo(
    () =>
      visible.map((item) => ({
        id: item.id,
        name: item.name,
        childCount: item.subraces.length,
        children: item.subraces.map((sub) => ({ id: sub.id, name: sub.name })),
      })),
    [visible],
  );
  // Every race talent tree lives under the "race/" category.
  const raceTreeIds = useMemo(
    () => data.trees.filter((tree) => tree.category === 'race').map((tree) => tree.id),
    [data.trees],
  );

  return (
    <div className="mx-auto max-w-[1600px] px-4 py-3">
      <div className="mb-3 flex items-center gap-2 lg:hidden">
        <MobileBrowsePicker
          title="种族"
          childLabel="亚种"
          currentName={race?.name ?? '—'}
          filter={filter}
          onFilterChange={setFilter}
          groups={pickerGroups}
          selectedId={race?.id}
          onSelect={selectRace}
          onSelectChild={scrollToSubrace}
          open={showPicker}
          onOpenChange={setShowPicker}
          emptyLabel="没有匹配的种族"
        />
      </div>
      <div className="flex gap-3">
        <aside className="hidden w-[220px] shrink-0 lg:block">
          <div className="panel sticky top-[calc(var(--header-h)+2px)] flex h-[calc(100vh-var(--header-h)-12px)] flex-col overflow-hidden">
            <div className="border-b border-line p-2.5">
              <input
                className="input"
                placeholder="筛选种族 / 亚种…"
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
              />
            </div>
            <div className="min-h-0 flex-1 overflow-y-auto py-1">
              {visible.map((item) => (
                <div key={item.id}>
                  <button
                    type="button"
                    onClick={() => selectRace(item.id)}
                    className={`flex w-full items-center justify-between gap-2 px-2.5 py-1.5 text-left text-[12.5px] font-semibold hover:bg-hover ${
                      item.id === race?.id ? 'bg-accent-soft text-accent-strong' : ''
                    }`}
                  >
                    <span className="truncate">{item.name}</span>
                    <span className="shrink-0 text-[11px] font-normal text-subtle">{item.subraces.length}</span>
                  </button>
                  {item.id === race?.id &&
                    item.subraces.map((sub) => (
                      <button
                        key={sub.id}
                        type="button"
                        onClick={() => scrollToSubrace(sub.id)}
                        className="block w-full truncate py-1 pl-6 pr-2 text-left text-[12px] text-muted hover:bg-hover hover:text-fg"
                      >
                        {sub.name}
                      </button>
                    ))}
                </div>
              ))}
              {!visible.length && <p className="px-2.5 py-4 text-[12px] text-subtle">没有匹配的种族</p>}
            </div>
          </div>
        </aside>

        <main className="min-w-0 flex-1 space-y-3">
          {race ? (
            <>
              <div className="panel flex items-start gap-3 px-4 py-3">
                <PortraitStrip images={race.subraces[0]?.images ?? []} alt={race.name} />
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-baseline gap-x-2">
                    <h1 className="text-[18px] font-bold">{race.name}</h1>
                    <span className="text-[11.5px] text-subtle">{race.englishName}</span>
                    <span className="chip">{race.subraces.length} 个亚种</span>
                  </div>
                  {race.description && <GameText html={race.description} className="mt-1.5" />}
                  <button type="button" className="btn mt-2" onClick={() => onSearchRace(raceTreeIds)}>
                    在搜索中按种族技能筛选
                  </button>
                </div>
              </div>

              {race.subraces.map((sub) => (
                <SubraceCard
                  key={sub.id}
                  sub={sub}
                  data={data}
                  onOpenTree={onOpenTree}
                  onSelectTalent={(talent, treeName, mastery) => setSelected({ talent, treeName, mastery })}
                />
              ))}
            </>
          ) : (
            <p className="panel px-4 py-8 text-center text-[13px] text-subtle">没有种族数据。</p>
          )}
        </main>

        {selected && (
          <div className="animate-fade-in hidden w-[340px] shrink-0 xl:block">
            <div className="sticky top-[calc(var(--header-h)+2px)] h-[calc(100vh-var(--header-h)-12px)]">
              <TalentDetail
                talent={asEntry(selected.talent, selected.treeName)}
                tree={data.byTree.get(selected.talent.tree)}
                meta={data.meta}
                terms={[]}
                onClose={() => setSelected(null)}
                onJumpToTree={() => undefined}
                onAddFlag={() => undefined}
                onSelectClass={() => undefined}
                favorite={false}
                onToggleFavorite={() => undefined}
                inCompare={false}
                onToggleCompare={() => onOpenTalent(selected.talent)}
                compareFull={false}
                mastery={selected.mastery}
                compact
              />
            </div>
          </div>
        )}
      </div>

      {selected && (
        <MobileSheet onClose={() => setSelected(null)} testId="race-talent-sheet">
          <TalentDetail
            talent={asEntry(selected.talent, selected.treeName)}
            tree={data.byTree.get(selected.talent.tree)}
            meta={data.meta}
            terms={[]}
            onClose={() => setSelected(null)}
            onJumpToTree={() => undefined}
            onAddFlag={() => undefined}
            onSelectClass={() => undefined}
            favorite={false}
            onToggleFavorite={() => undefined}
            inCompare={false}
            onToggleCompare={() => onOpenTalent(selected.talent)}
            compareFull={false}
            mastery={selected.mastery}
            compact
          />
        </MobileSheet>
      )}
    </div>
  );
}

function SubraceCard({
  sub,
  data,
  onOpenTree,
  onSelectTalent,
}: {
  sub: SubraceMeta;
  data: LoadedData;
  onOpenTree: (treeId: string) => void;
  onSelectTalent: (talent: Talent, treeName: string, mastery: number) => void;
}) {
  // Some subraces have no talents_types in the export; fall back to race/<id>.
  const trees = useMemo(() => {
    if (sub.trees.length) return sub.trees;
    const guessed = data.byTree.get(`race/${sub.id.toLowerCase()}`);
    if (!guessed) return [];
    return [{ id: guessed.id, name: guessed.plainName, mastery: 1, unlocked: true, talentCount: guessed.talentCount }];
  }, [sub, data.byTree]);

  return (
    <section id={`subrace-${sub.id}`} className="panel px-3 py-3">
      <div className="flex items-start gap-3">
        <PortraitStrip images={sub.images} alt={sub.name} />
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-baseline gap-x-2">
            <h2 className="text-[15px] font-semibold">{sub.name}</h2>
            <span className="text-[11.5px] text-subtle">{sub.englishName}</span>
            {sub.lifeRating !== null && <span className="chip">基础生命 {sub.lifeRating}</span>}
            {sub.experience !== null && <span className="chip">经验修正 {sub.experience}%</span>}
            {sub.size && <span className="chip">体型 {sub.size}</span>}
          </div>

          <div className="mt-1.5">
            <StatChips stats={sub.stats} />
          </div>
        </div>
      </div>

      {sub.description && <GameText html={sub.description} className="mt-2" />}

      {trees.length ? (
        <div className="mt-3 grid gap-2 lg:grid-cols-2">
          {trees.map((treeRef) => (
            <TalentTreePanel
              key={treeRef.id}
              treeRef={treeRef}
              tree={data.byTree.get(treeRef.id)}
              onSelectTalent={onSelectTalent}
              onOpenTree={onOpenTree}
            />
          ))}
        </div>
      ) : (
        <p className="mt-2 text-[11.5px] text-subtle">该亚种没有独立种族技能大系</p>
      )}
    </section>
  );
}

/** Keep the subrace heading clear of the sticky header. */
function scrollToSubrace(id: string) {
  const element = document.getElementById(`subrace-${id}`);
  if (!element) return;
  const header = document.querySelector('header');
  const offset = (header?.getBoundingClientRect().height ?? 56) + 10;
  const top = element.getBoundingClientRect().top + window.scrollY - offset;
  window.scrollTo({ top: Math.max(0, top), behavior: 'smooth' });
}

/** Wrap a plain Talent as a TalentEntry for the shared detail panel. */
function asEntry(talent: Talent, treeName: string): TalentEntry {
  return { ...talent, treeName, treePlainName: treeName, category: '', categoryName: '' };
}
