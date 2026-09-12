import type { ReactNode } from 'react';

interface MobileSheetProps {
  children: ReactNode;
  onClose: () => void;
  maxHeight?: '70vh' | '75vh' | '85vh';
  zIndex?: 'z-40' | 'z-50';
  testId?: string;
}

const HEIGHT_CLASSES: Record<NonNullable<MobileSheetProps['maxHeight']>, string> = {
  '70vh': 'max-h-[70vh]',
  '75vh': 'max-h-[75vh]',
  '85vh': 'max-h-[85vh]',
};

export function MobileSheet({
  children,
  onClose,
  maxHeight = '70vh',
  zIndex = 'z-40',
  testId,
}: MobileSheetProps) {
  return (
    <div
      className={`fixed inset-0 ${zIndex} xl:hidden`}
      data-testid={testId}
      onClick={onClose}
      role="presentation"
    >
      <div className="absolute inset-0 bg-slate-950/35" aria-hidden="true" />
      <div
        className={`absolute inset-x-0 bottom-0 flex ${HEIGHT_CLASSES[maxHeight]} flex-col`}
        onClick={(event) => event.stopPropagation()}
        role="dialog"
        aria-modal="true"
      >
        <div className={`animate-fade-in mx-2 mb-2 flex ${HEIGHT_CLASSES[maxHeight]} min-h-0 flex-col overflow-hidden`}>
          {children}
        </div>
      </div>
    </div>
  );
}
