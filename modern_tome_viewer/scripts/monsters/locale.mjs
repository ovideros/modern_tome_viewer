/**
 * Chinese localisation reader for the ToME locale tables.
 *
 * The game's `data/locales/zh_hans.lua` is a long list of
 * `t("<english>", "<中文>", "<context>")` calls. Entity names, descriptions and
 * talent names are looked up here so the encyclopedia can show Chinese without
 * inventing a standalone translation table, and can report what is missing.
 */

import fs from 'node:fs';
import { tokenize } from './lua-table.mjs';

/**
 * Parse a locale file into an English -> Chinese map.
 *
 * Only `t(...)` calls whose first argument is a plain string are kept. A later
 * entry for the same English text wins, matching how the game replaces
 * duplicate translations as it loads the file.
 */
export function parseLocale(src, options = {}) {
  const tokens = tokenize(src);
  const map = new Map();
  const contexts = new Map();
  let entries = 0;

  for (let i = 0; i < tokens.length; i += 1) {
    const token = tokens[i];
    if (token.type !== 'name' || token.value !== 't') continue;
    const open = tokens[i + 1];
    if (open?.type !== 'punct' || open.value !== '(') continue;
    const first = tokens[i + 2];
    if (first?.type !== 'string') continue;
    const comma = tokens[i + 3];
    if (comma?.type !== 'punct' || comma.value !== ',') continue;
    const second = tokens[i + 4];
    if (second?.type !== 'string') continue;

    const en = first.value;
    const zh = second.value;
    if (!en || !zh || en === zh) continue;
    map.set(en, zh);
    const context = tokens[i + 6];
    if (context?.type === 'string') contexts.set(en, context.value);
    entries += 1;
  }

  return { map, contexts, entries, file: options.file ?? null };
}

/** Read and parse a locale file from disk. */
export function readLocale(file) {
  if (!file || !fs.existsSync(file)) return { map: new Map(), contexts: new Map(), entries: 0, file: file ?? null, missing: true };
  return parseLocale(fs.readFileSync(file, 'utf8'), { file });
}

/** Merge several parsed locales; later files win. */
export function mergeLocales(...locales) {
  const map = new Map();
  const contexts = new Map();
  let entries = 0;
  const files = [];
  for (const locale of locales) {
    if (!locale) continue;
    for (const [k, v] of locale.map) map.set(k, v);
    for (const [k, v] of locale.contexts) contexts.set(k, v);
    entries += locale.entries ?? 0;
    if (locale.file) files.push(locale.file);
  }
  return { map, contexts, entries, files };
}

/**
 * Translate a game string, returning the Chinese text plus how it was found.
 *
 * `status` is `exact` for a direct hit, `english` when the text already looks
 * Chinese (no translation needed), and `missing` when only English is known.
 */
export function translate(localeMap, text) {
  if (typeof text !== 'string' || !text) return { text: text ?? '', status: 'missing' };
  if (/[\u4e00-\u9fff]/.test(text)) return { text, status: 'native' };
  const hit = localeMap.get(text);
  if (hit) return { text: hit, status: 'exact' };
  return { text, status: 'missing' };
}
