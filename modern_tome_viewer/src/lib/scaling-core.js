import { evaluateLuaExpression, formulaActorInputs, formulaCalls, formulaDependencies, POWER_LABELS } from './lua-formula.js';

/**
 * Shared scaling core. Validated Lua expressions take priority during evaluation;
 * the original numerical fit remains an explicitly approximate compatibility fallback.
 * A fixed-power ladder identifies one amplitude, not unique base/max coefficients.
 */

// ---------------------------------------------------------------------------
// Game formulas
// ---------------------------------------------------------------------------

/** combatTalentScale: matches `low` at talent level 1 and `high` at level 5. */
export function combatTalentScale(talentLevel, low, high, power = 0.5, add = 0, shift = 0) {
  const tl = talentLevel <= 0 ? 0.1 : talentLevel;
  const xLow = 1;
  const xHigh = 5;
  const xLowAdj = (xLow + shift) ** power;
  const xHighAdj = (xHigh + shift) ** power;
  const m = (high - low) / (xHighAdj - xLowAdj);
  const b = low - m * xLowAdj;
  return Math.max(0, m * (tl + shift) ** power + b + add);
}

/** rescaleDamage: the final step of every combat damage helper. */
export function rescaleDamage(value) {
  if (value <= 0) return value;
  return value ** 1.04;
}

/**
 * Shared shape of combatTalent{Spell,Mind,Physical,Steam}Damage:
 *   mod    = max / ((base + 100) * ((sqrt(5) - 1) * 0.8 + 1))
 *   raw    = (base + driver) * ((sqrt(tl) - 1) * 0.8 + 1) * mod
 *   result = rescaleDamage(raw)
 * `driver` is the power stat (spell/mind/physical/steam) or a fixed attribute
 * for combatTalentStatDamage.
 */
export function talentPowerDamage(talentLevel, base, max, driver) {
  const mod = max / ((base + 100) * ((Math.sqrt(5) - 1) * 0.8 + 1));
  const raw = (base + driver) * ((Math.sqrt(talentLevel) - 1) * 0.8 + 1) * mod;
  return rescaleDamage(raw);
}

/** combatTalentStatDamage without the optional diminishing-returns branch. */
export function talentStatDamage(talentLevel, stat, base, max) {
  return talentPowerDamage(talentLevel, base, max, stat);
}

/**
 * `rescaleCombatStats` — Combat.lua:1477, the convex hull of
 * `x, 20 + (x-20)/2, 40 + (x-60)/3, …`, floored.
 *
 * The damage helpers take an *effective* combat stat: `combatSpellpower()` is
 * this curve applied to the raw one (`combat_spellpower + getMag() + bonuses`),
 * so the character sheet prints "Spellpower: +N (M eff.)" — N raw, M effective.
 */
export function rescaleCombatStat(raw, interval = 20, step = 1) {
  const x = Number(raw);
  if (!Number.isFinite(x)) return NaN;
  let result = x;
  let shift = 1 + step;
  let tier = interval;
  let base = interval;
  for (;;) {
    const next = tier + (x - base) / shift;
    if (next < result) {
      result = next;
      base += interval * shift;
      tier += interval;
      shift += step;
    } else {
      return Math.floor(result);
    }
  }
}

/**
 * Paradox modifier (PMod) — `getParadoxModifier` in
 * `data/talents/chronomancy/chronomancer.lua:153`.
 *
 *   pm = sqrt(paradox / 300)   (linear below 300: pm = paradox / 300)
 *   pm = bound(pm, 0.5, 1.5)
 *
 * It drives paradox cost and chronomancy spellpower, and **saturates at +50%
 * when paradox = 675** (sqrt(675/300) = 1.5); below that it bottoms out at -50%
 * when paradox = 150. Paradox itself has no cap — 675 is simply the point past
 * which raising it changes nothing, which is why the slider stops there.
 */
export function paradoxModifier(paradox) {
  const value = Number(paradox);
  if (!Number.isFinite(value)) return 1;
  const raw = value < 300 ? value / 300 : Math.sqrt(value / 300);
  return Math.min(1.5, Math.max(0.5, raw));
}

