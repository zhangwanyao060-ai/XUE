# Sitemap Intelligence MVP

Cloudflare-only starter for monitoring competitor sitemaps and inferring page keywords.

## Stack
- React + Vite dashboard (static assets served by Workers)
- Cloudflare Worker API
- D1 for websites, URLs, snapshots, events and scan runs
- Cron Trigger for daily discovery
- Cloudflare Queues for isolated scan jobs
- Workers AI binding is optional; external AI provider can be configured with a Worker secret

## Local preview
```bash
npm install
npm run dev
```
The UI currently uses sample data until API integration is configured.

## Cloudflare setup
1. Install Wrangler: `npm i -D wrangler`
2. Create D1: `npx wrangler d1 create sitemap-monitor-db`
3. Put the returned database ID into `wrangler.jsonc`.
4. Create queue: `npx wrangler queues create sitemap-scan`
5. Apply schema: `npx wrangler d1 execute sitemap-monitor-db --remote --file=./migrations/0001_init.sql`
6. Add secrets as needed: `npx wrangler secret put CRON_SECRET`; configure AI credentials only if using an external model.
7. Build and deploy: `npm run build && npx wrangler deploy`

## Important
- A cron expression is configured for 02:00 UTC daily.
- The worker contains a real sitemap-discovery/parser foundation and API scaffolding, but production activation still requires Cloudflare resource creation, a real D1 ID, secrets, and end-to-end verification.
- Do not expose service secrets to the browser.
- Missing URLs are only marked as candidates after a complete sitemap scan.
