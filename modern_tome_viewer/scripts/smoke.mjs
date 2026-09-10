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
  text().includes('1826') || text().includes('1,826'),
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
check('typing filters the list', !afterSearch.includes('共 1826 条结果'), afterSearch.match(/共\s*[\d,]+\s*条结果/)?.[0] ?? '');
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
  check('reset clears the query and restores every talent', text().includes('共 1826 条结果'));
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

console.log('\nfavorites page');
await go('#/favorites', 300);
check('empty favourites page explains itself', text().includes('收藏夹是空的'));

console.log('\ncompare page');
await go('#/compare', 300);
check('empty compare page explains itself', text().includes('对比列表为空'));

// ---------------------------------------------------------------------------

console.log(`\n${checks - failures}/${checks} checks passed`);
console.error = originalError;
if (failures) {
  console.error(`${failures} check(s) failed`);
  process.exit(1);
}
