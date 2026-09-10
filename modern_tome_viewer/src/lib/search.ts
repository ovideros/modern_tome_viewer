/**
 * A small, dependency-free full-text index tuned for ToME talent data.
 *
 * Why not FlexSearch: its tokenizers handle CJK substrings poorly (a query for
 * 寒冰 fails to match a document containing 寒冰之矛), and the Document API
 * cannot express "match this term in these fields only" cleanly. For ~1800
 * talents a purpose-built inverted index is both simpler and more predictable.
 *
 * Tokenization:
 *   - CJK characters become unigrams plus overlapping bigrams ("火焰冲击" ->
 *     火, 火焰, 焰, 焰冲, 冲, 冲击, 击), so both "火焰" and "焰冲" match.
 *   - ASCII/digits become lowercased words, matched exactly or as a prefix.
 *   - Punctuation separates tokens.
 *
 * Query language (all terms are ANDed):
 *   fire              full text
 *   "fire damage"     phrase
 *   name:fire         restrict a term to one field
 *   tree:spell/fire   field-scoped with punctuation
 *   -name:passive     negated term
 *   mode:主动          Chinese works the same way
 */

export const SEARCH_FIELDS = ['name', 'tree', 'category', 'text'] as const;
export type SearchField = (typeof SEARCH_FIELDS)[number];

/** Relative weight of each field when ranking matches. */
export const FIELD_WEIGHTS: Record<SearchField, number> = {
  name: 12,
  tree: 6,
  category: 3,
  text: 1,
};

export const FIELD_LABELS: Record<SearchField, string> = {
  name: '技能名',
  tree: '技能大系',
  category: '技能分类',
  text: '技能文本',
};

const CJK = /[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\u3040-\u30ff\uac00-\ud7af]/;
const ASCII_WORD = /[a-z0-9]/;

/** Split a string into CJK unigrams/bigrams and lowercase ASCII words. */
export function tokenize(input: string): string[] {
  const text = String(input ?? '').toLowerCase();
  const base: string[] = [];
  let buffer = '';
  const flush = () => {
    if (buffer) {
      base.push(buffer);
      buffer = '';
    }
  };

  for (const char of text) {
    if (CJK.test(char)) {
      flush();
      base.push(char);
    } else if (ASCII_WORD.test(char)) {
      buffer += char;
    } else {
      flush();
    }
  }
  flush();

  const tokens: string[] = [];
  for (let i = 0; i < base.length; i += 1) {
    const token = base[i];
    tokens.push(token);
    const next = base[i + 1];
    if (next && CJK.test(token) && CJK.test(next)) tokens.push(token + next);
  }
  return tokens;
}

/** True when the query string contains CJK, i.e. we should also try bigrams. */
export function hasCjk(input: string): boolean {
  return CJK.test(input);
}

interface Posting {
  id: number;
  freq: number;
}

export interface FieldIndex {
  /** term -> postings */
  postings: Map<string, Posting[]>;
  /** terms sorted, used for prefix expansion */
  sortedTerms: string[];
  /** number of indexed documents in this field */
  docCount: number;
}

export interface SearchDocument {
  name: string;
  tree: string;
  category: string;
  text: string;
}

export interface IndexOptions {
  /** Minimum prefix length before prefix expansion kicks in. */
  minPrefix?: number;
  /** Cap on prefix expansions per term, to keep worst-case cost bounded. */
  maxPrefixExpansions?: number;
}

export interface SearchOptions {
  limit?: number;
  /** Fields used for bare (unqualified) terms. */
  defaultFields?: SearchField[];
  /** When true, only exact token matches are considered (no prefix expansion). */
  exact?: boolean;
  /** Maximum documents returned before ranking. */
  candidateCap?: number;
}

export interface SearchHit {
  index: number;
  score: number;
  matchedTerms: string[];
}

export interface ParsedTerm {
  raw: string;
  value: string;
  field: SearchField | null;
  negated: boolean;
  phrase: boolean;
}

export class TalentSearchIndex {
  private readonly fields: Record<SearchField, FieldIndex>;
  private readonly docs: SearchDocument[];
  private readonly options: Required<IndexOptions>;

