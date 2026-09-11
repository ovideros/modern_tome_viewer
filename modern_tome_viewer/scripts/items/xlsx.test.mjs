/**
 * Tests for the minimal XLSX reader and the community affix join.
 *
 * Run: node --test scripts/items/xlsx.test.mjs
 *
 * WHY a local ZIP writer: `ZipArchive` is read-only by design, so the smallest
 * trustworthy fixture is a hand-built stored-entry ZIP. Building it here (rather
 * than adding a writer to production code) keeps `scripts/items/xlsx.mjs`
 * read-only, while still exercising the real central-directory code path.
 *
 * The real-workbook cases are skipped when the spreadsheet is not on disk; they
 * are what pins the three spreadsheet defects the community table is known to
 * contain, so a future re-export that fixes them fails loudly here.
 */

import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { columnIndex, decodeXmlText, readWorkbook } from './xlsx.mjs';
import { EXPECTED_SHEETS, analyzeCommunity, allowedPoolsFor, loadPoolGraph, parseSheetTable, resolveXlsx } from './community.mjs';

// ---------------------------------------------------------------------------
// Minimal stored-entry ZIP writer (test-only)
// ---------------------------------------------------------------------------

const CRC_TABLE = (() => {
  const table = new Uint32Array(256);
  for (let i = 0; i < 256; i += 1) {
    let value = i;
    for (let bit = 0; bit < 8; bit += 1) {
      value = value & 1 ? 0xedb88320 ^ (value >>> 1) : value >>> 1;
    }
    table[i] = value >>> 0;
  }
  return table;
})();

function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) crc = CRC_TABLE[(crc ^ byte) & 0xff] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}

/** Build a ZIP whose entries are all method 0 (stored), which `ZipArchive` reads. */
function buildZip(files) {
  const localParts = [];
  const centralParts = [];
  let offset = 0;

  for (const [name, content] of files) {
    const nameBytes = Buffer.from(name, 'utf8');
    const data = Buffer.isBuffer(content) ? content : Buffer.from(content, 'utf8');
    const crc = crc32(data);

    const local = Buffer.alloc(30);
    local.writeUInt32LE(0x04034b50, 0);
    local.writeUInt16LE(20, 4); // version needed
    local.writeUInt16LE(0, 8); // method 0
    local.writeUInt32LE(crc, 14);
    local.writeUInt32LE(data.length, 18);
    local.writeUInt32LE(data.length, 22);
    local.writeUInt16LE(nameBytes.length, 26);
    localParts.push(local, nameBytes, data);

    const central = Buffer.alloc(46);
    central.writeUInt32LE(0x02014b50, 0);
    central.writeUInt16LE(20, 4); // version made by
    central.writeUInt16LE(20, 6); // version needed
    central.writeUInt16LE(0, 10); // method 0
    central.writeUInt32LE(crc, 16);
    central.writeUInt32LE(data.length, 20);
    central.writeUInt32LE(data.length, 24);
    central.writeUInt16LE(nameBytes.length, 28);
    central.writeUInt32LE(offset, 42);
    centralParts.push(central, nameBytes);

    offset += local.length + nameBytes.length + data.length;
  }

  const centralDirectory = Buffer.concat(centralParts);
  const eocd = Buffer.alloc(22);
  eocd.writeUInt32LE(0x06054b50, 0);
  eocd.writeUInt16LE(files.length, 8);
  eocd.writeUInt16LE(files.length, 10);
  eocd.writeUInt32LE(centralDirectory.length, 12);
  eocd.writeUInt32LE(offset, 16);

  return Buffer.concat([...localParts, centralDirectory, eocd]);
}

const XMLNS = 'xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"';

/** Write a fixture ZIP to a fresh temp dir and return its path plus a cleanup. */
function writeFixture(t, buffer) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'ego-xlsx-'));
  const file = path.join(dir, 'fixture.xlsx');
  fs.writeFileSync(file, buffer);
  t.after(() => fs.rmSync(dir, { recursive: true, force: true }));
  return file;
}

