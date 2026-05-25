# LAISA Agent OS — Agent-to-Supabase Sync Architecture

## Design Goal

Every agent in the LAISA Agent OS must write its state, actions, and outcomes to Supabase in near real-time. The dashboard reads from Supabase and receives live updates via Supabase Realtime. This document defines the sync contract, write patterns, and the orchestrator implementation.

---

## Sync Philosophy

- **Agents write, dashboard reads.** No agent directly queries the dashboard.
- **Service Role Key** for agent writes. **Anon Key + RLS** for dashboard reads.
- **Realtime channels** bridge the gap — dashboard subscribes to `INSERT`/`UPDATE` on key tables.
- **Idempotency** — every write should be safe to retry.
- **Graceful degradation** — if Supabase is unreachable, agents buffer in memory and retry with exponential backoff.

---

## Agent-to-Table Mapping

| Agent | Writes To | Reads From | Realtime Channel |
|-------|-----------|------------|------------------|
| **DenchClaw** | `appointments`, `clients`, `agent_activities` | `clients` (search), `appointments` (schedule) | `appointments` |
| **CashClaw** | `transactions`, `agent_activities` | `transactions` (reconcile), `clients` (billing) | `transactions` |
| **Naledi** | `social_platforms`, `content_queue`, `agent_activities` | `social_platforms` (metrics), `content_queue` (pipeline) | `social_platforms`, `content_queue` |
| **Charlie** | `agent_activities`, `appointments` (status updates) | `appointments` (reminders), `clients` (phone) | `appointments` |
| **Robusca** | `appointments` (notes, status), `agent_activities` | `appointments` (daily schedule), `clients` | `appointments` |
| **General** | `system_health`, `agent_activities`, `agents` (heartbeat) | `system_health`, `agents` | `system_health`, `agents` |

---

## Sync Patterns

### Pattern A: Heartbeat (General → agents, system_health)

Every 30 seconds, General writes:

```javascript
// General heartbeat
await supabase
  .from('agents')
  .update({
    status: 'Active',
    current_task: 'Monitoring all systems',
    last_heartbeat: new Date().toISOString()
  })
  .eq('agent_key', 'general')

// System health check
await supabase
  .from('system_health')
  .upsert({
    service_name: 'ORGO VM-02',
    status: 'Healthy',
    uptime_pct: 99.98,
    latency_ms: 24,
    memory_usage_pct: 62,
    last_check: new Date().toISOString()
  }, { onConflict: 'service_name' })
```

### Pattern B: Activity Log (All agents → agent_activities)

Every significant action produces an `agent_activities` row:

```javascript
const logActivity = async (agentKey, type, message, metadata = {}) => {
  const agentId = AGENT_ID_MAP[agentKey] // 'a1a1a1a1-...'
  await supabase
    .from('agent_activities')
    .insert({
      agent_id: agentId,
      activity_type: type,      // 'booking' | 'billing' | 'content' | 'call' | 'sync' | 'health' | 'system' | 'alert' | 'insight'
      message: message,
      metadata: metadata        // JSONB — structured context
    })
}

// Example usages:
await logActivity('denchclaw', 'booking', 'Confirmed booking for Sarah Jenkins (Thread Lift)', {
  client_id: '88888888-8888-8888-8888-888888888888',
  appointment_id: '...',
  channel: 'whatsapp'
})

await logActivity('cashclaw', 'billing', 'Generated payment link for invoice #INV-2026-8901', {
  invoice: 'INV-2026-8901',
  amount: 24500,
  payment_link: 'https://pay.laisa.co/tx/a1b2c3'
})

await logActivity('naledi', 'content', 'Instagram carousel published: "3 Tips for Post-Op Care"', {
  platform: 'Instagram',
  content_type: 'carousel',
  reach: 1240,
  engagements: 89
})
```

### Pattern C: State Machine (DenchClaw → appointments)

When DenchClaw confirms a booking via WhatsApp:

