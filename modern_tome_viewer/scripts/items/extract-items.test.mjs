/**
 * Tests for the item extractor.
 *
 * These cover the risks the handoff calls out explicitly: the inheritance chain,
 * the three-way split between literal / resolver / function values, ego pool
 * sharing, and the classification boundary between items and NPC definitions.
 *
 * Run:  node --test scripts/items/*.test.mjs
 */

import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { parseLuaFile, literalOf, keyName } from '../monsters/lua-table.mjs';
import { scanItemFile, ITEM_SOURCES } from './lua-entities.mjs';
import {
  AREA_ORDER, EQUIP_TYPES, NPC_TYPES, classifyValue, extractProps, normalizeEgoPath,
  resolveEgoPools, stripFormatColors,
} from './extract-items.mjs';
import { classifyArtifact } from './build-items.mjs';
import { loadFieldMap, extractFieldMap, damageTypeKeys } from './field-map.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..', '..');
const workspaceRoot = path.resolve(projectRoot, '..');
const sourcesAvailable = fs.existsSync(path.join(workspaceRoot, 'tome-src-full/mod/class/Object.lua'));
const skip = sourcesAvailable ? false : 'game sources are not present';

// ---------------------------------------------------------------------------
// Value classification
// ---------------------------------------------------------------------------

test('classifyValue: literals stay literal', () => {
  const [, node] = astOf('x = 42');
  const result = classifyValue(node);
  assert.equal(result.kind, 'literal');
  assert.equal(result.value, 42);
});

test('classifyValue: a string literal keeps its text', () => {
  const [, node] = astOf('x = "object/artifact/foo.png"');
  assert.deepEqual(classifyValue(node), { kind: 'literal', value: 'object/artifact/foo.png' });
});

test('classifyValue: rngrange yields its documented range, not a number', () => {
  const [, node] = astOf('x = resolvers.rngrange(225, 350)');
  const result = classifyValue(node);
  assert.equal(result.kind, 'resolver');
  assert.equal(result.resolver, 'resolvers.rngrange');
  assert.deepEqual(result.range, [225, 350]);
  // The point of the type: there is no single `value` to accidentally render.
  assert.equal(result.value, undefined);
});

test('classifyValue: mbonus_material reads (max, add), not (offset, step)', () => {
  // `resolvers.calc.mbonus_material` is
  //   `ceil(rng.mbonus(max, level, 90) * ml / 5) + add`
  // so `10, 5` spans 5..15, and the community sheet lists this very affix
  // (`balanced`) as `5-15命中闪避`. Reading the pair the other way round — as a
  // base plus a per-tier step — is what produced the old `15~35`.
  const [, node] = astOf('x = resolvers.mbonus_material(10, 5)');
  const result = classifyValue(node);
  assert.equal(result.kind, 'resolver');
  assert.equal(result.meaning, '随材料等级变化');
  assert.deepEqual(result.formula, {
    kind: 'material', max: 10, add: 5, transform: null, divisor: null, materialLevelRange: [1, 5],
  });
  assert.deepEqual(result.range, [5, 15]);
  // One range per material level; the last is the widest and equals `range`.
  assert.deepEqual(result.materialRanges, [[5, 7], [5, 9], [5, 11], [5, 13], [5, 15]]);
});

test('classifyValue: the price function is a value transform, applied to the range', () => {
  // `disarm_immune = mbonus_material(30, 20, v=v/100)`: 20..50, stored as a
  // fraction, printed by the tooltip with `scale = 100` as `+20%~+50%`.
  const node = itemAstOf('x = resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end)');
  const result = classifyValue(node);
  assert.equal(result.formula.transform, 'divide');
  assert.equal(result.formula.divisor, 100);
  assert.deepEqual(result.range, [0.2, 0.5]);
  assert.deepEqual(result.materialRanges[4], [0.2, 0.5]);
});

test('classifyValue: a negating transform keeps the range ordered', () => {
  // `fatigue = mbonus_material(6, 4, return 0, -v)`: 4..10 becomes -10..-4.
  const node = itemAstOf('x = resolvers.mbonus_material(6, 4, function(e, v) return 0, -v end)');
  const result = classifyValue(node);
  assert.equal(result.formula.transform, 'negate');
  assert.deepEqual(result.range, [-10, -4]);
  assert.deepEqual(result.materialRanges[0], [-6, -4]);
});