function fixtureWorkbook() {
  return buildZip([
    [
      'xl/workbook.xml',
      `<?xml version="1.0"?><workbook ${XMLNS}><sheets>`
        + '<sheet name="第一" sheetId="1" r:id="rId2"/>'
        + '<sheet name="第二" sheetId="2" r:id="rId1"/>'
        + '</sheets></workbook>',
    ],
    [
      'xl/_rels/workbook.xml.rels',
      '<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        + '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/second.xml"/>'
        + '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/first.xml"/>'
        + '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>'
        + '</Relationships>',
    ],
    [
      'xl/sharedStrings.xml',
      `<?xml version="1.0"?><sst ${XMLNS}>`
        + '<si><t>alpha</t></si>'
        + '<si><r><t>rich</t></r><r><t> text</t></r></si>'
        + '<si><t>a&amp;b&lt;c</t></si>'
        + '<si><t/></si>'
        + '</sst>',
    ],
    [
      'xl/worksheets/first.xml',
      `<?xml version="1.0"?><worksheet ${XMLNS}><sheetData>`
        + '<row r="1"><c r="A1" t="s"><v>0</v></c><c r="C1" t="inlineStr"><is><t>gamma</t></is></c><c r="E1"><v>42</v></c></row>'
        + '<row r="3"><c r="B3" t="s"><v>1</v></c></row>'
        + '<row r="4"><c r="A4" t="str"><v>formula-result</v></c><c r="B4" t="b"><v>1</v></c><c r="C4" t="weird"><v>ignored</v></c><c r="D4" t="s"><v>0</v></c></row>'
        + '<row r="5"><c t="inlineStr"><is><r><t>inline</t></r><r><t>rich</t></r></is></c><c t="s"><v>2</v></c></row>'
        + '<row r="6"><c r="A6" t="s"/><c r="B6" t="inlineStr"/></row>'
        + '</sheetData></worksheet>',
    ],
    [
      'xl/worksheets/second.xml',
      `<?xml version="1.0"?><worksheet ${XMLNS}><sheetData>`
        + '<row r="1"><c r="A1" t="inlineStr"><is><t>second</t></is></c></row>'
        + '</sheetData></worksheet>',
    ],
  ]);
}

// ---------------------------------------------------------------------------
// Reader unit tests
// ---------------------------------------------------------------------------

test('columnIndex maps references to 0-based columns and rejects gaps', () => {
  assert.equal(columnIndex('A1'), 0);
  assert.equal(columnIndex('C5'), 2);
  assert.equal(columnIndex('AA1'), 26);
  assert.equal(columnIndex('AB10'), 27);
  assert.equal(columnIndex(null), -1);
  assert.equal(columnIndex('5'), -1);
});

test('decodeXmlText handles named and numeric entities once', () => {
  assert.equal(decodeXmlText('a&amp;b&lt;c&gt;d&quot;e&apos;f'), 'a&b<c>d"e\'f');
  assert.equal(decodeXmlText('&#65;&#x42;'), 'AB');
  assert.equal(decodeXmlText('&amp;lt;'), '&lt;');
});

test('places sparse, shared, inline and numeric cells in their own columns', (t) => {
  const file = writeFixture(t, fixtureWorkbook());
  const workbook = readWorkbook(file);

  // Sheet order follows workbook.xml, and the part is reached through the
  // relationship id — not by assuming sheetN.xml matches tab N.
  assert.deepEqual(workbook.sheets.map((sheet) => sheet.name), ['第一', '第二']);
  assert.equal(workbook.sheets[0].path, 'xl/worksheets/first.xml');

  const rows = workbook.sheets[0].rows;
  // Shared (A1), inline (C1) and numeric (E1); B1/D1 stay empty instead of
  // shifting gamma/42 left.
  assert.deepEqual(rows[0], ['alpha', null, 'gamma', null, '42']);
  // Excel row 2 has no element: it must still occupy index 1.
  assert.deepEqual(rows[1], []);
  // A lone B3 cell keeps its column.
  assert.deepEqual(rows[2], [null, 'rich text']);
  // str, boolean, an unknown `t` that must not throw and must not be kept, and
  // a following shared string proving the unknown cell left its column empty.
  assert.deepEqual(rows[3], ['formula-result', '1', null, 'alpha']);
  // Cells without an `r` attribute fall back to document order.
  assert.deepEqual(rows[4], ['inlinerich', 'a&b<c']);
  // Cells present but without a value collapse to an empty row.
  assert.deepEqual(rows[5], []);

  assert.deepEqual(workbook.sheets[1].rows, [['second']]);
});

// ---------------------------------------------------------------------------
// Real workbook tests (skipped when the spreadsheet is absent)
// ---------------------------------------------------------------------------