```javascript
// 1. Insert appointment
const { data: appt } = await supabase
  .from('appointments')
  .insert({
    client_id: clientId,
    treatment_id: treatmentId,
    appointment_date: date,
    appointment_time: time,
    status: 'Booked',
    booked_by: 'DenchClaw'
  })
  .select()
  .single()

// 2. Log the activity
await logActivity('denchclaw', 'booking',
  `Confirmed booking for ${clientName} — ${treatmentName} on ${date} ${time}`,
  { client_id: clientId, appointment_id: appt.id, channel: 'whatsapp' }
)

// 3. Dashboard receives realtime INSERT on appointments table
```

### Pattern D: Revenue Capture (CashClaw → transactions)

When a payment is processed:

```javascript
const { data: tx } = await supabase
  .from('transactions')
  .insert({
    client_id: clientId,
    treatment_id: treatmentId,
    appointment_id: appointmentId, // optional
    amount: amount,
    payment_status: 'Paid',
    payment_method: method,      // 'Card' | 'EFT' | 'Medical Aid' | 'Payment Link'
    invoice_number: generateInvoiceNumber(),
    description: description,
    paid_at: new Date().toISOString()
  })
  .select()
  .single()

// Trigger auto-updates client.lifetime_value via DB trigger

await logActivity('cashclaw', 'billing',
  `Payment processed: ${invoiceNumber} — R${amount} via ${method}`,
  { transaction_id: tx.id, client_id: clientId }
)
```

### Pattern E: Social Sync (Naledi → social_platforms)

Naledi pulls metrics from Meta/IG APIs and writes:

```javascript
await supabase
  .from('social_platforms')
  .upsert({
    platform: 'Instagram',
    account_handle: '@laisa.skin',
    is_connected: true,
    followers: newFollowerCount,
    engagement_rate: newEngagementRate,
    posts_today: postsToday,
    impressions_24h: impressions24h,
    last_sync_at: new Date().toISOString()
  }, { onConflict: 'platform' })

await logActivity('naledi', 'content',
  `Instagram sync complete — ${newFollowerCount} followers, ${impressions24h} impressions`,
  { platform: 'Instagram', followers: newFollowerCount, impressions: impressions24h }
)
```

### Pattern F: Content Pipeline (Naledi → content_queue)

Higgsfield AI generates a video, Naledi updates the queue:

```javascript
// Video generation started
await supabase
  .from('content_queue')
  .insert({
    title: 'Skin Longevity Series — Episode 2',
    content_type: 'video',
    status: 'Rendering',
    duration_seconds: 15,
    resolution: 'HD',
    created_by_agent: 'naledi',
    platform_target: ['Instagram', 'Facebook'],
    metadata: { theme: 'education', source: 'higgsfield' }
  })

// When rendering completes
await supabase
  .from('content_queue')
  .update({ status: 'Ready', completed_at: new Date().toISOString() })
  .eq('id', contentId)

await logActivity('naledi', 'content',
  `Higgsfield render complete: "${title}" — Ready for review`,
  { content_id: contentId, duration: 15 }
)
```

---

## Orchestrator Implementation (Node.js)

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Agent Sync Orchestrator                     │
│                     (Node.js / n8n / Edge Function)          │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  Scheduler   │  │  Retry Queue │  │  Batch Inserter  │   │
│  │  (cron)      │  │  (bullmq)    │  │  (100ms buffer)  │   │
│  └──────────────┘  └──────────────┘  └──────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  Supabase Client (Service Role)                         │ │
│  │  • Connection pooling (PgBouncer)                      │ │
│  │  • Exponential backoff on failure                      │ │
│  │  • Circuit breaker for outages                         │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Core Sync Client