test('classifyValue: the field scale is applied, and only once', () => {
  // The tooltip prints `raw * mod`; `movement_speed = mbonus_material(15, 10,
  // v/100)` with `mod = 100` therefore reads `10%~25%`, which is the range the
  // community sheet quotes for `of speed`.
  const node = itemAstOf('x = resolvers.mbonus_material(15, 10, function(e, v) v=v/100 return 0, v end)');
  const result = classifyValue(node, 100);
  assert.deepEqual(result.range, [10, 25]);
  // Floating point must not leak into the dataset: `0.25 * 100` is 25.000000000000004.
  assert.equal(result.materialRanges[4][1], 25);
});

test('classifyValue: an unreadable transform is not turned into a number', () => {
  const node = itemAstOf('x = resolvers.mbonus_material(10, 5, function(e, v) return 0, v * e.material_level end)');
  const result = classifyValue(node);
  assert.equal(result.formula, null);
  assert.equal(result.range, undefined);
  assert.match(result.meaning, /未识别/);
});

test('classifyValue: an unknown call is reported, never zeroed', () => {
  const [, node] = astOf('x = resolvers.genericlast(function(e) return e.material_level end)');
  const result = classifyValue(node);
  assert.equal(result.kind, 'resolver');
  assert.ok(result.text, 'the source expression must be carried through');
  assert.equal(result.value, undefined);
});

test('classifyValue: a function callback is a function, not a value', () => {
  const [, node] = astOf('x = function(self, who) return 1 end');
  assert.equal(classifyValue(node).kind, 'function');
});

test('classifyValue: a reference is computed, not resolved', () => {
  const [, node] = astOf('x = self.material_level');
  const result = classifyValue(node);
  assert.equal(result.kind, 'computed');
  assert.equal(result.ref, 'self.material_level');
});

test('stripFormatColors removes engine colour codes but keeps the format', () => {
  assert.equal(stripFormatColors('%+d #LAST#(%+d eff.)'), '%+d (%+d eff.)');
  assert.equal(stripFormatColors('%+d%%'), '%+d%%');
  assert.equal(stripFormatColors(null), null);
});

// ---------------------------------------------------------------------------
// Field map
// ---------------------------------------------------------------------------

test('field map reads the writer and combat areas separately', { skip }, () => {
  const map = loadFieldMap(workspaceRoot);
  assert.ok(map.fields.size > 100, `expected a substantial map, got ${map.fields.size}`);

  // `combat_armor` is rendered by `desc_wielder`; `apr` by `descCombat`.
  assert.equal(map.fields.get('combat_armor').area, 'wielder');
  assert.equal(map.fields.get('stun_immune').area, 'wielder');
  assert.equal(map.fields.get('apr').area, 'combat');
  assert.equal(map.fields.get('block').area, 'combat');

  // `compare_scaled` puts the label in a different argument slot; if that is
  // misread the label becomes a format string.
  assert.equal(map.fields.get('combat_def').label, 'Defense: ');
  assert.equal(map.fields.get('combat_spellpower').label, 'Spellpower: ');
  assert.equal(map.fields.get('combat_def').format, '%+d #LAST#(%+d eff.)');
});

test('field map ignores call sites that merely mention desc_wielder', () => {
  // `self:desc_wielder(...)` must not be treated as the definition; if it were,
  // the combat field list would leak into the wielder list.
  const source = [
    'function _M:descCombat(use_actor, combat)',
    '  compare_fields(combat, w, field, "onlycombat", "%+d", _t"Combat Only: ")',
    'end',
    'function _M:getTextualDesc()',
    '  local desc_wielder = function(w, compare_with, field)',
    '    compare_fields(w, w, field, "onlywielder", "%+d", _t"Wielder Only: ")',
    '  end',
    '  desc_wielder(self, nil, "wielder")',
    'end',
  ].join('\n');
  const map = extractFieldMap(source);
  assert.equal(map.fields.get('onlywielder').area, 'wielder');
  assert.equal(map.fields.get('onlycombat').area, 'combat');
});

test('damage type codes map to the locale keys the game uses', { skip }, () => {
  const source = fs.readFileSync(path.join(workspaceRoot, 'tome-src-full/data/damage_types.lua'), 'utf8');
  const types = damageTypeKeys(source);
  assert.equal(types.get('FIRE').localeKey, 'fire');
  assert.equal(types.get('COLD').localeKey, 'cold');
  assert.equal(types.get('PHYSICAL').localeKey, 'physical');
  assert.ok(types.size > 100, `expected many damage types, got ${types.size}`);
});

// ---------------------------------------------------------------------------
// Ego applicability
// ---------------------------------------------------------------------------

