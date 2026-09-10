/**
 * Monster art index.
 *
 * Monster pictures live inside the game's ZIP archives, so they cannot be read
 * with `fs` directly. This module indexes the Shockbolt NPC art (the default
 * tile set) from the base game and the three DLCs, and copies exactly the files
 * the encyclopedia references into `public/img/npc/`.
 *
 * Reading the archives means the build does not depend on an extracted copy of
 * the gfx pack, and only referenced art is written to the web output.
 */

import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';

const EOCD_SIG = 0x06054b50;
const CEN_SIG = 0x02014b50;
const LOC_SIG = 0x04034b50;

/**
 * Minimal ZIP reader.
 *
 * The archives are stored with plain `deflate` (method 8) or no compression, so
 * a small central-directory reader avoids adding a dependency. It reads only
 * the central directory and the entries actually requested.
 */
export class ZipArchive {
  constructor(file) {
    this.file = file;
    this.fd = fs.openSync(file, 'r');
    this.size = fs.fstatSync(this.fd).size;
    this.entries = new Map();
    this.#readCentralDirectory();
  }

  #readCentralDirectory() {
    const tailSize = Math.min(this.size, 66_000);
    const tail = Buffer.alloc(tailSize);
    fs.readSync(this.fd, tail, 0, tailSize, this.size - tailSize);
    let eocd = -1;
    for (let i = tail.length - 22; i >= 0; i -= 1) {
      if (tail.readUInt32LE(i) === EOCD_SIG) { eocd = i; break; }
    }
    if (eocd === -1) throw new Error(`not a ZIP archive: ${this.file}`);
    const count = tail.readUInt16LE(eocd + 10);
    const cdOffset = tail.readUInt32LE(eocd + 16);
    const cdSize = tail.readUInt32LE(eocd + 12);
    const cd = Buffer.alloc(cdSize);
    fs.readSync(this.fd, cd, 0, cdSize, cdOffset);

    let p = 0;
    for (let i = 0; i < count && p + 46 <= cd.length; i += 1) {
      if (cd.readUInt32LE(p) !== CEN_SIG) break;
      const method = cd.readUInt16LE(p + 10);
      const compressedSize = cd.readUInt32LE(p + 20);
      const uncompressedSize = cd.readUInt32LE(p + 24);
      const nameLen = cd.readUInt16LE(p + 28);
      const extraLen = cd.readUInt16LE(p + 30);
      const commentLen = cd.readUInt16LE(p + 32);
      const localOffset = cd.readUInt32LE(p + 42);
      const name = cd.toString('utf8', p + 46, p + 46 + nameLen);
      this.entries.set(name, { name, method, compressedSize, uncompressedSize, localOffset });
      p += 46 + nameLen + extraLen + commentLen;
    }
  }

  has(name) {
    return this.entries.has(name);
  }

  names() {
    return [...this.entries.keys()];
  }

  read(name) {
    const entry = this.entries.get(name);
    if (!entry) return null;
    const header = Buffer.alloc(30);
    fs.readSync(this.fd, header, 0, 30, entry.localOffset);
    if (header.readUInt32LE(0) !== LOC_SIG) throw new Error(`bad local header for ${name}`);
    const nameLen = header.readUInt16LE(26);
    const extraLen = header.readUInt16LE(28);
    const start = entry.localOffset + 30 + nameLen + extraLen;
    const raw = Buffer.alloc(entry.compressedSize);
    fs.readSync(this.fd, raw, 0, entry.compressedSize, start);
    if (entry.method === 0) return raw;
    if (entry.method === 8) return zlib.inflateRawSync(raw);
    throw new Error(`unsupported ZIP method ${entry.method} for ${name}`);
  }

  close() {
    fs.closeSync(this.fd);
  }
}

/** Default archive paths, relative to the workspace root. */
export function archivePaths(rootDir) {
  return {
    gfx: path.join(rootDir, 't-engine4-src-1.7.6/game/modules/tome-1.7.6-gfx.team'),
    modules: [
      { id: 'orcs', file: path.join(rootDir, 'dlc-src/orcs/tome-orcs/overload/data/gfx/shockbolt/npc') },
    ],
  };
}

