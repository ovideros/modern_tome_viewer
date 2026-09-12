import fs from 'node:fs';
import path from 'node:path';
import test from 'node:test';
import assert from 'node:assert/strict';

const root = path.resolve(import.meta.dirname, '../..');
const dataset = JSON.parse(fs.readFileSync(path.join(root, 'public/data/artifacts.json'), 'utf8'));

test('generated artifact data includes connected fixed-artifact sets', () => {
  assert.equal(dataset.sets.length, 17);
  assert.equal(new Set(dataset.sets.flatMap((set) => set.memberIds)).size, 38);
  const artifactIds = new Set(dataset.artifacts.map((artifact) => artifact.id));
  assert.ok(dataset.sets.every((set) => set.memberIds.every((id) => artifactIds.has(id))));
  assert.ok(dataset.artifacts.filter((artifact) => artifact.setIds.length > 0).length === 39);
  const telos = dataset.sets.find((set) => set.memberIds.some((id) => id.endsWith(':TELOS_TOP_HALF')));
  assert.equal(telos?.memberIds.length, 3);
  assert.ok(telos?.memberIds.includes('tome:TELOS_BOTTOM_HALF'));
});

test('set branches preserve both conditions and static/runtime effects', () => {
  const seasons = dataset.sets.find((set) => set.memberIds.some((id) => id.endsWith(':EYE_OF_SUMMER')));
  assert.ok(seasons);
  assert.ok(seasons.branches.some((branch) => branch.id === 'seasons'));
  assert.ok(seasons.branches.some((branch) => branch.id === 'harmonious'));
  assert.ok(seasons.branches.every((branch) => branch.conditions.length > 0));
  assert.ok(seasons.branches.some((branch) => branch.effects.some((effect) => effect.kind === 'static')));
});
