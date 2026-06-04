// Legacy registerSW.js — kept to avoid 404 and remove old PWA caches from previous releases.
(async () => {
  try {
    if ("serviceWorker" in navigator) {
      const registrations = await navigator.serviceWorker.getRegistrations();
      await Promise.all(registrations.map((registration) => registration.unregister()));
    }

    if ("caches" in window) {
      const keys = await caches.keys();
      await Promise.all(keys.map((key) => caches.delete(key)));
    }

    const marker = "hn_lws_cache_cleanup_v1";
    if (!sessionStorage.getItem(marker) && location.search.includes("sw-cleanup")) {
      sessionStorage.setItem(marker, "1");
      location.replace(location.pathname + location.hash);
    }
  } catch {
    // Best-effort cleanup only.
  }
})();
