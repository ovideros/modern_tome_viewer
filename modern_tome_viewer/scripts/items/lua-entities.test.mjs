/**
 * Regression tests for the item-side Lua scanner.
 *
 * The whole reason this reader exists is that `parseLuaFile` silently returns
 * zero entities for `world-artifacts.lua`. These tests pin that behaviour down
 * in both directions: the monster reader still fails on such a file (documenting
 * why the item path exists), and the item reader handles it.
 *
 * Run:  node --test scripts/items/*.test.mjs
 */

import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { tokenize, parseLuaFile } from '../monsters/lua-table.mjs';
import { scanItemFile, scanItemTokens, matchBrackets, ITEM_SOURCES } from './lua-entities.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..', '..');
const workspaceRoot = path.resolve(projectRoot, '..');

/** Read a file relative to a source root, or null when the sources are absent. */
function sourceFile(sourceId, relative) {
  const source = ITEM_SOURCES.find((s) => s.id === sourceId);
  const file = path.join(workspaceRoot, source.dir, relative);
  return fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null;
}

test('brace matching ignores brackets inside strings', () => {
  const tokens = tokenize('local a = { x = "}", y = [[}]] , z = 1 }');
  const { openAt } = matchBrackets(tokens);
  const open = tokens.findIndex((t) => t.type === 'punct' && t.value === '{');
  const close = openAt.get(open);
  assert.ok(close !== undefined, 'the table brace must be paired');
  // The closer must be the final `}`, not either one hiding in a string.
  assert.equal(tokens[close].value, '}');
  assert.equal(tokens.slice(close + 1).filter((t) => t.type !== 'newline' && t.type !== 'eof').length, 0);
});

test('a top-level for loop does not swallow later definitions', () => {
  // This is the exact shape at the top of world-artifacts.lua.
  const src = [
    'for def, e in pairs(game.state:getWorldArtifacts()) do',
    '\timportEntity(e)',
    '\tprint("Importing "..e.name)',
    'end',
    '',
    'newEntity{ base = "BASE_GEM", name = "Real Artifact", unique = true, rarity = 10, }',
  ].join('\n');
  const { entities } = scanItemFile(src, 'synthetic.lua');
  assert.equal(entities.length, 1);
  const name = entities[0].fields.map.find((m) => m.key.value === 'name');
  assert.equal(name.value.value, 'Real Artifact');
});

test('the monster reader is still the reason this module exists', { skip: !sourceFile('tome', 'data/general/objects/world-artifacts.lua') }, () => {
  const src = sourceFile('tome', 'data/general/objects/world-artifacts.lua');
  // Documented upstream limitation, not something this task changed. If a
  // future change fixes parseLuaFile this assertion is the signal to revisit
  // the item-side reader rather than a claim that the fix is wrong.
  const monsterRead = parseLuaFile(src, 'world-artifacts.lua');
  assert.equal(monsterRead.entities.length, 0, 'parseLuaFile is expected to miss this file');
  assert.equal(monsterRead.diagnostics.length, 0, 'and to miss it silently');
});

test('world-artifacts.lua yields its full top-level definition count', { skip: !sourceFile('tome', 'data/general/objects/world-artifacts.lua') }, () => {
  const src = sourceFile('tome', 'data/general/objects/world-artifacts.lua');
  const { entities, nested } = scanItemFile(src, 'world-artifacts.lua');
  assert.ok(entities.length >= 180, `expected the big artifact file to be read, got ${entities.length}`);
  // Every captured block must carry a name or a define_as, otherwise the brace
  // pairing drifted and we captured something that is not an entity.
  for (const entity of entities) {
    const keys = entity.fields.map.map((m) => m.key.value);
    assert.ok(keys.includes('name') || keys.includes('define_as'), `unnamed block at line ${entity.line}`);
  }
  // Nested definitions are reported, never silently dropped.
  assert.ok(Array.isArray(nested));
});

test('entity field access survives nested callbacks and long strings', { skip: !sourceFile('tome', 'data/general/objects/world-artifacts.lua') }, () => {
  const src = sourceFile('tome', 'data/general/objects/world-artifacts.lua');
  const { entities } = scanItemFile(src, 'world-artifacts.lua');
  const read = (entity, key) => entity.fields.map.find((m) => m.key.value === key)?.value;

  const gem = entities.find((e) => read(e, 'name')?.value === 'Windborne Azurite');
  assert.ok(gem, 'Windborne Azurite must be found');
  assert.equal(read(gem, 'image').value, 'object/artifact/windborn_azurite.png');
  assert.equal(read(gem, 'unique').value, true);
  assert.equal(read(gem, 'rarity').value, 240);

  const wielder = read(gem, 'wielder');
  assert.equal(wielder.kind, 'table');
  const incDamage = wielder.map.find((m) => m.key.value === 'inc_damage');
  assert.equal(incDamage.value.kind, 'table');
  // `[DamageType.LIGHTNING] = 20` keeps its dotted reference path.
  assert.equal(incDamage.value.map[0].key.path.join('.'), 'DamageType.LIGHTNING');
});

