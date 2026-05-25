# GoodX / GoodLink Integration Research

**Date:** 2026-05-25
**Researcher:** Terminal B (Claude)
**Client:** SafeSight Aesthetic Clinic
**Context:** Telemedicine integration for LAISA OS dashboard and public website

---

## Executive Summary

**Finding:** The original GoodLink URL (`https://www.goodx.healthcare/covid19-telem`) shared by the client is **dead (404)**. GoodX does not offer a public developer API, embeddable telemedicine widget, or standalone GoodLink product for external integration.

**What GoodX Actually Has:** An "Online Bookings" module with built-in "Telemedicine support: Enable video call appointments for remote consultations." This is a native GoodX feature — not a separate product called GoodLink — and it runs entirely inside the GoodX practice management system.

**Implication:** There is no "correct GoodX integration URL" to embed into the SafeSight website or dashboard. Integration must happen at the **workflow level** (n8n bridging GoodX calendar events to a video platform), not the **embed level**.

---

## 1. GoodX Telemedicine Reality Check

### What GoodX Offers (Confirmed)
| Feature | Status | Notes |
|---------|--------|-------|
| Online Bookings | ✅ Native | Patients schedule via GoodX portal |
| Telemedicine support | ✅ Native | "Enable video call appointments for remote consultations" |
| VoIP (GoodX Connect) | ✅ Separate | Voice calls only — not video |
| Public API / Developer docs | ❌ None | No REST API, GraphQL, or SDK found |
| Embeddable booking widget | ❌ None | No iframe or JS snippet available |
| GoodLink standalone product | ❌ Dead | COVID-era URL 404s; product discontinued |
| Patient import links | ✅ Native | `myGC` links for demographics capture |

### GoodX Connect vs. Telemedicine
- **GoodX Connect** (`goodx.co.za/goodxconnect/`) = VoIP phone system built into GoodX. Voice only. No video. No API.
- **Telemedicine support** = A toggle inside the Online Bookings module that marks certain appointment types as "video call." The actual video call is likely powered by a generic integration (Zoom, Jitsi, or Google Meet) configured per practice.

---

## 2. The Dead GoodLink URL

**Original URL:** `https://www.goodx.healthcare/covid19-telem`
**Status:** HTTP 404 Not Found

**Assessment:** GoodLink was likely a COVID-19 emergency telemedicine offering (2020–2022) that GoodX launched during the pandemic. The domain `goodx.healthcare` and the `/covid19-telem` path strongly suggest a temporary product that has since been sunset. GoodX has consolidated telemedicine back into their core Online Bookings module.

---

## 3. Integration Options for SafeSight

Since there is no public GoodX API or embeddable telemedicine component, here are the **practical integration paths** ranked by feasibility:

### Option A: n8n Bridge (Recommended)
**How it works:**
1. SafeSight configures GoodX Online Bookings to tag telemedicine appointments with a custom type or note.
2. n8n polls GoodX (via email parsing, calendar sync, or a GoodX webhook if available to enterprise clients) for new telemedicine bookings.
3. n8n auto-generates a video call link (Zoom, Google Meet, or Jitsi) and sends it to the patient via WhatsApp/email.
4. The LAISA dashboard displays upcoming telemedicine appointments with their generated links.

**Pros:** Fully automated, patient gets link automatically, works with existing stack.
**Cons:** Requires GoodX to emit some trigger (email, calendar event, or webhook). May need GoodX enterprise tier.

### Option B: Manual Link Injection
**How it works:**
1. Receptionist books telemedicine appointment in GoodX as normal.
2. Receptionist manually pastes a pre-generated video room URL into the GoodX appointment notes.
3. The LAISA WhatsApp agent pulls the appointment notes and sends the link to the patient.

**Pros:** Zero custom dev on GoodX side. Works immediately.
**Cons:** Manual step per appointment. Not scalable.

### Option C: Embed a Third-Party Telemedicine Platform
**How it works:**
Replace the concept of "GoodLink integration" with a direct integration to a South Africa-friendly telemedicine platform:

| Platform | Best For | Integration |
|----------|----------|-------------|
| **Zoom for Healthcare** | HIPAA/POPIA compliance, waiting rooms | Zoom API + n8n |
| **Google Meet** | Free, simple, no account needed for patients | Google Calendar API + n8n |
| **Jitsi Meet** | Self-hosted, zero cost, open source | Self-hosted on Hetzner |
| **Microsoft Teams** | Enterprise, already in Office 365 orgs | Teams Graph API |
| **Whereby** | Browser-based, no app download | REST API, easy embed |

**Recommendation for SafeSight:** Use **Jitsi Meet** (self-hosted on your Hetzner box) or **Zoom for Healthcare** for POPIA compliance. Both have APIs that n8n can hit natively.

### Option D: GoodX Patient Portal Only
**How it works:**
If SafeSight already has GoodX Online Bookings enabled, simply link patients to the GoodX patient portal URL (provided by GoodX support). Patients log in, book, and receive video links entirely within GoodX. The LAISA dashboard does not need to embed anything — it just tracks that the booking happened.

**Contact GoodX support for the portal URL:**
- **Sales:** sales@goodx.co.za
- **Help:** help@goodx.co.za
- **Phone:** +27 (0)12 845 9888

---

## 4. What to Tell the Client

1. **GoodLink is dead.** The URL they shared no longer exists. GoodX absorbed telemedicine into their Online Bookings module.
2. **GoodX has no public API.** There is no developer key, REST endpoint, or embeddable widget for the website.
3. **The practical path is n8n + Zoom/Jitsi.** Build a bridge that watches GoodX appointments and auto-provisions video rooms. This is what "integration" looks like in the absence of a native API.
4. **SafeSight should ask GoodX directly** for:
   - Their patient portal URL (for online bookings)
   - Whether their Online Bookings module can auto-generate video links
   - Whether they offer webhooks or email triggers for enterprise clients

---

## 5. Next Steps

| Step | Owner | Action |
|------|-------|--------|
| 1 | SafeSight / Client | Email GoodX (sales@goodx.co.za) to confirm Online Bookings + telemedicine module status and patient portal URL |
| 2 | Studex | Build n8n workflow that listens for new "Telemedicine" appointment type and generates a Jitsi/Zoom room |
| 3 | Studex | Add "Book Telemedicine Consultation" button to website that links to GoodX patient portal (once URL is known) or WhatsApp agent |
| 4 | Studex | Update LAISA dashboard telemedicine section from placeholder to live n8n-connected widget |

---

## 6. Sources

- GoodX Official Website: [https://goodx.co.za](https://goodx.co.za)
- GoodX Connect (VoIP): [https://goodx.co.za/goodxconnect/](https://goodx.co.za/goodxconnect/)
- GoodX Contact / Support: [https://goodx.co.za/contact/](https://goodx.co.za/contact/)
- GoodX Features (Online Bookings + Telemedicine mention): [https://goodx.co.za/features/](https://goodx.co.za/features/)
- Dead URL: `https://www.goodx.healthcare/covid19-telem` (HTTP 404, confirmed 2026-05-25)

---

*Prepared for SafeSight Aesthetic Clinic × LAISA by StudEx Group.*
