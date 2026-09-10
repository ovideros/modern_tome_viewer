/**
 * Small localStorage-backed list of talent ids, shared by favourites and the
 * comparison tray. Both are plain ordered id lists, so one hook covers both.
 */

import { useCallback, useEffect, useMemo, useState } from 'react';
import type { LoadedData } from '../lib/data';
import type { TalentEntry } from '../lib/types';

function read(key: string): string[] {
  try {
    const raw = window.localStorage.getItem(key);
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed.filter((v): v is string => typeof v === 'string') : [];
  } catch {
    return [];
  }
}

export interface IdList {
  ids: string[];
  /** Resolved talents, in list order, skipping ids that no longer exist. */
  entries: TalentEntry[];
  has: (id: string) => boolean;
  add: (id: string) => void;
  remove: (id: string) => void;
  toggle: (id: string) => void;
  clear: () => void;
  /** Set when an add was rejected because the list is full. */
  limitReached: boolean;
  full: boolean;
}

export function useIdList(
  storageKey: string,
  data: LoadedData | null,
  maxItems = Number.POSITIVE_INFINITY,
): IdList {
  const [ids, setIds] = useState<string[]>(() => read(storageKey));
  const [limitReached, setLimitReached] = useState(false);

  useEffect(() => {
    try {
      window.localStorage.setItem(storageKey, JSON.stringify(ids));
    } catch {
      /* storage disabled */
    }
  }, [storageKey, ids]);

  // Keep the flag from sticking around after the user makes room.
  useEffect(() => {
    if (limitReached && ids.length < maxItems) setLimitReached(false);
  }, [ids.length, maxItems, limitReached]);

  const add = useCallback(
    (id: string) => {
      setIds((current) => {
        if (current.includes(id)) return current;
        if (current.length >= maxItems) {
          setLimitReached(true);
          return current;
        }
        return [...current, id];
      });
    },
    [maxItems],
  );

  const remove = useCallback((id: string) => setIds((current) => current.filter((v) => v !== id)), []);

  const toggle = useCallback(
    (id: string) => {
      setIds((current) => {
        if (current.includes(id)) return current.filter((v) => v !== id);
        if (current.length >= maxItems) {
          setLimitReached(true);
          return current;
        }
        return [...current, id];
      });
    },
    [maxItems],
  );

  const clear = useCallback(() => setIds([]), []);

  const entries = useMemo(() => {
    if (!data) return [];
    return ids.map((id) => data.byId.get(id)).filter((entry): entry is TalentEntry => Boolean(entry));
  }, [ids, data]);

  const idSet = useMemo(() => new Set(ids), [ids]);

  return {
    ids,
    entries,
    has: (id: string) => idSet.has(id),
    add,
    remove,
    toggle,
    clear,
    limitReached,
    full: ids.length >= maxItems,
  };
}

export const FAVORITES_KEY = 'tome-favorites';
export const COMPARE_KEY = 'tome-compare';
export const COMPARE_LIMIT = 6;
