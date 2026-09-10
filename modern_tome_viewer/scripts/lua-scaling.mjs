import { defaultSimParams, simAtAxis, evaluateAcronym } from '../src/lib/scaling-core.js';
import { evaluateLuaExpression, formulaCalls, formulaConditions, formulaDependencies, formulaActorInputs, formulaTalentRefs } from '../src/lib/lua-formula.js';

/** Decimal places a printed number actually carries. */
function displayedDecimals(value) {
  const text = String(value);
  const dot = text.indexOf('.');
  return dot < 0 ? 0 : text.length - dot - 1;
}

/** Round to `places` decimals the way a `%.Nf` specifier would. */
function roundTo(value, places) {
  const factor = 10 ** places;
  return Math.round(value * factor) / factor;
}

/**
 * The integer readings the export's pipeline can produce.
 *
 * `trunc` is Lua's `%d`, `round` is `%.0f`. The staged modes cover the export's
 * second rounding: it prints the integer part of a value the talent's specifier
 * had already rounded, so `%0.1f` of 46.4835 is "46.5" and prints as 47.
 */
const ROUNDING_MODES = ['trunc', 'round', 'round1', 'round2'];

function applyRounding(mode, value) {
  if (mode === 'trunc') return Math.trunc(value);
  if (mode === 'round1') return Math.round(roundTo(value, 1));
  if (mode === 'round2') return Math.round(roundTo(value, 2));
  return Math.round(value);
}

/**
 * Does a computed value reproduce a displayed number?
 *
 * The export renders every value through the talent's own format specifier and
 * then prints the integer part once the magnitude reaches 10, so a single
 * acronym routinely mixes "3.33" with "10". Read each point at the precision it
 * was actually printed with: a decimal point is an exact reading, an integer is
 * not.
 *
 * At a decimal point the reading is unambiguous, so compare exactly. At an
 * integer point every reading the pipeline could have produced is legitimate —
 * which one it used is settled for the whole ladder by `integerRounding`.
 */
export function matchesDisplayed(predicted, displayed, precision) {
  if (!Number.isFinite(predicted)) return false;
  const shown = displayedDecimals(displayed);
  if (shown > 0) return Math.abs(predicted - displayed) <= 0.5 * 10 ** -shown + 1e-8;
  const readings = [Math.round(predicted), Math.trunc(predicted)];
  for (const places of new Set([precision, 1, 2])) {
    if (!(places > 0)) continue;
    const staged = roundTo(predicted, places);
    readings.push(Math.round(staged), Math.trunc(staged));
  }
  return readings.includes(displayed);
}

/** The parameter the displayed values vary, and its five values. */
export function ladderAxis(acronym) {
  const axis = acronym.params.find((p) => p.ladder.length > 1);
  if (!axis) return null;
  // `axisLabel` is parsed once, so keep it consistent with the live parameter.
  acronym.axisLabel = axis.label;
  if (axis.ladder.length !== acronym.displayed.length || axis.ladder.length < 2) return null;
  // Every other input must be a single value we can pin.
  const others = acronym.params.filter((p) => p !== axis);
  if (others.some((p) => p.ladder.length > 1)) return null;
  return axis;
}

/**
 * Validate the entire exported ladder at its documented inputs, without fitting.
 *
 * The ladder may vary any one declared parameter — talent level, spell power,
 * agility or character level. Actor inputs the title does not list (`self.level`)
 * are allowed when the formula is otherwise reproducible, because the reader can
 * dial that input in too.
 */
export function matchLuaFormula(acronym, record) {
  if (!record || !record.candidates.length) return { reason: record?.reason || 'source unavailable' };
  const axis = ladderAxis(acronym);
  if (!axis) return { reason: 'unsupported input dimensions' };

  // Inputs the title declares, minus the axis being varied.
  const declared = declaredInputs(acronym, axis);
  const sim = defaultSimParams(acronym);
  const precision = acronym.precision ?? 0;
  const matches = new Map();

  for (const candidate of record.candidates) {
    const bound = bindTalentRefs(candidate.expr, acronym);
    const consumed = consumedInputs(bound.expr, axis.label);
    if (!inputsCovered(declared, consumed)) continue;

    // A conditional (`self:attr("x") and 2 or 1`, or an if/else on an argument
    // `info` never passes) is a state flag. Try every assignment; the export was
    // rendered by an actor without buffs, so `false` breaks ties.
    let accepted = null;
    for (const flags of conditionAssignments(bound.expr)) {
      const predicted = axis.ladder.map((value) =>
        evaluateLuaExpression(bound.expr, { ...simAtAxis(acronym, sim, value), flags }));
      if (!predicted.every((v, i) => Number.isFinite(v) && matchesDisplayed(v, acronym.displayed[i], precision))) continue;
      const allOff = Object.values(flags).every((v) => v === false);
      if (!accepted || (allOff && !Object.values(accepted.flags).every((v) => v === false))) accepted = { flags, predicted };
    }
    if (!accepted) continue;
    matches.set(JSON.stringify(bound.expr), { ...candidate, ...bound, predicted: accepted.predicted, flags: accepted.flags });
  }

  if (matches.size !== 1) return { reason: matches.size ? 'ambiguous formula' : 'reference mismatch' };
  const candidate = [...matches.values()][0];
  // A hand-written formula need not be one of the game's helper families: a pure
  // level expression like `["*",2,["talentLevel",true]]` is a formula too, it
  // just carries no family, base or max.
  const calls = formulaCalls(candidate.expr);
  const family = calls.length ? calls[0][0] : null;
  const args = calls.length ? calls[0].slice(1) : [];
  const offset = ['statDamage', 'statScale', 'talentLimit'].includes(family) ? 1 : 0;
  const conditions = Object.fromEntries(Object.entries(candidate.flags ?? {}).filter(([, v]) => v !== false));
  return {
    formula: {
      family,
      base: calls.length ? args[offset] : null,
      max: calls.length ? args[offset + 1] : null,
      mastery: sim.coefficient,
      lua: {
        expr: candidate.expr,
        file: record.file,
        line: record.line,
        argument: candidate.argument,
        precision,
        axis: axis.label,
        ...(formulaConditions(candidate.expr).length ? { conditions: candidate.flags } : {}),
        ...(candidate.assumed?.length ? { assumed: candidate.assumed } : {}),
      },
    },
  };
}

