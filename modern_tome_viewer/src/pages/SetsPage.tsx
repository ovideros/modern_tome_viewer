import { useEffect, useMemo, useState } from 'react';
import { ArtifactThumbnail, setBranchLabel, SetEffectList } from '../components/ArtifactSetBits';
import { MobileSheet } from '../components/MobileSheet';
import { navigate } from '../hooks/useHashRoute';
import { loadArtifactData, normalizeSearchText, searchTerms, sourcePath, type Artifact, type ArtifactSet, type LoadedArtifacts } from '../lib/items';
import type { TalentEntry, TalentTree } from '../lib/types';

interface SetsPageProps {
  params: URLSearchParams;
  talentOf: (id: string) => TalentEntry | undefined;
  treeOf: (id: string) => TalentTree | undefined;
  onOpenTalent: (id: string) => void;
  onOpenTree: (id: string) => void;
}

function memberName(artifact: Artifact | undefined, fallback: string) {
  return artifact ? artifact.nameZh ?? artifact.name : fallback;
}

function setSearchText(set: ArtifactSet, loaded: LoadedArtifacts) {
  const members = set.memberIds.map((id) => loaded.byId.get(id));
  return normalizeSearchText([
    set.name,
    ...members.flatMap((member) => [member?.name, member?.nameZh, member?.defineAs]),
    ...set.hints.flatMap((hint) => [hint.en, hint.zh]),
    ...set.branches.flatMap((branch) => [branch.id, ...branch.effects.map((effect) => effect.text)]),
  ].filter(Boolean).join(' '));
}

function SetDetail({
  set,
  loaded,
  onClose,
  onOpenArtifact,
  talentOf,
  treeOf,
  onOpenTalent,
  onOpenTree,
}: {
  set: ArtifactSet;
  loaded: LoadedArtifacts;
  onClose: () => void;
  onOpenArtifact: (id: string) => void;
  talentOf: (id: string) => TalentEntry | undefined;
  treeOf: (id: string) => TalentTree | undefined;
  onOpenTalent: (id: string) => void;
  onOpenTree: (id: string) => void;
}) {
  const members = set.memberIds.map((id) => loaded.byId.get(id));
  const source = sourcePath(loaded.report, set.source.file);
  return (
    <article className="space-y-4" data-testid="set-detail">
      <header>
        <div className="flex items-start justify-between gap-2">
          <div>
            <h2 className="text-[16px] font-semibold">{set.name}</h2>
            <p className="mt-1 text-[12px] text-muted">固定神器套装 · {set.memberIds.length} 件成员</p>
          </div>
          <button type="button" className="btn btn-ghost px-2 py-0.5" onClick={onClose}>关闭</button>
        </div>
      </header>

      <section>
        <h3 className="mb-1.5 text-[13px] font-semibold">套装成员</h3>
        <div className="space-y-1.5">
          {members.map((artifact, index) => (
            <button
              key={artifact?.id ?? set.memberIds[index]}
              type="button"
              className="flex w-full items-center gap-2.5 rounded-lg border border-line bg-surface-raised/60 px-2.5 py-2 text-left hover:bg-hover"
              onClick={() => onOpenArtifact(set.memberIds[index])}
            >
              {artifact && <ArtifactThumbnail artifact={artifact} size={42} />}
              <span className="min-w-0 truncate text-[12.5px] font-medium">
                {memberName(artifact, set.memberIds[index])}
              </span>
              <span className="ml-auto shrink-0 text-[10.5px] text-subtle">查看神器</span>
            </button>
          ))}
        </div>
      </section>

      <section>
        <h3 className="mb-1.5 text-[13px] font-semibold">套装效果</h3>
        <div className="space-y-3">
          {set.branches.map((branch) => (
            <div key={branch.id} className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5">
              {branch.id !== 'complete' && <h4 className="mb-1 text-[12.5px] font-semibold">分支：{setBranchLabel(branch.id)}</h4>}
              <SetEffectList
                branch={branch}
                dataset={loaded.dataset}
                talentOf={talentOf}
                treeOf={treeOf}
                onOpenTalent={onOpenTalent}
                onOpenTree={onOpenTree}
              />
            </div>
          ))}
        </div>
      </section>

      {set.hints.length > 0 && (
        <section className="rounded-lg border border-line bg-surface-raised/60 px-3 py-2.5">
          <h3 className="mb-1.5 text-[13px] font-semibold">游戏内提示</h3>
          <ul className="space-y-1 text-[12px] text-muted">
            {set.hints.map((hint) => (
              <li key={`${hint.memberId}-${hint.en}`}>{hint.zh ?? hint.en}</li>
            ))}
          </ul>
        </section>
      )}

      <p className="text-[11px] text-subtle">
        套装关系与效果均来自源码；标记为运行时机制的内容会随角色、目标或战斗过程变化。
        {source && <> 来源：{source}:{set.source.line}</>}
      </p>
    </article>
  );
}

