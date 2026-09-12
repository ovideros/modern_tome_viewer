/**
 * Fixed artifact encyclopedia (`#/artifacts`).
 *
 * Layout is coordinated with the monster encyclopedia on purpose — filter rail,
 * icon list, detail panel — because an artifact is also recognised by its icon.
 * Unlike monsters the icons are 64×64 item sprites, so the list renders them at
 * native size instead of scaling them up and blurring pixel art.
 *
 * The list defaults to player-equippable artifacts. Non-equipment fixed
 * artifacts (gems, scrolls, potions) stay in the data with an explicit status
 * and have their own filter rather than being dropped silently; the coverage
 * report lists what was excluded and why.
 */

import { useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { Highlight } from '../components/Highlight';
import { ArtifactDetail } from '../components/ArtifactDetail';
import { TalentDetail } from '../components/TalentDetail';
import { MobileSheet } from '../components/MobileSheet';
import { navigate } from '../hooks/useHashRoute';
import { makeCodeLabeler } from '../lib/item-labels';
import { writeHash } from '../lib/filters';
import {
  loadArtifactData,
  searchTerms,
  type Artifact,
  type LoadedArtifacts,
} from '../lib/items';
import { assetUrl } from '../lib/data';
import type { LoadedData } from '../lib/data';
import type { TalentEntry } from '../lib/types';

interface ArtifactsPageProps {
  data: LoadedData;
  params: URLSearchParams;
  onParamsChange: (params: URLSearchParams) => void;
  favoriteHas: (id: string) => boolean;
  onToggleFavorite: (id: string) => void;
  compareHas: (id: string) => boolean;
  onToggleCompare: (id: string) => void;
  compareFull: boolean;
  onOpenTalent: (id: string) => void;
}

/**
 * Every facet is a list of toggles, and the two collection tags are
 * **independent**, not a radio pair.
 *
 * "可装备" is on by default. Turning it off and turning "非装备" on shows only
 * non-equipment artifacts; having both on shows everything. The earlier
 * either/or control could not express "show me everything", which is a
 * perfectly reasonable thing to ask of a filtered list.
 */
interface ArtifactFilters {
  query: string;
  types: string[];
  tiers: string[];
  sources: string[];
  scope: {
    equipment: boolean;
    nonEquipment: boolean;
  };
}

const EMPTY_FILTERS: ArtifactFilters = {
  query: '',
  types: [],
  tiers: [],
  sources: [],
  scope: { equipment: true, nonEquipment: false },
};

/** Read a comma-separated multi-value facet. */
function readList(params: URLSearchParams, key: string): string[] {
  const raw = params.get(key);
  if (!raw) return [];
  return raw.split(',').map((part) => part.trim()).filter(Boolean);
}

function paramsToFilters(params: URLSearchParams): ArtifactFilters {
  const scope = params.get('scope');
  return {
    query: params.get('q') ?? '',
    types: readList(params, 'type'),
    tiers: readList(params, 'tier'),
    sources: readList(params, 'src'),
    // `all` used to mean "include non-equipment"; keep reading it so an older
    // shared link still opens the view it described.
    scope: scope === 'all'
      ? { equipment: true, nonEquipment: true }
      : scope === 'non'
        ? { equipment: false, nonEquipment: true }
        : scope === 'none'
          ? { equipment: false, nonEquipment: false }
          : { equipment: true, nonEquipment: false },
  };
}

function filtersToParams(filters: ArtifactFilters, artifactId: string | null): URLSearchParams {
  const next = new URLSearchParams();
  if (filters.query.trim()) next.set('q', filters.query.trim());
  if (filters.types.length) next.set('type', filters.types.join(','));
  if (filters.tiers.length) next.set('tier', filters.tiers.join(','));
  if (filters.sources.length) next.set('src', filters.sources.join(','));
  const { equipment, nonEquipment } = filters.scope;
  // The default (equipment only) is what no parameter means, so a plain link
  // stays short; every other combination is spelled out.
  if (!equipment && nonEquipment) next.set('scope', 'non');
  else if (!equipment && !nonEquipment) next.set('scope', 'none');
  else if (equipment && nonEquipment) next.set('scope', 'all');
  if (artifactId) next.set('a', artifactId);
  return next;
}

/** Toggle one value inside a facet list; an empty list means "no restriction". */
function toggleIn<T extends string>(list: T[], value: T): T[] {
  return list.includes(value) ? list.filter((item) => item !== value) : [...list, value];
}

/**
 * Collapsible filter section, matching the advanced-search panel.
 *
 * `defaultOpen` is set on the facets a reader reaches for first, so the common
 * path is one click instead of two.
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
}: {
  label: string;
  count?: number;
  pressed: boolean;
  onClick: () => void;
  title?: string;
}) {
  return (
    <button type="button" className="btn px-1.5 py-0.5 text-[11px]" aria-pressed={pressed} onClick={onClick} title={title}>
      {label}
      {count !== undefined && <span className="text-[10px] opacity-60">{count}</span>}
    </button>
  );
}

function filterArtifacts(loaded: LoadedArtifacts, filters: ArtifactFilters): Artifact[] {
  const terms = searchTerms(filters.query);
  const { equipment, nonEquipment } = filters.scope;
  const out: Artifact[] = [];
  for (const artifact of loaded.dataset.artifacts) {
    const isEquipment = artifact.status === 'included';
    // Within the scope facet the two tags are alternatives; with both on the
    // facet is unrestricted, and with neither on it matches nothing (which the
    // page explains rather than silently showing everything).
    if (isEquipment && !equipment) continue;
    if (!isEquipment && !nonEquipment) continue;
    if (filters.types.length && !filters.types.includes(artifact.type ?? '')) continue;
    if (filters.tiers.length && !filters.tiers.includes(String(artifact.tier))) continue;
    if (filters.sources.length && !filters.sources.includes(artifact.source)) continue;
    if (terms.length) {
      const text = loaded.haystack.get(artifact.id) ?? '';
      if (!terms.every((term) => text.includes(term))) continue;
    }
    out.push(artifact);
  }
  return out;
}

/** Native-size icon with a category fallback; never upscales the sprite. */
function Icon({ artifact, size = 40 }: { artifact: Artifact; size?: number }) {
  const [failed, setFailed] = useState(false);
  const src = artifact.imagePath ? assetUrl(artifact.imagePath) : null;
  if (!src || failed) {
    return (
      <div
        className="flex shrink-0 items-center justify-center rounded border border-line bg-sunken text-[10px] text-subtle"
        style={{ width: size, height: size }}
        title={artifact.image ? `缺少图标：${artifact.image}` : '该物品没有独立图标文件'}
      >
        {artifact.typeZh ?? artifact.type ?? '?'}
      </div>
    );
  }
  return (
    <img
      src={src}
      alt=""
      width={size}
      height={size}
      style={{ imageRendering: 'pixelated' }}
      className="shrink-0 rounded border border-line bg-sunken"
      onError={() => setFailed(true)}
    />
  );
}

export function ArtifactsPage({
  data,
  params,
  onParamsChange,
  favoriteHas,
  onToggleFavorite,
  compareHas,
  onToggleCompare,
  compareFull,
  onOpenTalent,
}: ArtifactsPageProps) {
  const [loaded, setLoaded] = useState<LoadedArtifacts | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState<ArtifactFilters>(() => paramsToFilters(params));
  const [selectedId, setSelectedId] = useState<string | null>(() => params.get('a'));
  const [selectedTalentId, setSelectedTalentId] = useState<string | null>(null);
  const [showFilters, setShowFilters] = useState(false);

  useEffect(() => {
    let alive = true;
    loadArtifactData()
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
    setSelectedId(params.get('a'));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [params.toString()]);

  useEffect(() => {
    const next = filtersToParams(filters, selectedId).toString();
    if (next === publishedHash.current) return;
    publishedHash.current = next;
    onParamsChange(new URLSearchParams(next));
    writeHash('artifacts', new URLSearchParams(next));
  }, [filters, selectedId, onParamsChange]);

  const results = useMemo(() => (loaded ? filterArtifacts(loaded, filters) : []), [loaded, filters]);
  const selected = selectedId && loaded ? loaded.byId.get(selectedId) ?? null : null;
  const missingSelection = selectedId && loaded && !selected ? selectedId : null;
  const damageTypes = useMemo(() => loaded?.dataset.labels.damageTypes ?? {}, [loaded]);

  const toggleType = (value: string) =>
    setFilters((current) => ({ ...current, types: toggleIn(current.types, value) }));
  const toggleTier = (value: string) =>
    setFilters((current) => ({ ...current, tiers: toggleIn(current.tiers, value) }));
  const toggleSource = (value: string) =>
    setFilters((current) => ({ ...current, sources: toggleIn(current.sources, value) }));
  const clearFilters = () => setFilters(EMPTY_FILTERS);
  const toggleScope = (which: 'equipment' | 'nonEquipment') =>
    setFilters((current) => ({ ...current, scope: { ...current.scope, [which]: !current.scope[which] } }));

  /** Chinese label for an item type, taken from any artifact that has one. */
  const typeLabels = useMemo(() => {
    const out = new Map<string, string>();
    for (const artifact of loaded?.dataset.artifacts ?? []) {
      if (artifact.type && artifact.typeZh && !out.has(artifact.type)) out.set(artifact.type, artifact.typeZh);
    }
    return out;
  }, [loaded]);

  const tiers = useMemo(() => {
    const set = new Set<number>();
    for (const artifact of loaded?.dataset.artifacts ?? []) {
      if (artifact.status === 'included' && artifact.tier !== null) set.add(artifact.tier);
    }
    return [...set].sort((a, b) => a - b);
  }, [loaded]);

  const talentOf = (id: string) => data.byId.get(id);

  /**
   * Turns engine codes into Chinese for the artifact's property rows.
   *
   * Artifacts grant talents by code (`learn_talent = { [Talents.T_WARD] = 2 }`)
   * and key damage bonuses by actor type, exactly like egos do, so they need the
   * same labelling or the row reads `Talents.T_WARD 2`.
   */
  const labelOf = useMemo(() => makeCodeLabeler({
    actorTypes: loaded?.dataset.labels.actorTypes,
    talent: (code) => data.byId.get(code)?.plainName ?? null,
    tree: (id) => data.byTree.get(id)?.plainName ?? null,
  }), [loaded, data.byId, data.byTree]);
  const selectedTalent = useMemo(() => {
    if (!selectedTalentId) return null;
    const entry = data.byId.get(selectedTalentId);
    if (!entry) return null;
    const tree = data.byTree.get(entry.tree);
    return {
      ...entry,
      treeName: tree?.plainName ?? entry.treeName,
      categoryName: tree?.category ?? entry.category,
    } as TalentEntry;
  }, [selectedTalentId, data.byId, data.byTree]);

  if (error) {
    return (
      <div className="panel mx-auto mt-12 max-w-lg px-6 py-8 text-center">
        <h2 className="mb-2 text-[15px] font-semibold">神器数据加载失败</h2>
        <p className="mb-3 text-[12.5px] text-muted">{error}</p>
        <p className="text-[12px] text-subtle">
          请先运行 <code className="rounded bg-chip px-1">npm run data:items</code> 生成{' '}
          <code className="rounded bg-chip px-1">public/data/artifacts.json</code>。
        </p>
      </div>
    );
  }

  if (!loaded) {
    return (
      <div className="flex min-h-[50vh] items-center justify-center">
        <p className="text-[13px] text-subtle">正在加载神器数据…</p>
      </div>
    );
  }

  const equipmentCount = loaded.dataset.artifacts.filter((a) => a.status === 'included').length;
  const nonEquipmentCount = loaded.dataset.artifacts.length - equipmentCount;

  return (
    <div className="mx-auto max-w-[1600px] px-4 py-4">
      <header className="mb-3">
        <h1 className="text-[18px] font-semibold">固定神器</h1>
        <p className="mt-0.5 text-[12.5px] text-muted">
          共 <span className="font-semibold tabular-nums">{loaded.dataset.artifacts.length}</span> 件，
          其中可装备/可使用 <span className="font-semibold tabular-nums">{equipmentCount}</span> 件
          {nonEquipmentCount > 0 && <>，非装备类 {nonEquipmentCount} 件（宝石、卷轴、药水等，可单独筛选）</>}
          {' '}· 数值取自游戏源码，未做模拟
        </p>
      </header>

      <div className="grid grid-cols-1 gap-4 xl:grid-cols-[16rem_minmax(0,1fr)_28rem]">
        {/* --- Filter rail: tag toggles, matching the advanced-search panel --- */}
        <aside className={`${showFilters ? 'block' : 'hidden'} xl:block`}>
          <div className="panel divide-y divide-line px-3">
            <div className="py-2.5">
              <label className="mb-1 block text-[12.5px] font-semibold" htmlFor="artifact-query">
                搜索神器
              </label>
              <input
                id="artifact-query"
                className="input"
                placeholder="中文 / 英文 / 别名 / 效果"
                value={filters.query}
                onChange={(event) => setFilters((current) => ({ ...current, query: event.target.value }))}
              />
            </div>

            {/*
              Open by default, and the two tags are independent rather than a
              radio pair: "可装备" alone is the default, unchecking it while
              checking "非装备" shows only non-equipment, and both together show
              everything.
            */}
            <Section
              title="收录范围"
              defaultOpen
              activeCount={Number(filters.scope.equipment) + Number(filters.scope.nonEquipment)}
            >
              <div className="flex flex-wrap gap-1">
                <TagButton
                  label="可装备"
                  count={equipmentCount}
                  pressed={filters.scope.equipment}
                  onClick={() => toggleScope('equipment')}
                  title="武器、护甲、首饰、灯具、工具等可以直接穿戴或使用的固定神器"
                />
                <TagButton
                  label="非装备"
                  count={nonEquipmentCount}
                  pressed={filters.scope.nonEquipment}
                  onClick={() => toggleScope('nonEquipment')}
                  title="宝石、卷轴、药水等同样是固定神器、但不能装备的类别"
                />
              </div>
              <p className="mt-1.5 text-[10.5px] leading-relaxed text-subtle">
                两个标签互不排斥，可以同时选中。两个都不选时列表为空（这里说明原因，而不是悄悄显示全部）。
              </p>
            </Section>

            <Section title="物品类型" defaultOpen activeCount={filters.types.length} hint={`${loaded.types.length} 类`}>
              <div className="flex flex-wrap gap-1">
                {loaded.types.map((type) => {
                  const count = loaded.dataset.artifacts.filter((artifact) => artifact.type === type).length;
                  return (
                    <TagButton
                      key={type}
                      label={typeLabels.get(type) ?? type}
                      count={count}
                      pressed={filters.types.includes(type)}
                      onClick={() => toggleType(type)}
                      title={type}
                    />
                  );
                })}
              </div>
            </Section>

            <Section title="阶级" activeCount={filters.tiers.length}>
              <div className="flex flex-wrap gap-1">
                {tiers.map((tier) => {
                  const count = loaded.dataset.artifacts.filter((artifact) => artifact.status === 'included' && artifact.tier === tier).length;
                  return (
                    <TagButton
                      key={tier}
                      label={`阶级 ${tier}`}
                      count={count}
                      pressed={filters.tiers.includes(String(tier))}
                      onClick={() => toggleTier(String(tier))}
                    />
                  );
                })}
              </div>
            </Section>

            <Section title="来源" activeCount={filters.sources.length}>
              <div className="flex flex-wrap gap-1">
                {loaded.dataset.sources.map((source) => {
                  const count = loaded.dataset.artifacts.filter((artifact) => artifact.source === source.id).length;
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

        <div className="min-w-0" data-testid="artifact-list-main">
          <div className="mb-2 flex flex-wrap items-center gap-2">
            <button type="button" className="btn xl:hidden" onClick={() => setShowFilters((v) => !v)}>
              {showFilters ? '收起筛选' : '筛选'}
            </button>
            <span className="text-[12px] text-muted">
              匹配 <span className="font-semibold tabular-nums">{results.length}</span> 件
            </span>
          </div>

          {results.length === 0 ? (
            <div className="panel px-4 py-8 text-center">
              <p className="text-[13px] font-medium">没有匹配的神器</p>
              <p className="mt-1 text-[12px] text-subtle">试试减少筛选条件，或清空全部条件。</p>
              <button type="button" className="btn mt-3" onClick={() => setFilters(EMPTY_FILTERS)}>
                清空全部条件
              </button>
            </div>
          ) : (
            <ul className="grid grid-cols-1 gap-1.5 md:grid-cols-2 2xl:grid-cols-3">
              {results.map((artifact) => (
                <li key={artifact.id}>
                  <button
                    type="button"
                    onClick={() => {
                      setSelectedId(artifact.id);
                      setSelectedTalentId(null);
                    }}
                    aria-pressed={selectedId === artifact.id}
                    className={`flex w-full items-start gap-2.5 rounded-lg border px-2.5 py-2 text-left transition-colors ${
                      selectedId === artifact.id
                        ? 'border-accent bg-accent-soft'
                        : 'border-line bg-surface hover:bg-hover'
                    }`}
                    data-testid="artifact-card"
                  >
                    <Icon artifact={artifact} size={40} />
                    <span className="min-w-0 flex-1">
                      <span className="flex flex-wrap items-baseline gap-x-1.5">
                        <span className="text-[13px] font-medium">
                          <Highlight
                            text={artifact.nameZh ?? artifact.name}
                            terms={searchTerms(filters.query)}
                          />
                        </span>
                        {artifact.nameZh && (
                          <span className="text-[11px] text-subtle">
                            <Highlight text={artifact.name} terms={searchTerms(filters.query)} />
                          </span>
                        )}
                      </span>
                      <span className="mt-1 flex flex-wrap items-center gap-1">
                        {artifact.subtypeZh && <span className="chip">{artifact.subtypeZh}</span>}
                        {artifact.slotZh && <span className="chip">{artifact.slotZh}</span>}
                        {artifact.tier !== null && <span className="chip">阶级 {artifact.tier}</span>}
                        {artifact.status === 'non-equipment' && <span className="chip">非装备</span>}
                        {artifact.quest && <span className="chip">任务</span>}
                      </span>
                    </span>
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>
        <aside className="hidden min-w-0 xl:block" aria-hidden={!selected}>
          {selected && (
            <div className="panel sticky top-[calc(var(--header-h)+2px)] max-h-[calc(100vh-var(--header-h)-12px)] overflow-y-auto p-3 pb-16">
              <ArtifactDetail
                artifact={selected}
                dataset={loaded.dataset}
                report={loaded.report}
                terms={searchTerms(filters.query)}
                damageTypes={damageTypes}
                labelResolver={labelOf}
                talentOf={talentOf}
                onSelectTalent={(talent) =>
                  setSelectedTalentId((current) => (current === talent.id ? null : talent.id))
                }
                selectedTalentId={selectedTalentId}
                onClose={() => setSelectedId(null)}
                onOpenSet={(id) => navigate('sets', { set: id })}
                onOpenTalent={onOpenTalent}
                onOpenTree={(id) => navigate('search', { trees: id })}
                treeOf={(id) => data.byTree.get(id)}
              />
              {selectedTalent && (
                <div className="mt-4 border-t border-line pt-3">
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
            </div>
          )}
        </aside>
      </div>

      {selected && (
        <>
          <MobileSheet onClose={() => setSelectedId(null)} testId="artifact-detail-sheet" ariaLabel="固定神器详情">
            <div className="panel flex min-h-0 flex-1 flex-col overflow-hidden p-3">
              <div className="min-h-0 flex-1 overflow-y-auto overscroll-contain">
              <ArtifactDetail
                artifact={selected}
                dataset={loaded.dataset}
                report={loaded.report}
                terms={searchTerms(filters.query)}
                damageTypes={damageTypes}
                labelResolver={labelOf}
                talentOf={talentOf}
                onSelectTalent={(talent) =>
                  setSelectedTalentId((current) => (current === talent.id ? null : talent.id))
                }
                selectedTalentId={selectedTalentId}
                onClose={() => setSelectedId(null)}
                onOpenSet={(id) => navigate('sets', { set: id })}
                onOpenTalent={onOpenTalent}
                onOpenTree={(id) => navigate('search', { trees: id })}
                treeOf={(id) => data.byTree.get(id)}
              />
              </div>
            </div>
          </MobileSheet>
        </>
      )}

      {selectedTalent && (
        <>
        <MobileSheet onClose={() => setSelectedTalentId(null)} zIndex="z-50" testId="artifact-talent-sheet" ariaLabel="技能详情">
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
        </MobileSheet>
        </>
      )}

      {missingSelection && (
        <div className="panel mt-4 px-4 py-6 text-center">
          <p className="text-[13px] font-medium">找不到神器 {missingSelection}</p>
          <p className="mt-1 text-[12px] text-subtle">链接里的神器 ID 不在当前数据集中。</p>
        </div>
      )}
    </div>
  );
}
