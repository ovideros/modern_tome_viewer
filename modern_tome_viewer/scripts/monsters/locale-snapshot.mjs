/**
 * Build the committed Chinese locale snapshot.
 *
 * The game's `zh_hans.lua` tables are part of the vendored source tree that the
 * repository deliberately does not track (16 MB of translations). The monster
 * pipeline still needs them, so the normalized `English -> 中文` map is
 * committed once as `data/raw/locales/zh_hans.json`, and the build prefers the
 * live locale files when a full checkout is present.
 *
 * Run:  node scripts/monsters/locale-snapshot.mjs [workspace-root] [out-file]
 */

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { readLocale, mergeLocales } from './locale.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..', '..');

/** Locale files that matter for NPC names and descriptions. */
export const LOCALE_SOURCES = [
  { id: 'tome', file: 'tome-src-full/data/locales/zh_hans.lua' },
  { id: 'orcs', file: 'dlc-src/orcs/tome-orcs/data/locales/zh_hans.lua' },
  { id: 'ashes', file: 'dlc-src/ashes-urhrok/tome-ashes-urhrok/data/locales/zh_hans.lua' },
  { id: 'cults', file: 'dlc-src/cults/tome-cults/data/locales/zh_hans.lua' },
];

/** Read and merge every locale file that exists under `workspaceRoot`. */
export function loadLocales(workspaceRoot) {
  const locales = LOCALE_SOURCES.map((source) => readLocale(path.join(workspaceRoot, source.file)));
  const merged = mergeLocales(...locales);
  return {
    ...merged,
    available: locales.filter((locale) => !locale.missing).length,
    expected: LOCALE_SOURCES.length,
  };
}

/**
 * Load the committed snapshot, or `null` when it has not been generated yet.
 *
 * The snapshot stores an array of `[english, chinese]` pairs, which is ~35%
 * smaller than an object and preserves insertion order.
 */
export function readLocaleSnapshot(file) {
  if (!fs.existsSync(file)) return null;
  const raw = JSON.parse(fs.readFileSync(file, 'utf8'));
  const map = new Map(raw.entries ?? []);
  return { map, contexts: new Map(), entries: raw.entries?.length ?? 0, files: raw.sources ?? [], snapshot: true };
}

/**
 * Entries longer than this are lore/book prose that no monster entry uses
 * (`desc` lines top out around 3 kB). Dropping them keeps the committed
 * snapshot around 2.8 MB instead of 4.9 MB.
 */
export const MAX_ENTRY_CHARS = 4000;

export function writeLocaleSnapshot(file, merged) {
  const entries = [...merged.map.entries()].filter(([en, zh]) => en.length + zh.length <= MAX_ENTRY_CHARS);
  const payload = {
    version: 1,
    generatedAt: new Date().toISOString(),
    note: '由 scripts/monsters/locale-snapshot.mjs 从游戏 data/locales/zh_hans.lua（本体 + 三个 DLC）提取的规范化「英文 -> 中文」表。上游语言表体积大且不入库，因此把规范化结果作为构建输入提交；只保留长度 <= 4000 字符的条目（覆盖怪物名称与描述，仅丢弃长篇书籍/剧情文本）。',
    sources: LOCALE_SOURCES.map((source) => source.file),
    maxEntryChars: MAX_ENTRY_CHARS,
    entries,
  };
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, JSON.stringify(payload));
  return payload;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const workspaceRoot = path.resolve(process.argv[2] ?? path.dirname(projectRoot));
  const outFile = path.resolve(process.argv[3] ?? path.join(projectRoot, 'data/raw/locales/zh_hans.json'));
  const merged = loadLocales(workspaceRoot);
  if (!merged.available) {
    console.error(`[locale-snapshot] no locale files under ${workspaceRoot}; nothing to do`);
    process.exit(1);
  }
  const payload = writeLocaleSnapshot(outFile, merged);
  console.log(
    `[locale-snapshot] ${merged.available}/${merged.expected} locale files, ` +
      `${merged.map.size} entries -> ${payload.entries.length} kept (<= ${MAX_ENTRY_CHARS} chars) -> ${path.relative(projectRoot, outFile)}`,
  );
  console.log(`[locale-snapshot]   ${(fs.statSync(outFile).size / 1024 / 1024).toFixed(2)} MB`);
}
