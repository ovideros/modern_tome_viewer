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
 *
 * `byContext` keeps the third argument of each call — the tag the engine looks
 * up with `_t(text, tag)`. It matters for the few English words that mean
 * different things per context: `light` is 光系 as a damage type but 轻甲 as an
 * armour subtype, and the monster tooltip asks for the subtype table
 * (`mod/class/Actor.lua`: `_t(self.subtype, "entity subtype")`).
 */
export function parseLocale(src, options = {}) {
  const tokens = tokenize(src);
  const map = new Map();
  const contexts = new Map();
  const byContext = new Map();
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
    // `t(en, zh, tag)`: the tag only counts when it follows a real comma, so a
    // two-argument call is not misread by peeking at whatever comes next.
    const separator = tokens[i + 5];
    const contextToken = separator?.type === 'punct' && separator.value === ',' ? tokens[i + 6] : null;
    if (contextToken?.type === 'string') {
      const context = contextToken.value;
      contexts.set(en, context);
      let table = byContext.get(context);
      if (!table) byContext.set(context, (table = new Map()));
      table.set(en, zh);
    }
    entries += 1;
  }

  return { map, contexts, byContext, entries, file: options.file ?? null };
}

/** Read and parse a locale file from disk. */
export function readLocale(file) {
  if (!file || !fs.existsSync(file)) {
    return { map: new Map(), contexts: new Map(), byContext: new Map(), entries: 0, file: file ?? null, missing: true };
  }
  return parseLocale(fs.readFileSync(file, 'utf8'), { file });
}

/** Merge several parsed locales; later files win. */
export function mergeLocales(...locales) {
  const map = new Map();
  const contexts = new Map();
  const byContext = new Map();
  let entries = 0;
  const files = [];
  for (const locale of locales) {
    if (!locale) continue;
    for (const [k, v] of locale.map) map.set(k, v);
    for (const [k, v] of locale.contexts) contexts.set(k, v);
    for (const [context, table] of locale.byContext ?? []) {
      let merged = byContext.get(context);
      if (!merged) byContext.set(context, (merged = new Map()));
      for (const [k, v] of table) merged.set(k, v);
    }
    entries += locale.entries ?? 0;
    if (locale.file) files.push(locale.file);
  }
  return { map, contexts, byContext, entries, files };
}

/**
 * Chinese label for a monster `type` / `subtype`.
 *
 * The entity tables are consulted first because that is what the game shows in
 * the actor tooltip; the flat map is only a fallback for a value that is absent
 * from them (and for an older snapshot that predates the context tables).
 * Returns the English value unchanged when nothing translates it.
 */
export function translateEntityWord(locale, context, value) {
  if (typeof value !== 'string' || !value) return { text: value ?? '', status: 'none' };
  const hit = locale?.byContext?.get(context)?.get(value) ?? locale?.map?.get(value);
  return hit ? { text: hit, status: 'exact' } : { text: value, status: 'missing' };
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