/**
 * The raw combat stat behind an effective one.
 *
 * Only the smallest raw value reaching that effective value can be named: the
 * curve is many-to-one and floored, so the result reads as a lower bound
 * (`原始值 ≥300` for an effective 100). Effective 100 needs raw 300, and
 * effective 200 needs raw 1100 — which is why the simulator's power slider
 * stops at 200.
 */
export function rawCombatStat(effective) {
  const y = Number(effective);
  if (!Number.isFinite(y)) return NaN;
  if (y <= 20) return Math.max(0, Math.round(y));
  // The segment that dominates at this value: 1 for (20,40], 4 for (80,100]…
  const tier = Math.ceil(y / 20) - 1;
  const base = 10 * tier * (tier + 1);
  return base + (y - 20 * tier) * (tier + 1);
}

// ---------------------------------------------------------------------------
// Parsing
// ---------------------------------------------------------------------------

const KIND_BY_LABEL = {
  技能系数: 'coefficient',
  法术强度: 'power',
  精神强度: 'power',
  'physical power': 'power',
  steampower: 'power',
  paradox: 'stat',
  psi: 'stat',
  力量: 'stat',
  敏捷: 'stat',
  体质: 'stat',
  魔力: 'stat',
  意志: 'stat',
  灵巧: 'stat',
  幸运: 'stat',
  // Character level is an actor input the reader can dial in, so it behaves
  // like any other stat dimension rather than being unmodellable.
  角色等级: 'stat',
};

const STAT_LABELS = new Set(['力量', '敏捷', '体质', '魔力', '意志', '灵巧', '幸运', 'psi']);

/**
 * Which effective combat stat each damage family consumes.
 *
 * Four powers exist and a value may take the best of two of them, so each label
 * keeps its own number in `sim.powers`; the titles and the tooltips use these
 * same labels.
 */
const FAMILY_POWER_LABELS = {
  spellDamage: '法术强度',
  mindDamage: '精神强度',
  physicalDamage: 'physical power',
  steamDamage: 'steampower',
};
/** The four power labels, in title order. */
const POWER_LABEL_LIST = Object.values(FAMILY_POWER_LABELS);

const NUM = String.raw`-?\d+(?:\.\d+)?`;
const NUM_RE = new RegExp(NUM, 'g');

/**
 * Text that wraps an acronym's numbers, e.g. `"+16, +22"` → prefix `"+"`,
 * `"1%, 2%"` → suffix `"%"`, `"0.36, 1.38."` → tail `"."`.
 *
 * The export sometimes wraps more than a bare list in one `<acronym>`: signs
 * (`+16, +22`), whole repeated sentence fragments, even a paragraph. Reading the
 * unit as "everything that is not a number" concatenates all of it (the classic
 * bug produced `+++++`), so the affixes are read from the outer text only, and
 * a suffix that is nothing but sentence punctuation is emitted once at the end.
 */
function affixes(inner) {
  const segments = String(inner ?? '').split(NUM_RE);
  const prefix = (segments[0] ?? '').replace(/[\s,，、]+$/, '');
  const raw = segments.length > 1 ? (segments[segments.length - 1] ?? '').replace(/^[\s,，、]+/, '').replace(/\s+$/, '') : '';
  const sentenceOnly = /^[.。,，;；!！?？:：、\s]*$/.test(raw);
  return { prefix, suffix: sentenceOnly ? '' : raw, tail: sentenceOnly ? raw.trim() : '' };
}

