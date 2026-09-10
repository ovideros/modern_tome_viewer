import { useMemo, useState } from 'react';
import type { DatasetMeta, TalentEntry } from '../lib/types';
import { Highlight } from '../components/Highlight';
import { TalentIcon, TalentStats } from '../components/TalentBits';

interface FavoritesPageProps {
  entries: TalentEntry[];
  meta: DatasetMeta;
  onRemove: (id: string) => void;
  onClear: () => void;
  onOpen: (talent: TalentEntry) => void;
  onCompare: (id: string) => void;
  onBack: () => void;
  compareHas: (id: string) => boolean;
}

export function FavoritesPage({
  entries,
  meta,
  onRemove,
  onClear,
  onOpen,
  onCompare,
  onBack,
  compareHas,
}: FavoritesPageProps) {
  const [filter, setFilter] = useState('');

  const visible = useMemo(() => {
    const needle = filter.trim().toLowerCase();
    if (!needle) return entries;
    return entries.filter((talent) =>
      `${talent.plainName} ${talent.shortName} ${talent.treePlainName} ${talent.categoryName} ${talent.plain}`
        .toLowerCase()
        .includes(needle),
    );
  }, [entries, filter]);

  const terms = useMemo(() => (filter.trim() ? [filter.trim()] : []), [filter]);

  if (!entries.length) {
    return (
      <div className="mx-auto max-w-[1600px] px-4 py-3">
        <div className="panel flex flex-col items-center gap-3 px-6 py-16 text-center">
          <p className="text-[15px] font-semibold">收藏夹是空的</p>
          <p className="max-w-md text-[12.5px] text-subtle">
            在搜索结果或技能详情里点击「收藏」，收藏会保存在本机浏览器中（localStorage），刷新或重开浏览器都不会丢失。
          </p>
          <button type="button" className="btn btn-primary" onClick={onBack}>
            去搜索技能
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-[1600px] px-4 py-3">
      <div className="panel mb-3 flex flex-wrap items-center gap-2 px-3 py-2.5">
        <div className="mr-auto">
          <h1 className="text-[15px] font-semibold">我的收藏</h1>
          <p className="text-[11.5px] text-subtle">
            共 {entries.length} 个技能
            {filter && ` · 匹配 ${visible.length} 个`}
          </p>
        </div>
        <input
          className="input max-w-[220px]"
          placeholder="在收藏中搜索…"
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
        />
        <button type="button" className="btn" onClick={onBack}>
          返回搜索
        </button>
        <button
          type="button"
          className="btn"
          onClick={() => {
            if (window.confirm('确定清空全部收藏？')) onClear();
          }}
        >
          清空
        </button>
      </div>

      <div className="space-y-1.5">
        {visible.map((talent) => (
          <div key={talent.id} className="panel flex items-start gap-3 px-3 py-2.5">
            <button type="button" onClick={() => onOpen(talent)} className="shrink-0">
              <TalentIcon talent={talent} iconSize={meta.iconSize} />
            </button>
            <button type="button" onClick={() => onOpen(talent)} className="min-w-0 flex-1 text-left">
              <div className="flex flex-wrap items-baseline gap-x-2">
                <span className="text-[14px] font-semibold">
                  <Highlight text={talent.plainName} terms={terms} />
                </span>
                <span className="text-[11.5px] text-subtle">{talent.shortName}</span>
              </div>
              <div className="mb-1 text-[11.5px] text-muted">
                <span className="text-accent-strong">{talent.categoryName}</span>
                <span className="text-subtle"> / </span>
                {talent.treePlainName}
              </div>
              <TalentStats talent={talent} dense />
            </button>
            <div className="flex shrink-0 flex-col gap-1">
              <button
                type="button"
                className="btn px-2 py-1 text-[11.5px]"
                onClick={() => onCompare(talent.id)}
                aria-pressed={compareHas(talent.id)}
              >
                {compareHas(talent.id) ? '已加入对比' : '加入对比'}
              </button>
              <button
                type="button"
                className="btn px-2 py-1 text-[11.5px]"
                onClick={() => onRemove(talent.id)}
                title="取消收藏"
              >
                ✕ 移除
              </button>
            </div>
          </div>
        ))}
        {!visible.length && (
          <p className="panel px-4 py-8 text-center text-[13px] text-subtle">没有匹配的收藏项。</p>
        )}
      </div>
    </div>
  );
}