```typescript
// src/lib/supabase-sync.ts
import { createClient, SupabaseClient } from '@supabase/supabase-js'

const SERVICE_URL = process.env.SUPABASE_URL!
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY!

class SupabaseSyncClient {
  private client: SupabaseClient
  private buffer: Map<string, any[]> = new Map()
  private flushInterval: NodeJS.Timeout | null = null
  private isHealthy = true
  private failureCount = 0

  constructor() {
    this.client = createClient(SERVICE_URL, SERVICE_KEY, {
      auth: { autoRefreshToken: false, persistSession: false }
    })
    this.startFlushLoop()
  }

  // ── Immediate Write (for critical data) ──
  async write(table: string, record: any) {
    if (!this.isHealthy) {
      this.bufferWrite(table, record)
      return { buffered: true }
    }

    const { data, error } = await this.client
      .from(table)
      .insert(record)
      .select()
      .single()

    if (error) {
      this.handleFailure()
      this.bufferWrite(table, record)
      throw error
    }

    this.failureCount = 0
    return data
  }

  // ── Upsert (for metrics, health, social) ──
  async upsert(table: string, record: any, conflictColumn: string) {
    const { data, error } = await this.client
      .from(table)
      .upsert(record, { onConflict: conflictColumn })
      .select()
      .single()

    if (error) {
      this.handleFailure()
      throw error
    }
    return data
  }

  // ── Buffered Batch Writes (for high-frequency logs) ──
  bufferWrite(table: string, record: any) {
    if (!this.buffer.has(table)) this.buffer.set(table, [])
    this.buffer.get(table)!.push({
      ...record,
      _buffered_at: Date.now()
    })
  }

  private startFlushLoop() {
    this.flushInterval = setInterval(() => this.flush(), 100)
  }

  private async flush() {
    if (this.buffer.size === 0 || !this.isHealthy) return

    for (const [table, records] of this.buffer) {
      if (records.length === 0) continue

      const batch = records.splice(0, 100) // Process max 100 at a time
      const { error } = await this.client.from(table).insert(batch)

      if (error) {
        // Re-queue failed records
        records.unshift(...batch)
        this.handleFailure()
      }
    }
  }

  // ── Circuit Breaker ──
  private handleFailure() {
    this.failureCount++
    if (this.failureCount >= 5) {
      this.isHealthy = false
      console.error('[SupabaseSync] Circuit breaker OPEN — buffering writes')
      setTimeout(() => this.probeHealth(), 30000) // Retry in 30s
    }
  }

  private async probeHealth() {
    const { error } = await this.client.from('system_health').select('id').limit(1)
    if (!error) {
      this.isHealthy = true
      this.failureCount = 0
      console.log('[SupabaseSync] Circuit breaker CLOSED — resuming direct writes')
      this.flush() // Flush buffered
    } else {
      setTimeout(() => this.probeHealth(), 30000)
    }
  }

  dispose() {
    if (this.flushInterval) clearInterval(this.flushInterval)
  }
}

export const sync = new SupabaseSyncClient()
```

### Agent Activity Logger

