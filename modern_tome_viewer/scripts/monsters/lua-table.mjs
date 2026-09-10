/**
 * A small, purpose-built Lua source reader for ToME entity definitions.
 *
 * It deliberately implements only what NPC/talent definition files use:
 *
 *   - comments (`--` and `--[[ ]]`)
 *   - string literals: `"..."`, `'...'`, `[[...]]`, `[==[...]==]`
 *   - numeric literals, booleans, nil
 *   - table constructors `{ ... }` with `key = value`, `["expr"] = value`,
 *     `[expr] = value` and array entries
 *   - calls `name(...)` / `name{...}` kept as opaque `{ kind: "call" }` nodes
 *   - identifiers and dotted paths as `{ kind: "ref", path: [...] }`
 *   - `newEntity{ ... }` blocks, including the `if cond then newEntity{...} end`
 *     wrapper the zone files use for conditional spawns
 *
 * Anything it cannot model is recorded as an `{ kind: "raw" }` node rather
 * than being silently dropped, so extraction can report what it skipped.
 *
 * The parser never executes Lua and never evaluates expressions. Semantic
 * interpretation (talent configs, inheritance, images) happens in
 * `extract.mjs`.
 */

const KEYWORDS = new Set([
  'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 'function',
  'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 'return', 'then', 'true',
  'until', 'while',
]);

const IDENT_START = /[A-Za-z_]/;
const IDENT_PART = /[A-Za-z0-9_]/;
const DIGIT = /[0-9]/;

