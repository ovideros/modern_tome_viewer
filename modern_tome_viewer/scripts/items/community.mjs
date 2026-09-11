/**
 * Community affix supplement importer.
 *
 * The generated ego dataset (`public/data/egos.json`) is derived from the game
 * sources and therefore knows the mechanical truth — rarity, level range,
 * pools — but not the community's practical notes (推荐度, 备注, richer effect
 * text). Those live in a hand-maintained spreadsheet that must never be allowed
 * to overwrite source data, only annotate it.
 *
 * This module reads that spreadsheet, joins every data row to an ego id by the
 * Chinese affix name restricted to the row's sheet-derived pool, and writes:
 *
 *   public/data/ego-community.json   machine-readable supplement
 *   docs/items-community-report.md   human review of matching and data quality
 *
 * Design rules:
 *  - The ego id is the join key; nothing here mutates `egos.json`.
 *  - Matching is conservative but not narrow: a row matches only egos whose
 *    owning `pool` is in the sheet's allowed set, derived from the `loads`
 *    graph in `items-report.json` as {sheet pool} ∪ what it loads ∪ pools that
 *    load it. `heavy-armor` loads `armor`, so the 重甲 sheet legitimately rolls
 *    plain-armor affixes; `bow`/`sling` load `ranged`, so 远程武器 covers their
 *    own affixes. Sibling pools a shared parent also loads (`steamsaw` loads
 *    both `weapon` and `shield`) are deliberately excluded, so nothing outside
 *    that derived set is ever matched.
 *  - Confidence is explicit: `high` for an own-pool match, `shared-pool` when
 *    the ego's file differs from the sheet's pool, `medium` when several egos
 *    in the allowed set share the Chinese name.
 *  - Every row is accounted for: matched, listed in `extra`, or listed as a
 *    conflict. The spreadsheet is evidence, so suspected spreadsheet mistakes
 *    are recorded (`findings`) rather than silently corrected.
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { readWorkbook } from './xlsx.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(HERE, '..', '..');
/** `others/` sits beside the web app, not inside it. */
const WORKSPACE_ROOT = path.dirname(REPO_ROOT);

/** Default spreadsheet, relative to the workspace root. */
export const DEFAULT_XLSX = 'others/物品词缀表（1.7.6版本适用）.xlsx';

/** Sheet tab order the importer expects; also used by the tests. */
export const EXPECTED_SHEETS = [
  '近战武器', '远程武器', '弹药', '法杖', '灵晶', '盾牌', '项链', '披风', '腰带', '鞋子',
  '手套', '法袍', '重甲', '板甲', '轻甲', '头盔', '法师帽', '灯具', '戒指', '锄头',
];

/**
 * Sheet -> ego pool (the pool whose file the sheet's item type owns).
 *
 * The sheet name is the only trustworthy signal for which pool an otherwise
 * ambiguous Chinese affix name belongs to. The allowed match set is this pool
 * widened by its `loads` closure, never an arbitrary cross-pool guess.
 */
export const SHEET_POOL = {
  近战武器: 'weapon',
  远程武器: 'ranged',
  弹药: 'ammo',
  法杖: 'staves',
  灵晶: 'mindstars',
  盾牌: 'shield',
  项链: 'amulets',
  戒指: 'rings',
  披风: 'cloak',
  腰带: 'belt',
  鞋子: 'boots',
  手套: 'gloves',
  法袍: 'robe',
  重甲: 'heavy-armor',
  板甲: 'massive-armor',
  轻甲: 'light-armor',
  头盔: 'helm',
  法师帽: 'wizard-hat',
  灯具: 'lite',
  锄头: 'digger',
};

/** Header label -> logical column. Columns are located per sheet, not assumed. */
export const HEADER = {
  name: '词缀名',
  greater: '是否为高级词缀',
  effect: '效果',
  rarity: '稀有度',
  recommend: '推荐度',
  note: '备注',
};

/** Positional fallback for a sheet with no readable header row. */
const FALLBACK_COLUMNS = { name: 0, greater: 1, effect: 2, rarity: 3, recommend: 4, note: 5 };

/** The pool/load graph is published by the item build next to `egos.json`. */
export const POOL_REPORT_FILE = path.join(REPO_ROOT, 'public/data/items-report.json');

/**
 * Read the `pool -> loads` graph from the item build report.
 *
 * WHY derived rather than hardcoded: an ego file that is `load()`ed by another
 * pool is reachable from it, so an item of the outer pool can roll the inner
 * pool's affixes. `heavy-armor.lua` loads `armor.lua`, which is exactly why the
 * 重甲 sheet lists plain-armor affixes. Encoding those edges by hand here would
 * silently rot the moment the game's load chain changes.
 *
 * Returns `Map<pool, string[]>`; a missing report yields an empty graph, which
 * degrades to own-pool-only matching and is reported as a finding.
 */
