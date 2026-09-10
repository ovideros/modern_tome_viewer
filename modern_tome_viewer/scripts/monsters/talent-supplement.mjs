/**
 * Supplemental talents for the monster encyclopedia.
 *
 * The upstream talent export is a 1.5-era snapshot; the 1.7.6 sources contain
 * talents it never emitted. Monster templates reference those anyway, so the
 * monster page would otherwise show "未收录" for real in-game skills.
 *
 * This module reads the actual `newTalent{...}` definitions from the local Lua
 * sources for exactly the ids the monster extraction could not resolve, pulls
 * their Chinese name and description out of the game's locale tables, and writes
 * `data/talent-supplement.json`. `scripts/build-data.mjs` merges that file into
 * `public/data/talents.json`, so the entries get the normal talent detail view.
 *
 * Only ids in the gap set are exported: this is not a second talent pipeline.
 */

import fs from 'node:fs';
import path from 'node:path';
import { parseLuaFile } from './lua-table.mjs';
import { readLocale, translate } from './locale.mjs';

/** Directories that may contain talent definitions. */
function talentDirs(rootDir) {
  return [
    path.join(rootDir, 'tome-src-full/data/talents'),
    path.join(rootDir, 'dlc-src/orcs/tome-orcs/data/talents'),
    path.join(rootDir, 'dlc-src/ashes-urhrok/tome-ashes-urhrok/data/talents'),
    path.join(rootDir, 'dlc-src/cults/tome-cults/data/talents'),
  ];
}