```typescript
// src/lib/agent-logger.ts
import { sync } from './supabase-sync'

const AGENT_IDS: Record<string, string> = {
  denchclaw: 'a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1',
  cashclaw:  'a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2',
  naledi:    'a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3',
  charlie:   'a4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4',
  robusca:   'a5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5',
  general:   'a6a6a6a6-a6a6-a6a6-a6a6-a6a6a6a6a6a6'
}

export async function agentLog(
  agentKey: string,
  activityType: string,
  message: string,
  metadata: Record<string, any> = {}
) {
  const agentId = AGENT_IDS[agentKey]
  if (!agentId) throw new Error(`Unknown agent: ${agentKey}`)

  // Use buffered write for logs (high frequency, low criticality)
  sync.bufferWrite('agent_activities', {
    agent_id: agentId,
    activity_type: activityType,
    message: message,
    metadata: metadata
  })
}

// Convenience wrappers for each agent
export const denchclaw = {
  log: (msg: string, meta?: any) => agentLog('denchclaw', 'booking', msg, meta),
  confirmBooking: (clientName: string, treatment: string, date: string, meta: any) =>
    agentLog('denchclaw', 'booking', `Confirmed booking for ${clientName} — ${treatment} on ${date}`, meta)
}

export const cashclaw = {
  log: (msg: string, meta?: any) => agentLog('cashclaw', 'billing', msg, meta),
  paymentProcessed: (invoice: string, amount: number, method: string, meta: any) =>
    agentLog('cashclaw', 'billing', `Payment processed: ${invoice} — R${amount} via ${method}`, meta)
}

export const naledi = {
  log: (msg: string, meta?: any) => agentLog('naledi', 'content', msg, meta),
  contentPublished: (platform: string, title: string, reach: number, meta: any) =>
    agentLog('naledi', 'content', `${platform} post published: "${title}" — ${reach} reach`, meta),
  contentReady: (title: string, duration: number, meta: any) =>
    agentLog('naledi', 'content', `Higgsfield render complete: "${title}" — Ready for review`, meta)
}

export const charlie = {
  log: (msg: string, meta?: any) => agentLog('charlie', 'call', msg, meta),
  callCompleted: (clientName: string, outcome: string, durationSec: number, meta: any) =>
    agentLog('charlie', 'call', `Call completed — ${clientName}: ${outcome} (${durationSec}s)`, meta)
}

export const robusca = {
  log: (msg: string, meta?: any) => agentLog('robusca', 'sync', msg, meta),
  scheduleSynced: (appointmentsCount: number, vipSlots: number, meta: any) =>
    agentLog('robusca', 'sync', `Daily schedule synced — ${appointmentsCount} appointments, ${vipSlots} VIP slots`, meta)
}

export const general = {
  log: (msg: string, meta?: any) => agentLog('general', 'system', msg, meta),
  healthCheck: (vm: string, cpu: number, memory: number, meta: any) =>
    agentLog('general', 'health', `${vm} health check passed — CPU ${cpu}%, Memory ${memory}%`, meta),
  alert: (agent: string, severity: string, msg: string, meta: any) =>
    agentLog('general', 'alert', `[${severity.toUpperCase()}] ${agent}: ${msg}`, meta)
}
```

---

## Realtime Wiring (Dashboard Side)

### React/Vue Hook for Full Dashboard

```typescript
// hooks/useDashboardRealtime.ts
import { useEffect, useRef } from 'react'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

export function useDashboardRealtime(callbacks: {
  onActivity?: (a: any) => void
  onAgentUpdate?: (a: any) => void
  onTransaction?: (t: any) => void
  onAppointment?: (a: any) => void
  onHealth?: (h: any) => void
  onSocial?: (s: any) => void
}) {
  const channelsRef = useRef<any[]>([])

  useEffect(() => {
    const channels = [
      // Mission log — new activities
      supabase.channel('activities')
        .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'agent_activities' },
          (p) => callbacks.onActivity?.(p.new))
        .subscribe(),

      // Agent status — status, task, heartbeat
      supabase.channel('agents')
        .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'agents' },
          (p) => callbacks.onAgentUpdate?.(p.new))
        .subscribe(),

      // Revenue — new payments
      supabase.channel('transactions')
        .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'transactions' },
          (p) => callbacks.onTransaction?.(p.new))
        .subscribe(),

      // Appointments — new bookings, status changes
      supabase.channel('appointments')
        .on('postgres_changes', { event: '*', schema: 'public', table: 'appointments' },
          (p) => callbacks.onAppointment?.(p.new))
        .subscribe(),

      // System health
      supabase.channel('health')
        .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'system_health' },
          (p) => callbacks.onHealth?.(p.new))
        .subscribe(),

      // Social metrics
      supabase.channel('social')
        .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'social_platforms' },
          (p) => callbacks.onSocial?.(p.new))
        .subscribe()
    ]

    channelsRef.current = channels

    return () => {
      channels.forEach(ch => supabase.removeChannel(ch))
    }
  }, [])
}
```