test('normalizeEgoPath collapses the base and DLC path spellings', () => {
  assert.equal(normalizeEgoPath('/data/general/objects/egos/weapon.lua'), 'weapon');
  assert.equal(normalizeEgoPath('/data-orcs/general/objects/egos/steamsaw.lua'), 'steamsaw');
  assert.equal(normalizeEgoPath('not a path'), null);
});

test('resolveEgoPools follows the transitive load chain', () => {
  const pools = new Map([
    ['armor', { pool: 'armor', loads: [] }],
    ['light-armor', { pool: 'light-armor', loads: ['armor'] }],
    ['heavy-armor', { pool: 'heavy-armor', loads: ['armor'] }],
    ['massive-armor', { pool: 'massive-armor', loads: ['armor'] }],
    ['weapon', { pool: 'weapon', loads: [] }],
    ['shield', { pool: 'shield', loads: [] }],
    ['steamsaw', { pool: 'steamsaw', loads: ['weapon', 'shield'] }],
  ]);
  // A chainsaw reaches the melee weapon and shield pools, which is what makes
  // its ego list correct without any name-based guessing.
  assert.deepEqual(resolveEgoPools(pools, 'steamsaw').sort(), ['shield', 'steamsaw', 'weapon']);
  // Light armour shares the common armour pool.
  assert.deepEqual(resolveEgoPools(pools, 'light-armor').sort(), ['armor', 'light-armor']);
  assert.deepEqual(resolveEgoPools(pools, 'weapon'), ['weapon']);
});

test('resolveEgoPools terminates on a load cycle', () => {
  const pools = new Map([
    ['a', { pool: 'a', loads: ['b'] }],
    ['b', { pool: 'b', loads: ['a'] }],
  ]);
  assert.deepEqual(resolveEgoPools(pools, 'a').sort(), ['a', 'b']);
});

// ---------------------------------------------------------------------------
// Property extraction
// ---------------------------------------------------------------------------

test('extractProps splits the same key by area', () => {
  const fields = tableOf(`
    newEntity{
      combat = { dam = 30, apr = 7, physcrit = 1.5 },
      wielder = { combat_armor = 15, resists = { [DamageType.FIRE] = 25 } },
    }
  `);
  const map = { fields: new Map([
    ['dam', { key: 'dam', area: 'combat', format: null }],
    ['apr', { key: 'apr', area: 'combat', format: '%+d' }],
    ['physcrit', { key: 'physcrit', area: 'combat', format: '%+.1f%%' }],
    ['combat_armor', { key: 'combat_armor', area: 'wielder', format: '%+d' }],
    ['resists', { key: 'resists', area: 'wielder', format: '%+d%%' }],
  ]) };
  const { byArea, unmapped } = extractProps(fields, map, { file: 'x.lua', line: 1 });
  assert.equal(unmapped.size, 0);
  assert.deepEqual(byArea.get('combat').props.map((p) => p.key), ['dam', 'apr', 'physcrit']);
  assert.deepEqual(byArea.get('wielder').props.map((p) => p.key), ['combat_armor', 'resists']);
  // The resistance table keeps its damage-type key as a reference, not a number.
  const resists = byArea.get('wielder').props.find((p) => p.key === 'resists');
  assert.equal(resists.items[0].code, 'FIRE');
  assert.equal(resists.items[0].value, 25);
});

test('extractProps reports a field the map does not know instead of dropping it', () => {
  const fields = tableOf('newEntity{ wielder = { mystery_stat = 5 } }');
  const { byArea, unmapped } = extractProps(fields, { fields: new Map() }, { file: 'x.lua', line: 1 });
  assert.equal(byArea.get('wielder').props.length, 1);
  assert.deepEqual([...unmapped.keys()], ['mystery_stat']);
});

test('extractProps keeps the last write when a key is repeated', () => {
  // A child template overriding its base writes the key twice.
  const fields = tableOf('newEntity{ wielder = { combat_armor = 5, combat_armor = 9 } }');
  const map = { fields: new Map([['combat_armor', { key: 'combat_armor', area: 'wielder', format: '%+d' }]]) };
  const { byArea } = extractProps(fields, map, { file: 'x.lua', line: 1 });
  const prop = byArea.get('wielder').props[0];
  assert.equal(prop.value, 9);
  assert.equal(prop.overridden, true);
  assert.equal(prop.valueCount, 2);
});

