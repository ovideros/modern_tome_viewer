import { useMemo, useState, type ReactNode } from 'react';
import type { FilterState } from '../lib/filters';
import { cooldownKindCounts, emptyFilters } from '../lib/filters';
import type { CooldownKind } from '../lib/filters';
import { COST_KIND_LABELS, RANGE_KIND_LABELS, RESOURCE_LABELS, flagLabel } from '../lib/data';
import type { DatasetMeta, TalentEntry, TallyEntry } from '../lib/types';
import { facetCounts } from '../lib/filters';

interface FilterPanelProps {
  meta: DatasetMeta;
  talents: TalentEntry[];
  filters: FilterState;
  onChange: (next: FilterState) => void;
  classTrees: Set<string> | undefined;
  /** Number of results matching the current filter state. */
  matchCount: number;
  totalCount: number;
  onClose?: () => void;
}

function Section({
  title,
  hint,
  children,
  defaultOpen = false,
  activeCount = 0,
}: {
  title: string;
  hint?: string;
  children: ReactNode;
  defaultOpen?: boolean;
  activeCount?: number;
}) {
  const [open, setOpen] = useState(defaultOpen);
  return (
    <div className="border-b border-line last:border-b-0">
      <button
        type="button"
        onClick={() => setOpen((v) => !v)}
        className="flex w-full items-center justify-between gap-2 px-3 py-2.5 text-left hover:bg-hover"
      >
        <span className="flex items-center gap-2">
          <span className="text-[13px] font-semibold">{title}</span>
          {activeCount > 0 && (
            <span className="rounded-full bg-accent-soft px-1.5 text-[11px] font-semibold text-accent-strong">
              {activeCount}
            </span>
          )}
        </span>
        <span className="flex items-center gap-2">
          {hint && <span className="text-[11px] text-subtle">{hint}</span>}
          <svg
            viewBox="0 0 20 20"
            className={`h-3.5 w-3.5 text-subtle transition-transform ${open ? 'rotate-90' : ''}`}
            fill="currentColor"
          >
            <path d="M7 4l6 6-6 6V4z" />
          </svg>
        </span>
      </button>
      {open && <div className="px-3 pb-3">{children}</div>}
    </div>
  );
}

function CheckList({
  options,
  selected,
  onToggle,
  searchable = false,
  labelFor,
  maxHeight = 208,
}: {
  options: TallyEntry[];
  selected: string[];
  onToggle: (value: string) => void;
  searchable?: boolean;
  labelFor?: (value: string) => string;
  maxHeight?: number;
}) {
  const [term, setTerm] = useState('');
  const visible = useMemo(() => {
    const needle = term.trim().toLowerCase();
    const list = needle
      ? options.filter((o) => {
          const label = labelFor ? labelFor(o.value) : o.value;
          return label.toLowerCase().includes(needle) || o.value.toLowerCase().includes(needle);
        })
      : options;
    // Selected entries float to the top so long lists stay usable.
    return [...list].sort((a, b) => {
      const aSel = selected.includes(a.value) ? 1 : 0;
      const bSel = selected.includes(b.value) ? 1 : 0;
      return bSel - aSel || b.count - a.count;
    });
  }, [options, term, selected, labelFor]);

  return (
    <div className="space-y-2">
      {searchable && (
        <input
          className="input"
          placeholder="筛选选项…"
          value={term}
          onChange={(e) => setTerm(e.target.value)}
        />
      )}
      <div className="space-y-0.5 overflow-y-auto pr-1" style={{ maxHeight }}>
        {visible.map((option) => {
          const checked = selected.includes(option.value);
          return (
            <label
              key={option.value}
              className={`flex cursor-pointer items-center gap-2 rounded px-1.5 py-1 text-[12.5px] hover:bg-hover ${
                checked ? 'bg-accent-soft/60' : ''
              }`}
            >
              <input
                type="checkbox"
                className="accent-[var(--accent)]"
                checked={checked}
                onChange={() => onToggle(option.value)}
              />
              <span className="flex-1 truncate" title={labelFor ? labelFor(option.value) : option.value}>
                {labelFor ? labelFor(option.value) : option.value}
              </span>
              <span className="text-[11px] text-subtle">{option.count}</span>
            </label>
          );
        })}
        {!visible.length && <p className="px-1.5 py-2 text-[12px] text-subtle">没有匹配的选项</p>}
      </div>
    </div>
  );
}