export function loadPoolGraph(reportFile = POOL_REPORT_FILE) {
  const graph = new Map();
  if (!fs.existsSync(reportFile)) return graph;
  const report = JSON.parse(fs.readFileSync(reportFile, 'utf8'));
  for (const entry of report.pools ?? []) {
    if (!entry?.pool) continue;
    graph.set(entry.pool, [...new Set(entry.loads ?? [])]);
  }
  return graph;
}

/** `pool` plus every pool reachable through `loads` (cycle-safe). */
export function poolClosure(pool, graph) {
  const closure = new Set();
  if (!pool) return closure;
  const pending = [pool];
  while (pending.length > 0) {
    const current = pending.pop();
    if (closure.has(current)) continue;
    closure.add(current);
    for (const next of graph.get(current) ?? []) pending.push(next);
  }
  return closure;
}

/** Every pool whose `loads` closure contains `pool` (the pools that roll it). */
export function poolAncestors(pool, graph) {
  const ancestors = new Set();
  if (!pool) return ancestors;
  for (const candidate of graph.keys()) {
    if (candidate === pool) continue;
    if (poolClosure(candidate, graph).has(pool)) ancestors.add(candidate);
  }
  return ancestors;
}

/**
 * Pools an ego of `pool` may be matched from, for one sheet.
 *
 * The sheet's pool is the affix file the sheet's item type owns, so the allowed
 * set is:
 *   - the pool itself,
 *   - everything it loads (e.g. `heavy-armor` loads `armor`, so 重甲 rolls plain
 *     armour affixes), and
 *   - every pool that loads it (e.g. `bow`/`sling` load `ranged`, so 远程武器
 *     legitimately covers the bow/sling-only affixes too, and `light-boots`
 *     loads `boots`, which is where 鞋子 row 4 潜行 lives).
 *
 * Sibling pools that a shared parent also loads are deliberately excluded:
 * `steamsaw` loads both `weapon` and `shield`, but a plain longsword is not a
 * shield, so 近战武器 must not pull in shield-only egos (and vice versa). This
 * is why matching uses the ego's owning `pool` rather than its expanded `pools`
 * reachability set: the latter would silently cross that boundary.
 */
export function allowedPoolsFor(pool, graph) {
  const allowed = poolClosure(pool, graph);
  for (const ancestor of poolAncestors(pool, graph)) allowed.add(ancestor);
  return allowed;
}

/**
 * Pools an ego can roll on.
 *
 * `egos.json` rows already carry the expanded reachable set in `pools`, so the
 * owning `pool` is only a fallback for a hypothetical row without it.
 */
export function egoPools(ego) {
  const pools = Array.isArray(ego?.pools) ? ego.pools.filter(Boolean) : [];
  return pools.length > 0 ? pools : (ego?.pool ? [ego.pool] : []);
}

/**
 * Damage-type words a resistance ego is expected to name in its effect, keyed
 * by the ego's source `keyword`. Used only to spot a name/effect misalignment
 * in the community text: `of light` grants 光系, so a row named 光系 whose effect
 * talks about 闪电 is evidence of a spreadsheet error, not of a match failure.
 */
const DAMAGE_TERM_BY_KEYWORD = {
  fire: '火焰',
  frost: '寒冷',
  lightning: '闪电',
  light: '光系',
  darkness: '暗影',
  corrosion: '酸性',
  nature: '自然',
  blight: '枯萎',
  mind: '精神',
  mountain: '物理',
  time: '时间',
};

/** Fixed scan order so the "actual" damage term is deterministic. */
const DAMAGE_TERMS = ['火焰', '寒冷', '闪电', '光系', '暗影', '酸性', '自然', '枯萎', '精神', '物理', '时间'];

/**
 * True for the elemental-resistance egos whose name carries the `(#RESIST#)`
 * placeholder that the engine fills with the granted damage type.
 *
 * The name/effect check is only sound for these: their source `keyword` maps
 * one-to-one onto the damage type shown in the effect. A greater variant whose
 * Chinese name is a flavour word (e.g. `瘟神` for `blight:greater`) does not
 * name a damage type, so checking it would invent a misalignment.
 */
