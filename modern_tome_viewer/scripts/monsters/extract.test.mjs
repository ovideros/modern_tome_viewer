/**
 * Monster extraction tests.
 *
 * These assert against the real 1.7.6 sources rather than a fixture, because
 * the failures worth catching are all "the pipeline read the game wrong":
 * inheritance that did not merge, a resolver structure that was flattened, a
 * talent level rule that was misread, or an image that resolves to a
 * transparent container.
 *
 * Run: node --test scripts/monsters/*.test.mjs
 */

import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { collectTemplates, resolveEntity, resolveTalents, classifyRank, autoImageName, resolveImage } from './extract.mjs';
import { buildImageIndex, buildArtLookup, lookupArt } from './images.mjs';
import { extractTalentSupplement } from './talent-supplement.mjs';
import { loadLocales, readLocaleSnapshot } from './locale-snapshot.mjs';
import { translate } from './locale.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..', '..');
const workspaceRoot = path.dirname(projectRoot);
const outDir = path.join(projectRoot, 'public');

const hasSources = fs.existsSync(path.join(workspaceRoot, 'tome-src-full/data/general/npcs'));
/**
 * Full checkout signals. The base game's Lua lives in this repository, but the
 * DLC sources, the gfx archive and the locale tables do not, so a fresh clone
 * has the templates and the built dataset while a development machine also has
 * the art and the translations. Tests that need the latter two say so.
 */
const hasDlcSources = fs.existsSync(path.join(workspaceRoot, 'dlc-src/orcs/tome-orcs/data/talents'));
const hasGfxArchive = fs.existsSync(path.join(workspaceRoot, 't-engine4-src-1.7.6/game/modules/tome-1.7.6-gfx.team'));
const hasLocaleTables = fs.existsSync(path.join(workspaceRoot, 'tome-src-full/data/locales/zh_hans.lua'));
const hasBuild = fs.existsSync(path.join(outDir, 'data/monsters.json'));

let cache = null;
function sources() {
  if (!cache) {
    const collected = collectTemplates(workspaceRoot);
    const byName = new Map();
    for (const record of collected.records) {
      const resolved = resolveEntity(record, collected.byDefineAs);
      const key = `${resolved.fields.name ?? ''}#${record.id}`;
      byName.set(key, { record, resolved, talents: resolveTalents(resolved.talentSources) });
    }
    const named = new Map();
    for (const entry of byName.values()) {
      const name = entry.resolved.fields.name;
      if (!name) continue;
      if (!named.has(name)) named.set(name, []);
      named.get(name).push(entry);
    }
    cache = { ...collected, all: byName, named };
  }
  return cache;
}

/**
 * Skip reason for tests that read the game's Lua sources.
 *
 * The repository deliberately does not track the vendored source trees, so a
 * clean clone can only run the tests that work off the committed
 * `public/data` and `data/raw/locales` snapshot. Those are the ones that guard
 * the deployed site; the rest need `--with-sources` locally.
 */
const skip = !hasSources ? 'game Lua sources not tracked in this checkout' : false;
const one = (name) => {
  const list = sources().named.get(name);
  assert.ok(list?.length, `expected a template named "${name}"`);
  return list[0];
};

// ---------------------------------------------------------------------------
// Rank classification
// ---------------------------------------------------------------------------

test('rank buckets follow Actor:textRank', () => {
  assert.equal(classifyRank(1), 'normal'); // critter
  assert.equal(classifyRank(2), 'normal');
  assert.equal(classifyRank(3), 'elite');
  assert.equal(classifyRank(3.2), 'elite'); // rare
  assert.equal(classifyRank(3.5), 'unique');
  assert.equal(classifyRank(4), 'boss');
  assert.equal(classifyRank(5), 'elite_boss');
  assert.equal(classifyRank(10), 'god');
  assert.equal(classifyRank(null), 'normal');
});

// ---------------------------------------------------------------------------
// Inheritance
// ---------------------------------------------------------------------------

test('skill: base inheritance merges parent fields', { skip }, () => {
  const worm = one('white worm mass');
  assert.equal(worm.resolved.fields.type, 'vermin', 'type must come from BASE_NPC_WORM');
  assert.equal(worm.resolved.fields.subtype, 'worms');
  assert.deepEqual(worm.resolved.chain, ['BASE_NPC_WORM']);
  assert.equal(worm.resolved.fields.can_multiply, 4, 'can_multiply=4 is declared on the base');
});