/** Parse a title such as "以下状况的数值<br>技能等级 1-5,<br>技能系数 1.50,<br>法术强度 100". */
export function parseAcronymTitle(title) {
  const params = [];
  for (const rawLine of String(title ?? '').split(/<br\s*\/?>/i)) {
    const line = rawLine
      .replace(/^以下状况的数值\s*,?\s*/, '')
      .trim()
      .replace(/,$/, '')
      .trim();
    if (!line) continue;

    const range = line.match(new RegExp(`^(.*?)\\s*(${NUM})\\s*[-–]\\s*(${NUM})$`));
    if (range && /等级/.test(range[1])) {
      const from = Number(range[2]);
      const to = Number(range[3]);
      params.push({
        label: range[1].trim() || '技能等级',
        kind: 'talentLevel',
        value: null,
        ladder: Array.from({ length: Math.max(0, Math.round(to - from) + 1) }, (_, i) => from + i),
        editable: true,
        min: 0.5,
        max: 10,
        step: 0.1,
      });
      continue;
    }

    const numbers = [...line.matchAll(NUM_RE)].map((m) => Number(m[0]));
    if (!numbers.length) continue;
    const label = line.replace(new RegExp(`${NUM}|[,%]`, 'g'), '').trim();
    const kind = KIND_BY_LABEL[label] ?? (/技能系数/.test(label) ? 'coefficient' : 'other');
    const ladder = numbers.length > 1 ? numbers : [];
    const param = {
      label: label || '参数',
      kind,
      value: numbers.length === 1 ? numbers[0] : null,
      ladder,
      editable: kind === 'coefficient' || kind === 'power' || kind === 'stat',
    };
    if (kind === 'coefficient') {
      param.min = 0.1;
      param.max = 5;
      param.step = 0.1;
    } else if (kind === 'power') {
      param.min = 0;
      param.max = 500;
      param.step = 1;
    } else if (kind === 'stat') {
      param.min = 0;
      param.max = 1000;
      param.step = 1;
    }
    params.push(param);
  }
  return params;
}

/** Decide which scaling family produced an acronym's numbers. */
export function pickFamily(className, params) {
  const hasExact = (label) => params.some((p) => p.label === label);
  const hasStat = params.some((p) => STAT_LABELS.has(p.label));
  if (className === 'stat-variable' || hasExact('角色等级')) return 'statDamage';
  if (hasExact('法术强度')) return 'spellDamage';
  if (hasExact('精神强度')) return 'mindDamage';
  if (hasExact('physical power')) return 'physicalDamage';
  if (hasExact('steampower')) return 'steamDamage';
  if (hasStat) return 'statDamage';
  if (className === 'talent-variable') return 'talentScale';
  return 'spellDamage';
}

