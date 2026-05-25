# Deploy Checklist — SafeSight Agent OS

**Repo:** https://github.com/TumeloRamaphosa/safesight-laisa-proposal
**Platform:** Vercel
**Last updated:** 2026-05-25

---

## Step 1: Environment Variables (CRITICAL)

In Vercel dashboard → Project Settings → Environment Variables, add:

| Variable | Status | Source |
|---|---|---|
| `ELEVENLABS_API_KEY` | NEEDS ROTATION + SET | ElevenLabs dashboard |
| `TWILIO_ACCOUNT_SID` | NEEDS ROTATION + SET | Twilio Console |
| `TWILIO_AUTH_TOKEN` | NEEDS ROTATION + SET | Twilio Console |
| `TWILIO_PHONE_NUMBER` | NEEDS SET | Twilio Console |
| `COMPOSIO_API_KEY` | NEEDS ROTATION + SET | Composio dashboard |

**Why:** These keys were exposed in `vercel.json`. The file has been cleaned, but the keys themselves may be compromised. Rotate them before deploying.

---

## Step 2: Deploy Command

```bash
# From repo root
vercel --prod
```

Or push to main branch with Git integration enabled.

---

## Step 3: Verify Live URLs

After deploy, check:

- [ ] Root domain → redirects to `/laisa-unified.html`
- [ ] `/laisa-unified.html` → dashboard loads, animations work
- [ ] `/api/tts` → returns audio when POSTed with `{ "text": "Hello" }`
- [ ] `/api/twilio-sms` → returns success when credentials are set
- [ ] `/api/composio-social` → returns social data when credentials are set
- [ ] `/laisa-crm.html` → CRM interface loads
- [ ] `/charlie.html` → standalone voice agent loads

---

## Step 4: Post-Deploy Fixes Needed

| Fix | Priority | Owner |
|---|---|---|
| Replace 4 doctor placeholders with real names/photos | HIGH | Tumi |
| Replace Johannesburg Maps embed with clinic address | HIGH | Tumi |
| GoodX integration research completion | MEDIUM | Terminal B |
| Google Ads account creation + campaign setup | MEDIUM | Tumi/Studex |
| Meta Business Manager setup (FB + IG) | MEDIUM | Tumi/Studex |
| WhatsApp Business API production approval | MEDIUM | Tumi/Studex |
| Supabase project creation + schema deploy | MEDIUM | Primary Terminal |

---

## Step 5: Demo Script for Client

1. Open dashboard homepage
2. Scroll through Hero → Agents → Activity → Business Intelligence → Social → Talking Agent → CRM → WhatsApp
3. Click "Book Consultation" CTA
4. Show live activity feed updating every 3-4 seconds
5. Show Charlie talking agent — type a greeting, hit Speak
6. Show social stats (will show demo numbers if Composio not connected)
7. Explain: "This is your command center. Every patient, every post, every ad, every booking — visible in one place."

---

## Files Ready to Deploy

- `public/laisa-unified.html` — unified dashboard (homepage target)
- `public/index.html` — redirect to dashboard
- `public/laisa-crm.html` — CRM interface
- `public/charlie.html` — standalone voice agent
- `public/api/tts.js` — ElevenLabs TTS endpoint
- `public/api/twilio-sms.js` — Twilio SMS endpoint
- `public/api/composio-social.js` — Composio social metrics endpoint
- `vercel.json` — routing + clean config (no keys)

---

**Deploy when env vars are set. Demo is ready.**