test('swarm: multiply count is inherited 4 but overridden to 2 for carrion', { skip }, () => {
  assert.equal(one('white worm mass').resolved.fields.can_multiply, 4);
  assert.equal(one('green worm mass').resolved.fields.can_multiply, 4);
  assert.equal(one('carrion worm mass').resolved.fields.can_multiply, 2, 'carrion worm mass overrides can_multiply');
});

test('swarm: on_die is a script, not a talent', { skip }, () => {
  const carrion = one('carrion worm mass');
  // The枯萎 area effect is delivered by an `on_die` function; it must not be
  // reported as a talent.
  assert.ok(carrion.record.rawFields.on_die, 'on_die should be recorded as a script');
  assert.ok(
    !carrion.talents.fixed.some((talent) => /DIE|DEATH/i.test(talent.id)),
    'death effects must not be invented as talents',
  );
});

test('skill: base=0 growth keeps its starting point', { skip }, () => {
  const necromancer = one('orc necromancer');
  const desolate = necromancer.talents.fixed.find((talent) => talent.id === 'T_DESOLATE_WASTE');
  assert.ok(desolate, 'T_DESOLATE_WASTE is in the fixed list');
  assert.equal(desolate.growth.base, 0, 'base=0 means it may not be owned yet');
  assert.equal(desolate.growth.every, 7);
  assert.equal(desolate.growth.max, 7);
  assert.equal(desolate.growth.last, 25);
});

// ---------------------------------------------------------------------------
// Random talent groups
// ---------------------------------------------------------------------------

test('orc necromancer: fixed talents plus four exclusive groups, not four sets at once', { skip }, () => {
  const necromancer = one('orc necromancer');
  const fixedIds = necromancer.talents.fixed.map((talent) => talent.id);
  assert.ok(fixedIds.includes('T_HIEMAL_SHIELD'));
  assert.ok(fixedIds.includes('T_STAFF_MASTERY'));
  assert.equal(necromancer.talents.rngSets.length, 4, 'the source declares four themes');

  // The four themes must stay grouped and mutually exclusive.
  for (const set of necromancer.talents.rngSets) assert.ok(set.length >= 4, 'every group has several talents');
  const setIds = necromancer.talents.rngSets.map((set) => set.map((talent) => talent.id).sort().join(','));
  assert.equal(new Set(setIds).size, 4, 'the groups are distinct');

  // A group talent must not leak into the fixed list, which would claim the
  // monster always has it.
  const groupOnly = necromancer.talents.rngSets[0][0].id;
  assert.ok(!fixedIds.includes(groupOnly), `${groupOnly} is a group member, not a fixed talent`);
});

// ---------------------------------------------------------------------------
// Talent level rules
// ---------------------------------------------------------------------------

test('phoenix: T_HEAT is referenced and the supplement defines it', { skip }, () => {
  const phoenix = one('Phoenix');
  const heat = phoenix.talents.fixed.find((talent) => talent.id === 'T_HEAT');
  assert.ok(heat, 'the Phoenix fixed list references T_HEAT');
  assert.equal(heat.level, 5);

  // The definition itself lives in the base game sources, which a clone has.
  const supplement = extractTalentSupplement(workspaceRoot, ['T_HEAT']);
  const entry = supplement.talents.find((talent) => talent.id === 'T_HEAT');
  assert.ok(entry, 'T_HEAT must be extractable from data/talents/spells/war-alchemy.lua');
  assert.equal(entry.enName, 'Heat');

  // The Chinese text needs the locale tables, which are not tracked.
  if (hasLocaleTables) {
    assert.equal(entry.name, '加热', 'Chinese name comes from the game locale');
    assert.match(entry.info ?? '', /火焰/, 'Chinese description comes from the game locale');
  }
});

