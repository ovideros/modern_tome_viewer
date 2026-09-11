/**
 * Real-browser end-to-end test against the production build.
 *
 * Requires a static server on the app:
 *   node scripts/serve.mjs dist 4173
 * and a Chromium binary:
 *   PLAYWRIGHT_BROWSERS_PATH=../.pw-browsers node scripts/e2e.mjs
 *
 * Usage: node scripts/e2e.mjs [url] [--headed] [--shot <dir>]
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const { chromium } = require('playwright-core');

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(__dirname, '..');

const url = process.argv[2]?.startsWith('http') ? process.argv[2] : 'http://127.0.0.1:4173/';
const headed = process.argv.includes('--headed');
const shotIndex = process.argv.indexOf('--shot');
const shotDir = shotIndex >= 0 ? path.resolve(process.argv[shotIndex + 1]) : null;
if (shotDir) fs.mkdirSync(shotDir, { recursive: true });

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
const section = (title) => console.log(`\n${title}`);

const browser = await chromium.launch({ headless: !headed });
const context = await browser.newContext({ viewport: { width: 1500, height: 950 }, deviceScaleFactor: 1 });
const page = await context.newPage();

const consoleErrors = [];
const failedRequests = [];
page.on('console', (msg) => {
  if (msg.type() === 'error') consoleErrors.push(msg.text());
});
page.on('pageerror', (error) => consoleErrors.push(`pageerror: ${error.message}`));
page.on('response', (response) => {
  if (response.status() >= 400) failedRequests.push(`${response.status()} ${response.url()}`);
});

const searchInput = () => page.locator('input[placeholder*="搜索技能名"]');
const resultCount = async () => {
  const text = await page.locator('body').innerText();
  // Matches both "共 274 条结果" and the zero-result form "0 条结果".
  const match = text.match(/共\s*([\d,]+)\s*条结果|(?:^|\s)(\d+)\s*条结果/);
  if (!match) return null;
  return Number((match[1] ?? match[2]).replace(/,/g, ''));
};
const shot = async (name) => {
  if (shotDir) await page.screenshot({ path: path.join(shotDir, `${name}.png`), fullPage: false });
};
/** Section header button in the filter panel — exact text, no placeholder collisions. */
const sectionButton = (title) => page.locator('button').filter({ hasText: new RegExp(`^${title}`) }).first();
/** Checkbox option inside the filter panel. */
const optionBox = (label) =>
  page.locator('label').filter({ hasText: new RegExp(`^${label}\\s*\\d*$`) }).first().locator('input[type=checkbox]');
const resetButton = () => page.locator('button').filter({ hasText: /^重置$/ }).first();
/** Open a collapsible section, but only when its content is not already shown. */
const openSection = async (title, probe) => {
  if (probe && (await page.getByText(probe, { exact: false }).count())) return;
  const button = sectionButton(title);
  if (await button.count()) {
    await button.click();
    await page.waitForTimeout(200);
  }
};

// ---------------------------------------------------------------------------
section('initial load');
await page.goto(url, { waitUntil: 'domcontentloaded' });
// Start from a clean slate so favourites/compare assertions are deterministic.
await page.evaluate(() => {
  localStorage.removeItem('tome-favorites');
  localStorage.removeItem('tome-compare');
});
await page.reload({ waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });

check('no console errors on load', consoleErrors.length === 0, consoleErrors.slice(0, 2).join(' | '));
check('header rendered', await page.locator('text=ToME 技能查看器').first().isVisible());
const headerNav = await page.locator('header').innerText();
check('header dropped the removed browse entry', headerNav.includes('职业'));
check(
  'header exposes the two new encyclopedia entries',
  headerNav.includes('装备词缀') && headerNav.includes('固定神器'),
  headerNav.replace(/\s+/g, ' ').slice(0, 120),
);
check('default result count is every talent', (await resultCount()) === 1834, String(await resultCount()));
check('filter panel is visible', await page.locator('text=高级筛选').first().isVisible());
check('manifest line rendered', (await page.locator('body').innerText()).includes('1834 技能'));
await shot('01-initial');

// ---------------------------------------------------------------------------
section('text search');
await searchInput().fill('火焰');
await page.waitForTimeout(250);
const fireCount = await resultCount();
check('CJK query narrows the list', fireCount !== null && fireCount > 0 && fireCount < 1834, String(fireCount));
check('URL hash carries the query', page.url().includes('q='), page.url());

const firstRowText = await page.locator('[data-testid="result-row"]').first().innerText();
check('top result contains the query term', firstRowText.includes('火焰'), firstRowText.replace(/\n/g, ' | ').slice(0, 90));
check('match highlighting rendered', (await page.locator('mark.mark').count()) > 0);
await shot('02-search-fire');

await searchInput().fill('name:火焰');
await page.waitForTimeout(250);
const nameOnlyRows = await page.locator('[data-testid="result-row"]').allInnerTexts();
check(
  'field-scoped query only returns names containing the term',
  nameOnlyRows.length > 0 && nameOnlyRows.slice(0, 8).every((row) => row.split('\n')[0].includes('火焰')),
  nameOnlyRows.slice(0, 3).join(' | '),
);

await searchInput().fill('"火焰伤害"');
await page.waitForTimeout(250);
check('quoted phrase query returns hits', ((await resultCount()) ?? 0) > 0);

await searchInput().fill('zzzz-not-real');
await page.waitForTimeout(250);
check('nonsense query shows the empty state', (await page.locator('text=没有匹配的技能').count()) > 0);

await searchInput().fill('');
await page.waitForTimeout(250);
check('clearing the query restores all talents', (await resultCount()) === 1834);

// ---------------------------------------------------------------------------
section('structured filters');
await openSection('使用模式', '持续技能');
await optionBox('持续技能').check();
await page.waitForTimeout(300);
check('mode filter narrows to 274 sustains', (await resultCount()) === 274, String(await resultCount()));
check('URL hash carries the mode filter', page.url().includes('modes='), page.url());
await shot('03-mode-filter');

// Add a cooldown window on top of the mode filter.
await sectionButton('冷却时间').click();
await page.waitForTimeout(200);
await page.locator('button').filter({ hasText: /^≤5$/ }).first().click();
await page.waitForTimeout(300);
const cooldownCount = await resultCount();
check('cooldown preset narrows further', cooldownCount !== null && cooldownCount < 274, String(cooldownCount));

// Resource filter on top (sustain + mana is 54 talents overall).
await sectionButton('资源消耗').click();
await page.waitForTimeout(200);
await optionBox('法力').check();
await page.waitForTimeout(300);
const resourceCount = await resultCount();
check('resource filter narrows further', resourceCount !== null && resourceCount <= cooldownCount, String(resourceCount));
check('URL hash carries the resource filter', page.url().includes('resources='), page.url());
await shot('03b-combined-filters');

// Two filters together behave like an intersection, not a union.
await resetButton().click();
await page.waitForTimeout(250);
await optionBox('法力').check();
await page.waitForTimeout(300);
check('resource-only filter matches the dataset (184 mana talents)', (await resultCount()) === 184, String(await resultCount()));
await optionBox('持续技能').check();
await page.waitForTimeout(300);
check('mode + resource intersect (54 sustains with mana)', (await resultCount()) === 54, String(await resultCount()));

// Reset everything.
await resetButton().click();
await page.waitForTimeout(300);
check('reset restores all talents', (await resultCount()) === 1834);
check('reset clears the URL hash filters', !page.url().includes('modes='), page.url());

// The fixed-cooldown switch is a radio group of two mutually exclusive halves.
await openSection('冷却时间', '固定冷却');
const cdKind = (label) => page.locator('[aria-label="固定冷却"] button').filter({ hasText: new RegExp(`^${label}`) }).first();
check('the fixed-cooldown switch offers three states', (await page.locator('[aria-label="固定冷却"] button').count()) === 3);
await cdKind('只看固定').click();
await page.waitForTimeout(300);
check('只看固定 narrows to the 27 flagged talents', (await resultCount()) === 27, String(await resultCount()));
check('URL hash carries the fixed switch', page.url().includes('cdKind=fixed'), page.url());
check(
  'the radio is marked pressed, not just styled',
  (await page.locator('[aria-label="固定冷却"] button[aria-pressed="true"]').innerText()).includes('只看固定'),
);
await cdKind('只看非固定').click();
await page.waitForTimeout(300);
check('只看非固定 is the complement', (await resultCount()) === 1834 - 27, String(await resultCount()));
check('the two states are mutually exclusive', (await page.locator('[aria-label="固定冷却"] button[aria-pressed="true"]').count()) === 1);
// The switch is orthogonal to the numeric window: 固定 + ≤5 is a strict subset.
await cdKind('只看固定').click();
await page.waitForTimeout(300);
await page.locator('button').filter({ hasText: /^≤5$/ }).first().click();
await page.waitForTimeout(300);
const fixedShort = await resultCount();
check('the fixed switch intersects the cooldown window', fixedShort !== null && fixedShort > 0 && fixedShort < 27, String(fixedShort));
// 全部 clears only the switch — the numeric window is a separate control.
await cdKind('全部').click();
await page.waitForTimeout(300);
const cdShort = await resultCount();
check('全部 keeps the numeric window', cdShort !== null && cdShort > fixedShort, `${cdShort} vs ${fixedShort}`);
check('the switch drops out of the URL but the window stays', !page.url().includes('cdKind=') && page.url().includes('cdMax=5'), page.url());
await resetButton().click();
await page.waitForTimeout(300);
check('reset clears the fixed switch too', (await resultCount()) === 1834 && !page.url().includes('cdKind='), page.url());

// ---------------------------------------------------------------------------
section('class scope');
await page.locator('select').first().selectOption('MAGE');
await page.waitForTimeout(350);
const mageCount = await resultCount();
check('class filter returns a subset', mageCount !== null && mageCount > 0 && mageCount < 1834, String(mageCount));
const mageTrees = await page.locator('[data-testid="result-row"]').first().innerText();
check('class-scoped results render', mageTrees.length > 0);
await shot('04-class-filter');
await resetButton().click();
await page.waitForTimeout(250);

// ---------------------------------------------------------------------------
section('talent detail panel');
await searchInput().fill('火焰冲击');
await page.waitForTimeout(300);
await page.locator('[data-testid="result-row"]').first().click();
await page.waitForTimeout(300);
const detail = await page.locator('aside').first().innerText();
check('detail panel opened', detail.includes('使用模式'));
check('detail shows cooldown', detail.includes('冷却时间'));
check('detail shows the talent text', detail.includes('技能说明'));
check('detail shows requirements or flags', detail.includes('升级需求') || detail.includes('技能标记'));
check('detail shows the data source', detail.includes('数据来源'));
check('URL carries the talent id', page.url().includes('talent='), page.url());
// 火焰冲击 has an ordinary cooldown, so no "固定" marker.
check('an ordinary cooldown is not marked fixed', (await page.locator('[data-testid="fixed-cooldown"]').count()) === 0);
await shot('05-detail');