### Plain JavaScript (for current HTML dashboards)

```javascript
// Add to laisa-agent-os.html to replace static orchestrator

class LiveDashboard {
  constructor() {
    this.supabase = supabase.createClient(
      'https://<your-project>.supabase.co',
      'eyJ...anon-key...'
    )
    this.initRealtime()
    this.loadInitialData()
  }

  async loadInitialData() {
    // KPIs
    const { data: kpis } = await this.supabase.from('v_dashboard_kpis').select('*').single()
    this.renderKPIs(kpis)

    // Agents
    const { data: agents } = await this.supabase.from('v_agent_status_board').select('*')
    this.renderAgents(agents)

    // Activities
    const { data: activities } = await this.supabase
      .from('agent_activities')
      .select('*, agents(name)')
      .order('created_at', { ascending: false })
      .limit(20)
    this.renderFeed(activities)

    // Transactions
    const { data: txs } = await this.supabase
      .from('transactions')
      .select('*, clients(full_name)')
      .order('created_at', { ascending: false })
      .limit(5)
    this.renderTransactions(txs)

    // Social
    const { data: social } = await this.supabase.from('social_platforms').select('*')
    this.renderSocial(social)
  }

  initRealtime() {
    this.supabase.channel('laisa-live')
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'agent_activities' },
        (p) => this.prependFeed(p.new))
      .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'agents' },
        (p) => this.updateAgent(p.new))
      .on('postgres_changes', { event: 'INSERT', schema: 'public', table: 'transactions' },
        (p) => this.updateRevenue(p.new))
      .on('postgres_changes', { event: 'UPDATE', schema: 'public', table: 'social_platforms' },
        (p) => this.updateSocial(p.new))
      .subscribe()
  }

  // ... render methods
}
```

---

## Deployment Options

### Option 1: n8n Webhook Workflow (Current Stack)

Use your existing n8n setup:

1. Create an **n8n HTTP Request** node that receives agent payloads
2. Node writes to Supabase via the **Supabase node**
3. Use n8n's **Error Trigger** for retry logic

```javascript
// n8n Function node: "Agent Sync Handler"
const payload = $input.first().json.body

const tableMap = {
  booking: { table: 'appointments', agent: 'denchclaw' },
  payment: { table: 'transactions', agent: 'cashclaw' },
  content: { table: 'content_queue', agent: 'naledi' },
  health:  { table: 'system_health', agent: 'general' }
}

const config = tableMap[payload.type]
if (!config) return [{ json: { error: 'Unknown type' } }]

// Write to main table
await $supabase.from(config.table).insert(payload.record)

// Log activity
await $supabase.from('agent_activities').insert({
  agent_id: AGENT_IDS[config.agent],
  activity_type: payload.type,
  message: payload.message,
  metadata: payload.metadata
})

return [{ json: { success: true } }]
```

### Option 2: Supabase Edge Functions (Recommended for Scale)

Deploy as Deno edge functions inside Supabase:

```bash
supabase functions deploy agent-sync
```

```typescript
// supabase/functions/agent-sync/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  const { type, record, message, metadata, agent_key } = await req.json()

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Validate API key
  const apiKey = req.headers.get('x-agent-api-key')
  if (apiKey !== Deno.env.get('AGENT_API_KEY')) {
    return new Response('Unauthorized', { status: 401 })
  }

  // Route to correct table
  const tableMap: Record<string, string> = {
    booking: 'appointments',
    payment: 'transactions',
    content: 'content_queue',
    social: 'social_platforms',
    health: 'system_health',
    mail: 'agentmail_deliveries'
  }

  const table = tableMap[type]
  if (!table) return new Response('Unknown type', { status: 400 })

  // Insert record
  const { error } = await supabase.from(table).insert(record)
  if (error) return new Response(JSON.stringify(error), { status: 500 })

  // Log activity
  const agentId = AGENT_IDS[agent_key]
  if (agentId) {
    await supabase.from('agent_activities').insert({
      agent_id: agentId,
      activity_type: type,
      message,
      metadata
    })
  }

  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
```

