import { useMemo, type ReactNode } from 'react';
import {
  acronymAxis,
  evaluateAcronym,
  exportCondition,
  formatAcronymValue,
  inputValue,
  simAtAxis,
  valueInputs,
} from '../lib/scaling';
import { HoverTip } from './HoverTip';
import type { Acronym, SimParams } from '../lib/scaling';

/**
 * Renders game text, replacing every `<acronym>` value with a live number.
 *
 * The numbers always reflect the simulator's current inputs — a value shown
 * next to a coefficient slider reading 1.0 is the value at 1.0, not the export's
 * own. Each value's tooltip names the inputs it reads and the values they
 * currently hold, so text, sliders and tooltip can never disagree.
 */
/** How a talent's values should be presented. */
export interface DisplayOptions {
  /**
   * Investable points. A talent capped at one point has no talent-level
   * dimension: the export still lists five levels, but the player cannot buy
   * them, so its values describe one situation and read as a single number.
   */
  points: number;
}

export function VariableText({
  html,
  acronyms,
  sim,
  display,
  className,
}: {
  html: string;
  acronyms: Acronym[];
  sim?: SimParams;
  display?: DisplayOptions;
  className?: string;
}) {
  const nodes = useMemo(
    () => buildNodes(html, acronyms, sim, display),
    [html, acronyms, sim, display],
  );
  return <div className={`talent-text ${className ?? ''}`}>{nodes}</div>;
}

/** True when at least one value can be recomputed. */
export function hasSimulatableValues(acronyms: Acronym[]): boolean {
  // A source formula counts too, even though it carries no fitted coefficients.
  return acronyms.some((acronym) => Boolean(acronym.lua) || (acronym.base !== null && acronym.max !== null));
}

/** A value's own numbers, read back out of a placeholder. */
const NUMBER_PATTERN = /-?\d+(?:\.\d+)?/g;

function numbersOf(text: string): number[] {
  return [...text.matchAll(NUMBER_PATTERN)].map((match) => Number(match[0]));
}

/** Same ladder, allowing for the export's own rounding of a decimal. */
function sameLadder(a: number[], b: number[]): boolean {
  return a.length === b.length && a.every((value, i) => Math.abs(value - b[i]) <= Math.max(1e-9, Math.abs(b[i]) * 1e-9));
}

/**
 * Pair each `<acronym>` placeholder with the value that belongs to it.
 *
 * Matching is by the numbers the placeholder itself shows, not by position
 * alone, because a description can contain a placeholder that carries **no**
 * numbers: a word ladder such as 护甲掌握's 降低护甲/增加护甲 or 鲁莽冲撞's
 * 体型词. The build emits no value for those, and counting them as one shifted
 * every later sentence onto the wrong number. When nothing matches — the export
 * and the extracted values disagree — this falls back to the next unused value,
 * which is exactly the old positional pairing.
 */
