# LAISA Agent OS — Supabase Setup Guide

## Overview

This guide walks you through creating a production-ready Supabase backend for the LAISA Agent OS dashboard and Aesthetic CRM. The schema supports:

- **Clients / Patients** (CRM)
- **Appointments / Bookings**
- **Treatments / Services**
- **Revenue / Transactions**
- **Agent Activities & Status** (Mission Log)
- **Social Media Metrics** (Naledi Content Engine)
- **System Health / Uptime** (Infrastructure)
- **Content Queue** (Higgsfield AI Pipeline)
- **AgentMail Delivery Log**

## Prerequisites

- A Supabase account (free tier works for development)
- Node.js 18+ (for the sync agent)
- `supabase` CLI installed globally: `npm install -g supabase`

## Step 1: Create the Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click **New Project**
3. Name it: `laisa-agent-os`
4. Set region: **Johannesburg (South Africa)** — closest to your SAST operations
5. Generate a strong database password. Save it in your password manager.
6. Wait for provisioning (~2 minutes).

## Step 2: Get Connection Details

From your project dashboard:

| Setting | Location | Value |
|---------|----------|-------|
| **Project URL** | Project Settings > API | `https://<project-ref>.supabase.co` |
| **Anon Key** | Project Settings > API | `eyJ...` (public client key) |
| **Service Role Key** | Project Settings > API | `eyJ...` (server-side only — treat as secret) |
| **Database Password** | Database Settings | The password you created |

Add these to your environment:

```bash
# .env.local (never commit this)
NEXT_PUBLIC_SUPABASE_URL=https://<project-ref>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...
```

## Step 3: Run the Schema

Open the **SQL Editor** in Supabase Dashboard (left sidebar) and run the contents of:

```
supabase-schema.sql
```

This creates:
- 10 core tables with proper types, constraints, and comments
- 5+ views for dashboard aggregations (KPIs, client 360, agent board)
- Auto-updating `updated_at` triggers
- Auto-recalculating client `lifetime_value` via transaction/appointment triggers
- Daily revenue snapshot table + refresh function
- Row Level Security (RLS) policies for authenticated users, admins, and service roles

## Step 4: Enable Realtime

The dashboard needs live updates. In Supabase Dashboard:

1. Go to **Database > Replication**
2. Under **Realtime**, toggle **ON** for these tables:
   - `agent_activities`
   - `system_health`
   - `social_platforms`
   - `transactions`
   - `appointments`
3. Alternatively, run this SQL in the editor:

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE agent_activities;
ALTER PUBLICATION supabase_realtime ADD TABLE system_health;
ALTER PUBLICATION supabase_realtime ADD TABLE social_platforms;
ALTER PUBLICATION supabase_realtime ADD TABLE transactions;
ALTER PUBLICATION supabase_realtime ADD TABLE appointments;
```

## Step 5: Seed Demo Data

Run the seed script in the SQL Editor:

```
supabase-seed.sql
```

This populates:
- 8 realistic South African client profiles
- 10 aesthetic treatments with pricing
- 12 upcoming appointments
- 15 revenue transactions (mix of paid, pending, medical aid)
- 6 AI agents (DenchClaw, CashClaw, Naledi, Charlie, Robusca, General)
- 20 activity log entries (the "Mission Stream")
- 5 social platforms (FB, IG, WA, TG connected; Ads pending)
- 3 content queue items (Higgsfield AI pipeline)
- 4 AgentMail deliveries
- 4 system health monitors

## Step 6: Create Auth Users (Optional)

If you want to test RLS with real auth:

1. Go to **Authentication > Users**
2. Click **Add User** and create a test user with email + password
3. Set the user's `role` claim to `admin` via SQL:

```sql
-- Set admin role on a user (replace with real UUID from Auth > Users)
UPDATE auth.users
SET raw_user_meta_data = raw_user_meta_data || '{"role": "admin"}'::jsonb
WHERE id = '<user-uuid>';
```

## Step 7: Verify the Setup

Run these verification queries in the SQL Editor:

```sql
-- 1. Dashboard KPIs
SELECT * FROM v_dashboard_kpis;

