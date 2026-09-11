/**
 * Frontend monster filter/search tests.
 *
 * `src/lib/monsters.ts` is a browser module: it imports `assetUrl` from
 * `./data`, which reads `import.meta.env`. To keep the search rules under test
 * without pulling in Vite, this test strips the two import lines and evaluates
 * the rest as a plain ES module.
 *
 * The cases are regressions: random-group talents must be searchable, and the
 * `-exclude` / `"phrase"` syntax must behave like the talent search.
 *
 * Run: node --test scripts/monsters/monster-search.test.mjs
 */

import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const esbuild = require('esbuild');

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..', '..');

// Transpile the browser module to plain ESM without its two imports, so the
// pure search logic can run under node:test without Vite's `import.meta.env`.
const source = fs.readFileSync(path.join(projectRoot, 'src/lib/monsters.ts'), 'utf8');
const withoutImports = source
  .split('\n')
  .filter((line) => !line.startsWith('import '))
  .join('\n');
const { code } = esbuild.transformSync(withoutImports, { loader: 'ts', format: 'esm', target: 'node20' });

const modulePath = path.join(projectRoot, 'node_modules/.cache/monsters-under-test.mjs');
fs.mkdirSync(path.dirname(modulePath), { recursive: true });
fs.writeFileSync(modulePath, code);
const { buildMonsterData, filterMonsters, emptyMonsterFilters, describeTalentRule, monsterTypeTree, monsterTypeLabels, subtypeKey } =
  await import(pathToFileURL(modulePath).href);

const monster = (overrides) => ({
  id: 'M1',
  defineAs: null,
  variantOf: null,
  name: 'test monster',
  nameZh: '测试怪',
  nameStatus: 'exact',
  type: 'humanoid',
  typeZh: '人形生物',
  subtype: 'orc',
  subtypeZh: '兽人',
  rank: 2,
  rankKey: 'normal',
  category: 'normal',
  categoryLabel: '普通怪物',
  unique: false,
  randboss: false,
  noDifficultyRandomClass: false,
  rarity: 1,
  levelRange: null,
  lifeRating: null,
  sizeCategory: null,
  expWorth: null,
  canMultiply: null,
  faction: null,
  autoClasses: null,
  desc: null,
  descZh: null,
  descStatus: 'none',
  image: null,
  imageKind: 'missing',
  imageMatch: null,
  imageCandidate: null,
  layers: null,
  tall: null,
  wide: null,
  talents: [],
  rngPools: [],
  rngSets: [],
  inheritance: null,
  source: 'tome',
  file: 'test.lua',
  line: 1,
  zone: null,
  unresolved: null,
  ...overrides,
});

const dataset = {
  version: 1,
  gameVersion: '1.7.6',
  builtAt: '2026-01-01T00:00:00.000Z',
  sources: [],
  categoryLabels: {},
  categories: [],
  census: {},
  monsters: [
    monster({
      id: 'NECRO',
      name: 'orc necromancer',
      nameZh: '兽人死灵法师',
      talents: [{ id: 'T_HIEMAL_SHIELD', level: 2, growth: null }],
      rngSets: [[{ id: 'T_CALL_OF_THE_CRYPT', level: null, growth: { base: 5, every: 5, max: 9, last: null } }]],
    }),
    monster({
      id: 'WORM',
      name: 'white worm mass',
      nameZh: '白色蠕虫团',
      type: 'vermin',
      typeZh: '害虫',
      subtype: 'worms',
      subtypeZh: '蠕虫',
      rank: 1,
      category: 'normal',
      canMultiply: 4,
      talents: [{ id: 'T_MULTIPLY', level: 1, growth: null }],
    }),
    monster({
      id: 'BOSS',
      name: 'the boss',
      nameZh: '首领',
      type: 'demon',
      typeZh: '恶魔',
      subtype: 'major',
      subtypeZh: '大恶魔',
      rank: 4,
      category: 'boss',
      categoryLabel: '固定Boss',
      source: 'orcs',
      rngPools: [{ count: 3, talents: [{ id: 'T_FIRE_BREATH', level: 5, growth: null }] }],
    }),
    // The three spellings the sources use for the same creature; the tree and
    // the filter must fold them into a single row.
    monster({ id: 'SHERTUL1', name: "sher'tul one", nameZh: '夏·图尔一号', subtype: "sher'tul", subtypeZh: '夏·图尔' }),
    monster({ id: 'SHERTUL2', name: 'shertul two', nameZh: '夏·图尔二号', subtype: 'shertul', subtypeZh: '夏·图尔' }),
  ],
};

const data = buildMonsterData(dataset);
const ids = (filters) => filterMonsters(data, { ...emptyMonsterFilters, ...filters }).map((entry) => entry.id);

test('search matches a fixed talent id', () => {
  assert.deepEqual(ids({ query: 'T_HIEMAL_SHIELD' }), ['NECRO']);
});

test('search matches a talent from an exclusive random group', () => {
  assert.deepEqual(ids({ query: 'T_CALL_OF_THE_CRYPT' }), ['NECRO'], 'random-group talents must be searchable');
});

