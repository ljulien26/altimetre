/* Altimètre — service worker
   Coquille applicative en cache, données live toujours réseau. */
const VERSION = "altimetre-v5";
const SHELL = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./icon-192.png",
  "./icon-512.png",
  "./apple-touch-icon.png"
];

self.addEventListener("install", e => {
  e.waitUntil(
    caches.open(VERSION)
      // {cache:"reload"} : sans ça, le précache peut être rempli depuis le cache HTTP
      // du navigateur (GitHub Pages envoie max-age=600) et réinstaller les vieux fichiers.
      .then(c => c.addAll(SHELL.map(u => new Request(u, {cache:"reload"}))))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if(req.method !== "GET") return;
  const url = new URL(req.url);

  // Mesures live : jamais de cache, sinon on afficherait de vieilles valeurs.
  if(/open-meteo\.com|bigdatacloud\.net/.test(url.hostname)) return;

  // Navigation : réseau d'abord (pour récupérer les mises à jour), coquille en secours.
  // On court-circuite le cache HTTP, sinon un rechargement dans les 10 minutes qui
  // suivent un déploiement peut resservir l'ancienne page.
  if(req.mode === "navigate"){
    e.respondWith(
      fetch(new Request(req.url, {cache:"reload", credentials:"same-origin"}))
        .then(res => {
          const copy = res.clone();
          caches.open(VERSION).then(c => c.put("./index.html", copy));
          return res;
        })
        .catch(() => caches.match("./index.html", {ignoreSearch:true}))
    );
    return;
  }

  // Polices Google + fichiers de l'app : cache d'abord, complété au fil de l'eau.
  e.respondWith(
    caches.match(req).then(hit => hit || fetch(req).then(res => {
      if(res.ok && (url.origin === self.location.origin || /fonts\.(googleapis|gstatic)\.com/.test(url.hostname))){
        const copy = res.clone();
        caches.open(VERSION).then(c => c.put(req, copy));
      }
      return res;
    }))
  );
});
