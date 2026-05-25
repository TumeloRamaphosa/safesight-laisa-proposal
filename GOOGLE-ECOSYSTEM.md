# GOOGLE-ECOSYSTEM.md — LAISA Aesthetic Clinic

**Researched:** 2026-05-19
**Domain:** Google Cloud + Google Maps + Google Ads + Firebase
**Confidence:** MEDIUM — based on training knowledge; external verification was not available during this session. All package names, version numbers, and pricing should be confirmed before execution.

---

## Executive Summary

This document maps how LAISA moves from static HTML demos to a live, Google-powered clinic operations platform. The goal: a single dashboard where LAISA sees website/social traffic, understands Google Ads performance, chats with patients on WhatsApp, and initiates calls — all demo-ready fast.

**Primary recommendation:** Use Firebase (Google Cloud's app platform) as the backbone — Firestore for real-time data, Cloud Functions for API glue, Firebase Hosting for the frontend, and Google Analytics 4 + Google Ads API feeding a unified metrics panel.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Clinic map / directions | Browser (Maps JS API) | — | Renders client-side; no backend needed |
| Website + social traffic | Browser (GA4 gtag) | Cloud Function (reporting) | GA4 collects client-side; aggregation pulled server-side |
| Google Ads campaign data | Cloud Function | Firestore | Ads API requires OAuth + server-side token refresh |
| Dashboard data sync | Firestore (real-time) | Cloud Function | Firestore listeners push live updates to dashboard |
| WhatsApp messaging | Cloud Function (webhook) | Firestore (chat log) | Meta WABA webhooks hit Cloud Functions; messages stored in Firestore |
| Voice calls | Browser (`tel:` / Twilio) | — | Click-to-call is client-side; Twilio bridges if needed |
| Patient CRM data | Firestore | Cloud Storage | Documents structured in Firestore; images/files in Storage |
| Auth (staff login) | Firebase Auth | — | Handles session, tokens, password resets |

---

## Standard Stack

### Core
| Service | Purpose | Why Standard | Cost Class |
|---------|---------|--------------|------------|
| **Firebase Hosting** | Serve dashboard + website | Zero-config CDN, custom domain, atomic deploys | Free tier generous [ASSUMED] |
| **Cloud Firestore** | Real-time database for appointments, patients, chat, metrics | Native real-time listeners; scales to zero; JSON-like documents | Pay per read/write; free tier covers demo [ASSUMED] |
| **Firebase Authentication** | Staff login to dashboard | Email/password + Google Sign-In out of the box | Free [ASSUMED] |
| **Cloud Functions (2nd gen)** | API glue: Google Ads fetch, WhatsApp webhook, analytics aggregation | Node.js runtime; HTTP + event triggers; pay per invocation | Free tier 2M invocations/month [ASSUMED] |
| **Google Maps JavaScript API** | Clinic location map + directions embed | Industry standard; customizable styling to match LAISA brand | Pay per map load; $200/mo free credit [ASSUMED] |
| **Google Analytics 4** | Track website + social traffic | Free; connects to Looker Studio + BigQuery export | Free [ASSUMED] |
| **Google Ads API** | Pull campaign impressions, clicks, cost, conversions into dashboard | Official Google source of truth; replaces scraping | Free to query; developer token required [ASSUMED] |
| **Cloud Storage** | Before/after photos, PDFs, voice notes | Firebase SDK integration; signed URLs for privacy | Pay per GB egress [ASSUMED] |

### Supporting
| Service | Purpose | When to Use |
|---------|---------|-------------|
| **BigQuery (sandbox)** | Store historical GA4 + Ads data for custom SQL reporting | When dashboard needs multi-month trend analysis beyond GA4 UI |
| **Looker Studio** | Build no-code visual reports from GA4 + Firestore | When clinic staff want drag-and-drop report building without engineering |
| **Firebase Cloud Messaging** | Push browser notifications for new appointments/messages | When dashboard should alert staff even when tab is backgrounded |
| **Cloud Run** | Containerized backend if clinic outgrows Cloud Functions | When you need custom runtime, long-running jobs, or concurrent websockets |
| **Secret Manager** | Store API keys (Ads, WhatsApp, Twilio) outside codebase | Required for any production deployment; prevents key leakage |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Firebase Hosting | Vercel (current) | Vercel is excellent for frontend; Firebase Hosting unifies auth + hosting under same GCP project |
| Cloud Firestore | Cloud SQL (PostgreSQL) | SQL is better for complex relational queries; Firestore wins for real-time dashboard sync |
| Google Ads API | Manual CSV export | Manual is slow and error-prone; API enables live dashboard metrics |
| Cloud Functions | Cloud Run | Cloud Run supports longer timeouts and websockets; Functions are simpler for HTTP webhooks |

---

## Package Legitimacy Audit

> No external npm packages are strictly required for the core Google integration (loaded via CDN/SDK). Optional packages below were identified via training knowledge and must be verified before install.

| Package | Registry | Source Repo | Disposition |
|---------|----------|-------------|-------------|
| `firebase` (npm) | npm | github.com/firebase/firebase-js-sdk | [ASSUMED] — verify on npmjs.com before install |
| `googleapis` (npm) | npm | github.com/googleapis/google-api-nodejs-client | [ASSUMED] — verify on npmjs.com before install |
| `@google-cloud/firestore` (npm) | npm | github.com/googleapis/nodejs-firestore | [ASSUMED] — verify on npmjs.com before install |
| `google-map-react` (npm) | npm | github.com/google-map-react/google-map-react | [ASSUMED] — optional wrapper; verify before install |

**All packages above are tagged `[ASSUMED]`** because external registry verification (npm view, slopcheck) was not available during this research session. The planner must run `npm view <pkg> version` and `slopcheck` before any install tasks.

---

## Architecture Patterns

### System Architecture Diagram

```
USER (Browser)
   |
   |---> LAISA Website (Firebase Hosting)
   |       |- Google Analytics 4 (gtag) -----> GA4 Backend
   |       |- Google Maps Embed (JS API) ----> Maps Platform
   |       |- "Book Now" --> Firestore (appointment write)
   |
   |---> LAISA Dashboard (Firebase Hosting)
   |       |- Firebase Auth (staff login)
   |       |- Firestore listeners (real-time patients, appointments, chat)
   |       |- Google Maps Directions (JS API)
   |       |- "Call Patient" (tel: link or Twilio client)
   |       |- "WhatsApp" (wa.me link or Twilio API)
   |
   |---> WhatsApp (Patient phone)
           ^
           |
META WhatsApp Business API
   |
   |---> Webhook --> Cloud Function (receive message)
   |       |- Write to Firestore (chat log)
   |       |- Trigger FCM notification to dashboard
   |
   |---> Cloud Function (send message)
           |- Read Firestore (outbound queue)
           |- POST to Meta Messages API

GOOGLE ADS API (scheduled job)
   |
   |---> Cloud Function (cron: every 15 min)
   |       |- OAuth2 refresh token
   |       |- Pull campaign metrics
   |       |- Write to Firestore (ads_metrics/{date})
   |
   v
Dashboard reads Firestore ads_metrics collection --> live charts
```

### Recommended Project Structure

```
laisa-gcp/
├── public/                    # Firebase Hosting static files
│   ├── index.html             # LAISA Website
│   ├── dashboard.html         # Operations Dashboard
│   ├── css/
│   └── js/
│       └── firebase-init.js   # Firebase SDK init + auth state
├── functions/                 # Cloud Functions (Node.js 20)
│   ├── src/
│   │   ├── ads-report.ts      # Google Ads API → Firestore
│   │   ├── whatsapp-webhook.ts # Meta WABA inbound handler
│   │   ├── whatsapp-send.ts   # Outbound message handler
│   │   └── analytics-agg.ts   # GA4 BigQuery → Firestore summary
│   └── package.json
├── firestore.rules            # Security rules (staff-only reads)
├── storage.rules              # Cloud Storage access rules
├── firebase.json              # Hosting + functions config
└── .env.local                 # NEVER COMMIT — API keys here
```

### Pattern 1: Real-Time Dashboard with Firestore Listeners
**What:** Dashboard subscribes to Firestore collections (`patients`, `appointments`, `chat`, `ads_metrics`) using `onSnapshot`. UI updates automatically when backend data changes.
**When to use:** All live panels (appointments, WhatsApp chat, revenue, ads metrics).
**Example:**
```javascript
// Source: Firebase documentation pattern [ASSUMED]
import { getFirestore, collection, onSnapshot } from "firebase/firestore";

const db = getFirestore();
onSnapshot(collection(db, "appointments"), (snapshot) => {
  const appts = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
  renderAppointments(appts); // Your UI update
});
```

### Pattern 2: Server-Side Google Ads Sync
**What:** A scheduled Cloud Function refreshes OAuth token, queries Google Ads API, normalizes metrics, writes to Firestore.
**When to use:** Campaign dashboards that need live spend/conversion data without exposing OAuth tokens client-side.
**Example:**
```javascript
// Source: Google Ads API Node.js client pattern [ASSUMED]
const { GoogleAdsApi } = require("google-ads-api"); // or googleapis

exports.syncAdsMetrics = onSchedule("every 15 minutes", async () => {
  const customer = client.Customer({ customer_id: CUSTOMER_ID });
  const rows = await customer.query(`
    SELECT campaign.name, metrics.impressions, metrics.clicks, metrics.cost_micros
    FROM campaign
    WHERE segments.date DURING LAST_7_DAYS
  `);
  // Write aggregated rows to Firestore
  await db.collection("ads_metrics").doc(today).set({ campaigns: rows });
});
```

### Anti-Patterns to Avoid
- **Exposing API keys in frontend code:** Google Ads API credentials, WhatsApp tokens, and Maps API keys must live in Cloud Functions or Secret Manager. A Maps key restricted to HTTP referrers is acceptable client-side.
- **Polling Firestore instead of listeners:** Do not `setInterval(fetch, 5000)`. Use `onSnapshot` — it is cheaper, faster, and simpler.
- **Storing images in Firestore documents:** Documents have a 1 MiB limit. Use Cloud Storage with download URLs stored in documents.
- **Using Cloud Functions for long-running websockets:** Functions have a timeout (9 min for 2nd gen). Use Cloud Run if you need persistent connections.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Real-time sync engine | WebSocket server + Redis pub/sub | Firestore `onSnapshot` | Scales to millions; handles reconnection, offline caching, auth |
| OAuth2 token refresh | Custom cron + token store | Google Auth library + Cloud Functions | Token rotation, scope handling, expiry logic are security-critical |
| Analytics dashboard from scratch | Custom event pipeline + charting library | GA4 + Looker Studio or GA4 + Firestore + Chart.js | GA4 already captures events; BigQuery export gives SQL access |
| Phone auth / password reset | Custom bcrypt + SMS gateway | Firebase Authentication | Handles MFA, password resets, account recovery, compliance |
| File upload / CDN | Custom multer + S3 | Firebase Storage + Hosting | Signed URLs, Firebase SDK integration, global CDN |
| Maps rendering | Custom Leaflet + tile server | Google Maps JS API | Street view, directions, Places autocomplete, accessibility |

---

## Quick Wins (Demo-Ready in Hours)

These deliver immediate visual impact for the demo without backend complexity.

| # | Quick Win | Time | What It Shows |
|---|-----------|------|---------------|
| Q1 | **Google Maps Embed on website + dashboard** | 30 min | Clinic location with gold-styled map, "Get Directions" button |
| Q2 | **GA4 gtag on all pages** | 15 min | Live user count, traffic sources, page views in GA4 dashboard |
| Q3 | **Click-to-WhatsApp (`wa.me`) links** | 15 min | "Chat on WhatsApp" buttons that open real WhatsApp with pre-filled message |
| Q4 | **Click-to-Call (`tel:`) links** | 10 min | "Call Patient" buttons on dashboard that dial numbers directly |
| Q5 | **Firestore "live mode" demo** | 1 hour | Wire one dashboard widget (e.g., appointments) to a Firestore collection; update data in Firebase console and see UI change live |
| Q6 | **Mock Google Ads widget** | 1 hour | Static JSON in Firestore → dashboard chart; proves the data pipeline works while real Ads API credentials are pending |

**Demo checklist:**
1. Open LAISA website → scroll to map section → click "Directions" → Google Maps opens with route.
2. Open GA4 Realtime report → see yourself as active user.
3. Open dashboard → see appointments update live when Firestore document changes.
4. Click WhatsApp icon → phone opens chat with "Hi LAISA, I'd like to book a consultation."
5. Click call button → phone dialer opens with patient number.

---

## Integration Roadmap

### Phase A: Foundation (Day 1 — Demo Block)
1. **Create Firebase project** (`laisa-clinic`) in Google Cloud console.
2. **Enable APIs:** Maps JavaScript API, Places API, Google Ads API, Analytics Admin API.
3. **Deploy static site to Firebase Hosting:** Move current HTML demos to `public/` and deploy.
4. **Add GA4 gtag** to every page (`index.html`, `dashboard.html`, etc.).
5. **Add Maps embed** to website and dashboard with custom obsidian-gold styling.
6. **Click-to-WhatsApp + Click-to-Call:** Add `wa.me` and `tel:` links across patient cards.

### Phase B: Live Data (Days 2–3)
1. **Firestore schema design:** `patients`, `appointments`, `chat_messages`, `ads_metrics`, `staff`.
2. **Firebase Auth:** Implement email/password login for demo staff accounts.
3. **Real-time dashboard wiring:** Connect dashboard widgets to Firestore collections using `onSnapshot`.
4. **Cloud Function: Ads sync mock:** Write a scheduled function that populates `ads_metrics` with realistic demo data.

### Phase C: Real Integrations (Days 4–7)
1. **Google Ads API:** Apply for developer token, set up OAuth2 consent screen, build real sync function.
2. **WhatsApp Business API:** Register business with Meta, configure webhook endpoint (Cloud Function), receive/send messages.
3. **Cloud Storage:** Upload before/after photos, generate signed URLs, store in patient documents.
4. **Security rules:** Lock Firestore so patients only see their own data; staff see clinic-wide data.

### Phase D: Polish (Week 2)
1. **Cloud Run migration:** If Cloud Functions hit timeout/memory limits, migrate heavy workloads to Cloud Run.
2. **Looker Studio:** Connect GA4 + Firestore to build no-code executive summary reports.
3. **Firebase Cloud Messaging:** Browser push notifications for urgent messages.
4. **Custom domain:** Configure `dashboard.laisa.co.za` on Firebase Hosting.

---

## Common Pitfalls

### Pitfall 1: Google Ads Developer Token Delay
**What goes wrong:** Google Ads API developer tokens require a "Token Review" that can take 2–5 business days. Demo stalls waiting for approval.
**How to avoid:** Apply for the token immediately. In parallel, build the dashboard with mock data in Firestore so the UI is ready.

### Pitfall 2: Maps API Key Theft
**What goes wrong:** Maps JavaScript API key committed to GitHub; scraped by bots; $10K bill overnight.
**Why it happens:** Unrestricted keys are valid on any domain.
**How to avoid:** Restrict the key to HTTP referrers (`*.laisa.co.za`, `localhost`) in Cloud Console. Never commit keys; use Firebase Hosting environment config or Secret Manager.

### Pitfall 3: Firestore Bill Shock
**What goes wrong:** Dashboard listener on a large collection causes millions of document reads.
**Why it happens:** `onSnapshot` on `patients` with 10K docs = 10K reads every time any doc changes.
**How to avoid:** Use queries with `where`, `limit`, and pagination. Aggregate counts in a separate `stats` document rather than counting all docs client-side.

### Pitfall 4: WhatsApp Webhook Verification Failure
**What goes wrong:** Meta WABA webhook subscription fails because Cloud Function does not respond correctly to the `hub.challenge` verification GET request.
**How to avoid:** Webhook handler must distinguish between Meta's verification GET (echo challenge) and message POST (process payload).

---

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | yes | Firebase Authentication (email/password + Google Sign-In) |
| V3 Session Management | yes | Firebase Auth handles JWT tokens, refresh, revocation |
| V4 Access Control | yes | Firestore Security Rules + Firebase Auth UID checks |
| V5 Input Validation | yes | Cloud Function validation for WhatsApp webhooks; Firestore rules for data shape |
| V6 Cryptography | yes | TLS 1.2+ everywhere (Firebase / GCP default); Secret Manager for API keys |
| V8 Data Protection | yes | Cloud Storage signed URLs expire; patient PHI/PII encrypted at rest by default on GCP |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| API key exposure in frontend | Information Disclosure | Restrict keys by referrer/IP; use Secret Manager for server-side keys |
| Unauthorized Firestore access | Elevation of Privilege | Security rules: `allow read, write: if request.auth != null && request.auth.token.role == 'staff'` |
| WhatsApp webhook spoofing | Spoofing | Verify Meta webhook signature (X-Hub-Signature-256) in Cloud Function |
| Google Ads OAuth token theft | Tampering | Store tokens in Secret Manager; rotate on suspicion |
| Patient data breach | Information Disclosure | GCP default encryption + Firestore rules + avoid logging PII |

---

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Node.js 18+ | Cloud Functions local dev | Must verify | — | Use `nvm` to install |
| Firebase CLI | Deploy hosting + functions | Must verify | — | `npm install -g firebase-tools` |
| Google Cloud SDK | Direct GCP resource management | Optional | — | Firebase CLI covers most needs |
| Google Ads account | Ads API data source | Must verify | — | Mock data in Firestore for demo |
| Meta Business account | WhatsApp Business API | Must verify | — | `wa.me` click-to-chat for demo |
| Domain (laisa.co.za) | Custom Firebase Hosting | Must verify | — | Default `.web.app` domain for demo |

---

## Assumptions Log

> Every claim in this document derived from training knowledge and not verified against live documentation during this session. The planner must confirm these before locking decisions.

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Firebase Hosting free tier covers static site traffic for a small clinic | Standard Stack | If exceeded, small pay-as-you-go cost |
| A2 | Cloud Firestore free tier includes 50K reads/day and 20K writes/day | Standard Stack | If exceeded, charges apply per 100K operations |
| A3 | Cloud Functions (2nd gen) free tier includes 2M invocations/month | Standard Stack | If exceeded, pay per invocation + compute time |
| A4 | Google Maps Platform provides $200/month free credit | Standard Stack | If map loads exceed credit, charges apply per load |
| A5 | Google Ads API developer token review takes 2–5 business days | Common Pitfalls | Could be longer; demo must use mock data |
| A6 | Firebase Auth email/password is free for unlimited users | Standard Stack | If pricing changed, may need upgrade |
| A7 | `google-ads-api` npm package (or `googleapis`) supports campaign metrics query | Standard Stack | If package deprecated, use REST directly |
| A8 | Meta WhatsApp Business API webhooks require HTTPS endpoint | Architecture Patterns | Cloud Functions provide HTTPS by default |
| A9 | Cloud Functions 2nd gen timeout is 9 minutes | Anti-Patterns | If changed, long jobs need Cloud Run |
| A10 | Firestore document size limit is 1 MiB | Anti-Patterns | Images must go to Cloud Storage |

---

## Sources

### Primary (HIGH confidence)
- None verified via Context7 or live official docs during this session.

### Secondary (MEDIUM confidence)
- Claims drawn from extensive training on Google Cloud, Firebase, and Google Ads API documentation as of early 2026.

### Tertiary (LOW confidence)
- Pricing tiers, free-tier limits, and exact API quotas may have shifted. **Must be verified** at:
  - https://firebase.google.com/pricing
  - https://cloud.google.com/pricing
  - https://developers.google.com/maps/documentation/javascript/usage-and-billing
  - https://developers.google.com/google-ads/api/docs/first-call/overview

---

## Actionable Next Steps

1. **Create the Firebase project now.** Go to https://console.firebase.google.com/ → create `laisa-clinic`.
2. **Register the Google Maps API key** with HTTP referrer restrictions.
3. **Apply for Google Ads API developer token** at https://developers.google.com/google-ads/api/docs/first-call/dev-token — do this today because it has a wait time.
4. **Set up Meta Business account** for WhatsApp Business API (or use `wa.me` links for immediate demo).
5. **Install Firebase CLI** locally: `npm install -g firebase-tools` then `firebase login`.
6. **Clone current HTML demos into a Firebase project scaffold** and deploy to Hosting — this gives a live URL for the demo in minutes.
7. **Add GA4 measurement ID** to all pages to start collecting traffic data immediately.

---

## Metadata

**Research date:** 2026-05-19
**Valid until:** 2026-06-19 (fast-moving platform; verify pricing monthly)
**Confidence breakdown:**
- Architecture patterns: MEDIUM — Firebase/Cloud Functions stack is well-established and recommended by Google for this exact use case.
- Pricing: LOW — free-tier numbers and credit amounts are training-data recall and must be verified before budget decisions.
- Security controls: MEDIUM — standard GCP defaults are sound, but rule syntax and auth token shape should be verified against current docs.