/**
 * Build the index of available Shockbolt art.
 *
 * Returns a Map of `<category>/<file>.png` -> { file, source, archive },
 * preferring the base game and letting DLCs add their own art. The whole
 * Shockbolt tileset is indexed, not just `npc/`: a few monsters legitimately
 * use `player/`, `object/` or `terrain/` art, and excluding those would report
 * a phantom missing-image gap. Files shipped loose in a DLC directory
 * (`overload/data/gfx/shockbolt`) are indexed as well.
 */
export function buildImageIndex(rootDir, options = {}) {
  const index = new Map();
  const archives = [];
  const missing = [];

  const gfx = path.join(rootDir, 't-engine4-src-1.7.6/game/modules/tome-1.7.6-gfx.team');
  if (!fs.existsSync(gfx)) missing.push('tome-1.7.6-gfx.team');
  if (fs.existsSync(gfx)) {
    const archive = new ZipArchive(gfx);
    archives.push({ id: 'tome', archive });
    for (const name of archive.names()) {
      const m = /(?:^|\/)data\/gfx\/shockbolt\/(.+\.png)$/.exec(name);
      if (!m) continue;
      index.set(m[1], { file: m[1], source: 'tome', archive: 'tome' });
    }
  }

  for (const source of options.dlcSources ?? []) {
    const root = path.join(rootDir, source.dir, 'overload/data/gfx/shockbolt');
    if (!fs.existsSync(root)) { missing.push(`dlc:${source.id}`); continue; }
    const walk = (dir) => {
      for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
        const full = path.join(dir, entry.name);
        if (entry.isDirectory()) walk(full);
        else if (entry.name.endsWith('.png')) {
          const key = path.relative(root, full).split(path.sep).join('/');
          if (!index.has(key)) index.set(key, { file: key, source: source.id, archive: null, dir: path.dirname(full) });
        }
      }
    };
    walk(root);
  }

  return { index, archives, missing };
}