test('supplement: pool and tutorial talents are found', { skip }, () => {
  const ids = ['T_STAMINA_POOL', 'T_MANA_POOL', 'T_TUTORIAL_SPELL_KB', 'T_TUTORIAL_MIND_KB'];
  const supplement = extractTalentSupplement(workspaceRoot, ids);
  const found = new Map(supplement.talents.map((talent) => [talent.id, talent]));
  for (const id of ids) assert.ok(found.has(id), `${id} should be extractable from the base game sources`);
  assert.equal(found.get('T_STAMINA_POOL').enName, 'Stamina Pool');
  assert.ok(found.get('T_TUTORIAL_SPELL_KB').info, 'tutorial talents carry their source text');

  // T_STEAM_POOL is defined by a DLC, so it only resolves in a full checkout.
  if (hasDlcSources) {
    const withDlc = extractTalentSupplement(workspaceRoot, ['T_STEAM_POOL']);
    assert.ok(withDlc.talents.some((talent) => talent.id === 'T_STEAM_POOL'), 'T_STEAM_POOL comes from the orcs DLC');
  }
  if (hasLocaleTables) {
    assert.equal(found.get('T_STAMINA_POOL').name, '体力值槽');
  }
});

// ---------------------------------------------------------------------------
// Descriptions and localisation
// ---------------------------------------------------------------------------

test('translation-wrapped descriptions are read and translated', { skip }, () => {
  const necromancer = one('orc necromancer');
  // `desc = _t[[...]]` hides the literal one call deep; missing that left every
  // monster description empty in the first build.
  const desc = necromancer.resolved.fields.desc ?? '';
  assert.match(desc, /orc dressed in black robes/);

  if (!hasLocaleTables) {
    // Without the game locale tables the description must still survive as
    // English, and the committed snapshot must still translate it — that is
    // what the deployed site relies on.
    const snapshot = readLocaleSnapshot(path.join(projectRoot, 'data/raw/locales/zh_hans.json'));
    assert.ok(snapshot, 'the committed locale snapshot is the fallback');
    assert.match(translate(snapshot.map, desc).text, /黑色长袍/);
    return;
  }
  const { map } = loadLocales(workspaceRoot);
  const zh = translate(map, desc);
  assert.equal(zh.status, 'exact');
  assert.match(zh.text, /黑色长袍/);
});

test('the committed locale snapshot carries the monster text the site shows', { skip: !hasBuild }, () => {
  const snapshotPath = path.join(projectRoot, 'data/raw/locales/zh_hans.json');
  assert.ok(fs.existsSync(snapshotPath), 'the locale snapshot is a committed build input');
  const snapshot = readLocaleSnapshot(snapshotPath);
  assert.ok(snapshot.map.size > 20000, `snapshot has ${snapshot.map.size} entries`);

  // Every monster name the site displays must resolve from the snapshot alone,
  // which is what makes a clone without the game locale tables still show
  // Chinese.
  const dataset = JSON.parse(fs.readFileSync(path.join(outDir, 'data/monsters.json'), 'utf8'));
  const missing = [];
  for (const monster of dataset.monsters) {
    if (monster.nameStatus !== 'exact') continue;
    const hit = translate(snapshot.map, monster.name);
    if (hit.status === 'missing') missing.push(monster.name);
  }
  assert.deepEqual(missing.slice(0, 5), [], `${missing.length} monster names are missing from the snapshot`);

  // Spot-check a description, which is longer text and was the reason the
  // snapshot is not pruned more aggressively.
  const phoenix = dataset.monsters.find((monster) => monster.name === 'Phoenix');
  assert.ok(phoenix?.descZh, 'the Phoenix description must be translatable from the snapshot');
  assert.match(phoenix.descZh, /凤凰|燃烧/);
});

test('dataset: most monsters carry a description', { skip: !hasBuild }, () => {
  const dataset = JSON.parse(fs.readFileSync(path.join(outDir, 'data/monsters.json'), 'utf8'));
  const withDesc = dataset.monsters.filter((monster) => monster.desc).length;
  assert.ok(withDesc > 700, `expected most templates to have a description, got ${withDesc}`);
  const withZh = dataset.monsters.filter((monster) => monster.descZh).length;
  assert.ok(withZh > withDesc * 0.95, `${withZh} of ${withDesc} descriptions translated`);
});

// ---------------------------------------------------------------------------
// Images
// ---------------------------------------------------------------------------