-- 2. Agent status board
SELECT * FROM v_agent_status_board;

-- 3. Client 360 (full profile + history)
SELECT * FROM v_client_360 WHERE id = '11111111-1111-1111-1111-111111111111';

-- 4. Revenue by category
SELECT * FROM v_revenue_by_category;

-- 5. Today's appointments
SELECT a.*, c.full_name, c.initials, t.name AS treatment_name
FROM appointments a
JOIN clients c ON c.id = a.client_id
JOIN treatments t ON t.id = a.treatment_id
WHERE a.appointment_date = CURRENT_DATE
ORDER BY a.appointment_time;

-- 6. Recent transactions
SELECT t.*, c.full_name, c.tag
FROM transactions t
JOIN clients c ON c.id = t.client_id
ORDER BY t.created_at DESC
LIMIT 10;

-- 7. Activity feed (mission log)
SELECT aa.*, a.name AS agent_name
FROM agent_activities aa
JOIN agents a ON a.id = aa.agent_id
ORDER BY aa.created_at DESC
LIMIT 20;
```

## Step 8: Connect the Dashboard

Replace the static demo data in `laisa-agent-os.html` and `laisa-crm.html` with live Supabase queries.

### Example: Fetch Dashboard KPIs

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

// Fetch live KPIs
async function loadKPIs() {
  const { data, error } = await supabase
    .from('v_dashboard_kpis')
    .select('*')
    .single()

  if (error) console.error(error)
  return data
}

// Subscribe to real-time agent activities
const channel = supabase
  .channel('agent-activities')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'agent_activities' },
    (payload) => {
      console.log('New agent activity:', payload.new)
      prependToFeed(payload.new)
    }
  )
  .subscribe()
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    LAISA Agent OS Dashboard                  │
│  (HTML / Next.js / React — reads from Supabase + Realtime)  │
└─────────────────────────┬───────────────────────────────────┘
                          │ REST / WebSocket
┌─────────────────────────▼───────────────────────────────────┐
│                      Supabase Platform                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐   │
│  │  Postgres   │  │   Realtime  │  │      Auth / RLS     │   │
│  │  (Tables)   │  │ (Broadcast) │  │  (Authenticated)    │   │
│  └─────────────┘  └─────────────┘  └─────────────────────┘   │
└─────────────────────────┬───────────────────────────────────┘
                          │ Service Role Key (secure)
┌─────────────────────────▼───────────────────────────────────┐
│                  Agent Orchestrator (Node.js)                  │
│  • DenchClaw  → writes bookings, WhatsApp logs               │
│  • CashClaw   → writes transactions, invoices                 │
│  • Naledi     → writes content queue, social metrics         │
│  • Charlie    → writes call logs, reminders                  │
│  • Robusca    → writes schedule syncs, notes                 │
│  • General    → writes health checks, alerts                 │
└─────────────────────────────────────────────────────────────┘
```

## Security Notes

- **Service Role Key** must never be exposed to the browser. Use it only in server-side code or edge functions.
- **Anon Key** is safe for client-side read-only operations (RLS protects writes).
- Admin role checks use `auth.jwt() ->> 'role' = 'admin'`. Set this claim via Supabase Auth metadata.
- All financial tables have `ON DELETE RESTRICT` to prevent accidental data loss.

## Next Steps

1. **Deploy edge functions** for webhook handlers (WhatsApp, Stripe, etc.)
2. **Set up the sync agent** (see `agent-sync-orchestrator.md` design below)
3. **Migrate from static HTML** to a Next.js app with `@supabase/ssr`
4. **Add storage bucket** for before/after photos and content assets
5. **Enable backups** (daily automated on Pro tier)

## Files in this Project

| File | Purpose |
|------|---------|
| `supabase-schema.sql` | Full production schema with tables, views, triggers, RLS |
| `supabase-seed.sql` | Realistic demo data for 8 clients, 6 agents, 20 activities |
| `SUPABASE-SETUP.md` | This guide |
| `supabase-queries.md` | Example queries for dashboard integration |
| `agent-sync-orchestrator.md` | Design spec for agent-to-Supabase sync |