/**
 * Another talent's level is an input of its own; the export pins such inputs
 * with a title parameter ("陷阱专精 技能等级") and otherwise renders them at 0,
 * which is the baseline a fake actor without talents produces.
 */
function bindTalentRefs(expr, acronym) {
  const refs = formulaTalentRefs(expr);
  if (!refs.length) return { expr };
  const pin = acronym.params.find(
    (p) => /技能等级|等级/.test(p.label) && p.label !== '技能等级' && p.kind !== 'power');
  const bound = new Set();
  const assumed = [];
  const rewrite = (node) => {
    if (!Array.isArray(node)) return node;
    if (node[0] === 'talentRef') {
      if (refs.length === 1 && pin) {
        bound.add(node[1]);
        return ['actor', pin.label];
      }
      assumed.push({ talent: node[1], level: 0 });
      return 0;
    }
    return [node[0], ...node.slice(1).map(rewrite)];
  };
  return { expr: rewrite(expr), proposed: [...bound], assumed };
}

/**
 * Inputs the title declares, minus the axis being varied.
 *
 * Another talent's level counts too ("陷阱专精 技能等级"), which the title parser
 * types either as a talent level or as a plain label.
 */
export function declaredInputs(acronym, axis) {
  return acronym.params
    .filter((p) => p !== axis && isDeclaredInput(p))
    .map((p) => p.label)
    .sort();
}

/**
 * Labels a formula consumes: power/stat drivers plus every actor lookup
 * (attributes, character level, resources). The axis is varied by the ladder,
 * everything else must be pinned by the title — a value that reads state the
 * title never mentions is not reproducible.
 */
export function consumedInputs(expr, axisLabel) {
  return [...new Set([
    ...formulaDependencies(expr),
    ...formulaActorInputs(expr),
  ])].filter((label) => label !== axisLabel).sort();
}

/**
 * May the title drive every input the formula reads?
 *
 * Only this direction is a correctness rule: an input the formula reads but the
 * title never pins has no slider, so the number would silently depend on state
 * nobody can set. The converse — "the title declared it, so the formula must use
 * it" — is not: the export writes a whole tooltip's parameter union into many
 * acronym titles, so a range that never touches paradox still carries
 * "paradox 300". Demanding equality there rejected formulas whose fifteen points
 * all reproduced.
 *
 * Returns the labels that are read but not declared; empty means covered.
 */
export function uncoveredInputs(declared, consumed) {
  const available = new Set(declared);
  return consumed.filter((label) => !available.has(label));
}

export function inputsCovered(declared, consumed) {
  return uncoveredInputs(declared, consumed).length === 0;
}

/**
 * Evaluate a hand-written expression against one exported rendering.
 *
 * The workbench and the build share this so an overlay entry is judged the same
 * way in both: same ladder, same display readings. (The input-coverage rule is
 * checked by the caller, which is the side that knows the title's declaration.)
 *
 * Returns `{ error }` when the rendering has no single varying axis, otherwise
 * `{ axis, ladder, points, ok }` with the raw prediction kept so callers can
 * report which integer reading matched.
 */
export function checkHandExpression(ref, expr, conditions = null) {
  const axis = ladderAxis(ref);
  if (!axis) return { error: 'unsupported axis' };
  const acronym = {
    ...ref,
    base: null,
    max: null,
    mastery: 1,
    lua: { expr, precision: ref.precision ?? 0 },
  };
  const sim = { ...defaultSimParams(acronym), ...(conditions ? { flags: conditions } : {}) };
  const points = axis.ladder.map((value, index) => {
    const predicted = evaluateAcronym(acronym, simAtAxis(acronym, sim, value));
    const displayed = ref.displayed[index];
    return {
      axis: value,
      displayed,
      predicted,
      ok: Number.isFinite(predicted) && matchesDisplayed(predicted, displayed, ref.precision ?? 0),
    };
  });
  return { axis: axis.label, ladder: axis.ladder, points, ok: points.every((point) => point.ok) };
}

