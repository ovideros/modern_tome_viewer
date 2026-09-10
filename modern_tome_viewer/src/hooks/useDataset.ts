import { useEffect, useState } from 'react';
import { loadDataset, type LoadedData } from '../lib/data';
import { TalentSearchIndex } from '../lib/search';

export interface DataState {
  data: LoadedData | null;
  index: TalentSearchIndex | null;
  error: string | null;
  /** 0–100, so the UI can show real progress while the dataset parses. */
  progress: number;
  building: boolean;
}

/**
 * Loads the dataset once and builds the search index off the critical path.
 *
 * The JSON fetch is the slow part (~2.5 MB); the index build (~1800 docs) is
 * done in a second pass so the browser can paint the shell and results first.
 */
export function useDataset(): DataState {
  const [state, setState] = useState<DataState>({
    data: null,
    index: null,
    error: null,
    progress: 0,
    building: false,
  });

  useEffect(() => {
    let cancelled = false;

    (async () => {
      try {
        setState((s) => ({ ...s, progress: 5 }));
        const data = await loadDataset();
        if (cancelled) return;
        setState((s) => ({ ...s, data, progress: 70, building: true }));

        // Yield a frame so the shell renders before the index build blocks.
        await new Promise((resolve) => requestAnimationFrame(() => resolve(null)));
        const index = new TalentSearchIndex(
          data.talents.map((talent) => ({
            // Ids are indexed alongside display names so queries such as
            // tree:spell/fire or name:T_FIRE_STORM resolve as users expect.
            name: `${talent.plainName} ${talent.shortName} ${talent.id}`,
            tree: `${talent.treeName} ${talent.tree}`,
            category: `${talent.categoryName} ${talent.category}`,
            text: talent.plain,
          })),
        );
        if (cancelled) return;
        setState((s) => ({ ...s, index, progress: 100, building: false }));
      } catch (error) {
        if (cancelled) return;
        setState((s) => ({
          ...s,
          error: error instanceof Error ? error.message : String(error),
          building: false,
        }));
      }
    })();

    return () => {
      cancelled = true;
    };
  }, []);

  return state;
}
