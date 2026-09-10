import { FIELD_LABELS, SEARCH_FIELDS } from '../lib/search';
import type { FilterState } from '../lib/filters';
import { activeFilterCount } from '../lib/filters';

interface SearchBarProps {
  filters: FilterState;
  onChange: (next: FilterState) => void;
  matchCount: number;
  building: boolean;
  onToggleFilters: () => void;
}

const EXAMPLES = ['火焰', 'name:冲击', '"持续 回合"', '-name:被动'];

export function SearchBar({ filters, onChange, matchCount, building, onToggleFilters }: SearchBarProps) {
  const toggleField = (field: string) => {
    const has = filters.fields.includes(field);
    const next = has ? filters.fields.filter((f) => f !== field) : [...filters.fields, field];
    // Never allow an empty field set — that would silently match nothing.
    if (!next.length) return;
    onChange({ ...filters, fields: next });
  };

  return (
    <div className="panel px-3 py-3">
      <div className="flex flex-col gap-2 lg:flex-row lg:items-center">
        <div className="relative flex-1">
          <svg
            viewBox="0 0 20 20"
            className="pointer-events-none absolute left-2.5 top-1/2 h-4 w-4 -translate-y-1/2 text-subtle"
            fill="currentColor"
          >
            <path d="M8.5 3a5.5 5.5 0 014.23 9.02l3.62 3.63a1 1 0 01-1.41 1.41l-3.63-3.62A5.5 5.5 0 118.5 3zm0 2a3.5 3.5 0 100 7 3.5 3.5 0 000-7z" />
          </svg>
          <input
            className="input py-2 pl-8 pr-8 text-[14px]"
            placeholder="搜索技能名、技能大系或技能文本…  例：name:火焰  或  “持续 回合”"
            value={filters.query}
            onChange={(e) => onChange({ ...filters, query: e.target.value })}
            autoFocus
            spellCheck={false}
          />
          {filters.query && (
            <button
              type="button"
              className="absolute right-2 top-1/2 -translate-y-1/2 text-subtle hover:text-fg"
              onClick={() => onChange({ ...filters, query: '' })}
              title="清空"
            >
              ✕
            </button>
          )}
        </div>

        <div className="flex items-center gap-1.5">
          <button
            type="button"
            className="btn lg:hidden"
            onClick={onToggleFilters}
            aria-pressed={activeFilterCount(filters) > 0}
          >
            筛选
            {activeFilterCount(filters) > 0 && (
              <span className="rounded-full bg-accent px-1.5 text-[11px] font-bold text-accent-contrast">
                {activeFilterCount(filters)}
              </span>
            )}
          </button>
          <span className="whitespace-nowrap text-[12px] text-subtle">
            {building ? '正在建立索引…' : `${matchCount} 条结果`}
          </span>
        </div>
      </div>

      <div className="mt-2 flex flex-wrap items-center gap-1.5">
        <span className="text-[11.5px] text-subtle">检索字段</span>
        {SEARCH_FIELDS.map((field) => (
          <button
            key={field}
            type="button"
            className="btn px-2 py-0.5 text-[11.5px]"
            aria-pressed={filters.fields.includes(field)}
            onClick={() => toggleField(field)}
            title={`在「${FIELD_LABELS[field]}」中检索无前缀关键词`}
          >
            {FIELD_LABELS[field]}
          </button>
        ))}
        <span className="mx-1 h-4 w-px bg-line" />
        <span className="text-[11.5px] text-subtle">示例</span>
        {EXAMPLES.map((example) => (
          <button
            key={example}
            type="button"
            className="btn px-2 py-0.5 font-mono text-[11px]"
            onClick={() => onChange({ ...filters, query: example })}
            title="点击填入检索框"
          >
            {example}
          </button>
        ))}
      </div>
    </div>
  );
}
