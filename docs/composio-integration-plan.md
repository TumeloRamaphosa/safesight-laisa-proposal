# Composio Integration Plan — LAISA Social Resonance Hub

**Date:** 2026-05-19
**Scope:** Replace simulated social metrics in `laisa-agent-os.html` with real data from Instagram Business, Google Analytics, and WhatsApp Business via Composio.
**Status:** PROTOTYPE / READY FOR CONNECTION

---

## 1. What Composio Provides

Composio exposes 1000+ external apps as typed tools. The pattern is:

1. **Discover:** `composio search "instagram"` or `composio manage toolkits list`
2. **Connect:** `composio link instagram` (OAuth, one-time per account)
3. **Execute:** `composio.execute "INSTAGRAM_BUSINESS_GET_ACCOUNT_INSIGHTS" -d '{...}'`
4. **Listen:** `composio listen` for real-time triggers (new messages, new followers, etc.)

[CITED: composio-cli.md, building-with-composio.md]

---

## 2. Recommended Integration Architecture

| Tier | Responsibility | Tech |
|------|---------------|------|
| **Browser** | Dashboard UI, data binding, polling | Vanilla JS (current stack) |
| **Frontend Server (optional)** | CORS proxy / API route if needed | Vercel edge function |
| **API / Backend** | **Composio SDK calls** | Node.js + `@composio/core` |
| **External** | Instagram, Meta, Google, WhatsApp | Composio managed OAuth |

The dashboard is currently 100% static HTML. To get real data without a backend server, the simplest path is:

1. **Short term:** A Node.js script (`scripts/fetch-social-metrics.js`) runs via cron or manually, writes results to `public/social-metrics.json`, and the dashboard polls that JSON file.
2. **Long term:** A lightweight Vercel API route (`api/social-metrics.js`) that calls Composio on-demand with caching.

[CITED: building-with-composio.md — SDK usage]

---

## 3. Target Data Sources

### 3.1 Instagram Business (PRIMARY — most visual for demos)

**Prerequisites:**
- Instagram Business or Creator account
- Facebook Business account linked to the IG account
- Facebook App with `instagram_basic`, `instagram_content_publish`, `instagram_manage_insights` permissions

**What to fetch:**
| Metric | Dashboard Field | Composio Likely Tool |
|--------|---------------|----------------------|
| Follower count | `Social Reach` (top stat) | `INSTAGRAM_BUSINESS_GET_ACCOUNT` or `GET_ACCOUNT_INSIGHTS` [ASSUMED] |
| Profile views (7d) | Engagement sub-label | `INSTAGRAM_BUSINESS_GET_INSIGHTS` with `metric=profile_views` [ASSUMED] |
| Media published (recent) | Content queue | `INSTAGRAM_BUSINESS_GET_MEDIA` [ASSUMED] |
| Likes + comments (7d) | Engagement rate | `INSTAGRAM_BUSINESS_GET_MEDIA_INSIGHTS` [ASSUMED] |

**Connection command:**
```bash
composio link instagram
```

### 3.2 Google Analytics 4

**Prerequisites:**
- GA4 property for `laisa.co.za` (or desired domain)
- `ga4` toolkit connected via Composio OAuth

**What to fetch:**
| Metric | Dashboard Field | Composio Likely Tool |
|--------|---------------|----------------------|
| Sessions (7d) | Secondary analytics panel | `GOOGLE_ANALYTICS_GET_REPORT` [ASSUMED] |
| Page views | Content performance | `GOOGLE_ANALYTICS_GET_REPORT` [ASSUMED] |
| Top pages | Content queue meta | `GOOGLE_ANALYTICS_GET_REPORT` [ASSUMED] |

**Connection command:**
```bash
composio link google-analytics
```

### 3.3 WhatsApp Business (via Meta / Twilio)

**Prerequisites:**
- WhatsApp Business API account (Meta Business Partner or Twilio)
- Composio `whatsapp` or `twilio` toolkit

