---
name: run-lyndrix-homepage
description: Run, start, build, preview, dev, serve, or screenshot the lyndrix-homepage Astro static marketing site. Use to launch the homepage locally, produce the production build in dist/, serve it, and drive it headlessly to capture a rendered screenshot for verifying a UI change.
---

# Run lyndrix-homepage

`lyndrix-homepage` is the **Astro static marketing site** for Lyndrix (a `/`
hero + a `/plugins` page, built to `dist/`). No backend — you build it, serve it
with `astro preview`, and screenshot the rendered page to verify it. The
"driver" is the off-the-shelf headless Chromium `--screenshot=` flag; there is
no separate driver script.

> Paths below are relative to the unit root (`lyndrix-homepage/`). Run everything
> from there.

## Prerequisites

Node 22 and a headless Chromium are already present — no `apt`/`sudo`. First
confirm `node` resolves to v22 (it does by default here); if it prints v18, see
the "old node" gotcha before continuing.

```bash
node --version      # -> v22.22.3  (Astro 6 needs >=22.12; a bare v18 will fail)
npm install         # installs astro@^6 into node_modules/
```

## Build

```bash
npm run build       # -> dist/  (expect "2 page(s) built": index.html + plugins/index.html)
```

## Run (agent path) — serve + screenshot, then look at the PNG

Do it all in **one shell block** — serve in the background, wait, shoot, then
kill the saved PID (a server backgrounded in one tool call is reaped before the
next call, so keep it inside a single block).

```bash
npm run preview -- --port 4399 > /tmp/astro-preview.log 2>&1 &
SRV=$!; sleep 5
echo "status=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:4399/)"   # -> status=200
CHROME=$(ls ~/.cache/ms-playwright/chromium_headless_shell-*/chrome-headless-shell-linux64/chrome-headless-shell | head -1)
"$CHROME" --headless --disable-gpu --no-sandbox --hide-scrollbars \
  --window-size=1440,2200 --screenshot=/tmp/lyndrix-homepage.png http://localhost:4399/
kill "$SRV"; file /tmp/lyndrix-homepage.png        # -> PNG image data, 1440 x 2200
```

Then **Read `/tmp/lyndrix-homepage.png`** — you should see the top nav (Home ·
Features · Plugins · Ecosystem · Docs · GitHub · Get Started) and the dark hero
**"Build Applications, Ship Plugins."** with a browser-framed dashboard mockup on
the right. Swap the URL for `http://localhost:4399/plugins/` to shoot the plugins
page.

## Run (human path)

```bash
npm run dev     # hot-reload dev server at http://localhost:4321/
```

## Gotchas

- **The hero sits far below the top — screenshot at ~2200px tall, not 900.** The
  page has a large empty spacer above the hero, so a `--window-size=1440,900`
  shot shows only nav + blank. Use `--window-size=1440,2200` (above) to actually
  capture "Build Applications, Ship Plugins." and the dashboard mockup. For the
  full page bottom-to-top, raise it further.
- **The hero mockup is a real screenshot asset** (`src/assets/lyndrix_screenshots/
  react_dashboard.png`, imported by `Hero.astro`). If the hero image renders
  blank/broken, an imported `*.png` under `src/assets/lyndrix_screenshots/` is
  missing — every import there must resolve at build time or `astro build` fails.
- **No `chromium-cli` on this box.** The off-the-shelf headless Chromium is
  Playwright's `chrome-headless-shell` in `~/.cache/ms-playwright/` — its
  `--screenshot=` flag is the whole driver (no Playwright script needed). `--no-sandbox`
  is required in this container.
- **Never `pkill -f astro` to clean up.** The pattern matches *this script's own
  command line* (it runs `…/astro/bin/astro.mjs`), so pkill kills the running
  shell — spurious exit 144, nothing after it runs. Kill the saved `$SRV` PID.
- **A backgrounded server won't survive past the call.** Don't launch preview in
  one tool call and screenshot in the next — start, shoot, and kill it in the one
  block above.
- **Old node fallback (WSL):** if `node --version` prints v18 (a fresh shell
  picked up `/usr/bin/node` first) or `node_modules/.bin/*` lack the execute bit
  (a Windows-mount artifact), run astro through the nvm v22 binary via the loader:
  `LD=/lib64/ld-linux-x86-64.so.2; NODE=~/.nvm/versions/node/v22.22.3/bin/node; "$LD" "$NODE" node_modules/astro/bin/astro.mjs build`
  and `chmod +x node_modules/.bin/* node_modules/@esbuild/*/bin/* 2>/dev/null`.
  On this box `node` already resolves to v22, so plain `npm` works — this is only
  the recovery path.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Astro requires Node >=22` / syntax error | `node --version` shows v18 — use the nvm v22 loader (old-node gotcha). |
| `Permission denied` / `EACCES` on astro/esbuild | `chmod +x node_modules/.bin/* node_modules/@esbuild/*/bin/*`, then retry. |
| `astro build` fails on an image import | A `*.png` imported under `src/assets/lyndrix_screenshots/` is missing — restore it. |
| `chrome-headless-shell: No such file` from the glob | Install it: `npx playwright install chromium-headless-shell`. |
| Spurious `exit 144`, lines after cleanup don't run | A `pkill -f astro` matched the script itself — kill `$SRV` by PID. |
| `status=000` / blank screenshot | Server not up yet — raise `sleep`, re-check; tail `/tmp/astro-preview.log`. Or the window was too short (see hero gotcha). |
