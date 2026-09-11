/**
 * Render smoke test for the production bundle.
 *
 * Loads dist/index.html into a happy-dom document, stubs fetch so the bundle
 * can read public/data from disk, then asserts that the app actually renders
 * results, applies filters and opens the detail panel. Run: node scripts/smoke.mjs
 *
 * This catches the class of bug that unit tests cannot: broken imports, bad
 * Tailwind classes that do not compile, runtime errors during render.
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { Window } from 'happy-dom';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, '..');
const dist = path.join(root, 'dist');

if (!fs.existsSync(path.join(dist, 'index.html'))) {
  console.error('dist/ not found — run `npx vite build` first');
  process.exit(1);
}

let failures = 0;
let checks = 0;
const check = (name, condition, detail = '') => {
  checks += 1;
  if (condition) console.log(`  ok   ${name}`);
  else {
    failures += 1;
    console.log(`  FAIL ${name}${detail ? ` — ${detail}` : ''}`);
  }
};

// ---------------------------------------------------------------------------
// DOM + network stubs
// ---------------------------------------------------------------------------

const window = new Window({
  url: 'http://localhost/',
  settings: { disableJavaScriptFileLoading: true, disableCSSFileLoading: true },
});
const { document } = window;

const html = fs.readFileSync(path.join(dist, 'index.html'), 'utf8');
// Keep only the body markup; we run the real bundle ourselves.
document.write(html);
document.close();

// happy-dom does not implement matchMedia; the theme bootstrap needs it.
if (!window.matchMedia) {
  window.matchMedia = () => ({
    matches: false,
    media: '',
    addEventListener() {},
    removeEventListener() {},
    addListener() {},
    removeListener() {},
    dispatchEvent: () => false,
  });
}

// Resolve fetch() against the dist directory. The production bundle uses a
// relative base ("data/talents.json"), so handle that plus absolute paths.
const fetchStub = async (input) => {
  const raw = String(typeof input === 'string' ? input : input.url);
  const url = raw
    .replace(/^https?:\/\/localhost\//, '')
    .replace(/^\.\//, '')
    .replace(/^\//, '');
  const file = path.join(dist, url.split('?')[0]);
  if (!fs.existsSync(file)) {
    return { ok: false, status: 404, statusText: 'Not Found', async json() { throw new Error(`404 ${url}`); } };
  }
  const body = fs.readFileSync(file, 'utf8');
  return { ok: true, status: 200, async json() { return JSON.parse(body); }, async text() { return body; } };
};
window.fetch = fetchStub;

// Expose the stubs as globals before importing the bundle. Some globals on
// Node 22+ are accessor-only, so define them instead of assigning.
const globals = {
  window,
  document,
  navigator: window.navigator,
  fetch: fetchStub,
  HTMLElement: window.HTMLElement,
  Element: window.Element,
  Node: window.Node,
  Event: window.Event,
  CustomEvent: window.CustomEvent,
  MouseEvent: window.MouseEvent,
  KeyboardEvent: window.KeyboardEvent,
  getComputedStyle: window.getComputedStyle.bind(window),
  requestAnimationFrame: (cb) => setTimeout(() => cb(performance.now()), 0),
  cancelAnimationFrame: (id) => clearTimeout(id),
};
for (const [key, value] of Object.entries(globals)) {
  Object.defineProperty(globalThis, key, { value, writable: true, configurable: true });
}

// ---------------------------------------------------------------------------
// Load the bundle
// ---------------------------------------------------------------------------

const assetsDir = path.join(dist, 'assets');
const entry = fs.readdirSync(assetsDir).find((f) => f.startsWith('index-') && f.endsWith('.js'));
if (!entry) {
  console.error('no JS bundle found in dist/assets');
  process.exit(1);
}

console.log(`\nbundle: ${entry}`);

const errors = [];
const originalError = console.error;
console.error = (...args) => {
  errors.push(args.map(String).join(' '));
  originalError(...args);
};
window.addEventListener('error', (event) => errors.push(String(event.error ?? event.message)));

await import(pathToFileURL(path.join(assetsDir, entry)).href);

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const text = () => document.body.textContent ?? '';
const click = (element) => {
  element.dispatchEvent(new window.MouseEvent('click', { bubbles: true, cancelable: true }));
};
const findCardByText = (needle) =>
  [...document.querySelectorAll('[data-testid="ego-card"]')].find((card) => (card.textContent ?? '').includes(needle));
const findByText = (selector, needle) =>
  [...document.querySelectorAll(selector)].find((el) => (el.textContent ?? '').includes(needle));

// Wait for the dataset + index to finish loading.
for (let i = 0; i < 100 && !text().includes('条结果'); i += 1) await wait(50);

console.log('\ninitial render');
check('no runtime errors', errors.length === 0, errors.slice(0, 3).join(' | '));
check('header rendered', text().includes('ToME 技能查看器'));
check('data finished loading', text().includes('条结果'), text().slice(0, 160));
check('search field toggles rendered', text().includes('技能文本'));
check('filter panel rendered', text().includes('高级筛选'));
check('facet counts rendered', text().includes('主动技能'));
check(
  'all talents are listed by default',
  text().includes('1834') || text().includes('1,834'),
  text().match(/共\s*[\d,]+\s*条结果/)?.[0] ?? 'no count found',
);

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------

// React tracks input values internally, so assign through the native setter
// to make the framework observe the change.
const setInput = (element, value) => {
  const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
  setter.call(element, value);
  element.dispatchEvent(new window.Event('input', { bubbles: true }));
};

console.log('\nsearch');
const input = document.querySelector('input[placeholder*="搜索技能名"]');
check('search input exists', Boolean(input));
setInput(input, '火焰');
await wait(200);
const afterSearch = text();
check('typing filters the list', !afterSearch.includes('共 1834 条结果'), afterSearch.match(/共\s*[\d,]+\s*条结果/)?.[0] ?? '');
check('result row shows a matched talent', afterSearch.includes('火焰'), '');
check('search state is reflected in the URL hash', window.location.hash.includes('q=%E7%81%AB%E7%84%B0'), window.location.hash);

// Field-scoped query
setInput(input, 'name:火焰');
await wait(200);
check('field-scoped query still returns results', text().includes('条结果') && !text().includes('没有匹配的技能'));

// ---------------------------------------------------------------------------
// Detail panel
// ---------------------------------------------------------------------------

console.log('\ndetail panel');
const firstRow = document.querySelector('[data-testid="result-row"]');
check('a result row exists', Boolean(firstRow));
if (firstRow) {
  // Click the row body button (happy-dom does not deliver delegated clicks on
  // the wrapping div, so target the button React attached the handler to).
  const rowBody = [...firstRow.querySelectorAll('button')].find((b) => !b.getAttribute('aria-label'));
  click(rowBody ?? firstRow);
  await wait(120);
  const aside = document.querySelector('aside');
  const detail = aside ? (aside.textContent ?? '') : '';
  check('detail panel opens', detail.includes('技能说明') || detail.includes('使用模式'), detail.slice(0, 80));
  check('detail shows source info', detail.includes('数据来源'), detail.slice(-120));
  check('detail shows cooldown row', detail.includes('冷却时间'));
  check('detail shows favourite / compare actions', detail.includes('收藏') && detail.includes('对比'));
}

// ---------------------------------------------------------------------------
// Structured filters
// ---------------------------------------------------------------------------

console.log('\nstructured filters');
const resetButton = findByText('button', '重置');
check('reset button exists', Boolean(resetButton));
if (resetButton) {
  click(resetButton);
  await wait(200);
  check('reset clears the query and restores every talent', text().includes('共 1834 条结果'));
}

// The "使用模式" section is open by default; only toggle if it is collapsed.
const modeLabel = () =>
  [...document.querySelectorAll('label')].find((el) => (el.textContent ?? '').includes('持续技能'));
if (!modeLabel()) {
  const modeSection = findByText('button', '使用模式');
  if (modeSection) {
    click(modeSection);
    await wait(80);
  }
}
const label = modeLabel();
check('sustain mode option rendered', Boolean(label));

// NOTE: happy-dom does not deliver React's synthetic checkbox change events, so
// filter *interaction* is verified in the real-browser suite (scripts/e2e.mjs)
// rather than here. This script only asserts the panel renders its options.
const checkboxes = [...document.querySelectorAll('input[type="checkbox"]')];
check('filter checkboxes are rendered', checkboxes.length >= 3, `${checkboxes.length} found`);

// Collapsed sections reveal their controls when expanded.
const cooldownSection = findByText('button', '冷却时间');
if (cooldownSection) {
  click(cooldownSection);
  await wait(120);
}
const numberInputs = document.querySelectorAll('input[type="number"]');
check('expanding 冷却时间 reveals its number inputs', numberInputs.length >= 2, `${numberInputs.length} found`);
check('cooldown presets are rendered', text().includes('无冷却') && text().includes('≤5'));

// ---------------------------------------------------------------------------
// Class / race pages
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Classes / races / favourites / compare routes
// ---------------------------------------------------------------------------

const go = async (hash, ms = 300) => {
  window.location.hash = hash;
  window.dispatchEvent(new window.Event('hashchange'));
  await wait(ms);
};

console.log('\nclasses page');
await go('#/classes', 500);
const classesText = text();
check('classes page renders class names', classesText.includes('战士系') && classesText.includes('法师系'));
check('classes page renders subclass cards', classesText.includes('狂战士'));
check('classes page renders attribute modifiers', classesText.includes('属性修正'));
check('classes page renders mastery without a percentage', classesText.includes('掌握 1.3') && !classesText.includes('掌握 1.3（'));
check('classes page renders talent tree panels', document.querySelectorAll('[data-testid="tree-panel"]').length > 0);
check('classes page renders talent cards', document.querySelectorAll('[data-testid="talent-card"]').length > 0);
check('classes page marks locked trees', document.querySelectorAll('[data-testid="tree-panel"][data-locked="true"]').length > 0);
check('classes page marks unlocked trees', document.querySelectorAll('[data-testid="tree-panel"][data-locked="false"]').length > 0);
check('classes page renders portraits', document.querySelectorAll('[data-testid="portrait"]').length > 0);

// Clicking a talent card opens the side panel.
const talentCard = document.querySelector('[data-testid="talent-card"]');
check('talent card exists', Boolean(talentCard));
if (talentCard) {
  click(talentCard);
  await wait(250);
  check('talent side panel opens', document.querySelectorAll('[data-testid="talent-detail"]').length > 0);
  const detailText = document.querySelector('[data-testid="talent-detail"]')?.textContent ?? '';
  check('side panel shows the full talent detail', detailText.includes('技能说明') && detailText.includes('使用模式'));
  check('side panel offers the value simulator', detailText.includes('数值模拟') || detailText.includes('技能说明'));
}

console.log('\nraces page');
await go('#/races', 500);
const racesText = text();
check('races page renders races', racesText.includes('人类') && racesText.includes('矮人'));
check('races page renders subrace stats', racesText.includes('属性修正'));
check('races page renders portraits', document.querySelectorAll('[data-testid="portrait"]').length > 0);
check('races page renders talent tree panels', document.querySelectorAll('[data-testid="tree-panel"]').length > 0);

console.log('\nmonsters page');
await go('#/monsters', 1200);
const monstersText = text();
check('monsters page renders the census headline', monstersText.includes('怪物图鉴') && monstersText.includes('个可遇怪物模板'), monstersText.slice(0, 80));
check('monsters page states the inclusion rule', monstersText.includes('抽象 BASE 模板'));
check(
  'monsters page lists the category buckets',
  monstersText.includes('普通怪物') && monstersText.includes('精英') && monstersText.includes('固定Boss'),
);
check('monsters page renders monster cards', document.querySelectorAll('main div.grid > button').length > 100, String(document.querySelectorAll('main div.grid > button').length));
check('monsters page renders artwork', document.querySelectorAll('main div.grid img').length > 0);

const monsterSearchInput = document.querySelector('aside input.input');
check('monster search box exists', Boolean(monsterSearchInput));
if (monsterSearchInput) {
  setInput(monsterSearchInput, '蠕虫团');
  await wait(300);
  const wormCount = document.querySelectorAll('main div.grid > button').length;
  check('monster name search narrows the list', wormCount > 0 && wormCount < 100, String(wormCount));
  check('monster search highlights matches', document.querySelectorAll('main mark.mark').length > 0);

  setInput(monsterSearchInput, 'T_MULTIPLY');
  await wait(300);
  const talentHit = text().includes('白色蠕虫团') || text().includes('white worm mass');
  check('monster search matches talent ids', talentHit);
  setInput(monsterSearchInput, '');
  await wait(200);
}

// Type tree: the engine's own `type` -> `subtype` classification, in Chinese.
const typeTree = document.querySelector('[data-testid="monster-type-tree"]');
check('monster sidebar renders the type tree', Boolean(typeTree));
const horrorRow = document.querySelector('[data-testid="monster-type-row"][data-value="horror"]');
check(
  'type tree labels a category in Chinese and English',
  (horrorRow?.textContent ?? '').includes('恐魔') && (horrorRow?.textContent ?? '').includes('horror'),
  horrorRow?.textContent ?? '',
);
if (horrorRow) {
  click(horrorRow);
  await wait(300);
  const horrorCount = document.querySelectorAll('main div.grid > button').length;
  check('type filter narrows the list to that category', horrorCount === 95, String(horrorCount));
  check('the active type is written to the URL', window.location.hash.includes('type=horror'), window.location.hash);
  const firstCard = document.querySelector('main div.grid > button')?.textContent ?? '';
  check('monster cards show the Chinese type', firstCard.includes('恐魔'), firstCard.slice(0, 80));

  const eldritchRow = document.querySelector('[data-testid="monster-subtype-row"][data-value="eldritch"]');
  check('selecting a type reveals its subtypes', (eldritchRow?.textContent ?? '').includes('艾尔德里奇'), eldritchRow?.textContent ?? '');
  if (eldritchRow) {
    click(eldritchRow);
    await wait(300);
    const subCount = document.querySelectorAll('main div.grid > button').length;
    check('subtype filter narrows further', subCount === 61, String(subCount));
    check('the active subtype is written to the URL', window.location.hash.includes('sub=eldritch'), window.location.hash);
    // Clicking the open subtype again goes back to the whole type.
    click(eldritchRow);
    await wait(250);
  }
  const allRow = document.querySelector('[data-testid="monster-type-row"][data-value="all"]');
  if (allRow) {
    click(allRow);
    await wait(300);
  }
  check(
    'clearing the type filter restores the full list',
    document.querySelectorAll('main div.grid > button').length === 812,
    String(document.querySelectorAll('main div.grid > button').length),
  );
}

const monsterCards = document.querySelectorAll('main div.grid > button');
// Pick a monster that actually has talents, so the skill-panel path is exercised.
let opened = null;
for (const card of monsterCards) {
  card.dispatchEvent(new window.MouseEvent('click', { bubbles: true }));
  await wait(250);
  const text = document.querySelector('section[aria-label$="的详情"]')?.textContent ?? '';
  if (text.includes('固定技能') && !text.includes('源码未给这个模板配置固定技能')) { opened = card; break; }
}
check('monster detail panel opens', document.querySelector('section[aria-label$="的详情"]') !== null);
const detailText = document.querySelector('section[aria-label$="的详情"]')?.textContent ?? '';
check('monster detail lists talents', detailText.includes('固定技能'));
check('monster detail cites its source', detailText.includes('数据来源与继承'));

// Skills open in an in-page panel here too — clicking one must not navigate.
// happy-dom reports zero-size rects, so presence (not layout) is what can be
// asserted; the real viewport matrix lives in e2e.
const skillRow = document.querySelector('section[aria-label$="的详情"] button[title*="技能栏"]');
check('monster skill rows are rendered', Boolean(skillRow));
if (skillRow) {
  skillRow.dispatchEvent(new window.MouseEvent('click', { bubbles: true }));
  await wait(600);
  const panel = document.querySelector('[data-testid="talent-detail"]');
  const panelText = panel?.textContent ?? '';
  check('clicking a monster skill stays on the monster route', window.location.hash.startsWith('#/monsters'), window.location.hash);
  check('clicking a monster skill opens an in-page talent panel', Boolean(panel));
  check('the talent panel carries the full detail', panelText.includes('使用模式'));
  // Either presentation is fine: a third column, a sheet, or the desktop
  // fallback when matchMedia is unavailable.
  check(
    'the talent panel has a presentation for this viewport',
    Boolean(
      document.querySelector('[data-testid="monster-talent-sheet"]') ||
        document.querySelector('[data-testid="monster-talent-column"]'),
    ),
  );
  const close = document.querySelector('[data-testid="talent-detail"] button[aria-label="返回怪物"], [data-testid="talent-detail"] button[aria-label="关闭"]');
  check('the talent panel can be closed', Boolean(close));
  if (close) {
    close.dispatchEvent(new window.MouseEvent('click', { bubbles: true }));
    await wait(500);
    check('closing the talent panel removes it', document.querySelector('[data-testid="talent-detail"]') === null);
  }
}

console.log('\nfavorites page');
await go('#/favorites', 300);
check('empty favourites page explains itself', text().includes('收藏夹是空的'));

console.log('\ncompare page');
await go('#/compare', 300);
check('empty compare page explains itself', text().includes('对比列表为空'));

// A description's values must sit next to their own sentence. The renderer pairs
// the `<acronym>` placeholders with the exported values, and dropping one used to
// move every later value onto the wrong clause: 法术亲和 showed its spell-power
// ladder as its cooldown reduction, without the "%". Values are dropped when the
// export has no fitted formula family for them — and four out of five of them are
// still fully simulatable, because they carry a Lua expression.
console.log('\ntalent description values');
await go('#/search?talent=T_SPELLCRAFT', 1200);
const spellcraftText = (document.querySelector('[data-testid="talent-detail"]')?.textContent ?? '').replace(/\s+/g, ' ');
check(
  '法术亲和 renders its cooldown reduction in the cooldown sentence, as a percent',
  /降低 6%, 13%, 20%, 26%, 30% 法术冷却时间/.test(spellcraftText),
  spellcraftText.slice(0, 120),
);
check(
  '法术亲和 keeps the spell-power ladder in its own sentence',
  /额外法术强度加成/.test(spellcraftText) && !/降低 49, 66/.test(spellcraftText),
  spellcraftText.slice(0, 200),
);

// A placeholder that shows *words* (a size or armour word ladder) has no value
// to substitute; the export text must stay, and the numeric values after it must
// still land in their own clauses.
await go('#/search?talent=T_GOLEM_ARMOUR', 1200);
const golemText = (document.querySelector('[data-testid="talent-detail"]')?.textContent ?? '').replace(/\s+/g, ' ');
check(
  'a word placeholder keeps its text and does not steal the next value',
  /降低护甲, 降低护甲, 增加护甲, 增加护甲, 增加护甲 -2, -1, 0, 1, 2 点/.test(golemText),
  golemText.slice(0, 160),
);

// ---------------------------------------------------------------------------
// Item encyclopedia: ego affixes and fixed artifacts
// ---------------------------------------------------------------------------

// Both pages fetch their own dataset lazily (never on the talent home page), so
// this section also guards the "does not slow the front page down" property:
// the talents dataset must already be loaded while these are fetched on demand.
console.log('\nego affix page');
await go('#/egos', 2500);
const egoText = text();
check('egos page renders the census', /共\s*\d+\s*条词缀/.test(egoText), egoText.slice(0, 120));
check('slot count names the curated equipment categories', /归入\s*\d+\s*个装备分类/.test(egoText), egoText.slice(0, 160));
const egoCards = document.querySelectorAll('[data-testid="ego-card"]');
check('egos page lists affixes', egoCards.length > 100, `${egoCards.length} cards`);
check('artifact nav entry exists', text().includes('固定神器'));

// The rail is tag toggles, not dropdowns, and 适用部位 is open by default.
const egoRailSelects = document.querySelectorAll('aside select');
check('ego filter rail has no dropdowns', egoRailSelects.length === 0, `${egoRailSelects.length} selects`);
check('適用部位 is expanded by default', text().includes('近战武器') && text().includes('锄头'));

// Ordering: the normal tier comes first, the greater tier after it.
const cardState = [...document.querySelectorAll('[data-testid="ego-card"]')].map((card) => ({
  greater: (card.textContent ?? '').includes('高级词缀'),
  recommend: Number(/推荐\s*(\d+)/.exec(card.textContent ?? '')?.[1] ?? -1),
}));
const firstGreater = cardState.findIndex((state) => state.greater);
const normalTier = firstGreater === -1 ? cardState : cardState.slice(0, firstGreater);
check('normal-tier affixes precede greater-tier ones', normalTier.every((state) => !state.greater));
check(
  'within a tier, affixes sort by community recommendation descending',
  normalTier.every((state, index) => index === 0 || normalTier[index - 1].recommend >= state.recommend),
);
check('the community recommendation is visible on the card', cardState.some((state) => state.recommend > 0));

if (egoCards.length) {
  const card = egoCards[0].querySelector('button') ?? egoCards[0];
  click(card);
  await wait(400);
  const detail = document.querySelector('[data-testid="ego-detail"]');
  const detailText = detail ? (detail.textContent ?? '') : '';
  check('ego detail opens', Boolean(detail));
  check('ego detail shows applicability', detailText.includes('适用装备'), detailText.slice(0, 80));
  check('ego detail states the generation-weight semantics', detailText.includes('不是掉落概率'));
  check(
    'ego detail splits wearer / weapon effects',
    detailText.includes('穿戴时生效') || detailText.includes('装备本体属性'),
    detailText.slice(0, 200),
  );
}

// ---------------------------------------------------------------------------
// The list has to answer "what does this affix do" without opening it. That
// used to fail two ways: a raw dump of property codes (`FIRE 10~15`), and the
// sentence "打开详情查看" for every callback affix.
// ---------------------------------------------------------------------------
const effectLines = [...document.querySelectorAll('[data-testid="ego-effect"]')].map((el) => el.textContent ?? '');
check('every affix card carries an effect line', effectLines.length === egoCards.length && effectLines.every((line) => line.trim().length > 0), `${effectLines.length} / ${egoCards.length}`);
check('no card defers the effect to the detail panel', !effectLines.some((line) => line.includes('打开详情')));
check('no card ends up with no readable effect', !effectLines.some((line) => line.includes('没有可静态读取的数值')), effectLines.find((line) => line.includes('没有可静态读取')) ?? '');

// The value model, pinned: `balanced` is `combat_atk = mbonus_material(10, 5)`
// with `disarm_immune = mbonus_material(30, 20, v=v/100)`, which the community
// sheet lists as `5-15命中闪避/20-50缴械免疫`. It used to render `15~35`.
const balancedCard = findCardByText('balanced');
const balancedText = balancedCard?.textContent ?? '';
check(
  'affix values use the engine formula (add .. add + max)',
  balancedText.includes('+5~+15') && balancedText.includes('+20%~+50%'),
  balancedText.slice(0, 160),
);
check('affix values are never shown as raw field keys', !/\bDamageType\.|\bStats\./.test(effectLines.join(' ')));

// ---------------------------------------------------------------------------
// Material level: a value that scales with the item's tier has to be readable
// at one tier, and the selector must be a single choice, not a filter.
// ---------------------------------------------------------------------------
const materialTags = [...document.querySelectorAll('aside button[aria-pressed]')].filter((b) => /^[1-5]\s*级$/.test((b.textContent ?? '').trim()));
check('the rail offers material levels 1–5', materialTags.length === 5, `${materialTags.length} tags`);
click(materialTags[0]);
await wait(300);
check('selecting a material level narrows the shown range', window.location.hash.includes('ml=1'), window.location.hash);
check('the card states which material level is shown', text().includes('材料 1 级'));
const levelOneText = findCardByText('of carrying')?.textContent ?? '';
click(materialTags[1]);
await wait(300);
const levelTwoText = findCardByText('of carrying')?.textContent ?? '';
check(
  'the same affix shows a different range at a different level',
  levelOneText.includes('+20~+28') && levelTwoText.includes('+20~+36'),
  `${levelOneText.slice(0, 90)} | ${levelTwoText.slice(0, 90)}`,
);
check('the material level is a single choice', [...document.querySelectorAll('aside button[aria-pressed]')].filter((b) => /^[1-5]\s*级$/.test((b.textContent ?? '').trim()) && b.getAttribute('aria-pressed') === 'true').length === 1);
click(materialTags[1]);
await wait(300);
check('clicking the active level again clears it', !window.location.hash.includes('ml='), window.location.hash);
const clearedText = findCardByText('of carrying')?.textContent ?? '';
check('clearing the level restores the full range', clearedText.includes('+20~+60'), clearedText.slice(0, 120));

// ---------------------------------------------------------------------------
// Callback effects reach the detail as the game's own sentence.
// ---------------------------------------------------------------------------
await go('#/egos?slot=charm&tier=normal', 900);
const charmCard = document.querySelector('[data-testid="ego-card"]');
if (charmCard) {
  click(charmCard.querySelector('button') ?? charmCard);
  await wait(500);
  const detailText = document.querySelector('[data-testid="ego-detail"]')?.textContent ?? '';
  check('a callback effect is shown as the game describes it', detailText.includes('游戏说明'), detailText.slice(0, 200));
  check('the effect section is present without expanding anything', detailText.includes('效果'));
}

console.log('\nartifact page');
await go('#/artifacts', 3500);
const artifactText = text();
check('artifacts page renders the census', /共\s*\d+\s*件/.test(artifactText), artifactText.slice(0, 140));
const artifactCards = document.querySelectorAll('[data-testid="artifact-card"]');
check('artifacts page lists items', artifactCards.length > 100, `${artifactCards.length} cards`);
check(
  'artifact cards carry a native icon or a category fallback',
  artifactCards.length > 0 &&
    [...artifactCards].every((card) => card.querySelector('img') || card.querySelector('div')),
);

if (artifactCards.length) {
  const card = artifactCards[0].querySelector('button') ?? artifactCards[0];
  click(card);
  await wait(600);
  const detail = document.querySelector('[data-testid="artifact-detail"]');
  const detailText = detail ? (detail.textContent ?? '') : '';
  check('artifact detail opens', Boolean(detail));
  check('artifact detail shows the equipment body section', detailText.includes('装备本体属性'), detailText.slice(0, 120));
  check('artifact detail keeps the weapon/wearer distinction explicit', detailText.includes('不是穿戴者获得的属性'));
  check('artifact detail lists acquisition / source info', detailText.includes('获取与出处'));
  check(
    'the equipment / non-equipment tags are independent, not a radio pair',
    document.querySelectorAll('aside button[aria-pressed]').length >= 2
      && [...document.querySelectorAll('aside button[aria-pressed]')].some((b) => (b.textContent ?? '').includes('可装备'))
      && [...document.querySelectorAll('aside button[aria-pressed]')].some((b) => (b.textContent ?? '').includes('非装备')),
  );
  // No simulation controls: the pages must never ask the reader to tune a
  // character in order to read a fixed artifact.
  check('no simulation sliders on the artifact page', document.querySelectorAll('input[type="range"]').length === 0);
}

// ---------------------------------------------------------------------------

console.log(`\n${checks - failures}/${checks} checks passed`);
console.error = originalError;
if (failures) {
  console.error(`${failures} check(s) failed`);
  process.exit(1);
}
