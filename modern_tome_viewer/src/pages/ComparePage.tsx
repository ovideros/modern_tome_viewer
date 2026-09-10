import type { DatasetMeta, TalentEntry } from '../lib/types';
import { COST_KIND_LABELS, RANGE_KIND_LABELS, RESOURCE_LABELS } from '../lib/data';
import { bestId, cooldownValue, costValue, rangeValue } from '../lib/compare';
import { GameText } from '../components/Highlight';
import { TalentIcon } from '../components/TalentBits';

interface ComparePageProps {
  entries: TalentEntry[];
  meta: DatasetMeta;
  onRemove: (id: string) => void;
  onClear: () => void;
  onBack: () => void;
}

interface Row {
  label: string;
  hint?: string;
  render: (talent: TalentEntry) => React.ReactNode;
  /** Optional numeric extractor; when set, the best column is highlighted. */
  numeric?: (talent: TalentEntry) => number | null;
  /** 'lower' (default) or 'higher' is better. */
  better?: 'lower' | 'higher';
  /** Which talent wins: computed from `numeric` when omitted. */
  best?: (talents: TalentEntry[]) => string | null;
}

const ROWS: Row[] = [
  {
    label: '使用模式',
    render: (t) => t.mode || '—',
  },
  {
    label: '冷却时间',
    hint: '越低越好',
    render: (t) => t.cooldown.display ?? '无',
    numeric: cooldownValue,
    better: 'lower',
  },
  {
    label: '使用速度',
    render: (t) => t.useSpeed || '—',
  },
  {
    label: '射程',
    hint: '越远越好',
    render: (t) => (t.range.display ? `${t.range.display}（${RANGE_KIND_LABELS[t.range.kind]}）` : '—'),
    numeric: rangeValue,
    better: 'higher',
  },
  {
    label: '资源消耗',
    hint: '越低越好',
    render: (t) =>
      t.cost.display ? (
        <>
          {t.cost.display}
          {t.cost.resource && (
            <span className="text-subtle">
              {' '}
              · {RESOURCE_LABELS[t.cost.resource] ?? t.cost.resource}
              {t.cost.kind ? `（${COST_KIND_LABELS[t.cost.kind]}）` : ''}
            </span>
          )}
        </>
      ) : (
        '—'
      ),
    numeric: costValue,
    better: 'lower',
  },
  {
    label: '可投点数',
    render: (t) => t.points || '—',
  },
  {
    label: '技能大系',
    render: (t) => (
      <>
        <div>{t.treePlainName}</div>
        <div className="text-[11px] text-subtle">{t.categoryName}</div>
      </>
    ),
  },
  {
    label: '升级需求',
    render: (t) =>
      t.require.length ? (
        <ul className="space-y-0.5">
          {t.require.map((requirement, index) => (
            <li key={index} className="text-[11.5px]">
              <span className="text-subtle">L{index + 1}</span> {requirement.display}
            </li>
          ))}
        </ul>
      ) : (
        '—'
      ),
  },
  {
    label: '技能标记',
    render: (t) => (
      <div className="flex flex-wrap gap-1">
        {Object.keys(t.flags).length ? (
          Object.keys(t.flags).map((flag) => (
            <span key={flag} className="chip">
              {flag}
            </span>
          ))
        ) : (
          <span className="text-subtle">—</span>
        )}
      </div>
    ),
  },
  {
    label: '技能说明',
    render: (t) => (t.text ? <GameText html={t.text} /> : <span className="text-subtle">暂无</span>),
  },
];

export function ComparePage({ entries, meta, onRemove, onClear, onBack }: ComparePageProps) {
  if (!entries.length) {
    return (
      <div className="mx-auto max-w-[1600px] px-4 py-3">
        <div className="panel flex flex-col items-center gap-3 px-6 py-16 text-center">
          <p className="text-[15px] font-semibold">对比列表为空</p>
          <p className="max-w-md text-[12.5px] text-subtle">
            在搜索结果或技能详情里点击「加入对比」，最多可以同时比较 6 个技能。
          </p>
          <button type="button" className="btn btn-primary" onClick={onBack}>
            返回搜索
          </button>
        </div>
      </div>
    );
  }

  const bestByRow = ROWS.map((row) => {
    if (row.best) return row.best(entries);
    if (!row.numeric) return null;
    return bestId(entries, row.numeric, row.better ?? 'lower');
  });

  return (
    <div className="mx-auto max-w-[1600px] px-4 py-3">
      <div className="panel mb-3 flex flex-wrap items-center justify-between gap-2 px-3 py-2.5">
        <div>
          <h1 className="text-[15px] font-semibold">技能对比</h1>
          <p className="text-[11.5px] text-subtle">共 {entries.length} 个技能 · 最优值已高亮</p>
        </div>
        <div className="flex items-center gap-2">
          <button type="button" className="btn" onClick={onBack}>
            返回搜索
          </button>
          <button type="button" className="btn" onClick={onClear}>
            清空对比
          </button>
        </div>
      </div>

      <div className="panel overflow-x-auto">
        <table className="w-full border-collapse text-[12.5px]">
          <thead>
            <tr>
              <th className="sticky left-0 z-10 w-[92px] min-w-[92px] border-b border-r border-line bg-raised px-2 py-2 text-left text-[11.5px] font-semibold text-subtle">
                属性
              </th>
              {entries.map((talent) => (
                <th
                  key={talent.id}
                  className="min-w-[220px] border-b border-line bg-raised px-2 py-2 text-left align-top"
                >
                  <div className="flex items-start gap-2">
                    <TalentIcon talent={talent} size={36} iconSize={meta.iconSize} />
                    <div className="min-w-0 flex-1">
                      <div className="text-[13px] font-semibold">{talent.plainName}</div>
                      <div className="font-mono text-[10.5px] text-subtle">{talent.shortName}</div>
                    </div>
                    <button
                      type="button"
                      className="btn-ghost btn px-1.5 py-0.5 text-[11px]"
                      onClick={() => onRemove(talent.id)}
                      title="从对比中移除"
                    >
                      ✕
                    </button>
                  </div>
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {ROWS.map((row, rowIndex) => (
              <tr key={row.label} className={rowIndex % 2 ? 'bg-sunken/40' : ''}>
                <th className="sticky left-0 z-10 border-b border-r border-line bg-surface px-2 py-2 text-left align-top text-[11.5px] font-semibold text-muted">
                  {row.label}
                  {row.hint && <div className="text-[10.5px] font-normal text-subtle">{row.hint}</div>}
                </th>
                {entries.map((talent) => {
                  const isBest = bestByRow[rowIndex] === talent.id && entries.length > 1;
                  return (
                    <td
                      key={talent.id}
                      className={`border-b border-line px-2 py-2 align-top ${
                        isBest ? 'bg-accent-soft/50 font-semibold text-accent-strong' : ''
                      }`}
                    >
                      {row.render(talent)}
                      {isBest && <span className="ml-1 text-[10.5px]">★</span>}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <p className="mt-2 px-1 text-[11px] text-subtle">
        ★ 表示该行中数值最优的技能（冷却 / 消耗越低越好，射程越高越好）；无冷却的技能不参与冷却比较。
      </p>
    </div>
  );
}
