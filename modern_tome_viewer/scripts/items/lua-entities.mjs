/**
 * Item-side Lua entity scanner.
 *
 * Why this exists instead of reusing `parseLuaFile` from the monster pipeline:
 *
 * 1. `parseLuaFile` returns **zero** entities for
 *    `data/general/objects/world-artifacts.lua` — the single most important
 *    artifact file (186 blocks, 313 KB). Its `parseStatement` routes `for` /
 *    `while` / `repeat` into the loose `skipBlockStatement()`, whose depth
 *    accounting treats every `end` as a block terminator. The `for` loop at the
 *    top of the file ("Load additional artifacts") therefore swallows the rest
 *    of the file. The correct `skipBlock()` lives right there in the same file
 *    but is only reachable from `parseUnary`. This module never goes through
 *    statements at all, so that class of bug cannot reach items.
 * 2. Items need nested tables read *structurally* (`wielder`, `combat`,
 *    `special_on_hit`, ...), which the monster reader deliberately summarises
 *    into `rawFields` for diagnostics.
 *
 * Shared read-only pieces are imported from the monster pipeline rather than
 * reimplemented: the tokenizer, table/fragment parsers, `literalOf`, `keyName`.
 * Nothing in `scripts/monsters/` is modified by this module.
 *
 * The scanner is a single pass over the token stream that pairs `{` with `}`
 * **outside strings**. A second pass then parses the table literal found at
 * each recorded open brace into the same AST shape `parseLuaFile` produces, so
 * the two readers stay interchangeable where it matters.
 */

import { tokenize, parseLuaFile } from '../monsters/lua-table.mjs';

/** The four source roots, mirroring the monster pipeline's `SOURCES`. */
export const ITEM_SOURCES = [
  { id: 'tome', label: '本体', en: 'Base game', dir: 'tome-src-full', version: '1.7.6' },
  { id: 'orcs', label: '兽人 DLC', en: 'Embers of Rage', dir: 'dlc-src/orcs/tome-orcs', version: '1.7.6' },
  { id: 'ashes', label: '灰烬 DLC', en: "Ashes of Urh'Rok", dir: 'dlc-src/ashes-urhrok/tome-ashes-urhrok', version: '1.7.4' },
  { id: 'cults', label: '邪教 DLC', en: 'Forbidden Cults', dir: 'dlc-src/cults/tome-cults', version: '1.7.6' },
];

/** Brace/bracket/paren pairs the scanner pairs up. */
const OPENERS = { '{': '}', '[': ']', '(': ')' };
const CLOSERS = { '}': '{', ']': '[', ')': '(' };

/**
 * Match every bracket pair in the token list.
 *
 * Returns `openAt` (token index of an opener -> index of its closer) and
 * `openersBefore` (for each index, how many openers are still unbalanced, i.e.
 * the nesting depth *at* that token). Strings are already single tokens by the
 * time we get here, so braces inside strings cannot confuse the count.
 */
export function matchBrackets(tokens) {
  const openAt = new Map();
  const depthAt = new Array(tokens.length).fill(0);
  const stack = [];
  let depth = 0;

  for (let i = 0; i < tokens.length; i += 1) {
    const token = tokens[i];
    depthAt[i] = depth;
    if (token.type !== 'punct') continue;
    const value = token.value;
    if (OPENERS[value]) {
      stack.push({ index: i, close: OPENERS[value] });
      depth += 1;
    } else if (CLOSERS[value]) {
      // Pop to the nearest matching opener, tolerating a malformed stream by
      // simply ignoring the stray closer.
      for (let k = stack.length - 1; k >= 0; k -= 1) {
        if (stack[k].close === value) {
          openAt.set(stack[k].index, i);
          stack.length = k;
          depth -= 1;
          break;
        }
      }
    }
  }

  return { openAt, depthAt };
}

function isName(token, value) {
  return token?.type === 'name' && token.value === value;
}

/**
 * Find every `newEntity{...}` table in a token stream, plus every top-level
 * `load("...")` call.
 *
 * Nested `newEntity` blocks (an entity defined inside another entity's callback)
 * are reported once: the outer table's bounds are skipped after it is recorded.
 * That is intentional — the inner one belongs to the outer definition.
 */
