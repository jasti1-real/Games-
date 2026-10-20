# Games — Neon Arcade

A responsive, dark neon-themed browser arcade with small games built into the page.

## Included
- Neon Snake (keyboard and touch buttons)
- Tic-Tac-Toe against a basic computer opponent
- Memory Match
- Neon Click timed challenge
- Local best scores using localStorage
- Service worker cache for offline loading
- Install prompt support where browsers allow it

## Run locally
Open `index.html` in a browser to play the games. Service-worker offline caching and installability require serving the project from HTTPS or localhost; they do not work from a direct `file://` URL.

## Deploy
Publish the repository as a static site (for example, GitHub Pages or Cloudflare Pages). Ensure `index.html`, `sw.js`, and `manifest.json` are deployed at the same path. Open the site once while online so the service worker can cache the app, then revisit it offline.

## Notes
This initial version is a client-side arcade. It does not include accounts, online multiplayer, or shared leaderboards. Local scores remain on the device/browser where they were earned.