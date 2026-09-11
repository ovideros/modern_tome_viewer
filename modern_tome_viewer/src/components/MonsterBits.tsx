import { useState } from 'react';
import { assetUrl } from '../lib/data';
import { monsterTypeLabels } from '../lib/monsters';
import type { Monster, MonsterCategory, MonsterImageLayer } from '../lib/monsters';

/** Tone per monster category, so ranks are distinguishable at a glance. */
const CATEGORY_TONE: Record<MonsterCategory, string> = {
  critter: 'bg-slate-500/15 text-slate-500',
  normal: 'bg-chip text-muted',
  elite: 'bg-amber-500/15 text-amber-600 dark:text-amber-400',
  unique: 'bg-orange-500/15 text-orange-600 dark:text-orange-400',
  boss: 'bg-red-500/15 text-red-600 dark:text-red-400',
  elite_boss: 'bg-fuchsia-500/15 text-fuchsia-600 dark:text-fuchsia-400',
  god: 'bg-violet-500/15 text-violet-600 dark:text-violet-400',
};

export function CategoryBadge({ category, label }: { category: MonsterCategory; label?: string }) {
  return (
    <span className={`chip border-0 ${CATEGORY_TONE[category] ?? CATEGORY_TONE.normal}`}>
      {label ?? category}
    </span>
  );
}

/**
 * Monster portrait.
 *
 * Monster art is a single Shockbolt tile, but a few templates are layered
 * (`invis.png` container plus `add_mos` overlays). Layered art is drawn as a
 * stack with the engine's offsets so tall monsters are not cropped, and a
 * missing image falls back to the creature's type/subtype character rather than
 * an empty box.
 */
export function MonsterArtwork({
  monster,
  size = 72,
  className = '',
}: {
  monster: Monster;
  size?: number;
  className?: string;
}) {
  const [failed, setFailed] = useState(false);
  const layers: MonsterImageLayer[] = monster.layers?.length
    ? monster.layers
    : monster.image
      ? [{ file: monster.image, display_h: null, display_w: null, display_x: null, display_y: null }]
      : [];

  const src = monster.image ? assetUrl(`img/${monster.image}`) : null;
  const tall = monster.tall && monster.imageKind === 'layered';

  if (!src || failed) {
    return (
      <div
        className={`flex shrink-0 items-center justify-center rounded-md border border-line bg-sunken text-[11px] text-subtle ${className}`}
        style={{ width: size, height: size }}
        title={monster.imageCandidate ? `缺少图片：${monster.imageCandidate}` : '缺少图片'}
      >
        {monster.typeZh ?? monster.type ?? '?'}
      </div>
    );
  }

  return (
    <div
      className={`relative shrink-0 overflow-hidden rounded-md border border-line bg-sunken ${className}`}
      style={{ width: size, height: size }}
    >
      <img
        src={src}
        alt={monster.name}
        loading="lazy"
        decoding="async"
        onError={() => setFailed(true)}
        className="h-full w-full object-contain"
        style={tall ? { transform: 'scaleY(1.12) translateY(4%)' } : undefined}
      />
      {layers.length > 1 && (
        <span
          className="absolute right-0.5 bottom-0.5 rounded bg-surface/85 px-1 text-[9.5px] text-subtle"
          title={`该图片由 ${layers.length} 层绘制`}
        >
          {layers.length}层
        </span>
      )}
    </div>
  );
}

/**
 * Type/subtype chip, e.g. `恐魔 / 艾尔德里奇`.
 *
 * The Chinese words come from the game's own `entity type` / `entity subtype`
 * tables — the same ones `Actor.lua` uses for the in-game tooltip — with the
 * English source words kept in the tooltip and as the fallback.
 */
export function TypeChip({ monster }: { monster: Monster }) {
  if (!monster.type && !monster.subtype) return null;
  const labels = monsterTypeLabels(monster);
  const raw = [monster.type, monster.subtype].filter(Boolean).join(' / ');
  return (
    <span className="chip" title={`游戏内部类型 / 亚类：${raw}`} data-testid="monster-type-chip">
      {labels.type}
      {labels.subtype ? ` / ${labels.subtype}` : ''}
    </span>
  );
}