/** Tokenize Lua source into a flat token list. */
export function tokenize(src) {
  const tokens = [];
  let i = 0;
  const n = src.length;
  // Track the line number incrementally. Recomputing it per token is O(n^2)
  // and made parsing the 3.8 MB locale tables take minutes.
  let line = 1;

  const push = (type, value) => tokens.push({ type, value, line });
  /** Count the newlines we just skipped, without rescanning the source. */
  const advance = (to) => {
    for (let k = i; k < to && k < n; k += 1) if (src.charCodeAt(k) === 10) line += 1;
  };

  while (i < n) {
    const c = src[i];

    // Long bracket comments and strings: [[ ... ]], [==[ ... ]==]
    if (c === '[') {
      const m = /^\[(=*)\[/.exec(src.slice(i, i + 40));
      if (m) {
        const close = `]${m[1]}]`;
        const startLine = line;
        const end = src.indexOf(close, i + m[0].length);
        if (end === -1) {
          push('string', src.slice(i + m[0].length));
          i = n;
        } else {
          push('string', src.slice(i + m[0].length, end));
          advance(end + close.length);
          i = end + close.length;
        }
        continue;
      }
    }

    // Comments
    if (c === '-' && src[i + 1] === '-') {
      const m = /^--\[(=*)\[/.exec(src.slice(i, i + 40));
      if (m) {
        const close = `]${m[1]}]`;
        const end = src.indexOf(close, i + m[0].length);
        const to = end === -1 ? n : end + close.length;
        advance(to);
        i = to;
      } else {
        const end = src.indexOf('\n', i);
        i = end === -1 ? n : end + 1;
        line += 1;
      }
      continue;
    }

    // Whitespace
    if (c === '\n') { push('newline', '\n'); i += 1; line += 1; continue; }
    if (c === ' ' || c === '\t' || c === '\r') { i += 1; continue; }

    // Strings
    if (c === '"' || c === "'") {
      const startLine = line;
      let j = i + 1;
      let value = '';
      while (j < n) {
        const d = src[j];
        if (d === '\\') {
          const e = src[j + 1];
          if (e === 'n') value += '\n';
          else if (e === 't') value += '\t';
          else if (e === 'r') value += '\r';
          else if (e === '\\') value += '\\';
          else if (e === '"') value += '"';
          else if (e === "'") value += "'";
          else if (e === '\n') value += '\n';
          else value += e ?? '';
          j += 2;
          continue;
        }
        if (d === c) break;
        value += d;
        j += 1;
      }
      push('string', value);
      advance(j + 1);
      i = j + 1;
      continue;
    }

    // Numbers
    if (DIGIT.test(c) || (c === '.' && DIGIT.test(src[i + 1] ?? ''))) {
      const m = /^(0[xX][0-9a-fA-F]+|\d+\.?\d*(?:[eE][+-]?\d+)?|\.\d+(?:[eE][+-]?\d+)?)/.exec(src.slice(i));
      push('number', m[0]);
      advance(i + m[0].length);
      i += m[0].length;
      continue;
    }

    // Identifiers / keywords
    if (IDENT_START.test(c)) {
      let j = i + 1;
      while (j < n && IDENT_PART.test(src[j])) j += 1;
      const word = src.slice(i, j);
      push(KEYWORDS.has(word) ? 'keyword' : 'name', word);
      advance(j);
      i = j;
      continue;
    }

    // Operators / punctuation
    const two = src.slice(i, i + 2);
    if (two === '==' || two === '~=' || two === '<=' || two === '>=' || two === '..' || two === '::') {
      push('punct', two);
      advance(i + 2);
      i += 2;
      continue;
    }
    push('punct', c);
    advance(i + 1);
    i += 1;
  }

  tokens.push({ type: 'eof', value: '', line });
  return tokens;
}

/**
 * Parse one Lua file.
 *
 * Returns `{ entities, assignments, diagnostics }`:
 *  - `entities`: every `newEntity{...}` block with a `fields` map
 *  - `assignments`: top-level `local X = {...}` / `X = {...}` tables
 *  - `diagnostics`: things the reader skipped, with line numbers
 */
export function parseLuaFile(src, file) {
  const tokens = tokenize(src);
  const parser = new Parser(tokens, file);
  return parser.parseChunk();
}

class Parser {
  constructor(tokens, file) {
    this.tokens = tokens;
    this.pos = 0;
    this.file = file;
    this.diagnostics = [];
    this.entities = [];
    this.talentBlocks = [];
    this.assignments = [];
  }

  peek(offset = 0) {
    return this.tokens[Math.min(this.pos + offset, this.tokens.length - 1)];
  }

  next() {
    const token = this.tokens[this.pos];
    if (this.pos < this.tokens.length - 1) this.pos += 1;
    return token;
  }

  at(type, value) {
    const token = this.peek();
    return token.type === type && (value === undefined || token.value === value);
  }

  skipNewlines() {
    while (this.at('newline') || this.at('punct', ';')) this.next();
  }

  note(message, line) {
    this.diagnostics.push({ file: this.file, line, message });
  }

  parseChunk() {
    while (!this.at('eof')) {
      this.skipNewlines();
      if (this.at('eof')) break;
      const before = this.pos;
      this.parseStatement();
      if (this.pos === before) {
        const token = this.next();
        this.note(`跳过无法解析的记号 ${JSON.stringify(token.value)}`, token.line);
      }
    }
    return {
      entities: this.entities,
      talentBlocks: this.talentBlocks,
      assignments: this.assignments,
      diagnostics: this.diagnostics,
    };
  }

  parseStatement() {
    const token = this.peek();

    if (token.type === 'keyword') {
      switch (token.value) {
        case 'local': {
          // local A = expr  /  local A, B = ...
          const saved = this.pos;
          this.next();
          const names = [];
          while (this.at('name')) {
            names.push(this.next().value);
            if (this.at('punct', ',')) { this.next(); continue; }
            break;
          }
          if (this.at('punct', '=')) {
            this.next();
            const value = this.parseExpression();
            for (const name of names) {
              this.assignments.push({ name, value, line: token.line });
            }
          } else {
            this.pos = saved;
            this.next(); // local
            this.skipToStatementEnd();
          }
          return;
        }
        case 'if': {
          this.parseIf();
          return;
        }
        case 'for':
        case 'while':
        case 'repeat': {
          this.skipBlockStatement();
          return;
        }
        case 'return':
        case 'break': {
          this.skipToStatementEnd();
          return;
        }
        default:
          this.skipToStatementEnd();
          return;
      }
    }

    // Assignment or call: NAME(.field)* = expr | call
    if (token.type === 'name') {
      const saved = this.pos;
      const path = this.parsePath();
      if (this.at('punct', '=')) {
        this.next();
        const value = this.parseExpression();
        if (path.length === 1) this.assignments.push({ name: path[0], value, line: token.line });
        return;
      }
      this.pos = saved;
      this.parseExpression();
      return;
    }

    this.next();
  }

  parsePath() {
    const path = [];
    path.push(this.next().value);
    while (this.at('punct', '.') || this.at('punct', ':')) {
      this.next();
      if (this.at('name')) path.push(this.next().value);
      else break;
    }
    return path;
  }

  /** `if cond then ... end`, parsing any newEntity blocks inside both arms. */
  parseIf() {
    this.next(); // if
    // Skip the condition up to `then`.
    while (!this.at('eof') && !this.at('keyword', 'then')) this.next();
    if (this.at('keyword', 'then')) this.next();

    while (!this.at('eof') && !this.at('keyword', 'end') && !this.at('keyword', 'else') && !this.at('keyword', 'elseif')) {
      this.skipNewlines();
      if (this.at('eof') || this.at('keyword', 'end') || this.at('keyword', 'else') || this.at('keyword', 'elseif')) break;
      const before = this.pos;
      this.parseStatement();
      if (this.pos === before) this.next();
    }

    if (this.at('keyword', 'elseif')) {
      this.parseIfTail();
    } else if (this.at('keyword', 'else')) {
      this.next();
      while (!this.at('eof') && !this.at('keyword', 'end')) {
        this.skipNewlines();
        if (this.at('eof') || this.at('keyword', 'end')) break;
        const before = this.pos;
        this.parseStatement();
        if (this.pos === before) this.next();
      }
    }
    if (this.at('keyword', 'end')) this.next();
  }

  parseIfTail() {
    // `elseif cond then ... end` — treat like a nested if without re-reading `if`.
    this.next(); // elseif
    while (!this.at('eof') && !this.at('keyword', 'then')) this.next();
    if (this.at('keyword', 'then')) this.next();
    while (!this.at('eof') && !this.at('keyword', 'end') && !this.at('keyword', 'else') && !this.at('keyword', 'elseif')) {
      this.skipNewlines();
      if (this.at('eof') || this.at('keyword', 'end') || this.at('keyword', 'else') || this.at('keyword', 'elseif')) break;
      const before = this.pos;
      this.parseStatement();
      if (this.pos === before) this.next();
    }
    if (this.at('keyword', 'elseif')) this.parseIfTail();
    else if (this.at('keyword', 'else')) {
      this.next();
      while (!this.at('eof') && !this.at('keyword', 'end')) {
        this.skipNewlines();
        if (this.at('eof') || this.at('keyword', 'end')) break;
        const before = this.pos;
        this.parseStatement();
        if (this.pos === before) this.next();
      }
    }
    if (this.at('keyword', 'end')) this.next();
  }

  skipBlockStatement() {
    // Consume until the matching `end` (loose: does not parse bodies).
    let depth = 1;
    while (!this.at('eof') && depth > 0) {
      const token = this.next();
      if (token.type === 'keyword') {
        if (token.value === 'if' || token.value === 'for' || token.value === 'while' || token.value === 'repeat' || token.value === 'function' || token.value === 'do') depth += 1;
        else if (token.value === 'end' || token.value === 'until') depth -= 1;
      }
    }
  }

  skipToStatementEnd() {
    let depth = 0;
    while (!this.at('eof')) {
      const token = this.peek();
      if (token.type === 'newline' && depth === 0) return;
      if (token.type === 'punct') {
        if (token.value === '(' || token.value === '{' || token.value === '[') depth += 1;
        else if (token.value === ')' || token.value === '}' || token.value === ']') {
          if (depth === 0) return;
          depth -= 1;
        }
      }
      this.next();
    }
  }

  /**
   * Parse an expression, then fold any trailing binary operator chain into an
   * `arith` node. ToME writes things like `exp_worth = 3 / 5` and
   * `max_life = 100 * 1.5`, which we keep as opaque arithmetic rather than
   * evaluating.
   */
  parseExpression() {
    const first = this.parseUnary();
    const BIN_OPS = new Set(['+', '-', '*', '/', '%', '^', '..']);
    let left = first;
    while (this.peek().type === 'punct' && BIN_OPS.has(this.peek().value)) {
      const op = this.next().value;
      const right = this.parseUnary();
      left = { kind: 'arith', op, left, right, line: left.line ?? right.line };
    }
    return left;
  }

  parseUnary() {
    this.skipNewlines();
    const token = this.peek();

    if (token.type === 'string') { this.next(); return { kind: 'string', value: token.value }; }
    if (token.type === 'number') { this.next(); return { kind: 'number', value: Number(token.value) }; }
    if (token.type === 'keyword' && token.value === 'nil') { this.next(); return { kind: 'nil' }; }
    if (token.type === 'keyword' && token.value === 'true') { this.next(); return { kind: 'boolean', value: true }; }
    if (token.type === 'keyword' && token.value === 'false') { this.next(); return { kind: 'boolean', value: false }; }

    if (this.at('punct', '{')) return this.parseTable();
    if (this.at('punct', '#')) { this.next(); const inner = this.parseExpression(); return { kind: 'length', of: inner }; }
    if (this.at('punct', '-')) { this.next(); const inner = this.parseExpression(); return { kind: 'negate', of: inner }; }

    if (token.type === 'name') {
      const line = token.line;
      const path = this.parsePath();

      // Function call / call-with-table
      if (this.at('punct', '(')) {
        const args = this.parseCallArgs();
        return { kind: 'call', path, args, line };
      }
      if (this.at('punct', '{')) {
        const table = this.parseTable();
        const callee = path.join('.');
        if (callee === 'newEntity') {
          this.entities.push({ fields: table, line, file: this.file, callee: 'newEntity' });
        } else if (callee === 'newEntity_silent') {
          this.entities.push({ fields: table, line, file: this.file, callee: 'newEntity_silent', silent: true });
        } else if (callee === 'newTalent' || callee === 'newTalentType' || callee === 'newDamageType') {
          this.talentBlocks.push({ fields: table, line, file: this.file, callee });
        }
        return { kind: 'call', path, args: [table], line };
      }
      if (this.at('string')) {
        const arg = this.parseExpression();
        return { kind: 'call', path, args: [arg], line };
      }

      const name = path[path.length - 1];
      if (path.length === 1 && name === 'newEntity') {
        this.note('newEntity 缺少表参数', line);
      }
      return { kind: 'ref', path, line };
    }

    if (token.type === 'keyword' && token.value === 'function') {
      const line = token.line;
      const node = { kind: 'function', line };
      this.skipBlockStatement2(node);
      return node;
    }

    // Give up on anything else; consume a single token so we always progress.
    const skipped = this.next();
    this.note(`跳过表达式记号 ${JSON.stringify(skipped.value)}`, skipped.line);
    return { kind: 'raw', value: skipped.value, line: skipped.line };
  }

  /**
   * Skip a `function ... end` body starting at the `function` keyword.
   *
   * While skipping, the first `return` of a plain string literal is recorded on
   * the node as `infoText`. ToME talent `info` functions are usually
   * `return ([[...]]):tformat(...)`; that literal is the display text and is
   * worth keeping, while anything more complex is left unresolved rather than
   * guessed at.
   */
  skipBlockStatement2(node = null) {
    this.next(); // function keyword
    const start = this.pos;
    this.skipBlock();
    const end = this.pos;
    if (!node) return;
    const text = this.firstStringReturn(this.tokens.slice(start, end));
    if (text !== null) node.infoText = text;
  }

  /** First `return <string>` literal in a token slice, or null. */
  firstStringReturn(tokens) {
    for (let i = 0; i < tokens.length - 1; i += 1) {
      const token = tokens[i];
      if (token.type !== 'keyword' || token.value !== 'return') continue;
      const next = tokens[i + 1];
      if (next?.type === 'string') return next.value;
      // `return ([[...]])` — the literal follows the opening parenthesis.
      if (next?.type === 'punct' && next.value === '(' && tokens[i + 2]?.type === 'string') {
        return tokens[i + 2].value;
      }
      return null;
    }
    return null;
  }

  /**
   * Consume a block body up to (and including) the `end` that closes it.
   *
   * Only one keyword announces each block: `function`, `if`, `for`, `while`
   * each consume a single `end`, `do` is just the body label of a `for`/`while`
   * and must NOT open a block of its own, and `repeat` is closed by `until`
   * rather than `end`. Getting this wrong swallows the enclosing entity table's
   * closing brace, so the counts are asserted by the parser tests.
   */
  skipBlock() {
    let endDepth = 1;
    // `repeat` bodies are closed by `until`; track them separately so an inner
    // `until` is not mistaken for the terminator of an outer one.
    let repeatDepth = 0;
    // A `for`/`while` header can contain arbitrary keyword noise
    // (`for k, v in pairs(t) do`), so remember that a loop header is open
    // rather than looking at the immediately previous keyword.
    let loopHeaderOpen = false;

    while (!this.at('eof') && (endDepth > 0 || repeatDepth > 0)) {
      const token = this.next();
      if (token.type !== 'keyword') continue;

      switch (token.value) {
        case 'function':
        case 'if':
          endDepth += 1;
          break;
        case 'for':
        case 'while':
          endDepth += 1;
          loopHeaderOpen = true;
          break;
        case 'do':
          // The `do` of `for ... do` / `while ... do` labels the body of the
          // loop already counted above; a bare `do ... end` opens its own.
          if (loopHeaderOpen) loopHeaderOpen = false;
          else endDepth += 1;
          break;
        case 'repeat':
          repeatDepth += 1;
          break;
        case 'until':
          repeatDepth = Math.max(0, repeatDepth - 1);
          break;
        case 'end':
          endDepth -= 1;
          break;
        default:
          break;
      }
    }
  }

  parseCallArgs() {
    const args = [];
    this.next(); // (
    this.skipNewlines();
    while (!this.at('eof') && !this.at('punct', ')')) {
      args.push(this.parseExpression());
      this.skipNewlines();
      if (this.at('punct', ',')) { this.next(); this.skipNewlines(); continue; }
      break;
    }
    if (this.at('punct', ')')) this.next();
    return args;
  }

  /**
   * Parse a table constructor. Returns
   * `{ kind: "table", array: [...], map: [{key, value, keyKind, line}], line }`.
   */
  parseTable() {
    const line = this.peek().line;
    this.next(); // {
    const table = { kind: 'table', array: [], map: [], line };
    this.skipNewlines();

    while (!this.at('eof') && !this.at('punct', '}')) {
      let entry = null;

      if (this.at('punct', '[')) {
        this.next();
        const key = this.parseExpression();
        if (this.at('punct', ']')) this.next();
        if (this.at('punct', '=')) this.next();
        const value = this.parseExpression();
        entry = { key, value, keyKind: 'expression', line: key.line ?? line };
      } else if (this.at('name') && this.peek(1).type === 'punct' && this.peek(1).value === '=') {
        const keyToken = this.next();
        this.next(); // =
        const value = this.parseExpression();
        entry = { key: { kind: 'string', value: keyToken.value }, value, keyKind: 'name', line: keyToken.line };
      } else if (
        (this.at('name') || this.at('keyword')) &&
        this.peek(1).type === 'punct' &&
        (this.peek(1).value === '.' || this.peek(1).value === ':')
      ) {
        // `resolvers.talents{...}` as a bare array entry, or `a.b = c`.
        const saved = this.pos;
        const keyStart = this.peek();
        const path = this.parsePath();
        if (this.at('punct', '=')) {
          this.next();
          const value = this.parseExpression();
          entry = {
            key: { kind: 'ref', path },
            value,
            keyKind: 'expression',
            line: keyStart.line,
          };
        } else {
          this.pos = saved;
          const value = this.parseExpression();
          entry = { key: null, value, keyKind: 'array', line: value.line ?? line };
        }
      } else if (
        this.at('name') &&
        this.peek(1).type === 'newline' &&
        this.peek(2).type === 'punct' &&
        this.peek(2).value !== '=' &&
        this.peek(2).value !== ','
      ) {
        // Malformed Lua in the wild: `x = 1 self:foo()` on one line with no
        // separator. Skip the stray identifier instead of misreading it as a
        // new array entry.
        const stray = this.next();
        this.note(`跳过缺少分隔符的记号 ${JSON.stringify(stray.value)}`, stray.line);
        continue;
      } else {
        const value = this.parseExpression();
        entry = { key: null, value, keyKind: 'array', line: value.line ?? line };
      }

      if (entry) {
        if (entry.keyKind === 'array') table.array.push(entry.value);
        else table.map.push(entry);
      }

      this.skipNewlines();
      if (this.at('punct', ',') || this.at('punct', ';')) {
        this.next();
        this.skipNewlines();
      }
    }

    if (this.at('punct', '}')) this.next();
    else this.note('表构造器未闭合', line);

    return table;
  }
}

// ---------------------------------------------------------------------------
// Entity collection
// ---------------------------------------------------------------------------

/** Convert an AST value into a plain JSON-ish value where possible. */
export function literalOf(node) {
  if (!node) return undefined;
  switch (node.kind) {
    case 'string': return node.value;
    case 'number': return node.value;
    case 'boolean': return node.value;
    case 'nil': return null;
    case 'negate': {
      const inner = literalOf(node.of);
      return typeof inner === 'number' ? -inner : undefined;
    }
    case 'arith': {
      // Only literal arithmetic (`3 / 5`, `100 * 1.5`) is folded; anything
      // else stays unknown so callers can report it.
      const left = literalOf(node.left);
      const right = literalOf(node.right);
      if (typeof left !== 'number' || typeof right !== 'number') return undefined;
      switch (node.op) {
        case '+': return left + right;
        case '-': return left - right;
        case '*': return left * right;
        case '/': return right === 0 ? undefined : left / right;
        case '%': return right === 0 ? undefined : left % right;
        case '^': return left ** right;
        default: return undefined;
      }
    }
    case 'table': {
      const out = {};
      for (const entry of node.map) {
        const key = keyName(entry.key);
        if (key === null) continue;
        out[key] = literalOf(entry.value);
      }
      // Array entries are not representable as a plain map; callers that care
      // read `node.array` from the AST instead.
      return out;
    }
    default:
      return undefined;
  }
}

/** Best-effort key name for a table key node (`["x"]`, `x`, or `[expr]`). */
export function keyName(node) {
  if (!node) return null;
  if (node.kind === 'string') return node.value;
  if (node.kind === 'number') return String(node.value);
  if (node.kind === 'ref') return node.path.join('.');
  return null;
}

/**
 * Walk the top-level assignments to find the local aliases used for the
 * talent table, e.g. `local Talents = require("engine.interface.ActorTalents")`.
 * Returns the set of variable names that resolve to talent constants.
 */
export function findTalentAliases(assignments) {
  const aliases = new Set(['Talents']);
  for (const assignment of assignments) {
    const value = assignment.value;
    if (!value || value.kind !== 'call') continue;
    const callee = value.path?.join('.');
    if (callee !== 'require') continue;
    const arg = value.args?.[0];
    const module = arg?.kind === 'string' ? arg.value : '';
    if (/ActorTalents/.test(module)) aliases.add(assignment.name);
  }
  return aliases;
}
