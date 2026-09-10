/**
 * Types for the shared scaling core (src/lib/scaling-core.js).
 * The implementation is plain JavaScript so the data build script can import it
 * without a bundler; keep these signatures in sync with that file.
 */

export interface ScalingParamCore {
  label: string;
  kind: 'talentLevel' | 'coefficient' | 'power' | 'stat' | 'other';
  value: number | null;
  ladder: number[];
  editable: boolean;
  min?: number;
  max?: number;
  step?: number;
}

export interface AcronymCore {
  className: string;
  axisLabel?: string | null;
  /** Parameters that share the axis ladder and ride it in lockstep. */
  axisLabels?: string[];
  displayed: number[];
  suffix: string;
  prefix?: string;
  tail?: string;
  params: ScalingParamCore[];
  family: 'talentScale' | 'spellDamage' | 'mindDamage' | 'physicalDamage' | 'steamDamage' | 'statDamage' | 'talentLimit' | 'weaponDamage' | 'statScale';
  base: number | null;
  max: number | null;
  precision?: number;
  mastery: number;
  lua?: {
    expr: unknown[];
    file: string;
    line: number;
    argument: number;
    precision: number;
    /** How the export printed an integer: `%d` truncates, `%.0f` rounds. */
    rounding?: 'trunc' | 'round' | null;
    /** State flags the formula was validated against. */
    conditions?: Record<string, boolean> | null;
    /** Another talent's level the export rendered at its baseline of 0. */
    assumed?: Array<{ talent: string; level: number }> | null;
  };
}

export interface SimParamsCore {
  talentLevel: number;
  characterLevel?: number;
  coefficient: number;
  power: number;
  powers?: Record<string, number>;
  stats: Record<string, number>;
  flags?: Record<string, boolean>;
}

export function combatTalentScale(
  talentLevel: number,
  low: number,
  high: number,
  power?: number,
  add?: number,
  shift?: number,
): number;
export function rescaleDamage(value: number): number;
/** chronomancer.lua:153 — paradox modifier (PMod), saturating at 675. */
export function paradoxModifier(paradox: number): number;
/** Combat.lua:1477 — effective combat stat from a raw one. */
export function rescaleCombatStat(raw: number, interval?: number, step?: number): number;
/** The smallest raw combat stat reaching an effective value. */
export function rawCombatStat(effective: number): number;
export function talentPowerDamage(talentLevel: number, base: number, max: number, driver: number): number;
export function talentStatDamage(talentLevel: number, stat: number, base: number, max: number): number;
export function parseAcronymTitle(title: string): ScalingParamCore[];
export function pickFamily(className: string, params: ScalingParamCore[]): AcronymCore['family'];
export function parseAcronyms(html: string, options?: { fit?: boolean }): AcronymCore[];
export function fitCoefficients(acronym: AcronymCore): { base: number | null; max: number | null; mastery?: number };
export function defaultSimParams(acronym: AcronymCore): SimParamsCore;
export function simAtAxis(acronym: AcronymCore, sim: SimParamsCore, axisValue: number): SimParamsCore;
/** Parameters carrying an element-wise copy of the axis ladder, axis included. */
export function axisSiblings(acronym: { params?: ScalingParamCore[] }): ScalingParamCore[];
export function axisLadder(acronym: AcronymCore): { label: string; values: number[] } | null;
export function evaluateAcronym(acronym: AcronymCore, sim: SimParamsCore): number | null;
export function formatValue(value: number | null | undefined, suffix: string): string;
export function formatAcronymValue(acronym: AcronymCore, value: number | null): string;
export function describeParams(acronym: AcronymCore): string;
/** The condition the export rendered its own values under, one line per input. */
export function exportCondition(acronym: AcronymCore): string[];
/** Every simulator input a value reads, in tooltip order. */
export function valueInputs(acronym: AcronymCore): Array<{ key: string; label: string }>;
/** The value a simulation currently holds for one input key. */
export function inputValue(sim: SimParamsCore, key: string): number | null;