export function scanItemTokens(tokens) {
  const { openAt, depthAt } = matchBrackets(tokens);
  const entities = [];
  const nested = [];
  const loads = [];
  // Token-index ranges of tables already captured. A `newEntity` token inside
  // one of them is a definition nested in some callback: it is reported
  // separately rather than silently dropped, so the coverage report can account
  // for the file's true `newEntity` count.
  const claimed = [];

  for (let i = 0; i < tokens.length; i += 1) {
    const token = tokens[i];

    if (isName(token, 'newEntity')) {
      // `newEntity{...}`, `newEntity { ... }` and `newEntity\n{...}` are all
      // valid call syntax in Lua.
      let j = i + 1;
      while (tokens[j]?.type === 'newline') j += 1;
      if (tokens[j]?.type === 'punct' && tokens[j].value === '{') {
        const close = openAt.get(j);
        if (close !== undefined) {
          if (claimed.some(([from, to]) => i > from && i < to)) {
            nested.push({ line: token.line, endLine: tokens[close]?.line ?? token.line });
          } else {
            entities.push({
              openIndex: j,
              closeIndex: close,
              line: token.line,
              endLine: tokens[close]?.line ?? token.line,
            });
            claimed.push([i, close]);
          }
        }
      }
    }

    if (isName(token, 'load')) {
      let j = i + 1;
      while (tokens[j]?.type === 'newline') j += 1;
      if (tokens[j]?.type === 'punct' && tokens[j].value === '(') {
        const close = openAt.get(j);
        const arg = tokens[j + 1];
        if (close !== undefined && arg?.type === 'string') {
          loads.push({ path: arg.value, line: token.line });
        }
      }
    }
  }

  return { entities, nested, loads, openAt, depthAt };
}

/**
 * Parse the table literal that starts at `tokens[openIndex]`.
 *
 * `parseLuaFile` is given a synthetic fragment (`local __frag = { ... }`) so we
 * reuse the tested table/AST reader verbatim instead of forking it. The
 * fragment's own line numbers are relative to the slice; `lineOffset` maps them
 * back to the real file.
 */
function parseTableFragment(tokens, openIndex, closeIndex, file) {
  const slice = tokens.slice(openIndex, closeIndex + 1);
  const source = `local __frag = ${reconstruct(slice)}`;
  const parsed = parseLuaFile(source, file);
  const assignment = parsed.assignments.find((a) => a.name === '__frag');
  if (!assignment) return { table: null, diagnostics: parsed.diagnostics };
  // Function bodies are skipped by the shared reader, which keeps only a plain
  // `return "text"` on `infoText`. Item tooltips routinely use
  // `return ("... %d ..."):tformat(...)` instead, so the text is recovered here
  // from the fragment's own tokens. This stays item-side: the shared parser is
  // left untouched.
  const fragmentTokens = tokenize(source);
  attachFunctionText(assignment.value, fragmentTokens);
  attachFunctionBodies(assignment.value, fragmentTokens);
  shiftLines(assignment.value, tokens[openIndex].line);
  return { table: assignment.value, diagnostics: parsed.diagnostics };
}

/**
 * Rebuild Lua source from tokens.
 *
 * The tokenizer already decoded string bodies, so they are re-quoted with a
 * minimal escape set. Only used to hand a *table literal* back to the parser,
 * where re-decoding must yield the same value — `escaped` covers the cases the
 * tokenizer itself unescapes.
 */
function reconstruct(slice) {
  let out = '';
  let previous = null;
  for (const token of slice) {
    if (token.type === 'newline') {
      out += '\n';
      previous = token;
      continue;
    }
    // Two adjacent word-like tokens must stay separated or they fuse into a
    // different token: `return _t"..."` (keyword + name) became the identifier
    // `return_t` when only same-type pairs were spaced, which silently broke
    // every function-body text extraction in minified-looking source.
    if (previous && isWordLike(previous.type) && isWordLike(token.type)) out += ' ';
    out += token.type === 'string' ? quote(token.value) : token.value;
    previous = token;
  }
  return out;
}

/** Token types that would merge with an adjacent word if written without space. */
function isWordLike(type) {
  return type === 'name' || type === 'number' || type === 'keyword';
}