test('image: auto naming follows NPC:init', () => {
  assert.equal(
    autoImageName({ type: 'vermin', subtype: 'worms', name: 'white worm mass' }),
    'npc/vermin_worms_white_worm_mass.png',
  );
  assert.equal(autoImageName({ type: 'animal', subtype: 'bird', name: 'Phoenix' }), 'npc/animal_bird_phoenix.png');
  // Punctuation and apostrophes become underscores, exactly like the engine.
  assert.equal(
    autoImageName({ type: 'humanoid', subtype: 'orc', name: "Khulmanar, General of Urh'Rok" }),
    'npc/humanoid_orc_khulmanar__general_of_urh_rok.png',
  );
});

const skipArt = hasGfxArchive ? false : 'gfx archive not present (not tracked in this repository)';

test('image: the documented monsters resolve to real non-transparent art', { skip: skipArt }, () => {
  const { index } = buildImageIndex(workspaceRoot, {
    dlcSources: [
      { id: 'orcs', dir: 'dlc-src/orcs/tome-orcs' },
      { id: 'ashes', dir: 'dlc-src/ashes-urhrok/tome-ashes-urhrok' },
      { id: 'cults', dir: 'dlc-src/cults/tome-cults' },
    ],
  });
  const lookup = buildArtLookup(index);
  const expectations = [
    ['white worm mass', 'npc/vermin_worms_white_worm_mass.png'],
    ['Phoenix', 'npc/animal_bird_phoenix.png'],
    ['orc necromancer', 'npc/humanoid_orc_orc_necromancer.png'],
  ];
  for (const [name, expected] of expectations) {
    const { resolved } = one(name);
    assert.ok(index.has(expected), `${expected} must exist in the Shockbolt archive`);
    const image = resolveImage(resolved.fields, index, lookup);
    assert.equal(image.image, expected, `${name} resolves to ${expected}`);
    assert.ok(!/invis\.png$/.test(image.image), 'invis.png is only a layer container, never the picture');
  }
});

test('image: a layered tile never reports the invis container as its art', { skip: skipArt }, () => {
  const { index } = buildImageIndex(workspaceRoot, { dlcSources: [] });
  const lookup = buildArtLookup(index);
  const fields = {
    type: 'horror',
    subtype: 'eldritch',
    name: 'The One That Hunts',
    image: 'invis.png',
    add_mos: { __array: [{ image: 'npc/horror_eldritch_the_one_that_hunts.png', display_h: 2, display_y: -1 }] },
  };
  const image = resolveImage(fields, index, lookup);
  assert.notEqual(image.image, 'invis.png');
  assert.equal(image.image, 'npc/horror_eldritch_the_one_that_hunts.png');
  assert.equal(image.kind, 'layered');
  assert.equal(image.layerMeta.length, 1);
});

test('image: fuzzy lookup resolves dotted names without guessing', { skip: skipArt }, () => {
  const { index } = buildImageIndex(workspaceRoot, { dlcSources: [] });
  const lookup = buildArtLookup(index);
  const match = lookupArt(lookup, { subtype: 'bear', name: 'grizzly bear' }, 'npc/animal_bear_grizzly_bear.png');
  assert.ok(match, 'grizzly bear should match its real art file');
  assert.equal(match.key, 'npc/grizzly_bear.png', 'the longer trailing name must win over the bare word "bear"');
});

// ---------------------------------------------------------------------------
// Built dataset invariants
// ---------------------------------------------------------------------------

test('dataset: census is internally consistent', { skip: !hasBuild }, () => {
  const dataset = JSON.parse(fs.readFileSync(path.join(outDir, 'data/monsters.json'), 'utf8'));
  const { census, monsters } = dataset;
  assert.equal(census.concrete, monsters.length);
  assert.equal(
    Object.values(census.byCategory).reduce((a, b) => a + b, 0),
    monsters.length,
    'every monster falls into exactly one category bucket',
  );
  assert.equal(
    Object.values(census.bySource).reduce((a, b) => a + b, 0),
    monsters.length,
    'every monster belongs to exactly one source package',
  );
  assert.ok(census.abstract > 0, 'abstract BASE templates are counted but excluded');
  assert.equal(monsters.filter((monster) => monster.nameStatus === 'exact').length, census.withChineseName);
  assert.equal(monsters.filter((monster) => monster.image).length, census.withImage);
});

