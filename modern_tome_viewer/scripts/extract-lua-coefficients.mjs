#!/usr/bin/env node
/** Conservative static extraction; no Lua runtime and no eval. See docs/lua-scaling.md. */
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { formulaCalls } from '../src/lib/lua-formula.js';

export function tokenizeLua(source) {
  const tokens = [];
  let i = 0;
  while (i < source.length) {
    if (/\s/.test(source[i])) { i++; continue; }
    const start = i;
    const comment = source.startsWith('--', i);
    if (comment) i += 2;
    const long = source.slice(i).match(/^\[(=*)\[/);
    if (long) {
      const endMark = `]${long[1]}]`;
      const end = source.indexOf(endMark, i + long[0].length);
      if (end < 0) throw new Error(`Unclosed long string at ${start}`);
      if (!comment) tokens.push({ v: source.slice(i + long[0].length, end), kind: 'string', start, end: end + endMark.length });
      i = end + endMark.length;
      continue;
    }
    if (comment) { const end = source.indexOf('\n', i); i = end < 0 ? source.length : end; continue; }
    if (source[i] === '"' || source[i] === "'") {
      const quote = source[i++];
      let value = '';
      while (i < source.length && source[i] !== quote) {
        if (source[i] === '\\') { i++; value += source[i++] ?? ''; }
        else value += source[i++];
      }
      if (i >= source.length) throw new Error(`Unclosed string at ${start}`);
      i++;
      tokens.push({ v: value, kind: 'string', start, end: i });
      continue;
    }
    const match = source.slice(i).match(/^(?:0[xX][\da-fA-F]+|(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?|[A-Za-z_][\w]*|\.\.|==|~=|<=|>=)/);
    const v = match ? match[0] : source[i];
    i += v.length;
    tokens.push({ v, kind: /^(?:\d|\.\d)/.test(v) ? 'number' : 'token', start, end: i });
  }
  return tokens;
}

const is = (t, v) => t?.kind === 'token' && t.v === v;

/**
 * Actor.lua wrappers that take exactly one argument and rescale it by an
 * equipment/attribute term. Their neutral value is the identity, so they are
 * unwrapped under the stated baseline assumption. That assumption is not
 * trusted blindly: the resulting formula still has to reproduce every displayed
 * number, so a wrong baseline simply fails to match instead of producing a
 * plausible but incorrect value.
 */
const PASS_THROUGH = {
  'self:getShieldAmount': 'shield_factor=0 (baseline: no shield bonus)',
  'self:getShieldDuration': 'shield_dur=0 (baseline: no shield duration bonus)',
  'self:getHealAmount': 'heal_factor=0 (baseline: no heal bonus)',
};

/** Field table of the talent currently being parsed (named getter arguments). */
let currentFields = Object.create(null);
/** Resolver for the talent currently being parsed: name -> lua expression AST. */
let currentGetter = () => { throw new Error('Getter resolver unavailable'); };

/** `uberTalent` blocks declare no tree; the file name carries it. */
const UBER_TREE_BY_FILE = {
  str: 'strength', dex: 'dexterity', const: 'constitution',
  mag: 'magic', wil: 'willpower', cun: 'cunning',
};
function closeAt(tokens, start) {
  const pairs = { '(': ')', '{': '}', '[': ']' };
  const stack = [];
  for (let i = start; i < tokens.length; i++) {
    const t = tokens[i];
    if (t.kind !== 'token') continue;
    if (Object.hasOwn(pairs,t.v)) stack.push(pairs[t.v]);
    else if ([')', '}', ']'].includes(t.v)) {
      if (stack.pop() !== t.v) throw new Error(`Unbalanced delimiters at ${t.start}: ${tokens.slice(Math.max(0,i-8),i+3).map(t=>t.v).join(' ')}`);
      if (!stack.length) return i;
    }
  }
  throw new Error('Unclosed delimiter');
}

// Lua block keywords matter when splitting table fields containing functions.
function splitTop(tokens, delimiter = ',') {
  const out = [];
  let start = 0, pendingDo = 0;
  const blocks = [];
  for (let i = 0; i < tokens.length; i++) {
    const t = tokens[i];
    if (t.kind !== 'token') continue;
    if (['(', '{', '['].includes(t.v)) { i = closeAt(tokens, i); continue; }
    if (['function', 'if', 'for', 'while', 'repeat'].includes(t.v)) {
      blocks.push(t.v);
      if (t.v === 'for' || t.v === 'while') pendingDo++;
    } else if (t.v === 'do') {
      if (pendingDo) pendingDo--; else blocks.push('do');
    } else if (t.v === 'end' || t.v === 'until') blocks.pop();
    if (t.v === delimiter && !blocks.length) { out.push(tokens.slice(start, i)); start = i + 1; }
  }
  out.push(tokens.slice(start));
  return out.filter(x => x.length);
}

function literal(tokens) {
  if (tokens.length === 1) {
    const t = tokens[0];
    if (t.kind === 'number') return Number(t.v);
    if (t.kind === 'string') return t.v;
    if (t.v === 'true') return true;
    if (t.v === 'false') return false;
    if (t.v === 'nil') return null;
  }
  if (tokens.length === 2 && is(tokens[0], '-') && tokens[1].kind === 'number') return -Number(tokens[1].v);
  throw new Error('Non-literal argument');
}

/**
 * A field value we can name a talent by, or null.
 *
 * `short_name = WARDEN_S_FOCUS` is written unquoted all over the game data —
 * reading it as `literal()` threw and the whole block was dropped, which is why
 * a handful of exported talents had no record at all.
 */
function literalOrNull(tokens) {
  if (!tokens?.length) return null;
  if (tokens.length === 1 && tokens[0].kind === 'token' && /^[A-Za-z_][A-Za-z0-9_]*$/.test(tokens[0].v) &&
      !['true', 'false', 'nil'].includes(tokens[0].v)) return tokens[0].v;
  try { return literal(tokens); } catch { return null; }
}

const families = {
  combatTalentSpellDamage: 'spellDamage', combatTalentMindDamage: 'mindDamage',
  combatTalentPhysicalDamage: 'physicalDamage', combatTalentSteamDamage: 'steamDamage',
  combatTalentScale: 'talentScale', combatTalentLimit: 'talentLimit',
  combatTalentWeaponDamage: 'weaponDamage', combatTalentStatDamage: 'statDamage', combatStatScale: 'statScale',
};

const DAMAGE_HELPERS = {
  'self:combatTalentSpellDamage': 'spellDamage',
  'self:combatTalentMindDamage': 'mindDamage',
  'self:combatTalentPhysicalDamage': 'physicalDamage',
  'self:combatTalentSteamDamage': 'steamDamage',
};

/**
 * `self:combatSpellpower(mod, add)` and friends return the *effective* combat
 * stat the damage helpers consume. Four separate powers exist (a talent may take
 * the best of two of them), so each keeps its own label — the same label the
 * export uses in its titles.
 */
const POWER_GETTERS = {
  'self:combatSpellpower': '法术强度',
  'self:combatMindpower': '精神强度',
  'self:combatPhysicalpower': 'physical power',
  'self:combatSteampower': 'steampower',
};

/** Actor accessors that read a resource rather than an attribute. */
const RESOURCE_GETTERS = {
  'self:getParadox': 'paradox',
  'self:getPsi': 'psi',
  'self:getHate': 'hate',
  'self:getPositive': 'positive',
  'self:getNegative': 'negative',
};

/**
 * `self:getMag()` and friends. The label is the same one the export prints in
 * titles, so a value reading an attribute the title pins resolves directly.
 */
const ACTOR_STAT_LABELS = { str: '力量', dex: '敏捷', con: '体质', mag: '魔力', wil: '意志', cun: '灵巧', lck: '幸运' };

/** Extra math functions the expression language understands. */
const MATH_FUNCTIONS = {
  'math.floor': 1, 'math.ceil': 1, 'math.min': null, 'math.max': null,
  'math.sqrt': 1, 'math.abs': 1, 'math.log': 1, 'math.log10': 1, 'math.exp': 1, 'math.pow': 2,
};
function combatCall(name, args) {
  const family = families[name];
  if (!family) throw new Error('Unsupported combat helper');
  if (family !== 'statScale' && !(args[0]?.length === 1 && is(args[0][0], 't'))) throw new Error('Other talent');
  const a = (family === 'statScale' ? args : args.slice(1)).map(literal);
  const num = (x) => typeof x === 'number' && Number.isFinite(x);
  if (['spellDamage', 'mindDamage', 'physicalDamage', 'steamDamage', 'weaponDamage'].includes(family)) {
    if (a.length !== 2 || !a.every(num)) throw new Error('Unsupported damage arguments');
  } else if (family === 'talentScale' || family === 'statScale') {
    const offset = family === 'statScale' ? 1 : 0;
    if (offset && !['str','dex','con','mag','wil','cun','lck'].includes(a[0])) throw new Error('Unknown stat');
    if (a.length < 2 + offset || a.length > (offset ? 6 : 6) || !num(a[offset]) || !num(a[offset+1])) throw new Error('Scale arguments');
    const defaults = [0.5,0,0,false];
    for (let i = 2 + offset; i < 6 + offset - (offset ? 1 : 0); i++) a[i] ??= defaults[i-2-offset];
    if (!(num(a[2+offset]) || a[2+offset] === 'log') || !num(a[3+offset]) || !num(a[4+offset]) || (!offset && typeof a[5] !== 'boolean')) throw new Error('Scale option');
  } else if (family === 'talentLimit') {
    if (a.length < 3 || a.length > 5 || !a.slice(0,3).every(num)) throw new Error('Limit arguments');
    a[3] ??= false; a[4] ??= 1.3;
    if (typeof a[3] !== 'boolean' || !num(a[4]) || a[4] <= 0 || (a[2]-a[0])/(a[1]-a[0]) <= 0) throw new Error('Invalid limit');
  } else if (family === 'statDamage') {
    if (a.length < 3 || a.length > 4 || !['str','dex','con','mag','wil','cun','lck'].includes(a[0]) || !a.slice(1,3).every(num)) throw new Error('Stat damage arguments');
    a[3] ??= false;
    if (typeof a[3] !== 'boolean') throw new Error('Stat damage option');
  }
  return [family, ...a];
}

/**
 * Names a parsed expression still references as bare values. Used only for
 * diagnostics: a value depending on `self.level` or another actor attribute
 * cannot be simulated from talent parameters, and saying so is more useful than
 * reporting "no formula call".
 */
function resolvedSymbols(expr, out = []) {
  if (Array.isArray(expr)) {
    if (typeof expr[0] === 'string' && /^[a-z_]+$/.test(expr[0])) out.push(expr[0]);
    for (const part of expr.slice(1)) resolvedSymbols(part, out);
  }
  return out;
}

/** Parse only whitelisted arithmetic, pure getters, and supported combat helpers. */

/** Parse only whitelisted arithmetic, pure getters, and supported combat helpers. */
function expression(tokens, env, getter) {
  const r = conditionalAt(tokens, env, getter);
  if (r.pos !== tokens.length) throw new Error('Unconsumed expression');
  return r.expr;
}

/**
 * `X and A or B` — Lua's conditional idiom.
 *
 * Talent getters double a value while a buff is up: `damage * (self:attr("x")
 * and 2 or 1)`. Only a state flag conditions an expression, so anything else
 * fails closed; the validated formula then keeps the branch the export was
 * rendered with (an actor without the buff).
 */
function conditionalAt(tokens, env, getter) {
  const first = expressionAt(tokens, env, getter);
  if (!is(tokens[first.pos], 'and')) return first;
  const whenTrue = expressionAt(tokens.slice(first.pos + 1), env, getter);
  const afterTrue = first.pos + 1 + whenTrue.pos;
  if (!is(tokens[afterTrue], 'or')) throw new Error('Conditional without or');
  const alternate = expressionAt(tokens.slice(afterTrue + 1), env, getter);
  const flag = Array.isArray(first.expr) && first.expr[0] === 'attr' ? first.expr[1] : null;
  if (!flag) throw new Error('Non-attribute condition');
  return {
    expr: ['cond', flag, whenTrue.expr, alternate.expr],
    pos: afterTrue + 1 + alternate.pos,
  };
}

/**
 * Parse one expression and report how many tokens it consumed.
 *
 * Every atom returns {expr, pos} where `pos` is the number of tokens it
 * occupied, so callers can advance through a statement list. Nested parses
 * (getter bodies, wrapper arguments) parse their own token list and therefore
 * must report `pos` rather than sharing the caller's cursor.
 */
function expressionAt(tokens, env, getter) {
  let pos = 0;
  const precedence = { '+': 1, '-': 1, '*': 2, '/': 2, '^': 4 };

  function atom() {
    const token = tokens[pos];
    const start = pos;
    pos++;
    if (!token) throw new Error('Missing expression');
    if (is(token, '-')) return { expr: ['*', -1, parse(3)], pos: pos - start };
    if (token.kind === 'number') return { expr: Number(token.v), pos: 1 };
    if (is(token, '(')) {
      // A parenthesised conditional is common: `damage * (self:attr("x") and 2 or 1)`.
      const inner = conditionalAt(tokens.slice(pos), env, getter);
      pos += inner.pos;
      if (!is(tokens[pos++], ')')) throw new Error('Parentheses');
      return { expr: inner.expr, pos: pos - start };
    }

    let name = token.v;
    while (is(tokens[pos], '.') || is(tokens[pos], ':')) name += tokens[pos++].v + tokens[pos++].v;
    if (!is(tokens[pos], '(')) {
      if (Object.hasOwn(env, name)) return { expr: env[name], pos: pos - start };
      if (name === 'self.level') return { expr: ['actor', '角色等级'], pos: pos - start };
      throw new Error(`Unresolved ${name}`);
    }

    const end = closeAt(tokens, pos);
    const args = splitTop(tokens.slice(pos + 1, end));
    pos = end + 1;
    const consumed = pos - start;
    const done = (expr) => ({ expr, pos: consumed });

    // The four damage helpers take an optional *expression* as their power
    // override — chronomancy passes `getParadoxSpellpower(self, t)` there.
    if (DAMAGE_HELPERS[name]) {
      if (args.length < 3 || args.length > 4) throw new Error('Damage arguments');
      if (!(args[0].length === 1 && is(args[0][0], 't'))) throw new Error('Other talent');
      const base = literal(args[1]);
      const max = literal(args[2]);
      if (typeof base !== 'number' || typeof max !== 'number') throw new Error('Damage arguments');
      const override = args[3] ? expressionAt(args[3], env, getter).expr : null;
      return done(override === null ? [DAMAGE_HELPERS[name], base, max] : [DAMAGE_HELPERS[name], base, max, override]);
    }

    if (name === 'self:combatTalentWeaponDamage') {
      // The optional fourth argument shifts the level the multiplier is solved
      // for (a second talent's level, halved), so it is an expression, not a
      // literal like the other helpers' arguments.
      if (args.length < 3 || args.length > 4) throw new Error('Weapon damage arguments');
      if (!(args[0].length === 1 && is(args[0][0], 't'))) throw new Error('Other talent');
      const base = literal(args[1]);
      const max = literal(args[2]);
      const bonus = args[3] ? expressionAt(args[3], env, getter).expr : 0;
      if (typeof base !== 'number' || typeof max !== 'number') throw new Error('Weapon damage arguments');
      return done(['weaponDamage', base, max, bonus]);
    }

    // Generic scalers: same convex-hull maths as the talent versions, but with
    // explicit anchors, and their driver is an arbitrary expression.
    if (name === 'self:combatScale' || name === 'self:combatLimit') {
      const parts = args.map((a) => expressionAt(a, env, getter).expr);
      if (name === 'self:combatScale') {
        if (parts.length < 5 || parts.length > 8) throw new Error('combatScale arguments');
        return done(['combatScale', ...parts]);
      }
      if (parts.length !== 6) throw new Error('combatLimit arguments');
      return done(['combatLimit', ...parts]);
    }

    if (name.startsWith('self:combat')) {
      if (POWER_GETTERS[name]) {
        // `mod` multiplies the effective stat; `add` is added to the *raw* stat
        // before the diminishing curve, which cannot be inverted from an
        // effective value, so a non-zero `add` fails closed.
        const [mod, add] = args.map((a) => literalOrNull(a));
        if (args.length > 2) throw new Error('Power arguments');
        if (mod !== null && mod !== undefined && (typeof mod !== 'number' || mod <= 0)) throw new Error('Power arguments');
        if (add !== null && add !== undefined && add !== 0) throw new Error('Power raw bonus unsupported');
        return done(['power', POWER_GETTERS[name], mod ?? 1]);
      }
      return done(combatCall(name.slice(5), args));
    }

    if (name === 'self:getTalentLevel' || name === 'self:getTalentLevelRaw') {
      const raw = name.endsWith('Raw');
      if (args.length !== 1) throw new Error('Other talent level');
      if (args[0].length === 1 && is(args[0][0], 't')) return done(['talentLevel', raw]);
      // self:getTalentLevel(self.T_X): another talent's level is an input of its
      // own. Binding it to a title parameter (or to the export's own baseline)
      // happens when the formula is validated.
      if (args[0].length === 3 && is(args[0][0], 'self') && is(args[0][1], '.') && /^T_[A-Z0-9_]+$/.test(args[0][2].v)) {
        return done(['talentRef', args[0][2].v, raw]);
      }
      throw new Error('Other talent level');
    }

    // Chronomancy helpers (chronomancer.lua:153 / 173). PMod drives paradox cost
    // and chronomancy spellpower: `combatSpellpower(mod * pm)`.
    if (name === 'getParadoxModifier') {
      if (args.length > 1) throw new Error('getParadoxModifier arguments');
      return done(['pmod', ['actor', 'paradox']]);
    }
    if (name === 'getParadoxSpellpower') {
      if (args.length < 2 || args.length > 4) throw new Error('getParadoxSpellpower arguments');
      const mod = args[2] ? expressionAt(args[2], env, getter).expr : 1;
      const add = args[3] ? literalOrNull(args[3]) : null;
      if (add) throw new Error('Paradox spellpower raw bonus unsupported');
      return done(['power', '法术强度', ['*', mod, ['pmod', ['actor', 'paradox']]]]);
    }

    if (RESOURCE_GETTERS[name]) {
      if (args.length !== 0) throw new Error('Resource accessor arguments');
      return done(['actor', RESOURCE_GETTERS[name]]);
    }

    // `self:attr("name")` is a boolean-ish flag: truthy whenever the attribute
    // exists. It only ever appears as a condition (see the conditional branch).
    if (name === 'self:attr') {
      const attr = args.length === 1 ? literalOrNull(args[0]) : null;
      if (typeof attr !== 'string') throw new Error('attr arguments');
      return done(['attr', attr]);
    }

    if (/^t\.\w+$/.test(name)) {
      // t.<getter>(self, t)                   -> that getter's own expression
      // t.<getter>(self, t_otherGetter, ...)  -> the getter named by argument 2,
      //   the idiom talents use to share one getter with several parameters.
      if (args.length < 2 || args[0].length !== 1 || args[0][0].v !== 'self') throw new Error('Getter arguments');
      let field = name.slice(2);
      const second = args[1];
      if (second.length === 1 && second[0].kind === 'token' && /^[A-Za-z_]/.test(second[0].v) &&
          second[0].v !== 't' && !Object.hasOwn(env, second[0].v)) {
        field = second[0].v;
        if (!currentFields[field]) throw new Error('Unresolved getter');
      }
      return done(currentGetter(field, env));
    }

    const accessors = { 'self:getTalentRadius': 'radius', 'self:getTalentRange': 'range', 'self:getTalentCooldown': 'cooldown' };
    if (accessors[name]) {
      if (args.length !== 1 || args[0].length !== 1 || args[0][0].v !== 't') throw new Error('Accessor arguments');
      return done(currentGetter(accessors[name]));
    }

    // Actor.lua one-argument wrappers; see PASS_THROUGH for the baseline caveat.
    // Actor attribute accessors: self:getWil(), self:getLevel() ...
    const actorMatch = name.match(/^self:get(Str|Dex|Con|Mag|Wil|Cun|Lck|Level)$/);
    if (actorMatch) {
      if (args.length !== 0) throw new Error('Actor accessor arguments');
      const key = actorMatch[1].toLowerCase();
      const label = key === 'level' ? '角色等级' : ACTOR_STAT_LABELS[key.slice(0, 3)];
      if (!label) throw new Error('Unknown actor accessor');
      return done(['actor', label]);
    }

    if (PASS_THROUGH[name]) {
      if (args.length !== 1) throw new Error('Wrapper arguments');
      return done(expressionAt(args[0], env, getter).expr);
    }

    if (name === 'damDesc') {
      if (args.length !== 3 || args[0].length !== 1 || args[0][0].v !== 'self' ||
          args[1].map((t) => t.v).join('').match(/^DamageType\.\w+$/) === null) throw new Error('damDesc arguments');
      return done(expressionAt(args[2], env, getter).expr);
    }

    if (Object.hasOwn(MATH_FUNCTIONS, name)) {
      const arity = MATH_FUNCTIONS[name];
      if (arity !== null && args.length !== arity) throw new Error('Math arguments');
      if (arity === null && args.length < 1) throw new Error('Math arguments');
      return done([name.slice(5), ...args.map((a) => expressionAt(a, env, getter).expr)]);
    }

    throw new Error(`Unsupported call ${name}`);
  }

  function parse(min) {
    let left = atom().expr;
    while (tokens[pos]?.kind === 'token' && (precedence[tokens[pos].v] ?? -1) >= min) {
      const op = tokens[pos++].v;
      left = [op, left, parse(precedence[op] + (op === '^' ? 0 : 1))];
    }
    return left;
  }

  const result = parse(0);
  return { expr: result, pos };
}


function functionBody(tokens) {
  if (!is(tokens[0], 'function') || !is(tokens[1], '(') || !is(tokens.at(-1), 'end')) throw new Error('Not function');
  const close = closeAt(tokens, 1);
  const params = tokens.slice(2,close).filter((t) => !is(t, ',')).map(t=>t.v);
  // Optional parameters beyond (self, t) are never passed by `info`, so they are
  // always nil there — see getterBody, which keeps only the branch that runs.
  if (!/^self,t(,\w+)*$/.test(params.join(','))) throw new Error('Extra function parameters');
  return { body: tokens.slice(close+1,-1), params };
}

/**
 * The expression a getter returns.
 *
 * `getDamage = function(self, t, second) if second then ... else ... end end`
 * is called from `info` as `t.getDamage(self, t)`, so `second` is nil and the
 * else branch is the one the export rendered.
 */
function getterBody(body, params) {
  if (is(body[0], 'return')) return body.slice(1);
  const extra = params.slice(2);
  if (is(body[0], 'if') && extra.length) {
    const cond = is(body[1], 'token') ? body[1].v : null;
    if (cond && extra.includes(cond) && is(body[2], 'then') && is(body[3], 'return')) {
      // Skip to the matching `else`, which starts at the branch's own depth.
      let depth = 0;
      for (let i = 3; i < body.length; i++) {
        if (is(body[i], 'if') || is(body[i], 'function') || is(body[i], 'for') || is(body[i], 'while')) depth++;
        else if (is(body[i], 'end')) depth--;
        else if (is(body[i], 'else') && depth === 0) {
          if (!is(body[i+1], 'return')) throw new Error('Getter control flow');
          return body.slice(i + 2);
        }
      }
    }
  }
  throw new Error('Getter control flow');
}

function infoExpressions(tokens, getter, debug) {
  const { body } = functionBody(tokens);
  // Conditional statements and reassignments require control-flow analysis. Fail closed.
  const env = Object.create(null);
  let pos = 0;
  // Locals are consumed one statement at a time by parsing the expression and
  // using its token count. The previous scanner skipped balanced groups and
  // mistook call parentheses for a nested block, which is why
  // `local absorb = self:getShieldAmount(t.getAbsorb(self, t))` never resolved.
  while (is(body[pos], 'local')) {
    // Collect the declared names: `local a = x` or `local a, b = x, y`.
    const names = [];
    let head = pos + 1;
    while (body[head] && !is(body[head], '=')) {
      if (body[head].kind === 'token' && /^[A-Za-z_]/.test(body[head].v)) names.push(body[head].v);
      else if (body[head].v !== ',') throw new Error('Multiple local assignment');
      head++;
    }
    if (!names.length || !is(body[head], '=') || names.length > 4) throw new Error('Multiple local assignment');
    const name = names[0];
    const rhsAt = head + 1;
    // Multiple right-hand sides: parse them in order and bind names positionally.
    const parts = names.length > 1 ? splitTop(body.slice(rhsAt)) : [body.slice(rhsAt)];
    if (names.length > 1 && parts.length !== names.length) throw new Error('Multiple local assignment');
    try {
      if (names.length > 1) {
        let cursor = rhsAt;
        for (let k = 0; k < parts.length; k++) {
          const rk = expressionAt(body.slice(cursor), env, getter);
          env[names[k]] = rk.expr;
          cursor += rk.pos;
        }
        pos = cursor;
        if (is(body[pos], ';')) pos++;
        continue;
      }
    } catch {
      // fall through to the single-name path below, which has its own recovery
    }
    try {
      const r = expressionAt(body.slice(pos + 3), env, getter);
      // dodge: a local RHS must reach the end of the statement, not stop early
      const after = body[pos + 3 + r.pos];
      if (after && !is(after, ';') && !is(after, 'local') && !is(after, 'return')) {
        throw new Error('Trailing tokens in local');
      }
      env[name] = r.expr;
      pos = pos + 3 + r.pos;
    } catch {
      // Skip just this statement so a later local can still resolve, and so the
      // `return` detection below still lands on the right token.
      pos += 3;
      let depth = 0;
      while (pos < body.length) {
        const v = body[pos].v;
        if (['(', '{', '['].includes(v)) depth++;
        else if ([')', '}', ']'].includes(v)) depth--;
        else if (depth === 0 && ['local', 'return', ';'].includes(v)) break;
        pos++;
      }
    }
    if (is(body[pos], ';')) pos++;
  }
  if (!is(body[pos], 'return')) throw new Error('Info control flow');
  const rest = body.slice(pos+1);
  // A single literal format string, optionally wrapped in parentheses.
  let i = 0;
  if (is(rest[i], '(')) {
    if (rest[i+1]?.kind !== 'string' || !is(rest[i+2], ')')) throw new Error('Dynamic format');
    i += 3;
  } else { if (rest[i]?.kind !== 'string') throw new Error('Dynamic format'); i++; }
  if (!is(rest[i], ':') || !['format','tformat'].includes(rest[i+1]?.v) || !is(rest[i+2], '(')) throw new Error('Missing format');
  const end = closeAt(rest,i+2);
  if (end !== rest.length-1) throw new Error('Extra info expression');
  return splitTop(rest.slice(i+3,end)).flatMap((arg,index) => {
    try {
      const expr = expressionAt(arg, env, getter).expr;
      const calls = formulaCalls(expr).length;
      if (debug && !calls) {
        const symbols = [...new Set(resolvedSymbols(expr))];
        debug.push(
          symbols.length
            ? `arg${index + 1}: depends on unmodelled actor state (${symbols.slice(0, 4).join(', ')})`
            : `arg${index + 1}: holds no formula call`,
        );
      }
      return calls ? [{ expr, argument: index + 1 }] : [];
    } catch (e) {
      if (debug) debug.push(`arg${index + 1}: ${e.message}`);
      return [];
    }
  });
}

export function extractTalents(source, file = 'fixture.lua') {
  const tokens = tokenizeLua(source);
  const records = [];
  // Three constructors define player-visible talents. `uberTalent` blocks carry
  // no `type` field (the file names the tree: uber/str.lua -> uber/strength) and
  // `newInscription` blocks all declare index 1, so both need a synthesized
  // index: the 0-based ordinal of blocks sharing that tree, in file order — which
  // is exactly how the export indexes them.
  const fileKey = String(file).split('/').pop().replace(/\.lua$/, '');
  let uberOrdinal = 0;
  const treeCounts = new Map();
  for (let i=0;i<tokens.length;i++) {
    const kind = is(tokens[i], 'newTalent') ? 'newTalent'
      : is(tokens[i], 'uberTalent') ? 'uberTalent'
        : is(tokens[i], 'newInscription') ? 'newInscription' : null;
    if (!kind || !is(tokens[i+1], '{')) continue;
    const end = closeAt(tokens,i+1);
    const fields = Object.create(null);
    for (const field of splitTop(tokens.slice(i+2,end))) {
      if (is(field[1], '=')) fields[field[0].v] = field.slice(2);
    }
    const line = source.slice(0,tokens[i].start).split('\n').length;
    currentFields = fields;
    i = end;
    const type = fields.type;
    const declared = is(type?.[0],'{') && is(type?.at(-1),'}') ? splitTop(type.slice(1,-1)).slice(0,2).map((tokens) => { try { return literal(tokens); } catch { return undefined; } }) : null;
    const declaredTree = typeof declared?.[0] === 'string' ? declared[0] : null;
    const declaredIndex = Number.isInteger(declared?.[1]) ? declared[1] : null;
    const takeOrdinal = (key) => {
      const next = treeCounts.get(key) ?? 0;
      treeCounts.set(key, next + 1);
      return next;
    };
    let tree, index;
    if (kind === 'uberTalent') {
      tree = `uber/${UBER_TREE_BY_FILE[fileKey] ?? fileKey}`;
      index = uberOrdinal++;
    } else if (declaredTree && (kind === 'newInscription' || declaredIndex === null)) {
      // `type = {"spell/other", }` (no index) and every `newInscription` block
      // (all declare index 1) still have a real position in their tree: the
      // export indexes them by order of appearance.
      tree = declaredTree;
      index = takeOrdinal(declaredTree);
    } else {
      [tree, index] = declared ?? [];
    }
    const shortName = literalOrNull(fields.short_name);
    const name = literalOrNull(fields.name);
    const identity = () => ({tree,index,shortName,name,file,line});
    if (typeof tree !== 'string' || !Number.isInteger(index)) continue;
    try {
      const cache = new Map(), active = new Set();
      const getterFn = (name, env) => {
        if (cache.has(name)) return cache.get(name);
        if (active.has(name) || !fields[name]) throw new Error('Unknown or recursive getter');
        active.add(name);
        try {
          let body = fields[name];
          if (is(body[0],'function')) {
            const signature = functionBody(body);
            body = getterBody(signature.body, signature.params);
          }
          const result = expression(body, env || {}, getterCall);
          cache.set(name, result);
          return result;
        } finally { active.delete(name); }
      };
      // getterFn returns the bare expression AST, so no `.expr` unwrapping here.
      const getterCall = (name, env) => getterFn(name, env);
      currentGetter = getterCall;
      let candidates = [], reason = null;
      const debug = process.env.TOME_EXTRACT_DEBUG ? [] : null;
      try { candidates = infoExpressions(fields.info || [], getterCall, debug); } catch(e) { reason = e.message; }
      if (debug && !candidates.length) {
        const label = fields.name ? literal(fields.name) : `${file}:${line}`;
        debug.forEach((d) => console.error(`[extract] ${label} ${d}`));
      }
      const calls = [];
      // Audit all combat calls, including those intentionally not evaluated.
      for (const [field, value] of Object.entries(fields)) {
        for (let k=0;k<value.length-3;k++) if (is(value[k],'self') && is(value[k+1],':') && /^combat/.test(value[k+2].v) && is(value[k+3],'(')) {
          const stop=closeAt(value,k+3);
          const args=splitTop(value.slice(k+4,stop));
          let parsed=null;
          try { parsed=combatCall(value[k+2].v,args); } catch {}
          calls.push({field,method:value[k+2].v,arguments:args.map(a=>a.map(t=>t.kind==='string'?JSON.stringify(t.v):t.v).join(' ')),literal:parsed!==null});
        }
      }
      records.push({...identity(),candidates,calls,...(reason?{reason}:{})});
    } catch (e) {
      // A block that resolves its identity but fails to parse must stay visible:
      // silently dropping it hides recoverable values from the audit.
      records.push({...identity(),candidates:[],reason:`extract failed: ${e.message}`});
    }
  }
  return records;
}

function walk(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name,'en')).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)):e.name.endsWith('.lua')?[path.join(dir,e.name)]:[]);
}