/** Does this title parameter name an input the formula must consume? */
function isDeclaredInput(param) {
  if (['power', 'stat'].includes(param.kind)) return true;
  if (param.label === '技能等级' || param.label === '技能系数') return false;
  return /等级/.test(param.label);
}

/** Every assignment of the condition flags a formula reads (0 when it reads none). */
function conditionAssignments(expr) {
  const flags = formulaConditions(expr);
  if (!flags.length) return [{}];
  const out = [];
  for (let mask = 0; mask < (1 << flags.length); mask++) {
    const assignment = {};
    flags.forEach((flag, index) => { assignment[flag] = Boolean(mask & (1 << index)); });
    out.push(assignment);
  }
  return out;
}

/**
 * Which integer reading of a value the export used: 'trunc' or 'round'.
 *
 * The export does not record its format specifier, and Lua's `%d` truncates
 * while `%.0f` rounds. A ladder point whose prediction is fractional identifies
 * the specifier that produced it whenever the two readings disagree, so the
 * ladder itself is the evidence: 被捕猎's `4.571 -> 4` can only be `%d`, while
 * 初现光芒's `33.967 -> 34` can only be `%.0f`.
 *
 * Returns null when every point is integral or agrees under both readings (no
 * evidence), or when two points would need opposite conventions.
 */
export function integerRounding(acronym) {
  if (!acronym.lua || acronym.lua.precision > 0) return null;
  const readings = ladderReadings(acronym);
  if (!readings) return null;
  const reproducing = ROUNDING_MODES.filter((mode) => reproducesLadder(acronym, mode));
  // No reading explains every point: the ladder is not self-consistent.
  if (!reproducing.length) return null;
  // Every reading explains every point: the ladder carries no evidence, and the
  // sibling that does (same `tformat` call) settles it through the group.
  if (reproducing.length === ROUNDING_MODES.length) return null;
  // Otherwise the surviving readings are the candidates; preference order picks
  // the least surprising one, and any of them renders this ladder identically.
  return reproducing[0];
}

/** Predicted and displayed values at every documented ladder point. */
function ladderReadings(acronym) {
  if (!acronym.lua || acronym.lua.precision > 0) return null;
  const axis = ladderAxis(acronym);
  if (!axis) return null;
  const sim = defaultSimParams(acronym);
  const out = [];
  for (const [index, value] of axis.ladder.entries()) {
    const predicted = evaluateLuaExpression(acronym.lua.expr, simAtAxis(acronym, sim, value));
    if (!Number.isFinite(predicted)) return null;
    out.push({ predicted, displayed: acronym.displayed[index] });
  }
  return out;
}

/** Does one reading reproduce every integer this ladder displays? */
function reproducesLadder(acronym, mode) {
  const readings = ladderReadings(acronym);
  if (!readings) return false;
  return readings.every(({ predicted, displayed }) => applyRounding(mode, predicted) === displayed);
}

/**
 * Resolve one convention per export call.
 *
 * Every value of a `tformat` call is printed by the same format string, so a
 * sibling's evidence settles a value that has none of its own: 被捕猎's radius
 * (`10 + level/5`, integral at all five reference levels) inherits the `%d` its
 * percentage sibling proves. Direct evidence always wins over the group, and an
 * inherited convention is only kept when it really reproduces the ladder.
 */
export function resolveIntegerRounding(acronyms) {
  const groups = new Map();
  for (const acronym of acronyms) {
    if (!acronym.lua) continue;
    const key = `${acronym.lua.file}:${acronym.lua.line}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push({ acronym, own: integerRounding(acronym) });
  }
  for (const entries of groups.values()) {
    const agreed = new Set(entries.map((entry) => entry.own).filter(Boolean));
    const groupMode = agreed.size === 1 ? [...agreed][0] : null;
    for (const { acronym, own } of entries) {
      if (acronym.lua.precision > 0) continue;
      const mode = own ?? groupMode;
      if (mode && reproducesLadder(acronym, mode)) acronym.lua.rounding = mode;
    }
  }
  return acronyms;
}

/**
 * Actor inputs are acceptable when the acronym either varies that input along
 * its ladder, or never mentions it because the export pinned it.
 */
function actorInputsAreDialable(acronym, axis, actorDeps) {
  const axisIsActor = actorDeps.includes(axis.label);
  const unlisted = actorDeps.filter((label) => label !== axis.label);
  // An unlisted actor input is only safe if no other actor input varies with it;
  // otherwise two free variables would have to fit one ladder.
  return axisIsActor || unlisted.length === 0;
}