function quote(value) {
  const escaped = String(value)
    .replace(/\\/g, '\\\\')
    .replace(/"/g, '\\"')
    .replace(/\n/g, '\\n')
    .replace(/\r/g, '\\r')
    .replace(/\t/g, '\\t');
  return `"${escaped}"`;
}

/**
 * Attach the display text of each `function` node found in a fragment.
 *
 * Uses the *fragment's* line numbers, so this must run before `shiftLines`
 * rebases them onto the original file. The rule is deliberately narrow: the
 * first string literal inside the function body, which is what
 * `("...%d..."):tformat(...)` and `return _t"..."` both start with. Anything
 * without a leading literal keeps `infoText === undefined`, which the build
 * reports as a computed value rather than inventing prose.
 */
function attachFunctionText(root, fragmentTokens) {
  // Collect every function in document order first: a function's display text
  // lives between its own `function` keyword and the next function in the same
  // entity. Searching to the end of the entity would let a function with no
  // literal of its own borrow a later callback's text, which is how 76 items
  // ended up with a wrong or missing `special_desc`.
  const functions = [];
  (function collect(node, depth) {
    if (!node || typeof node !== 'object' || depth > 40) return;
    if (node.kind === 'function' && typeof node.line === 'number') functions.push(node);
    for (const entry of node.map ?? []) collect(entry.value, depth + 1);
    for (const item of node.array ?? []) collect(item, depth + 1);
    for (const arg of node.args ?? []) collect(arg, depth + 1);
    collect(node.of, depth + 1);
    collect(node.left, depth + 1);
    collect(node.right, depth + 1);
  }(root, 0));

  functions.sort((a, b) => a.line - b.line);
  for (let i = 0; i < functions.length; i += 1) {
    const node = functions[i];
    if (node.infoText) continue;
    // A nested function shares its parent's start line at the earliest, so the
    // next collected function is always a valid upper bound. Both bounds are in
    // fragment coordinates here, because `shiftLines` rebases them afterwards.
    const next = functions[i + 1]?.line ?? Infinity;
    const text = firstStringReturnInRange(fragmentTokens, node.line, next);
    if (text !== null) node.infoText = text;
  }
}

/**
 * Attach the reconstructed source text of every `function` node to `bodyText`.
 *
 * `infoText` alone is not enough for the item pages: several egos express their
 * whole effect inside a callback, and the page has to be able to say what the
 * callback does. Two shapes need the body rather than its first string:
 *
 *   `resolvers.mbonus_material(30, 20, function(e, v) v=v/100 return 0, v end)`
 *     — the trailing function is a *value transform* (here: divide by 100), so
 *     reading it is what turns `20..50` into `20%..50%`. Ignoring it is how the
 *     affix page used to show `25~65` for a resistance that is really `20%~50%`.
 *   `function(self, who) return ("heal for %d"):tformat(self.soothing_heal) end`
 *     — the game's own description template plus the fields it interpolates,
 *     which is the most authoritative wording available for a callback effect.
 *
 * The body is delimited by block nesting, not by the next function in the
 * entity: a nested callback (`tformat(function() ... end)`) would otherwise be
 * mistaken for the outer one's end. Block keywords follow Lua's own rules —
 * `for`/`while` open a block and their `do` does not open a second one.
 */
function attachFunctionBodies(root, tokens) {
  const functions = [];
  (function collect(node, depth) {
    if (!node || typeof node !== 'object' || depth > 40) return;
    if (node.kind === 'function' && typeof node.line === 'number') functions.push(node);
    for (const entry of node.map ?? []) collect(entry.value, depth + 1);
    for (const item of node.array ?? []) collect(item, depth + 1);
    for (const arg of node.args ?? []) collect(arg, depth + 1);
    collect(node.of, depth + 1);
    collect(node.left, depth + 1);
    collect(node.right, depth + 1);
  }(root, 0));

  functions.sort((a, b) => a.line - b.line);
  const keywords = [];
  for (let i = 0; i < tokens.length; i += 1) {
    if (tokens[i].type === 'keyword' && tokens[i].value === 'function') keywords.push(i);
  }

  let cursor = 0;
  for (const node of functions) {
    let start = -1;
    for (let k = cursor; k < keywords.length; k += 1) {
      // Two callbacks can share a line (`{100, descFn, effectFn}`); document
      // order is the tie-breaker, which the ascending cursor provides.
      if (tokens[keywords[k]].line >= node.line) {
        start = keywords[k];
        cursor = k + 1;
        break;
      }
    }
    if (start < 0) continue;
    const end = functionEnd(tokens, start);
    node.bodyText = reconstruct(tokens.slice(start, end + 1));
  }
}

/** Index of the `end` closing the `function` keyword at `start`, or the last token. */
function functionEnd(tokens, start) {
  let depth = 1;
  // A `do` that belongs to a `for`/`while` header closes nothing on its own;
  // counting it as an opener would make the scan run past the real `end`.
  let pendingDo = false;
  for (let i = start + 1; i < tokens.length; i += 1) {
    const token = tokens[i];
    if (token.type !== 'keyword') continue;
    switch (token.value) {
      case 'for': case 'while': depth += 1; pendingDo = true; break;
      case 'do': if (pendingDo) pendingDo = false; else depth += 1; break;
      case 'if': case 'function': case 'repeat': depth += 1; break;
      case 'end': case 'until': depth -= 1; break;
      default: break;
    }
    if (depth === 0) return i;
  }
  return tokens.length - 1;
}

/**
 * First string literal belonging to a `return` in the token line range
 * `[fromLine, toLine)`.
 *
 * The shapes item tooltips use, all of which the shared reader misses because it
 * only accepts `return` immediately followed by a string:
 *
 *   `return _t"..."`                     name between `return` and the literal
 *   `return ("... %d ..."):tformat(...)`  literal behind a parenthesis
 *   `return "...":tformat(...)`           literal directly
 *
 * Returns null when the callback computes its text without a leading literal, so
 * the build reports it as computed rather than guessing.
 */
function firstStringReturnInRange(tokens, fromLine, toLine) {
  for (let i = 0; i < tokens.length; i += 1) {
    const token = tokens[i];
    if (token.line < fromLine) continue;
    if (token.line >= toLine) break;
    if (token.type !== 'keyword' || token.value !== 'return') continue;

    // Walk forward over the localisation wrapper (`_t`, `t`, `tformat`) and any
    // opening parenthesis until the literal appears.
    for (let j = i + 1; j < tokens.length; j += 1) {
      const next = tokens[j];
      if (next.line >= toLine) break;
      if (next.type === 'newline') continue;
      if (next.type === 'string') return next.value;
      if (next.type === 'name' && ['_t', 't', 'tformat'].includes(next.value)) continue;
      if (next.type === 'punct' && next.value === '(') continue;
      break;
    }
    return null;
  }
  return null;
}

/**
 * Re-base the AST's line numbers onto the original file.
 *
 * The synthetic fragment starts at the table's own line, so a node on fragment
 * line N belongs to real line `firstLine + N - 1`.
 */
function shiftLines(node, firstLine) {
  if (!node || typeof node !== 'object') return;
  if (typeof node.line === 'number') node.line = firstLine + node.line - 1;
  for (const entry of node.map ?? []) {
    shiftLines(entry.key, firstLine);
    shiftLines(entry.value, firstLine);
    if (typeof entry.line === 'number') entry.line = firstLine + entry.line - 1;
  }
  for (const item of node.array ?? []) shiftLines(item, firstLine);
  for (const arg of node.args ?? []) shiftLines(arg, firstLine);
  shiftLines(node.of, firstLine);
  shiftLines(node.left, firstLine);
  shiftLines(node.right, firstLine);
  for (const part of node.body ?? []) shiftLines(part, firstLine);
}

/**
 * Scan one Lua file for item entities.
 *
 * Returns `{ entities, loads, diagnostics }`, where each entity is
 * `{ fields, line, endLine, file }` with `fields` in the same AST shape
 * `parseLuaFile` produces.
 */
export function scanItemFile(src, file) {
  const tokens = tokenize(src);
  const { entities: blocks, nested, loads } = scanItemTokens(tokens);
  const diagnostics = [];
  const entities = [];

  for (const block of blocks) {
    const { table, diagnostics: fragmentDiagnostics } = parseTableFragment(
      tokens, block.openIndex, block.closeIndex, file,
    );
    for (const diagnostic of fragmentDiagnostics) {
      diagnostics.push({ file, line: block.line, message: `表片段解析：${diagnostic.message}` });
    }
    if (!table) {
      diagnostics.push({ file, line: block.line, message: 'newEntity 表未能解析' });
      continue;
    }
    entities.push({
      fields: table,
      line: block.line,
      endLine: block.endLine,
      file,
    });
  }

  return { entities, nested, loads, diagnostics };
}
