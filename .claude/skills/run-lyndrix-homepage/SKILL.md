---
name: run-lyndrix-homepage
description: Run, start, build, preview, dev, serve, or screenshot the lyndrix-homepage Astro static marketing site. Use to launch the homepage locally, produce the production build in dist/, serve it, and drive it headlessly to capture a rendered screenshot for verifying a UI change.
---

# Run lyndrix-homepage

`lyndrix-homepage` is the **Astro static marketing site** for Lyndrix (hero +
`/` and `/plugins` pages, built to `dist/`). There is no backend — you build it,
serve it with `astro preview`, and screenshot the rendered page to verify it.

> Paths below are relative to the unit root (`lyndrix-homepage/`). Run everything
> from there. **All `node`/`npm`/`astro` calls go through the loader shim** (see
> Gotchas) — the system `/usr/bin/node` is v18 and too old for Astro 6.

## Prerequisites

The Node 22 toolchain and a headless Chromium are already present on this box; no
`apt`/`sudo` needed. Set the shim once per shell, then install deps:

```bash
export LD=/lib64/ld-linux-x86-64.so.2
export NODE=~/.nvm/versions/node/v22.22.3/bin/node
export NPM=~/.nvm/versions/node/v22.22.3/lib/node_modules/npm/bin/npm-cli.js
node22() { "$LD" "$NODE" "$@"; }          # run any node script under the loader

node22 "$NPM" install                      # installs astro@^6 into node_modules/
```

## Build

```bash
chmod +x node_modules/@esbuild/*/bin/* node_modules/.bin/* 2>/dev/null   # restore +x (see Gotchas)
node22 node_modules/astro/bin/astro.mjs build                            # -> dist/ (2 pages)
```

Expect: `2 page(s) built` and `dist/index.html`, `dist/plugins/index.html`.

## Run (agent path) — serve + screenshot, then look at the PNG

Do the whole thing in **one shell block** — serve in the background, wait, shoot,
then kill the saved PID. (In this harness a background server outliving the call gets
reaped; keeping it inside one call sidesteps that.)

```bash
"$LD" "$NODE" node_modules/astro/bin/astro.mjs preview --port 4399 > /tmp/astro-preview.log 2>&1 &
SRV=$!; sleep 4
echo "status=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:4399/)"   # -> status=200
CHROME=$(ls ~/.cache/ms-playwright/chromium_headless_shell-*/chrome-headless-shell-linux64/chrome-headless-shell | head -1)
"$CHROME" --headless --disable-gpu --no-sandbox --hide-scrollbars \
  --window-size=1440,900 --screenshot=/tmp/lyndrix-homepage.png http://localhost:4399/
kill "$SRV"; file /tmp/lyndrix-homepage.png        # -> PNG image data, 1440 x 900
```

Then **Read `/tmp/lyndrix-homepage.png`** — you should see the dark hero
"Build Applications, Ship Plugins." with the top nav and a dashboard mockup.
Swap the URL for `http://localhost:4399/plugins/` to shoot the plugins page.

## Run (human path)

```bash
node22 node_modules/astro/bin/astro.mjs dev    # hot-reload dev server at http://localhost:4321/
```

## Gotchas

- **Node exec-bit trap (WSL):** the nvm `node` at `~/.nvm/versions/node/v22.22.3/bin/node`
  and the `node_modules/.bin/*` + `@esbuild/*/bin/*` shims often **lack the execute bit**
  (a Windows-mount artifact), so `npm`/`astro` die with `Permission denied` / `EACCES`.
  Fix without touching the global install: run node through the dynamic loader
  (`"$LD" "$NODE" <script>`, i.e. the `node22` helper) and `chmod +x` the regenerable
  `node_modules` binaries (shown in Build).
- **System node is v18.** `/usr/bin/node --version` → v18; Astro 6 needs `>=22.12`. Always
  use the nvm v22 binary via the shim, never bare `node`/`npm`/`npx`.
- **No `chromium-cli` on this box.** The off-the-shelf headless Chromium is Playwright's
  `chrome-headless-shell` in `~/.cache/ms-playwright/` — its `--screenshot=` flag is the
  whole driver (no Playwright script / driver file needed).
- **Never `pkill -f astro` to clean up.** The pattern matches *this script's own command
  line* (it contains `…/astro/bin/astro.mjs`), so pkill kills the running shell — you get a
  spurious exit 144 and nothing after it runs. Kill the saved `$SRV` PID instead.
- **A backgrounded server won't survive past the call.** Don't launch the preview in one
  tool call and screenshot in the next — start, shoot, and kill it all in the one block above.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Permission denied` / `EACCES` running astro or esbuild | Re-run the `chmod +x node_modules/...` line, then call via `node22` (the loader). |
| `Astro requires Node >=22` (or a syntax error) | You used bare `node`/`npx` (v18). Use `node22` / the nvm v22 binary. |
| `chrome-headless-shell: No such file` from the glob | Headless shell not cached; install it: `node22 "$NPM" exec playwright install chromium-headless-shell`. |
| Spurious `exit 144`, lines after a cleanup step don't run | A `pkill -f astro` matched the script itself — see Gotchas; kill `$SRV` by PID. |
| `status=000` / blank screenshot | Server not up yet — raise the `sleep`, then re-check; tail `/tmp/astro-preview.log`. |