function buildNodes(
  html: string,
  acronyms: Acronym[],
  sim?: SimParams,
  display?: DisplayOptions,
): ReactNode[] {
  if (!acronyms.length) return [<span key="raw" dangerouslySetInnerHTML={{ __html: html }} />];

  const nodes: ReactNode[] = [];
  const pattern = /<acronym class="([^"]+)" title="([^"]*)">([^<]*)<\/acronym>/g;
  const used = new Set<number>();
  let cursor = 0;

  for (const match of html.matchAll(pattern)) {
    const start = match.index ?? 0;
    if (start > cursor) {
      nodes.push(<span key={`t${start}`} dangerouslySetInnerHTML={{ __html: html.slice(cursor, start) }} />);
    }
    cursor = start + match[0].length;

    const shown = numbersOf(match[3]);
    if (!shown.length) {
      // A word ladder has nothing to substitute; keep the export's own text.
      nodes.push(<span key={`w${start}`} dangerouslySetInnerHTML={{ __html: match[0] }} />);
      continue;
    }

    let index = acronyms.findIndex((acronym, i) => !used.has(i) && sameLadder(acronym.displayed, shown));
    if (index < 0) index = acronyms.findIndex((_, i) => !used.has(i));
    if (index < 0) {
      nodes.push(<span key={`x${start}`} dangerouslySetInnerHTML={{ __html: match[0] }} />);
      continue;
    }
    used.add(index);
    nodes.push(<ValueSpan key={`v${index}`} acronym={acronyms[index]} sim={sim} display={display} />);
  }
  if (cursor < html.length) {
    nodes.push(<span key="tail" dangerouslySetInnerHTML={{ __html: html.slice(cursor) }} />);
  }
  return nodes;
}

function ValueSpan({
  acronym,
  sim,
  display,
}: {
  acronym: Acronym;
  sim?: SimParams;
  display?: DisplayOptions;
}) {
  const simulatable = Boolean(acronym.lua) || (acronym.base !== null && acronym.max !== null);
  const points = display?.points ?? 5;
  const axis = acronymAxis(acronym);
  // A value's ladder is the talent's own levels — five buyable ones, or the
  // export's unattainable 1-5 for a one-point talent. Any other axis (character
  // level, spell power, an attribute) is a continuous slider input instead, so
  // the export's five samples must not be presented as the current state.
  const levels = !axis || axis.label === '技能等级';
  const sweep = axis ? axis.ladder : (acronym.params.find((p) => p.label === '技能等级')?.ladder ?? [1, 2, 3, 4, 5]);
  const ladder = simulatable && Boolean(sim) && points > 1 && levels && sweep.length > 1;

  // One number for the current inputs, or the ladder of buyable talent levels.
  const computed = simulatable && sim
    ? (ladder ? sweep.map((value) => evaluateAcronym(acronym, simAtAxis(acronym, sim, value))) : [evaluateAcronym(acronym, sim)])
    : null;
  const selectedIndex = ladder && sim ? sweep.indexOf(sim.talentLevel) : -1;
  // The export wraps more than a bare list in one <acronym>: a sign ("+16"),
  // a unit ("1%"), a repeated sentence fragment, or a closing period.
  const prefix = acronym.prefix ?? '';
  const tail = acronym.tail ?? '';
  const reference = `${acronym.displayed.map((value) => `${prefix}${value}${acronym.suffix}`).join(', ')}${tail}`;

  return (
    <HoverTip
      data-testid={`${acronym.lua ? 'source' : simulatable ? 'estimated' : 'reference'}-value`}
      className={`cursor-help border-b border-dotted font-semibold ${
        simulatable ? 'border-accent text-accent-strong' : 'border-line-strong text-muted'
      }`}
      content={
        <TipBody acronym={acronym} simulatable={simulatable} sim={sim} ladder={ladder} sweep={sweep} reference={reference} />
      }
    >
      {computed
        ? computed.map((value, index) => {
            const emphasised = !ladder || index === selectedIndex;
            return (
              <span key={index} className={emphasised ? 'rounded bg-accent-soft px-0.5' : ''}>
                {index > 0 && ', '}
                {prefix}
                {formatAcronymValue(acronym, value)}
                {index === computed.length - 1 && tail}
              </span>
            );
          })
        : reference}
    </HoverTip>
  );
}

function TipBody({
  acronym,
  simulatable,
  sim,
  ladder,
  sweep,
  reference,
}: {
  acronym: Acronym;
  simulatable: boolean;
  sim?: SimParams;
  ladder: boolean;
  sweep: number[];
  reference: string;
}) {
  const inputs = useMemo(() => valueInputs(acronym), [acronym]);
  const conditions = simulatable && sim
    ? inputs
        .map((input) => {
          const value = inputValue(sim, input.key);
          return value === null ? null : `${input.label} ${trimNumber(value)}`;
        })
        .filter(Boolean)
    : null;
  const exported = exportCondition(acronym);
  // A value recomputed from validated game source does not need the export's
  // own numbers repeated next to it: they describe the same formula. Fitted and
  // reference-only values keep them, because there the export *is* the data.
  const showExport = !acronym.lua;

  return (
    <>
      <span className="block font-semibold text-fg">数值说明</span>
      <span className="block text-muted">
        {/* The condition the number belongs to: the sliders' current values. */}
        {conditions?.length ? `当前条件：${conditions.join('，')}` : `取决于：${exported.join('，')}`}
      </span>
      {simulatable ? (
        <span className="mt-1 block text-subtle">
          {acronym.lua ? '源码公式' : '反解估算'}
          {acronym.family ? `：${FAMILY_LABELS[acronym.family] ?? acronym.family}` : ''}
          {!acronym.lua && acronym.base !== null && ` · 系数 ${acronym.base} / ${acronym.max}`}
          {acronym.lua && (
            <span className="block">
              来源：{acronym.lua.file}:{acronym.lua.line}
            </span>
          )}
          {acronym.lua?.conditions && (
            <span className="block">
              按导出渲染时的状态：
              {Object.entries(acronym.lua.conditions)
                .map(([flag, on]) => `${flag} ${on ? '开' : '关'}`)
                .join('，')}
            </span>
          )}
          {acronym.lua?.assumed?.length ? (
            <span className="block">
              另一技能等级按基准 0 计：
              {acronym.lua.assumed.map((entry) => `${entry.talent.replace(/^T_/, '')}=${entry.level}`).join('，')}
            </span>
          ) : null}
          {!acronym.lua && <span className="block">可复现参考数据，其他输入下可能存在偏差。</span>}
        </span>
      ) : (
        <span className="mt-1 block text-subtle">该数值无法参数化重算，仅显示数据参考值。</span>
      )}
      {ladder && (
        <span className="mt-1 block text-subtle">
          五个数值依次对应技能等级 {sweep[0]}–{sweep[sweep.length - 1]}。
        </span>
      )}
      {showExport && (
        <>
          <span className="mt-1 block text-subtle">导出参考值：{reference}</span>
          {conditions?.length ? <span className="block text-subtle">导出条件：{exported.join('，')}</span> : null}
        </>
      )}
    </>
  );
}

/** Input values keep their decimals but drop float noise from the multipliers. */
function trimNumber(value: number): string {
  return Number.isInteger(value) ? String(value) : String(Number(value.toFixed(3)));
}

const FAMILY_LABELS: Record<string, string> = {
  talentLimit: 'combatTalentLimit',
  weaponDamage: 'combatTalentWeaponDamage',
  statScale: 'combatStatScale',
  talentScale: '按技能等级缩放',
  spellDamage: '法术伤害公式',
  mindDamage: '精神伤害公式',
  physicalDamage: '物理伤害公式',
  steamDamage: '蒸汽伤害公式',
  statDamage: '属性伤害公式',
  actor: '按角色状态计算',
};

/** Backwards-compatible wrapper for places that only need static markup. */
export function GameText({ html, className }: { html: string; className?: string }): ReactNode {
  return <div className={`talent-text ${className ?? ''}`} dangerouslySetInnerHTML={{ __html: html }} />;
}
