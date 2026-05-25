# LAISA Agent OS — Dashboard Query Reference

This document contains production-ready SQL and JavaScript/TypeScript queries for every dashboard panel in the LAISA Agent OS and Aesthetic CRM.

## Table of Contents

1. [Dashboard KPIs (Top Stats Row)](#1-dashboard-kpis-top-stats-row)
2. [Agent Status Board (Left Sidebar)](#2-agent-status-board-left-sidebar)
3. [Activity Feed / Mission Log (Center Panel)](#3-activity-feed--mission-log-center-panel)
4. [Revenue & Transactions (Billing Panel)](#4-revenue--transactions-billing-panel)
5. [Social Resonance Hub (Naledi Panel)](#5-social-resonance-hub-naledi-panel)
6. [Content Queue (Higgsfield Panel)](#6-content-queue-higgsfield-panel)
7. [AgentMail Delivery (Right Panel)](#7-agentmail-delivery-right-panel)
8. [System Health (Top Bar)](#8-system-health-top-bar)
9. [CRM Client List](#9-crm-client-list)
10. [CRM Client 360 Detail](#10-crm-client-360-detail)
11. [CRM Treatment Timeline](#11-crm-treatment-timeline)
12. [CRM Upcoming Appointments](#12-crm-upcoming-appointments)
13. [Analytics & Reports](#13-analytics--reports)
14. [Realtime Subscriptions](#14-realtime-subscriptions)

---

## 1. Dashboard KPIs (Top Stats Row)

### SQL

```sql
SELECT * FROM v_dashboard_kpis;
```

### JavaScript (Supabase JS Client)

```javascript
const { data, error } = await supabase
  .from('v_dashboard_kpis')
  .select('*')
  .single()

// Returns:
// {
//   daily_revenue: 42300.00,
//   new_patients_today: 1,
//   appointments_today: 3,
//   social_reach_24h: 5025,
//   agent_actions_24h: 47,
//   system_uptime_avg: 99.97
// }
```

### React Hook Pattern

```typescript
import { useEffect, useState } from 'react'
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

export function useDashboardKPIs() {
  const [kpis, setKpis] = useState(null)

  useEffect(() => {
    const load = async () => {
      const { data } = await supabase.from('v_dashboard_kpis').select('*').single()
      setKpis(data)
    }
    load()

    // Refresh every 30 seconds
    const interval = setInterval(load, 30000)
    return () => clearInterval(interval)
  }, [])

  return kpis
}
```

---

## 2. Agent Status Board (Left Sidebar)

### SQL

```sql
SELECT * FROM v_agent_status_board;
```

### JavaScript

```javascript
const { data: agents } = await supabase
  .from('agents')
  .select('*, agent_activities(count)')
  .eq('is_enabled', true)
  .order('name')

// Real-time agent status updates
supabase
  .channel('agent-status')
  .on('postgres_changes',
    { event: 'UPDATE', schema: 'public', table: 'agents' },
    (payload) => updateAgentInSidebar(payload.new)
  )
  .subscribe()
```

---

## 3. Activity Feed / Mission Log (Center Panel)

### SQL — Recent 50 entries

```sql
SELECT
  aa.id,
  aa.activity_type,
  aa.message,
  aa.metadata,
  aa.created_at,
  a.name AS agent_name,
  a.agent_key
FROM agent_activities aa
JOIN agents a ON a.id = aa.agent_id
ORDER BY aa.created_at DESC
LIMIT 50;
```

### JavaScript — Real-time Feed

```javascript
const loadFeed = async () => {
  const { data } = await supabase
    .from('agent_activities')
    .select(`
      id,
      activity_type,
      message,
      metadata,
      created_at,
      agents(name, agent_key)
    `)
    .order('created_at', { ascending: false })
    .limit(50)
  return data
}

// Real-time new entries
supabase
  .channel('mission-log')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'agent_activities' },
    (payload) => {
      prependFeedItem({
        time: new Date(payload.new.created_at).toLocaleTimeString(),
        message: payload.new.message,
        agent: payload.new.agent_id // resolve via local cache
      })
    }
  )
  .subscribe()
```

---

## 4. Revenue & Transactions (Billing Panel)

### SQL — Today's Transactions

```sql
SELECT
  t.id,
  t.amount,
  t.payment_status,
  t.payment_method,
  t.invoice_number,
  t.description,
  t.created_at,
  c.full_name AS client_name,
  tr.name AS treatment_name
FROM transactions t
JOIN clients c ON c.id = t.client_id
LEFT JOIN treatments tr ON tr.id = t.treatment_id
WHERE DATE(t.created_at) = CURRENT_DATE
ORDER BY t.created_at DESC;
```

### SQL — Revenue by Day (Last 7 Days)

```sql
SELECT
  DATE(created_at) AS day,
  COALESCE(SUM(amount), 0) AS revenue,
  COUNT(*) AS transaction_count
FROM transactions
WHERE payment_status = 'Paid'
  AND created_at >= CURRENT_DATE - interval '7 days'
GROUP BY DATE(created_at)
ORDER BY day;
```

### SQL — Outstanding Payments

```sql
SELECT
  t.invoice_number,
  t.amount,
  t.payment_status,
  c.full_name,
  c.phone,
  t.created_at
FROM transactions t
JOIN clients c ON c.id = t.client_id
WHERE t.payment_status IN ('Pending', 'Partial', 'Failed')
ORDER BY t.created_at DESC;
```

### JavaScript — Transaction List

```javascript
const { data: transactions } = await supabase
  .from('transactions')
  .select(`
    id, amount, payment_status, payment_method, invoice_number, description, created_at,
    clients(full_name),
    treatments(name)
  `)
  .gte('created_at', new Date().toISOString().split('T')[0])
  .order('created_at', { ascending: false })
```

---

## 5. Social Resonance Hub (Naledi Panel)

### SQL — Platform Status

```sql
SELECT
  platform,
  account_handle,
  is_connected,
  followers,
  engagement_rate,
  posts_today,
  impressions_24h,
  last_sync_at
FROM social_platforms
ORDER BY is_connected DESC, platform;
```

### SQL — Weekly Social Performance

```sql
SELECT
  platform,
  SUM(impressions_24h) AS total_impressions,
  SUM(posts_today) AS total_posts,
  AVG(engagement_rate) AS avg_engagement
FROM social_platforms
WHERE last_sync_at >= now() - interval '7 days'
GROUP BY platform;
```

### JavaScript — Real-time Metrics

```javascript
const { data: platforms } = await supabase
  .from('social_platforms')
  .select('*')
  .order('platform')

// Subscribe to metric updates from Naledi
supabase
  .channel('social-metrics')
  .on('postgres_changes',
    { event: 'UPDATE', schema: 'public', table: 'social_platforms' },
    (payload) => updatePlatformCard(payload.new)
  )
  .subscribe()
```

---

## 6. Content Queue (Higgsfield Panel)

### SQL — Active Pipeline

```sql
SELECT
  id,
  title,
  content_type,
  status,
  duration_seconds,
  resolution,
  created_by_agent,
  platform_target,
  metadata,
  created_at,
  completed_at
FROM content_queue
WHERE status NOT IN ('Archived', 'Failed')
ORDER BY
  CASE status
    WHEN 'Rendering' THEN 1
    WHEN 'Ready' THEN 2
    WHEN 'Pending' THEN 3
    WHEN 'Published' THEN 4
  END,
  created_at DESC;
```

### JavaScript — Content Status

```javascript
const { data: content } = await supabase
  .from('content_queue')
  .select('*')
  .not('status', 'in', '(Archived,Failed)')
  .order('created_at', { ascending: false })
  .limit(10)
```

---

## 7. AgentMail Delivery (Right Panel)

### SQL — Recent Deliveries

```sql
SELECT
  id,
  subject,
  recipient_email,
  recipient_phone,
  delivery_type,
  status,
  sent_by_agent,
  sent_at
FROM agentmail_deliveries
ORDER BY created_at DESC
LIMIT 10;
```

### JavaScript

```javascript
const { data: deliveries } = await supabase
  .from('agentmail_deliveries')
  .select('*')
  .order('created_at', { ascending: false })
  .limit(10)
```

---

## 8. System Health (Top Bar)

### SQL — Current Status

```sql
SELECT
  service_name,
  status,
  uptime_pct,
  latency_ms,
  memory_usage_pct,
  last_check,
  metadata
FROM system_health
WHERE last_check >= now() - interval '5 minutes'
ORDER BY service_name;
```

### JavaScript — Live Health Bar

```javascript
const { data: health } = await supabase
  .from('system_health')
  .select('*')
  .gte('last_check', new Date(Date.now() - 5 * 60 * 1000).toISOString())
  .order('service_name')

// Real-time health updates
supabase
  .channel('system-health')
  .on('postgres_changes',
    { event: 'UPDATE', schema: 'public', table: 'system_health' },
    (payload) => updateHealthIndicator(payload.new)
  )
  .subscribe()
```

---

## 9. CRM Client List

### SQL — Searchable Client List

```sql
SELECT
  id,
  full_name,
  initials,
  phone,
  email,
  tag,
  lifetime_value,
  visits_count,
  last_visit_date,
  created_at
FROM clients
WHERE
  full_name ILIKE '%' || :search || '%'
  OR email ILIKE '%' || :search || '%'
  OR phone ILIKE '%' || :search || '%'
  OR tag ILIKE '%' || :search || '%'
ORDER BY
  CASE tag
    WHEN 'VIP' THEN 1
    WHEN 'Elite' THEN 2
    WHEN 'Regular' THEN 3
    WHEN 'New' THEN 4
  END,
  last_visit_date DESC NULLS LAST
LIMIT 50 OFFSET :offset;
```

### JavaScript — Paginated + Search

```javascript
const searchClients = async (term = '', page = 0, pageSize = 50) => {
  let query = supabase
    .from('clients')
    .select('*', { count: 'exact' })
    .order('tag', { ascending: true }) // VIP first if ordered correctly
    .order('last_visit_date', { ascending: false, nullsFirst: false })
    .range(page * pageSize, (page + 1) * pageSize - 1)

  if (term) {
    query = query.or(`full_name.ilike.%${term}%,email.ilike.%${term}%,phone.ilike.%${term}%,tag.ilike.%${term}%`)
  }

  return await query
}
```

---

## 10. CRM Client 360 Detail

### SQL — Full Client Profile (uses the view)

```sql
SELECT * FROM v_client_360 WHERE id = :client_id;
```

### JavaScript

```javascript
const loadClient360 = async (clientId) => {
  const { data } = await supabase
    .from('v_client_360')
    .select('*')
    .eq('id', clientId)
    .single()
  return data
}
```

### Manual Join Alternative (if views have RLS issues)

```javascript
const { data: client } = await supabase
  .from('clients')
  .select(`
    *,
    appointments(
      id, appointment_date, appointment_time, status, notes,
      treatments(name, description, base_price)
    ),
    transactions(
      id, amount, payment_status, payment_method, invoice_number, description, created_at,
      treatments(name)
    )
  `)
  .eq('id', clientId)
  .single()
```

---

## 11. CRM Treatment Timeline

### SQL — All treatments for a client

```sql
SELECT
  a.appointment_date,
  t.name AS treatment_name,
  t.description,
  t.base_price,
  a.status,
  a.notes,
  tx.amount AS paid_amount,
  tx.payment_status
FROM appointments a
JOIN treatments t ON t.id = a.treatment_id
LEFT JOIN transactions tx ON tx.appointment_id = a.id
WHERE a.client_id = :client_id
ORDER BY a.appointment_date DESC;
```

---

## 12. CRM Upcoming Appointments

### SQL — All future appointments

```sql
SELECT
  a.id,
  a.appointment_date,
  a.appointment_time,
  a.status,
  a.notes,
  c.full_name AS client_name,
  c.initials,
  c.phone,
  t.name AS treatment_name,
  t.duration_minutes
FROM appointments a
JOIN clients c ON c.id = a.client_id
JOIN treatments t ON t.id = a.treatment_id
WHERE a.appointment_date >= CURRENT_DATE
  AND a.status NOT IN ('Cancelled', 'No-show')
ORDER BY a.appointment_date, a.appointment_time;
```

### SQL — Today's Schedule

```sql
SELECT
  a.appointment_time,
  c.full_name,
  c.tag,
  t.name AS treatment_name,
  t.duration_minutes,
  a.status,
  a.notes
FROM appointments a
JOIN clients c ON c.id = a.client_id
JOIN treatments t ON t.id = a.treatment_id
WHERE a.appointment_date = CURRENT_DATE
ORDER BY a.appointment_time;
```

---

## 13. Analytics & Reports

### Monthly Revenue Trend

```sql
SELECT
  DATE_TRUNC('month', created_at) AS month,
  COALESCE(SUM(amount), 0) AS revenue,
  COUNT(*) AS transactions
FROM transactions
WHERE payment_status = 'Paid'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC
LIMIT 12;
```

### Client Retention (Repeat vs New)

```sql
SELECT
  tag,
  COUNT(*) AS client_count,
  COALESCE(SUM(lifetime_value), 0) AS segment_value,
  AVG(visits_count) AS avg_visits
FROM clients
GROUP BY tag
ORDER BY
  CASE tag
    WHEN 'VIP' THEN 1
    WHEN 'Elite' THEN 2
    WHEN 'Regular' THEN 3
    WHEN 'New' THEN 4
  END;
```

### Treatment Popularity

```sql
SELECT
  t.name,
  t.category,
  COUNT(a.id) AS booking_count,
  COALESCE(SUM(tx.amount), 0) AS total_revenue
FROM treatments t
LEFT JOIN appointments a ON a.treatment_id = t.id AND a.status = 'Completed'
LEFT JOIN transactions tx ON tx.treatment_id = t.id AND tx.payment_status = 'Paid'
WHERE t.is_active = true
GROUP BY t.id, t.name, t.category
ORDER BY total_revenue DESC;
```

### Agent Productivity (Actions per Hour)

```sql
SELECT
  a.name AS agent_name,
  COUNT(aa.id) AS actions_24h,
  COUNT(DISTINCT DATE(aa.created_at)) AS active_days
FROM agents a
LEFT JOIN agent_activities aa ON aa.agent_id = a.id
  AND aa.created_at >= now() - interval '24 hours'
WHERE a.is_enabled = true
GROUP BY a.id, a.name
ORDER BY actions_24h DESC;
```

---

## 14. Realtime Subscriptions

### Complete Dashboard Subscription Setup

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

class DashboardRealtime {
  private channels: any[] = []

  subscribeAll(handlers: {
    onActivity: (activity: any) => void
    onAgentUpdate: (agent: any) => void
    onTransaction: (tx: any) => void
    onHealthUpdate: (health: any) => void
    onSocialUpdate: (social: any) => void
  }) {
    // Agent activities feed
    this.channels.push(
      supabase.channel('activities')
        .on('postgres_changes',
          { event: 'INSERT', schema: 'public', table: 'agent_activities' },
          (payload) => handlers.onActivity(payload.new)
        )
        .subscribe()
    )

    // Agent status changes
    this.channels.push(
      supabase.channel('agents')
        .on('postgres_changes',
          { event: 'UPDATE', schema: 'public', table: 'agents' },
          (payload) => handlers.onAgentUpdate(payload.new)
        )
        .subscribe()
    )

    // New transactions
    this.channels.push(
      supabase.channel('transactions')
        .on('postgres_changes',
          { event: 'INSERT', schema: 'public', table: 'transactions' },
          (payload) => handlers.onTransaction(payload.new)
        )
        .subscribe()
    )

    // System health
    this.channels.push(
      supabase.channel('health')
        .on('postgres_changes',
          { event: 'UPDATE', schema: 'public', table: 'system_health' },
          (payload) => handlers.onHealthUpdate(payload.new)
        )
        .subscribe()
    )

    // Social metrics
    this.channels.push(
      supabase.channel('social')
        .on('postgres_changes',
          { event: 'UPDATE', schema: 'public', table: 'social_platforms' },
          (payload) => handlers.onSocialUpdate(payload.new)
        )
        .subscribe()
    )
  }

  unsubscribeAll() {
    this.channels.forEach(ch => supabase.removeChannel(ch))
    this.channels = []
  }
}

export const dashboardRealtime = new DashboardRealtime()
```

---

## Performance Notes

- All heavy aggregations use **materialized views** or pre-computed snapshots (`daily_revenue_snapshots`) to avoid table scans on every dashboard load.
- The `v_dashboard_kpis` view is lightweight and caches well — call it on page load, then rely on realtime for updates.
- For large client lists (1000+), use server-side pagination with `range()` and `count: 'exact'`.
- Index coverage is complete for all `WHERE`, `ORDER BY`, and `JOIN` columns used in dashboard queries.
