import { navigate } from '../hooks/useHashRoute';
import type { Theme } from '../hooks/useTheme';
import type { BuildManifest } from '../lib/types';

interface HeaderProps {
  route: string;
  theme: Theme;
  onToggleTheme: () => void;
  manifest: BuildManifest | null;
  favoriteCount: number;
  compareCount: number;
}

const NAV = [
  { name: 'search', label: '高级搜索' },
  { name: 'classes', label: '职业' },
  { name: 'races', label: '种族' },
  { name: 'monsters', label: '怪物' },
  { name: 'egos', label: '装备词缀' },
  { name: 'artifacts', label: '固定神器' },
  { name: 'sets', label: '套装' },
  { name: 'favorites', label: '收藏' },
];

export function Header({ route, theme, onToggleTheme, manifest, favoriteCount, compareCount }: HeaderProps) {
  const countFor = (name: string): number | null => {
    if (name === 'favorites' && favoriteCount > 0) return favoriteCount;
    if (name === 'compare' && compareCount > 0) return compareCount;
    return null;
  };

  return (
    <header className="sticky top-0 z-30 border-b border-line bg-surface/85 backdrop-blur">
      <div className="mx-auto flex max-w-[1600px] flex-wrap items-center gap-x-4 gap-y-1 px-4 py-2.5">
        <button type="button" className="flex items-baseline gap-2" onClick={() => navigate('search')}>
          <span className="text-[15px] font-bold tracking-tight">ToME 技能查看器</span>
          <span className="hidden text-[11px] text-subtle sm:inline">Tales of Maj'Eyal</span>
        </button>

        <nav className="flex flex-wrap items-center gap-1">
          {NAV.map((item) => {
            const count = countFor(item.name);
            return (
              <button
                key={item.name}
                type="button"
                className="btn"
                aria-pressed={route === item.name}
                onClick={() => navigate(item.name)}
              >
                {item.label}
                {count !== null && (
                  <span className="rounded-full bg-accent px-1.5 text-[10.5px] font-bold text-accent-contrast">
                    {count}
                  </span>
                )}
              </button>
            );
          })}
        </nav>

        <div className="ml-auto flex items-center gap-2">
          {manifest && (
            <span className="hidden text-[11px] text-subtle xl:inline" title={`构建于 ${manifest.builtAt}`}>
              数据 {manifest.gameVersion} · {manifest.counts.talents} 技能 / {manifest.counts.trees} 大系 ·{' '}
              {manifest.hash}
            </span>
          )}
          <button
            type="button"
            className="btn px-2"
            onClick={onToggleTheme}
            title={theme === 'dark' ? '切换到亮色主题' : '切换到暗色主题'}
            aria-label="切换主题"
          >
            {theme === 'dark' ? '☀' : '☾'}
          </button>
        </div>
      </div>
    </header>
  );
}
