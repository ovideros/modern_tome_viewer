/** A deliberately closed expression language. Never executes Lua or JavaScript text. */
export const STAT_LABELS = { str: '力量', dex: '敏捷', con: '体质', mag: '魔力', wil: '意志', cun: '灵巧', lck: '幸运' };

/**
 * Actor lookups the export can drive with a slider. The extractor rewrites
 * `self:getWil()` etc. into these labels, so a value that "depends on character
 * state" is still computable: the state is just another input.
 */
export const ACTOR_LABELS = {
  ...Object.fromEntries(Object.entries(STAT_LABELS).map(([key, label]) => [`stat:${key}`, label])),
  level: '角色等级',
  charLevel: '角色等级',
};
export const POWER_LABELS = { spellDamage: '法术强度', mindDamage: '精神强度', physicalDamage: 'physical power', steamDamage: 'steampower' };

/**
 * The effective combat stat behind a power label.
 *
 * Four powers exist and a value may take the best of two of them, so each keeps
 * its own number: `sim.powers[label]`. `sim.power` remains the single-value
 * fallback for callers that model only one (the oracle fixtures, the fitted
 * families, older data).
 */
export function powerValue(sim, label) {
  const perType = sim?.powers?.[label];
  if (Number.isFinite(perType)) return perType;
  return Number.isFinite(sim?.power) ? sim.power : 0;
}

export function evaluateLuaExpression(expr, sim) {
  if (typeof expr === 'number') return expr;
  if (!Array.isArray(expr)) return NaN;
  const [fn, ...a] = expr;
  const value = (x) => evaluateLuaExpression(x, sim);
  const level = sim.talentLevel * sim.coefficient;
  if (fn === '+') return value(a[0]) + value(a[1]);
  if (fn === '-') return value(a[0]) - value(a[1]);
  if (fn === '*') return value(a[0]) * value(a[1]);
  if (fn === '/') return value(a[0]) / value(a[1]);
  if (fn === '^') return value(a[0]) ** value(a[1]);
  if (fn === 'floor') return Math.floor(value(a[0]));
  if (fn === 'ceil') return Math.ceil(value(a[0]));
  if (fn === 'min') return Math.min(...a.map(value));
  if (fn === 'max') return Math.max(...a.map(value));
  if (fn === 'sqrt') return Math.sqrt(value(a[0]));
  if (fn === 'abs') return Math.abs(value(a[0]));
  if (fn === 'log') return Math.log(value(a[0]));
  if (fn === 'log10') return Math.log10(value(a[0]));
  if (fn === 'exp') return Math.exp(value(a[0]));
  if (fn === 'pow') return value(a[0]) ** value(a[1]);
  if (fn === 'talentLevel') return a[0] ? sim.talentLevel : level;
  if (fn === 'power') {
    const [label, mod = 1] = a;
    return powerValue(sim, label) * (value(mod) ?? 1);
  }
  if (fn === 'actor') {
    const label = a[0];
    if (label === '角色等级') return sim.characterLevel ?? 1;
    return sim.stats?.[label] ?? 0;
  }
  if (fn === 'pmod') {
    // getParadoxModifier: sqrt(paradox/300), linear below 300, capped at +/-50%.
    const paradox = value(a[0]);
    const raw = paradox < 300 ? paradox / 300 : Math.sqrt(paradox / 300);
    return Math.min(1.5, Math.max(0.5, raw));
  }
  if (fn === 'cond') {
    const [flag, whenTrue, whenFalse] = a;
    return sim.flags?.[flag] ? value(whenTrue) : value(whenFalse);
  }
  if (fn === 'talentRef') {
    // Another talent's level. Validation either binds it to a title parameter
    // (rewritten to `actor`) or leaves the export's own baseline of 0.
    const [id] = a;
    const bound = sim.stats?.[`talent:${id}`];
    return Number.isFinite(bound) ? bound : 0;
  }
  if (fn === 'combatScale') {
    const [x, yLow, xLow, yHigh, xHigh, power = 0.5, add = 0, shift = 0] = a.map(value);
    const transform = (v) => (power === 'log' ? Math.log10(v + shift) : (v + shift) ** power);
    const lo = transform(xLow);
    const hi = transform(xHigh);
    if (!(hi !== lo)) return NaN;
    const m = (yHigh - yLow) / (hi - lo);
    return m * (transform(x) - lo) + yLow + add;
  }
  if (fn === 'combatLimit') {
    const [x, limit, yLow, xLow, yHigh, xHigh] = a.map(value);
    const lo = xLow ** 0.75;
    const hi = xHigh ** 0.75;
    if (hi === lo) return NaN;
    if (yHigh >= yLow) {
      const slope = Math.log((yHigh - limit) / (yLow - limit)) / (hi - lo);
      const offset = -((hi - lo) * Math.log(1 - yHigh / limit) - hi * Math.log((yHigh - limit) / (yLow - limit))) / (lo - hi);
      return limit * (1 - Math.exp(x ** 0.75 * slope + offset));
    }
    if (yLow > yHigh) {
      const slope = Math.log((yHigh - limit) / (yLow - limit)) / (hi - lo);
      const offset = -((hi - lo) * Math.log(1 - (yLow - yHigh) / (yLow - limit)) - hi * Math.log((yHigh - limit) / (yLow - limit))) / (lo - hi);
      return yLow - (yLow - limit) * (1 - Math.exp(x ** 0.75 * slope + offset));
    }
    return NaN;
  }
  if (fn === 'talentScale' || fn === 'statScale') {
    const stat = fn === 'statScale';
    const [low, high, power = 0.5, add = 0, shift = 0, raw = false] = stat ? a.slice(1) : a;
    let x = stat ? sim.stats[STAT_LABELS[a[0]]] : raw ? sim.talentLevel : level;
    if (!stat && x <= 0) x = 0.1;
    if (power === 'log') x = Math.max(1, x);
    const transform = (v) => power === 'log' ? Math.log10(v + shift) : (v + shift) ** power;
    const lo = transform(stat ? 10 : 1);
    const slope = (high - low) / (transform(stat ? 100 : 5) - lo);
    return Math.max(0, slope * (transform(x) - lo) + low + add);
  }
  if (fn === 'talentLimit') {
    const [limit, low, high, raw = false, mastery = 1.3] = a;
    let tl = raw ? sim.talentLevel : level;
    if (tl <= 0) tl = 0.5;
    const fraction = (Math.sqrt(tl) - Math.sqrt(mastery)) / (Math.sqrt(5 * mastery) - Math.sqrt(mastery));
    return limit + (low - limit) * ((high - limit) / (low - limit)) ** fraction;
  }
  if (fn === 'weaponDamage') {
    // combatTalentWeaponDamage(t, base, max, t2): the bonus level is halved.
    const [base, max, bonus = 0] = a.map(value);
    return base + (max - base) * Math.sqrt((level + bonus / 2) / 5);
  }
  if (fn === 'statDamage') {
    const [stat, base, max, noDR = false] = a;
    let damage = (base + sim.stats[STAT_LABELS[stat]]) * ((Math.sqrt(level) - 1) * 0.8 + 1) * max / ((base + 100) * ((Math.sqrt(5) - 1) * 0.8 + 1));
    if (!noDR) damage *= 1 - Math.log10(damage * 2) / 7;
    // Combat.lua applies ^(1/1.04) then rescaleDamage(^1.04).
    return damage >= 0 ? damage : NaN;
  }
  if (Object.hasOwn(POWER_LABELS, fn)) {
    const [base, max, override] = a;
    // The helpers accept an explicit power override (chronomancy puts
    // `getParadoxSpellpower(...)` there); without one the family's own stat rules.
    const driver = override === undefined ? powerValue(sim, POWER_LABELS[fn]) : value(override);
    const damage = (base + driver) * ((Math.sqrt(level) - 1) * 0.8 + 1) * max / ((base + 100) * ((Math.sqrt(5) - 1) * 0.8 + 1));
    return damage <= 0 ? damage : damage ** 1.04;
  }
  return NaN;
}

