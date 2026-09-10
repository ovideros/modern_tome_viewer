import { assetUrl } from '../lib/data';
import type { PortraitRef, Talent, TalentTree, TreeRef } from '../lib/types';
import { TalentIcon } from './TalentBits';

const STAT_LABELS: Record<string, string> = {
  str: '力量',
  dex: '敏捷',
  con: '体质',
  mag: '魔力',
  wil: '意志',
  cun: '灵巧',
  luck: '幸运',
};

const STAT_ORDER = ['str', 'dex', 'con', 'mag', 'wil', 'cun', 'luck'];

/** Attribute modifiers as compact chips, e.g. +5 力量 / −2 魔力. */
export function StatChips({ stats }: { stats: Record<string, number> }) {
  const entries = STAT_ORDER.filter((key) => key in stats).map((key) => [key, stats[key]] as const);
  if (!entries.length) return <span className="text-[11.5px] text-subtle">无属性修正数据</span>;
  return (
    <div className="flex flex-wrap gap-1">
      {entries.map(([key, value]) => (
        <span
          key={key}
          className={`chip ${value > 0 ? 'text-emerald-600 dark:text-emerald-400' : value < 0 ? 'text-red-500' : ''}`}
        >
          {value > 0 ? '+' : value < 0 ? '−' : ''}
          {Math.abs(value)} {STAT_LABELS[key] ?? key}
        </span>
      ))}
    </div>
  );
}

/**
 * Portraits for a class or race. The first image is the primary portrait; any
 * extra NPC art is shown small next to it.
 */
export function PortraitStrip({ images, alt }: { images: PortraitRef[]; alt: string }) {
  if (!images.length) return null;
  const [primary, ...rest] = images;
  return (
    <div className="flex shrink-0 items-start gap-1.5">
      <img
        data-testid="portrait"
        src={assetUrl(`img/${primary.file}`)}
        alt={alt}
        width={primary.width ?? 64}
        height={primary.height ?? 64}
        className="rounded-md border border-line bg-sunken object-contain"
        style={{ width: 72, height: 72 }}
        loading="eager"
      />
      {rest.slice(0, 2).map((image) => (
        <img
          key={image.file}
          src={assetUrl(`img/${image.file}`)}
          alt=""
          className="rounded border border-line bg-sunken object-contain opacity-80"
          style={{ width: 44, height: 44 }}
          loading="lazy"
        />
      ))}
    </div>
  );
}

/**
 * One talent tree inside a class/race card: header (name, mastery, lock state)
 * followed by the tree's talents as clickable icon+name cards.
 */
export function TalentTreePanel({
  treeRef,
  tree,
  onSelectTalent,
  onOpenTree,
}: {
  treeRef: TreeRef;
  tree: TalentTree | undefined;
  onSelectTalent: (talent: Talent, treeName: string, mastery: number) => void;
  onOpenTree: (treeId: string) => void;
}) {
  const locked = !treeRef.unlocked;
  const talents = tree?.talents ?? [];

  return (
    <section
      className={`rounded-lg border p-2 ${
        locked ? 'border-line bg-sunken/60 opacity-70' : 'border-line bg-surface'
      }`}
      data-testid="tree-panel"
      data-locked={locked ? 'true' : 'false'}
    >
      <header className="mb-1.5 flex flex-wrap items-baseline gap-x-2 gap-y-0.5">
        <button
          type="button"
          onClick={() => onOpenTree(treeRef.id)}
          className={`text-left text-[12.5px] font-semibold hover:underline ${
            locked ? 'text-subtle' : 'text-fg'
          }`}
          title={`在搜索中查看「${treeRef.name}」`}
        >
          {treeRef.name}
        </button>
        <span className="text-[11px] text-subtle">掌握 {treeRef.mastery}</span>
        {locked && (
          <span className="rounded bg-chip px-1.5 text-[10.5px] text-subtle" title="需要投入大系点解锁">
            🔒 未解锁
          </span>
        )}
      </header>

      {talents.length ? (
        <div className="grid grid-cols-2 gap-1 sm:grid-cols-3 xl:grid-cols-4">
          {talents.map((talent) => (
            <button
              key={talent.id}
              type="button"
              data-testid="talent-card"
              onClick={() => onSelectTalent(talent, treeRef.name, treeRef.mastery)}
              title={`${talent.plainName} · ${talent.shortName}`}
              className={`flex flex-col items-center gap-1 rounded border border-transparent px-1 py-1.5 text-center hover:border-accent hover:bg-hover ${
                locked ? 'grayscale-[0.35]' : ''
              }`}
            >
              <TalentIcon talent={talent} size={32} iconSize={48} />
              <span className="line-clamp-2 w-full text-[11px] leading-tight">{talent.plainName}</span>
            </button>
          ))}
        </div>
      ) : (
        <p className="px-1 py-1 text-[11px] text-subtle">该大系暂无技能数据</p>
      )}
    </section>
  );
}
