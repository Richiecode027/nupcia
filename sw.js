/* Service Worker de Nupcia — caché ligera para que abra offline */
const CACHE = "nupcia-v4";
const SHELL = ["./", "index.html", "manifest.json", "icon.svg"];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  // Solo manejamos GET del mismo origen. Supabase y la librería CDN van directo a la red.
  if (req.method !== "GET" || new URL(req.url).origin !== self.location.origin) return;

  // Network-first: intenta la red, guarda en caché, y si falla usa la caché.
  e.respondWith(
    fetch(req).then(res => {
      const copy = res.clone();
      caches.open(CACHE).then(c => c.put(req, copy)).catch(() => {});
      return res;
    }).catch(() => caches.match(req).then(r => r || caches.match("index.html")))
  );
});
