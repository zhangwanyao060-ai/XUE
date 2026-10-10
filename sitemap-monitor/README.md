# Sitemap Intelligence MVP

Cloudflare-first dashboard for competitor sitemap monitoring and page keyword intelligence.

## Current implementation

- React + Vite dashboard served through Cloudflare Workers Static Assets.
- Worker API for websites, pages, events, and manual scan dispatch.
- D1 schema for categories, websites, pages, snapshots, keyword analyses, scan runs, sitemap sources, and events.
- Daily Cron Trigger configured for 02:00 UTC (10:00 China Standard Time).
- Cloudflare Queues for asynchronous site scans and retries.
- Workers AI inference for new page primary keywords, related keywords, search intent, page type, topic cluster, and rationale.
- Dashboard includes demo data when no deployed API is available.

## Deploy to Cloudflare

Prerequisites: Node.js 20+ and a Cloudflare account with Workers, D1, Queues, and Workers AI enabled.

1. Enter this directory and install packages:
   ```bash
   cd sitemap-monitor
   npm install
   ```
2. Create the D1 database:
   ```bash
   npx wrangler d1 create sitemap-monitor-db
   ```
   Copy the returned database ID into `wrangler.jsonc` replacing `REPLACE_WITH_YOUR_D1_DATABASE_ID`.
3. Create the queue:
   ```bash
   npx wrangler queues create sitemap-scan
   ```
4. Apply the schema to the remote database:
   ```bash
   npx wrangler d1 execute sitemap-monitor-db --remote --file=./migrations/0001_init.sql
   ```
5. Build and deploy:
   ```bash
   npm run build
   npx wrangler deploy
   ```
6. Verify the deployment by opening `/api/health`, adding a test site, and clicking **立即扫描**. Check the Worker logs and D1 records before relying on the daily schedule.

## Local preview

```bash
npm install
npm run dev
```

The local UI uses sample data unless it can reach a deployed Worker API.

## Important production notes

- A code scaffold is not a live deployment. A real D1 ID, Queue, deployment, and end-to-end verification are still required.
- Cloudflare Cron expressions use UTC; `0 2 * * *` means 10:00 China Standard Time.
- AI-inferred keywords are estimates based on page content, not verified Google rankings or search-volume metrics.
- The scanner does not mark pages missing if a sitemap scan returns no usable URLs.
- Only scan public pages you are authorized to monitor and respect site policies. Review rate limits and add authentication (Cloudflare Access) before exposing a private dashboard.
- The initial scanner is an MVP foundation; very large sitemaps should be load-tested and scanned in smaller chunks before production use.
