/**
 * Formula workbench for values the extractor could not read from source.
 *
 * The export ships the same talents rendered three times (tooltip coefficient
 * 1.00 / 1.30 / 1.50), so every value has 15 real data points. A hand-written
 * expression is accepted only when it reproduces **all 15**, which is what makes
 * "read the Lua and write the formula" a verifiable job rather than a guessing
 * game.
 *
 * Usage:
 *   node scripts/try-formula.mjs --list [--tree chronomancy/anomalies] [--limit 20]
 *   node scripts/try-formula.mjs --talent T_FLAMESHOCK --arg 2 --expr '["spellDamage",10,250]'
 *   node scripts/try-formula.mjs --overlay data/lua-expressions.json
 *
 * Expression nodes are documented in docs/expression-overlay.md.
 */

import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { parseAcronyms, defaultSimParams, simAtAxis, evaluateAcronym } = require('../src/lib/scaling-core.js');
const { matchesDisplayed, declaredInputs, consumedInputs, uncoveredInputs, ladderAxis, checkHandExpression } = await import('./lua-scaling.mjs');

const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
const SITE = path.resolve(ROOT, '../starsapphirex.github.io/tometips/data/master');
const VARIANT_NAMES = ['1', '1.3', '1.5'];
const BUILT = JSON.parse(fs.readFileSync(path.join(ROOT, 'public/data/talents.json'), 'utf8'));
const LUA_INDEX = JSON.parse(fs.readFileSync(path.join(ROOT, 'data/lua-coefficients.json'), 'utf8'));

/** Variant coefficient -> acronyms per talent, in info-text order. */
const variantAcronyms = new Map();
function variant(name) {
  if (!variantAcronyms.has(name)) {
    const map = new Map();
    for (const file of fs.readdirSync(SITE).filter((n) => n.endsWith(`-${name}.json`))) {
      for (const group of JSON.parse(fs.readFileSync(path.join(SITE, file), 'utf8'))) {
        for (const talent of group.talents || []) {
          map.set(talent.id, parseAcronyms(talent.info_text || '', { fit: false }));
        }
      }
    }
    variantAcronyms.set(name, map);
  }
  return variantAcronyms.get(name);
}

const built = new Map();
for (const tree of BUILT.trees) for (const talent of tree.talents || []) built.set(talent.id, { talent, tree });

const args = process.argv.slice(2);
const flag = (name) => {
  const i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : null;
};
const has = (name) => args.includes(name);

