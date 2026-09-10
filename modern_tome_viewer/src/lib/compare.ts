/**
 * Numeric extraction and "best value" selection for the comparison table.
 * Kept free of React so it can be unit-tested against the real dataset.
 */

import type { TalentEntry } from './types';

/** Cooldown used for comparison: the lowest value of the level ladder. */
export function cooldownValue(talent: TalentEntry): number | null {
  return talent.cooldown.min;
}

/** Range used for comparison: the highest value of the level ladder. */
export function rangeValue(talent: TalentEntry): number | null {
  return talent.range.max;
}

/** Resource amount consumed per use. */
export function costValue(talent: TalentEntry): number | null {
  return talent.cost.amount;
}

export type Direction = 'lower' | 'higher';

/** Id of the talent with the best value, or null when none has one. */
export function bestId(
  talents: TalentEntry[],
  extract: (talent: TalentEntry) => number | null,
  direction: Direction = 'lower',
): string | null {
  let best: string | null = null;
  let bestValue = direction === 'higher' ? Number.NEGATIVE_INFINITY : Number.POSITIVE_INFINITY;
  for (const talent of talents) {
    const value = extract(talent);
    if (value === null || !Number.isFinite(value)) continue;
    if (direction === 'higher' ? value > bestValue : value < bestValue) {
      bestValue = value;
      best = talent.id;
    }
  }
  return best;
}

export interface CompareRow {
  key: string;
  label: string;
  hint?: string;
  numeric?: (talent: TalentEntry) => number | null;
  direction?: Direction;
}

/** The numeric rows of the comparison table, in display order. */
export const NUMERIC_ROWS: CompareRow[] = [
  { key: 'cooldown', label: '冷却时间', hint: '越低越好', numeric: cooldownValue, direction: 'lower' },
  { key: 'range', label: '射程', hint: '越远越好', numeric: rangeValue, direction: 'higher' },
  { key: 'cost', label: '资源消耗', hint: '越低越好', numeric: costValue, direction: 'lower' },
];

/** Map of row key -> winning talent id, for highlighting. */
export function bestByRow(talents: TalentEntry[]): Record<string, string | null> {
  const out: Record<string, string | null> = {};
  for (const row of NUMERIC_ROWS) {
    if (row.numeric) out[row.key] = bestId(talents, row.numeric, row.direction ?? 'lower');
  }
  return out;
}