export function formulaCalls(expr) {
  if (!Array.isArray(expr)) return [];
  if (Object.hasOwn(POWER_LABELS, expr[0]) ||
      ['talentScale', 'talentLimit', 'weaponDamage', 'statDamage', 'statScale', 'actor', 'power',
       'combatScale', 'combatLimit', 'pmod'].includes(expr[0])) return [expr];
  return expr.slice(1).flatMap(formulaCalls);
}

/** State flags a formula conditions on, e.g. `self:attr("x") and 2 or 1`. */
export function formulaConditions(expr, out = []) {
  if (!Array.isArray(expr)) return out;
  if (expr[0] === 'cond') out.push(expr[1]);
  for (const part of expr.slice(1)) formulaConditions(part, out);
  return [...new Set(out)];
}

/** Another talent's level a formula reads, e.g. `self:getTalentLevel(self.T_X)`. */
export function formulaTalentRefs(expr, out = []) {
  if (!Array.isArray(expr)) return out;
  if (expr[0] === 'talentRef') out.push(expr[1]);
  for (const part of expr.slice(1)) formulaTalentRefs(part, out);
  return [...new Set(out)];
}

/**
 * The power/stat inputs a formula consumes, wherever they sit in the tree —
 * including inside a `combatScale` driver or a `weaponDamage` bonus argument.
 */
export function formulaDependencies(expr, out = []) {
  if (!Array.isArray(expr)) return out;
  const fn = expr[0];
  if (Object.hasOwn(POWER_LABELS, fn)) out.push(POWER_LABELS[fn]);
  else if (fn === 'power') out.push(expr[1]);
  else if (fn === 'statDamage' || fn === 'statScale') out.push(STAT_LABELS[expr[1]]);
  for (const part of expr.slice(1)) formulaDependencies(part, out);
  return [...new Set(out)];
}

/**
 * Actor inputs (character level, attributes, resources) a formula reads.
 *
 * Walks the whole tree rather than only the recognized calls, so an actor lookup
 * nested inside `combatTalentWeaponDamage`'s bonus argument still counts.
 */
export function formulaActorInputs(expr, out = []) {
  if (!Array.isArray(expr)) return out;
  if (expr[0] === 'actor') out.push(expr[1]);
  for (const part of expr.slice(1)) formulaActorInputs(part, out);
  return [...new Set(out)];
}
