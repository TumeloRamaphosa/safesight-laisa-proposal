# OTHER TERMINAL — DIRECTIVE BRIEF
**Assigned by:** Tumelo Ramaphosa (Tumi) — Studex Group
**Target:** Second Claude instance / Terminal B
**DO NOT PROCEED UNTIL YOU HAVE READ THIS ENTIRE FILE**

---

## YOUR SOLE PURPOSE

You are the **Content + Website Builder**. You do NOT build the internal dashboard. You do NOT write invoices or proposals. You build the **public-facing clinic website** and produce **content assets** that the Primary Terminal will wire into the system.

---

## WHAT HAS ALREADY BEEN DONE (DO NOT DUPLICATE)

| File | Status | Owner |
|---|---|---|
| `public/laisa-unified.html` | **DONE** — Single-scroll unified dashboard | Primary Terminal |
| `docs/saas-proposal.md` | **DONE** — Pricing, scope, timeline | Primary Terminal |
| `docs/invoice-work-completed.md` | **DONE** — R25,000 billable hours | Primary Terminal |
| `docs/invoice-template.md` | **DONE** — Template | Primary Terminal |
| API endpoints (`api/tts.js`, `api/twilio-sms.js`, `api/composio-social.js`) | **DONE** — Live integrations | Primary Terminal |
| `vercel.json` | **DONE** — Security cleaned | Primary Terminal |
| `supabase-schema.sql` | **DONE** — 10-table schema | Primary Terminal |

**If you touch any of these, you are wasting time.**

---

## YOUR THREE TASKS

### TASK 1: Enhanced SafeSight Website (Highest Priority)
**File:** `public/safesight-website-enhanced.html` (NEW FILE)

Build a public-facing clinic website for patients, not agents.

**Required sections (single-scroll or multi-page, your call):**
1. **Hero** — Clinic name "SafeSight Aesthetic Clinic", tagline about vision/aesthetics, CTA "Book Consultation"
2. **Services** — LASIK, Cataract Surgery, Aesthetic Treatments, Consultations. Use placeholder descriptions.
3. **Doctors** — 4 doctor cards. Use the placeholder names from `laisa-unified.html` OR replace with real data if Tumi provides it in this session.
4. **Why Choose Us** — Technology, experience, patient care. Mock content.
5. **Patient Reviews** — 3 mock testimonials with names and star ratings.
6. **Location + Contact** — Google Maps embed (same generic Johannesburg location for now), phone placeholder, email placeholder.
7. **Footer** — "Powered by Studex Group", social links placeholder.

**Design rules:**
- Background: `#0A0A0A` (obsidian)
- Accent: `#C9A84C` (gold)
- Text: `#F5F0E8` (cream)
- Headings: `'Cormorant Garamond', serif`
- Body: `'Inter', sans-serif`
- All CSS inline. All JS inline. No external dependencies.
- Responsive (mobile + desktop).

### TASK 2: Doctor Profile Content
**File:** `docs/doctor-profiles.md` (NEW FILE)

Create structured content for 4 doctors. Use placeholders if Tumi hasn't provided real data yet. Format:

```markdown
## Dr. [Name]
- **Title:** [e.g. Medical Director]
- **Specialty:** [e.g. Ophthalmic Surgery]
- **Bio:** 2-3 sentences
- **Education:** University placeholder
- **Languages:** English, Afrikaans, etc.
- **Photo:** [placeholder note]
```

This file will be consumed by the Primary Terminal and injected into both the dashboard and the website.

### TASK 3: GoodX / GoodLink Integration Research
**File:** `docs/goodx-integration.md` (NEW FILE)

The client mentioned "GoodLink" integration. The URL Tumi initially shared (`https://www.goodx.healthcare/covid19-telem`) returned 404.

Your job:
1. Search for `goodx.healthcare` or `GoodX healthcare` or `GoodX telemedicine South Africa`
2. Find the correct product name, URL, and API/integration documentation
3. Summarize in 5 bullet points: what it is, what it does, how a clinic uses it, whether it has an API or webhook, and how we might integrate it into LAISA
4. If you find pricing, note it

**If you find nothing conclusive after 10 minutes, write that in the file and move on.** Do not stall.

---

## WHAT YOU MUST NOT DO

- ❌ Do NOT edit `laisa-unified.html`
- ❌ Do NOT edit any file in `docs/` except the two new files above
- ❌ Do NOT edit any file in `api/`
- ❌ Do NOT write a new proposal or invoice
- ❌ Do NOT change the design system colors/fonts
- ❌ Do NOT use emojis unless explicitly asked
- ❌ Do NOT create planning documents or decision logs — just build

---

## HOW TO HAND BACK TO PRIMARY TERMINAL

When you finish a task:
1. `git add -A`
2. `git commit -m "[terminal-b] TASK: description — e.g. website sections built, doctor profiles drafted"`
3. `git push origin main`
4. Append a summary to this file at the bottom (add a new dated section)
5. The Primary Terminal will pull and integrate your outputs

---

## CONTEXT YOU NEED TO KNOW

- **Client:** SafeSight Aesthetic Clinic — eye surgery + aesthetics, South Africa
- **Their current state:** Zero digital infrastructure. No Google Ads, no Maps listing, no Facebook, no Instagram, no website, no AI.
- **Studex pitch:** Become their full SaaS digital partner — website, ads, social, ops dashboard, WhatsApp bot.
- **Pricing already set:** R25,000 setup + R4,500/R7,500/R12,000 monthly. Do not change.
- **Stack:** Vercel (frontend), Supabase (backend), Composio (social), Twilio (SMS), ElevenLabs (voice).
- **Brand:** Obsidian-gold, editorial luxury, cinematic. No pink. No playful. Premium medical.

---

## END OF BRIEF

If this file conflicts with something Tumi tells you verbally in your session, **Tumi's direct instruction wins over this brief.** Otherwise, follow this exactly.

**Last updated:** 2026-05-25 07:45 SAST
**By:** Primary Terminal