function isResistEgo(ego) {
  return /\(#RESIST#\)\s*$/.test(String(ego?.name?.zh ?? ''));
}

/**
 * Normalise a Chinese affix name for comparison.
 *
 * Two normalisations are needed, both observed in the real data:
 *  - `(#RESIST#)`, `(#STATBONUS#)` and friends are localisation placeholders,
 *    not part of the name: the ego is `光系之 (#RESIST#)` while the sheet says
 *    `光系`. Without stripping the placeholder those rows could never match.
 *  - the trailing possessive 的/之 is dropped, so `平衡的`/`平衡之` both become
 *    `平衡`. Stripping is trailing-only and the remainder is compared exactly,
 *    so `火焰` can never match `火焰抗性`.
 */
export function normalizeZh(value) {
  return String(value ?? '')
    .replace(/\s*\(#[A-Za-z_]+#\)\s*$/, '')
    .trim()
    .replace(/[的之]$/, '')
    .trim();
}

/** Trimmed cell text, treating a missing cell as an empty string. */
function cellAt(row, index) {
  if (!Number.isInteger(index) || index < 0) return '';
  const value = row?.[index];
  return value === null || value === undefined ? '' : String(value).trim();
}

/** Parse an Excel rarity cell into a number, or null when it is not numeric. */
export function parseRarity(value) {
  const text = String(value ?? '').trim();
  if (text === '') return null;
  const number = Number(text);
  return Number.isFinite(number) ? number : null;
}

/**
 * Locate the header row and read every data row of one sheet.
 *
 * The header is found by content (`词缀名`) rather than by position: some
 * sheets carry a leading note row (近战武器, 远程武器) and a trailing fully
 * styled but empty row (重甲). Data rows are exactly the rows below the header
 * whose 词缀名 cell is non-empty, which is what makes `rowCount` stable.
 */
export function parseSheetTable(sheet) {
  const rows = sheet?.rows ?? [];
  let headerRow = -1;
  let columns = null;
  for (let i = 0; i < rows.length; i += 1) {
    const cells = rows[i] ?? [];
    if (cells.includes(HEADER.name)) {
      headerRow = i;
      columns = {};
      for (const [key, label] of Object.entries(HEADER)) columns[key] = cells.indexOf(label);
      break;
    }
  }
  const missingHeader = headerRow === -1;
  if (missingHeader) columns = { ...FALLBACK_COLUMNS };

  const data = [];
  for (let i = headerRow + 1; i < rows.length; i += 1) {
    const cells = rows[i] ?? [];
    const rawName = cellAt(cells, columns.name);
    if (rawName === '') continue;
    data.push({
      sheet: sheet.name,
      row: i + 1,
      rawName,
      greater: cellAt(cells, columns.greater),
      effect: cellAt(cells, columns.effect),
      rarity: cellAt(cells, columns.rarity),
      recommend: cellAt(cells, columns.recommend),
      note: cellAt(cells, columns.note),
      cells: cells.map((cell) => (cell === null || cell === undefined ? '' : String(cell))),
    });
  }
  return { headerRow: headerRow === -1 ? null : headerRow + 1, columns, missingHeader, rows: data };
}

/**
 * Chinese-name -> egos index, sorted by id for deterministic candidate order.
 *
 * The pool scoping happens at match time (allowed-set intersection), not here:
 * one Chinese name can legitimately appear in several reachable pools and every
 * one of them must be considered for the sheet being processed.
 */
export function buildEgoIndex(egos) {
  const byName = new Map();
  for (const ego of egos ?? []) {
    const key = normalizeZh(ego?.name?.zh);
    if (key === '' || !ego?.id) continue;
    byName.set(key, [...(byName.get(key) ?? []), ego]);
  }
  for (const [key, list] of byName) byName.set(key, [...list].sort((a, b) => a.id.localeCompare(b.id)));
  return { byName };
}

/** Pick the reportable subset of a row (everything except the raw cell array). */
function rowEvidence(row) {
  return {
    sheet: row.sheet,
    row: row.row,
    rawName: row.rawName,
    greater: row.greater,
    effect: row.effect,
    rarity: row.rarity,
    recommend: row.recommend,
    note: row.note,
  };
}

/**
 * Join the workbook to the ego dataset.
 *
 * Returns `{ data, findings, stats, closures }`. `data` is the exact JSON
 * payload written to `ego-community.json`; `findings` are the spreadsheet
 * data-quality observations the report spells out (duplicate rows, name/effect
 * misalignment, ambiguous names, shared-pool repeats); `stats` is per-sheet
 * coverage; `closures` records the derived allowed pool set per sheet.
 *
 * `options.poolLoads` is the `pool -> loads` graph (see `loadPoolGraph`). It is
 * injectable so tests can pin a synthetic graph; the real call loads the item
 * build report.
 */
export function analyzeCommunity(workbook, egos, options = {}) {
  const index = buildEgoIndex(egos);
  const egoById = new Map((egos ?? []).map((ego) => [ego.id, ego]));
  const poolLoads = options.poolLoads ?? loadPoolGraph();
  const byEgoId = new Map();
  const extra = [];
  const conflicts = [];
  const findings = [];
  const stats = [];
  const closures = [];
  /** egoId -> every (sheet, row) that matched it, for shared-pool reporting. */
  const matchLog = new Map();

  if (poolLoads.size === 0) {
    findings.push({
      type: 'missing-pool-graph',
      sheet: '（全局）',
      row: null,
      message: '未读到 items-report.json 的 pools[].loads，只能按工作表本池匹配（共享池将会显示为未匹配）',
    });
  }

  for (const sheet of workbook?.sheets ?? []) {
    const pool = SHEET_POOL[sheet.name] ?? null;
    const allowedPools = allowedPoolsFor(pool, poolLoads);
    const table = parseSheetTable(sheet);
    closures.push({ sheet: sheet.name, pool, allowed: [...allowedPools] });
    if (!pool) {
      findings.push({ type: 'unknown-sheet', sheet: sheet.name, message: '工作表未映射到词缀池，整表按未匹配处理' });
    }
    if (table.missingHeader) {
      findings.push({ type: 'missing-header', sheet: sheet.name, message: '未找到表头行，按固定列序解析' });
    }

    let matched = 0;
    let own = 0;
    let shared = 0;
    for (const row of table.rows) {
      const key = normalizeZh(row.rawName);
      // Only egos whose OWNING pool is in the sheet's derived allowed set may
      // match; a name that exists elsewhere stays in `extra` with a
      // reporting-only hint.
      const candidates = (index.byName.get(key) ?? [])
        .filter((ego) => allowedPools.has(ego.pool ?? ''));
      if (candidates.length === 0) {
        const crossPool = (index.byName.get(key) ?? []).map((ego) => ({ id: ego.id, pool: ego.pool, pools: egoPools(ego) }));
        extra.push({ ...rowEvidence(row), pool, allowedPools: [...allowedPools], crossPool });
        continue;
      }
      matched += 1;
      // The ego's owning `pool` (its file) decides the label, not its expanded
      // `pools` set: `armor.lua` egos list heavy/massive/light in `pools`, but
      // they are shared across those sheets, so matching them from 重甲 is a
      // shared-pool hit. Own-pool hits are `high`; shared ones are labelled
      // `shared-pool`. `medium` (name shared by several reachable egos) is the
      // least certain signal and therefore dominates the label.
      const isOwn = candidates.some((ego) => (ego.pool ?? null) === pool);
      const confidence = candidates.length > 1 ? 'medium' : (isOwn ? 'high' : 'shared-pool');
      if (isOwn) own += 1;
      else shared += 1;
      if (candidates.length > 1) {
        findings.push({
          type: 'ambiguous-name',
          sheet: row.sheet,
          row: row.row,
          rawName: row.rawName,
          pool,
          egoIds: candidates.map((ego) => ego.id),
          message: `允许池内有 ${candidates.length} 个同名 ego，整行记给全部候选并降为 medium 置信度`,
        });
      }

      for (const ego of candidates) {
        matchLog.set(ego.id, [...(matchLog.get(ego.id) ?? []), { sheet: row.sheet, row: row.row, confidence }]);
        const excelRarity = parseRarity(row.rarity);
        const sourceRarity = Number.isFinite(ego.rarity) ? ego.rarity : null;
        const differs = excelRarity !== null && sourceRarity !== null && excelRarity !== sourceRarity;
        if (differs) {
          conflicts.push({
            sheet: row.sheet,
            row: row.row,
            rawName: row.rawName,
            egoId: ego.id,
            excelRarity: row.rarity,
            sourceRarity: ego.rarity,
            match: 'name+pool',
            confidence,
          });
        }

        const existing = byEgoId.get(ego.id);
        if (!existing) {
          byEgoId.set(ego.id, {
            ...rowEvidence(row),
            match: 'name+pool',
            confidence,
            // Source rarity wins; `updated` only flags that the community value
            // disagreed and is preserved as evidence in `conflicts`.
            updated: differs,
          });
        } else if (existing.sheet === row.sheet) {
          // Two rows of the SAME sheet hitting one ego is a real duplicate.
          findings.push({
            type: 'duplicate-match',
            sheet: row.sheet,
            row: row.row,
            rawName: row.rawName,
            egoId: ego.id,
            firstSheet: existing.sheet,
            firstRow: existing.row,
            message: '同一个 ego 被同一工作表的多行匹配，仅首行写入 byEgoId',
          });
        }
        // A repeat from a DIFFERENT sheet is expected for a shared reachable
        // pool (armor rolls on heavy/massive/light armour alike) and is
        // summarised as a `shared-match` finding after the sheet loop.

        const expectedTerm = isResistEgo(ego) ? DAMAGE_TERM_BY_KEYWORD[ego.keyword] : null;
        if (expectedTerm && row.effect) {
          const actualTerm = DAMAGE_TERMS.find((term) => row.effect.includes(term)) ?? null;
          if (actualTerm && actualTerm !== expectedTerm) {
            findings.push({
              type: 'name-effect-misalignment',
              sheet: row.sheet,
              row: row.row,
              rawName: row.rawName,
              egoId: ego.id,
              expectedEffectTerm: expectedTerm,
              actualEffectTerm: actualTerm,
              effect: row.effect,
              message: '词缀名与效果文本指向不同伤害类型',
            });
          }
        }
      }
    }

    stats.push({ sheet: sheet.name, pool, rows: table.rows.length, matched, own, shared, unmatched: table.rows.length - matched });
  }

  // A shared-pool ego is legitimately rolled by several sheets; record which
  // ones so the report can show that the supplement is per-ego, not per-sheet.
  const sheetOrder = new Map((workbook?.sheets ?? []).map((sheet, i) => [sheet.name, i]));
  for (const [egoId, entries] of matchLog) {
    const sheets = [...new Set(entries.map((entry) => entry.sheet))];
    if (sheets.length < 2) continue;
    const ordered = [...entries].sort((a, b) => (sheetOrder.get(a.sheet) ?? 0) - (sheetOrder.get(b.sheet) ?? 0) || a.row - b.row);
    findings.push({
      type: 'shared-match',
      sheet: ordered[0].sheet,
      row: ordered[0].row,
      egoId,
      pool: egoById.get(egoId)?.pool ?? null,
      sheets,
      matches: ordered,
      message: `共享池词缀，被 ${sheets.length} 个工作表命中`,
    });
  }

  // Whole-row duplicates inside one sheet: two data rows with identical 词缀名,
  // 高级词缀, 效果, 稀有度, 推荐度 and 备注 carry no extra information and are a
  // copy/paste artefact worth reviewing.
  for (const sheet of workbook?.sheets ?? []) {
    const table = parseSheetTable(sheet);
    const groups = new Map();
    for (const row of table.rows) {
      const signature = JSON.stringify([row.rawName, row.greater, row.effect, row.rarity, row.recommend, row.note]);
      groups.set(signature, [...(groups.get(signature) ?? []), row]);
    }
    for (const rows of groups.values()) {
      if (rows.length < 2) continue;
      findings.push({
        type: 'duplicate-row',
        sheet: sheet.name,
        rows: rows.map((row) => row.row),
        rawName: rows[0].rawName,
        message: `同一工作表内有 ${rows.length} 行完全相同`,
      });
    }
  }

  // Workbook order, then Excel row: the sheet order is part of the source, so it
  // is the most reviewable sort for every list in the report (`sheetOrder` was
  // built above for the shared-pool summary).
  const byPosition = (a, b) => (sheetOrder.get(a.sheet) ?? 0) - (sheetOrder.get(b.sheet) ?? 0) || a.row - b.row;
  extra.sort(byPosition);
  conflicts.sort(byPosition);
  findings.sort((a, b) => (sheetOrder.get(a.sheet) ?? 0) - (sheetOrder.get(b.sheet) ?? 0) || (a.row ?? 0) - (b.row ?? 0));

  const sortedById = {};
  for (const id of [...byEgoId.keys()].sort()) sortedById[id] = byEgoId.get(id);

  // Value cross-check: does the sheet's `4-9` agree with any range the source
  // derives? This checks *our* value model as much as the sheet —
  // `mbonus_material(max, add)` was once read as `add + level * max`, and this
  // comparison is what settles it (the sheet's `5-15` is `add .. add + max`).
  // A disagreement is recorded, never applied: the page always shows the
  // source-derived numbers.
  const valueConflicts = [];
  for (const [id, row] of Object.entries(sortedById)) {
    const ego = egoById.get(id);
    if (!ego || !row.effect) continue;
    const sheetRanges = sheetNumberRanges(row.effect);
    const sourceRanges = egoValueRanges(ego);
    if (!sheetRanges.length || !sourceRanges.length) continue;
    if (sheetRanges.some(([lo, hi]) => sourceRanges.some(([a, b]) => near(a, lo) && near(b, hi)))) continue;
    valueConflicts.push({
      sheet: row.sheet,
      row: row.row,
      rawName: row.rawName,
      egoId: id,
      effect: row.effect,
      sheetRanges,
      sourceRanges,
    });
  }
  valueConflicts.sort(byPosition);

  const rowCount = stats.reduce((sum, entry) => sum + entry.rows, 0);
  const data = {
    generatedAt: new Date().toISOString(),
    source: {
      file: DEFAULT_XLSX,
      sheetCount: (workbook?.sheets ?? []).length,
      rowCount,
    },
    byEgoId: sortedById,
    extra,
    conflicts,
    valueConflicts,
  };
  return { data, findings, stats, closures };
}

/** `10-25移速/5-15命中` -> `[[10, 25], [5, 15]]`. */
export function sheetNumberRanges(effect) {
  return [...String(effect).matchAll(/(\d+(?:\.\d+)?)\s*[-~]\s*(\d+(?:\.\d+)?)/g)]
    .map((match) => [Number(match[1]), Number(match[2])]);
}

/** Every statically known range on an ego, in the units the page prints. */
export function egoValueRanges(ego) {
  const out = [];
  for (const area of ego.areas ?? []) {
    for (const prop of area.props ?? []) {
      const members = prop.items?.length ? prop.items : [prop];
      for (const item of members) {
        if (item.range) out.push(item.range);
        for (const range of item.materialRanges ?? []) out.push(range);
      }
    }
  }
  return out;
}

/** Ranges are quoted to whole numbers on the sheet; allow the rounding gap. */
function near(a, b) {
  return Math.abs(a - b) < 0.51;
}

/** Render the review report. Deterministic given the analysis. */
export function renderReport(analysis, options = {}) {
  const { data, findings, stats, closures = [] } = analysis;
  const sourceFile = options.sourceFile ?? data.source.file;
  const matched = Object.keys(data.byEgoId).length;
  const updated = Object.values(data.byEgoId).filter((entry) => entry.updated).length;
  const rows = stats.reduce((sum, entry) => sum + entry.rows, 0);
  const matchedRows = stats.reduce((sum, entry) => sum + entry.matched, 0);
  const sharedRows = stats.reduce((sum, entry) => sum + (entry.shared ?? 0), 0);
  const sharedPoolRecords = Object.values(data.byEgoId).filter((entry) => entry.confidence === 'shared-pool').length;

  const lines = [];
  lines.push('# 物品词缀社区补充表导入报告');
  lines.push('');
  lines.push('由 `scripts/items/community.mjs` 生成，请勿手工编辑。');
  lines.push('');
  lines.push('## 总览');
  lines.push('');
  lines.push(`- 生成时间：${data.generatedAt}`);
  lines.push(`- 来源文件：\`${sourceFile}\``);
  lines.push(`- 工作表数：${data.source.sheetCount}`);
  lines.push(`- 数据行（词缀名非空）：${rows}`);
  lines.push(`- 匹配到 ego 的行：${matchedRows}（其中仅经共享池匹配：${sharedRows}）`);
  lines.push(`- 未匹配行：${data.extra.length}`);
  lines.push(`- 稀有度冲突：${data.conflicts.length}`);
  lines.push(`- 数值区间对不上：${(data.valueConflicts ?? []).length}`);
  lines.push(`- 写入 ego 记录：${matched}（其中 \`confidence: shared-pool\`：${sharedPoolRecords}）`);
  lines.push(`- 其中被标记 \`updated\`：${updated}`);
  lines.push('');

  lines.push('## 匹配口径');
  lines.push('');
  lines.push('1. 工作表名映射到一个「本池」（见下表）。');
  lines.push('2. 允许池集合由 `public/data/items-report.json` 的 `pools[].loads` 派生，不硬编码，包含三部分：本池本身 ∪ 本池加载的池（传递闭包）∪ 加载本池的池。');
  lines.push('   - 加载闭包：`heavy-armor` 加载 `armor`，所以重甲/板甲/轻甲可以出普通护甲（armor）词缀；');
  lines.push('   - 反向的「加载本池」：`bow`/`sling` 加载 `ranged`，所以远程武器表可以覆盖弓/投石索专属词缀；`light-boots` 加载 `boots`，所以鞋子表的「潜行」有归属。');
  lines.push('   - 有意排除「兄弟池」：`steamsaw` 同时加载 `weapon` 和 `shield`，但普通长剑不是盾，因此近战武器表不会拉入 shield 专有词缀（盾牌表同理），否则共享中文名会产生错误匹配。');
  lines.push('3. 一个 ego 命中，当且仅当其**所属池** `ego.pool`（定义它的文件）属于允许池集合。不使用 `ego.pools`（可达集）求交集——可达集包含兄弟池，会造成上面那条的越界匹配；`ego.pool` 同时用于报告。');
  lines.push('4. 置信度取值：');
  lines.push('   - `high`：本池直接命中（`ego.pool === 本池`）；');
  lines.push('   - `shared-pool`：经共享池命中（`ego.pool` 属于允许集合但不是本池，例如 armor 词缀落在重甲/板甲/轻甲上）；');
  lines.push('   - `medium`：允许池内有多个同名 ego，整行记给全部候选。');
  lines.push('5. 允许池集合之外的任何池都不会被匹配；未命中行仍带跨池同名线索进入「未匹配行」供人工排查。');
  lines.push('');

  lines.push('## 允许池集合（本池 ∪ 加载闭包 ∪ 加载本池的池）');
  lines.push('');
  lines.push('| 工作表 | 本池 | 允许池集合 |');
  lines.push('| --- | --- | --- |');
  for (const entry of closures) {
    lines.push(`| ${entry.sheet} | ${entry.pool ?? '—'} | ${entry.allowed.length > 0 ? entry.allowed.join('、') : '—'} |`);
  }
  lines.push('');

  lines.push('## 每个工作表');
  lines.push('');
  lines.push('| 工作表 | 词缀池 | 数据行 | 已匹配 | 本池命中 | 共享池命中 | 未匹配 |');
  lines.push('| --- | --- | ---: | ---: | ---: | ---: | ---: |');
  for (const entry of stats) {
    lines.push(`| ${entry.sheet} | ${entry.pool ?? '—'} | ${entry.rows} | ${entry.matched} | ${entry.own ?? 0} | ${entry.shared ?? 0} | ${entry.unmatched} |`);
  }
  lines.push('');

  lines.push('## 稀有度冲突（Excel vs 源数据）');
  lines.push('');
  lines.push('以源数据 `egos.json` 的 `rarity` 为准；下表仅为证据，不会写回 ego。');
  lines.push('');
  if (data.conflicts.length === 0) {
    lines.push('（无）');
  } else {
    lines.push('| 工作表 | 行 | 词缀名 | ego | Excel 稀有度 | 源稀有度 | 置信度 |');
    lines.push('| --- | ---: | --- | --- | ---: | ---: | --- |');
    for (const conflict of data.conflicts) {
      lines.push(`| ${conflict.sheet} | ${conflict.row} | ${conflict.rawName} | \`${conflict.egoId}\` | ${conflict.excelRarity} | ${conflict.sourceRarity} | ${conflict.confidence} |`);
    }
  }
  lines.push('');

  lines.push('## 数值区间交叉核对（Excel 文本 vs 源码推导）');
  lines.push('');
  lines.push('把 Excel「效果」列里的 `a-b` 数字区间与源码推导出的区间逐一比对。一致即不列出；列出的行表示两边对不上，**页面一律显示源码推导值**。');
  lines.push('这项工作同时是对本站数值模型的检验：`mbonus_material(max, add)` 的区间是 `add ~ add + max`（源码 `ceil(rng.mbonus(max, level, 90) * ml / 5) + add`），不是 `add + 材料等级 × max`。');
  lines.push('');
  if ((data.valueConflicts ?? []).length === 0) {
    lines.push('（无）');
  } else {
    lines.push('| 工作表 | 行 | 词缀名 | ego | Excel 效果 | Excel 区间 | 源码区间 |');
    lines.push('| --- | ---: | --- | --- | --- | --- | --- |');
    for (const conflict of data.valueConflicts) {
      const fmt = (ranges) => ranges.map(([lo, hi]) => `${lo}~${hi}`).join('、');
      lines.push(`| ${conflict.sheet} | ${conflict.row} | ${conflict.rawName} | \`${conflict.egoId}\` | ${conflict.effect} | ${fmt(conflict.sheetRanges)} | ${fmt(conflict.sourceRanges)} |`);
    }
  }
  lines.push('');

  lines.push('## 未匹配行');
  lines.push('');
  lines.push('这些行的中文名在「本池 ∪ 加载闭包」内找不到 ego。`跨池同名候选` 是允许池集合之外的同名 ego，仅作排查线索，绝不会被自动匹配。');
  lines.push('');
  if (data.extra.length === 0) {
    lines.push('（无）');
  } else {
    lines.push('| 工作表 | 行 | 词缀名 | 效果 | 跨池同名候选 |');
    lines.push('| --- | ---: | --- | --- | --- |');
    for (const row of data.extra) {
      const cross = row.crossPool.length === 0
        ? '—'
        : row.crossPool.map((candidate) => `${candidate.id}`).join('<br>');
      lines.push(`| ${row.sheet} | ${row.row} | ${row.rawName} | ${row.effect.replace(/\|/g, '\\|')} | ${cross} |`);
    }
  }
  lines.push('');

  lines.push('## 数据质量发现');
  lines.push('');
  const duplicates = findings.filter((finding) => finding.type === 'duplicate-row');
  const misaligned = findings.filter((finding) => finding.type === 'name-effect-misalignment');
  const ambiguous = findings.filter((finding) => finding.type === 'ambiguous-name');
  const duplicatedMatches = findings.filter((finding) => finding.type === 'duplicate-match');
  const sharedMatches = findings.filter((finding) => finding.type === 'shared-match');
  const other = findings.filter((finding) => ['duplicate-row', 'name-effect-misalignment', 'ambiguous-name', 'duplicate-match', 'shared-match'].includes(finding.type) === false);

  lines.push('### 完全重复的行');
  lines.push('');
  if (duplicates.length === 0) {
    lines.push('（无）');
  } else {
    for (const finding of duplicates) {
      lines.push(`- ${finding.sheet} 第 ${finding.rows.join('、')} 行：\`${finding.rawName}\`，${finding.message}。`);
    }
  }
  lines.push('');

  lines.push('### 词缀名与效果错位');
  lines.push('');
  lines.push('判定方式：名称匹配到的 ego 按其源 `keyword` 应有伤害类型词，若该行效果里出现的是另一个伤害类型词，则为错位。');
  lines.push('');
  if (misaligned.length === 0) {
    lines.push('（无）');
  } else {
    lines.push('| 工作表 | 行 | 词缀名 | ego | 应有伤害类型 | 效果中的伤害类型 |');
    lines.push('| --- | ---: | --- | --- | --- | --- |');
    for (const finding of misaligned) {
      lines.push(`| ${finding.sheet} | ${finding.row} | ${finding.rawName} | \`${finding.egoId}\` | ${finding.expectedEffectTerm} | ${finding.actualEffectTerm} |`);
    }
  }
  lines.push('');

  lines.push('### 池内同名（多个 ego 共享同一中文名）');
  lines.push('');
  if (ambiguous.length === 0) {
    lines.push('（无）');
  } else {
    lines.push('| 工作表 | 行 | 词缀名 | 词缀池 | 候选 ego |');
    lines.push('| --- | ---: | --- | --- | --- |');
    for (const finding of ambiguous) {
      lines.push(`| ${finding.sheet} | ${finding.row} | ${finding.rawName} | ${finding.pool} | ${finding.egoIds.map((id) => `\`${id}\``).join('<br>')} |`);
    }
    lines.push('');
    lines.push('这些行整行记给全部候选，置信度标记为 `medium`。');
  }
  lines.push('');

  lines.push('### 共享池：同一个 ego 被多个工作表命中');
  lines.push('');
  lines.push('这是预期行为：共享池词缀（如 armor）在重甲/板甲/轻甲上都会出现。`byEgoId` 每个 ego 只保留首行记录，其余工作表出处列在下面。');
  lines.push('');
  if (sharedMatches.length === 0) {
    lines.push('（无）');
  } else {
    lines.push('| ego | 所属池 | 命中的工作表与行 |');
    lines.push('| --- | --- | --- |');
    for (const finding of sharedMatches) {
      const refs = finding.matches.map((match) => `${match.sheet} ${match.row}`).join('<br>');
      lines.push(`| \`${finding.egoId}\` | ${finding.pool ?? '—'} | ${refs} |`);
    }
  }
  lines.push('');

  lines.push('### 一个 ego 被同一工作表的多行命中');
  lines.push('');
  if (duplicatedMatches.length === 0) {
    lines.push('（无）');
  } else {
    for (const finding of duplicatedMatches) {
      lines.push(`- ${finding.sheet} 第 ${finding.row} 行 \`${finding.rawName}\` 与 ${finding.firstSheet} 第 ${finding.firstRow} 行指向同一个 \`${finding.egoId}\`；仅首行写入 \`byEgoId\`。`);
    }
  }
  lines.push('');

  if (other.length > 0) {
    lines.push('### 其他');
    lines.push('');
    for (const finding of other) {
      lines.push(`- ${finding.sheet ?? '—'}${finding.row ? ` 第 ${finding.row} 行` : ''}：${finding.message}`);
    }
    lines.push('');
  }

  return `${lines.join('\n')}\n`;
}

/** Locate the spreadsheet, preferring an explicit argument and the workspace copy. */
export function resolveXlsx(explicit) {
  const candidates = [
    explicit,
    process.env.EGO_COMMUNITY_XLSX,
    path.join(WORKSPACE_ROOT, DEFAULT_XLSX),
    path.join(REPO_ROOT, DEFAULT_XLSX),
  ].filter(Boolean);
  for (const candidate of candidates) {
    const full = path.resolve(candidate);
    if (fs.existsSync(full)) return full;
  }
  throw new Error(`找不到物品词缀表，请传入路径或放到 ${path.join(WORKSPACE_ROOT, DEFAULT_XLSX)}`);
}

function writeJson(file, value) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, `${JSON.stringify(value, null, 2)}\n`);
}

