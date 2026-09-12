import { useEffect, useRef, type ReactNode } from 'react';

interface MobileSheetProps {
  children: ReactNode;
  onClose: () => void;
  maxHeight?: '70vh' | '75vh' | '85vh';
  zIndex?: 'z-40' | 'z-50';
  testId?: string;
  ariaLabel?: string;
  breakpoint?: 'lg' | 'xl';
}

const HEIGHT_CLASSES: Record<NonNullable<MobileSheetProps['maxHeight']>, string> = {
  '70vh': 'max-h-[70vh]',
  '75vh': 'max-h-[75vh]',
  '85vh': 'max-h-[85vh]',
};

const BREAKPOINT_CLASSES: Record<NonNullable<MobileSheetProps['breakpoint']>, string> = {
  lg: 'lg:hidden',
  xl: 'xl:hidden',
};

export function MobileSheet({
  children,
  onClose,
  maxHeight = '70vh',
  zIndex = 'z-40',
  testId,
  ariaLabel = '详情面板',
  breakpoint = 'xl',
}: MobileSheetProps) {
  const restoreFocus = useRef<HTMLElement | null>(null);
  const onCloseRef = useRef(onClose);
  onCloseRef.current = onClose;

  useEffect(() => {
    const mediaQuery = breakpoint === 'lg' ? '(max-width: 1023px)' : '(max-width: 1279px)';
    const isMobile = typeof window.matchMedia !== 'function' || window.matchMedia(mediaQuery).matches;
    if (!isMobile) return undefined;

    restoreFocus.current = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';

    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onCloseRef.current();
    };
    window.addEventListener('keydown', onKey);

    return () => {
      window.removeEventListener('keydown', onKey);
      document.body.style.overflow = previousOverflow;
      restoreFocus.current?.focus({ preventScroll: true });
    };
  }, [breakpoint]);

  return (
    <div
      className={`fixed inset-0 ${zIndex} ${BREAKPOINT_CLASSES[breakpoint]}`}
      data-testid={testId}
      onClick={onClose}
      role="presentation"
    >
      <div className="absolute inset-0 bg-slate-950/35" aria-hidden="true" />
      <div
        className={`absolute inset-x-0 bottom-0 flex ${HEIGHT_CLASSES[maxHeight]} flex-col pb-[env(safe-area-inset-bottom)]`}
        onClick={(event) => event.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-label={ariaLabel}
      >
        <div className="mx-auto mb-1.5 mt-1 h-1 w-10 shrink-0 rounded-full bg-slate-400/60" aria-hidden="true" />
        <div className={`animate-fade-in mx-2 mb-1 flex ${HEIGHT_CLASSES[maxHeight]} min-h-0 flex-col overflow-hidden`}>
          {children}
        </div>
      </div>
    </div>
  );
}
