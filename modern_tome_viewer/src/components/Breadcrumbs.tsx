import { navigate } from '../hooks/useHashRoute';

export interface BreadcrumbItem {
  label: string;
  onClick?: () => void;
}

export function Breadcrumbs({ items }: { items: BreadcrumbItem[] }) {
  if (!items.length) return null;
  return (
    <nav className="mx-auto flex max-w-[1600px] items-center gap-1.5 overflow-x-auto px-4 pt-3 text-[11.5px] text-subtle" aria-label="面包屑">
      {items.map((item, index) => (
        <span key={`${item.label}-${index}`} className="flex shrink-0 items-center gap-1.5">
          {index > 0 && <span aria-hidden="true">/</span>}
          {item.onClick ? (
            <button type="button" className="hover:text-accent-strong hover:underline" onClick={item.onClick}>
              {item.label}
            </button>
          ) : (
            <span className={index === items.length - 1 ? 'font-medium text-fg' : ''} aria-current="page">
              {item.label}
            </span>
          )}
        </span>
      ))}
    </nav>
  );
}

export function homeBreadcrumb(): BreadcrumbItem {
  return { label: '首页', onClick: () => navigate('search') };
}