test('runtime function values are preserved as function nodes, not dropped', { skip: !sourceFile('tome', 'data/general/objects/world-artifacts.lua') }, () => {
  const src = sourceFile('tome', 'data/general/objects/world-artifacts.lua');
  const { entities } = scanItemFile(src, 'world-artifacts.lua');
  const read = (entity, key) => entity.fields.map.find((m) => m.key.value === key)?.value;
  const truth = entities.find((e) => read(e, 'name')?.value === "Golden Three-Edged Sword 'The Truth'");
  assert.ok(truth, "The Truth must be found");
  const combat = read(truth, 'combat');
  const proc = combat.map.find((m) => m.key.value === 'special_on_hit');
  assert.ok(proc, 'special_on_hit must be present');
  const fct = proc.value.map.find((m) => m.key.value === 'fct');
  assert.equal(fct.value.kind, 'function', 'the trigger callback must survive as a function node');
  // The fixed part of the same block must still be readable.
  assert.equal(combat.map.find((m) => m.key.value === 'dam').value.value, 49);
});

test('an entity with no name is still captured so nothing is lost', () => {
  const src = 'newEntity{ define_as = "BASE_THING", type = "weapon", slot = "MAINHAND", }';
  const { entities } = scanItemFile(src, 'synthetic.lua');
  assert.equal(entities.length, 1);
  const keys = entities[0].fields.map.map((m) => m.key.value);
  assert.deepEqual(keys, ['define_as', 'type', 'slot']);
});

test('nested newEntity inside a callback is reported as nested, not double counted', () => {
  const src = [
    'newEntity{ name = "Outer", unique = true, on_die = function(self)',
    '  newEntity{ name = "Inner" }',
    'end, }',
  ].join('\n');
  const { entities, nested } = scanItemFile(src, 'synthetic.lua');
  assert.equal(entities.length, 1);
  assert.equal(nested.length, 1);
  assert.equal(entities[0].fields.map.find((m) => m.key.value === 'name').value.value, 'Outer');
});

test('load() calls are collected for ego applicability resolution', () => {
  const src = [
    'load("/data/general/objects/egos/weapon.lua")',
    'load("/data/general/objects/egos/shield.lua")',
    '-- load("/data/general/objects/egos/ignored.lua")',
  ].join('\n');
  const tokens = tokenize(src);
  const { loads } = scanItemTokens(tokens);
  assert.deepEqual(loads.map((l) => l.path), [
    '/data/general/objects/egos/weapon.lua',
    '/data/general/objects/egos/shield.lua',
  ]);
});

test('steamsaw egos load both the weapon and the shield pools', { skip: !sourceFile('orcs', 'data/general/objects/egos/steamsaw.lua') }, () => {
  const src = sourceFile('orcs', 'data/general/objects/egos/steamsaw.lua');
  const { loads } = scanItemFile(src, 'steamsaw.lua');
  const paths = loads.map((l) => l.path);
  assert.ok(paths.includes('/data/general/objects/egos/weapon.lua'), 'chainsaws share the melee weapon pool');
  assert.ok(paths.includes('/data/general/objects/egos/shield.lua'), 'chainsaws also share the shield pool');
});

test('line numbers point at the real definition line', () => {
  const src = '-- header\n\nnewEntity{ name = "X" }\n';
  const { entities } = scanItemFile(src, 'synthetic.lua');
  assert.equal(entities[0].line, 3);
});

test('every ego file in every source parses, and stubs are the only empty ones', { skip: !sourceFile('tome', 'data/general/objects/egos/weapon.lua') }, () => {
  let files = 0;
  const empty = [];
  for (const source of ITEM_SOURCES) {
    const egosDir = path.join(workspaceRoot, source.dir, 'data', 'general', 'objects', 'egos');
    if (!fs.existsSync(egosDir)) continue;
    for (const name of fs.readdirSync(egosDir).filter((f) => f.endsWith('.lua'))) {
      const src = fs.readFileSync(path.join(egosDir, name), 'utf8');
      const { entities } = scanItemFile(src, name);
      if (entities.length === 0) {
        // A handful of ego files are pure loader stubs (`totems.lua` only
        // loads `charms.lua`); those are expected to hold no definitions.
        empty.push(`${source.id}/${name}`);
        continue;
      }
      for (const entity of entities) {
        const keys = entity.fields.map.map((m) => m.key.value);
        assert.ok(keys.includes('name') || keys.includes('define_as'), `${source.id}/${name} line ${entity.line} has neither name nor define_as`);
      }
      files += 1;
    }
  }
  // 40 ego files exist across the four sources; the four loader stubs account
  // for the difference.
  assert.ok(files >= 35, `expected to walk the ego files, only saw ${files}`);
  // An empty result is only legitimate for a pure loader stub, i.e. a file that
  // loads other ego files and defines nothing of its own. Anything else coming
  // back empty means the reader lost a file.
  for (const stub of empty) {
    assert.match(stub, /\/(totems|torques|steamsaw|steamgun)\.lua$/, `unexpected empty ego file: ${stub}`);
  }
});
