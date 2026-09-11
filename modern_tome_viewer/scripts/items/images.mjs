/**
 * Artifact icon resolution and copying.
 *
 * Reuses the monster pipeline's ZIP reader and (read-only) index builder rather
 * than duplicating a ZIP implementation. Artifacts are simpler than NPCs: the
 * definition states its own `image = "object/artifact/foo.png"`, so resolution
 * is an exact path lookup with a normalised fallback for the DLC directories
 * that ship their icons loose under `overload/data/gfx/shockbolt/`.
 *
 * Only icons the dataset actually references are written, matching how the
 * monster encyclopedia treats Shockbolt art.
 */

import fs from 'node:fs';
import path from 'node:path';

import { buildImageIndex, copyImages, normalizeArtName } from '../monsters/images.mjs';
import { ITEM_SOURCES } from './lua-entities.mjs';

/** Build the Shockbolt art index for the base game plus the three DLCs. */
export function buildArtifactImageIndex(workspaceRoot) {
  return buildImageIndex(workspaceRoot, {
    dlcSources: ITEM_SOURCES.filter((s) => s.id !== 'tome').map((s) => ({ id: s.id, dir: s.dir })),
  });
}

/**
 * Resolve one artifact's icon to an index key.
 *
 * Returns `{ key, how }` or null. `how` is recorded so the report distinguishes
 * an exact path hit from a fuzzy one — a fuzzy hit must never be mistaken for a
 * verified match.
 */
export function resolveArtifactImage(index, imagePath) {
  if (typeof imagePath !== 'string' || !imagePath) return null;
  const relative = imagePath.replace(/^(?:shockbolt\/)+/, '').replace(/^\/+/, '');
  const exact = index.get(relative);
  if (exact) return { key: relative, how: 'exact' };

  // The DLC directories store art under `object/artifact/`, matching the base
  // game, so a normalised comparison handles casing and separator differences.
  const normalized = normalizeArtName(relative);
  for (const key of index.keys()) {
    if (normalizeArtName(key) === normalized) return { key, how: 'normalized' };
  }

  // Last resort: match on the basename only, which is still exact enough to be
  // verifiable, and record it as its own category in the report.
  const base = normalizeArtName(path.basename(relative, '.png'));
  const matches = [...index.keys()].filter((key) => normalizeArtName(path.basename(key, '.png')) === base);
  if (matches.length === 1) return { key: matches[0], how: 'basename' };
  return null;
}

/** Icons deliberately generated from a material template rather than a file. */
const RESOLVER_IMAGE = /^resolvers\./;

/**
 * Resolve icons for the artifact list and copy the referenced files.
 *
 * Artifacts whose `image` is a resolver call are reported as
 * `resolver-generated`: the engine picks a texture from the item's material, so
 * there is no single file to copy and the page must fall back to a category
 * icon instead of inventing one.
 */
export function copyArtifactImages({ workspaceRoot, outDir, artifacts }) {
  const { index, archives, missing: missingSources } = buildArtifactImageIndex(workspaceRoot);
  const toCopy = new Set();
  const missing = [];
  const resolverGenerated = [];
  const resolution = new Map();

  for (const artifact of artifacts) {
    const image = artifact.image;
    if (!image) {
      missing.push({ id: artifact.id, name: artifact.name, image: null, reason: 'no-image-field' });
      continue;
    }
    if (RESOLVER_IMAGE.test(image)) {
      resolverGenerated.push({ id: artifact.id, name: artifact.name, image, reason: 'resolver-generated' });
      continue;
    }
    const hit = resolveArtifactImage(index, image);
    if (!hit) {
      missing.push({ id: artifact.id, name: artifact.name, image, reason: 'not-in-index' });
      continue;
    }
    resolution.set(artifact.id, hit);
    toCopy.add(hit.key);
  }

  // A missing art source is a legitimately degraded checkout: the gfx pack and
  // the DLC art are large vendored binaries the repository does not track. Say
  // so rather than reporting every icon as a gap.
  const copyable = missingSources.length === 0
    ? copyImages({ index, archives }, [...toCopy], outDir)
    : { copied: [], missing: [...toCopy] };

  for (const artifact of artifacts) {
    const hit = resolution.get(artifact.id);
    if (!hit) continue;
    artifact.imagePath = `img/${hit.key}`;
    artifact.imageMatch = hit.how;
  }

  for (const archive of archives) {
    if (typeof archive.archive?.close === 'function') archive.archive.close();
  }

  return {
    indexSize: index.size,
    copied: copyable.copied,
    missing,
    missingSources,
    resolverGenerated,
    resolution,
  };
}