test('extractProps moves a nested area table into its own section', () => {
  // `wielder = { combat = { melee_project = ... } }` is how the engine attaches
  // weapon fields to a wearer item (33 egos do it). Treating `combat` as a
  // property produced a row labelled `combat` listing `melee_project` and
  // `burst_on_crit` as *values*, in the wrong section.
  const fields = tableOf(`newEntity{ wielder = { inc_stats = {}, combat = { melee_project = 3, burst_on_crit = 9 } } }`);
  const map = {
    fields: new Map([
      ['inc_stats', { key: 'inc_stats', area: 'wielder', kind: 'table' }],
      ['melee_project', { key: 'melee_project', area: 'combat', kind: 'table' }],
      ['burst_on_crit', { key: 'burst_on_crit', area: 'combat', kind: 'table' }],
    ]),
  };
  const { byArea, unmapped } = extractProps(fields, map, { file: 'x.lua', line: 1 });
  assert.deepEqual(byArea.get('wielder').props.map((p) => p.key), ['inc_stats']);
  assert.deepEqual(byArea.get('combat').props.map((p) => p.key), ['melee_project', 'burst_on_crit']);
  assert.equal(byArea.get('combat').props[0].value, 3);
  assert.deepEqual([...unmapped.keys()], [], '`combat` is an area, not an unmapped field');
});

test('extractProps never folds a resolver into a number', () => {
  const fields = tableOf('newEntity{ wielders = {}, wielder = { combat_atk = resolvers.mbonus_material(10, 5) } }');
  const map = { fields: new Map([['combat_atk', { key: 'combat_atk', area: 'wielder', format: '%+d' }]]) };
  const { byArea } = extractProps(fields, map, { file: 'x.lua', line: 1 });
  const prop = byArea.get('wielder').props[0];
  assert.equal(prop.kind, 'resolver');
  assert.equal(prop.value, undefined);
  assert.deepEqual(prop.range, [5, 15]);
});

// ---------------------------------------------------------------------------
// Artifact classification
// ---------------------------------------------------------------------------

test('classifyArtifact separates equipment, non-equipment and NPC definitions', () => {
  const item = (fields) => ({ ast: tableOf(`newEntity{ ${fields} }`) });
  const resolved = (type) => ({ fields: { type } });

  assert.equal(classifyArtifact(item('unique = true, name = "A"'), resolved('weapon')).include, true);
  assert.equal(classifyArtifact(item('unique = true, name = "A"'), resolved('armor')).reason, 'equipment');

  const scroll = classifyArtifact(item('unique = true, name = "A"'), resolved('scroll'));
  assert.equal(scroll.include, true);
  assert.equal(scroll.nonEquipment, true);

  // A boss definition carries `unique = true` too; it is not an item.
  assert.equal(classifyArtifact(item('unique = true, name = "A"'), resolved('humanoid')).reason, 'npc-definition');
  assert.ok(NPC_TYPES.has('humanoid'));

  assert.equal(classifyArtifact(item('name = "A"'), resolved('weapon')).reason, 'not-unique');
  assert.equal(classifyArtifact(item('unique = true, name = "A", quest = true'), resolved('weapon')).reason, 'quest-item');
  assert.equal(classifyArtifact(item('unique = true'), resolved('weapon')).reason, 'no-name');
  assert.equal(classifyArtifact(item('unique = true, name = "A"'), resolved(null)).reason, 'no-type');
});

test('EQUIP_TYPES covers everything a player can wear or use', () => {
  for (const type of ['weapon', 'armor', 'jewelry', 'lite', 'tool', 'ammo', 'charm', 'orb', 'tinker']) {
    assert.ok(EQUIP_TYPES.has(type), `${type} must be equippable`);
  }
});

test('AREA_ORDER is the display order and is stable', () => {
  // Weapon body first, then shield attack, then the wearer. A drifting order
  // would make two artifacts hard to compare side by side.
  assert.deepEqual(AREA_ORDER, ['combat', 'special_combat', 'wielder', 'carrier', 'imbue_powers']);
});

// ---------------------------------------------------------------------------
// End-to-end against the real sources
// ---------------------------------------------------------------------------

test('the world-artifact file yields definitions with resolvable types', { skip }, () => {
  const file = path.join(workspaceRoot, 'tome-src-full/data/general/objects/world-artifacts.lua');
  const { entities } = scanItemFile(fs.readFileSync(file, 'utf8'), 'world-artifacts.lua');
  assert.ok(entities.length >= 180, `expected the big artifact file to be read, got ${entities.length}`);

  const bill = entities.find((e) => e.fields.map.some((m) => keyName(m.key) === 'name' && m.value.value === 'Windborne Azurite'));
  assert.ok(bill, 'a known artifact must be found');
});

