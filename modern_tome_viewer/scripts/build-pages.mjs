/**
 * Build the GitHub Pages artifact.
 *
 * The repository commits the generated `public/data` and `public/img` (see
 * `docs/deployment.md`), so a deployment does not need the game sources that
 * those files were produced from — which a CI checkout does not have.
 * `vite build` copies `public/` into `dist/`, so this is a plain app build; the
 * script exists to make the deployment entry point explicit and to check that
 * the data assets are actually present before publishing.
 *
 * Run:  node scripts/build-pages.mjs
 */

import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..');

/** Files the site fetches at runtime; a deploy without them is a broken site. */
const REQUIRED = [
  'public/data/talents.json',
  'public/data/meta.json',
  'public/data/manifest.json',
  'public/data/monsters.json',
  'public/data/monsters-report.json',
];

const missing = REQUIRED.filter((relative) => !fs.existsSync(path.join(projectRoot, relative)));
if (missing.length) {
  console.error('[build-pages] missing generated data:');
  for (const relative of missing) console.error(`  - ${relative}`);
  console.error('[build-pages] run `npm run data` with the game sources present, then commit public/data.');
  process.exit(1);
}

const npcDir = path.join(projectRoot, 'public/img/npc');
const iconDir = path.join(projectRoot, 'public/img/talents');
const npcCount = fs.existsSync(npcDir) ? fs.readdirSync(npcDir).length : 0;
const iconCount = fs.existsSync(iconDir)
  ? fs.readdirSync(iconDir).reduce((total, size) => total + fs.readdirSync(path.join(iconDir, size)).length, 0)
  : 0;
console.log(`[build-pages] data present; npc art ${npcCount}, talent icons ${iconCount}`);

const vite = path.join(projectRoot, 'node_modules/.bin/vite');
const result = spawnSync(vite, ['build'], { cwd: projectRoot, stdio: 'inherit' });
if (result.error) throw result.error;
process.exit(result.status ?? 1);