  constructor(docs: SearchDocument[], options: IndexOptions = {}) {
    this.docs = docs;
    this.options = {
      minPrefix: options.minPrefix ?? 2,
      maxPrefixExpansions: options.maxPrefixExpansions ?? 200,
    };
    this.fields = {
      name: emptyField(),
      tree: emptyField(),
      category: emptyField(),
      text: emptyField(),
    };

    for (const [docIndex, doc] of docs.entries()) {
      for (const field of SEARCH_FIELDS) {
        this.indexField(docIndex, field, doc[field]);
      }
    }

    for (const field of SEARCH_FIELDS) {
      const index = this.fields[field];
      index.sortedTerms = [...index.postings.keys()].sort();
    }
  }

  private indexField(docIndex: number, field: SearchField, value: string) {
    const index = this.fields[field];
    const tokens = tokenize(value);
    if (!tokens.length) return;

    const counts = new Map<string, number>();
    for (const token of tokens) counts.set(token, (counts.get(token) ?? 0) + 1);

    for (const [token, freq] of counts) {
      let postings = index.postings.get(token);
      if (!postings) {
        postings = [];
        index.postings.set(token, postings);
      }
      postings.push({ id: docIndex, freq });
    }
    index.docCount += 1;
  }

  get documentCount(): number {
    return this.docs.length;
  }

  /** Number of distinct terms across all fields — handy for diagnostics. */
  get termCount(): number {
    return SEARCH_FIELDS.reduce((sum, field) => sum + this.fields[field].postings.size, 0);
  }

