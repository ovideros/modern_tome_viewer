/**
 * Tests for the affix effect notes.
 *
 * The point of `summary.mjs` is that an affix whose effect lives in a callback
 * still arrives at the list card as a sentence rather than "open the detail to
 * find out". Three sources feed it and each has its own failure mode:
 *
 *   - the game's description inside a `function` (needs the callback body, not
 *     just its first string, to know which fields fill the `%d`s);
 *   - the game's description as data (`desc = _t"..."` beside the callback,
 *     which has no `%d` at all in most cases and is easy to filter out by
 *     accident);
 *   - a hand-written note for callbacks that have no text (which must quote the
 *     source expression it came from, and must survive the `:greater` suffix).
 *
 * Run:  node --test scripts/items/*.test.mjs
 */

import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { scanItemFile } from './lua-entities.mjs';
import { egoNotes, egoRandomOptions, CALLBACK_NOTES, placeholderize } from './summary.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..', '..');
const workspaceRoot = path.resolve(projectRoot, '..');
const sourcesAvailable = fs.existsSync(path.join(workspaceRoot, 'tome-src-full/mod/class/Object.lua'));
const skip = sourcesAvailable ? false : 'game sources are not present';

/** A locale stub: tests pin the wording, not the shipped translation table. */
const locale = {
  text: (value) => (value.includes('SHIELD') ? '测试翻译%d点' : null),
  entityWord: () => null,
};

/** Parse one synthetic `newEntity{...}` and run the note builder over it. */
function notesOf(id, source) {
  const { entities } = scanItemFile(`newEntity{ ${source} }`, 'fragment.lua');
  assert.equal(entities.length, 1, 'the fragment must contain one entity');
  return egoNotes(id, { ast: entities[0].fields }, locale).notes;
}

test('a callback description becomes a note with its own field as the value', () => {
  const notes = notesOf('tome:charms:test', `
    name = " evasive",
    evasive_chance = resolvers.mbonus_material(30, 10),
    charm_on_use = {
      {100, function(self, who) return ("gain a %d%% chance to evade"):tformat(self.evasive_chance) end, function(self) end},
    },
  `);
  assert.equal(notes.length, 1);
  const note = notes[0];
  assert.equal(note.basis, 'game');
  // The note keeps `{0}`: filling it is the UI's job, because the number moves
  // with the material level the reader selects.
  assert.equal(note.text, 'gain a {0}% chance to evade');
  // The placeholder is tied to a statically known value, so the UI can show the
  // range for a chosen material level.
  assert.deepEqual(note.values['0'].range, [10, 40]);
  assert.deepEqual(note.values['0'].materialRanges[0], [10, 16]);
});

test('the percent escape does not swallow the next word', () => {
  // `%%` followed by ` for` used to match as one `% f` specifier, turning the
  // sentence into "reduce fatigue by X%?or 2 turns".
  const notes = notesOf('tome:charms:test', `
    name = " innervating",
    innervating_fatigue = resolvers.mbonus_material(40, 20),
    charm_on_use = {
      {100, function(self, who) return ("reduce fatigue by %d%% for 2 turns"):tformat(self.innervating_fatigue) end, function(self) end},
    },
  `);
  assert.equal(notes[0].text, 'reduce fatigue by {0}% for 2 turns');
  assert.equal(Object.keys(notes[0].values).length, 1);
});

test('a value computed from the wielder stays a visible placeholder', () => {
  const notes = notesOf('tome:weapon:test', `
    name = " acidic",
    special_on_crit = {
      desc = function(self, who, special)
        local dam = special.acid_splash(who)
        return ("Splash the target with acid dealing %d damage"):tformat(dam)
      end,
      fct = function(combat, who, target) end,
    },
  `);
  assert.equal(notes.length, 1);
  assert.match(notes[0].text, /dealing \{0\} damage/);
  assert.equal(notes[0].values['0'].range, null, 'a runtime value must not be invented');
  assert.match(notes[0].values['0'].expression, /运行时计算/);
});

test('a description declared as data is found even without a placeholder', () => {
  // This is the `of torment` shape: `desc` is a plain string, so a scan limited
  // to `function` nodes (or to strings containing `%d`) misses it entirely.
  const notes = notesOf('tome:weapon:test', `
    name = " of torment",
    combat = {
      special_on_hit = {
        desc = _t"50% chance to stun the target for 3 turns",
        fct = function(combat, who, target) end,
      },
    },
  `);
  assert.equal(notes.length, 1);
  assert.equal(notes[0].text, '50% chance to stun the target for 3 turns');
  assert.deepEqual(notes[0].values, {});
});

