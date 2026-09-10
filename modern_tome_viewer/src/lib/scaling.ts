/**
 * Typed façade over the shared scaling core (src/lib/scaling-core.js).
 *
 * The core is plain JavaScript so the data build script can import it directly
 * without a bundler; this module adds the TypeScript types used by the UI.
 */

import {
  axisLadder as coreAxisLadder,
  axisSiblings as coreAxisSiblings,
  combatTalentScale,
  defaultSimParams as coreDefaultSimParams,
  describeParams,
  evaluateAcronym as coreEvaluateAcronym,
  exportCondition as coreExportCondition,
  formatAcronymValue as coreFormatAcronymValue,
  formatValue,
  inputValue as coreInputValue,
  parseAcronyms as coreParseAcronyms,
  parseAcronymTitle,
  paradoxModifier,
  pickFamily,
  rawCombatStat,
  rescaleCombatStat,
  rescaleDamage,
  simAtAxis as coreSimAtAxis,
  talentPowerDamage,
  talentStatDamage,
  valueInputs as coreValueInputs,
} from './scaling-core.js';

export type ParamKind = 'talentLevel' | 'coefficient' | 'power' | 'stat' | 'other';

export interface ScalingParam {
  label: string;
  kind: ParamKind;
  value: number | null;
  ladder: number[];
  editable: boolean;
  min?: number;
  max?: number;
  step?: number;
}

export type FormulaFamily =
  | 'talentScale'
  | 'spellDamage'
  | 'mindDamage'
  | 'physicalDamage'
  | 'steamDamage'
  | 'statDamage'
  | 'talentLimit'
  | 'weaponDamage'
  | 'statScale';

export interface Acronym {
  className: string;
  /** Label of the parameter the displayed ladder varies; null when none. */
  axisLabel?: string | null;
  /** Parameters that share the axis ladder and ride it in lockstep. */
  axisLabels?: string[];
  displayed: number[];
  suffix: string;
  /** Text the export wraps around the numbers, e.g. "+" before "+16". */
  prefix?: string;
  /** Sentence punctuation the export left after the last number, e.g. ".". */
  tail?: string;
  params: ScalingParam[];
  family: FormulaFamily;
  base: number | null;
  max: number | null;
  mastery: number;
  lua?: {
    expr: unknown[];
    file: string;
    line: number;
    argument: number;
    precision: number;
    /**
     * How the export printed an integer value: Lua's `%d` truncates, `%.0f`
     * rounds. Inferred from the exported ladder during the build, and absent
     * when the ladder cannot tell the two apart.
     */
    rounding?: 'trunc' | 'round' | null;
    /**
     * State flags the formula conditions on (`self:attr("x") and 2 or 1`), at
     * the values that reproduce the exported ladder — the export was rendered by
     * an actor without temporary buffs.
     */
    conditions?: Record<string, boolean> | null;
    /** Another talent's level the export rendered at its baseline of 0. */
    assumed?: Array<{ talent: string; level: number }> | null;
  };
}

export interface SimParams {
  /** Raw talent level (1-5), as invested by the player. */
  talentLevel: number;
  /** Character level, for values that scale with it (e.g. 被捕猎). */
  characterLevel: number;
  coefficient: number;
  /** Legacy single power, kept for formulas and stored sims that predate them. */
  power: number;
  /**
   * The four effective combat stats, keyed by the label the game and the export
   * use (法术强度 / 精神强度 / physical power / steampower). They stay separate
   * because a value may take the best of two different powers.
   */
  powers?: Record<string, number>;
  /** Attribute, resource and sub-talent inputs, keyed by their display label. */
  stats: Record<string, number>;
  /** State flags a conditional formula was validated against. */
  flags?: Record<string, boolean>;
}

export {
  combatTalentScale,
  describeParams,
  formatValue,
  paradoxModifier,
  parseAcronymTitle,
  pickFamily,
  rawCombatStat,
  rescaleCombatStat,
  rescaleDamage,
  talentPowerDamage,
  talentStatDamage,
};

export const parseAcronyms = coreParseAcronyms as (html: string) => Acronym[];
export const defaultSimParams = coreDefaultSimParams as (acronym: Acronym) => SimParams;
export const simAtAxis = coreSimAtAxis as (acronym: Acronym, sim: SimParams, axisValue: number) => SimParams;
export const axisLadder = coreAxisLadder as (acronym: Acronym) => { label: string; values: number[] } | null;
/** Parameters carrying an element-wise copy of the axis ladder, axis included. */
export const axisSiblings = coreAxisSiblings as (acronym: { params?: ScalingParam[] }) => ScalingParam[];

/** One simulator input a value reads; `key` addresses it inside SimParams. */
export interface ValueInput {
  key: string;
  label: string;
}

export const valueInputs = coreValueInputs as (acronym: Acronym) => ValueInput[];
export const inputValue = coreInputValue as (sim: SimParams, key: string) => number | null;
export const exportCondition = coreExportCondition as (acronym: Acronym) => string[];
export const formatAcronymValue = coreFormatAcronymValue as (acronym: Acronym, value: number | null) => string;

/**
 * The parameter a value's ladder was rendered along.
 *
 * Derived from the parameters rather than the stored `axisLabel`, because the
 * build's compact wire format keeps only the parameter tuples — the axis is
 * always the single parameter that carries five values.
 */
export function acronymAxis(acronym: Acronym): { label: string; kind: string; ladder: number[] } | null {
  const param = acronym.params.find((p) => p.ladder.length > 1);
  return param ? { label: param.label, kind: param.kind, ladder: param.ladder } : null;
}
export const evaluateAcronym = coreEvaluateAcronym as (acronym: Acronym, sim: SimParams) => number | null;
