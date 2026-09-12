import { useEffect } from 'react';

export interface BrowsePickerGroup {
  id: string;
  name: string;
  childCount: number;
  children: { id: string; name: string }[];
}

interface MobileBrowsePickerProps {
  title: string;
  currentName: string;
  filter: string;
  onFilterChange: (value: string) => void;
  groups: BrowsePickerGroup[];
  selectedId: string | undefined;
  onSelect: (id: string) => void;
  onSelectChild: (id: string) => void;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  emptyLabel: string;
  childLabel?: string;
}

export function MobileBrowsePicker({
  title,
  currentName,
  filter,
  onFilterChange,
  groups,
  selectedId,
  onSelect,
  onSelectChild,
  open,
  onOpenChange,
  emptyLabel,
  childLabel = `子${title}`,
}: MobileBrowsePickerProps) {
  useEffect(() => {
    if (!open) return;
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') onOpenChange(false);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, onOpenChange]);

  return (
    <>
      <button
        type="button"
        className="btn lg:hidden"
        aria-expanded={open}
        onClick={() => onOpenChange(true)}
        data-testid="mobile-browse-trigger"
      >
        {title}：{currentName} ▾
      </button>

      {open && (
        <div
          className="fixed inset-0 z-40 lg:hidden"
          onClick={() => onOpenChange(false)}
          role="presentation"
        >
          <div className="absolute inset-0 bg-slate-950/35" aria-hidden="true" />
          <div
            className="absolute inset-x-0 bottom-0 flex max-h-[78vh] flex-col"
            onClick={(event) => event.stopPropagation()}
            role="dialog"
            aria-modal="true"
            aria-label={`${title}选择`}
          >
            <div className="animate-fade-in mx-2 mb-2 flex min-h-0 flex-col overflow-hidden rounded-xl border border-line bg-surface shadow-panel">
              <div className="flex items-center justify-between gap-2 border-b border-line px-3 py-2.5">
                <h2 className="text-[14px] font-semibold">选择{title}</h2>
                <button type="button" className="btn-ghost btn px-2 py-1" onClick={() => onOpenChange(false)}>
                  关闭
                </button>
              </div>
              <div className="border-b border-line p-2.5">
                <input
                  autoFocus
                  className="input"
                  placeholder={`筛选${title} / ${childLabel}…`}
                  value={filter}
                  onChange={(event) => onFilterChange(event.target.value)}
                />
              </div>
              <div className="min-h-0 overflow-y-auto py-1">
                {groups.map((group) => (
                  <div key={group.id}>
                    <button
                      type="button"
                      onClick={() => {
                        onSelect(group.id);
                        onOpenChange(false);
                      }}
                      className={`flex w-full items-center justify-between gap-2 px-3 py-2 text-left text-[13px] font-semibold hover:bg-hover ${
                        group.id === selectedId ? 'bg-accent-soft text-accent-strong' : ''
                      }`}
                    >
                      <span className="truncate">{group.name}</span>
                      <span className="shrink-0 text-[11px] font-normal text-subtle">{group.childCount}</span>
                    </button>
                    {group.id === selectedId &&
                      group.children.map((child) => (
                        <button
                          key={child.id}
                          type="button"
                          onClick={() => {
                            onSelectChild(child.id);
                            onOpenChange(false);
                          }}
                          className="block w-full truncate py-1.5 pl-7 pr-3 text-left text-[12px] text-muted hover:bg-hover hover:text-fg"
                        >
                          {child.name}
                        </button>
                      ))}
                  </div>
                ))}
                {!groups.length && <p className="px-3 py-5 text-center text-[12px] text-subtle">{emptyLabel}</p>}
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
