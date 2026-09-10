import { useEffect, useState } from 'react';

export interface Route {
  name: string;
  params: URLSearchParams;
}

function parseHash(): Route {
  const raw = window.location.hash.replace(/^#\/?/, '');
  const [name, search] = raw.split('?');
  return { name: name || 'search', params: new URLSearchParams(search ?? '') };
}

export function useHashRoute(): Route {
  const [route, setRoute] = useState<Route>(parseHash);

  useEffect(() => {
    const onChange = () => setRoute(parseHash());
    window.addEventListener('hashchange', onChange);
    return () => window.removeEventListener('hashchange', onChange);
  }, []);

  return route;
}

export function navigate(name: string, params: URLSearchParams | Record<string, string> = {}) {
  const search = params instanceof URLSearchParams ? params.toString() : new URLSearchParams(params).toString();
  const next = `#/${name}${search ? `?${search}` : ''}`;
  if (window.location.hash !== next) window.location.hash = next;
}