function collectLua(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  const walk = (current) => {
    for (const entry of fs.readdirSync(current, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
      const full = path.join(current, entry.name);
      if (entry.isDirectory()) walk(full);
      else if (entry.name.endsWith('.lua')) out.push(full);
    }
  };
  walk(dir);
  return out;
}

const LITERAL_KEYS = new Set([
  'name', 'short_name', 'type', 'points', 'mana', 'stamina', 'cooldown', 'range', 'equilibrium',
  'vim', 'positive', 'negative', 'psi', 'hate', 'paradox', 'soul', 'steam', 'insanity',
  'mode', 'no_energy', 'no_silence', 'is_spell', 'is_mind', 'is_nature', 'is_steam',
  'is_summon', 'is_heal', 'requires_target', 'direct_hit', 'hide', 'not_listed',
  'is_melee', 'is_unarmed', 'is_necromancy', 'is_teleport', 'is_antimagic', 'generic',
  'uber', 'innate', 'is_curse', 'is_hex', 'is_psyshot', 'is_technomancy',
  'fixed_cooldown', 'use_speed', 'random_ego', 'proj_speed', 'refectable',
  'tactical', 'info',
]);

/**
 * Read one `newTalent{...}` block.
 *
 * `info` is a function whose returned literal is the display text when the
 * source uses a simple long string; more complex bodies are reported as
 * unavailable rather than guessed at.
 */
function extractTalent(node) {
  const fields = {};
  for (const entry of node.fields.map) {
    const key = entry.key?.value ?? entry.key?.path?.join('.') ?? null;
    if (!key || !LITERAL_KEYS.has(key)) continue;
    const value = entry.value;
    if (key === 'info') {
      fields.info = infoLiteral(value);
      continue;
    }
    if (value.kind === 'string') fields[key] = value.value;
    else if (value.kind === 'number') fields[key] = value.value;
    else if (value.kind === 'boolean') fields[key] = value.value;
    else if (value.kind === 'table') fields[key] = tableLiteral(value);
  }
  return fields;
}

/** Best-effort literal for a `type = {"spell/war-alchemy", 1}` table. */
function tableLiteral(node) {
  if (node.array?.length) {
    const first = node.array[0];
    return first?.kind === 'string' ? first.value : undefined;
  }
  return undefined;
}

/**
 * Pull the returned string out of an `info = function(self, t) ... end` body.
 *
 * Only the simplest shape is supported: a single `return ([[...]]):tformat(...)`
 * or `return [[...]]`. Anything else returns null so the report can list it as
 * "description needs manual review" instead of inventing text.
 */
function infoLiteral(node) {
  if (!node || node.kind !== 'function') return null;
  return node.infoText ?? null;
}

/**
 * Find talent definitions for the requested ids.
 *
 * The game derives the talent id as `T_` + the uppercase `short_name` or, when
 * absent, the uppercased `name` with non-alphanumerics replaced. Both spellings
 * are checked.
 */
export function extractTalentSupplement(rootDir, wantedIds, options = {}) {
  const wanted = new Set(wantedIds);
  const found = new Map();
  const diagnostics = [];
  const locale = options.locale ?? readLocale(path.join(rootDir, 'tome-src-full/data/locales/zh_hans.lua'));

  for (const dir of talentDirs(rootDir)) {
    for (const file of collectLua(dir)) {
      const rel = path.relative(rootDir, file);
      const parsed = parseLuaFile(fs.readFileSync(file, 'utf8'), rel);
      for (const talent of parsed.talentBlocks ?? []) {
        if (talent.callee !== 'newTalent') continue;
        const fields = extractTalent(talent);
        const id = talentIdFor(fields);
        if (!id || !wanted.has(id) || found.has(id)) continue;
        const nameZh = translate(locale.map, fields.name ?? '');
        const infoZh = fields.info ? translate(locale.map, fields.info) : null;
        found.set(id, {
          id,
          enName: fields.name ?? id,
          name: nameZh.status === 'missing' ? (fields.name ?? id) : nameZh.text,
          tree: typeof fields.type === 'string' ? fields.type : null,
          points: typeof fields.points === 'number' ? fields.points : null,
          cooldown: typeof fields.cooldown === 'number' ? fields.cooldown : null,
          mode: fields.mode ?? null,
          info: infoZh && infoZh.status !== 'missing' ? infoZh.text : fields.info ?? null,
          infoStatus: infoZh?.status ?? (fields.info ? 'english' : 'none'),
          nameStatus: nameZh.status,
          file: rel,
          line: talent.line,
          source: 'lua-supplement',
        });
        if (!fields.info) {
          diagnostics.push({ id, file: rel, line: talent.line, message: 'info 未提取到字面量文本' });
        }
      }
    }
  }

  for (const id of wanted) {
    if (!found.has(id)) diagnostics.push({ id, message: '源码中未找到定义', file: null, line: null });
  }

  return { talents: [...found.values()].sort((a, b) => a.id.localeCompare(b.id)), diagnostics };
}

/** Derive the game talent id from the definition fields. */
export function talentIdFor(fields) {
  const base = fields.short_name ?? fields.name;
  if (typeof base !== 'string' || !base) return null;
  return `T_${base.toUpperCase().replace(/[^A-Z0-9]+/g, '_')}`;
}

export function writeSupplement(rootDir, outFile, wantedIds) {
  const result = extractTalentSupplement(rootDir, wantedIds);
  fs.mkdirSync(path.dirname(outFile), { recursive: true });
  fs.writeFileSync(
    outFile,
    JSON.stringify(
      {
        version: 1,
        generatedAt: new Date().toISOString(),
        note: '由 scripts/monsters/talent-supplement.mjs 从本地 1.7.6 Lua 源码提取，仅覆盖上游技能导出缺失、但怪物模板实际引用的技能。',
        talents: result.talents,
        diagnostics: result.diagnostics,
      },
      null,
      2,
    ) + '\n',
  );
  return result;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const root = path.resolve(process.argv[2] ?? path.join(process.cwd(), '..'));
  const out = path.resolve(process.argv[3] ?? path.join(process.cwd(), 'data/talent-supplement.json'));
  const wanted = process.argv.slice(4);
  const result = writeSupplement(root, out, wanted);
  console.log(`[talent-supplement] ${result.talents.length} talents -> ${out}`);
  for (const talent of result.talents) console.log(`  ${talent.id}  ${talent.name}  (${talent.file})`);
  for (const diagnostic of result.diagnostics) console.log(`  ! ${diagnostic.id}: ${diagnostic.message}`);
}