**What to fetch:**
| Metric | Dashboard Field | Composio Likely Tool |
|--------|---------------|----------------------|
| Messages sent/received (24h) | Agent log feed | `WHATSAPP_SEND_MESSAGE` / triggers [ASSUMED] |
| Conversation count | Comms panel | `WHATSAPP_GET_ANALYTICS` [ASSUMED] |

**Connection command:**
```bash
composio link whatsapp
# or
composio link twilio
```

---

## 4. Implementation Plan

### Phase A — Discovery & Auth (manual, one-time)
1. Install Composio CLI: `curl -fsSL https://composio.dev/install | bash`
2. Login: `composio login`
3. Search for exact tool slugs:
   ```bash
   composio search "instagram business insights"
   composio search "google analytics report"
   composio search "whatsapp business"
   ```
4. Connect accounts:
   ```bash
   composio link instagram
   composio link google-analytics
   composio link whatsapp
   ```

### Phase B — Prototype Script (delivered now)
`scripts/fetch-social-metrics.js` — runs Composio SDK calls and writes `public/social-metrics.json`.

### Phase C — Dashboard Wiring (delivered now)
Update `laisa-agent-os.html` to poll `social-metrics.json` instead of using `AgentOrchestrator.stats` for social numbers.

### Phase D — Automation (future)
- Cron job or GitHub Action that runs `node scripts/fetch-social-metrics.js` every 15 minutes
- Or migrate to a Vercel API route with ISR/revalidation

---

## 5. File Deliverables

| File | Purpose |
|------|---------|
| `docs/composio-integration-plan.md` | This document |
| `src/composio-social-bridge.js` | Browser module that polls JSON and emits events the dashboard already listens for |
| `scripts/fetch-social-metrics.js` | Node script that uses Composio SDK (simulated mode now, real mode after auth) |
| `scripts/composio-config.json` | Configuration mapping toolkits to accounts and metric targets |
| `public/social-metrics.json` | Initial simulated data file so the dashboard works immediately |

---

## 6. Assumptions & Risks

| # | Assumption | Risk if Wrong |
|---|------------|---------------|
| A1 | Composio has `instagram` toolkit with Business API tools [ASSUMED] | May need to use `facebook` toolkit (IG Business API is technically part of Facebook Graph API) |
| A2 | Tool slugs follow pattern `INSTAGRAM_BUSINESS_GET_*` [ASSUMED] | Actual slugs may differ; must verify via `composio search` |
| A3 | Google Analytics 4 is available as `google-analytics` toolkit [ASSUMED] | May be `ga4`, `google_analytics`, or nested under `google` |
| A4 | WhatsApp Business available directly [ASSUMED] | May need Twilio middleware toolkit |
| A5 | Static JSON polling is acceptable for demo | For production, needs API route + caching |

---

## 7. Next Steps

1. **Tumi runs Phase A** — install Composio CLI, login, search for exact tool slugs, connect IG/GA/WA accounts
2. **Update `scripts/composio-config.json`** with real `toolkit`, `tool`, and `version` strings from `composio manage tools info`
3. **Flip `MODE` from `"simulated"` to `"live"`** in `fetch-social-metrics.js`
4. **Run the script** to generate real `public/social-metrics.json`
5. **Open dashboard** — numbers will now reflect live data

---

## Sources

- [CITED] `~/.claude/skills/composio/rules/composio-cli.md` — CLI workflow: search, link, execute, listen
- [CITED] `~/.claude/skills/composio/rules/building-with-composio.md` — SDK setup, version pinning, direct execution
- [CITED] `~/.claude/skills/composio/rules/app-execute-tools.md` — execute params, error handling, response format
- [CITED] `~/.claude/skills/composio/rules/app-toolkits.md` — toolkit discovery, categories, auth requirements
- [ASSUMED] Instagram Business, Google Analytics 4, WhatsApp Business tool availability and slug naming conventions