/** Strip diacritics and non-alphanumerics so `dúathedlen` matches `duathedlen`. */
export function normalizeArtName(name) {
  return name
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

/**
 * Secondary lookup used when the generated filename does not exist verbatim.
 *
 * The vanilla archive contains art whose filename does not follow
 * `npc/<type>_<subtype>_<name>.png` exactly: the prefix is sometimes dropped
 * (`grizzly_bear.png` for an `animal/bear` npc), punctuation is normalised
 * (`npc/spiderkin_spider_ninandra_the_great_weaver.png`) or accented letters
 * are stripped (`demon_major_duathedlen.png`). Keying by a normalised
 * `subtype + name` / `name` pair resolves those without guessing.
 */
export function buildArtLookup(index) {
  const byNormalizedFull = new Map();
  const bySubtypeName = new Map();
  const byName = new Map();
  // The creature-name part of each basename (`type_subtype_name` -> `name`).
  // A single trailing word such as `bear` is useless for matching — both
  // `black_bear.png` and `grizzly_bear.png` end in it — so `byName` only keeps
  // names that are themselves unique, and `byNameParts` records the exact
  // word sequences for a collision check.
  const byNameParts = new Map();
  const nameUseCount = new Map();
  // Index by basename: the generated candidate is always `npc/<type>_<subtype>
  // _<name>.png`, while the archive files art under its own category
  // (`npc/`, but also `construct/`, `elemental/`, `player/`). Matching on the
  // basename keeps those reachable instead of reporting a phantom gap.
  for (const key of index.keys()) {
    const base = key.split('/').pop().replace(/\.png$/, '');
    const parts = base.split('_');
    if (!byNormalizedFull.has(normalizeArtName(base))) byNormalizedFull.set(normalizeArtName(base), key);
    if (parts.length >= 2) {
      const subtypeName = normalizeArtName(parts.slice(-2).join('_'));
      if (!bySubtypeName.has(subtypeName)) bySubtypeName.set(subtypeName, key);
    }
    // Register the whole basename and every trailing 2+ word sequence, so a
    // generated `type_subtype_name` candidate can be matched by the longest
    // suffix it shares with the real file. A name claimed by two different files
    // is dropped below, because picking either one would be a guess.
    const words = parts.map((part) => normalizeArtName(part));
    for (let start = 0; start <= words.length - 2; start += 1) {
      const joined = words.slice(start).join('_');
      if (!byNameParts.has(joined)) byNameParts.set(joined, key);
      nameUseCount.set(joined, (nameUseCount.get(joined) ?? 0) + 1);
    }
    const nameOnly = normalizeArtName(parts[parts.length - 1]);
    if (!byName.has(nameOnly)) byName.set(nameOnly, key);
  }
  // Drop names that more than one file claims: matching them would be a guess.
  const unique = new Map();
  for (const [name, key] of byNameParts) {
    if ((nameUseCount.get(name) ?? 0) === 1) unique.set(name, key);
  }
  return { byNormalizedFull, bySubtypeName, byName, byNameParts: unique };
}

/**
 * Find the best real art file for an entity whose generated name is missing.
 *
 * Returns `{ key, how }` or null. `how` records which rule matched so the build
 * report can distinguish an exact hit from a fuzzy one.
 */
export function lookupArt(lookup, fields, candidate) {
  if (!candidate) return null;
  const base = candidate.split('/').pop().replace(/\.png$/, '');
  const normalized = normalizeArtName(base);
  if (lookup.byNormalizedFull.has(normalized)) {
    return { key: lookup.byNormalizedFull.get(normalized), how: 'normalized' };
  }
  const sub = normalizeArtName(fields.subtype ?? '');
  const name = normalizeArtName(fields.name ?? '');
  if (sub && name && lookup.bySubtypeName.has(`${sub}_${name}`)) {
    return { key: lookup.bySubtypeName.get(`${sub}_${name}`), how: 'subtype+name' };
  }
  // Whole-name containment: `Ureslak the Prismatic` -> `_ureslak_the_prismatic`
  // inside `drake_multi_ureslak_the_prismatic`. Requires a reasonably long name
  // and an underscore-delimited match so short words cannot collide.
  const fullName = normalizeArtName(fields.name ?? '');
  if (fullName.length >= 6) {
    for (const [normalizedKey, key] of lookup.byNormalizedFull) {
      if (normalizedKey.includes(`_${fullName}`) || normalizedKey.startsWith(`${fullName}_`)) {
        return { key, how: 'name-contained' };
      }
    }
  }
  // Finally, the creature-name part of the generated filename must be exactly
  // `type_subtype_name`, but the archive sometimes names the same art without
  // the `type_subtype_` prefix (`grizzly_bear.png`) or with the words in a
  // different order (`drake_multi_ureslak_the_prismatic.png`). Both are matched
  // by the whole name, so `bear` can never steal `grizzly bear`.
  const parts = base.split('_');
  if (parts.length >= 3) {
    const nameExact = parts.slice(2).join('_');
    if (lookup.byNameParts.has(nameExact)) {
      return { key: lookup.byNameParts.get(nameExact), how: 'name-exact' };
    }
    for (const length of [2, 3, 4]) {
      if (parts.length <= length) continue;
      const suffix = parts.slice(-length).join('_');
      if (lookup.byNameParts.has(suffix)) {
        return { key: lookup.byNameParts.get(suffix), how: 'name-suffix' };
      }
    }
    // A contained name must be long and follow a word boundary, so generic
    // words cannot match.
    for (const [known, key] of lookup.byNameParts) {
      if (known.length >= 12 && base.includes(`_${known}`)) {
        return { key, how: 'name-contained' };
      }
    }
  }
  return null;
}

/**
 * Copy the referenced art into `public/img/npc/`.
 *
 * Returns { copied, missing } where `missing` lists references with no art in
 * any source (kept so the pipeline can report real gaps instead of pretending
 * every monster has a picture).
 */
export function copyImages({ index, archives }, files, outDir) {
  const copied = [];
  const missing = [];
  const byArchive = new Map(archives.map((a) => [a.id, a.archive]));

  for (const key of files) {
    const entry = index.get(key);
    if (!entry) { missing.push(key); continue; }
    let data = null;
    if (entry.archive) {
      const archive = byArchive.get(entry.archive);
      data = archive?.read(`data/gfx/shockbolt/${key}`) ?? null;
    } else {
      const file = path.join(entry.dir, path.basename(key));
      data = fs.existsSync(file) ? fs.readFileSync(file) : null;
    }
    if (!data) { missing.push(key); continue; }
    const target = path.join(outDir, 'img', key);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.writeFileSync(target, data);
    copied.push(key);
  }

  return { copied, missing };
}
