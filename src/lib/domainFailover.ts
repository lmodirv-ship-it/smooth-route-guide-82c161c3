/**
 * APK Domain Failover utility.
 * Tries domains in priority order, caches the working one for 24h.
 * Used by the native splash screen and as a runtime healthcheck.
 */

export const APK_DOMAIN_PRIORITY = [
  "https://hndriver.company",      // 🟢 PRIMARY (Lovable, paid 1y)
  "https://www.hn-driver.com",     // Backup 1
  "https://www.hn-driver.net",     // Backup 2
] as const;

const CACHE_KEY = "hn_apk_active_domain";
const CACHE_TTL_MS = 24 * 60 * 60 * 1000; // 24h
const PROBE_TIMEOUT_MS = 4000;

interface CachedDomain {
  url: string;
  ts: number;
}

const probe = async (url: string): Promise<boolean> => {
  try {
    const ctrl = new AbortController();
    const t = setTimeout(() => ctrl.abort(), PROBE_TIMEOUT_MS);
    // no-cors HEAD: opaque response is enough to know server is reachable
    await fetch(url + "/favicon.png", {
      method: "HEAD",
      mode: "no-cors",
      cache: "no-store",
      signal: ctrl.signal,
    });
    clearTimeout(t);
    return true;
  } catch {
    return false;
  }
};

export const getCachedDomain = (): string | null => {
  try {
    const raw = localStorage.getItem(CACHE_KEY);
    if (!raw) return null;
    const c: CachedDomain = JSON.parse(raw);
    if (Date.now() - c.ts > CACHE_TTL_MS) return null;
    return c.url;
  } catch {
    return null;
  }
};

export const setCachedDomain = (url: string) => {
  try {
    localStorage.setItem(CACHE_KEY, JSON.stringify({ url, ts: Date.now() }));
  } catch { /* ignore */ }
};

export const clearCachedDomain = () => {
  try { localStorage.removeItem(CACHE_KEY); } catch { /* ignore */ }
};

/** Returns the first reachable domain (or null if all fail). */
export const findActiveDomain = async (): Promise<string | null> => {
  const cached = getCachedDomain();
  if (cached && await probe(cached)) return cached;

  for (const url of APK_DOMAIN_PRIORITY) {
    if (await probe(url)) {
      setCachedDomain(url);
      return url;
    }
  }
  return null;
};