/** Read the expression as JSON, tolerating single quotes from a shell. */
function parseExpression(text) {
  try {
    return JSON.parse(text);
  } catch {
    return JSON.parse(text.replace(/'/g, '"'));
  }
}

/**
 * Evaluate one expression against every variant's own rendering.
 *
 * Each variant declares its own 技能系数, so the expression is evaluated at that
 * coefficient — the point of the exercise is that one formula, three renderings.
 */
function checkExpression(talentId, acronymIndex, expr, conditions = null) {
  const entry = built.get(talentId);
  if (!entry) return { ok: false, error: `unknown talent ${talentId}` };
  const variants = [];
  for (const name of VARIANT_NAMES) {
    const ref = variant(name).get(talentId)?.[acronymIndex];
    if (!ref) {
      variants.push({ name, error: '该技能在这套导出里找不到，或没有这个 acronym' });
      continue;
    }
    const check = checkHandExpression(ref, expr, conditions);
    if (check.error) {
      variants.push({ name, error: '标题里没有唯一可变的轴' });
      continue;
    }
    const decimal = (ref.precision ?? 0) > 0;
    const points = check.points.map((point) => {
      const finite = Number.isFinite(point.predicted);
      const truncMatches = finite && Math.trunc(point.predicted) === point.displayed;
      const roundMatches = finite && Math.round(point.predicted) === point.displayed;
      return {
        axis: point.axis,
        displayed: point.displayed,
        predicted: finite ? Number(point.predicted.toFixed(4)) : null,
        ok: point.ok,
        reading: decimal ? 'decimal' : truncMatches && roundMatches ? 'both' : truncMatches ? 'trunc' : roundMatches ? 'round' : 'none',
      };
    });
    const coefficient = ref.params.find((p) => p.kind === 'coefficient')?.value ?? 1.5;
    variants.push({
      name,
      coefficient,
      axis: check.axis,
      ladder: check.ladder,
      suffix: ref.suffix,
      prefix: ref.prefix ?? '',
      tail: ref.tail ?? '',
      points,
      ok: check.ok,
    });
  }
  // The three variants say the same thing about inputs (only the coefficient
  // differs), so read the declaration off the canonical 1.5 set.
  const canonical = variant('1.5').get(talentId)?.[acronymIndex];
  const canonicalAxis = canonical ? ladderAxis(canonical) : null;
  const declared = canonical && canonicalAxis ? declaredInputs(canonical, canonicalAxis) : [];
  const first = variants.find((v) => v.points);
  const consumed = first ? consumedInputs(expr, first.axis) : [];
  // Only "the formula reads something the title never pins" fails. The reverse
  // (title declared more than this value uses) is normal in this export and is
  // reported as a superset, not as a failure.
  const missing = uncoveredInputs(declared, consumed);
  const unused = declared.filter((label) => !consumed.includes(label));
  return {
    talentId,
    acronymIndex,
    declared,
    consumed,
    missing,
    unused,
    inputsMatch: missing.length === 0,
    variants,
    ok: variants.every((v) => v.ok),
  };
}

function printCheck(result) {
  const entry = built.get(result.talentId);
  console.log(`技能 ${result.talentId} ${entry ? `(${entry.talent.name} / ${entry.tree.id})` : ''} · acronym#${result.acronymIndex}`);
  const rec = LUA_INDEX.talents?.[result.talentId];
  if (rec) console.log(`源码 ${rec.file}:${rec.line}`);
  const relation = result.inputsMatch
    ? (result.unused.length ? `✅ 覆盖（标题是超集，本值未用到：${result.unused.join(', ')}）` : '✅ 完全一致')
    : `❌ 表达式读了标题未声明的输入 [${result.missing.join(', ')}]`;
  console.log(`输入集合：标题声明 [${result.declared.join(', ') || '无'}] vs 表达式消耗 [${result.consumed.join(', ') || '无'}] ${relation}`);
  for (const v of result.variants) {
    if (v.error) {
      console.log(`  系数 ${v.name}: ✗ ${v.error}`);
      continue;
    }
    const points = v.points
      .map((p) => `${p.axis}→ 导出 ${p.displayed}${v.suffix} / 算得 ${p.predicted === null ? '—' : p.predicted}${p.ok ? '✅' : '❌'}${p.reading === 'trunc' ? '(截断)' : p.reading === 'round' ? '(四舍五入)' : ''}`)
      .join('  ');
    console.log(`  系数 ${String(v.coefficient).padEnd(4)}: ${v.ok ? '✅ 5/5' : '❌'}  ${points}`);
  }
  console.log(result.ok && result.inputsMatch ? '\n结论：PASS（三套 15 点全中，输入集合覆盖）' : '\n结论：FAIL');
}

function listTargets() {
  const treeFilter = flag('--tree');
  const limit = Number(flag('--limit') ?? 0);
  let shown = 0;
  for (const tree of BUILT.trees) {
    if (treeFilter && tree.id !== treeFilter) continue;
    for (const talent of tree.talents || []) {
      const rec = LUA_INDEX.talents?.[talent.id];
      for (const [index, acronym] of (talent.acronyms || []).entries()) {
        if (acronym.l) continue;
        shown += 1;
        if (limit && shown > limit) return;
        const ladders = VARIANT_NAMES.map((name) => {
          const ref = variant(name).get(talent.id)?.[index];
          return ref ? `${ref.displayed.join('/')}${ref.suffix}` : '—';
        });
        const params = (acronym.p || []).map((p) => `${p[0]}=${p[2] ?? p[3].join('/')}`).join(', ');
        console.log([
          talent.id, talent.name, tree.id, `acronym#${index}`,
          `点数=${talent.points}`,
          `值: ${ladders.join(' | ')}`,
          `参数: ${params}`,
          `源码: ${rec ? `${rec.file}:${rec.line}` : '无记录'}`,
          rec && !rec.candidates.length ? (rec.reason || '无候选') : '',
        ].join('\t'));
      }
    }
  }
}

function runOverlay() {
  const file = flag('--overlay');
  if (!file || !fs.existsSync(path.resolve(ROOT, file))) {
    console.error(`overlay not found: ${file}`);
    process.exit(2);
  }
  const overlay = JSON.parse(fs.readFileSync(path.resolve(ROOT, file), 'utf8'));
  const entries = Array.isArray(overlay) ? overlay : Object.entries(overlay).map(([id, v]) => ({ talent: id, ...v }));
  let pass = 0;
  const failures = [];
  for (const entry of entries) {
    const result = checkExpression(entry.talent, entry.acronym, parseExpression(JSON.stringify(entry.expr)), entry.conditions ?? null);
    if (result.ok && result.inputsMatch) pass += 1;
    else failures.push({ entry, result });
  }
  console.log(`覆盖层校验：${pass}/${entries.length} 通过`);
  for (const f of failures.slice(0, 10)) {
    console.log(`\n✗ ${f.entry.talent} acronym#${f.entry.acronym}`);
    if (f.result.error) console.log(`   ${f.result.error}`);
    else printCheck(f.result);
  }
  if (failures.length) process.exitCode = 1;
}

if (has('--list')) listTargets();
else if (has('--overlay')) runOverlay();
else {
  const talentId = flag('--talent');
  const expr = flag('--expr');
  if (!talentId || !expr) {
    console.error('用法：--list [--tree X] [--limit N] | --talent <ID> --arg <序号> --expr <JSON> | --overlay <文件>');
    process.exit(2);
  }
  const result = checkExpression(talentId, Number(flag('--arg') ?? 0), parseExpression(expr));
  if (has('--json')) console.log(JSON.stringify(result, null, 1));
  else printCheck(result);
  if (!result.ok || !result.inputsMatch) process.exitCode = 1;
}