// `fixed_cooldown = true` (Actor.lua:6872 — "Can not touch this cooldown"):
// 超越永恒's 50 turns cannot be shortened by any effect, and the character sheet
// spells that out. The card must too.
await page.goto(`${url}#/search?talent=T_TIMELESS`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(800);
const timelessPanel = page.locator('[data-testid="talent-detail"]:visible').first();
const timelessText = await timelessPanel.innerText();
check('超越永恒 shows its cooldown', /冷却时间\s*50/.test(timelessText), timelessText.split('\n').slice(0, 8).join(' | '));
check('超越永恒 is marked as a fixed cooldown', /冷却时间[\s\S]{0,20}固定/.test(timelessText), timelessText.split('\n').slice(0, 8).join(' | '));
check(
  'the fixed marker explains itself',
  ((await timelessPanel.locator('[data-testid="fixed-cooldown"] .chip').getAttribute('title')) ?? '').includes('任何效果都不能增减'),
);
// 狂热's cooldown is a ladder *and* fixed — the two properties are orthogonal.
await page.goto(`${url}#/search?talent=T_DREM_FRENZY`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(800);
const frenzyText = await page.locator('[data-testid="talent-detail"]:visible').first().innerText();
check('a fixed cooldown may still be a level ladder', /44,\s*35,\s*30,\s*26,\s*24/.test(frenzyText) && /固定/.test(frenzyText), frenzyText.split('\n').slice(0, 8).join(' | '));

// Flag chip adds a filter. Target the chip itself, not the breadcrumb link.
const flagChip = page.locator('aside button:visible').filter({ hasText: /^法术$/ }).first();
if (await flagChip.count()) {
  await flagChip.click();
  await page.waitForTimeout(400);
  check('clicking a flag chip applies a filter', page.url().includes('flags='), page.url());
  await resetButton().click();
  await page.waitForTimeout(250);
}

// ---------------------------------------------------------------------------
section('value simulator');
await page.goto(`${url}#/search?talent=T_FLAMESHOCK`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(900);
const simPanel = page.locator('[data-testid="talent-detail"]:visible').first();
const detailText = await simPanel.innerText();
check('simulator section rendered', detailText.includes('数值模拟'));
const sliders = simPanel.locator('input[type=range]');
const sliderCount = await sliders.count();
check('the inputs the numbers depend on all get a slider', sliderCount >= 3, `${sliderCount} sliders`);
const sliderLabels = await sliders.evaluateAll((els) =>
  els.map((el) => el.closest('label')?.innerText.replace(/\n/g, ' ') ?? ''),
);
check(
  'slider labels are descriptive',
  ['技能等级', '技能系数', '强度'].every((needle) => sliderLabels.some((l) => l.includes(needle))),
  sliderLabels.join(' | '),
);
// Mastery is unknown on the search page, so the coefficient starts at 1.
check(
  'search page starts the coefficient at 1',
  sliderLabels.some((l) => /技能系数\s*1$/.test(l.trim())),
  sliderLabels.join(' | '),
);

const damageText = async () => {
  const text = await simPanel.innerText();
  return text.match(/共受到\s*([\d.,\s]+?)\s*点/)?.[1]?.trim() ?? '';
};
const asNumbers = (text) => JSON.stringify(text.split(',').map(Number));
// The text must show the value for the inputs the panel is showing: the search
// page starts the coefficient at 1, so the numbers start there too — not at the
// 1.50 the export was rendered with.
const baseline = await damageText();
check(
  'the text starts at the coefficient the simulator starts at',
  asNumbers(baseline) === asNumbers('153, 205, 246, 281, 312'),
  baseline,
);
// Dialling the coefficient to the export's own value must reproduce the export.
await sliders.nth(1).fill('1.5');
await page.waitForTimeout(400);
const asExported = await damageText();
check(
  'dialling the export coefficient reproduces the exported ladder',
  asNumbers(asExported) === asNumbers('181, 246, 297, 340, 378'),
  asExported,
);
await sliders.nth(1).fill('1');
await page.waitForTimeout(400);
check('returning the coefficient restores the first reading', (await damageText()) === baseline, await damageText());
// Tooltips are portalled into <body>, so read them from the document.
// Move the pointer off every trigger, so the next hover cannot read back a
// leftover tip from an earlier hover.
const resetPointer = async () => {
  await page.mouse.move(2, 2);
  await page.waitForTimeout(150);
};
const tooltipText = () => page.locator('[role="tooltip"]').last().innerText();
await resetPointer();
await simPanel.getByTestId('source-value').first().hover();
await page.waitForTimeout(300);
const sourceTooltip = await tooltipText();
check('source provenance survives the production data loader', sourceTooltip.includes('源码公式') && sourceTooltip.includes('spells/fire.lua'), sourceTooltip.replace(/\n/g, ' | ').slice(0, 120));
await resetPointer();
// The approximate fallback is rare now that most values are backed by a source
// formula — it survives only where the Lua is not in this checkout (the psionic
// addon trees). Visit one of those instead of assuming this talent has one.
await page.goto(`${url}#/search?talent=T_SHOCKSTAR`, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(900);
await page.locator('[data-testid="talent-detail"]:visible').first().getByTestId('estimated-value').first().hover();
await page.waitForTimeout(300);
check('approximate fallback is labelled in the detail', (await tooltipText()).includes('反解估算'));
await resetPointer();
await page.goto(`${url}#/search?talent=T_FLAMESHOCK`, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(900);
check('computed damage ladder rendered', /^[\d.,\s]+$/.test(baseline) && baseline.split(',').length === 5, baseline);

// Raising the power stat must raise the numbers. 150 is the top of the power
// slider — the effective stat the game's damage helpers read.
await sliders.nth(2).fill('150');
await page.waitForTimeout(400);
const boosted = await damageText();
check('raising spell power changes the numbers', boosted !== baseline, `${baseline} -> ${boosted}`);
const boostedFirst = Number(boosted.split(',')[0].trim());
// Combat.lua oracle: combatTalentSpellDamage(t=1, 10, 250) at effective
// spellpower 150. The search page leaves mastery unknown, so the coefficient
// starts at 1 and the effective talent level is 1 x 1 = 1, giving 225.
const sourceExpected = 225;
check('power slider evaluates source coefficients accurately', boostedFirst === sourceExpected, `${boostedFirst} vs ${sourceExpected}`);
const baselineFirst = Number(baseline.split(',')[0].trim());
check('raising spell power increases the value', boostedFirst > baselineFirst, `${baselineFirst} -> ${boostedFirst}`);

// The slider must cover every real character: the damage helpers read the
// *effective* combat stat, which the game's diminishing curve keeps small.
const powerRanges = await sliders.evaluateAll((els) =>
  els.map((el) => `${el.closest('label')?.innerText.replace(/\n/g, ' ')}:${el.min}..${el.max}/${el.step}`),
);
check(
  'the power slider is 1-150 and prints the raw value behind it',
  powerRanges.some((l) => l.includes('强度（有效值）') && l.includes(':1..150/1') && l.includes('原始值')),
  powerRanges.join(' | '),
);
check(
  'the power slider names the power it sets',
  powerRanges.some((l) => l.includes('法术强度（有效值）')),
  powerRanges.join(' | '),
);
check(
  'the coefficient slider spans 0.9-1.5 in tenths',
  powerRanges.some((l) => l.startsWith('技能系数') && l.includes(':0.9..1.5/0.1')),
  powerRanges.join(' | '),
);

// Lowering the coefficient must lower the numbers. The slider spans 0.9-1.5 in
// tenths, so 1.5 is the top and 0.9 the bottom.
await sliders.nth(1).fill('1.5');
await page.waitForTimeout(400);
const atTopCoefficient = Number((await damageText()).split(',')[0].trim());
await sliders.nth(1).fill('0.9');
await page.waitForTimeout(400);
const atFloorCoefficient = Number((await damageText()).split(',')[0].trim());
check(
  'the coefficient slider moves the value across its range',
  atFloorCoefficient < atTopCoefficient,
  `0.9: ${atFloorCoefficient} vs 1.5: ${atTopCoefficient}`,
);
// Leave a realistic mastery in place for the tooltip checks below.
await sliders.nth(1).fill('1.3');
await page.waitForTimeout(400);
await shot('05b-simulator');

// Tooltips explain the value. They are portalled into <body> so a clipping
// container (the detail panel is overflow-hidden) cannot cut them off.
const valueTrigger = simPanel.locator('[data-testid$="-value"]:visible').first();
check('a value trigger exists', (await valueTrigger.count()) > 0);
await resetPointer();
await valueTrigger.hover();
await page.waitForTimeout(300);
check('tooltip rendered outside the clipping panel', (await page.locator('body > [role="tooltip"]').count()) > 0);
const tip = await page.locator('body > [role="tooltip"]').first().innerText();
check(
  'tooltip names the inputs',
  tip.includes('取决于') || tip.includes('当前条件'),
  tip.replace(/\n/g, ' | ').slice(0, 90),
);
// The sliders sit at coefficient 1.3 and power 150 just above. A tooltip that
// describes the export's condition instead of the current one would say 1.5 and
// 100 — that is exactly what must not happen.
check('tooltip reports the coefficient the slider is at', tip.includes('技能系数 1.3'), tip.replace(/\n/g, ' | ').slice(0, 110));
// The sliders sit at coefficient 1.3 and power 150 just above. A tooltip that
// describes the export's condition instead of the current one would say 1.5 and
// 100 — that is exactly what must not happen. (This trigger is a source value,
// so it drops the export lines entirely; the fallback keeps them, and the
// estimated tooltip further down asserts that.)
check(
  'tooltip separates the current condition from the export one',
  tip.includes('技能系数 1.3') && !tip.includes('技能系数 1.5'),
  tip.replace(/\n/g, ' | ').slice(0, 130),
);
// The first source value in the text is the radius, which does not read power,
// so find the value that does instead of trusting their order.
await resetPointer();
const sourceValues = simPanel.getByTestId('source-value');
const sourceCount = await sourceValues.count();
let damageTip = '';
for (let index = 0; index < sourceCount; index += 1) {
  await resetPointer();
  await sourceValues.nth(index).hover();
  await page.waitForTimeout(250);
  const tip = await page.locator('body > [role="tooltip"]').first().innerText();
  if (tip.includes('法术强度')) { damageTip = tip; break; }
}
check('a source value that reads the power slider is present', damageTip.includes('法术强度 150'), `${sourceCount} source values | ${damageTip.replace(/\n/g, ' | ').slice(0, 120)}`);
check('and the coefficient on the same value', damageTip.includes('技能系数 1.3'), damageTip.replace(/\n/g, ' | ').slice(0, 110));
// A source value needs no export reference: the formula already defines it.
check(
  'a source value tooltip drops the redundant export lines',
  !damageTip.includes('导出参考值') && !damageTip.includes('导出条件'),
  damageTip.replace(/\n/g, ' | ').slice(0, 130),
);
await resetPointer();
// Same reason as above: the export reference only survives on the fallback,
// which now exists only where the Lua is missing from this checkout.
await page.goto(`${url}#/search?talent=T_SHOCKSTAR`, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(900);
await page.locator('[data-testid="talent-detail"]:visible').first().getByTestId('estimated-value').first().hover();
await page.waitForTimeout(300);
const estimatedTip = await page.locator('body > [role="tooltip"]').first().innerText();
check(
  'an estimated value keeps its export reference',
  estimatedTip.includes('导出参考值') && estimatedTip.includes('导出条件'),
  estimatedTip.replace(/\n/g, ' | ').slice(0, 130),
);

const tipBox = await page.evaluate(() => {
  const tip = document.querySelector('body > [role="tooltip"]');
  if (!tip) return null;
  const b = tip.getBoundingClientRect();
  const panel = document.querySelector('[data-testid="talent-detail"]');
  const p = panel?.getBoundingClientRect();
  return {
    insideViewport: b.top >= -1 && b.left >= -1 && b.right <= window.innerWidth + 1 && b.bottom <= window.innerHeight + 1,
    // The old bug: the tip was confined to the panel, so it could not exceed it.
    widerThanPanel: p ? b.width >= p.width * 0.5 : true,
    panelClipped: p ? b.left >= p.left && b.right <= p.right : false,
  };
});
check('tooltip fits in the viewport', tipBox?.insideViewport === true, JSON.stringify(tipBox));
check('tooltip is not confined to the detail panel', tipBox?.panelClipped === false, JSON.stringify(tipBox));

// ---------------------------------------------------------------------------
section('mastery-derived coefficient');
// Viewing a talent through its class must start the coefficient at that tree's
// mastery, because the game multiplies the raw talent level by mastery.
await page.goto(`${url}#/classes`, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(1500);
const bulwarkSection = page.locator('section[id="subclass-BULWARK"]');
const bulwarkHeader = await bulwarkSection.locator('[data-testid="tree-panel"]').first().innerText();
check('Bulwark first tree shows mastery 1.3', bulwarkHeader.includes('掌握 1.3'), bulwarkHeader.split('\n').slice(0, 2).join(' | '));
await bulwarkSection.locator('[data-testid="talent-card"]').first().click();
await page.waitForTimeout(600);
const classSliders = await page
  .locator('[data-testid="talent-detail"]:visible input[type=range]')
  .evaluateAll((els) => els.map((el) => el.closest('label')?.innerText.replace(/\n/g, ' ') ?? ''));
check(
  'class page starts the coefficient at the tree mastery',
  classSliders.some((l) => /技能系数\s*1\.3$/.test(l.trim())),
  classSliders.join(' | '),
);
// ...and the text must be showing that same coefficient, so the tooltip reports
// the mastery rather than the export's own 1.50.
await resetPointer();
await page
  .locator('[data-testid="talent-detail"]:visible [data-testid="source-value"], [data-testid="talent-detail"]:visible [data-testid="estimated-value"]')
  .first()
  .hover();
await page.waitForTimeout(300);
const classTip = await page.locator('body > [role="tooltip"]').first().innerText();
check('class page tooltip reports the mastery the sliders show', /技能系数 1\.3/.test(classTip), classTip.replace(/\n/g, ' | ').slice(0, 110));
await shot('16-mastery-coefficient');

// ---------------------------------------------------------------------------
// A talent capped at one point has no talent-level dimension to explore.
await page.goto(`${url}#/search?talent=T_HUNTED_PLAYER`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(800);
const onePointSliders = await page
  .locator('[data-testid="talent-detail"]:visible input[type=range]')
  .evaluateAll((els) => els.map((el) => el.closest('label')?.innerText.replace(/\n/g, ' ') ?? ''));
check(
  'a one-point talent offers no talent-level slider',
  !onePointSliders.some((l) => l.includes('技能等级')),
  onePointSliders.join(' | '),
);
check('its real axis still gets a slider', onePointSliders.some((l) => l.includes('角色等级')), onePointSliders.join(' | '));

// Before any slider is touched the text still shows the export's ladder.
const onePointPanel = page.locator('[data-testid="talent-detail"]:visible').first();
const radiusOf = async () => {
  const raw = (await onePointPanel.innerText()).match(/半径([\s\S]{0,80}?)的怪/)?.[1] ?? '';
  return raw.replace(/\s+/g, ' ').replace(/\s*,\s*/g, ', ').trim();
};
check(
  'a one-point talent reads as a single value from the start',
  (await radiusOf()) === '10',
  await radiusOf(),
);

const onePointCharSlider = onePointPanel
  .locator('input[type=range]')
  .nth(onePointSliders.findIndex((l) => l.includes('角色等级')));
await onePointCharSlider.fill('25');
await page.waitForTimeout(400);
const collapsed = await radiusOf();
check(
  'selecting an axis value collapses the ladder to one number',
  /^15$/.test(collapsed),
  collapsed,
);

// A slider position the export never sampled must still be computed, not
// silently snapped back to the ladder: at character level 24 the game prints
// `%d` of 10 + 24/5, which truncates to 14.
await onePointCharSlider.fill('24');
await page.waitForTimeout(400);
const offLadder = await radiusOf();
check('an unsampled slider position is computed, not snapped to the ladder', offLadder === '14', offLadder);
await resetPointer();
await onePointPanel.locator('[data-testid$="-value"]').first().hover();
await page.waitForTimeout(300);
const offLadderTip = await page.locator('body > [role="tooltip"]').first().innerText();
check('its tooltip names the unsampled condition too', offLadderTip.includes('角色等级 24'), offLadderTip.replace(/\n/g, ' | ').slice(0, 110));
check('and never falls back to the export ladder', !/取决于/.test(offLadderTip), offLadderTip.replace(/\n/g, ' | ').slice(0, 110));
await onePointCharSlider.fill('25');
await page.waitForTimeout(400);

// The tooltip must describe the selected condition, not the export's ladder.
const onePointTrigger = onePointPanel.locator('[data-testid$="-value"]').first();
await resetPointer();
await onePointTrigger.hover();
await page.waitForTimeout(300);
const onePointTip = await page.locator('body > [role="tooltip"]').first().innerText();
check('tooltip names the selected condition', onePointTip.includes('当前条件') && onePointTip.includes('角色等级 25'), onePointTip.replace(/\n/g, ' | ').slice(0, 110));
check('tooltip no longer presents the export ladder as the condition', !/取决于：角色等级 1\/10\/25/.test(onePointTip), onePointTip.replace(/\n/g, ' | ').slice(0, 110));
// 被捕猎's radius comes from validated source, so its tooltip carries the
// formula and the provenance instead of repeating the export's own ladder.
check('tooltip reports the source instead of the export', onePointTip.includes('源码公式') && onePointTip.includes('misc.lua'), onePointTip.replace(/\n/g, ' | ').slice(0, 110));
check('and leaves the export reference out', !onePointTip.includes('导出参考值'), onePointTip.replace(/\n/g, ' | ').slice(0, 110));

// A five-level talent keeps five distinct values, and its tooltip tracks the
// selected level.
await page.goto(`${url}#/search?talent=T_FLAMESHOCK`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(800);
const multiPanel = page.locator('[data-testid="talent-detail"]:visible').first();
await multiPanel.locator('input[type=range]').first().fill('3');
await page.waitForTimeout(400);
const multiDamage = await multiPanel.innerText();
const multiLadder = multiDamage.match(/共受到([\s\S]{0,60}?)点/)?.[1]?.replace(/\s*,\s*/g, ', ').replace(/\s+/g, ' ').trim() ?? '';
check('a five-level talent still shows five values', multiLadder.split(',').length === 5, multiLadder);
check(
  'its ladder is computed at the current coefficient, not the exported 1.50',
  asNumbers(multiLadder) === asNumbers('153, 205, 246, 281, 312'),
  multiLadder,
);
await resetPointer();
await multiPanel.locator('[data-testid$="-value"]').nth(1).hover();
await page.waitForTimeout(350);
const multiTip = await page.locator('[role="tooltip"]').last().innerText();
check('its tooltip names the selected talent level', multiTip.includes('当前条件') && multiTip.includes('技能等级 3'), multiTip.replace(/\n/g, ' | ').slice(0, 110));
check('its tooltip reports the source formula and location', multiTip.includes('源码公式') && multiTip.includes('spells/fire.lua'), multiTip.replace(/\n/g, ' | ').slice(0, 110));
await shot('17-dynamic-tooltip');

// ---------------------------------------------------------------------------
section('per-power sliders');
// 腐朽之地 takes max(spell damage, mind damage): with one shared slider the two
// branches always agreed, so the value could never follow the stronger power.
await page.goto(`${url}#/search?talent=T_DECAYING_GROUNDS`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(800);
const decayPanel = page.locator('[data-testid="talent-detail"]:visible').first();
const decaySliders = await decayPanel
  .locator('input[type=range]')
  .evaluateAll((els) => els.map((el) => el.closest('label')?.innerText.replace(/\n/g, ' ') ?? ''));
check(
  'each power a value reads gets its own slider',
  decaySliders.some((l) => l.includes('法术强度')) && decaySliders.some((l) => l.includes('精神强度')),
  decaySliders.join(' | '),
);
const decayValue = async () =>
  Number((await decayPanel.locator('[data-testid$="-value"]').first().innerText()).split(',')[0].replace(/[^\d.]/g, ''));
const decayIndex = (needle) => decaySliders.findIndex((l) => l.includes(needle));
const decayAtRest = await decayValue();
await decayPanel.locator('input[type=range]').nth(decayIndex('精神强度')).fill('150');
await page.waitForTimeout(400);
const mindBoosted = await decayValue();
await decayPanel.locator('input[type=range]').nth(decayIndex('精神强度')).fill('100');
await decayPanel.locator('input[type=range]').nth(decayIndex('法术强度')).fill('150');
await page.waitForTimeout(400);
const spellBoosted = await decayValue();
check(
  'raising either power raises the value, symmetrically',
  mindBoosted > decayAtRest && mindBoosted === spellBoosted,
  `${decayAtRest} / mind 150: ${mindBoosted} / spell 150: ${spellBoosted}`,
);

// 饥荒挽歌 renders its ladder at character level 50 while varying the talent
// level, so 角色等级 must appear as a pinned, adjustable input.
await page.goto(`${url}#/search?talent=T_DIRGE_OF_FAMINE`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(800);
const dirgeSliders = await page
  .locator('[data-testid="talent-detail"]:visible input[type=range]')
  .evaluateAll((els) => els.map((el) => el.closest('label')?.innerText.replace(/\n/g, ' ') ?? ''));
check(
  'a title-pinned character level is adjustable',
  dirgeSliders.some((l) => /角色等级\s*50/.test(l)),
  dirgeSliders.join(' | '),
);

// ---------------------------------------------------------------------------
section('paradox modifier');
// Paradox has no cap, but PMod — bound(sqrt(paradox/300), 0.5, 1.5) — saturates
// at +50% when paradox reaches 675, so the slider stops there.
await page.goto(`${url}#/search?talent=T_ASHES_TO_ASHES`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(800);
const paradoxPanel = page.locator('[data-testid="talent-detail"]:visible').first();
const paradoxRows = await paradoxPanel
  .locator('input[type=range]')
  .evaluateAll((els) => els.map((el) => `${el.closest('label')?.innerText.replace(/\n/g, ' ')} [${el.min}..${el.max}]`));
check(
  'the paradox slider covers the range PMod actually uses',
  paradoxRows.some((l) => l.startsWith('paradox') && l.includes('[0..675]')),
  paradoxRows.join(' | '),
);
const paradoxSlider = paradoxPanel.locator('input[type=range]').nth(paradoxRows.findIndex((l) => l.startsWith('paradox')));
const paradoxDamage = async () =>
  Number((await paradoxPanel.locator('[data-testid$="-value"]').nth(1).innerText()).split(',')[0]);
await paradoxSlider.fill('300');
await page.waitForTimeout(350);
const atBalance = await paradoxDamage();
const balanceHint = await paradoxPanel.getByTestId('input-hint').innerText();
await paradoxSlider.fill('675');
await page.waitForTimeout(350);
const atCap = await paradoxDamage();
const capHint = await paradoxPanel.getByTestId('input-hint').innerText();
check('300 paradox is the balance point (PMod x1.00)', balanceHint.includes('×1.00'), balanceHint);
check('675 paradox is the cap (PMod x1.50)', capHint.includes('×1.50'), capHint);
check(
  'raising paradox multiplies the value by PMod',
  Math.abs(atCap / atBalance - 1.5) < 0.02,
  `300: ${atBalance} -> 675: ${atCap}`,
);

// ---------------------------------------------------------------------------
section('wrapped acronym text');
// Some export entries wrap more than a bare list in one <acronym>: a leading
// sign, a unit, or a whole repeated sentence fragment. Reading the "suffix" as
// everything that is not a number turned 侦查圣诗's "+16, +22, …" into
// "16+++++" and repeated 饥荒挽歌's sentence five times over.
const firstValue = () =>
  page.locator('[data-testid="talent-detail"]:visible [data-testid$="-value"]').first().innerText();
const textOf = async (id) => {
  await page.goto(`${url}#/search?talent=${id}`, { waitUntil: 'domcontentloaded' });
  await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
  await page.waitForTimeout(600);
  return (await firstValue()).replace(/\s+/g, ' ').trim();
};
const signed = await textOf('T_HYMN_OF_DETECTION');
check('a leading sign is kept, once per value', /^(\+\d+, ){4}\+\d+$/.test(signed), signed.slice(0, 90));
const sentence = await textOf('T_DIRGE_OF_FAMINE');
check(
  'a sentence wrapped around the values is not repeated inside each value',
  (sentence.match(/增加你的生命回复/g) ?? []).length === 5 && !sentence.includes('加成。增加'),
  sentence.slice(0, 120),
);

// ---------------------------------------------------------------------------
section('axis sliders');
// 被捕猎's numbers scale with character level, not talent level: the export
// lists them for character levels 1/10/25/40/50. The reader must be able to dial
// that input, so a 角色等级 slider has to appear and drive the text.
await page.goto(`${url}#/search?talent=T_HUNTED_PLAYER`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(900);
const axisPanel = page.locator('[data-testid="talent-detail"]:visible').first();
const axisLabels = await axisPanel.locator('input[type=range]').evaluateAll((els) =>
  els.map((el) => el.closest('label')?.innerText.replace(/\n/g, ' ') ?? ''),
);
check('a character-level slider appears for character-scaled values', axisLabels.some((l) => l.includes('角色等级')), axisLabels.join(' | '));

const radiusLadder = async () => {
  const text = await axisPanel.innerText();
  const raw = text.match(/半径([\s\S]{0,80}?)的怪/)?.[1] ?? '';
  // The ladder renders as "20\n, 20": collapse whitespace first, then normalise
  // the commas, so the result is exactly "20, 20, 20, 20, 20".
  return raw.replace(/\s+/g, ' ').replace(/\s*,\s*/g, ', ').trim();
};
const charSlider = axisPanel.locator('input[type=range]').nth(axisLabels.findIndex((l) => l.includes('角色等级')));
await charSlider.fill('1');
await page.waitForTimeout(350);
const atLevel1 = await radiusLadder();
check(
  'character level 1 collapses to the exported first value',
  atLevel1 === '10',
  atLevel1,
);
await charSlider.fill('50');
await page.waitForTimeout(350);
const atLevel50 = await radiusLadder();
check('character level 50 recomputes from the source formula', atLevel50 === '20', atLevel50);
check('the two levels really differ', atLevel1 !== atLevel50, `${atLevel1} vs ${atLevel50}`);
// The untruncated reference ladder is only for the exported inputs, so at the
// exported first character level the collapsed value must equal its first entry.
check('the collapsed value sits on the exported ladder', atLevel1 === '10' && atLevel50 === '20');
await shot('15-axis-slider');

// ---------------------------------------------------------------------------
section('scroll behaviour');
await page.goto(`${url}#/classes`, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(1200);
await page.evaluate(() => window.scrollTo(0, 1400));
await page.waitForTimeout(200);
check('page is scrolled before switching', (await page.evaluate(() => window.scrollY)) > 500);
await page.locator('aside button').filter({ hasText: /^法师系/ }).first().click();
await page.waitForTimeout(600);
check('switching class scrolls back to the top', (await page.evaluate(() => window.scrollY)) === 0, String(await page.evaluate(() => window.scrollY)));

// Sidebar subclass link must land below the sticky header, not underneath it.
await page.locator('aside button').filter({ hasText: /^元素法师$/ }).first().click();
await page.waitForTimeout(900);
const landing = await page.evaluate(() => {
  // Find the card whose heading is the subclass we navigated to.
  const card = [...document.querySelectorAll('section[id^="subclass-"]')].find((el) =>
    el.querySelector('h2')?.textContent.includes('元素法师'),
  );
  const header = document.querySelector('header');
  if (!card) return null;
  return { cardTop: Math.round(card.getBoundingClientRect().top), headerBottom: Math.round(header.getBoundingClientRect().bottom) };
});
check('subclass anchor lands below the sticky header', landing !== null && landing.cardTop >= landing.headerBottom - 2, JSON.stringify(landing));

// Search page: the sticky bar must not cover the filter panel or the detail panel.
await page.goto(`${url}#/search?talent=T_FLAMESHOCK`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.evaluate(() => window.scrollTo(0, 900));
await page.waitForTimeout(500);
const overlap = await page.evaluate(() => {
  const bar = document.querySelector('input[placeholder*="搜索技能名"]').closest('div.sticky').getBoundingClientRect();
  const filterHeading = [...document.querySelectorAll('h2')].find((h) => h.textContent.includes('高级筛选'))?.getBoundingClientRect();
  const detailHeading = document.querySelector('[data-testid="talent-detail"] h2')?.getBoundingClientRect();
  return { barBottom: Math.round(bar.bottom), filterTop: filterHeading ? Math.round(filterHeading.top) : null, detailTop: detailHeading ? Math.round(detailHeading.top) : null };
});
check('filter panel is not covered by the sticky search bar', overlap.filterTop === null || overlap.filterTop >= overlap.barBottom, JSON.stringify(overlap));
check('detail panel is not covered by the sticky search bar', overlap.detailTop === null || overlap.detailTop >= overlap.barBottom, JSON.stringify(overlap));

// ---------------------------------------------------------------------------
// Clicking the tree breadcrumb in the detail panel narrows the search to it.
const breadcrumb = page.locator('aside button').filter({ hasText: /^法术 \/ / }).first();
if (await breadcrumb.count()) {
  await breadcrumb.click();
  await page.waitForTimeout(500);
  check('tree breadcrumb filters the search by that tree', page.url().includes('trees='), page.url());
  await resetButton().click();
  await page.waitForTimeout(250);
}

// Deep link into a talent.
await page.goto(`${url}#/search?talent=T_FIRE_STORM`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(300);
check('deep link opens the talent detail', (await page.locator('aside').first().innerText()).includes('火焰风暴'));

// ---------------------------------------------------------------------------
section('classes page');
await page.goto(`${url}#/classes`, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(900);
const classesText = await page.locator('body').innerText();
check('classes sidebar lists every class', classesText.includes('战士系') && classesText.includes('法师系'));
check('subclass cards rendered', (await page.locator('section[id^="subclass-"]').count()) > 0);
const subclassCount = await page.locator('section[id^="subclass-"]').count();
check('first class shows 5 subclasses', subclassCount === 5, String(subclassCount));
check('attribute modifiers rendered', classesText.includes('属性修正'));
check('life rating chip rendered', classesText.includes('每级生命'));
check('initial talents rendered', classesText.includes('初始技能'));
check('portraits rendered', (await page.locator('[data-testid="portrait"]').count()) > 0);
check(
  'portrait images actually loaded',
  await page.evaluate(() =>
    [...document.querySelectorAll('[data-testid="portrait"]')].every(
      (img) => img.complete && img.naturalWidth > 0,
    ),
  ),
);
check('mastery shown without a percentage', !/掌握\s*1\.3（/.test(classesText) && classesText.includes('掌握 1.3'));
check('talent tree panels rendered', (await page.locator('[data-testid="tree-panel"]').count()) > 0);
const treePanels = await page.locator('[data-testid="tree-panel"]').count();
check('every class/generic tree of the first subclass is listed', treePanels >= 11, String(treePanels));
check('talent cards rendered inside trees', (await page.locator('[data-testid="talent-card"]').count()) > 0);
check('locked trees are visually marked', (await page.locator('[data-testid="tree-panel"][data-locked="true"]').count()) > 0);
check('unlocked trees are visually marked', (await page.locator('[data-testid="tree-panel"][data-locked="false"]').count()) > 0);
check('lock badge text rendered', classesText.includes('未解锁'));
check('unlocked counter rendered', /\d+\/\d+ 个大系已解锁/.test(classesText), classesText.match(/\d+\/\d+ 个大系已解锁/)?.[0] ?? '');
await shot('10-classes');

// Regression: Bulwark's three generic trees are unlocked in game.
const bulwark = page.locator('section[id="subclass-BULWARK"]');
check('Bulwark card found', (await bulwark.count()) > 0);
if (await bulwark.count()) {
  const bulwarkText = await bulwark.innerText();
  check(
    'Bulwark generic trees are not marked locked',
    ['生存', '战斗训练', '体质强化'].every((name) => {
      const panel = page.locator('[data-testid="tree-panel"]', { hasText: name }).first();
      return panel.getAttribute('data-locked') !== 'true';
    }),
    bulwarkText.slice(0, 120),
  );
  const lockedInBulwark = await bulwark.locator('[data-testid="tree-panel"][data-locked="true"]').count();
  check('Bulwark has exactly 4 locked class trees', lockedInBulwark === 4, String(lockedInBulwark));
}

// Clicking a talent opens the right-hand panel.
const talentCard = page.locator('[data-testid="talent-card"]').first();
check('talent card clickable', (await talentCard.count()) > 0);
if (await talentCard.count()) {
  await talentCard.click();
  await page.waitForTimeout(400);
  const side = page.locator('[data-testid="talent-detail"]').first();
  check('talent side panel opens', (await side.count()) > 0);
  const sideText = await side.innerText();
  check('side panel shows the talent text', sideText.includes('技能说明'));
  check('side panel shows the same sections as the search page', ['使用模式', '冷却时间', '升级需求', '技能标记', '数据来源'].every((s) => sideText.includes(s)));
  await shot('10b-class-talent');
}

// Selecting a class in the sidebar updates the URL.
const mageButton = page.locator('aside button:visible').filter({ hasText: /^法师系/ }).first();
check('class sidebar entry for 法师系 exists', (await mageButton.count()) > 0);
if (await mageButton.count()) {
  await mageButton.click();
  await page.waitForTimeout(500);
  check('selecting a class updates the URL', page.url().includes('class=MAGE'), page.url());
  check('selected class shows its subclasses', (await page.locator('body').innerText()).includes('元素法师'));
}

// Deep link straight to a class.
await page.goto(`${url}#/classes?class=ROGUE`, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(800);
check('class deep link works', (await page.locator('body').innerText()).includes('盗贼'));

// "Filter search by this class" jumps to the search page with the class filter.
const classSearchButton = page.locator('button').filter({ hasText: '在搜索中按此职业筛选' }).first();
check('class page offers a "filter search by class" shortcut', (await classSearchButton.count()) > 0);
if (await classSearchButton.count()) {
  await classSearchButton.click();
  await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
  await page.waitForTimeout(400);
  check('class search shortcut applies the class filter', page.url().includes('class=ROGUE'), page.url());
  check('class-filtered search shows results', ((await resultCount()) ?? 0) > 0);
}

// ---------------------------------------------------------------------------
section('races page');
await page.goto(`${url}#/races`, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(900);
const racesText = await page.locator('body').innerText();
check('races sidebar lists races', racesText.includes('人类') && racesText.includes('矮人'));
check('subrace cards rendered', (await page.locator('section[id^="subrace-"]').count()) > 0);
check('subrace stats rendered', racesText.includes('属性修正'));
check('race portraits rendered', (await page.locator('[data-testid="portrait"]').count()) > 0);
check(
  'race portrait images actually loaded',
  await page.evaluate(() =>
    [...document.querySelectorAll('[data-testid="portrait"]')].every(
      (img) => img.complete && img.naturalWidth > 0,
    ),
  ),
);
check('race talent trees rendered', (await page.locator('[data-testid="tree-panel"]').count()) > 0);
check('race talent cards rendered', (await page.locator('[data-testid="talent-card"]').count()) > 0);
await shot('11-races');

const elfButton = page.locator('aside button:visible').filter({ hasText: /^精灵/ }).first();
check('race sidebar entry for 精灵 exists', (await elfButton.count()) > 0);
if (await elfButton.count()) {
  await elfButton.click();
  await page.waitForTimeout(500);
  check('selecting a race updates the URL', page.url().includes('race=ELF'), page.url());
}

// Race talent cards open the same right-hand panel.
const raceTalent = page.locator('[data-testid="talent-card"]').first();
if (await raceTalent.count()) {
  await raceTalent.click();
  await page.waitForTimeout(400);
  check('race talent side panel opens', (await page.locator('[data-testid="talent-detail"]').count()) > 0);

  // The same portalled tooltip must escape this panel too.
  const raceTrigger = page.locator('[data-testid="talent-detail"]:visible [data-testid$="-value"]').first();
  if (await raceTrigger.count()) {
    await resetPointer();
    await raceTrigger.hover();
    await page.waitForTimeout(300);
    const box = await page.evaluate(() => {
      const tip = document.querySelector('body > [role="tooltip"]');
      if (!tip) return null;
      const b = tip.getBoundingClientRect();
      const panel = document.querySelector('[data-testid="talent-detail"]')?.getBoundingClientRect();
      return {
        inside: b.top >= -1 && b.left >= -1 && b.right <= window.innerWidth + 1 && b.bottom <= window.innerHeight + 1,
        confined: panel ? b.left >= panel.left && b.right <= panel.right : null,
      };
    });
    check('race page tooltip escapes its panel', box?.inside === true && box?.confined === false, JSON.stringify(box));
  }
}

// ---------------------------------------------------------------------------
section('monsters page');

const monsterCards = () => page.locator('main div.grid > button');
/** Count rendered monster cards straight from the DOM, avoiding locator staleness. */
const monsterCardCount = () => page.evaluate(() => document.querySelectorAll('main div.grid > button').length);
const monsterSearch = () => page.locator('aside input.input');

await page.goto(`${url}#/monsters`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('怪物图鉴'), null, { timeout: 30000 });
await page.waitForTimeout(600);

const monstersBody = await page.locator('body').innerText();
check('header exposes the monsters entry', (await page.locator('header').innerText()).includes('怪物'));
check('census headline states the inclusion rule', monstersBody.includes('个可遇怪物模板') && monstersBody.includes('抽象 BASE 模板'));
check(
  'category counts are rendered',
  /普通怪物\s*447/.test(monstersBody) && /精英\s*176/.test(monstersBody) && /固定Boss\s*98/.test(monstersBody),
);
check('every concrete template is listed', (await monsterCardCount()) === 812, String(await monsterCardCount()));
check('monster artwork rendered', (await page.locator('main div.grid img').count()) > 0);
await shot('10-monsters');

// Chinese name search.
await monsterSearch().fill('蠕虫团');
await page.waitForTimeout(400);
const wormCards = await monsterCards().allInnerTexts();
check('Chinese name search narrows to the worm masses', wormCards.length > 0 && wormCards.length < 40, String(wormCards.length));
check('Chinese search highlights the match', (await page.locator('main mark.mark').count()) > 0);

// Talent search must hit the fixed configuration as well as random groups.
await monsterSearch().fill('T_MULTIPLY');
await page.waitForTimeout(400);
const multiplyCards = await monsterCards().allInnerTexts();
check(
  'talent-id search finds the worm masses',
  multiplyCards.some((card) => card.includes('白色蠕虫团') || card.includes('white worm mass')),
  multiplyCards.slice(0, 3).join(' | '),
);
await monsterSearch().fill('T_CALL_OF_THE_CRYPT');
await page.waitForTimeout(400);
const necroCards = await monsterCards().allInnerTexts();
check(
  'talent search also matches random skill groups',
  necroCards.some((card) => card.includes('兽人死灵法师')),
  necroCards.slice(0, 3).join(' | '),
);

// Zero results.
await monsterSearch().fill('zzzz-no-such-monster');
await page.waitForTimeout(400);
check('zero-result state is explicit', (await page.locator('body').innerText()).includes('没有匹配的怪物'));
await monsterSearch().fill('');
await page.waitForTimeout(400);

// Sidebar type tree: broad category (`type`) -> subtype, in Chinese. The labels
// come from the game's own `entity type` / `entity subtype` tables.
const typeRow = (value) => page.locator(`[data-testid="monster-type-row"][data-value="${value}"]`);
const subtypeRow = (value) => page.locator(`[data-testid="monster-subtype-row"][data-value="${value}"]`);
check('type tree renders Chinese categories', (await typeRow('horror').innerText()).includes('恐魔'), await typeRow('horror').innerText());
await typeRow('horror').click();
await page.waitForFunction(() => document.querySelectorAll('main div.grid > button').length === 95, null, { timeout: 15000 });
await page.waitForTimeout(300);
check('type filter lists every horror template', (await monsterCardCount()) === 95, String(await monsterCardCount()));
check('type filter is written to the URL', page.url().includes('type=horror'), page.url());
check('the result line names the active category', (await page.locator('[data-testid="monster-type-filter"]').innerText()).includes('恐魔'));
check(
  'cards chip the Chinese type',
  (await monsterCards().first().innerText()).includes('恐魔'),
  (await monsterCards().first().innerText()).slice(0, 80),
);
await subtypeRow('eldritch').click();
await page.waitForFunction(() => document.querySelectorAll('main div.grid > button').length === 61, null, { timeout: 15000 });
await page.waitForTimeout(300);
check('subtype filter narrows to eldritch', (await monsterCardCount()) === 61, String(await monsterCardCount()));
check('subtype filter is written to the URL', page.url().includes('sub=eldritch'), page.url());
check('the result line names the active subtype', (await page.locator('[data-testid="monster-type-filter"]').innerText()).includes('艾尔德里奇'));
await shot('14-monster-type-tree');
await typeRow('all').click();
await page.waitForFunction(() => document.querySelectorAll('main div.grid > button').length === 812, null, { timeout: 15000 });
check('clearing the type filter restores the full list', (await monsterCardCount()) === 812, String(await monsterCardCount()));

// The filter is part of the shareable URL.
await page.goto(`${url}#/monsters?type=horror&sub=eldritch`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.querySelectorAll('main div.grid > button').length === 61, null, { timeout: 15000 });
check('deep link restores the type filter', (await monsterCardCount()) === 61, String(await monsterCardCount()));
check('deep link marks the active subtype row', (await subtypeRow('eldritch').getAttribute('aria-pressed')) === 'true');
await page.goto(`${url}#/monsters`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.querySelectorAll('main div.grid > button').length === 812, null, { timeout: 15000 });

// Detail panel: the orc necromancer is the handover's worked example.
await monsterCards().filter({ hasText: '兽人死灵法师' }).first().click();
await page.waitForTimeout(500);
const detailPanel = page.locator('section[aria-label$="的详情"]:visible').first();
const necroDetail = await detailPanel.innerText();
check('detail panel opens', (await detailPanel.count()) === 1);
check('fixed talents listed', necroDetail.includes('固定技能') && necroDetail.includes('T_HIEMAL_SHIELD'));
check('base=0 growth is spelled out', necroDetail.includes('初始 0 级'), necroDetail.slice(0, 200));
check('mutually exclusive groups are grouped and explained', necroDetail.includes('技能组 4') && necroDetail.includes('互斥'));
check('detail records the defining source file', necroDetail.includes('数据来源与继承') || necroDetail.includes('orc-rak-shor.lua'));

// Clicking a skill opens it in a panel *beside* the monster (>= 1800px) or in a
// bottom sheet (>= 1280px) — it must not navigate away from the monster.
await detailPanel.locator('button:has-text("↗")').first().click();
await page.waitForTimeout(900);
const visibleTalentPanel = () => page.locator('[data-testid="talent-detail"]:visible');
check('clicking a monster talent stays on the monster route', page.url().includes('#/monsters'), page.url());
check('talent panel renders without navigating', (await visibleTalentPanel().count()) === 1);
check('monster panel stays visible beside the talent', await detailPanel.isVisible());
check(
  'talent panel carries the full detail',
  (await visibleTalentPanel().first().innerText()).includes('使用模式'),
);
check(
  'the open talent is marked in the monster skill list',
  (await page.locator('section[aria-label$="的详情"] button[aria-pressed="true"][title*="技能栏"]').count()) > 0,
);
await shot('13-monster-talent-panel');

// Closing the talent must leave the monster panel in place.
await visibleTalentPanel().first().locator('button[title^="关闭"]').click();
await page.waitForTimeout(500);
check('closing the talent panel keeps the monster open', (await visibleTalentPanel().count()) === 0 && (await detailPanel.isVisible()));

// From 1280px up the talent is a third column, and the list pays for it by
// dropping to a single card column. It used to need 1800px.
await page.setViewportSize({ width: 1500, height: 950 });
await page.waitForTimeout(300);
await page.locator('section[aria-label$="的详情"]:visible button[title*="技能栏"]').first().click();
await page.waitForTimeout(700);
const sheetState = () => page.evaluate(() => {
  const rect = (q) => {
    const el = document.querySelector(q);
    if (!el) return null;
    const r = el.getBoundingClientRect();
    return r.width > 0 && r.height > 0;
  };
  const list = document.querySelector('main');
  const grid = document.querySelector('main div.grid');
  return {
    sheet: rect('[data-testid="monster-talent-sheet"]'),
    column: rect('[data-testid="monster-talent-column"]'),
    monsterSheet: rect('[data-testid="monster-detail-sheet"]'),
    // How many card columns the list is actually rendering, and how wide it is.
    cardColumns: grid ? getComputedStyle(grid).gridTemplateColumns.split(' ').length : 0,
    listWidth: list ? Math.round(list.getBoundingClientRect().width) : 0,
    monsterSections: [...document.querySelectorAll('section[aria-label$="的详情"]')].filter((el) => {
      const r = el.getBoundingClientRect();
      return r.width > 0 && r.height > 0;
    }).length,
    talentPanels: [...document.querySelectorAll('[data-testid="talent-detail"]')].filter((el) => {
      const r = el.getBoundingClientRect();
      return r.width > 0 && r.height > 0;
    }).length,
  };
});
let state = await sheetState();
check(
  '1500px opens the talent in a column, not a sheet',
  state.column === true && state.sheet === false && state.talentPanels === 1,
  JSON.stringify(state),
);
check('1500px keeps the monster panel visible', state.monsterSections === 1, JSON.stringify(state));
check('1500px drops the list to one card column to make room', state.cardColumns === 1, JSON.stringify(state));
await page.locator('[data-testid="monster-talent-column"] button[title^="关闭"]').click();
await page.waitForTimeout(500);

// 1280px is the low end of the three-pane layout.
await page.setViewportSize({ width: 1280, height: 900 });
await page.waitForTimeout(400);
await page.locator('section[aria-label$="的详情"]:visible button[title*="技能栏"]').first().click();
await page.waitForTimeout(700);
state = await sheetState();
check(
  '1280px still shows monster + talent side by side',
  state.column === true && state.talentPanels === 1 && state.monsterSections === 1,
  JSON.stringify(state),
);
check('1280px keeps the list usable as a single column', state.cardColumns === 1 && state.listWidth > 240, JSON.stringify(state));
await page.locator('[data-testid="monster-talent-column"] button[title^="关闭"]').click();
await page.waitForTimeout(500);

// Wide enough for two card columns again, with the talent still open.
await page.setViewportSize({ width: 1600, height: 950 });
await page.waitForTimeout(400);
await page.locator('section[aria-label$="的详情"]:visible button[title*="技能栏"]').first().click();
await page.waitForTimeout(700);
state = await sheetState();
check(
  '1600px gives the list its second column back while the talent is open',
  state.column === true && state.cardColumns === 2 && state.listWidth > 560,
  JSON.stringify(state),
);
await page.locator('[data-testid="monster-talent-column"] button[title^="关闭"]').click();
await page.waitForTimeout(500);

// Below xl the talent sheet replaces the monster sheet, with a way back.
for (const width of [1200, 900, 420, 360]) {
  await page.setViewportSize({ width, height: 900 });
  await page.waitForTimeout(350);
  await page.locator('section[aria-label$="的详情"]:visible button[title*="技能栏"]').first().click();
  await page.waitForTimeout(700);
  state = await sheetState();
  check(
    `${width}px opens the talent in a bottom sheet`,
    state.sheet && state.column === false && state.talentPanels === 1,
    JSON.stringify(state),
  );
  check(`${width}px hides the monster sheet behind the talent`, state.monsterSections === 0, JSON.stringify(state));
  const back = page.locator('[data-testid="talent-detail"]:visible button[aria-label="返回怪物"]');
  check(`${width}px offers a back-to-monster control`, (await back.count()) > 0);
  await back.click();
  await page.waitForTimeout(600);
  state = await sheetState();
  check(
    `${width}px closing the talent brings the monster sheet back`,
    state.talentPanels === 0 && state.monsterSections === 1,
    JSON.stringify(state),
  );
}
await page.setViewportSize({ width: 1500, height: 950 });
await page.waitForTimeout(300);

// Direct link + refresh keeps the selection, and Back returns to it.
await page.goto(`${url}#/monsters?cat=boss&m=WALROG`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('怪物图鉴'), null, { timeout: 30000 });
await page.waitForTimeout(700);
check('deep link restores the category filter', (await monsterCardCount()) === 98, String(await monsterCardCount()));
const linkedDetail = await page.locator('section[aria-label$="的详情"]').first().innerText();
check('deep link restores the selected monster', linkedDetail.includes('乌尔罗格') || linkedDetail.includes('Walrog'), linkedDetail.slice(0, 60));
check('supplemented talent T_HEAT resolves', linkedDetail.includes('加热') && !linkedDetail.includes('未收录'), linkedDetail.slice(0, 400));

await page.goto(`${url}#/monsters?cat=elite`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('怪物图鉴'), null, { timeout: 30000 });
// Wait for the filter to actually apply, not just for the heading to exist.
await page.waitForFunction(() => document.querySelectorAll('main div.grid > button').length === 176, null, { timeout: 15000 });
check('elite filter lists every elite template', (await monsterCardCount()) === 176, String(await monsterCardCount()));
await page.goBack();
await page.waitForFunction(() => document.querySelectorAll('main div.grid > button').length === 98, null, { timeout: 15000 });
check('browser Back restores the previous monster view', (await monsterCardCount()) === 98, String(await monsterCardCount()));

// Multi-layer art must not render as a transparent tile.
await page.goto(`${url}#/monsters?m=THE_ONE_THAT_HUNTS`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('怪物图鉴'), null, { timeout: 30000 });
await page.waitForTimeout(600);
const layered = await page.locator('section[aria-label$="的详情"] img').first().evaluate((el) => ({
  width: el.naturalWidth,
  height: el.naturalHeight,
  src: el.getAttribute('src'),
}));
check(
  'layered monster art is a real non-empty image',
  layered.width > 0 && layered.height > 0 && !/invis\.png$/.test(layered.src ?? ''),
  JSON.stringify(layered),
);
await shot('11-monsters-detail');

// Mobile layout: the sidebar collapses and the list still renders.
await page.setViewportSize({ width: 420, height: 900 });
await page.goto(`${url}#/monsters`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('怪物图鉴'), null, { timeout: 30000 });
await page.waitForTimeout(700);
check('mobile monster list renders', (await monsterCardCount()) > 0);
check('mobile category toggle available', (await page.locator('button', { hasText: '分类' }).count()) > 0);
await page.locator('button', { hasText: '分类' }).first().click();
await page.waitForTimeout(300);
check('mobile category chips expand', (await page.locator('button', { hasText: '固定Boss' }).count()) > 0);

// The desktop tree does not fit a phone; the same two levels are selects.
check('mobile type select is offered', (await page.locator('#monster-type-select').count()) === 1);
await page.locator('#monster-type-select').selectOption('horror');
await page.waitForTimeout(400);
check('mobile type select filters the list', (await monsterCardCount()) === 95, String(await monsterCardCount()));
check('mobile subtype select follows the chosen type', (await page.locator('#monster-subtype-select').count()) === 1);
await page.locator('#monster-subtype-select').selectOption('eldritch');
await page.waitForTimeout(400);
check('mobile subtype select narrows further', (await monsterCardCount()) === 61, String(await monsterCardCount()));
check(
  'mobile cards chip the Chinese type',
  (await monsterCards().first().innerText()).includes('恐魔'),
  (await monsterCards().first().innerText()).slice(0, 80),
);
await page.locator('#monster-type-select').selectOption('all');
await page.waitForTimeout(400);
check('mobile type select can be cleared', (await monsterCardCount()) === 812, String(await monsterCardCount()));
await shot('12-monsters-mobile');

// Bottom sheets must scroll *themselves*. A sheet built with only `max-h` (no
// bounded flex column) lets the panel grow to its content, clip it, and send the
// drag to the page behind — which is exactly what a reader sees as "the sheet
// will not scroll, the list behind moves instead".
const sheetScroll = (selector) => page.evaluate((sel) => {
  const root = document.querySelector(sel);
  const scroller = root?.querySelector('section div.overflow-y-auto, aside div.overflow-y-auto');
  if (!scroller) return null;
  const rect = scroller.getBoundingClientRect();
  return {
    scrollable: scroller.scrollHeight > scroller.clientHeight + 1,
    scrollHeight: scroller.scrollHeight,
    clientHeight: scroller.clientHeight,
    point: { x: Math.round(rect.x + rect.width / 2), y: Math.round(rect.y + Math.min(40, rect.height / 2)) },
  };
}, selector);

/** Wheel at a point inside the sheet body; report what actually moved. */
const wheelInSheet = async (selector) => {
  const info = await sheetScroll(selector);
  if (!info) return null;
  const before = await page.evaluate(() => Math.round(document.scrollingElement.scrollTop));
  await page.mouse.move(info.point.x, info.point.y);
  await page.mouse.wheel(0, 320);
  await page.waitForTimeout(350);
  return page.evaluate((sel) => {
    const scroller = document.querySelector(sel).querySelector('section div.overflow-y-auto, aside div.overflow-y-auto');
    return {
      scrollerTop: Math.round(scroller.scrollTop),
      bodyTop: Math.round(document.scrollingElement.scrollTop),
    };
  }, selector).then((after) => ({ ...info, before, ...after }));
};

// WALROG is used here because its sheet is genuinely taller than 75vh (many
// talents), which is the case that used to be unreachable.
await page.goto(`${url}#/monsters?m=WALROG`, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(700);
const monsterSheetScroll = await wheelInSheet('[data-testid="monster-detail-sheet"]');
check(
  '420px monster sheet scrolls itself',
  monsterSheetScroll?.scrollable === true && monsterSheetScroll.scrollerTop > 0,
  JSON.stringify(monsterSheetScroll),
);
check(
  '420px monster sheet does not scroll the list behind it',
  monsterSheetScroll?.bodyTop === monsterSheetScroll?.before,
  JSON.stringify(monsterSheetScroll),
);
await page.locator('[data-testid="monster-detail-sheet"] button[title*="技能栏"]').first().click();
await page.waitForTimeout(700);
const talentSheetScroll = await wheelInSheet('[data-testid="monster-talent-sheet"]');
check(
  '420px talent sheet scrolls itself',
  talentSheetScroll?.scrollable === true && talentSheetScroll.scrollerTop > 0,
  JSON.stringify(talentSheetScroll),
);
check(
  '420px talent sheet does not scroll the list behind it',
  talentSheetScroll?.bodyTop === talentSheetScroll?.before,
  JSON.stringify(talentSheetScroll),
);
await page.locator('[data-testid="talent-detail"]:visible button[aria-label="返回怪物"]').click();
await page.waitForTimeout(500);

await page.setViewportSize({ width: 1500, height: 950 });

// ---------------------------------------------------------------------------
section('favorites');
await page.goto(`${url}#/search`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(300);

const favoriteButtons = page.locator('button[aria-label^="收藏"]:visible');
check('favorite buttons render on result rows', (await favoriteButtons.count()) > 0);
await favoriteButtons.nth(0).click();
await page.waitForTimeout(200);
await favoriteButtons.nth(1).click();
await page.waitForTimeout(300);
check('header shows the favorite count', (await page.locator('header').innerText()).includes('收藏'));

await page.goto(`${url}#/favorites`, { waitUntil: 'domcontentloaded' });
await page.waitForTimeout(600);
const favText = await page.locator('body').innerText();
check('favorites page lists the saved talents', favText.includes('我的收藏') && favText.includes('共 2 个技能'), favText.slice(0, 120));
await shot('12-favorites');

// Persistence across a reload.
await page.reload({ waitUntil: 'domcontentloaded' });
await page.waitForTimeout(700);
check(
  'favorites persist in localStorage after reload',
  (await page.locator('body').innerText()).includes('共 2 个技能'),
  (await page.locator('body').innerText()).slice(0, 120),
);

// Remove one favourite.
const removeFav = page.locator('button').filter({ hasText: '移除' }).first();
if (await removeFav.count()) {
  await removeFav.click();
  await page.waitForTimeout(400);
  check('removing a favourite updates the list', (await page.locator('body').innerText()).includes('共 1 个技能'));
}

// ---------------------------------------------------------------------------
section('compare');
await page.goto(`${url}#/search`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(300);

const compareButtons = page.locator('button[aria-label^="加入对比"]:visible');
await compareButtons.nth(0).click();
await page.waitForTimeout(200);
await compareButtons.nth(1).click();
await page.waitForTimeout(300);
check('compare tray appears', (await page.locator('body').innerText()).includes('开始对比'));
check('compare tray lists both talents', (await page.locator('body').innerText()).includes('对比 2'), '');
await shot('13-compare-tray');

await page.locator('button').filter({ hasText: /^开始对比$/ }).first().click();
await page.waitForTimeout(500);
const compareText = await page.locator('body').innerText();
check('compare page renders a table', compareText.includes('技能对比'));
check('compare table has stat rows', compareText.includes('冷却时间') && compareText.includes('射程'));
check('compare table shows both columns', (await page.locator('table thead th').count()) === 3, String(await page.locator('table thead th').count()));
check('best value is highlighted', (await page.locator('table td.bg-accent-soft\\/50').count()) > 0 || compareText.includes('★'));
await shot('14-compare');

// Compare limit: adding more than six is refused.
await page.goto(`${url}#/search`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(300);
for (let i = 0; i < 6; i += 1) {
  const button = page.locator('button[aria-label^="加入对比"]:visible').nth(i);
  if (await button.count()) {
    await button.click();
    await page.waitForTimeout(80);
  }
}
await page.waitForTimeout(400);
const trayText = await page.locator('body').innerText();
check('compare tray caps at 6 talents', trayText.includes('对比 6'), trayText.match(/对比 \d+/)?.[0] ?? '');

// ---------------------------------------------------------------------------
section('theming + resilience');
const htmlClassBefore = await page.evaluate(() => document.documentElement.className);
await page.locator('button[aria-label="切换主题"]').click();
await page.waitForTimeout(200);
const htmlClassAfter = await page.evaluate(() => document.documentElement.className);
check('theme toggle flips the dark class', htmlClassBefore !== htmlClassAfter, `${htmlClassBefore} -> ${htmlClassAfter}`);
check('theme choice persists', (await page.evaluate(() => localStorage.getItem('tome-theme'))) !== null);
await shot('08-toggled-theme');

await page.reload({ waitUntil: 'domcontentloaded' });
await page.waitForTimeout(1200);
check('theme survives a reload', (await page.evaluate(() => document.documentElement.className)) === htmlClassAfter);
check('reload keeps the user on the classes route', (await page.locator('body').innerText()).includes('战士系'));

// Mobile viewport sanity check.
await page.setViewportSize({ width: 420, height: 900 });
await page.waitForTimeout(300);
await page.goto(`${url}#/search?q=火焰`, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => document.body.innerText.includes('条结果'), null, { timeout: 30000 });
await page.waitForTimeout(300);
check('mobile layout renders results', ((await resultCount()) ?? 0) > 0);
check('mobile filter button is available', (await page.locator('button', { hasText: '筛选' }).count()) > 0);
await shot('09-mobile');

// Icons for a handful of talents are missing from the upstream export; the UI
// falls back to a letter tile, so those 404s are expected and tolerated.
const unexpected404 = failedRequests.filter((entry) => !entry.includes('/img/talents/'));
check('no unexpected failed requests', unexpected404.length === 0, unexpected404.slice(0, 3).join(' | '));
const icon404 = failedRequests.filter((entry) => entry.includes('/img/talents/'));
if (icon404.length) console.log(`  note ${icon404.length} icon 404(s) tolerated (upstream export is missing them)`);

// Console errors caused by those missing icons are not application errors.
const appConsoleErrors = consoleErrors.filter((entry) => !/Failed to load resource/.test(entry));
check('no application console errors during the whole run', appConsoleErrors.length === 0, appConsoleErrors.slice(0, 3).join(' | '));

// ---------------------------------------------------------------------------
// Equipment ego affixes and fixed artifacts
// ---------------------------------------------------------------------------

// A real browser is the only place these can be checked properly: the property
// grouping is CSS Grid, and the requirement that two items line up on one row
// cannot be asserted from a happy-dom text dump.
// The filter rail is a collapsible sheet below 1280px, and an earlier section
// leaves the page at phone width. Pin the desktop layout and open the rail
// explicitly rather than relying on whatever the previous section left behind.
await page.setViewportSize({ width: 1500, height: 950 });
const openFilterRail = async () => {
  if (!(await page.locator('#ego-query, #artifact-query').first().isVisible().catch(() => false))) {
    const toggle = page.locator('button', { hasText: /^筛选$/ });
    if (await toggle.count()) await toggle.first().click();
    await page.waitForTimeout(300);
  }
};

section('ego affixes');
await page.goto(`${url}#/egos`, { waitUntil: 'domcontentloaded' });
await page.waitForSelector('[data-testid="ego-card"]', { timeout: 30000 });
await openFilterRail();
await page.waitForTimeout(300);

const egosBody = await page.locator('body').innerText();
const egoCardCount = await page.locator('[data-testid="ego-card"]').count();
check('ego list renders', egoCardCount > 100, `${egoCardCount} cards`);
check('ego census is stated', /共\s*608\s*条词缀/.test(egosBody), /共[^\n]*/.exec(egosBody)?.[0]);

// Search must be punctuation-insensitive: the stun-immunity property is
// labelled 震慑/冰冻免疫, and a reader types 震慑免疫.
await page.fill('#ego-query', '震慑免疫');
await page.waitForTimeout(500);
const stunCount = Number(/匹配\s*(\d+)\s*条/.exec(await page.locator('body').innerText())?.[1] ?? 0);
check('ego search matches a label containing a slash', stunCount >= 4, `${stunCount} matches`);
await shot('10-egos-stun-immunity');

// The stun tag must agree with the search: tags are derived from the parsed
// properties, not from the description text.
await page.locator('button', { hasText: '任意状态免疫' }).first().click();
await page.waitForTimeout(400);
const taggedCount = Number(/匹配\s*(\d+)\s*条/.exec(await page.locator('body').innerText())?.[1] ?? 0);
check('effect tag narrows the list', taggedCount > 0 && taggedCount <= stunCount, `${taggedCount} tagged`);

// The rail is tag toggles rather than dropdowns, and 适用部位 is expanded by
// default so choosing a slot costs one click instead of two.
check('the ego filter rail uses tags, not selects', (await page.locator('aside select').count()) === 0);
check('a slot tag is reachable without expanding a section', await page.locator('aside button', { hasText: '盾牌' }).first().isVisible());

// Two facets combine with AND while a facet's own values are alternatives.
await page.fill('#ego-query', '');
await page.locator('button', { hasText: '清空全部条件' }).first().click();
await page.waitForTimeout(400);
await page.locator('aside button', { hasText: '盾牌' }).first().click();
await page.waitForTimeout(400);
const shieldOnly = Number(/匹配\s*(\d+)\s*条/.exec(await page.locator('body').innerText())?.[1] ?? 0);
check('a slot tag filters on one click', shieldOnly > 0 && shieldOnly < 608, `${shieldOnly} in the shield pool`);
const shieldUrl = page.url();
check('multi-select facets are written to the URL', shieldUrl.includes('slot='), shieldUrl.split('#')[1]);
await page.goto(shieldUrl, { waitUntil: 'domcontentloaded' });
await page.waitForFunction(() => /匹配\s*\d+\s*条/.test(document.body.innerText), null, { timeout: 20000 });
const restoredSlots = Number(/匹配\s*(\d+)\s*条/.exec(await page.locator('body').innerText())?.[1] ?? -1);
check('the slot selection survives a reload', restoredSlots === shieldOnly, `${restoredSlots} vs ${shieldOnly}`);

// Ordering: normal tier first, then the greater tier; inside each, community
// recommendation descending.
await page.locator('button', { hasText: '清空全部条件' }).first().click();
await page.waitForTimeout(600);
const egoOrder = await page.locator('[data-testid="ego-card"]').evaluateAll((cards) =>
  cards.map((card) => ({
    greater: (card.textContent ?? '').includes('高级词缀'),
    recommend: Number(/推荐\s*(\d+)/.exec(card.textContent ?? '')?.[1] ?? -1),
  })),
);
const firstGreaterIndex = egoOrder.findIndex((entry) => entry.greater);
const normalRun = firstGreaterIndex === -1 ? egoOrder : egoOrder.slice(0, firstGreaterIndex);
check('normal-tier affixes are listed before greater-tier ones', normalRun.every((entry) => !entry.greater));
check(
  'same-tier affixes are ordered by community recommendation',
  normalRun.every((entry, index) => index === 0 || normalRun[index - 1].recommend >= entry.recommend),
);
// The greater marker must be visually distinct, not another grey chip.
const greaterColour = await page
  .locator('[data-testid="ego-card"] span', { hasText: '高级词缀' })
  .first()
  .evaluate((el) => getComputedStyle(el).color);
const chipColour = await page
  .locator('[data-testid="ego-card"] span.chip')
  .first()
  .evaluate((el) => getComputedStyle(el).color);
check('the greater-tier marker is colour-coded apart from ordinary chips', greaterColour !== chipColour, `${greaterColour} vs ${chipColour}`);
await shot('10b-egos-ordering');

// A shared ego pool: the chainsaw loads both the melee weapon and shield pools,
// so some of its affixes are marked as coming from a shared pool.
await page.goto(`${url}#/egos?q=${encodeURIComponent('链锯')}`, { waitUntil: 'domcontentloaded' });
await page.waitForSelector('[data-testid="ego-card"]', { timeout: 20000 });
await page.waitForTimeout(500);
const sharedText = await page.locator('body').innerText();
check('shared ego pool is labelled, not hidden', sharedText.includes('共享词缀池'));

// Deep link: selection survives a reload.
await page.locator('[data-testid="ego-card"]').first().click();
await page.waitForTimeout(400);
const egoShare = page.url();
await page.goto(egoShare, { waitUntil: 'domcontentloaded' });
await page.waitForSelector('[data-testid="ego-detail"]:visible', { timeout: 20000 });
check('ego selection survives a reload', true, egoShare.split('#')[1]?.slice(0, 60));

// ---------------------------------------------------------------------------
// The detail panel is pinned to the viewport, so its top edge must clear the
// sticky header. Anchoring it at `top: 0` put the affix name and the close
// button underneath the header — unreadable, and impossible to notice from a
// text dump because the markup was all there.
// ---------------------------------------------------------------------------
await page.goto(`${url}#/egos?q=${encodeURIComponent('of carrying')}`, { waitUntil: 'domcontentloaded' });
await page.waitForSelector('[data-testid="ego-card"]', { timeout: 20000 });
await page.locator('[data-testid="ego-card"]').first().click();
await page.waitForSelector('[data-testid="ego-detail"]:visible', { timeout: 15000 });
const headerBox = await page.locator('header.sticky').boundingBox();
const panelName = await page.locator('[data-testid="ego-detail"]:visible h2').first().boundingBox();
const panelTop = await page.locator('[data-testid="ego-detail"]:visible').first().boundingBox();
check(
  'the affix detail panel starts below the header',
  headerBox !== null && panelTop !== null && panelTop.y >= headerBox.y + headerBox.height - 1,
  `header ends ${headerBox ? Math.round(headerBox.y + headerBox.height) : '?'}, panel starts ${panelTop ? Math.round(panelTop.y) : '?'}`,
);
check(
  'the affix name is not covered by the header',
  headerBox !== null && panelName !== null && panelName.y >= headerBox.y + headerBox.height - 1,
  `name at ${panelName ? Math.round(panelName.y) : '?'}`,
);
await shot('10c-egos-detail-below-header');

// The effect is on the card, not only in the panel: a callback affix (a charm
// proc) has no property table at all, so before this it read "open the detail".
await page.goto(`${url}#/egos?q=evasive`, { waitUntil: 'domcontentloaded' });
await page.waitForSelector('[data-testid="ego-effect"]', { timeout: 20000 });
const evasiveEffect = await page.locator('[data-testid="ego-effect"]').first().innerText();
check('a callback affix states its effect on the card', evasiveEffect.includes('躲闪'), evasiveEffect.slice(0, 80));
check('the card effect carries the real value range', evasiveEffect.includes('10~40'), evasiveEffect.slice(0, 80));

// Material level: one choice, and it moves the numbers on the cards.
const cardRange = async (query, level) => {
  await page.goto(`${url}#/egos?q=${encodeURIComponent(query)}${level ? `&ml=${level}` : ''}`, { waitUntil: 'domcontentloaded' });
  await page.waitForSelector('[data-testid="ego-effect"]', { timeout: 20000 });
  await page.waitForTimeout(300);
  return page.locator('[data-testid="ego-effect"]').first().innerText();
};
const fullRange = await cardRange('of carrying', null);
const ironRange = await cardRange('of carrying', 1);
const voratunRange = await cardRange('of carrying', 5);
check('the widest range spans material levels 1–5', fullRange.includes('+20~+60'), fullRange.replace(/\n/g, ' | '));
check('material level 1 narrows the range', ironRange.includes('+20~+28'), ironRange.replace(/\n/g, ' | '));
check('material level 5 restores the widest range', voratunRange.includes('+20~+60'), voratunRange.replace(/\n/g, ' | '));
await page.goto(`${url}#/egos?q=evasive&ml=1`, { waitUntil: 'domcontentloaded' });
await page.waitForSelector('[data-testid="ego-card"]', { timeout: 20000 });
await page.locator('[data-testid="ego-card"]').first().click();
await page.waitForSelector('[data-testid="ego-detail"]:visible', { timeout: 15000 });
await page.waitForTimeout(300);
const levelDetail = await page.locator('[data-testid="ego-detail"]:visible').first().innerText();
check('the detail panel states the level its numbers are for', levelDetail.includes('数值按材料等级 1 计算'), levelDetail.slice(0, 200));
check('a callback value moves with the material level too', levelDetail.includes('10~16'), levelDetail.slice(0, 300));

section('fixed artifacts');
await page.goto(`${url}#/artifacts`, { waitUntil: 'domcontentloaded' });
await page.waitForSelector('[data-testid="artifact-card"]', { timeout: 30000 });
await openFilterRail();
await page.waitForTimeout(300);

const artifactsBody = await page.locator('body').innerText();
const artifactCardCount = await page.locator('[data-testid="artifact-card"]').count();
check('artifact list renders', artifactCardCount > 100, `${artifactCardCount} cards`);
check('artifact census separates equipment from the rest', /可装备\/可使用\s*\d+/.test(artifactsBody));
check('artifact list shows native icons', (await page.locator('[data-testid="artifact-card"] img').count()) > 100);
check('the artifact rail uses tags, not selects', (await page.locator('aside select').count()) === 0);

// The two collection tags are independent: equipment only by default, then
// non-equipment only, then everything.
const artifactCount = async () =>
  Number(/匹配\s*(\d+)\s*件/.exec(await page.locator('body').innerText())?.[1] ?? -1);
check('equipment is the default scope', (await artifactCount()) === 416, String(await artifactCount()));
await page.locator('aside button', { hasText: '可装备' }).first().click();
await page.locator('aside button', { hasText: '非装备' }).first().click();
await page.waitForTimeout(500);
check('unchecking 可装备 and checking 非装备 shows only non-equipment', (await artifactCount()) === 80, String(await artifactCount()));
check('the non-equipment scope is written to the URL', page.url().includes('scope=non'), page.url().split('#')[1]);
await page.locator('aside button', { hasText: '可装备' }).first().click();
await page.waitForTimeout(500);
check('both tags on shows everything', (await artifactCount()) === 496, String(await artifactCount()));
await page.locator('button', { hasText: '清空全部条件' }).first().click();
await page.waitForTimeout(500);
check('clearing restores the equipment-only default', (await artifactCount()) === 416, String(await artifactCount()));

// A multi-resistance artifact: many damage types must share one 抗性 row with
// the Chinese type names, and must not be summed into a single number.
await page.fill('#artifact-query', '防腐腰带');
await page.waitForTimeout(600);
await page.locator('[data-testid="artifact-card"]').first().click();
await page.waitForSelector('[data-testid="artifact-detail"]:visible', { timeout: 15000 });
const beltText = await page.locator('[data-testid="artifact-detail"]:visible').first().innerText();
check('multiple resistances group onto one row', /抗性[\s\S]{0,240}火焰/.test(beltText));
check('resistances are labelled by damage type', ['火焰', '寒冷', '闪电', '酸性'].every((t) => beltText.includes(t)));
check(
  'resistances are not summed into one number',
  !/抗性[^\n]{0,40}\b(165|135|11\s*×)\b/.test(beltText),
);
await shot('11-artifact-resistances');

// A growth / random-property artifact must be described in words and must not
// grow a simulator.
await page.fill('#artifact-query', '命运之轮');
await page.waitForTimeout(600);
await page.locator('[data-testid="artifact-card"]').first().click();
await page.waitForTimeout(500);
const wheelLocator = page.locator('[data-testid="artifact-detail"]:visible').first();
const wheelText = await wheelLocator.innerText();
check('Wheel of Fate is described in words', wheelText.includes('重置戒指属性'), wheelText.slice(0, 120));
check('Wheel of Fate has no random-attribute panel or slider', (await wheelLocator.locator('input[type="range"]').count()) === 0);
check('Wheel of Fate says it has no static property panel', wheelText.includes('没有静态属性面板'));

// The wearer / weapon distinction must be visible, not merged.
await page.fill('#artifact-query', '比尔的树干');
await page.waitForTimeout(600);
await page.locator('[data-testid="artifact-card"]').first().click();
await page.waitForTimeout(500);
const billText = await page.locator('[data-testid="artifact-detail"]:visible').first().innerText();
check('weapon body is a separate section from wearer effects', billText.includes('装备本体属性'));
check('weapon body states it is not a wearer bonus', billText.includes('不是穿戴者获得的属性'));
check('equipment requirements are kept complete', /装备需求[\s\S]{0,40}力量\s*25/.test(billText), billText.slice(0, 200));
check('a talent ability links into the shared talent library', billText.includes('T_SHATTERING_BLOW'));
check('flavour text is not the effect list', billText.includes('风味描述'));

// Narrow-screen layout: the detail must stay readable without horizontal
// scrolling, which is where the grouped rows would break first.
await page.setViewportSize({ width: 390, height: 844 });
await page.waitForTimeout(500);
const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
check('artifact detail does not force horizontal scrolling on a phone', overflow <= 2, `${overflow}px overflow`);
await shot('12-artifact-mobile');

// ---------------------------------------------------------------------------

console.log(`\n${checks - failures}/${checks} checks passed`);
await browser.close();
if (failures) {
  console.error(`${failures} check(s) failed`);
  process.exit(1);
}