  /** Parse the query language into terms. Exposed for UI hints and tests. */
  static parseQuery(query: string): ParsedTerm[] {
    const terms: ParsedTerm[] = [];
    // A term is a quoted phrase, or a run of non-space characters that may
    // contain "/" so tree paths such as tree:spell/fire stay a single term.
    const pattern = /(-?)(?:([a-zA-Z]+):)?("[^"]*"|[^\s"]+)/g;
    let match: RegExpExecArray | null;
    while ((match = pattern.exec(query)) !== null) {
      const [, negation, fieldName, rawToken] = match;
      const quoted = rawToken.startsWith('"');
      const raw = (quoted ? rawToken.slice(1, -1) : rawToken).trim();
      if (!raw) continue;
      const field = (SEARCH_FIELDS as readonly string[]).includes(fieldName ?? '')
        ? (fieldName as SearchField)
        : null;
      // An unknown prefix such as "cooldown:5" is treated as plain text so the
      // query still does something sensible.
      const value = field ? raw : fieldName ? `${fieldName}:${raw}` : raw;
      terms.push({
        raw,
        value,
        field,
        negated: negation === '-',
        phrase: quoted,
      });
    }
    return terms;
  }

  /**
   * Expand a term into the token groups it must match.
   *
   * A term can carry several tokens — "spell/fire" tokenizes to spell + fire,
   * and CJK terms produce unigrams and bigrams. Every group must match the same
   * document for the term to count, which is what makes "spell/fire" mean the
   * spell tree named fire rather than any spell or any fire.
   */
  private expandGroups(term: ParsedTerm, field: SearchField, exact: boolean): string[][] {
    const value = term.value.toLowerCase();
    const tokens = tokenize(value);
    if (!tokens.length) return [];

    const groups: string[][] = [];
    for (const token of tokens) {
      const group = this.expandToken(token, field, exact);
      if (!group.length) return [];
      groups.push(group);
    }
    return groups;
  }

  /** All index terms that satisfy one token: the token itself or a prefix match. */
  private expandToken(token: string, field: SearchField, exact: boolean): string[] {
    const index = this.fields[field];
    if (index.postings.has(token)) return [token];
    if (exact) return [];
    if (token.length < this.options.minPrefix) return [];
    if (CJK.test(token)) return [];

    const start = lowerBound(index.sortedTerms, token);
    const expanded: string[] = [];
    for (let i = start; i < index.sortedTerms.length; i += 1) {
      const candidate = index.sortedTerms[i];
      if (!candidate.startsWith(token)) break;
      expanded.push(candidate);
      if (expanded.length >= this.options.maxPrefixExpansions) break;
    }
    return expanded;
  }

  /** Inverse document frequency, smoothed to avoid division by zero. */
  private idf(field: SearchField, term: string): number {
    const index = this.fields[field];
    const df = index.postings.get(term)?.length ?? 0;
    const total = Math.max(index.docCount, 1);
    return Math.log(1 + total / (1 + df));
  }

  search(query: string, options: SearchOptions = {}): SearchHit[] {
    const limit = options.limit ?? 60;
    const defaultFields = options.defaultFields ?? [...SEARCH_FIELDS];
    const exact = options.exact ?? false;
    const candidateCap = options.candidateCap ?? 4000;
    const terms = TalentSearchIndex.parseQuery(query).filter((term) => term.value.length > 0);
    if (!terms.length) return [];

    // docId -> accumulated score / matched index terms
    const scores = new Map<number, number>();
    const matchedByDoc = new Map<number, Set<string>>();
    let first = true;

    for (const term of terms) {
      const fields = term.field ? [term.field] : defaultFields;
      const perDoc = new Map<number, { score: number; terms: Set<string> }>();

      for (const field of fields) {
        const groups = this.expandGroups(term, field, exact);
        if (!groups.length) continue;

        // Intersect the posting lists group by group: a document must contain
        // every token of the term in this field.
        let candidates: Map<number, number> | null = null;
        for (const group of groups) {
          const groupCounts = new Map<number, number>();
          for (const expansion of group) {
            const postings = this.fields[field].postings.get(expansion);
            if (!postings) continue;
            for (const posting of postings) {
              groupCounts.set(posting.id, (groupCounts.get(posting.id) ?? 0) + posting.freq);
            }
          }
          if (!groupCounts.size) {
            candidates = null;
            break;
          }
          if (candidates === null) {
            candidates = groupCounts;
          } else {
            for (const id of [...candidates.keys()]) {
              if (!groupCounts.has(id)) candidates.delete(id);
              else candidates.set(id, (candidates.get(id) ?? 0) + (groupCounts.get(id) ?? 0));
            }
            if (!candidates.size) break;
          }
        }
        if (!candidates || !candidates.size) continue;

        // Rarer tokens carry more signal: for "火焰" the bigram is far more
        // specific than the unigram 火, so use the strongest IDF in the term.
        let idf = 0;
        for (const group of groups) {
          for (const token of group) idf = Math.max(idf, this.idf(field, token));
        }

        const groupBonus = groups.length;
        for (const [id, freq] of candidates) {
          const entry = perDoc.get(id) ?? { score: 0, terms: new Set<string>() };
          // Longer terms (more matched tokens) are more specific → score higher.
          entry.score += FIELD_WEIGHTS[field] * groupBonus * idf * (1 + Math.log(freq));
          for (const group of groups) for (const token of group) entry.terms.add(token);
          perDoc.set(id, entry);
        }
      }

      if (term.negated) {
        for (const id of perDoc.keys()) {
          scores.delete(id);
          matchedByDoc.delete(id);
        }
        if (first) {
          // A query made only of negations has no positive candidate set.
          for (let i = 0; i < this.docs.length; i += 1) {
            if (!perDoc.has(i)) scores.set(i, 0);
          }
        }
        first = false;
        continue;
      }

      if (first) {
        for (const [id, entry] of perDoc) {
          scores.set(id, entry.score);
          matchedByDoc.set(id, entry.terms);
        }
        first = false;
      } else {
        // AND semantics: keep only documents matching this term too.
        for (const id of [...scores.keys()]) {
          const entry = perDoc.get(id);
          if (!entry) {
            scores.delete(id);
            matchedByDoc.delete(id);
          } else {
            scores.set(id, (scores.get(id) ?? 0) + entry.score);
            const matched = matchedByDoc.get(id);
            if (matched) for (const token of entry.terms) matched.add(token);
          }
        }
      }

      if (scores.size === 0) return [];
    }

    const hits: SearchHit[] = [];
    for (const [id, score] of scores) {
      hits.push({ index: id, score, matchedTerms: [...(matchedByDoc.get(id) ?? [])] });
      if (hits.length >= candidateCap) break;
    }

    hits.sort((a, b) => b.score - a.score || a.index - b.index);
    return hits.slice(0, limit);
  }
}

function emptyField(): FieldIndex {
  return { postings: new Map(), sortedTerms: [], docCount: 0 };
}

/** First index whose value is >= target, in a sorted string array. */
function lowerBound(sorted: string[], target: string): number {
  let low = 0;
  let high = sorted.length;
  while (low < high) {
    const mid = (low + high) >>> 1;
    if (sorted[mid] < target) low = mid + 1;
    else high = mid;
  }
  return low;
}
