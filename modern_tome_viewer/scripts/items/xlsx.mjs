/**
 * Minimal read-only XLSX reader.
 *
 * WHY this exists: the community affix tables arrive as `.xlsx`, but no
 * spreadsheet library may be added as a dependency, and the only thing that is
 * genuinely needed is a sheet-name/row-grid view with the original cell
 * references intact. An `.xlsx` is a ZIP of OOXML parts, and the ZIP layer is
 * already implemented for the monster art pipeline (`ZipArchive`), so this
 * module only adds the XML side.
 *
 * WHY cell references matter: the community sheets are sparse — a blank 备注 or
 * an omitted 推荐度 cell simply has no `<c>` element. Expanding cells in
 * document order would shift 稀有度 into 效果 and silently corrupt every
 * downstream comparison, so each cell is placed by its own `r="C5"` reference
 * and rows are placed by their `r` attribute. Row `i` in the returned grid
 * therefore always corresponds to Excel row `i + 1`, which lets the report cite
 * real sheet/row evidence.
 */

import { ZipArchive } from '../monsters/images.mjs';

const WORKBOOK_PART = 'xl/workbook.xml';
const RELS_PART = 'xl/_rels/workbook.xml.rels';
const SHARED_STRINGS_PART = 'xl/sharedStrings.xml';

/** Read an attribute value out of an element's raw attribute string. */
function attrValue(attrs, name) {
  const match = new RegExp(`(?:^|\\s)${name}="([^"]*)"`).exec(attrs ?? '');
  return match ? match[1] : null;
}

/**
 * Iterate the direct `<tag ...>body</tag>` elements of an XML fragment.
 *
 * Deliberately textual: OOXML's spreadsheet part is a flat, non-nesting list of
 * rows and cells, so scanning tags is both sufficient and dependency-free.
 * Self-closing tags yield an empty body instead of being skipped.
 */
function* elements(xml, tag) {
  const re = new RegExp(`<${tag}\\b([^>]*?)(\\/?)>`, 'g');
  let match;
  while ((match = re.exec(xml))) {
    if (match[2] === '/') {
      yield { attrs: match[1], body: '' };
      continue;
    }
    const end = xml.indexOf(`</${tag}>`, re.lastIndex);
    const body = end === -1 ? xml.slice(re.lastIndex) : xml.slice(re.lastIndex, end);
    re.lastIndex = end === -1 ? xml.length : end + tag.length + 3;
    yield { attrs: match[1], body };
  }
}

