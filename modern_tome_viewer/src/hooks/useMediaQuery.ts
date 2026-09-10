import { useEffect, useState } from 'react';

/**
 * True when the viewport matches `query`, kept in sync with resizes.
 *
 * `fallback` is returned when `matchMedia` is unavailable (happy-dom, very old
 * engines). Callers whose logic turns *off* a responsive layout should pass
 * `true`, so an environment that cannot answer keeps the desktop behaviour
 * instead of silently dropping a panel.
 */
export function useMediaQuery(query: string, fallback = false): boolean {
  const [matches, setMatches] = useState(() =>
    typeof window !== 'undefined' && typeof window.matchMedia === 'function' ? window.matchMedia(query).matches : fallback,
  );

  useEffect(() => {
    if (typeof window === 'undefined' || typeof window.matchMedia !== 'function') {
      setMatches(fallback);
      return;
    }
    const list = window.matchMedia(query);
    const update = () => setMatches(list.matches);
    update();
    // `addEventListener` is missing on very old engines; guard both shapes.
    if (list.addEventListener) {
      list.addEventListener('change', update);
      return () => list.removeEventListener('change', update);
    }
    list.addListener(update);
    return () => list.removeListener(update);
  }, [query, fallback]);

  return matches;
}