export function buildLuaIndex({workspace,rawDir}) {
  const roots = [
    ['base','tome-src-full',0], ['ashes-urhrok','dlc-src/ashes-urhrok/tome-ashes-urhrok',2],
    ['cults','dlc-src/cults/tome-cults',3], ['orcs','dlc-src/orcs/tome-orcs',10],
  ];
  const exports = fs.readdirSync(rawDir).filter(n=>/^talents\..*-1\.5\.json$/.test(n)).flatMap(n=>JSON.parse(fs.readFileSync(path.join(rawDir,n),'utf8')).flatMap(t=>t.talents||[]));
  const byType = new Map();
  for(const t of exports) { const key=JSON.stringify(t.type); const list=byType.get(key)||[]; list.push(t); byType.set(key,list); }
  /**
   * The export names the defining file and line of every talent, so (file, line)
   * identifies it independently of any tree/index the parser had to synthesize
   * (`type = {"spell/other", }`, `uberTalent`). Both sides normalize to
   * `<addon-data-dir>|<path under it>|<line>`.
   */
  const byLine = new Map();
  const lineKey = (addon, sourcePath, line) => {
    const trimmed = String(sourcePath || '').replace(/^data\//, '');
    return `${addon === 'base' ? 'data' : `data-${addon}`}|${trimmed}|${line}`;
  };
  for(const t of exports) {
    const [sourcePath, line] = t.source_code || [];
    if(!sourcePath) continue;
    const key = lineKey(String(sourcePath).split('/')[0].replace(/^data-?/, '') || 'base', sourcePath, line);
    const list = byLine.get(key) || [];
    list.push(t);
    byLine.set(key, list);
  }
  const rawHash=crypto.createHash('sha256');
  for(const name of fs.readdirSync(rawDir).filter(n=>/^talents\..*-1\.5\.json$/.test(n)).sort()) rawHash.update(name).update(fs.readFileSync(path.join(rawDir,name)));
  const hash=crypto.createHash('sha256');
  const records=[]; const overlays=[]; const missing=[];
  for(const [addon,rel,weight] of roots) {
    const root=path.join(workspace,rel);
    if(!fs.existsSync(path.join(root,'data/talents'))) { missing.push(addon); continue; }
    for (const relFile of ['init.lua', addon === 'base' ? 'mod/class/interface/Combat.lua' : 'superload/mod/class/interface/Combat.lua']) {
      const file = path.join(root, relFile);
      if (fs.existsSync(file)) hash.update(path.relative(workspace,file)).update(fs.readFileSync(file));
    }
    for(const file of walk(path.join(root,'data/talents'))) {
      const source=fs.readFileSync(file,'utf8');
      const relative=path.relative(workspace,file).split(path.sep).join('/');
      hash.update(relative).update(source);
      let extracted; try { extracted=extractTalents(source,relative); } catch(e) { throw new Error(`${relative}: ${e.message}`); }
      records.push(...extracted.map(r=>({...r,addon,weight,sourcePath:path.relative(root,file).split(path.sep).join('/')})));
    }
    if(addon!=='base') for(const folder of ['superload','overload','hooks']) for(const file of walk(path.join(root,folder))) {
      const source=fs.readFileSync(file,'utf8');
      const relative=path.relative(workspace,file).split(path.sep).join('/');
      hash.update(relative).update(source);
      const code=tokenizeLua(source);
      const ids=[...new Set(code.filter(t=>t.kind==='token' && /^T_[A-Z0-9_]+$/.test(t.v)).map(t=>t.v))];
      // Mentioning a talent is not patching it: engine-side superloads talk about
      // dozens of ids in `knowTalent` checks. A file only changes the numbers we
      // extract when it defines the talent, assigns one of its fields directly
      // (`Talents.T_X.getDamage = …`), or assigns a getter field on a single-id
      // alias (`local t = Talents.talents_def.T_X; t.getDamage = …`).
      const patchedIds=new Set();
      try {
        for(const r of extractTalents(source, relative)) {
          const short = r.shortName || (typeof r.name === 'string' ? r.name.toUpperCase().replace(/[^A-Z0-9_]/g,'_') : null);
          if(short) patchedIds.add(`T_${String(short).toUpperCase()}`);
        }
      } catch { /* the overlay still counts as a patch by path below */ }
      let aliasedFieldAssignment=false;
      for(let k=0;k<code.length-3;k++) {
        if(code[k].kind!=='token' || code[k+1].v!=='.') continue;
        if(!/^(?:info|get[A-Za-z_]+)$/.test(code[k+2]?.v||'')) continue;
        if(!is(code[k+3],'=')) continue;
        const target=code[k].v;
        if(/^T_[A-Z0-9_]+$/.test(target)) patchedIds.add(target);
        else aliasedFieldAssignment=true;
      }
      if(aliasedFieldAssignment && ids.length===1) patchedIds.add(ids[0]);
      overlays.push({file:relative,ids,patchedIds:[...patchedIds],sourcePath:folder==='hooks'?null:path.relative(path.join(root,folder),file).split(path.sep).join('/')});
    }
  }
  const talents={}; let unmapped=0;
  for(const record of records) {
    let possible=byType.get(JSON.stringify([record.tree,record.index]))||[];
    // A synthesized tree/index may not match the export's enumeration, so fall
    // back to the defining file and line, which the export states outright.
    if(possible.length!==1 && record.sourcePath && record.line) {
      const direct=byLine.get(lineKey(record.addon,record.sourcePath,record.line))||[];
      if(direct.length===1) possible=direct;
    }
    if(record.shortName) possible=possible.filter(t=>t.short_name===record.shortName);
    if(possible.length>1 && typeof record.name==='string') {
      const named=possible.filter(t=>t.short_name===record.name.toUpperCase().replace(/[^A-Z0-9_]/g,'_'));
      if(named.length===1) possible=named;
    }
    if(possible.length>1) possible=possible.filter(t=>t.source_code?.[0]===record.sourcePath);
    if(possible.length>1) possible=possible.filter(t=>t.source_code?.[1]===record.line);
    if(possible.length!==1) { unmapped++; continue; }
    const raw=possible[0];
    // A mismatched source path is evidence of a different talent/version, not an alias.
    const sourceMatches = raw.source_code?.[0] === record.sourcePath || raw.source_code?.[0] === `/data-${record.addon}/${record.sourcePath.slice(5)}` || raw.source_code?.[0] === `data-${record.addon}/${record.sourcePath.slice(5)}`;
    const entry={...record,id:raw.id,sourceMatches};
    const previous=talents[raw.id];
    if(!previous || previous.weight<record.weight) talents[raw.id]=entry;
    else if(previous.weight===record.weight) talents[raw.id]={...previous,candidates:[],reason:'ambiguous duplicate definition'};
  }
  for(const entry of Object.values(talents)) {
    const affected=overlays.filter(o=>o.patchedIds.includes(entry.id) || (o.sourcePath===entry.sourcePath && o.patchedIds.length));
    // A DLC that really redefines the talent wins (addons load after the base
    // game); merely being mentioned by engine code does not.
    if(affected.length) { entry.candidates=[]; entry.reason='possible DLC patch'; entry.patches=affected.map(o=>o.file); }
    if(!entry.sourceMatches) { entry.candidates=[]; entry.reason='source path mismatch'; }
  }
  return {version:1,rawHash:rawHash.digest('hex'),sourceHash:hash.digest('hex'),loadOrder:roots.map(r=>r[0]),missing,stats:{definitions:records.length,mapped:Object.keys(talents).length,unmapped,candidates:Object.values(talents).reduce((n,t)=>n+t.candidates.length,0),calls:records.reduce((n,t)=>n+t.calls.length,0),literalCalls:records.reduce((n,t)=>n+t.calls.filter(c=>c.literal).length,0)},talents};
}

if(process.argv[1] && path.resolve(process.argv[1])===fileURLToPath(import.meta.url)) {
  const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
  const arg=(name,fallback)=>{const i=process.argv.indexOf(name);return i<0?fallback:path.resolve(process.argv[i+1]);};
  const index=buildLuaIndex({workspace:arg('--workspace',path.dirname(root)),rawDir:arg('--raw',path.join(root,'data/raw/master'))});
  const output=arg('--out',path.join(root,'data/lua-coefficients.json'));
  if(index.missing.length) throw new Error(`Incomplete Lua source trees: ${index.missing.join(', ')}; existing snapshot was not changed`);
  fs.writeFileSync(output,JSON.stringify(index,null,2)+'\n');
  console.log(JSON.stringify({...index.stats,sourceHash:index.sourceHash,missing:index.missing,output},null,2));
}
