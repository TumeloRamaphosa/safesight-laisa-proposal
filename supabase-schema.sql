-- =============================================================================
-- LAISA Agent OS — Supabase Production Schema
-- Aesthetic Clinic Dashboard + Agent Orchestrator Backend
-- =============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- 1. CLIENTS / PATIENTS (CRM Core)
-- =============================================================================
CREATE TABLE clients (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name       TEXT NOT NULL,
    initials        TEXT GENERATED ALWAYS AS (
                        upper(regexp_replace(full_name, '([a-zA-Z])[a-zA-Z]* *', '\1', 'g'))
                    ) STORED,
    phone           TEXT,
    email           TEXT,
    date_of_birth   DATE,
    tag             TEXT NOT NULL DEFAULT 'New' CHECK (tag IN ('New','Regular','Elite','VIP')),
    lifetime_value  NUMERIC(12,2) NOT NULL DEFAULT 0,
    visits_count    INTEGER NOT NULL DEFAULT 0,
    last_visit_date DATE,
    notes           TEXT,
    referral_source TEXT,
    consent_given   BOOLEAN NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE clients IS 'Patient/client registry for LAISA aesthetic clinic CRM';

-- =============================================================================
-- 2. TREATMENTS / SERVICES
-- =============================================================================
CREATE TABLE treatments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            TEXT NOT NULL,
    description     TEXT,
    category        TEXT NOT NULL DEFAULT 'Facial' CHECK (category IN (
                        'Facial','Body','Laser','Injectables','Membership','Consultation','Package'
                    )),
    base_price      NUMERIC(10,2) NOT NULL DEFAULT 0,
    duration_minutes INTEGER NOT NULL DEFAULT 60,
    is_active       BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE treatments IS 'Catalog of aesthetic services and treatments offered';

-- =============================================================================
-- 3. APPOINTMENTS / BOOKINGS
-- =============================================================================
CREATE TABLE appointments (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id       UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    treatment_id    UUID NOT NULL REFERENCES treatments(id) ON DELETE RESTRICT,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status          TEXT NOT NULL DEFAULT 'Booked' CHECK (status IN (
                        'Pending','Booked','Confirmed','Checked-in','Completed','Cancelled','No-show'
                    )),
    notes           TEXT,
    booked_by       TEXT DEFAULT 'System', -- agent name or 'System'
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE appointments IS 'Client appointment bookings linked to treatments';

-- =============================================================================
-- 4. REVENUE / TRANSACTIONS
-- =============================================================================
CREATE TABLE transactions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id       UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    treatment_id    UUID REFERENCES treatments(id) ON DELETE SET NULL,
    appointment_id  UUID REFERENCES appointments(id) ON DELETE SET NULL,
    amount          NUMERIC(12,2) NOT NULL,
    currency        TEXT NOT NULL DEFAULT 'ZAR',
    payment_status  TEXT NOT NULL DEFAULT 'Pending' CHECK (payment_status IN (
                        'Pending','Paid','Partial','Refunded','Failed','Waived'
                    )),
    payment_method  TEXT CHECK (payment_method IN (
                        'Cash','Card','EFT','Medical Aid','Payment Link','Membership','Other'
                    )),
    invoice_number  TEXT UNIQUE,
    description     TEXT,
    paid_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE transactions IS 'All revenue transactions including treatments, memberships, and products';

-- =============================================================================
-- 5. AGENTS (Agent OS Registry)
-- =============================================================================
CREATE TABLE agents (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_key       TEXT NOT NULL UNIQUE, -- 'denchclaw', 'cashclaw', 'naledi', etc.
    name            TEXT NOT NULL,
    role            TEXT NOT NULL,
    status          TEXT NOT NULL DEFAULT 'Idle' CHECK (status IN (
                        'Active','Idle','Thinking','Error','Offline'
                    )),
    current_task    TEXT,
    model           TEXT,
    config_json     JSONB DEFAULT '{}',
    last_heartbeat  TIMESTAMPTZ,
    is_enabled      BOOLEAN NOT NULL DEFAULT true,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE agents IS 'Autonomous AI agents in the LAISA Agent OS';

-- =============================================================================
-- 6. AGENT ACTIVITIES / MISSION LOG
-- =============================================================================
CREATE TABLE agent_activities (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_id        UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    activity_type   TEXT NOT NULL CHECK (activity_type IN (
                        'booking','billing','content','call','sync','health','system','alert','insight'
                    )),
    message         TEXT NOT NULL,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE agent_activities IS 'Real-time activity feed from all agents — mission log';

-- =============================================================================
-- 7. SOCIAL MEDIA METRICS (Naledi Content Engine)
-- =============================================================================
CREATE TABLE social_platforms (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    platform        TEXT NOT NULL UNIQUE CHECK (platform IN (
                        'Facebook','Instagram','WhatsApp','Telegram','Google Ads','TikTok','LinkedIn'
                    )),
    account_handle  TEXT,
    is_connected    BOOLEAN NOT NULL DEFAULT false,
    followers       INTEGER DEFAULT 0,
    engagement_rate NUMERIC(5,2) DEFAULT 0, -- percentage
    posts_today     INTEGER DEFAULT 0,
    impressions_24h INTEGER DEFAULT 0,
    last_sync_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE social_platforms IS 'Social platform connection status and metrics';

-- =============================================================================
-- 8. CONTENT QUEUE (Higgsfield AI Pipeline)
-- =============================================================================
CREATE TABLE content_queue (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title           TEXT NOT NULL,
    content_type    TEXT NOT NULL CHECK (content_type IN ('video','image','carousel','story','reel')),
    status          TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN (
                        'Pending','Rendering','Ready','Published','Failed','Archived'
                    )),
    duration_seconds INTEGER,
    resolution      TEXT DEFAULT 'HD',
    created_by_agent TEXT DEFAULT 'naledi',
    platform_target TEXT[], -- e.g. {'Instagram','Facebook'}
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at    TIMESTAMPTZ
);

COMMENT ON TABLE content_queue IS 'AI-generated content pipeline tracking';

-- =============================================================================
-- 9. AGENTMAIL / DELIVERY LOG
-- =============================================================================
CREATE TABLE agentmail_deliveries (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject         TEXT NOT NULL,
    recipient_email TEXT,
    recipient_phone TEXT,
    delivery_type   TEXT NOT NULL CHECK (delivery_type IN ('email','sms','whatsapp','report')),
    status          TEXT NOT NULL DEFAULT 'Drafting' CHECK (status IN (
                        'Drafting','Queued','Sent','Delivered','Failed','Read'
                    )),
    sent_by_agent   TEXT,
    body_text       TEXT,
    metadata        JSONB DEFAULT '{}',
    sent_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE agentmail_deliveries IS 'AgentMail delivery tracking — reports, VIP briefings, SMS';

-- =============================================================================
-- 10. SYSTEM HEALTH / UPTIME
-- =============================================================================
CREATE TABLE system_health (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_name    TEXT NOT NULL, -- 'ORGO VM-02', 'n8n', 'Supabase', 'Claude API'
    region          TEXT DEFAULT 'jnb', -- Johannesburg
    status          TEXT NOT NULL DEFAULT 'Healthy' CHECK (status IN (
                        'Healthy','Degraded','Down','Maintenance','Unknown'
                    )),
    uptime_pct      NUMERIC(5,2) NOT NULL DEFAULT 100.00,
    latency_ms      INTEGER,
    memory_usage_pct NUMERIC(5,2),
    last_check      TIMESTAMPTZ NOT NULL DEFAULT now(),
    check_interval_sec INTEGER DEFAULT 60,
    metadata        JSONB DEFAULT '{}'
);

COMMENT ON TABLE system_health IS 'Real-time infrastructure monitoring for dashboard status bar';

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================
CREATE INDEX idx_clients_tag ON clients(tag);
CREATE INDEX idx_clients_last_visit ON clients(last_visit_date DESC);
CREATE INDEX idx_clients_created ON clients(created_at DESC);

CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_appointments_client ON appointments(client_id);
CREATE INDEX idx_appointments_status ON appointments(status);

CREATE INDEX idx_transactions_client ON transactions(client_id);
CREATE INDEX idx_transactions_created ON transactions(created_at DESC);
CREATE INDEX idx_transactions_status ON transactions(payment_status);

CREATE INDEX idx_agent_activities_agent ON agent_activities(agent_id);
CREATE INDEX idx_agent_activities_created ON agent_activities(created_at DESC);
CREATE INDEX idx_agent_activities_type ON agent_activities(activity_type);

CREATE INDEX idx_content_queue_status ON content_queue(status);
CREATE INDEX idx_system_health_service ON system_health(service_name);

-- =============================================================================
-- FUNCTIONS: AUTO-UPDATE updated_at
-- =============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER clients_updated_at BEFORE UPDATE ON clients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER appointments_updated_at BEFORE UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- FUNCTIONS: CLIENT LIFETIME VALUE AUTO-UPDATE
-- =============================================================================
CREATE OR REPLACE FUNCTION update_client_lifetime_value()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE clients
    SET lifetime_value = (
        SELECT COALESCE(SUM(amount), 0)
        FROM transactions
        WHERE client_id = NEW.client_id AND payment_status = 'Paid'
    ),
    visits_count = (
        SELECT COUNT(*) FROM appointments
        WHERE client_id = NEW.client_id AND status = 'Completed'
    ),
    last_visit_date = (
        SELECT MAX(appointment_date) FROM appointments
        WHERE client_id = NEW.client_id AND status = 'Completed'
    )
    WHERE id = NEW.client_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER transactions_update_client_stats
    AFTER INSERT OR UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_client_lifetime_value();

CREATE TRIGGER appointments_update_client_stats
    AFTER INSERT OR UPDATE ON appointments
    FOR EACH ROW EXECUTE FUNCTION update_client_lifetime_value();

-- =============================================================================
-- FUNCTIONS: DAILY REVENUE SNAPSHOT (for dashboard trend charts)
-- =============================================================================
CREATE TABLE daily_revenue_snapshots (
    snapshot_date   DATE PRIMARY KEY,
    total_revenue   NUMERIC(12,2) NOT NULL DEFAULT 0,
    transaction_count INTEGER NOT NULL DEFAULT 0,
    new_clients     INTEGER NOT NULL DEFAULT 0,
    completed_appointments INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION refresh_daily_revenue_snapshot(target_date DATE DEFAULT CURRENT_DATE)
RETURNS void AS $$
BEGIN
    INSERT INTO daily_revenue_snapshots (snapshot_date, total_revenue, transaction_count, new_clients, completed_appointments)
    SELECT
        target_date,
        COALESCE(SUM(t.amount), 0),
        COUNT(t.id),
        (SELECT COUNT(*) FROM clients WHERE DATE(created_at) = target_date),
        (SELECT COUNT(*) FROM appointments WHERE appointment_date = target_date AND status = 'Completed')
    FROM transactions t
    WHERE DATE(t.created_at) = target_date AND t.payment_status = 'Paid'
    ON CONFLICT (snapshot_date)
    DO UPDATE SET
        total_revenue = EXCLUDED.total_revenue,
        transaction_count = EXCLUDED.transaction_count,
        new_clients = EXCLUDED.new_clients,
        completed_appointments = EXCLUDED.completed_appointments,
        created_at = now();
END;
$$ language 'plpgsql';

-- =============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_platforms ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE agentmail_deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_health ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_revenue_snapshots ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated dashboard users can read everything
CREATE POLICY "Allow authenticated read all" ON clients
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read all" ON appointments
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read all" ON treatments
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read all" ON transactions
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read all" ON agents
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read all" ON agent_activities
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read all" ON social_platforms
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read all" ON content_queue
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read all" ON agentmail_deliveries
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read all" ON system_health
    FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read all" ON daily_revenue_snapshots
    FOR SELECT TO authenticated USING (true);

-- Policy: Admin role can manage everything
CREATE POLICY "Allow admin full access" ON clients
    FOR ALL TO authenticated USING (auth.jwt() ->> 'role' = 'admin') WITH CHECK (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Allow admin full access" ON appointments
    FOR ALL TO authenticated USING (auth.jwt() ->> 'role' = 'admin') WITH CHECK (auth.jwt() ->> 'role' = 'admin');
CREATE POLICY "Allow admin full access" ON transactions
    FOR ALL TO authenticated USING (auth.jwt() ->> 'role' = 'admin') WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Policy: Service role (agents via API key) can insert/update activities and metrics
CREATE POLICY "Allow service role write metrics" ON agent_activities
    FOR INSERT TO service_role WITH CHECK (true);
CREATE POLICY "Allow service role write metrics" ON system_health
    FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Allow service role write metrics" ON social_platforms
    FOR ALL TO service_role USING (true) WITH CHECK (true);
CREATE POLICY "Allow service role write metrics" ON content_queue
    FOR ALL TO service_role USING (true) WITH CHECK (true);

-- =============================================================================
-- VIEWS: DASHBOARD AGGREGATES
-- =============================================================================

-- Today's dashboard KPIs
CREATE OR REPLACE VIEW v_dashboard_kpis AS
SELECT
    (SELECT COALESCE(SUM(amount), 0) FROM transactions
     WHERE DATE(created_at) = CURRENT_DATE AND payment_status = 'Paid') AS daily_revenue,
    (SELECT COUNT(*) FROM clients WHERE DATE(created_at) = CURRENT_DATE) AS new_patients_today,
    (SELECT COUNT(*) FROM appointments WHERE appointment_date = CURRENT_DATE) AS appointments_today,
    (SELECT COALESCE(SUM(impressions_24h), 0) FROM social_platforms) AS social_reach_24h,
    (SELECT COUNT(*) FROM agent_activities WHERE created_at > now() - interval '24 hours') AS agent_actions_24h,
    (SELECT AVG(uptime_pct) FROM system_health WHERE last_check > now() - interval '5 minutes') AS system_uptime_avg;

-- Client 360 view (for CRM detail panel)
CREATE OR REPLACE VIEW v_client_360 AS
SELECT
    c.id,
    c.full_name,
    c.initials,
    c.phone,
    c.email,
    c.tag,
    c.lifetime_value,
    c.visits_count,
    c.last_visit_date,
    c.notes,
    c.referral_source,
    c.created_at,
    COALESCE(
        (SELECT jsonb_agg(jsonb_build_object(
            'id', t.id,
            'date', t.appointment_date,
            'name', tr.name,
            'desc', tr.description,
            'price', tr.base_price,
            'status', t.status
        ) ORDER BY t.appointment_date DESC)
        FROM appointments t
        JOIN treatments tr ON tr.id = t.treatment_id
        WHERE t.client_id = c.id),
        '[]'::jsonb
    ) AS treatment_history,
    COALESCE(
        (SELECT jsonb_agg(jsonb_build_object(
            'id', a.id,
            'time', a.appointment_time,
            'date', a.appointment_date,
            'service', tr.name,
            'status', a.status
        ) ORDER BY a.appointment_date, a.appointment_time)
        FROM appointments a
        JOIN treatments tr ON tr.id = a.treatment_id
        WHERE a.client_id = c.id AND a.appointment_date >= CURRENT_DATE AND a.status NOT IN ('Cancelled','No-show')),
        '[]'::jsonb
    ) AS upcoming_appointments
FROM clients c;

-- Agent status board (for sidebar)
CREATE OR REPLACE VIEW v_agent_status_board AS
SELECT
    a.id,
    a.agent_key,
    a.name,
    a.role,
    a.status,
    a.current_task,
    a.model,
    a.last_heartbeat,
    a.is_enabled,
    (SELECT COUNT(*) FROM agent_activities WHERE agent_id = a.id AND created_at > now() - interval '1 hour') AS actions_last_hour
FROM agents a
WHERE a.is_enabled = true
ORDER BY a.name;

-- Revenue by treatment category (for analytics)
CREATE OR REPLACE VIEW v_revenue_by_category AS
SELECT
    tr.category,
    COUNT(tx.id) AS transaction_count,
    COALESCE(SUM(tx.amount), 0) AS total_revenue,
    AVG(tx.amount) AS avg_transaction
FROM transactions tx
JOIN treatments tr ON tr.id = tx.treatment_id
WHERE tx.payment_status = 'Paid'
GROUP BY tr.category
ORDER BY total_revenue DESC;

-- =============================================================================
-- REALTIME SUBSCRIPTIONS: ENABLE PUBLICATIONS
-- =============================================================================
-- These tables will broadcast changes via Supabase Realtime for live dashboard updates
-- Run in Supabase Dashboard SQL Editor after schema creation:
--
--   ALTER PUBLICATION supabase_realtime ADD TABLE agent_activities;
--   ALTER PUBLICATION supabase_realtime ADD TABLE system_health;
--   ALTER PUBLICATION supabase_realtime ADD TABLE social_platforms;
--   ALTER PUBLICATION supabase_realtime ADD TABLE transactions;
--   ALTER PUBLICATION supabase_realtime ADD TABLE appointments;
--
-- =============================================================================
