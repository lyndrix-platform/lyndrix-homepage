# lyndrix-homepage

Static landing page for **lyndrix.eu**, deployed with a minimal Cloudflare Worker plus static assets via Wrangler.

## Files
- `public/index.html`: Main landing page content
- `public/styles.css`: Site styling
- `worker.js`: Minimal Worker entrypoint that serves the static assets
- `wrangler.jsonc`: Wrangler configuration for `npx wrangler deploy`

## Deploy
1. Authenticate with Cloudflare:
   ```bash
   npx wrangler login
   ```
2. Deploy the Worker and bundled static assets:
   ```bash
   npx wrangler deploy
   ```
