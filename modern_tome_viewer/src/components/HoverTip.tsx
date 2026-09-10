import { useCallback, useEffect, useLayoutEffect, useRef, useState, type ReactNode } from 'react';
import { createPortal } from 'react-dom';

interface HoverTipProps {
  /** Tooltip body. */
  content: ReactNode;
  /** The trigger; rendered inline and focused/hovered to show the tip. */
  children: ReactNode;
  className?: string;
  /** Test hook for the trigger element. */
  'data-testid'?: string;
}

const GAP = 8;
const MARGIN = 8;

/**
 * Tooltip that escapes its container.
 *
 * The talent detail panel and its scrolling body both clip overflow, so an
 * absolutely-positioned tip is cut off at the panel edge — and this tip is wider
 * than the 380px panel. The tip is therefore rendered into `document.body` with
 * fixed coordinates measured from the trigger, and it flips above/below and
 * clamps horizontally to stay on screen.
 */
export function HoverTip({ content, children, className, 'data-testid': testId }: HoverTipProps) {
  const triggerRef = useRef<HTMLSpanElement>(null);
  const tipRef = useRef<HTMLSpanElement>(null);
  const [open, setOpen] = useState(false);
  const [pos, setPos] = useState<{ top: number; left: number; placement: 'top' | 'bottom' } | null>(null);

  const place = useCallback(() => {
    const trigger = triggerRef.current;
    const tip = tipRef.current;
    if (!trigger || !tip) return;
    const rect = trigger.getBoundingClientRect();
    const size = tip.getBoundingClientRect();
    const viewportW = window.innerWidth;
    const viewportH = window.innerHeight;

    // Prefer above the trigger; flip below when there is not enough room.
    const roomAbove = rect.top;
    const placement: 'top' | 'bottom' = roomAbove >= size.height + GAP + MARGIN ? 'top' : 'bottom';
    const top = placement === 'top' ? rect.top - size.height - GAP : rect.bottom + GAP;

    let left = rect.left + rect.width / 2 - size.width / 2;
    left = Math.max(MARGIN, Math.min(left, viewportW - size.width - MARGIN));

    setPos({ top: Math.max(MARGIN, Math.min(top, viewportH - size.height - MARGIN)), left, placement });
  }, []);

  // Measure once the tip is in the DOM, so its real size drives the placement.
  useLayoutEffect(() => {
    if (open) place();
  }, [open, place, content]);

  useEffect(() => {
    if (!open) {
      setPos(null);
      return;
    }
    // Keep the tip glued to the trigger while scrolling or resizing any ancestor.
    const onChange = () => place();
    window.addEventListener('scroll', onChange, true);
    window.addEventListener('resize', onChange);
    return () => {
      window.removeEventListener('scroll', onChange, true);
      window.removeEventListener('resize', onChange);
    };
  }, [open, place]);

  return (
    <>
      <span
        ref={triggerRef}
        className={`inline-flex items-center ${className ?? ''}`}
        data-testid={testId}
        onMouseEnter={() => setOpen(true)}
        onMouseLeave={() => setOpen(false)}
        onFocus={() => setOpen(true)}
        onBlur={() => setOpen(false)}
        tabIndex={0}
      >
        {/* A text-only wrapper keeps the trigger's accessible name (and its
            innerText) equal to the value, even when the tip body starts with a
            span, so tests and screen readers read the number rather than a label. */}
        <span>{children}</span>
      </span>
      {open &&
        createPortal(
          <span
            ref={tipRef}
            role="tooltip"
            className="pointer-events-none fixed z-[100] block w-max max-w-[340px] rounded-md border border-line bg-raised px-2.5 py-1.5 text-left text-[11px] leading-relaxed text-fg shadow-panel"
            style={{
              top: pos?.top ?? -9999,
              left: pos?.left ?? -9999,
              visibility: pos ? 'visible' : 'hidden',
            }}
          >
            {content}
          </span>,
          document.body,
        )}
    </>
  );
}