function NumberRange({
  label,
  unit,
  min,
  max,
  bounds,
  presets,
  onChange,
}: {
  label: string;
  unit?: string;
  min: number | null;
  max: number | null;
  bounds: { min: number; max: number };
  presets?: { label: string; min: number | null; max: number | null }[];
  onChange: (next: { min: number | null; max: number | null }) => void;
}) {
  const parse = (value: string): number | null => {
    if (value.trim() === '') return null;
    const num = Number(value);
    return Number.isFinite(num) ? num : null;
  };

  return (
    <div className="space-y-2">
      <div className="flex items-center gap-2">
        <input
          type="number"
          className="input"
          placeholder={String(bounds.min)}
          value={min ?? ''}
          onChange={(e) => onChange({ min: parse(e.target.value), max })}
          aria-label={`${label}下限`}
        />
        <span className="text-subtle">–</span>
        <input
          type="number"
          className="input"
          placeholder={String(bounds.max)}
          value={max ?? ''}
          onChange={(e) => onChange({ min, max: parse(e.target.value) })}
          aria-label={`${label}上限`}
        />
        {unit && <span className="shrink-0 text-[11px] text-subtle">{unit}</span>}
      </div>
      {presets && (
        <div className="flex flex-wrap gap-1">
          {presets.map((preset) => {
            const active = min === preset.min && max === preset.max;
            return (
              <button
                key={preset.label}
                type="button"
                aria-pressed={active}
                className="btn px-2 py-0.5 text-[11.5px]"
                onClick={() => onChange({ min: preset.min, max: preset.max })}
              >
                {preset.label}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}

/** The three mutually exclusive states of the fixed-cooldown switch. */
const COOLDOWN_KIND_OPTIONS: { value: CooldownKind; label: string }[] = [
  { value: 'any', label: '全部' },
  { value: 'fixed', label: '只看固定' },
  { value: 'normal', label: '只看非固定' },
];

export function FilterPanel({
  meta,
  talents,
  filters,
  onChange,
  classTrees,
  matchCount,
  totalCount,
  onClose,
}: FilterPanelProps) {
  const set = <K extends keyof FilterState>(key: K, value: FilterState[K]) =>
    onChange({ ...filters, [key]: value });

  const toggleIn = (key: keyof FilterState, value: string) => {
    const current = filters[key] as string[];
    const next = current.includes(value) ? current.filter((v) => v !== value) : [...current, value];
    set(key as never, next as never);
  };

  const categoryOptions = useMemo<TallyEntry[]>(
    () =>
      facetCounts(talents, filters, 'categories', classTrees).length
        ? facetCounts(talents, filters, 'categories', classTrees)
        : meta.categories.map((c) => ({ value: c.id, count: c.talentCount })),
    [talents, filters, classTrees, meta.categories],
  );

  const treeOptions = useMemo(() => {
    const counts = facetCounts(talents, filters, 'trees', classTrees);
    const map = new Map(counts.map((c) => [c.value, c.count]));
    return meta.treeNames.length
      ? meta.treeNames.map((t) => ({ value: t.id, count: map.get(t.id) ?? 0 }))
      : counts;
  }, [talents, filters, classTrees, meta.treeNames]);

  const cooldownCounts = useMemo(
    () => cooldownKindCounts(talents, filters, classTrees),
    [talents, filters, classTrees],
  );

  const treeLabel = (id: string) => meta.treeNames.find((t) => t.id === id)?.name ?? id;
  const classLabel = (id: string) => meta.classes.find((c) => c.id === id)?.name ?? id;

  return (
    <div className="panel flex h-full flex-col overflow-hidden">
      <div className="flex items-center justify-between gap-2 border-b border-line px-3 py-2.5">
        <div>
          <h2 className="text-[13px] font-semibold">高级筛选</h2>
          <p className="text-[11px] text-subtle">
            <span className="font-semibold text-accent-strong">{matchCount}</span> / {totalCount} 个技能
          </p>
        </div>
        <div className="flex items-center gap-1">
          <button type="button" className="btn px-2 py-1 text-[11.5px]" onClick={() => onChange(emptyFilters())}>
            重置
          </button>
          {onClose && (
            <button type="button" className="btn-ghost btn px-2 py-1 lg:hidden" onClick={onClose}>
              收起
            </button>
          )}
        </div>
      </div>

      <div className="min-h-0 flex-1 overflow-y-auto">
        <Section title="适用范围" defaultOpen activeCount={(filters.classId ? 1 : 0) + filters.categories.length}>
          <div className="space-y-2">
            <select
              className="input"
              value={filters.classId ?? ''}
              onChange={(e) => set('classId', e.target.value || null)}
            >
              <option value="">全部职业</option>
              {meta.classList.map((cls) => (
                <option key={cls.id} value={cls.id}>
                  {cls.name}
                </option>
              ))}
            </select>
            {filters.classId && (
              <p className="text-[11px] text-subtle">
                仅显示 {classLabel(filters.classId)} 及其子职业可以学习的技能大系。
              </p>
            )}
            <div>
              <p className="mb-1 text-[11.5px] font-medium text-muted">技能分类</p>
              <CheckList
                options={categoryOptions}
                selected={filters.categories}
                onToggle={(value) => toggleIn('categories', value)}
                labelFor={(id) => meta.categories.find((c) => c.id === id)?.name ?? id}
              />
            </div>
          </div>
        </Section>

        <Section title="技能大系" activeCount={filters.trees.length} hint={`${treeOptions.length} 个`}>
          <CheckList
            options={treeOptions}
            selected={filters.trees}
            onToggle={(value) => toggleIn('trees', value)}
            searchable
            labelFor={treeLabel}
            maxHeight={260}
          />
        </Section>

        <Section title="使用模式" defaultOpen activeCount={filters.modes.length}>
          <CheckList
            options={meta.facets.mode}
            selected={filters.modes}
            onToggle={(value) => toggleIn('modes', value)}
          />
        </Section>

        <Section
          title="冷却时间"
          activeCount={
            (filters.cooldown.min !== null || filters.cooldown.max !== null ? 1 : 0)
            + (filters.cooldownKind !== 'any' ? 1 : 0)
          }
        >
          <div className="space-y-2">
            <NumberRange
              label="冷却"
              min={filters.cooldown.min}
              max={filters.cooldown.max}
              bounds={meta.bounds.cooldown}
              presets={[
                { label: '无冷却', min: 0, max: 0 },
                { label: '≤5', min: null, max: 5 },
                { label: '6–15', min: 6, max: 15 },
                { label: '16–30', min: 16, max: 30 },
                { label: '>30', min: 31, max: null },
              ]}
              onChange={(next) => set('cooldown', next)}
            />
            <div>
              <p className="mb-1 text-[11.5px] font-medium text-muted">固定冷却</p>
              <div className="flex flex-wrap gap-1" role="radiogroup" aria-label="固定冷却">
                {COOLDOWN_KIND_OPTIONS.map((option) => (
                  <button
                    key={option.value}
                    type="button"
                    role="radio"
                    aria-checked={filters.cooldownKind === option.value}
                    // `aria-pressed` is what styles.css keys the active state off.
                    aria-pressed={filters.cooldownKind === option.value}
                    className="btn px-2 py-0.5 text-[11.5px]"
                    onClick={() => set('cooldownKind', option.value)}
                  >
                    {option.label}
                    {option.value !== 'any' && (
                      <span className="ml-1 text-subtle">
                        {option.value === 'fixed' ? cooldownCounts.fixed : cooldownCounts.normal}
                      </span>
                    )}
                  </button>
                ))}
              </div>
              <p className="mt-1 text-[11px] leading-snug text-subtle">
                「固定」＝任何效果都不能增减它的冷却（源码 <code>fixed_cooldown</code>），
                与数值是否随技能等级变化无关——超越永恒是固定 50，狂热是固定但随等级
                <code>44–24</code>。超越永恒/时空回响这类减 CD 效果会跳过它们。
              </p>
            </div>
            <label className="flex cursor-pointer items-center gap-2 text-[12px]">
              <input
                type="checkbox"
                className="accent-[var(--accent)]"
                checked={filters.includeNoCooldown}
                onChange={(e) => set('includeNoCooldown', e.target.checked)}
              />
              包含没有冷却的技能（被动 / 持续）
            </label>
          </div>
        </Section>

        <Section title="使用速度" activeCount={filters.useSpeeds.length}>
          <CheckList
            options={meta.facets.useSpeed}
            selected={filters.useSpeeds}
            onToggle={(value) => toggleIn('useSpeeds', value)}
          />
        </Section>

        <Section title="射程" activeCount={filters.range.min !== null || filters.range.max !== null ? 1 : 0}>
          <div className="space-y-3">
            <NumberRange
              label="射程"
              unit="码"
              min={filters.range.min}
              max={filters.range.max}
              bounds={meta.bounds.range}
              presets={[
                { label: '近战', min: null, max: 1 },
                { label: '≤5', min: null, max: 5 },
                { label: '6–10', min: 6, max: 10 },
                { label: '>10', min: 11, max: null },
              ]}
              onChange={(next) => set('range', next)}
            />
            <div>
              <p className="mb-1 text-[11.5px] font-medium text-muted">射程类型</p>
              <CheckList
                options={meta.facets.rangeKind}
                selected={filters.rangeKinds}
                onToggle={(value) => toggleIn('rangeKinds', value)}
                labelFor={(value) => RANGE_KIND_LABELS[value as keyof typeof RANGE_KIND_LABELS] ?? value}
              />
            </div>
          </div>
        </Section>

        <Section
          title="资源消耗"
          activeCount={filters.resources.length + filters.costKinds.length}
        >
          <div className="space-y-3">
            <div>
              <p className="mb-1 text-[11.5px] font-medium text-muted">资源类型</p>
              <CheckList
                options={meta.facets.resource}
                selected={filters.resources}
                onToggle={(value) => toggleIn('resources', value)}
                labelFor={(value) => RESOURCE_LABELS[value] ?? value}
              />
            </div>
            <div>
              <p className="mb-1 text-[11.5px] font-medium text-muted">消耗方式</p>
              <CheckList
                options={meta.facets.costKind}
                selected={filters.costKinds}
                onToggle={(value) => toggleIn('costKinds', value)}
                labelFor={(value) => COST_KIND_LABELS[value as keyof typeof COST_KIND_LABELS] ?? value}
              />
            </div>
          </div>
        </Section>

        <Section title="技能需求" activeCount={filters.requireLevel.min !== null || filters.requireLevel.max !== null ? 1 : 0}>
          <NumberRange
            label="需求等级"
            min={filters.requireLevel.min}
            max={filters.requireLevel.max}
            bounds={{ min: 0, max: 50 }}
            presets={[
              { label: '0–4', min: 0, max: 4 },
              { label: '5–9', min: 5, max: 9 },
              { label: '10+', min: 10, max: null },
            ]}
            onChange={(next) => set('requireLevel', next)}
          />
        </Section>

        <Section title="技能标记" activeCount={filters.flags.length}>
          <CheckList
            options={meta.facets.flag}
            selected={filters.flags}
            onToggle={(value) => toggleIn('flags', value)}
            labelFor={flagLabel}
            searchable
            maxHeight={240}
          />
        </Section>
      </div>
    </div>
  );
}