test('the item flavour text is not mistaken for an effect', () => {
  const notes = notesOf('tome:weapon:test', `
    name = " test",
    desc = _t"#YELLOW#A blade that hums with barely contained spite.",
    wielder = { combat_atk = resolvers.mbonus_material(10, 5) },
  `);
  assert.deepEqual(notes, []);
});

test('a charm power description comes from the resolver argument', () => {
  const notes = notesOf('tome:torques-powers:test', `
    name = " of psionic shield", addon = true,
    charm_power_def = {add=3, max=200, floor=true},
    resolvers.charm(_t"SHIELD reducing all damage taken by %d for 5 turns", 25, function(self, who) end),
  `);
  assert.equal(notes.length, 1);
  // The translation table is stubbed; the placeholder survives it.
  assert.match(notes[0].text, /测试翻译\{0\}点/);
  assert.equal(notes[0].values['0'].range, null);
  assert.match(notes[0].values['0'].expression, /getCharmPower/);
});

test('a hand-written note is used when the callback carries no text', () => {
  const notes = notesOf('tome:charms:charm_proc_quick', `
    name = "quick ", prefix=true, unique_ego = "charm_proc_quick",
    resolvers.genericlast(function(e) e.charm_power_mods = {} end),
  `);
  assert.equal(notes.length, 1);
  assert.equal(notes[0].basis, 'source');
  assert.match(notes[0].text, /60%~80%/);
  assert.ok(notes[0].from, 'a hand-written note must quote the expression it summarises');
});

test('a greater variant inherits its base note', () => {
  const notes = notesOf('tome:charms:charm_proc_quick:greater', `
    name = "quick ", prefix=true, greater_ego = 1, unique_ego = "charm_proc_quick",
    resolvers.genericlast(function(e) e.charm_power_mods = {} end),
  `);
  assert.equal(notes.length, 1);
  assert.equal(notes[0].basis, 'source');
});

test('a hand-written note replaces an unusable template for the same effect', () => {
  // `of shrapnel` has both: the game's line needs the wielder's physical power,
  // and the hand-written note explains the same effect without a `?` in it.
  const notes = notesOf('tome:shield:shrapnel:greater', `
    name = " of shrapnel", greater_ego = 1,
    on_block = {
      desc = function(self, who, special) return ("bleed for %d damage"):tformat(special.shield_shrapnel(who)) end,
      shield_shrapnel = function(who) return 10 end,
      fct = function(self, who) end,
    },
  `);
  assert.equal(notes.length, 1);
  assert.equal(notes[0].basis, 'source');
});

test('every hand-written note names its source expression', () => {
  for (const [id, spec] of Object.entries(CALLBACK_NOTES)) {
    assert.ok(spec.text, `${id} needs text`);
    assert.ok(spec.from, `${id} must record where the wording came from`);
    // A value placeholder must have a matching spec, or the UI renders `?`.
    for (const match of spec.text.matchAll(/\{(\d+)\}/g)) {
      assert.ok(spec.values?.[match[1]], `${id} references {${match[1]}} with no value spec`);
    }
  }
});

test('the imbued staff exposes the source-defined weighted talent pool', () => {
  const options = egoRandomOptions('tome:staves:imbued:greater');
  assert.equal(options.length, 29);
  assert.equal(options.reduce((total, option) => total + option.weight, 0), 155);
  assert.deepEqual(options[0], { talentId: 'T_FLAME', weight: 10 });
  assert.deepEqual(options.at(-1), { talentId: 'T_ENTROPY', weight: 1 });
});

test('placeholderize keeps an escaped percent and numbers the specs', () => {
  assert.deepEqual(placeholderize('a %d%% b %s'), { text: 'a {0}% b {1}', count: 2 });
  assert.deepEqual(placeholderize('no specs here'), { text: 'no specs here', count: 0 });
});

test('real egos with callback effects all produce a readable line', { skip }, () => {
  // The regression this guards: 51 affixes used to reach the list as "open the
  // detail to see the effect". Every one of them must now produce a note.
  const egosFile = path.join(projectRoot, 'public/data/egos.json');
  if (!fs.existsSync(egosFile)) return;
  const dataset = JSON.parse(fs.readFileSync(egosFile, 'utf8'));
  const withoutProperties = dataset.egos.filter((ego) => (ego.areas ?? []).length === 0);
  assert.ok(withoutProperties.length > 0, 'the dataset should contain callback-only affixes');
  for (const ego of withoutProperties) {
    assert.ok((ego.notes ?? []).length > 0, `${ego.id} has no properties and no note`);
  }
});