test('dataset: ids are globally unique even for re-declared define_as', { skip: !hasBuild }, () => {
  const dataset = JSON.parse(fs.readFileSync(path.join(outDir, 'data/monsters.json'), 'utf8'));
  const ids = dataset.monsters.map((monster) => monster.id);
  assert.equal(new Set(ids).size, ids.length, 'ids must be unique because they are React list keys');
  for (const id of ids) assert.ok(id.length > 0, `empty id: ${id}`);
  // The game re-declares some define_as in several zones; those must stay
  // separate rows with a disambiguated id, not overwrite each other.
  const gladiators = dataset.monsters.filter((monster) => monster.defineAs === 'GLADIATOR');
  assert.equal(gladiators.length, 2, 'both gladiator templates are kept');
  assert.equal(new Set(gladiators.map((monster) => monster.id)).size, 2);
  assert.ok(gladiators.some((monster) => monster.variantOf === 'GLADIATOR'));
});

test('dataset: no parent template is left unresolved', { skip: !hasBuild }, () => {
  const dataset = JSON.parse(fs.readFileSync(path.join(outDir, 'data/monsters.json'), 'utf8'));
  const broken = dataset.monsters.filter((monster) => monster.unresolved?.length);
  assert.deepEqual(
    broken.map((monster) => `${monster.id}: ${monster.unresolved.map((u) => u.reason).join(',')}`),
    [],
    'every base= reference must resolve',
  );
});

test('dataset: every talent reference is covered by the talent library', { skip: !hasBuild }, () => {
  const dataset = JSON.parse(fs.readFileSync(path.join(outDir, 'data/monsters.json'), 'utf8'));
  const talents = JSON.parse(fs.readFileSync(path.join(outDir, 'data/talents.json'), 'utf8'));
  const known = new Set();
  for (const tree of talents.trees) for (const talent of tree.talents) known.add(talent.id);

  const missing = new Set();
  for (const monster of dataset.monsters) {
    for (const talent of monster.talents) if (!known.has(talent.id)) missing.add(talent.id);
    for (const pool of monster.rngPools) for (const talent of pool.talents) if (!known.has(talent.id)) missing.add(talent.id);
    for (const set of monster.rngSets) for (const talent of set) if (!known.has(talent.id)) missing.add(talent.id);
  }
  assert.deepEqual([...missing].sort(), [], 'unresolved talent references are a build failure');
});

test('dataset: random groups survive the pipeline', { skip: !hasBuild }, () => {
  const dataset = JSON.parse(fs.readFileSync(path.join(outDir, 'data/monsters.json'), 'utf8'));
  const necromancer = dataset.monsters.find((monster) => monster.name === 'orc necromancer');
  assert.ok(necromancer, 'orc necromancer is in the dataset');
  assert.equal(necromancer.rngSets.length, 4, 'its four exclusive groups must not be flattened');
  assert.ok(!necromancer.talents.some((talent) => talent.id === necromancer.rngSets[0][0].id));
});

test('dataset: level rules are recorded, not clipped', { skip: !hasBuild }, () => {
  const dataset = JSON.parse(fs.readFileSync(path.join(outDir, 'data/monsters.json'), 'utf8'));
  for (const monster of dataset.monsters) {
    for (const talent of monster.talents) {
      if (talent.level !== null) {
        assert.ok(Number.isFinite(talent.level) && talent.level >= 0, `${monster.id}/${talent.id} level ${talent.level}`);
        // Some endgame bosses really do carry skills at 100+; only absurd
        // values indicate a mis-parse.
        assert.ok(talent.level <= 1000, `implausible monster talent level: ${talent.id}=${talent.level}`);
      }
      if (talent.growth) {
        for (const [key, value] of Object.entries(talent.growth)) {
          assert.ok(value === null || Number.isFinite(value), `${monster.id}/${talent.id} ${key}=${value}`);
        }
      }
    }
  }
});

test('dataset: every collected image file exists on disk', { skip: !hasBuild }, () => {
  const dataset = JSON.parse(fs.readFileSync(path.join(outDir, 'data/monsters.json'), 'utf8'));
  const missing = [];
  for (const monster of dataset.monsters) {
    if (!monster.image) continue;
    const file = path.join(outDir, 'img', monster.image);
    if (!fs.existsSync(file)) missing.push(monster.image);
  }
  assert.deepEqual([...new Set(missing)].slice(0, 5), [], 'referenced art must be copied into public/img');
});