test('search matches a talent from a random pool', () => {
  assert.deepEqual(ids({ query: 'T_FIRE_BREATH' }), ['BOSS']);
});

test('search matches Chinese and English names', () => {
  assert.deepEqual(ids({ query: '蠕虫' }), ['WORM']);
  assert.deepEqual(ids({ query: 'worm mass' }), ['WORM']);
});

test('search matches type and subtype', () => {
  // All terms must be present, but not necessarily adjacent: the haystack is a
  // bag of fields, so `orc` also matches the necromancer's `type/subtype`.
  assert.ok(ids({ query: 'humanoid orc' }).includes('NECRO'));
  assert.deepEqual(ids({ query: 'undead vampire' }), []);
});

test('quoted phrases and -exclusion work', () => {
  assert.deepEqual(ids({ query: '"white worm"' }), ['WORM']);
  assert.deepEqual(ids({ query: 'mass -white' }), [], 'the only mass is the white one');
});

test('category and source filters narrow the list', () => {
  assert.deepEqual(ids({ category: 'boss' }), ['BOSS']);
  assert.deepEqual(ids({ source: 'orcs' }), ['BOSS']);
});

test('type and subtype filters narrow the list', () => {
  assert.deepEqual(ids({ type: 'vermin' }), ['WORM']);
  assert.deepEqual(ids({ type: 'humanoid', subtype: 'orc' }), ['NECRO']);
  assert.deepEqual(ids({ type: 'demon', category: 'boss' }), ['BOSS']);
  // A subtype from another type must not leak in.
  assert.deepEqual(ids({ type: 'demon', subtype: 'orc' }), []);
});

test('subtype spellings are folded into one filter value', () => {
  assert.equal(subtypeKey("sher'tul"), 'shertul');
  assert.equal(subtypeKey('Sher\'Tul'), 'shertul');
  // Both spellings answer to the same filter value.
  assert.deepEqual(ids({ type: 'humanoid', subtype: 'shertul' }).sort(), ['SHERTUL1', 'SHERTUL2']);
});

test('search matches the Chinese type and subtype labels', () => {
  assert.deepEqual(ids({ query: '害虫' }), ['WORM']);
  assert.deepEqual(ids({ query: '大恶魔' }), ['BOSS']);
});

test('the type tree groups subtypes under their type', () => {
  const tree = monsterTypeTree(data.dataset.monsters);
  const labels = tree.map((entry) => entry.label);
  assert.ok(labels.includes('人形生物'));
  // 3 humanoids, 2 demons/vermin... the biggest type comes first.
  assert.equal(tree[0].label, '人形生物');
  assert.equal(tree[0].count, 3);
  const humanoid = tree.find((entry) => entry.type === 'humanoid');
  // orc + the two Sher'Tul spellings, folded into a single row; biggest first.
  assert.deepEqual(
    humanoid.subtypes.map((sub) => [sub.subtype, sub.label, sub.count]),
    [
      ['shertul', '夏·图尔', 2],
      ['orc', '兽人', 1],
    ],
  );
  const vermin = tree.find((entry) => entry.type === 'vermin');
  assert.deepEqual(vermin.subtypes, [{ subtype: 'worms', label: '蠕虫', count: 1 }]);
});

test('type labels fall back to English when the locale has no entry', () => {
  assert.deepEqual(monsterTypeLabels({ type: 'horror', typeZh: '恐魔', subtype: 'eldritch', subtypeZh: '艾尔德里奇' }), {
    type: '恐魔',
    typeEn: 'horror',
    subtype: '艾尔德里奇',
    subtypeEn: 'eldritch',
  });
  assert.equal(monsterTypeLabels({ type: 'horror', typeZh: null, subtype: null, subtypeZh: null }).type, 'horror');
  assert.equal(monsterTypeLabels({ type: null, typeZh: null, subtype: null, subtypeZh: null }).type, '未知');
});

test('onlyRandomGroups keeps just the random-group monsters', () => {
  assert.deepEqual(ids({ onlyRandomGroups: true }).sort(), ['BOSS', 'NECRO']);
});

test('a query that matches nothing returns an empty list', () => {
  assert.deepEqual(ids({ query: 'zzz-not-a-monster' }), []);
});

test('talent level rules render as Chinese explanations', () => {
  assert.equal(describeTalentRule({ id: 'A', level: 5, growth: null }), '固定 5 级');
  assert.match(
    describeTalentRule({ id: 'B', level: null, growth: { base: 0, every: 7, max: 7, last: 25 } }),
    /初始 0 级.*每 7 级 \+1.*上限 7 级.*25 级后不再提升/,
  );
});

test('the random-talent index is built for both pools and sets', () => {
  assert.equal(data.byRandomTalent.get('T_CALL_OF_THE_CRYPT')?.[0]?.id, 'NECRO');
  assert.equal(data.byRandomTalent.get('T_FIRE_BREATH')?.[0]?.id, 'BOSS');
  assert.equal(data.byFixedTalent.get('T_MULTIPLY')?.[0]?.id, 'WORM');
  assert.ok(!data.byFixedTalent.has('T_CALL_OF_THE_CRYPT'), 'group talents must not claim to be fixed');
});