/** Read the workbook and dataset, write both outputs, print a short summary. */
export function main(argv = process.argv.slice(2)) {
  const xlsxFile = resolveXlsx(argv[0]);
  const egosFile = path.join(REPO_ROOT, 'public/data/egos.json');
  const outFile = path.join(REPO_ROOT, 'public/data/ego-community.json');
  const reportFile = path.join(REPO_ROOT, 'docs/items-community-report.md');

  const workbook = readWorkbook(xlsxFile);
  const egos = JSON.parse(fs.readFileSync(egosFile, 'utf8')).egos ?? [];
  const poolLoads = loadPoolGraph();
  const analysis = analyzeCommunity(workbook, egos, { poolLoads });

  const relative = path.relative(WORKSPACE_ROOT, xlsxFile);
  const sourceFile = relative.startsWith('..') ? path.basename(xlsxFile) : relative.split(path.sep).join('/');
  analysis.data.source.file = sourceFile;

  writeJson(outFile, analysis.data);
  fs.mkdirSync(path.dirname(reportFile), { recursive: true });
  fs.writeFileSync(reportFile, renderReport(analysis, { sourceFile }));

  const rows = analysis.stats.reduce((sum, entry) => sum + entry.rows, 0);
  const matchedRows = analysis.stats.reduce((sum, entry) => sum + entry.matched, 0);
  const sharedRows = analysis.stats.reduce((sum, entry) => sum + (entry.shared ?? 0), 0);
  console.log(`[community] ${path.basename(xlsxFile)}: ${workbook.sheets.length} 个工作表，${rows} 行数据，加载图 ${poolLoads.size} 池`);
  console.log(`[community] 匹配 ${matchedRows} 行（本池 ${matchedRows - sharedRows} / 共享池 ${sharedRows}） / ${Object.keys(analysis.data.byEgoId).length} 个 ego，未匹配 ${analysis.data.extra.length} 行，稀有度冲突 ${analysis.data.conflicts.length} 条，数值区间对不上 ${(analysis.data.valueConflicts ?? []).length} 条`);
  console.log(`[community] 输出 ${path.relative(REPO_ROOT, outFile)} 与 ${path.relative(REPO_ROOT, reportFile)}`);
  return analysis;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