export function SetsPage({ params, talentOf, treeOf, onOpenTalent, onOpenTree }: SetsPageProps) {
  const [loaded, setLoaded] = useState<LoadedArtifacts | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let alive = true;
    loadArtifactData()
      .then((next) => alive && setLoaded(next))
      .catch((err: unknown) => alive && setError(err instanceof Error ? err.message : String(err)));
    return () => { alive = false; };
  }, []);

  const query = params.get('q') ?? '';
  const selectedId = params.get('set');
  const selected = selectedId && loaded ? loaded.bySetId.get(selectedId) ?? null : null;
  const results = useMemo(() => {
    if (!loaded) return [];
    const terms = searchTerms(query);
    return loaded.dataset.sets
      .filter((set) => {
        const haystack = setSearchText(set, loaded);
        return terms.every((term) => haystack.includes(term));
      })
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [loaded, query]);

  const updateQuery = (value: string) => {
    const next = new URLSearchParams(params);
    if (value.trim()) next.set('q', value.trim());
    else next.delete('q');
    navigate('sets', next);
  };
  const selectSet = (id: string | null) => {
    const next = new URLSearchParams(params);
    if (id) next.set('set', id);
    else next.delete('set');
    navigate('sets', next);
  };

  if (error) {
    return (
      <div className="panel mx-auto mt-12 max-w-lg px-6 py-8 text-center">
        <h2 className="mb-2 text-[15px] font-semibold">套装数据加载失败</h2>
        <p className="text-[12.5px] text-muted">{error}</p>
      </div>
    );
  }
  if (!loaded) {
    return <div className="flex min-h-[50vh] items-center justify-center text-[13px] text-subtle">正在加载套装数据…</div>;
  }

  return (
    <div className="mx-auto max-w-[1600px] px-4 py-4">
      <header className="mb-3">
        <h1 className="text-[18px] font-semibold">固定神器套装</h1>
        <p className="mt-0.5 text-[12.5px] text-muted">
          共 <span className="font-semibold tabular-nums">{loaded.dataset.sets.length}</span> 套，成员可跳转到固定神器页面；静态数值与运行时机制分开标注。
        </p>
      </header>

      <div className="mb-3 max-w-xl">
        <label className="mb-1 block text-[12.5px] font-semibold" htmlFor="set-query">搜索套装</label>
        <input
          id="set-query"
          className="input"
          placeholder="套装名 / 成员 / 效果"
          value={query}
          onChange={(event) => updateQuery(event.target.value)}
        />
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-[minmax(0,1fr)_28rem]">
        <main className="min-w-0">
          <p className="mb-2 text-[11.5px] text-muted">匹配 {results.length} 套</p>
          {results.length ? (
            <ul className="grid grid-cols-1 gap-1.5 md:grid-cols-2 2xl:grid-cols-3">
              {results.map((set) => (
                <li key={set.id}>
                  <button
                    type="button"
                    className={`w-full rounded-lg border px-3 py-2.5 text-left ${selected?.id === set.id ? 'border-accent bg-accent-soft' : 'border-line bg-surface hover:bg-hover'}`}
                    aria-pressed={selected?.id === set.id}
                    onClick={() => selectSet(set.id)}
                  >
                    <span className="block truncate text-[13px] font-medium">{set.name}</span>
                    <span className="mt-2 flex flex-wrap gap-1.5">
                      {set.memberIds.map((memberId) => {
                        const member = loaded.byId.get(memberId);
                        return member ? (
                          <span key={memberId} title={memberName(member, memberId)}>
                            <ArtifactThumbnail artifact={member} size={38} />
                          </span>
                        ) : null;
                      })}
                    </span>
                    <span className="mt-1 flex flex-wrap gap-1">
                      <span className="chip">{set.memberIds.length} 件</span>
                      {set.branches.length > 1 && <span className="chip">{set.branches.length} 个效果分支</span>}
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          ) : (
            <div className="panel px-4 py-8 text-center text-[13px] text-subtle">没有匹配的套装。</div>
          )}
        </main>

        <aside className="hidden min-w-0 lg:block" aria-hidden={!selected}>
          {selected && (
            <div className="panel sticky top-[calc(var(--header-h)+2px)] max-h-[calc(100vh-var(--header-h)-12px)] overflow-y-auto p-3">
              <SetDetail
                set={selected}
                loaded={loaded}
                onClose={() => selectSet(null)}
                onOpenArtifact={(id) => navigate('artifacts', { a: id })}
                talentOf={talentOf}
                treeOf={treeOf}
                onOpenTalent={onOpenTalent}
                onOpenTree={onOpenTree}
              />
            </div>
          )}
        </aside>
      </div>

      {selected && (
        <MobileSheet onClose={() => selectSet(null)} breakpoint="lg" testId="set-detail-sheet" ariaLabel="套装详情">
          <div className="panel flex min-h-0 flex-1 flex-col overflow-hidden p-3">
            <div className="min-h-0 flex-1 overflow-y-auto overscroll-contain">
              <SetDetail
                set={selected}
                loaded={loaded}
                onClose={() => selectSet(null)}
                onOpenArtifact={(id) => navigate('artifacts', { a: id })}
                talentOf={talentOf}
                treeOf={treeOf}
                onOpenTalent={onOpenTalent}
                onOpenTree={onOpenTree}
              />
            </div>
          </div>
        </MobileSheet>
      )}
    </div>
  );
}
