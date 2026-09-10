import { useState } from 'react';
import { assetUrl, RANGE_KIND_LABELS } from '../lib/data';
import type { Talent } from '../lib/types';

/** Minimum shape needed to render an icon (works for plain Talent too). */
type IconSubject = Pick<Talent, 'image' | 'plainName'>;

export function TalentIcon({
  talent,
  size = 40,
  iconSize,
}: {
  talent: IconSubject;
  size?: number;
  iconSize: number;
}) {
  const [failed, setFailed] = useState(false);
  const src = talent.image ? assetUrl(`img/talents/${iconSize}/${talent.image}`) : null;

  if (!src || failed) {
    return (
      <div
        className="flex shrink-0 items-center justify-center rounded-md border border-line bg-sunken text-subtle"
        style={{ width: size, height: size, fontSize: size * 0.4 }}
        title="缺少图标"
      >
        {talent.plainName.slice(0, 1)}
      </div>
    );
  }

  return (
    <img
      src={src}
      alt=""
      width={size}
      height={size}
      loading="lazy"
      decoding="async"
      onError={() => setFailed(true)}
      className="shrink-0 rounded-md border border-line bg-sunken object-contain"
      style={{ width: size, height: size }}
    />
  );
}

export function Chip({
  children,
  title,
  tone = 'default',
}: {
  children: React.ReactNode;
  title?: string;
  tone?: 'default' | 'accent' | 'warn' | 'muted';
}) {
  const toneClass =
    tone === 'accent'
      ? 'bg-accent-soft text-accent-strong'
      : tone === 'warn'
        ? 'bg-red-500/15 text-red-500'
        : tone === 'muted'
          ? 'bg-chip text-subtle'
          : 'bg-chip text-muted';
  return (
    <span className={`chip ${toneClass}`} title={title}>
      {children}
    </span>
  );
}

/** Compact stat chips shared by the results list, detail panel and class pages. */
export function TalentStats({ talent, dense = false }: { talent: Talent; dense?: boolean }) {
  const cooldown = talent.cooldown;
  return (
    <div className="flex flex-wrap items-center gap-1">
      <Chip tone="accent" title="使用模式">
        {talent.mode || '未知'}
      </Chip>
      {talent.useSpeed && (
        <Chip title="使用速度">
          速度 <span className="font-medium">{talent.useSpeed}</span>
        </Chip>
      )}
      {cooldown.display !== null && (
        <Chip
          title={
            (cooldown.values.length > 1 ? `随等级变化：${cooldown.display}` : '冷却时间') +
            (cooldown.fixed ? '；固定冷却：任何效果都不能增减它' : '')
          }
        >
          冷却 <span className="font-medium">{cooldown.display}</span>
          {cooldown.fixed && <span className="ml-1 text-[10px] text-subtle">固定</span>}
        </Chip>
      )}
      {talent.range.display && (
        <Chip title="射程">
          射程 <span className="font-medium">{RANGE_KIND_LABELS[talent.range.kind] === '近战' ? '近战' : talent.range.display}</span>
        </Chip>
      )}
      {talent.cost.display && (
        <Chip title={`资源：${talent.cost.display}`}>
          {talent.cost.display}
        </Chip>
      )}
      {!dense && talent.points > 0 && <Chip title="可投入点数">点数 {talent.points}</Chip>}
      {!dense && talent.flags.generic && <Chip tone="muted">通用</Chip>}
      {!dense && talent.flags.uber && <Chip tone="muted">觉醒</Chip>}
    </div>
  );
}
