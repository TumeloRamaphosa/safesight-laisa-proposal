# CLAUDE CONTEXT HANDOFF — LAISA / SafeSight Project
**Last updated:** 2026-05-25 07:38 SAST
**Terminal:** Primary (Claude Code CLI)
**Status:** WORK IN PROGRESS — DO NOT DUPLICATE

---

## What This Terminal (Primary) Has Already Completed

### 1. Unified LAISA OS Dashboard — DONE
- **File:** `public/laisa-unified.html` (1,094 lines, 42KB)
- Single-scroll obsidian-gold design using Studex brand system
- Sections: Hero (4 doctors), Agent Command Center (6 agents), Activity Feed, Business Intelligence (Maps + Ads), Social Command, Talking Agent (Charlie TTS), CRM Snapshot, WhatsApp Bot, Footer
- Responsive. All CSS/JS inline. Standalone.
- **DO NOT rebuild this from scratch** — enhance it if needed.

### 2. SaaS Proposal — DONE
- **File:** `docs/saas-proposal.md`
- ZAR pricing: R25,000 setup + R4,500/R7,500/R12,000 monthly tiers
- 4-week timeline. Value proposition. Scope tables.

### 3. Invoice Template — DONE
- **File:** `docs/invoice-template.md`
- Professional template with Phase A/Phase B line items

### 4. Work-Completed Invoice — DONE
- **File:** `docs/invoice-work-completed.md`
- 46 hours billed (18 human @ R1,200 + 28 agent @ R450)
- R25,000 due now (50% of Phase A)
- Remaining R25,000 at go-live

### 5. Security Fix — DONE
- Removed exposed API keys from `vercel.json`
- **ACTION REQUIRED:** Keys must still be rotated in Twilio, ElevenLabs, Composio dashboards
- Keys must be set as Vercel environment variables before next deploy

### 6. JARVIS Integration Analysis — DONE
- Repo cloned and analyzed: `https://github.com/Ammaribrahimbinumar/AI-JARVIS-ASSISTANT-OFFLINE-MODE`
- Python desktop assistant (Ollama + pyttsx3 + pyautogui)
- **Not a web component.** Requires bridge: add `/command` POST endpoint to `server.py`, connect to LAISA orchestrator as local execution agent.

---

## What the OTHER Terminal Should Focus On

The other Claude instance appears to be working on:
1. Explore repos/sites for proposal
2. Calculate project value / draft payment proposal
3. Build enhanced SafeSight website
4. Build integrated LAISA OS dashboard

**COORDINATION RULES:**
- ✅ **DO:** Work on `public/safesight-website.html` (enhanced clinic website)
- ✅ **DO:** Research GoodX/GoodLink integration (URL https://www.goodx.healthcare/ — the covid19-telem link was 404)
- ✅ **DO:** Research doctor profile content if Tumi provides it
- ✅ **DO:** Work on Supabase deployment (`supabase-schema.sql`, `supabase-seed.sql`) if access is available
- ❌ **DO NOT:** Rebuild `laisa-unified.html` — it's done
- ❌ **DO NOT:** Rewrite `docs/saas-proposal.md` or `docs/invoice-work-completed.md` — they're done
- ❌ **DO NOT:** Re-do the JARVIS analysis — summary above is sufficient

**Suggested split:**
- **This terminal (Primary):** Dashboard logic, API endpoints, orchestrator, voice agent wiring
- **Other terminal:** Website content, SEO, Google Maps config, doctor profiles, GoodLink research

---

## Critical Blockers / Need User Input

1. **API Key Rotation:** Twilio, ElevenLabs, Composio keys were exposed. Must rotate before live deploy.
2. **Vercel Environment Variables:** Need to configure `ELEVENLABS_API_KEY`, `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_PHONE_NUMBER`, `COMPOSIO_API_KEY` in Vercel dashboard.
3. **Doctor Profiles:** Currently placeholder names in `laisa-unified.html`. Need real names, titles, bios, photos.
4. **Clinic Address:** Google Maps embed uses generic Johannesburg. Need real address.
5. **GoodLink Integration:** URL provided was dead. Need correct integration method or API docs.
6. **Git Push:** GitHub MCP write ops time out. Use terminal `git push` as fallback.

---

## Files Touched by This Terminal (Commit These)

- `public/laisa-unified.html` — NEW unified dashboard
- `docs/saas-proposal.md` — NEW proposal
- `docs/invoice-template.md` — NEW invoice template
- `docs/invoice-work-completed.md` — NEW completed-work invoice
- `vercel.json` — MODIFIED (keys removed)
- `public/vercel.json` — check if also needs cleaning

---

## Next Actions for Whoever Reads This

**If you are the OTHER terminal:**
1. Run `git pull` immediately to get this context
2. Read `docs/saas-proposal.md` to understand pricing
3. Read `public/laisa-unified.html` to understand dashboard structure
4. Pick ONE task from the "What the OTHER Terminal Should Focus On" list above
5. Append your own section to this file before you finish

**If you are TUMI:**
- Decide which terminal owns which workstream
- Approve or edit the invoice amounts
- Provide doctor profile content and clinic address
- Rotate API keys in vendor dashboards

---

*Do not delete this file. Append updates at the top so newest context is first.*
