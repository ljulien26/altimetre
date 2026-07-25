# Altimètre

Instrument de terrain dans le navigateur : altitude du terrain, boussole, position GPS, météo et éphémérides. Application d'une seule page, sans build ni dépendance, installable sur téléphone.

## Utilisation

Ouvrir l'URL https du site, appuyer sur **Activer les capteurs**, puis autoriser la position (et la boussole sur iOS).

⚠️ La géolocalisation et la boussole ne fonctionnent qu'en **HTTPS** (ou sur `localhost`). Ouvrir le fichier en `file://` ou via une adresse `http://192.168…` ne donnera pas accès aux capteurs.

### Installer sur le téléphone

- **iPhone (Safari)** : bouton Partager → *Sur l'écran d'accueil*.
- **Android (Chrome)** : menu ⋮ → *Installer l'application* / *Ajouter à l'écran d'accueil*.

L'interface se charge ensuite hors-ligne ; les mesures live (altitude, météo) nécessitent le réseau.

## Contenu

| Fichier | Rôle |
| --- | --- |
| `index.html` | toute l'application : interface, styles et logique capteurs |
| `manifest.webmanifest` | métadonnées PWA (nom, icônes, mode plein écran) |
| `sw.js` | service worker : coquille en cache, données live toujours réseau |
| `icon-192.png`, `icon-512.png`, `apple-touch-icon.png` | icônes d'écran d'accueil |

## Sources de données

- **Altitude du terrain** : modèle numérique de terrain [Open-Meteo](https://open-meteo.com/) — plus stable que l'altitude GPS brute, qui reste affichée à part.
- **Météo et éphémérides** : Open-Meteo.
- **Boussole** : `DeviceOrientationEvent` du téléphone, avec repli sur le cap GPS en déplacement.
- **Azimuts du soleil** : calculés localement (déclinaison solaire + latitude, réfraction −0,833°).

Aucune donnée n'est envoyée à un serveur tiers en dehors de ces appels de mesure, et rien n'est stocké : la session repart à zéro à chaque ouverture.
