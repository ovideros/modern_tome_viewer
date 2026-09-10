import type { TalentEntry } from '../lib/types';
import { COMPARE_LIMIT } from '../hooks/useIdList';

interface CompareBarProps {
  entries: TalentEntry[];
  onRemove: (id: string) => void;
  onClear: () => void;
  onOpen: () => void;
  limitReached: boolean;
}

/** Fixed tray that appears once at least one talent is queued for comparison. */
export function CompareBar({ entries, onRemove, onClear, onOpen, limitReached }: CompareBarProps) {
  if (!entries.length) return null;

  return (
    <div className="pointer-events-none fixed inset-x-0 bottom-0 z-40 flex justify-center px-3 pb-3">
      <div className="panel pointer-events-auto flex max-w-[1200px] flex-wrap items-center gap-2 px-3 py-2">
        <span className="text-[12px] font-semibold">
          对比 {entries.length}
          <span className="font-normal text-subtle"> / {COMPARE_LIMIT}</span>
        </span>
        <div className="flex flex-wrap items-center gap-1">
          {entries.map((talent) => (
            <span key={talent.id} className="chip">
              {talent.plainName}
              <button
                type="button"
                className="ml-0.5 text-subtle hover:text-fg"
                onClick={() => onRemove(talent.id)}
                title="移出对比"
                aria-label={`移出对比：${talent.plainName}`}
              >
                ✕
              </button>
            </span>
          ))}
        </div>
        {limitReached && <span className="text-[11.5px] text-red-500">对比最多 {COMPARE_LIMIT} 个技能</span>}
        <div className="ml-auto flex items-center gap-1.5">
          <button type="button" className="btn" onClick={onClear}>
            清空
          </button>
          <button type="button" className="btn btn-primary" onClick={onOpen} disabled={entries.length < 2}>
            {entries.length < 2 ? '再选 1 个即可对比' : '开始对比'}
          </button>
        </div>
      </div>
    </div>
  );
}
