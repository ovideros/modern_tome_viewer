import { useMemo, type ReactNode } from 'react';

interface HighlightProps {
  text: string;
  /** Terms to highlight, as typed by the user. */
  terms: string[];
  className?: string;
}

/**
 * Highlights every occurrence of the search terms inside a plain string.
 * CJK terms highlight exact substrings; ASCII terms are case-insensitive.
 */
export function Highlight({ text, terms, className }: HighlightProps) {
  const parts = useMemo(() => splitByTerms(text, terms), [text, terms]);

  return (
    <span className={className}>
      {parts.map((part, index) =>
        part.match ? (
          <mark key={index} className="mark">
            {part.text}
          </mark>
        ) : (
          <span key={index}>{part.text}</span>
        ),
      )}
    </span>
  );
}

interface Segment {
  text: string;
  match: boolean;
}

function splitByTerms(text: string, terms: string[]): Segment[] {
  const cleaned = [...new Set(terms.map((t) => t.trim()).filter((t) => t.length > 0))];
  if (!cleaned.length) return [{ text, match: false }];

  // Longest first so "火焰伤害" wins over "火焰".
  cleaned.sort((a, b) => b.length - a.length);
  const escaped = cleaned.map((term) => term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
  const pattern = new RegExp(`(${escaped.join('|')})`, 'gi');

  const segments: Segment[] = [];
  let lastIndex = 0;
  for (const match of text.matchAll(pattern)) {
    const index = match.index ?? 0;
    if (index > lastIndex) segments.push({ text: text.slice(lastIndex, index), match: false });
    segments.push({ text: match[0], match: true });
    lastIndex = index + match[0].length;
  }
  if (lastIndex < text.length) segments.push({ text: text.slice(lastIndex), match: false });
  return segments.length ? segments : [{ text, match: false }];
}

/** Renders game HTML (already sanitized to spans/acronyms) with tooltips. */
export function GameText({ html, className }: { html: string; className?: string }): ReactNode {
  return <div className={`talent-text ${className ?? ''}`} dangerouslySetInnerHTML={{ __html: html }} />;
}