/** Absolute path of the real spreadsheet, or null when it is not on disk. */
function realWorkbookFile() {
  try {
    return resolveXlsx();
  } catch {
    return null;
  }
}

const REAL_XLSX = realWorkbookFile();
const REAL_EGOS = fileURLToPath(new URL('../../public/data/egos.json', import.meta.url));
const SKIP = REAL_XLSX && fs.existsSync(REAL_EGOS) ? false : '未找到真实词缀表或 egos.json';

test('real workbook has the 20 sheets in tab order', { skip: SKIP }, () => {
  const workbook = readWorkbook(REAL_XLSX);
  assert.equal(workbook.sheets.length, 20);
  assert.deepEqual(workbook.sheets.map((sheet) => sheet.name), EXPECTED_SHEETS);
});

test('real workbook exposes at least 500 data rows with stable row numbers', { skip: SKIP }, () => {
  const workbook = readWorkbook(REAL_XLSX);
  let total = 0;
  for (const sheet of workbook.sheets) {
    const table = parseSheetTable(sheet);
    total += table.rows.length;
    // Every data row cites the Excel row it came from: leading note rows shift
    // 近战武器 to header row 2 and data row 3.
    if (sheet.name === '近战武器') {
      assert.equal(table.headerRow, 2);
      assert.equal(table.rows[0].row, 3);
      assert.equal(table.rows[0].rawName, '平衡');
    }
  }
  assert.ok(total >= 500, `expected >= 500 data rows, got ${total}`);
});

test('real workbook reproduces the three known spreadsheet defects', { skip: SKIP }, () => {
  const workbook = readWorkbook(REAL_XLSX);
  const egos = JSON.parse(fs.readFileSync(REAL_EGOS, 'utf8')).egos;
  const analysis = analyzeCommunity(workbook, egos);

  // 1. 法袍 rows 3 and 4 are byte-identical 冰冻 rows.
  const duplicate = analysis.findings.find((finding) => finding.type === 'duplicate-row' && finding.sheet === '法袍');
  assert.ok(duplicate, '法袍 duplicate rows must be reported');
  assert.deepEqual(duplicate.rows, [3, 4]);
  assert.equal(duplicate.rawName, '冰冻');

  const robe = parseSheetTable(workbook.sheets.find((sheet) => sheet.name === '法袍'));
  const [row3, row4] = [robe.rows[1], robe.rows[2]];
  assert.notEqual(row3, undefined);
  assert.notEqual(row4, undefined);
  assert.equal(row3.row, 3);
  assert.equal(row4.row, 4);
  assert.deepEqual(row3.cells, row4.cells);

  // 2. 近战武器 row 5 强酸 says 10, tome:weapon:acidic sources 5.
  const conflict = analysis.data.conflicts.find((entry) => entry.sheet === '近战武器' && entry.row === 5);
  assert.ok(conflict, '强酸 rarity conflict must be reported');
  assert.equal(conflict.egoId, 'tome:weapon:acidic');
  assert.equal(conflict.excelRarity, '10');
  assert.equal(conflict.sourceRarity, 5);
  assert.equal(analysis.data.byEgoId['tome:weapon:acidic'].updated, true);
  assert.equal(analysis.data.byEgoId['tome:weapon:acidic'].rarity, '10');

  // 3. 法师帽 rows 5/6/8 pair a name with the wrong damage type.
  const misaligned = analysis.findings
    .filter((finding) => finding.type === 'name-effect-misalignment' && finding.sheet === '法师帽')
    .map((finding) => ({ row: finding.row, name: finding.rawName, expected: finding.expectedEffectTerm, actual: finding.actualEffectTerm }));
  assert.deepEqual(misaligned, [
    { row: 5, name: '光系', expected: '光系', actual: '闪电' },
    { row: 6, name: '暗影', expected: '暗影', actual: '光系' },
    { row: 8, name: '腐蚀', expected: '酸性', actual: '暗影' },
  ]);

  // The join itself must stay conservative and complete: source rarity wins and
  // every data row is accounted for.
  const rows = analysis.stats.reduce((sum, entry) => sum + entry.rows, 0);
  assert.equal(rows, analysis.stats.reduce((sum, entry) => sum + entry.matched + entry.unmatched, 0));
  assert.ok(Object.keys(analysis.data.byEgoId).length > 400);
  assert.ok(analysis.data.extra.length > 0);
});

