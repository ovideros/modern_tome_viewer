import type { MonsterTypeOption } from '../lib/monsters';

interface MonsterTypeTreeProps {
  /** Broad categories (`type`) with their subtypes, already sorted for display. */
  options: MonsterTypeOption[];
  /** Every concrete template, for the "all categories" row. */
  total: number;
  activeType: string | 'all';
  activeSubtype: string | 'all';
  /** Called with the whole selection: a type always carries its subtype state. */
  onSelect: (type: string | 'all', subtype: string | 'all') => void;
}

/**
 * Sidebar picker for the engine's `type` / `subtype` pair.
 *
 * Laid out like the class page: the broad category is a row, and its subtypes
 * appear indented while that row is selected — one focused level at a time
 * instead of 20 types times 89 subtypes at once.
 *
 * Clicking the selected row again walks back up a level (subtype -> type ->
 * all), which is the only way to clear the filter without hunting for a reset
 * button.
 */
export function MonsterTypeTree({ options, total, activeType, activeSubtype, onSelect }: MonsterTypeTreeProps) {
  const selectType = (type: string) => {
    if (activeType !== type) onSelect(type, 'all');
    else if (activeSubtype !== 'all') onSelect(type, 'all');
    else onSelect('all', 'all');
  };

  const selectSubtype = (type: string, subtype: string) => {
    onSelect(type, activeSubtype === subtype ? 'all' : subtype);
  };

  return (
    <div className="pb-1" data-testid="monster-type-tree">
      <h3 className="px-2.5 pt-1 pb-0.5 text-[11px] font-semibold text-subtle">怪物类别（大类 / 亚类）</h3>
      <TreeRow
        label="全部类别"
        count={total}
        active={activeType === 'all'}
        onClick={() => onSelect('all', 'all')}
        testId="monster-type-row"
        testValue="all"
      />
      {options.map((option) => (
        <div key={option.type}>
          <TreeRow
            label={option.label}
            english={option.type}
            count={option.count}
            active={activeType === option.type}
            onClick={() => selectType(option.type)}
            testId="monster-type-row"
            testValue={option.type}
          />
          {activeType === option.type &&
            option.subtypes.map((sub) => (
              <TreeRow
                key={sub.subtype}
                label={sub.label}
                english={sub.subtype}
                count={sub.count}
                active={activeSubtype === sub.subtype}
                indent
                onClick={() => selectSubtype(option.type, sub.subtype)}
                testId="monster-subtype-row"
                testValue={sub.subtype}
              />
            ))}
        </div>
      ))}
      {!options.length && <p className="px-2.5 py-2 text-[11.5px] text-subtle">数据里没有类型字段。</p>}
    </div>
  );
}

function TreeRow({
  label,
  english,
  count,
  active,
  indent = false,
  onClick,
  testId,
  testValue,
}: {
  label: string;
  english?: string;
  count: number;
  active: boolean;
  indent?: boolean;
  onClick: () => void;
  testId: string;
  testValue: string;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-pressed={active}
      data-testid={testId}
      data-value={testValue}
      // `title` carries the English word, which is what the sources and the
      // search box use.
      title={english ? `${label} · ${english}` : label}
      className={`flex w-full items-center justify-between gap-2 py-1.5 pr-2.5 text-left text-[12.5px] hover:bg-hover ${
        indent ? 'pl-6' : 'pl-2.5'
      } ${active ? 'bg-accent-soft font-semibold text-accent-strong' : ''}`}
    >
      <span className="flex min-w-0 items-baseline gap-1.5">
        <span className="truncate">{label}</span>
        {english && <span className="truncate text-[10.5px] font-normal text-subtle">{english}</span>}
      </span>
      <span className="shrink-0 text-[11px] font-normal text-subtle">{count}</span>
    </button>
  );
}
