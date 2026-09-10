/**
 * Unit tests for the Lua entity reader.
 *
 * Run: node --test scripts/monsters/lua-table.test.mjs
 *
 * Every case here is drawn from a real construct in the ToME 1.7.6 sources;
 * the block-balance cases exist because getting `do`/`end` counting wrong makes
 * the reader swallow the closing brace of the enclosing `newEntity{...}` table.
 */

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseLuaFile, tokenize, literalOf, keyName } from './lua-table.mjs';

/** Parsed literal map for the single entity in `src`. */
const fields = (src) => {
  const out = parseLuaFile(src, 'test.lua');
  assert.deepEqual(out.diagnostics, [], 'unexpected diagnostics');
  assert.equal(out.entities.length, 1, 'expected exactly one entity');
  return Object.fromEntries(out.entities[0].fields.map.map((e) => [keyName(e.key), literalOf(e.value)]));
};

/** Raw AST entry for a named field, for cases literalOf cannot represent. */
const rawField = (src, name) => {
  const out = parseLuaFile(src, 'test.lua');
  assert.deepEqual(out.diagnostics, [], 'unexpected diagnostics');
  return out.entities[0].fields.map.find((e) => keyName(e.key) === name)?.value;
};

test('reads scalar fields and nested tables', () => {
  const f = fields(`newEntity{ define_as = "A", name = "thing", rank = 3,
    stats = { str = 10, mag = 5 },
    level_range = { 5, 20 },
  }`);
  assert.equal(f.define_as, 'A');
  assert.equal(f.name, 'thing');
  assert.equal(f.rank, 3);
  assert.deepEqual(f.stats, { str: 10, mag: 5 });
  assert.deepEqual(f.level_range, {}); // array part lives in the AST, see the next assertion
  assert.deepEqual(rawField(`newEntity{ level_range = { 5, 20 } }`, 'level_range').array.map(literalOf), [5, 20]);
});

test('keeps resolver calls as array entries', () => {
  const out = parseLuaFile(
    `newEntity{ define_as = "A",
      resolvers.talents{ [Talents.T_BITE] = 2, [Talents.T_RUSH] = { base = 1, every = 5 } },
      resolvers.rngtalentsets{ { [Talents.T_X] = 3 }, { [Talents.T_Y] = 4 } },
    }`,
    'test.lua',
  );
  assert.deepEqual(out.diagnostics, []);
  const entries = out.entities[0].fields.array;
  assert.equal(entries.length, 2);
  assert.equal(entries[0].path.join('.'), 'resolvers.talents');
  assert.equal(entries[1].path.join('.'), 'resolvers.rngtalentsets');
  assert.equal(entries[1].args[0].array.length, 2, 'two mutually exclusive sets');
});

test('balances if/for/do/end inside a function field', () => {
  const src0 = `newEntity{ define_as = "A",
    on_die = function(self, src)
      if profile.x then return end
      for uid, e in pairs(game.level.entities) do if e.is_ads then
        local o = e.onTakeHit
      end end
      return value
    end,
    rank = 4,
  }`;
  const f = fields(src0);
  assert.equal(f.rank, 4, 'the field after the function body must survive');
  assert.equal(rawField(src0, 'on_die').kind, 'function');
});

test('balanced do ... end block opens its own scope', () => {
  const f = fields(`newEntity{ define_as = "A",
    fn = function(self) do local x = 1 end end,
    rank = 1,
  }`);
  assert.equal(f.rank, 1);
});

test('balanced repeat ... until inside a function', () => {
  const f = fields(`newEntity{ define_as = "A",
    fn = function(self)
      repeat
        local x = 1
      until x
    end,
    rank = 1,
  }`);
  assert.equal(f.rank, 1);
});

test('braces inside a function body do not close the entity table', () => {
  const f = fields(`newEntity{ define_as = "A",
    fn = function(self) local t = { a = 1, b = { c = 2 } } end,
    rank = 7,
  }`);
  assert.equal(f.rank, 7);
});

test('folds literal arithmetic and leaves symbolic math unknown', () => {
  const f = fields(`newEntity{ define_as = "A", exp_worth = 3 / 5, max_life = 100 * 1.5, other = 2 ^ 3 }`);
  assert.equal(f.exp_worth, 0.6);
  assert.equal(f.max_life, 150);
  assert.equal(f.other, 8);
});

test('parses newEntity inside an if guard', () => {
  const out = parseLuaFile(`if game.difficulty == 1 then\n newEntity{ define_as = "B", name = "b" }\nend`, 'test.lua');
  assert.deepEqual(out.diagnostics, []);
  assert.equal(out.entities.length, 1);
  assert.equal(keyName(out.entities[0].fields.map[0].key), 'define_as');
});

test('records rather than silently drops unparseable input', () => {
  const out = parseLuaFile(`newEntity{ define_as = "A", rank = ?? }`, 'test.lua');
  assert.ok(out.diagnostics.length > 0, 'must report what it could not read');
});

test('tokenizes long-bracket strings and comments', () => {
  const tokens = tokenize(`--[[ comment ]] local s = [[raw\nstring]] -- tail`);
  assert.equal(tokens.filter((t) => t.type === 'string').length, 1);
  assert.match(tokens.find((t) => t.type === 'string').value, /raw\nstring/);
});
