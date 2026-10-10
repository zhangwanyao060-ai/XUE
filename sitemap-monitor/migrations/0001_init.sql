PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  color TEXT NOT NULL DEFAULT '#64748b',
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS websites (
  id TEXT PRIMARY KEY,
  domain TEXT NOT NULL UNIQUE,
  name TEXT,
  category_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','paused','error')),
  sitemap_url TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  last_scan_at TEXT
);

CREATE TABLE IF NOT EXISTS pages (
  id TEXT PRIMARY KEY,
  website_id TEXT NOT NULL REFERENCES websites(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  title TEXT,
  description TEXT,
  h1 TEXT,
  content_hash TEXT,
  primary_keyword TEXT,
  related_keywords TEXT NOT NULL DEFAULT '[]',
  search_intent TEXT,
  page_type TEXT,
  topic_cluster TEXT,
  ai_status TEXT NOT NULL DEFAULT 'pending',
  first_seen_at TEXT NOT NULL DEFAULT (datetime('now')),
  last_seen_at TEXT NOT NULL DEFAULT (datetime('now')),
  last_sitemap_seen_at TEXT,
  status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active','missing','removed')),
  UNIQUE(website_id, url)
);

CREATE TABLE IF NOT EXISTS page_snapshots (
  id TEXT PRIMARY KEY,
  page_id TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
  content_hash TEXT NOT NULL,
  title TEXT,
  description TEXT,
  h1 TEXT,
  content_excerpt TEXT,
  captured_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(page_id, content_hash)
);

CREATE TABLE IF NOT EXISTS keyword_analyses (
  id TEXT PRIMARY KEY,
  page_id TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
  primary_keyword TEXT,
  related_keywords TEXT NOT NULL DEFAULT '[]',
  search_intent TEXT,
  page_type TEXT,
  topic_cluster TEXT,
  rationale TEXT,
  confidence REAL,
  model TEXT,
  prompt_version TEXT,
  analyzed_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS scan_runs (
  id TEXT PRIMARY KEY,
  website_id TEXT NOT NULL REFERENCES websites(id) ON DELETE CASCADE,
  started_at TEXT NOT NULL DEFAULT (datetime('now')),
  finished_at TEXT,
  status TEXT NOT NULL DEFAULT 'running' CHECK(status IN ('running','success','partial','failed')),
  urls_found INTEGER NOT NULL DEFAULT 0,
  new_pages INTEGER NOT NULL DEFAULT 0,
  error TEXT
);

CREATE TABLE IF NOT EXISTS page_events (
  id TEXT PRIMARY KEY,
  page_id TEXT NOT NULL REFERENCES pages(id) ON DELETE CASCADE,
  scan_run_id TEXT REFERENCES scan_runs(id) ON DELETE SET NULL,
  event_type TEXT NOT NULL CHECK(event_type IN ('new_page','content_changed','missing_from_sitemap','returned_to_sitemap')),
  is_read INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  read_at TEXT
);

CREATE TABLE IF NOT EXISTS sitemaps (
  id TEXT PRIMARY KEY,
  website_id TEXT NOT NULL REFERENCES websites(id) ON DELETE CASCADE,
  sitemap_url TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'discovered',
  last_seen_at TEXT,
  UNIQUE(website_id, sitemap_url)
);

CREATE INDEX IF NOT EXISTS idx_pages_website_seen ON pages(website_id, first_seen_at DESC);
CREATE INDEX IF NOT EXISTS idx_events_unread ON page_events(is_read, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_scans_website_started ON scan_runs(website_id, started_at DESC);
CREATE INDEX IF NOT EXISTS idx_pages_keyword ON pages(primary_keyword);