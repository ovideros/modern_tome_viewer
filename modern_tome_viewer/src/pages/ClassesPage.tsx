import { useEffect, useMemo, useState } from 'react';
import type { LoadedData } from '../lib/data';
import { writeHash } from '../lib/filters';
import type { SubclassMeta, Talent, TalentEntry, TreeRef } from '../lib/types';
import { GameText } from '../components/Highlight';
import { PortraitStrip, StatChips, TalentTreePanel } from '../components/ClassBits';
import { MobileBrowsePicker } from '../components/MobileBrowsePicker';
import { MobileSheet } from '../components/MobileSheet';
import { TalentDetail } from '../components/TalentDetail';

interface ClassesPageProps {
  data: LoadedData;
  params: URLSearchParams;
  onParamsChange: (params: URLSearchParams) => void;
  onOpenTree: (treeId: string) => void;
  onSearchClass: (classId: string) => void;
  onOpenTalent: (talent: Talent) => void;
}

export function ClassesPage({
  data,
  params,
  onParamsChange,
  onOpenTree,
  onSearchClass,
  onOpenTalent,
}: ClassesPageProps) {
  const { classes } = data.meta;
  const initial = params.get('class') ?? classes[0]?.id ?? '';
  const [classId, setClassId] = useState(initial);
  const [filter, setFilter] = useState('');
  const [selected, setSelected] = useState<{ talent: Talent; treeName: string; mastery: number } | null>(null);
  const [showPicker, setShowPicker] = useState(false);

  useEffect(() => {
    const fromHash = params.get('class');
    if (fromHash && classes.some((c) => c.id === fromHash) && fromHash !== classId) setClassId(fromHash);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [params.get('class')]);

  const selectClass = (id: string) => {
    setClassId(id);
    setSelected(null);
    // Switching class must start at the top of the new class.
    window.scrollTo({ top: 0, behavior: 'auto' });
    const next = new URLSearchParams(params);
    next.set('class', id);
    next.delete('sub');
    onParamsChange(next);
    writeHash('classes', next);
  };

  const visibleClasses = useMemo(() => {
    const needle = filter.trim().toLowerCase();
    if (!needle) return classes;
    return classes
      .map((cls) => {
        const matchesClass = `${cls.name} ${cls.englishName} ${cls.plainDescription}`.toLowerCase().includes(needle);
        const subclasses = cls.subclasses.filter((sub) =>
          `${sub.name} ${sub.englishName} ${sub.plainDescription}`.toLowerCase().includes(needle),
        );
        if (matchesClass) return cls;
        if (subclasses.length) return { ...cls, subclasses };
        return null;
      })
      .filter((cls): cls is (typeof classes)[number] => Boolean(cls));
  }, [classes, filter]);

  const cls = classes.find((c) => c.id === classId) ?? classes[0];
  const pickerGroups = useMemo(
    () =>
      visibleClasses.map((item) => ({
        id: item.id,
        name: item.name,
        childCount: item.subclasses.length,
        children: item.subclasses.map((sub) => ({ id: sub.id, name: sub.name })),
      })),
    [visibleClasses],
  );

  return (
    <div className="mx-auto max-w-[1600px] px-4 py-3">
      <div className="mb-3 flex items-center gap-2 lg:hidden">
        <MobileBrowsePicker
          title="职业"
          currentName={cls?.name ?? '—'}
          filter={filter}
          onFilterChange={setFilter}
          groups={pickerGroups}
          selectedId={cls?.id}
          onSelect={selectClass}
          onSelectChild={scrollToSubclass}
          open={showPicker}
          onOpenChange={setShowPicker}
          emptyLabel="没有匹配的职业"
        />
      </div>
      <div className="flex gap-3">
        <aside className="hidden w-[240px] shrink-0 lg:block">
          <div className="panel sticky top-[calc(var(--header-h)+2px)] flex h-[calc(100vh-var(--header-h)-12px)] flex-col overflow-hidden">
            <div className="border-b border-line p-2.5">
              <input
                className="input"
                placeholder="筛选职业 / 子职业…"
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
              />
            </div>
            <div className="min-h-0 flex-1 overflow-y-auto py-1">
              {visibleClasses.map((item) => (
                <div key={item.id}>
                  <button
                    type="button"
                    onClick={() => selectClass(item.id)}
                    className={`flex w-full items-center justify-between gap-2 px-2.5 py-1.5 text-left text-[12.5px] font-semibold hover:bg-hover ${
                      item.id === cls?.id ? 'bg-accent-soft text-accent-strong' : ''
                    }`}
                  >
                    <span className="truncate">{item.name}</span>
                    <span className="shrink-0 text-[11px] font-normal text-subtle">{item.subclasses.length}</span>
                  </button>
                  {item.id === cls?.id &&
                    item.subclasses.map((sub) => (
                      <button
                        key={sub.id}
                        type="button"
                        onClick={() => scrollToSubclass(sub.id)}
                        className="block w-full truncate py-1 pl-6 pr-2 text-left text-[12px] text-muted hover:bg-hover hover:text-fg"
                      >
                        {sub.name}
                      </button>
                    ))}
                </div>
              ))}
              {!visibleClasses.length && <p className="px-2.5 py-4 text-[12px] text-subtle">没有匹配的职业</p>}
            </div>
          </div>
        </aside>

        <main className="min-w-0 flex-1 space-y-3">
          {cls ? (
            <>
              <div className="panel flex items-start gap-3 px-4 py-3">
                <PortraitStrip images={cls.subclasses[0]?.images ?? []} alt={cls.name} />
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-baseline gap-x-2">
                    <h1 className="text-[18px] font-bold">{cls.name}</h1>
                    <span className="text-[11.5px] text-subtle">{cls.englishName}</span>
                    <span className="chip">{cls.subclasses.length} 个子职业</span>
                  </div>
                  {cls.description && <GameText html={cls.description} className="mt-1.5" />}
                  <button type="button" className="btn mt-2" onClick={() => onSearchClass(cls.id)}>
                    在搜索中按此职业筛选
                  </button>
                </div>
              </div>

              {cls.subclasses.map((sub) => (
                <SubclassCard
                  key={sub.id}
                  sub={sub}
                  data={data}
                  onOpenTree={onOpenTree}
                  onSelectTalent={(talent, treeName, mastery) => setSelected({ talent, treeName, mastery })}
                />
              ))}
            </>
          ) : (
            <p className="panel px-4 py-8 text-center text-[13px] text-subtle">没有职业数据。</p>
          )}
        </main>

        <aside className="hidden w-[340px] shrink-0 xl:block" aria-hidden={!selected}>
          {selected && (
            <div className="animate-fade-in sticky top-[calc(var(--header-h)+2px)] h-[calc(100vh-var(--header-h)-12px)]">
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
          )}
        </aside>
      </div>

      {selected && (
        <MobileSheet onClose={() => setSelected(null)} testId="class-talent-sheet">
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

function SubclassCard({
  sub,
  data,
  onOpenTree,
  onSelectTalent,
}: {
  sub: SubclassMeta;
  data: LoadedData;
  onOpenTree: (treeId: string) => void;
  onSelectTalent: (talent: Talent, treeName: string, mastery: number) => void;
}) {
  const starting = sub.startingTalents
    .map((id) => data.byId.get(id))
    .filter((talent): talent is TalentEntry => Boolean(talent));

  const trees = [...sub.classTrees, ...sub.genericTrees];
  const unlockedCount = trees.filter((tree) => tree.unlocked).length;

  return (
    <section id={`subclass-${sub.id}`} className="panel px-3 py-3">
      <div className="flex items-start gap-3">
        <PortraitStrip images={sub.images} alt={sub.name} />
        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-baseline gap-x-2">
            <h2 className="text-[15px] font-semibold">{sub.name}</h2>
            <span className="text-[11.5px] text-subtle">{sub.englishName}</span>
            {sub.lifeRating !== null && <span className="chip">每级生命 +{sub.lifeRating}</span>}
            {sub.extraTalentPoints ? <span className="chip">额外职业技能点 {sub.extraTalentPoints}</span> : null}
            {sub.extraGenericPoints ? <span className="chip">额外通用技能点 {sub.extraGenericPoints}</span> : null}
            {sub.extraTreePoints ? <span className="chip">额外技能点 {sub.extraTreePoints}</span> : null}
            <span className="chip" title="未解锁的大系需要投入大系点">
              {unlockedCount}/{trees.length} 个大系已解锁
            </span>
          </div>

          <div className="mt-1.5 mb-1.5">
            <StatChips stats={sub.stats} />
          </div>

          {starting.length > 0 && (
            <div className="flex flex-wrap items-center gap-1">
              <span className="text-[11.5px] text-subtle">初始技能</span>
              {starting.map((talent) => (
                <span key={talent.id} className="chip" title={`${talent.treePlainName} · ${talent.id}`}>
                  {talent.plainName}
                </span>
              ))}
            </div>
          )}
        </div>
      </div>

      {sub.description && <GameText html={sub.description} className="mt-2" />}

      <div className="mt-3 grid gap-3 lg:grid-cols-2">
        <TreeGroup
          title="职业技能"
          trees={sub.classTrees}
          data={data}
          onOpenTree={onOpenTree}
          onSelectTalent={onSelectTalent}
        />
        <TreeGroup
          title="通用技能"
          trees={sub.genericTrees}
          data={data}
          onOpenTree={onOpenTree}
          onSelectTalent={onSelectTalent}
        />
      </div>
    </section>
  );
}

/** One column of talent trees under a shared heading. */
function TreeGroup({
  title,
  trees,
  data,
  onOpenTree,
  onSelectTalent,
}: {
  title: string;
  trees: TreeRef[];
  data: LoadedData;
  onOpenTree: (treeId: string) => void;
  onSelectTalent: (talent: Talent, treeName: string, mastery: number) => void;
}) {
  if (!trees.length) return null;
  return (
    <div className="space-y-2">
      <h3 className="text-[12px] font-semibold text-muted">
        {title}
        <span className="ml-1.5 font-normal text-subtle">{trees.length}</span>
      </h3>
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
  );
}

/**
 * Scroll a subclass card to just below the sticky header and search chrome,
 * otherwise the card title ends up hidden underneath it.
 */
function scrollToSubclass(id: string) {
  const element = document.getElementById(`subclass-${id}`);
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
