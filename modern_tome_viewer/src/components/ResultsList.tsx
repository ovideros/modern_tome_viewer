import { useMemo, useState } from 'react';
import type { TalentEntry } from '../lib/types';
import { TalentIcon, TalentStats } from './TalentBits';
import { Highlight } from './Highlight';

interface ResultsListProps {
  entries: TalentEntry[];
  terms: string[];
  iconSize: number;
  selectedId: string | null;
  onSelect: (talent: TalentEntry) => void;
  pageSize?: number;
  favoriteHas: (id: string) => boolean;
  onToggleFavorite: (id: string) => void;
  compareHas: (id: string) => boolean;
  onToggleCompare: (id: string) => void;
  compareFull: boolean;
}

/** Build a short excerpt around the first matching term, for the result row. */
function excerpt(text: string, terms: string[]): string {
  if (!text) return '';
  const cleaned = terms.map((t) => t.trim()).filter(Boolean);
  let index = -1;
  for (const term of cleaned) {
    const found = text.toLowerCase().indexOf(term.toLowerCase());
    if (found >= 0 && (index === -1 || found < index)) index = found;
  }
  if (index < 0) return text.length > 150 ? `${text.slice(0, 150)}…` : text;
  const start = Math.max(0, index - 45);
  const end = Math.min(text.length, index + 130);
  return `${start > 0 ? '…' : ''}${text.slice(start, end)}${end < text.length ? '…' : ''}`;
}

export function ResultsList({
  entries,
  terms,
  iconSize,
  selectedId,
  onSelect,
  pageSize = 60,
  favoriteHas,
  onToggleFavorite,
  compareHas,
  onToggleCompare,
  compareFull,
}: ResultsListProps) {
  const [visible, setVisible] = useState(pageSize);

  // Reset pagination whenever the result set changes identity.
  const signature = useMemo(() => `${entries.length}:${entries[0]?.id ?? ''}:${terms.join('|')}`, [entries, terms]);
  const [lastSignature, setLastSignature] = useState(signature);
  if (signature !== lastSignature) {
    setLastSignature(signature);
    setVisible(pageSize);
  }

  const shown = entries.slice(0, visible);

  if (!entries.length) {
    return (
      <div className="panel flex flex-col items-center justify-center gap-2 px-6 py-16 text-center">
        <p className="text-[15px] font-semibold">没有匹配的技能</p>
        <p className="max-w-md text-[12.5px] text-subtle">
          试着减少筛选条件，或改用更短的检索词。检索语法支持 <code className="rounded bg-chip px-1">name:火焰</code>、
          <code className="ml-1 rounded bg-chip px-1">"火焰伤害"</code>、<code className="ml-1 rounded bg-chip px-1">-name:被动</code>。
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between px-1 text-[12px] text-subtle">
        <span>
          共 <span className="font-semibold text-fg">{entries.length}</span> 条结果
          {entries.length > shown.length && ` · 已显示前 ${shown.length} 条`}
        </span>
      </div>

      <div className="space-y-1.5">
        {shown.map((talent) => (
          <div
            key={talent.id}
            data-testid="result-row"
            className={`panel flex items-start gap-3 px-3 py-2.5 transition-colors ${
              selectedId === talent.id ? 'border-accent bg-accent-soft/40' : 'hover:bg-hover'
            }`}
          >
            <button type="button" onClick={() => onSelect(talent)} className="flex min-w-0 flex-1 items-start gap-3 text-left">
              <TalentIcon talent={talent} iconSize={iconSize} />
              <div className="min-w-0 flex-1">
                <div className="flex flex-wrap items-baseline gap-x-2 gap-y-0.5">
                  <span className="text-[14px] font-semibold">
                    <Highlight text={talent.plainName} terms={terms} />
                  </span>
                  <span className="text-[11.5px] text-subtle">{talent.shortName}</span>
                </div>
                <div className="mb-1 flex flex-wrap items-center gap-1 text-[11.5px] text-muted">
                  <span className="text-accent-strong">
                    <Highlight text={talent.categoryName} terms={terms} />
                  </span>
                  <span className="text-subtle">/</span>
                  <span>
                    <Highlight text={talent.treePlainName} terms={terms} />
                  </span>
                </div>
                <TalentStats talent={talent} dense />
                <p className="mt-1.5 line-clamp-2 text-[12px] leading-relaxed text-muted">
                  <Highlight text={excerpt(talent.plain, terms)} terms={terms} />
                </p>
              </div>
            </button>
            <div className="flex shrink-0 flex-col gap-1">
              <button
                type="button"
                className="btn px-1.5 py-0.5 text-[12px]"
                aria-pressed={favoriteHas(talent.id)}
                onClick={() => onToggleFavorite(talent.id)}
                title={favoriteHas(talent.id) ? '取消收藏' : '加入收藏'}
                aria-label={`${favoriteHas(talent.id) ? '取消收藏' : '收藏'}：${talent.plainName}`}
              >
                {favoriteHas(talent.id) ? '★' : '☆'}
              </button>
              <button
                type="button"
                className="btn px-1.5 py-0.5 text-[11px]"
                aria-pressed={compareHas(talent.id)}
                onClick={() => onToggleCompare(talent.id)}
                title={compareHas(talent.id) ? '移出对比' : compareFull ? '对比列表已满' : '加入对比'}
                aria-label={`${compareHas(talent.id) ? '移出对比' : '加入对比'}：${talent.plainName}`}
              >
                对比
              </button>
            </div>
          </div>
        ))}
      </div>

      {entries.length > shown.length && (
        <button
          type="button"
          className="btn w-full justify-center py-2"
          onClick={() => setVisible((v) => v + pageSize)}
        >
          显示更多（剩余 {entries.length - shown.length} 条）
        </button>
      )}
    </div>
  );
}