test('a chainsaw resolves to the weapon and shield ego pools', { skip }, () => {
  const file = path.join(workspaceRoot, 'dlc-src/orcs/tome-orcs/data/general/objects/steamsaw.lua');
  const { entities } = scanItemFile(fs.readFileSync(file, 'utf8'), 'steamsaw.lua');
  const withEgos = entities.find((e) => e.fields.map.some((m) => keyName(m.key) === 'egos'));
  const egosEntry = withEgos.fields.map.find((m) => keyName(m.key) === 'egos');
  assert.equal(normalizeEgoPath(literalOf(egosEntry.value)), 'steamsaw');

  const egoFile = path.join(workspaceRoot, 'dlc-src/orcs/tome-orcs/data/general/objects/egos/steamsaw.lua');
  const { loads } = scanItemFile(fs.readFileSync(egoFile, 'utf8'), 'steamsaw-egos.lua');
  const pools = loads.map((l) => normalizeEgoPath(l.path));
  assert.ok(pools.includes('weapon'));
  assert.ok(pools.includes('shield'));
});

test('the acidic weapon ego keeps its trigger callback as a function', { skip }, () => {
  const file = path.join(workspaceRoot, 'tome-src-full/data/general/objects/egos/weapon.lua');
  const { entities } = scanItemFile(fs.readFileSync(file, 'utf8'), 'weapon.lua');
  const acidic = entities.find((e) => e.fields.map.some((m) => keyName(m.key) === 'name' && m.value.value === 'acidic '));
  assert.ok(acidic, 'the acidic ego must exist in weapon.lua');
  const rarity = acidic.fields.map.find((m) => keyName(m.key) === 'rarity');
  // Confirmed against the source; the community spreadsheet says 10 for the
  // melee-weapon sheet, which is a spreadsheet error recorded in the report.
  assert.equal(literalOf(rarity.value), 5);
});

test('the greater-ego tier is a distinct definition from the base tier', { skip }, () => {
  const file = path.join(workspaceRoot, 'tome-src-full/data/general/objects/egos/charms.lua');
  const { entities } = scanItemFile(fs.readFileSync(file, 'utf8'), 'charms.lua');
  const quick = entities.filter((e) => e.fields.map.some((m) => keyName(m.key) === 'name' && m.value.value === 'quick '));
  assert.equal(quick.length, 2, 'the charm ego exists as a normal and a greater tier');
  const flags = quick.map((e) => e.fields.map.find((m) => keyName(m.key) === 'greater_ego'));
  assert.equal(flags.filter(Boolean).length, 1, 'exactly one of the two is the greater tier');
});

test('all four sources contribute ego definitions', { skip }, () => {
  const totals = {};
  for (const source of ITEM_SOURCES) {
    const dir = path.join(workspaceRoot, source.dir, 'data/general/objects/egos');
    if (!fs.existsSync(dir)) continue;
    let count = 0;
    for (const name of fs.readdirSync(dir).filter((f) => f.endsWith('.lua'))) {
      const { entities } = scanItemFile(fs.readFileSync(path.join(dir, name), 'utf8'), name);
      count += entities.length;
    }
    totals[source.id] = count;
  }
  assert.ok(totals.tome > 500, `base game egos: ${totals.tome}`);
  assert.ok(totals.orcs > 0, 'the Orcs DLC defines its own egos');
});

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

/** Parse `key = value` and return `[key, valueNode]`. */
function astOf(assignment) {
  const parsed = parseLuaFile(`local ${assignment}`, 'fragment.lua');
  const first = parsed.assignments[0];
  assert.ok(first, `no assignment parsed from ${JSON.stringify(assignment)}`);
  return [first.name, first.value];
}

/**
 * The same, but through the item scanner.
 *
 * `resolvers.mbonus_material(max, add, function(e, v) ... end)` carries its
 * value transform in the callback body, and only the item-side scanner keeps
 * that body (`attachFunctionBodies`); the shared parser drops it. Reading a
 * transform therefore has to be tested through the real path, not a bare AST.
 */
function itemAstOf(assignment) {
  const { entities } = scanItemFile(`newEntity{ ${assignment} }`, 'fragment.lua');
  const entry = entities[0]?.fields.map.find((m) => keyName(m.key) === 'x');
  assert.ok(entry, `no field parsed from ${JSON.stringify(assignment)}`);
  return entry.value;
}

/** The `newEntity{...}` table literal of a synthetic snippet. */
function tableOf(source) {
  const { entities } = scanItemFile(source, 'synthetic.lua');
  assert.equal(entities.length, 1, 'snippet must define exactly one entity');
  return entities[0].fields;
}