/** Decode the XML entities OOXML actually uses, including numeric ones. */
export function decodeXmlText(text) {
  const codePoint = (value) => {
    try {
      return String.fromCodePoint(value);
    } catch {
      return '';
    }
  };
  return String(text ?? '')
    .replace(/&#x([0-9a-fA-F]+);/g, (_, hex) => codePoint(Number.parseInt(hex, 16)))
    .replace(/&#(\d+);/g, (_, dec) => codePoint(Number.parseInt(dec, 10)))
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'")
    // `&amp;` is decoded last so `&amp;lt;` becomes the literal `&lt;`.
    .replace(/&amp;/g, '&');
}

/**
 * 0-based column index for a cell reference such as `C5`, or -1 when the
 * reference is absent/unreadable. Only the leading letters are used.
 */
export function columnIndex(ref) {
  const match = /^([A-Za-z]+)/.exec(String(ref ?? ''));
  if (!match) return -1;
  let index = 0;
  for (const letter of match[1].toUpperCase()) {
    index = index * 26 + (letter.charCodeAt(0) - 64);
  }
  return index - 1;
}

/** Concatenate every `<t>` run of a rich-text fragment (`<is>`, `<si>`). */
function textRuns(fragment) {
  // Phonetic hints are annotations, not cell text.
  const withoutPhonetics = String(fragment ?? '').replace(/<rPh\b[\s\S]*?<\/rPh>/g, '');
  let out = '';
  const re = /<t\b([^>]*?)(\/?)>/g;
  let match;
  while ((match = re.exec(withoutPhonetics))) {
    if (match[2] === '/') continue;
    const end = withoutPhonetics.indexOf('</t>', re.lastIndex);
    out += decodeXmlText(withoutPhonetics.slice(re.lastIndex, end === -1 ? withoutPhonetics.length : end));
    re.lastIndex = end === -1 ? withoutPhonetics.length : end + 4;
  }
  return out;
}

/** Inline `<v>` value of a cell, or null when there is none. */
function rawValue(body) {
  const match = /<v\b[^>]*?(\/?)>/.exec(body);
  if (!match) return null;
  if (match[1] === '/') return '';
  const end = body.indexOf('</v>', match.index + match[0].length);
  const text = body.slice(match.index + match[0].length, end === -1 ? body.length : end);
  return decodeXmlText(text);
}

/**
 * Shared-string table (`xl/sharedStrings.xml`).
 *
 * A shared string may be split across several `<t>` runs by rich-text
 * formatting; all runs are concatenated so a bolded word does not truncate the
 * affix name.
 */
export function parseSharedStrings(xml) {
  const out = [];
  if (!xml) return out;
  for (const item of elements(xml, 'si')) out.push(textRuns(item.body));
  return out;
}

/**
 * Resolve a relationship target against the `xl/` part directory.
 *
 * OOXML targets are either package-absolute (`/xl/worksheets/sheet1.xml`) or
 * relative to the source part's folder (`worksheets/sheet1.xml`), so both
 * spellings are normalised to a ZIP entry name.
 */
function resolvePart(target) {
  if (!target) return null;
  const segments = [];
  for (const segment of target.replace(/^\/+/, '').split('/')) {
    if (segment === '' || segment === '.') continue;
    if (segment === '..') segments.pop();
    else segments.push(segment);
  }
  const joined = segments.join('/');
  return joined ? (target.startsWith('/') ? joined : `xl/${joined}`) : null;
}

/** Map relationship id -> worksheet target (`rId3` -> `worksheets/sheet1.xml`). */
export function parseRelationships(xml) {
  const out = new Map();
  for (const rel of elements(xml ?? '', 'Relationship')) {
    const id = attrValue(rel.attrs, 'Id');
    const target = attrValue(rel.attrs, 'Target');
    if (id) out.set(id, target ?? null);
  }
  return out;
}

/** Text of one `<c>` cell, honouring shared/inline/formula/boolean cells. */
function cellValue(body, type, sharedStrings) {
  if (type === 'inlineStr') {
    const match = /<is\b[^>]*?(\/?)>/.exec(body);
    if (!match) return null;
    if (match[1] === '/') return '';
    const end = body.indexOf('</is>', match.index + match[0].length);
    const text = textRuns(body.slice(match.index + match[0].length, end === -1 ? body.length : end));
    return text === '' ? null : text;
  }
  const raw = rawValue(body);
  if (raw === null) return null;
  if (type === 's') {
    const index = Number.parseInt(raw, 10);
    return Number.isInteger(index) && index >= 0 && index < sharedStrings.length
      ? sharedStrings[index]
      : null;
  }
  // `n`/absent (number), `str` (formula result), `b` (boolean) and `e` (error)
  // all already arrive as display text. Any other/unknown `t` is intentionally
  // ignored rather than guessed at, so a future cell type can never throw.
  if (type === null || type === 'n' || type === 'str' || type === 'b' || type === 'e') {
    return raw === '' ? null : raw;
  }
  return null;
}

/** Parse a `<row>` body into a column-indexed cell array (nulls for gaps). */
function parseRow(body, sharedStrings) {
  const cells = [];
  let fallback = 0;
  for (const cell of elements(body, 'c')) {
    const reference = attrValue(cell.attrs, 'r');
    const column = columnIndex(reference);
    const index = column === -1 ? fallback : column;
    const value = cellValue(cell.body, attrValue(cell.attrs, 't'), sharedStrings);
    while (cells.length < index) cells.push(null);
    cells[index] = value;
    fallback = index + 1;
  }
  // Keep trailing empties out so an untouched row is `[]` and duplicate rows
  // compare equal by value.
  while (cells.length > 0 && cells[cells.length - 1] === null) cells.pop();
  return cells;
}

/**
 * Rows of one worksheet part. Row `i` maps to Excel row `i + 1` (gaps are
 * materialised as empty arrays), matching the `r` attributes in the sheet XML.
 */
export function parseSheet(xml, sharedStrings = []) {
  const rows = [];
  for (const row of elements(xml ?? '', 'row')) {
    const number = Number.parseInt(attrValue(row.attrs, 'r') ?? '', 10);
    const index = Number.isInteger(number) && number >= 1 ? number - 1 : rows.length;
    while (rows.length < index) rows.push([]);
    rows[index] = parseRow(row.body, sharedStrings);
  }
  return rows;
}

/**
 * Read a workbook into `{ sheets: [{ name, rows }] }`, in workbook tab order.
 *
 * Read-only and defensive: a missing relationship, part or shared-string table
 * degrades to empty rows rather than throwing, because a partially unreadable
 * workbook should surface as a report finding, not a crashed import.
 */
export function readWorkbook(file) {
  const zip = new ZipArchive(file);
  try {
    const part = (name) => (zip.has(name) ? zip.read(name)?.toString('utf8') ?? null : null);
    const sharedStrings = parseSharedStrings(part(SHARED_STRINGS_PART));
    const relationships = parseRelationships(part(RELS_PART));
    const sheets = [];
    for (const sheet of elements(part(WORKBOOK_PART) ?? '', 'sheet')) {
      const name = decodeXmlText(attrValue(sheet.attrs, 'name') ?? '');
      const target = resolvePart(relationships.get(attrValue(sheet.attrs, 'r:id')));
      const xml = target ? part(target) : null;
      sheets.push({ name, path: target, rows: parseSheet(xml ?? '', sharedStrings) });
    }
    return { sheets };
  } finally {
    zip.close();
  }
}
