# lyndrix-homepage

The public marketing/info site for the **Lyndrix** application platform
(<https://lyndrix.eu>). It is a static [Astro](https://astro.build) site built to
plain HTML/CSS/JS and deployed to Cloudflare as static assets served by a thin
Worker (`worker.js` + `wrangler.jsonc`).

There is no backend, no client framework, and no runtime third-party CDN
dependency — fonts fall back to the locally-installed JetBrains Mono Nerd Font
and then `system-ui`.

## Project structure

```text
/
├── public/                 # static files copied verbatim (favicons, manifest)
├── src/
│   ├── assets/             # images, logos, screenshots (processed by Astro)
│   ├── components/         # page sections (Hero, Features, Screenshots, …)
│   ├── layouts/
│   │   └── Layout.astro    # shared <head>, global CSS variables/reset
│   └── pages/
│       ├── index.astro     # landing page
│       └── plugins.astro   # plugin overview page
├── worker.js               # Cloudflare Worker: forwards requests to ASSETS
├── wrangler.jsonc          # Cloudflare deploy config (serves ./dist)
└── astro.config.mjs
```

## Commands

All commands run from the repo root:

| Command           | Action                                       |
| :---------------- | :------------------------------------------- |
| `npm install`     | Install dependencies                         |
| `npm run dev`     | Start the dev server at `localhost:4321`     |
| `npm run build`   | Build the production site to `./dist/`       |
| `npm run preview` | Preview the production build locally         |

## Build caveat (WSL / Node 22)

On some WSL setups the bundled Node binary ships without the executable bit, so
`astro build` fails to spawn. The workaround (a Node loader shim) is documented in
`.claude/skills/run-lyndrix-homepage/SKILL.md` — use that skill to build/run the
site in this environment.

## Deployment

`npm run build` emits static assets to `./dist/`, which the Cloudflare Worker
(`worker.js`) serves via its `ASSETS` binding (`wrangler.jsonc`). Deploy with
`wrangler deploy`.