/** Parse every acronym inside an info_text string and fit its coefficients. */
export function parseAcronyms(html, { fit = true } = {}) {
  const out = [];
  const pattern = /<acronym class="([^"]+)" title="([^"]*)">([^<]*)<\/acronym>/g;
  for (const match of String(html ?? '').matchAll(pattern)) {
    const [, className, title, inner] = match;
    const numbers = [...inner.matchAll(NUM_RE)].map((m) => Number(m[0]));
    if (!numbers.length) continue;
    const params = parseAcronymTitle(title);
    // Which parameter the five displayed values vary. The title marks it by
    // giving that parameter five values instead of one, and it is not always the
    // talent level: 时空调谐 varies spell power, 被捕猎 varies character level.
    const axis = params.find((p) => p.ladder.length > 1) ?? null;
    const wrap = affixes(inner);
    const acronym = {
      className,
      axisLabel: axis ? axis.label : null,
      displayed: numbers,
      ...wrap,
      precision: Math.max(...[...inner.matchAll(NUM_RE)].map(m => (m[0].split('.')[1] || '').length)),
      params,
      family: pickFamily(className, params),
      base: null,
      max: null,
      mastery: 1,
    };
    if (fit) Object.assign(acronym, fitCoefficients(acronym));
    out.push(acronym);
  }
  return out;
}

// ---------------------------------------------------------------------------
// Fitting
// ---------------------------------------------------------------------------

const DEFAULT_TALENT_LEVELS = [1, 2, 3, 4, 5];
/** Ladders are rendered at raw level × mastery; 1.3 dominates, others exist. */
const MASTERY_CANDIDATES = [1.3, 1, 1.2, 1.1, 0.9, 1.4, 1.5];

function ssePowerDamage(shown, levels, driver, base, max) {
  let total = 0;
  for (let i = 0; i < shown.length; i += 1) {
    const predicted = talentPowerDamage(levels[i] ?? levels[0], base, max, driver);
    total += (predicted - shown[i]) ** 2;
  }
  return total;
}

/**
 * Coarse 2D grid plus shrinking local refinement.
 *
 * Historical compatibility algorithm. At a fixed driver, base/max are not
 * separately identifiable: only max*(base+driver)/(base+100) is constrained.
 * A good reference fit does not establish correctness at other power values.
 */
function gridFitPowerDamage(shown, levels, driver) {
  let best = null;
  const maxFloor = Math.max(1, Math.min(...shown) - driver);
  for (let base = 0; base <= 300; base += 2) {
    if (base + driver <= 0) continue;
    for (let max = maxFloor; max <= maxFloor + 3000; max += 4) {
      const err = ssePowerDamage(shown, levels, driver, base, max);
      if (!best || err < best.err) best = { base, max, err };
    }
  }
  if (!best) return null;

  let current = best;
  for (const step of [8, 4, 2, 1, 0.5, 0.25, 0.1, 0.05, 0.01]) {
    let improved = true;
    while (improved) {
      improved = false;
      for (const dBase of [-step, 0, step]) {
        for (const dMax of [-step, 0, step]) {
          const nextBase = current.base + dBase;
          const nextMax = current.max + dMax;
          if (nextBase <= -99 || nextMax <= 0) continue;
          const err = ssePowerDamage(shown, levels, driver, nextBase, nextMax);
          if (err < current.err - 1e-12) {
            current = { base: nextBase, max: nextMax, err };
            improved = true;
          }
        }
      }
    }
  }
  return current;
}

function fitPowerDamage(acronym) {
  // Power-family helpers and the fixed-stat form of combatTalentStatDamage share
  // this shape; only the driver differs.
  const driver =
    acronym.family === 'statDamage'
      ? (acronym.params.find((p) => p.kind === 'stat' && p.value !== null)?.value ?? null)
      : (acronym.params.find((p) => p.kind === 'power')?.value ?? 100);
  if (driver === null) return { base: null, max: null };

  const shown = acronym.displayed;
  if (shown.length < 2 || shown.some((v) => v <= 0)) return { base: null, max: null };

  const rawLevels = acronym.params.find((p) => p.kind === 'talentLevel')?.ladder;
  const raw = rawLevels && rawLevels.length ? rawLevels : DEFAULT_TALENT_LEVELS;

  let best = null;
  for (const mastery of MASTERY_CANDIDATES) {
    const levels = raw.map((level) => level * mastery);
    const candidate = gridFitPowerDamage(shown, levels, driver);
    if (!candidate) continue;
    if (!best || candidate.err < best.err) best = { ...candidate, mastery };
  }
  if (!best) return { base: null, max: null };

  const tolerance = shown.reduce((sum, value) => sum + Math.max(2, value * 0.05) ** 2, 0);
  if (best.err > tolerance) return { base: null, max: null };
  return {
    base: Math.round(best.base * 100) / 100,
    max: Math.round(best.max * 100) / 100,
    mastery: best.mastery,
  };
}

/** combatTalentScale: base/max carry the low/high endpoints. */
function fitTalentScale(acronym) {
  const shown = acronym.displayed;
  const levels = acronym.params.find((p) => p.kind === 'talentLevel')?.ladder;
  if (shown.length < 2 || !levels || !levels.length) return { base: null, max: null, mastery: 1 };
  const low = shown[0];
  const high = shown[shown.length - 1];
  const err = shown.reduce((sum, value, index) => {
    const predicted = combatTalentScale(levels[index] ?? levels[0], low, high);
    return sum + (predicted - value) ** 2;
  }, 0);
  const tolerance = shown.reduce((sum, value) => sum + Math.max(0.5, Math.abs(value) * 0.1) ** 2, 0);
  if (err > tolerance) return { base: null, max: null, mastery: 1 };
  return { base: low, max: high, mastery: 1 };
}

export function fitCoefficients(acronym) {
  switch (acronym.family) {
    case 'talentScale':
      return fitTalentScale(acronym);
    case 'spellDamage':
    case 'mindDamage':
    case 'physicalDamage':
    case 'steamDamage':
    case 'statDamage':
      // Ladder forms such as "法术强度 10, 25, 50, 75, 100" carry no fixed
      // driver, so fitPowerDamage returns null for them.
      return fitPowerDamage(acronym);
    default:
      return { base: null, max: null };
  }
}

// ---------------------------------------------------------------------------
// Evaluation
// ---------------------------------------------------------------------------

/** Default slider values for an acronym, taken from its own title. */
export function defaultSimParams(acronym) {
  const axis = acronym.axisLabel;
  /** A non-axis parameter's pinned value. */
  const pinned = (label) => {
    const param = acronym.params.find((p) => p.label === label);
    if (!param) return null;
    if (param.value !== null && param.value !== undefined) return param.value;
    return param.ladder.length ? param.ladder[0] : null;
  };

  const levels = acronym.params.find((p) => p.label === '技能等级');
  const stats = {};
  for (const param of acronym.params) {
    if (param.label === '技能等级' || param.label === '技能系数') continue;
    // Attributes, resources (paradox/psi), saves and another talent's level are
    // all read through `actor` lookups, so they share the stat map.
    const value = param.value ?? param.ladder[0];
    if (Number.isFinite(value)) stats[param.label] = value;
  }
  const powers = {};
  for (const param of acronym.params) {
    if (param.kind === 'power') powers[param.label] = param.value ?? param.ladder[0] ?? 100;
  }
  // A value whose family consumes a power the title never names still needs one.
  const familyPower = FAMILY_POWER_LABELS[acronym.family];
  if (familyPower && !(familyPower in powers)) powers[familyPower] = 100;

  return {
    // The axis is varied by simAtAxis; give it the first ladder value here so a
    // caller that evaluates without varying still gets a valid reading.
    talentLevel: axis === '技能等级'
      ? (levels?.ladder[0] ?? 1)
      : (pinned('技能等级') ?? 1),
    // A title may pin the character level without varying it (e.g. 饥荒挽歌
    // renders its regen ladder at 角色等级 50 for talent levels 1-5).
    characterLevel: pinned('角色等级') ?? 1,
    coefficient: pinned('技能系数') ?? 1,
    // Legacy single-value field, kept as the fallback for callers (and stored
    // data) that predate per-type powers.
    power: Object.values(powers)[0] ?? 100,
    powers,
    stats,
  };
}

/** Slider definition for the axis this value varies along. */
export function axisLadder(acronym) {
  if (!acronym.axisLabel) return null;
  const param = acronym.params.find((p) => p.label === acronym.axisLabel);
  if (!param || param.ladder.length < 2) return null;
  return { label: acronym.axisLabel, values: param.ladder };
}

/** Recompute one acronym. Returns null when its coefficients could not be fitted. */
/**
 * Substitute the axis value into a simulation for one ladder point.
 *
 * The axis parameter is the only thing the five displayed values vary, so every
 * other input stays at the value the export recorded.
 */
export function simAtAxis(acronym, sim, axisValue) {
  const label = acronym.axisLabel;
  if (!label) return { ...sim, talentLevel: axisValue };
  if (label === '技能等级') return { ...sim, talentLevel: axisValue };
  if (label === '角色等级') return { ...sim, characterLevel: axisValue };

  // Power stats are first-class inputs of the damage formulas, so set the field
  // the formulas read rather than only the generic stat map.
  const next = { ...sim, stats: { ...sim.stats, [label]: axisValue } };
  if (POWER_LABEL_LIST.includes(label)) {
    next.powers = { ...sim.powers, [label]: axisValue };
    next.power = axisValue;
  }
  return next;
}

export function evaluateAcronym(acronym, sim) {
  if (acronym.lua) {
    // A formula validated against the export keeps the state flags it was
    // rendered with (an actor without temporary buffs).
    const scoped = acronym.lua.conditions ? { ...sim, flags: acronym.lua.conditions } : sim;
    const result = evaluateLuaExpression(acronym.lua.expr, scoped);
    return Number.isFinite(result) ? result : null;
  }
  if (acronym.base === null || acronym.max === null) return null;
  // The coefficient is the mastery multiplier the ladder was rendered with; the
  // fitted `mastery` reproduces the data exactly when the two agree.
  const coefficient = sim.coefficient > 0 ? sim.coefficient : 1;
  const scale = acronym.family === 'talentScale' ? 1 : (acronym.mastery * coefficient) / 1.5;
  const effectiveLevel = sim.talentLevel * scale;
  switch (acronym.family) {
    case 'talentScale':
      return combatTalentScale(sim.talentLevel, acronym.base, acronym.max);
    case 'spellDamage':
    case 'mindDamage':
    case 'physicalDamage':
    case 'steamDamage':
      return talentPowerDamage(effectiveLevel, acronym.base, acronym.max, inputValue(sim, `powers:${FAMILY_POWER_LABELS[acronym.family]}`));
    case 'statDamage': {
      const statParam = acronym.params.find((p) => p.kind === 'stat');
      const stat = statParam ? (sim.stats[statParam.label] ?? statParam.value ?? 0) : 0;
      return talentStatDamage(effectiveLevel, stat, acronym.base, acronym.max);
    }
    default:
      return null;
  }
}

/** Round for display: percentages keep one decimal, big numbers none. */
export function formatValue(value, suffix) {
  if (value === null || value === undefined || !Number.isFinite(value)) return '—';
  const decimals = suffix && suffix.includes('%') ? 1 : value >= 100 ? 0 : value >= 10 ? 1 : 2;
  const rounded = Number(value.toFixed(decimals));
  return `${rounded}${suffix ?? ''}`;
}

/** Decimals the export itself displays, e.g. 2 for "1.31, 1.78, 2.15". */
function displayedPrecision(acronym) {
  return acronym.displayed.reduce((max, value) => Math.max(max, String(value).split('.')[1]?.length ?? 0), 0);
}

/**
 * Format one recomputed value the way the export would have printed it.
 *
 * Values carry as many decimals as the exported ladder shows, which also
 * settles the integer case: Lua's `%d` truncates and `%.0f` rounds, and the
 * build records which one produced the ladder this value belongs to.
 *
 * One ladder can mix both readings: the export keeps the specifier's decimals
 * below 10 and prints the integer part from 10 up (no value >= 10 in the raw
 * export carries a decimal point), so "8.18, 11, 13, 15, 17" is one formula read
 * two ways.
 */
export function formatAcronymValue(acronym, value) {
  if (value === null || value === undefined || !Number.isFinite(value)) return '—';
  const suffix = acronym.suffix ?? '';
  const precision = acronym.lua ? acronym.lua.precision : displayedPrecision(acronym);
  if (precision > 0) {
    if (Math.abs(value) < 10) return `${value.toFixed(precision)}${suffix}`;
    // From 10 up the export prints the integer part of a value the specifier had
    // already rounded ("%0.1f" of 46.4835 is "46.5", which prints as 47).
    const factor = 10 ** precision;
    return `${Math.round(Math.round(value * factor) / factor)}${suffix}`;
  }
  // The build resolves one integer reading per export call: `%d` truncates,
  // `%.0f` rounds, and the second-rounding modes print the integer part of a
  // value the specifier had already rounded to one or two decimals.
  const mode = acronym.lua?.rounding;
  if (mode === 'round1' || mode === 'round2') {
    const factor = 10 ** (mode === 'round1' ? 1 : 2);
    return `${Math.round(Math.round(value * factor) / factor)}${suffix}`;
  }
  const rounded = mode === 'trunc' ? Math.trunc(value) : Math.round(value);
  return `${rounded}${suffix}`;
}

/** Human-readable list of the inputs a value depends on. */
export function describeParams(acronym) {
  return acronym.params
    .filter((p) => p.kind !== 'talentLevel')
    .map((p) => (p.value !== null ? `${p.label} ${p.value}` : `${p.label} ${p.ladder.join('/')}`))
    .join('，');
}

/** The condition the export rendered its own values under, as text lines. */
export function exportCondition(acronym) {
  return acronym.params
    .map((p) => {
      const pinned = p.value !== null && p.value !== undefined ? p.value : p.ladder.join('/');
      return pinned === '' ? null : `${p.label} ${pinned}`;
    })
    .filter(Boolean);
}

// ---------------------------------------------------------------------------
// Inputs of a value
// ---------------------------------------------------------------------------

/** Tooltip order: the talent's own level first, attributes last. */
const INPUT_ORDER = { talentLevel: 0, characterLevel: 1, coefficient: 2, power: 3, powers: 3, stat: 4 };

/** Lua calls whose result moves with the talent level (and so with mastery). */
const LEVEL_CALLS = new Set([
  'talentLevel',
  'talentScale',
  'talentLimit',
  'weaponDamage',
  'statDamage',
  ...Object.keys(FAMILY_POWER_LABELS),
]);

/** Power fields the damage helpers read, by their display label. */
const POWER_LABEL_VALUES = new Set(POWER_LABEL_LIST);

/**
 * Every simulator input a value actually reads.
 *
 * The tooltip lists exactly these, so it can never describe an input the number
 * ignores, nor hide one that moves it. The title declares most of them; a
 * validated Lua expression names the rest (`self:getWil()` becomes a 意志 slider
 * even when the title never mentions it), and the fitted fallback reads the
 * talent level, the coefficient, and its family's driver.
 */
export function valueInputs(acronym) {
  const found = new Map();
  const add = (key, label) => {
    if (!found.has(key)) found.set(key, { key, label });
  };

  for (const param of acronym.params) {
    if (param.label === '技能等级') add('talentLevel', '技能等级');
    else if (param.label === '角色等级') add('characterLevel', '角色等级');
    else if (param.kind === 'coefficient') add('coefficient', '技能系数');
    else if (param.kind === 'power') add(`powers:${param.label}`, param.label);
    else if (param.kind === 'stat' || param.kind === 'talentLevel') add(`stat:${param.label}`, param.label);
  }

  if (acronym.lua) {
    const usesLevel = formulaCalls(acronym.lua.expr).some(([fn]) => LEVEL_CALLS.has(fn));
    if (usesLevel) {
      add('talentLevel', '技能等级');
      add('coefficient', '技能系数');
    }
    for (const label of formulaActorInputs(acronym.lua.expr)) {
      if (label === '角色等级') add('characterLevel', '角色等级');
      else add(`stat:${label}`, label);
    }
    for (const label of formulaDependencies(acronym.lua.expr)) {
      if (POWER_LABEL_VALUES.has(label)) add(`powers:${label}`, label);
      else add(`stat:${label}`, label);
    }
  } else if (acronym.base !== null) {
    add('talentLevel', '技能等级');
    if (acronym.family !== 'talentScale') add('coefficient', '技能系数');
    if (acronym.family === 'statDamage') {
      // combatTalentStatDamage drives on an attribute, not on power.
      const stat = acronym.params.find((p) => p.kind === 'stat');
      add(`stat:${stat ? stat.label : '力量'}`, stat ? stat.label : '力量');
    } else if (FAMILY_POWER_LABELS[acronym.family]) {
      add(`powers:${FAMILY_POWER_LABELS[acronym.family]}`, FAMILY_POWER_LABELS[acronym.family]);
    }
  }

  return [...found.values()]
    .map((entry) => ({ ...entry, kind: entry.key.split(':')[0] }))
    .sort((a, b) => (INPUT_ORDER[a.kind] ?? 9) - (INPUT_ORDER[b.kind] ?? 9) || a.label.localeCompare(b.label))
    .map(({ key, label }) => ({ key, label }));
}

/**
 * The effective combat stat for a label, falling back to the legacy single
 * `power` field when the per-type map has nothing to say.
 */
function powerValue(sim, label) {
  const perType = label === undefined ? undefined : sim?.powers?.[label];
  if (Number.isFinite(perType)) return perType;
  return Number.isFinite(sim?.power) ? sim.power : 0;
}

/** The value a simulation currently holds for one input. */
export function inputValue(sim, key) {
  if (key === 'talentLevel') return sim.talentLevel;
  if (key === 'characterLevel') return sim.characterLevel ?? 1;
  if (key === 'coefficient') return sim.coefficient;
  if (key === 'power') return powerValue(sim);
  if (key.startsWith('powers:')) return powerValue(sim, key.slice(7));
  if (key.startsWith('stat:')) {
    const value = sim.stats?.[key.slice(5)];
    // An input the simulation never seeded reads as zero, which is exactly what
    // the evaluator substitutes — the tooltip stays truthful about that.
    return Number.isFinite(value) ? value : 0;
  }
  return null;
}
