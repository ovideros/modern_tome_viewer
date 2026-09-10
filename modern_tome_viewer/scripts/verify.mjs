/**
 * End-to-end checks for the search index and filter engine against the real
 * generated dataset. Run with: node scripts/verify.mjs
 *
 * This exercises the same code paths the browser uses (search.ts / filters.ts
 * are transpiled on the fly with esbuild) so a regression shows up here before
 * it shows up in the UI.
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { build } from 'esbuild';
import { defaultSimParams, evaluateAcronym, talentPowerDamage } from '../src/lib/scaling-core.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, '..');

let failures = 0;
let checks = 0;

function check(name, condition, detail = '') {
  checks += 1;
  if (condition) {
    console.log(`  ok   ${name}`);
  } else {
    failures += 1;
    console.log(`  FAIL ${name}${detail ? ` — ${detail}` : ''}`);
  }
}

function section(title) {
  console.log(`\n${title}`);
}

// ---------------------------------------------------------------------------
// Transpile the browser modules so we can import them in Node.
// ---------------------------------------------------------------------------

const outDir = path.join(root, 'node_modules', '.cache', 'verify');
await build({
  entryPoints: {
    search: path.join(root, 'src/lib/search.ts'),
    filters: path.join(root, 'src/lib/filters.ts'),
    data: path.join(root, 'src/lib/data.ts'),
    compare: path.join(root, 'src/lib/compare.ts'),
  },
  outdir: outDir,
  bundle: true,
  format: 'esm',
  platform: 'neutral',
  target: 'es2022',
  logLevel: 'error',
  // data.ts references import.meta.env.BASE_URL (Vite-only) — stub it out.
  define: { 'import.meta.env.BASE_URL': '"/"' },
});

const searchMod = await import(pathToFileURL(path.join(outDir, 'search.js')).href);
const filtersMod = await import(pathToFileURL(path.join(outDir, 'filters.js')).href);
const dataMod = await import(pathToFileURL(path.join(outDir, 'data.js')).href);
const compareMod = await import(pathToFileURL(path.join(outDir, 'compare.js')).href);

const { TalentSearchIndex, tokenize } = searchMod;
const { compileFilters, cooldownKindCounts, emptyFilters, facetCounts, filtersToParams, paramsToFilters } = filtersMod;
const { normalizeDataset } = dataMod;
const { bestByRow, bestId, cooldownValue, rangeValue, costValue } = compareMod;

// ---------------------------------------------------------------------------
// Load the generated dataset
// ---------------------------------------------------------------------------

const wire = JSON.parse(fs.readFileSync(path.join(root, 'public/data/talents.json'), 'utf8'));
const meta = JSON.parse(fs.readFileSync(path.join(root, 'public/data/meta.json'), 'utf8'));
const { trees, talents } = normalizeDataset(wire, meta);

section('dataset');
check('trees loaded', trees.length === 381, `got ${trees.length}`);
check('talents loaded', talents.length === 1834, `got ${talents.length}`);
check('every talent has a tree name', talents.every((t) => t.treePlainName.length > 0));
check('every talent has a category name', talents.every((t) => t.categoryName.length > 0));
check(
  'no negative cooldown leaked from the acronym title',
  talents.every((t) => t.cooldown.values.every((v) => v >= 0)),
  JSON.stringify(talents.filter((t) => t.cooldown.values.some((v) => v < 0)).slice(0, 3).map((t) => t.id)),
);
// `fixed_cooldown = true` (Actor.lua:6872 — "Can not touch this cooldown") is
// orthogonal to whether the value is a constant: 超越永恒 is a flat 50, while
// 狂热/哨兵/定向跳跃 scale with talent level and are still untouchable.
const fixedCooldowns = talents.filter((t) => t.cooldown.fixed);
check('fixed cooldowns survive the build', fixedCooldowns.length === 27, `got ${fixedCooldowns.length}`);
const timeless = talents.find((t) => t.id === 'T_TIMELESS');
check('超越永恒 carries its fixed cooldown', timeless?.cooldown.fixed === true && timeless?.cooldown.display === '50', JSON.stringify(timeless?.cooldown));
const frenzy = talents.find((t) => t.id === 'T_DREM_FRENZY');
check('a fixed cooldown may still be a level ladder', frenzy?.cooldown.fixed === true && frenzy?.cooldown.values.length === 5, JSON.stringify(frenzy?.cooldown));

// ---------------------------------------------------------------------------
// Tokenizer
// ---------------------------------------------------------------------------

section('tokenizer');
check('CJK bigrams', tokenize('火焰冲击').includes('火焰'), JSON.stringify(tokenize('火焰冲击')));
check('CJK unigrams', tokenize('火焰冲击').includes('冲'));
check('ascii words lowercase', tokenize('T_MASS_REPAIR').join(',') === 't,mass,repair', tokenize('T_MASS_REPAIR').join(','));
check('mixed script', tokenize('火焰 100 伤害').includes('100'));

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

const started = performance.now();
const index = new TalentSearchIndex(
  talents.map((t) => ({
    name: `${t.plainName} ${t.shortName} ${t.id}`,
    tree: `${t.treeName} ${t.tree}`,
    category: `${t.categoryName} ${t.category}`,
    text: t.plain,
  })),
);
const buildMs = performance.now() - started;

section(`search index (built in ${buildMs.toFixed(0)} ms, ${index.termCount} terms)`);
check('index build is fast enough', buildMs < 3000, `${buildMs.toFixed(0)} ms`);

const searchIds = (query, limit = 10) => index.search(query, { limit }).map((hit) => talents[hit.index].id);

const fire = searchIds('火焰');
check('CJK substring query returns hits', fire.length > 0, JSON.stringify(fire));
check(
  'CJK substring match is real (not empty-prefix noise)',
  fire.every((id) => {
    const talent = talents.find((t) => t.id === id);
    return `${talent.plainName}${talent.treePlainName}${talent.plain}`.includes('火焰');
  }),
);

const nameScoped = index
  .search('name:火焰', { limit: 10 })
  .map((hit) => talents[hit.index]);
check('field-scoped query only matches the name field', nameScoped.length > 0);
check(
  'field-scoped results really contain the term in their name',
  nameScoped.every((t) => t.plainName.includes('火焰')),
  JSON.stringify(nameScoped.map((t) => t.plainName)),
);

const shortName = searchIds('repair');
check('ascii prefix query works', shortName.length > 0, JSON.stringify(shortName));
check(
  'ascii prefix matches talent short names',
  index
    .search('repair', { limit: 5 })
    .map((h) => talents[h.index])
    .some((t) => t.shortName.toLowerCase().includes('repair')),
);

const phrase = searchIds('"火焰伤害"');
check('quoted phrase query works', phrase.length > 0, JSON.stringify(phrase));

const negated = index.search('-name:被动', { limit: 5 }).map((h) => talents[h.index]);
check('negated term excludes matches', negated.length > 0 && negated.every((t) => !t.plainName.includes('被动')));

// Tree paths contain a slash; they must stay one term.
const treePath = index.search('tree:spell/fire', { limit: 50 }).map((h) => talents[h.index]);
check('tree path query (tree:spell/fire) returns hits', treePath.length > 0, JSON.stringify(treePath.slice(0, 3).map((t) => t.id)));
// "fire" prefix-expands to "fire-alchemy", so accept that tree and its variants.
check(
  'tree path query only returns that tree family',
  treePath.every((t) => t.tree === 'spell/fire' || t.tree.startsWith('spell/fire-')),
  JSON.stringify(treePath.filter((t) => !t.tree.startsWith('spell/fire')).slice(0, 3).map((t) => t.tree)),
);
const idQuery = index.search('name:T_FIRE_STORM', { limit: 5 }).map((h) => talents[h.index]);
check('internal id query works', idQuery.some((t) => t.id === 'T_FIRE_STORM'), JSON.stringify(idQuery.map((t) => t.id)));

const none = searchIds('zzzzz-not-a-real-term');
check('nonsense query returns nothing', none.length === 0, JSON.stringify(none));

const multi = searchIds('火焰 伤害');
check('multi-term query uses AND semantics', multi.length > 0 && multi.length <= fire.length, `${multi.length} vs ${fire.length}`);

// Relevance: a name match should outrank a body-only match.
const nameFirst = index.search('火焰', { limit: 5 }).map((h) => talents[h.index]);
check('name matches rank above body-only matches', nameFirst.length > 0 && nameFirst[0].plainName.includes('火焰'));

// Field weights: the same term scores higher in `name` than in `text`.
const nameHits = new Map(index.search('火焰', { limit: 500, defaultFields: ['name'] }).map((h) => [h.index, h.score]));
const textHits = new Map(index.search('火焰', { limit: 500, defaultFields: ['text'] }).map((h) => [h.index, h.score]));
const shared = [...nameHits.keys()].filter((id) => textHits.has(id));
check(
  'name field outranks text field for the same term',
  shared.length > 0 && shared.every((id) => nameHits.get(id) > textHits.get(id)),
  `${shared.length} shared docs`,
);

// ---------------------------------------------------------------------------
// Filters
// ---------------------------------------------------------------------------

section('filters');

const activeOnly = compileFilters({ ...emptyFilters(), modes: ['主动技能'] });
const activeCount = talents.filter(activeOnly).length;
check('mode filter matches the reported facet count', activeCount === 1128, `got ${activeCount}`);

const cdZero = compileFilters({ ...emptyFilters(), cooldown: { min: 0, max: 0 } });
const cdZeroMatches = talents.filter(cdZero);
check('cooldown 0 filter returns hits', cdZeroMatches.length > 0);
check(
  'cooldown 0 filter keeps only ladders containing 0 (plus no-cooldown talents)',
  cdZeroMatches.every((t) => t.cooldown.values.length === 0 || t.cooldown.values.includes(0)),
  JSON.stringify(cdZeroMatches.filter((t) => t.cooldown.values.length && !t.cooldown.values.includes(0)).slice(0, 3).map((t) => [t.id, t.cooldown.values])),
);
check(
  'cooldown 0 filter excludes every talent whose ladder starts above 0',
  !cdZeroMatches.some((t) => t.cooldown.values.length && Math.min(...t.cooldown.values) > 0),
);
check(
  'no-cooldown talents are included by default',
  cdZeroMatches.some((t) => t.cooldown.values.length === 0),
);

const cdZeroNoNulls = compileFilters({
  ...emptyFilters(),
  cooldown: { min: 1, max: 5 },
  includeNoCooldown: false,
});
check(
  'excluding no-cooldown talents removes passives',
  talents.filter(cdZeroNoNulls).every((t) => t.cooldown.values.length > 0),
);

// The fixed/non-fixed switch: two mutually exclusive halves of the same set.
const onlyFixed = compileFilters({ ...emptyFilters(), cooldownKind: 'fixed' });
const onlyNormal = compileFilters({ ...emptyFilters(), cooldownKind: 'normal' });
const fixedMatches = talents.filter(onlyFixed);
const normalMatches = talents.filter(onlyNormal);
check('fixed-only filter returns exactly the flagged talents', fixedMatches.length === 27, `got ${fixedMatches.length}`);
check('fixed-only filter keeps only flagged talents', fixedMatches.every((t) => t.cooldown.fixed));
check('not-fixed-only filter keeps only unflagged talents', normalMatches.every((t) => !t.cooldown.fixed));
check(
  'the two halves partition the corpus',
  fixedMatches.length + normalMatches.length === talents.length,
  `${fixedMatches.length} + ${normalMatches.length} vs ${talents.length}`,
);
check(
  'both halves are non-empty and neither contains the other',
  fixedMatches.length > 0 && normalMatches.length > 0 && fixedMatches.length < normalMatches.length,
);
// Fixed is a flag, not a shape: a fixed talent may still show a cooldown ladder.
check(
  'fixed-only is not the same as "cooldown is a single number"',
  fixedMatches.some((t) => t.cooldown.values.length > 1)
    && normalMatches.some((t) => t.cooldown.values.length === 1),
);
const cdKindTally = cooldownKindCounts(talents, emptyFilters());
check(
  'the switch counts agree with the predicates',
  cdKindTally.fixed === fixedMatches.length && cdKindTally.normal === normalMatches.length,
  JSON.stringify(cdKindTally),
);

const melee = compileFilters({ ...emptyFilters(), rangeKinds: ['melee'] });
check('range kind filter matches facet count', talents.filter(melee).length === 1024, `got ${talents.filter(melee).length}`);

const mana = compileFilters({ ...emptyFilters(), resources: ['mana'] });
check('resource filter matches facet count', talents.filter(mana).length === 184, `got ${talents.filter(mana).length}`);

const spells = compileFilters({ ...emptyFilters(), flags: ['is_spell'] });
check('flag filter matches facet count', talents.filter(spells).length === 786, `got ${talents.filter(spells).length}`);

// Class scope: MAGE should only see its own trees.
const mageTrees = new Set(trees.filter((t) => t.classes.includes('MAGE')).map((t) => t.id));
const mageFilter = compileFilters({ ...emptyFilters(), classId: 'MAGE' }, mageTrees);
const mageMatches = talents.filter(mageFilter);
check('class filter returns a non-empty subset', mageMatches.length > 0 && mageMatches.length < talents.length);
check('class filter only returns that class’ trees', mageMatches.every((t) => mageTrees.has(t.tree)));

// Facet counts must ignore their own dimension but respect the others.
const baseFilters = { ...emptyFilters(), modes: ['持续技能'] };
const counts = facetCounts(talents, baseFilters, 'categories');
const sustainTotal = talents.filter((t) => t.mode === '持续技能').length;
const countedTotal = counts.reduce((sum, entry) => sum + entry.count, 0);
check('category facet counts sum to the filtered total', countedTotal === sustainTotal, `${countedTotal} vs ${sustainTotal}`);

// ---------------------------------------------------------------------------
// URL round-trip
// ---------------------------------------------------------------------------

section('url round-trip');
const original = {
  ...emptyFilters(),
  query: 'name:火焰 伤害',
  modes: ['主动技能'],
  resources: ['mana'],
  classId: 'MAGE',
  cooldown: { min: 1, max: 10 },
  includeNoCooldown: false,
  flags: ['is_spell'],
};
const roundTripped = paramsToFilters(filtersToParams(original));
check('query survives', roundTripped.query === original.query);
check('arrays survive', roundTripped.modes.join() === original.modes.join() && roundTripped.flags.join() === original.flags.join());
check('class survives', roundTripped.classId === original.classId);
check('numeric ranges survive', roundTripped.cooldown.min === 1 && roundTripped.cooldown.max === 10);
check('boolean survives', roundTripped.includeNoCooldown === false);

// ---------------------------------------------------------------------------
// Classes and races (class/race pages)

section('classes and races');
check('12 classes present', meta.classList.length === 12, String(meta.classList.length));
check('10 races present', meta.raceList.length === 10, String(meta.raceList.length));
check('every class has subclasses', meta.classes.every((c) => c.subclasses.length > 0));
check(
  'every subclass has attribute modifiers',
  meta.classes.every((c) => c.subclasses.every((s) => Object.keys(s.stats).length > 0)),
);
// The upstream export omits life_rating for 10 subclasses (verified below);
// the UI renders "—" for those rather than inventing a number.
const missingLife = meta.classes.flatMap((c) => c.subclasses.filter((s) => typeof s.lifeRating !== 'number'));
check(
  'life ratings are numbers when present',
  meta.classes.every((c) => c.subclasses.every((s) => s.lifeRating === null || typeof s.lifeRating === 'number')),
);
check('life rating coverage is >= 70% of subclasses', missingLife.length <= 10, `${missingLife.length} missing`);

const allTreeRefs = meta.classes.flatMap((c) => c.subclasses.flatMap((s) => [...s.classTrees, ...s.genericTrees]));
check('class tree refs resolved', allTreeRefs.length > 200, `${allTreeRefs.length} refs`);
check(
  'every class tree ref points at a real tree',
  allTreeRefs.every((ref) => trees.some((tree) => tree.id === ref.id)),
  JSON.stringify(allTreeRefs.filter((ref) => !trees.some((t) => t.id === ref.id)).slice(0, 3).map((r) => r.id)),
);
check(
  'mastery values are sane (0.9 – 1.3)',
  allTreeRefs.every((ref) => ref.mastery >= 0.9 && ref.mastery <= 1.3),
  JSON.stringify(allTreeRefs.filter((r) => r.mastery < 0.9 || r.mastery > 1.3).slice(0, 3)),
);
check(
  'every tree ref carries an unlocked flag',
  allTreeRefs.every((ref) => typeof ref.unlocked === 'boolean'),
);

// Regression: upstream encodes the tuple as [unlocked, mastery, label]. Reading
// it as "locked" inverted every badge; Bulwark's three generic trees are all
// unlocked in game, and its shield trees are unlocked while warcries are not.
const bulwark = meta.classes.find((c) => c.id === 'WARRIOR')?.subclasses.find((s) => s.id === 'BULWARK');
check('Bulwark found', Boolean(bulwark));
if (bulwark) {
  check(
    'Bulwark generic trees are all unlocked',
    bulwark.genericTrees.every((tree) => tree.unlocked),
    JSON.stringify(bulwark.genericTrees.map((t) => [t.id, t.unlocked])),
  );
  check(
    'Bulwark shield trees are unlocked',
    bulwark.classTrees.filter((t) => t.id.includes('shield')).every((t) => t.unlocked),
  );
  check(
    'Bulwark warcries / battle-tactics are locked',
    bulwark.classTrees.filter((t) => /warcries|battle-tactics/.test(t.id)).every((t) => !t.unlocked),
  );
  check('Bulwark has portrait images', bulwark.images.length >= 1, JSON.stringify(bulwark.images));
}
check(
  'every subclass has a class icon portrait',
  meta.classes.every((c) => c.subclasses.every((s) => s.images.some((i) => i.file.startsWith('class-icons/')))),
);
check(
  'every subrace has at least one portrait or is a known gap',
  meta.races.every((r) => r.subraces.every((s) => s.images.length > 0)),
  JSON.stringify(meta.races.flatMap((r) => r.subraces.filter((s) => s.images.length === 0).map((s) => s.id))),
);
check(
  'portrait files are present on disk',
  [...meta.classes.flatMap((c) => c.subclasses.flatMap((s) => s.images)), ...meta.races.flatMap((r) => r.subraces.flatMap((s) => s.images))]
    .every((image) => fs.existsSync(path.join(root, 'public', 'img', image.file))),
  JSON.stringify(
    [...meta.classes.flatMap((c) => c.subclasses.flatMap((s) => s.images)), ...meta.races.flatMap((r) => r.subraces.flatMap((s) => s.images))]
      .filter((image) => !fs.existsSync(path.join(root, 'public', 'img', image.file)))
      .slice(0, 5)
      .map((i) => i.file),
  ),
);
// Starting lists also name resource pools (T_STAMINA_POOL, T_INSANITY_POOL)
// that are engine-internal and absent from the talent export.
const danglingStarters = meta.classes.flatMap((c) =>
  c.subclasses.flatMap((s) => s.startingTalents.filter((id) => !talents.some((t) => t.id === id)).map((id) => `${s.id}:${id}`)),
);
check(
  'starting talents resolve except known engine pools',
  danglingStarters.every((entry) => /_POOL$/.test(entry)),
  JSON.stringify(danglingStarters.slice(0, 5)),
);
// Adventurer is a custom-build class and intentionally has no fixed start.
const withoutStarters = meta.classes.flatMap((c) => c.subclasses.filter((s) => s.startingTalents.length === 0));
check(
  'subclasses list starting talents (Adventurer excepted)',
  withoutStarters.length === 0 || withoutStarters.every((s) => s.id === 'ADVENTURER'),
  JSON.stringify(withoutStarters.map((s) => s.id)),
);
check(
  'race descriptions are valid HTML (balanced spans)',
  [...meta.classes, ...meta.races].every((r) => {
    const text = `${r.description} ${(r.subclasses ?? r.subraces ?? []).map((x) => x.description).join(' ')}`;
    return (text.match(/<span/g) ?? []).length === (text.match(/<\/span>/g) ?? []).length;
  }),
);
check(
  'no literal backreference artefacts leaked into descriptions',
  ![...meta.classes, ...meta.races].some((r) => `${r.description}`.includes('$1') || `${r.description}`.includes('$3')),
);

// ---------------------------------------------------------------------------
// Comparison helpers

section('comparison');
const byId = new Map(talents.map((t) => [t.id, t]));
const fireTrio = ['T_FLAMESHOCK', 'T_FIRE_STORM', 'T_INFERNO'].map((id) => byId.get(id)).filter(Boolean);
check('comparison sample talents exist', fireTrio.length === 3, String(fireTrio.length));
const winners = bestByRow(fireTrio);
check('cooldown winner is the lowest-cooldown talent', winners.cooldown === bestId(fireTrio, cooldownValue, 'lower'));
check('range winner is the highest-range talent', winners.range === bestId(fireTrio, rangeValue, 'higher'));
check(
  'cooldown winner really has the minimum cooldown',
  cooldownValue(byId.get(winners.cooldown)) === Math.min(...fireTrio.map(cooldownValue).filter((v) => v !== null)),
);
check(
  'range winner really has the maximum range',
  rangeValue(byId.get(winners.range)) === Math.max(...fireTrio.map(rangeValue).filter((v) => v !== null)),
);
check('cost helper reads the parsed amount', costValue(byId.get('T_FLAMESHOCK')) === 30, String(costValue(byId.get('T_FLAMESHOCK'))));
check('a single talent is its own winner', bestId([fireTrio[0]], cooldownValue) === fireTrio[0].id);
check('empty comparison has no winner', bestId([], cooldownValue) === null);
check(
  'talents without cooldown never win the cooldown row',
  bestId([byId.get('T_ATTACK'), byId.get('T_FLAMESHOCK')], cooldownValue) === 'T_FLAMESHOCK',
);

// ---------------------------------------------------------------------------

section('source scaling');
const sourceValues = [...byId.values()].flatMap(t => t.acronyms).filter(a => a.lua);
check('at least 1200 values carry validated Lua formulas', sourceValues.length >= 1200, String(sourceValues.length));
const flame = byId.get('T_FLAMESHOCK').acronyms[1];
check('Flameshock retains source coefficients and provenance', flame.base === 10 && flame.max === 250 && flame.lua?.file.endsWith('spells/fire.lua') && flame.lua?.line === 89);
const flameSim = defaultSimParams(flame);
check('Flameshock exactly reproduces the exported damage ladder', JSON.stringify([1,2,3,4,5].map(talentLevel => Math.round(evaluateAcronym(flame, {...flameSim, talentLevel})))) === JSON.stringify([181,246,297,340,378]));
// Powers are per type now: the family reads 法术强度 (with the legacy single
// field kept in step for callers that only pass one).
check('Flameshock power 300 uses actual source coefficients', Math.abs(evaluateAcronym(flame, {...flameSim, power: 300, powers: {...flameSim.powers, 法术强度: 300}}) - talentPowerDamage(1.5, 10, 250, 300)) < 1e-9);

console.log(`\n${checks - failures}/${checks} checks passed`);
if (failures) {
  console.error(`${failures} check(s) failed`);
  process.exit(1);
}