### Option 3: Local FastAPI Microservice (Current Pattern)

Aligns with your existing microservice approach:

```python
# microservices/supabase-sync/main.py
from fastapi import FastAPI, Header, HTTPException
from supabase import create_client, Client
import os

app = FastAPI()
supabase: Client = create_client(
    os.getenv("SUPABASE_URL"),
    os.getenv("SUPABASE_SERVICE_ROLE_KEY")
)

AGENT_IDS = {
    "denchclaw": "a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1",
    "cashclaw":  "a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2",
    "naledi":    "a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3",
    "charlie":   "a4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4",
    "robusca":   "a5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5",
    "general":   "a6a6a6a6-a6a6-a6a6-a6a6-a6a6a6a6a6a6"
}

TABLE_MAP = {
    "booking": "appointments",
    "payment": "transactions",
    "content": "content_queue",
    "social": "social_platforms",
    "health": "system_health",
    "mail": "agentmail_deliveries"
}

@app.post("/sync/{sync_type}")
async def sync_data(
    sync_type: str,
    payload: dict,
    x_agent_key: str = Header(None),
    x_api_key: str = Header(None)
):
    if x_api_key != os.getenv("AGENT_API_KEY"):
        raise HTTPException(401, "Invalid API key")

    table = TABLE_MAP.get(sync_type)
    if not table:
        raise HTTPException(400, f"Unknown sync type: {sync_type}")

    # Insert main record
    supabase.table(table).insert(payload["record"]).execute()

    # Log activity
    agent_id = AGENT_IDS.get(x_agent_key)
    if agent_id and payload.get("message"):
        supabase.table("agent_activities").insert({
            "agent_id": agent_id,
            "activity_type": sync_type,
            "message": payload["message"],
            "metadata": payload.get("metadata", {})
        }).execute()

    return {"status": "ok"}
```

---

## Error Handling & Resilience

| Scenario | Strategy |
|----------|----------|
| Supabase timeout | Buffer in memory, retry with 2^x backoff (max 30s) |
| Auth failure | Alert General agent, switch to local log file |
| Invalid schema | Reject write, log to `agent_activities` as `alert` |
| Rate limit (429) | Reduce flush interval, batch more aggressively |
| Circuit breaker open | Queue writes to Redis/File, replay when healthy |
| Realtime disconnect | Dashboard falls back to 30s polling |

---

## Monitoring the Sync Itself

Add a meta-health check:

```sql
-- Track sync lag per agent
SELECT
  a.name,
  a.last_heartbeat,
  EXTRACT(EPOCH FROM (now() - a.last_heartbeat))/60 AS heartbeat_age_minutes,
  (SELECT COUNT(*) FROM agent_activities WHERE agent_id = a.id AND created_at > now() - interval '1 hour') AS actions_1h
FROM agents a
WHERE a.is_enabled = true;
```

If `heartbeat_age_minutes > 5`, General raises an `alert` activity.

---

## Migration Path (from Static HTML)

1. **Phase 1**: Deploy schema + seed to Supabase. Keep static HTML. Add a small polling script that fetches KPIs every 30s.
2. **Phase 2**: Add Supabase Realtime subscriptions to HTML dashboard. Static data becomes live.
3. **Phase 3**: Build Next.js app with `@supabase/ssr`. Migrate HTML components to React.
4. **Phase 4**: Agents write directly to Supabase via the sync client. Remove static orchestrator simulation.

---

## Files Reference

| File | Purpose |
|------|---------|
| `supabase-schema.sql` | Production schema |
| `supabase-seed.sql` | Demo data |
| `supabase-queries.md` | All dashboard queries |
| `agent-sync-orchestrator.md` | This sync architecture document |
| `SUPABASE-SETUP.md` | Step-by-step setup guide |