test('allowed pools follow the derived load graph, not sibling reachability', { skip: SKIP }, () => {
  const graph = loadPoolGraph();
  const allowed = (pool) => [...allowedPoolsFor(pool, graph)].sort();

  // Descendants: heavy/massive/light armour all load the plain `armor` pool.
  assert.deepEqual(allowed('heavy-armor'), ['armor', 'heavy-armor']);
  assert.deepEqual(allowed('massive-armor'), ['armor', 'massive-armor']);
  assert.deepEqual(allowed('light-armor'), ['armor', 'light-armor']);

  // Ancestors: bow/sling/steamgun load `ranged`, so 远程武器 covers their own
  // affixes; light-boots loads `boots`.
  assert.deepEqual(allowed('ranged'), ['bow', 'ranged', 'sling', 'steamgun']);
  assert.deepEqual(allowed('boots'), ['boots', 'light-boots']);

  // Siblings are excluded on purpose: steamsaw loads weapon AND shield, but a
  // longsword is not a shield. Matching on `pools` reachability would leak
  // 盾牌's shield-only egos into 近战武器 (and the reverse).
  assert.deepEqual(allowed('weapon'), ['steamsaw', 'weapon']);
  assert.deepEqual(allowed('shield'), ['shield', 'steamsaw']);
});

test('shared armour/ranged pools match without contaminating other sheets', { skip: SKIP }, () => {
  const workbook = readWorkbook(REAL_XLSX);
  const egos = JSON.parse(fs.readFileSync(REAL_EGOS, 'utf8')).egos;
  const analysis = analyzeCommunity(workbook, egos, { poolLoads: loadPoolGraph() });
  const stat = (sheet) => analysis.stats.find((entry) => entry.sheet === sheet);

  // Armour sheets now resolve every row, most through the shared `armor` pool.
  for (const sheet of ['重甲', '板甲', '轻甲']) {
    assert.equal(stat(sheet).unmatched, 0, `${sheet} must match every row`);
    assert.ok(stat(sheet).shared > 0, `${sheet} must include shared-pool hits`);
  }
  assert.equal(analysis.data.byEgoId['tome:armor:fire res'].confidence, 'shared-pool');
  assert.equal(analysis.data.byEgoId['tome:heavy-armor:impenetrable'].confidence, 'high');

  // Ranged row 3 灵巧 is sling-only and row 4 敏捷 is bow-only.
  assert.equal(analysis.data.byEgoId['tome:sling:cun'].sheet, '远程武器');
  assert.equal(analysis.data.byEgoId['tome:sling:cun'].confidence, 'shared-pool');
  assert.equal(analysis.data.byEgoId['tome:bow:dex'].sheet, '远程武器');
  assert.equal(analysis.data.byEgoId['tome:bow:dex'].confidence, 'shared-pool');

  // Boots row 4 潜行 lives in the light-boots pool that loads `boots`.
  assert.equal(analysis.data.byEgoId['tome:light-boots:stealth'].confidence, 'shared-pool');

  // The steamsaw bridge must NOT leak shield egos into 近战武器 (nor weapon egos
  // into 盾牌). This is the regression guard for a `pools`-intersection rule:
  // it would add shield:acidic to 近战武器 row 5 and weapon:enhanced:greater to
  // 盾牌 row 2, each producing a spurious rarity conflict.
  const weaponAcid = analysis.data.conflicts.filter((entry) => entry.sheet === '近战武器' && entry.row === 5);
  assert.deepEqual(weaponAcid.map((entry) => entry.egoId), ['tome:weapon:acidic']);
  assert.equal(analysis.data.byEgoId['tome:shield:acidic'].sheet, '盾牌');
  assert.deepEqual(analysis.data.conflicts.filter((entry) => entry.sheet === '盾牌' && entry.row === 2), []);
  assert.equal(analysis.data.conflicts.length, 14);

  // No new name/effect misalignment outside the three known wizard-hat rows.
  const misaligned = analysis.findings
    .filter((finding) => finding.type === 'name-effect-misalignment')
    .map((finding) => `${finding.sheet}:${finding.row}`);
  assert.deepEqual(misaligned, ['法师帽:5', '法师帽:6', '法师帽:8']);

  // The same shared ego is legitimately reported from several sheets.
  const shared = analysis.findings.filter((finding) => finding.type === 'shared-match');
  assert.ok(shared.some((finding) => finding.egoId === 'tome:armor:fire res' && finding.sheets.length === 3));
});
