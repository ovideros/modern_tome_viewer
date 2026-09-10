import { useEffect } from 'react';

/**
 * Keeps `--header-h` in sync with the real header height.
 *
 * The header wraps on narrow viewports, so a hard-coded sticky offset would let
 * the search bar slide under it. Sticky elements use
 * `top: calc(var(--header-h) + 2px)` instead.
 */
export function useHeaderHeight(): void {
  useEffect(() => {
    const header = document.querySelector('header');
    if (!header) return;

    const apply = () => {
      const height = Math.round(header.getBoundingClientRect().height);
      document.documentElement.style.setProperty('--header-h', `${height}px`);
    };

    apply();
    // ResizeObserver is unavailable in some test DOMs; fall back to resize events.
    const observer = typeof ResizeObserver === 'function' ? new ResizeObserver(apply) : null;
    observer?.observe(header);
    window.addEventListener('resize', apply);
    return () => {
      observer?.disconnect();
      window.removeEventListener('resize', apply);
    };
  }, []);
}
