-- =============================================================================
-- LAISA Agent OS — Realistic Demo Seed Data
-- 8 Clients, 6 Treatments, 12 Appointments, 15 Transactions
-- 6 Agents, 20 Activity Logs, 5 Social Platforms, 3 Content Items
-- =============================================================================

-- =============================================================================
-- TREATMENTS (Aesthetic Services Catalog)
-- =============================================================================
INSERT INTO treatments (id, name, description, category, base_price, duration_minutes) VALUES
  (gen_random_uuid(), 'Full Face Rejuvenation', 'Laser resurfacing + PRP combination therapy', 'Facial', 24500, 120),
  (gen_random_uuid(), 'Chemical Peel Series', '3-session TCA peel for skin resurfacing', 'Facial', 12000, 45),
  (gen_random_uuid(), 'Dermal Fillers', 'Hyaluronic acid cheek and lip augmentation', 'Injectables', 8200, 30),
  (gen_random_uuid(), 'Botox Touch-up', 'Forehead, crow\'s feet, glabella relaxation', 'Injectables', 3500, 20),
  (gen_random_uuid(), 'Thread Lift', 'PDO/PLLA mid-face suspension lift', 'Facial', 18500, 90),
  (gen_random_uuid(), 'Profhilo Full Face', 'Bio-remodelling hyaluronic acid injections', 'Injectables', 6800, 45),
  (gen_random_uuid(), 'Microneedling + PRP', 'Collagen induction therapy with platelet rich plasma', 'Facial', 4500, 60),
  (gen_random_uuid(), 'Laser Hair Removal', 'Full legs package — 6 sessions', 'Laser', 15000, 60),
  (gen_random_uuid(), 'Hydrafacial Signature', 'Deep cleanse, exfoliate, hydrate', 'Facial', 2800, 45),
  (gen_random_uuid(), 'Elite Membership', 'Annual unlimited consultation + 15% treatment discount', 'Membership', 8200, 0);

-- Capture treatment IDs for later use (we'll reference by name in the seed)
-- =============================================================================
-- CLIENTS (8 Realistic South African Client Profiles)
-- =============================================================================
INSERT INTO clients (id, full_name, phone, email, date_of_birth, tag, lifetime_value, visits_count, last_visit_date, notes, referral_source, consent_given) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Lebohang Mokoena', '+27 82 345 6789', 'lebohang.m@email.com', '1985-03-14', 'VIP', 48200, 12, '2026-05-05',
   'Premium client. Prefers afternoon appointments. Sensitive to hyaluronic acid. Always books Full Face Rejuvenation + Chemical Peel combo. VIP parking allocated.',
   'Instagram', true),
  ('22222222-2222-2222-2222-222222222222', 'Catherine Botha', '+27 83 456 7890', 'cathy.botha@email.com', '1978-11-22', 'Elite', 76800, 18, '2026-05-16',
   'Elite tier member since 2024. Prefers Dr. Naidoo. Bi-monthly Profhilo maintenance. Travels from Pretoria — book mid-morning slots.',
   'Referral — Priya Naidoo', true),
  ('33333333-3333-3333-3333-333333333333', 'Zandile Khumalo', '+27 84 567 8901', 'zandi.k@email.com', '1992-07-08', 'New', 12000, 2, '2026-04-05',
   'First aesthetic clinic experience. Nervous about pain — reassure thoroughly. Responded to Instagram ad for Chemical Peel introductory package.',
   'Instagram', true),
  ('44444444-4444-4444-4444-444444444444', 'Amahle Dlamini', '+27 85 678 9012', 'amahle.d@email.com', '1988-01-30', 'VIP', 34500, 8, '2026-05-12',
   'Hair restoration client — 4-session Microneedling + PRP protocol. Also purchased laser hair removal full legs. Very active on social — ask for reviews.',
   'Google', true),
  ('55555555-5555-5555-5555-555555555555', 'Priya Naidoo', '+27 86 789 0123', 'priya.n@email.com', '1983-09-18', 'Regular', 22100, 6, '2026-04-28',
   'Consistent botox + filler client. Books every 4 months. Interested in thread lift consultation — flag to Robusca for follow-up call.',
   'Walk-in', true),
  ('66666666-6666-6666-6666-666666666666', 'Jacques Marais', '+27 72 901 2345', 'jacques.m@email.com', '1975-05-03', 'Elite', 92300, 24, '2026-05-14',
   'High-value male client. Annual full face protocol — laser, PRP, fillers. Very particular about discretion. Private entrance used. Corporate referral network.',
   'Corporate Partner', true),
  ('77777777-7777-7777-7777-777777777777', 'Thandiwe Mbatha', '+27 73 012 3456', 'thandiwe.mbatha@email.com', '1990-12-11', 'Regular', 18500, 5, '2026-05-02',
   'Skin health focused. Monthly Hydrafacial + seasonal peels. Budget-conscious but loyal. Responds well to package deals.',
   'Facebook', true),
  ('88888888-8888-8888-8888-888888888888', 'Sarah Jenkins', '+27 74 123 4567', 'sarah.j@email.com', '1972-04-25', 'VIP', 112000, 31, '2026-05-18',
   'Longest-standing VIP. Started 2022. Full surgical and non-surgical history on file. Personal relationship with clinic director. Birthday reminder: April 25.',
   'Word of Mouth', true);

-- =============================================================================
-- APPOINTMENTS (12 bookings across upcoming dates)
-- =============================================================================
INSERT INTO appointments (client_id, treatment_id, appointment_date, appointment_time, status, notes, booked_by) VALUES
  -- Lebohang Mokoena
  ('11111111-1111-1111-1111-111111111111', (SELECT id FROM treatments WHERE name = 'Chemical Peel Series'), '2026-05-19', '14:00', 'Confirmed', 'Follow-up consultation + Session 2 prep', 'DenchClaw'),
  ('11111111-1111-1111-1111-111111111111', (SELECT id FROM treatments WHERE name = 'Chemical Peel Series'), '2026-06-15', '10:00', 'Booked', 'Session 2 — TCA medium depth', 'Robusca'),
  -- Catherine Botha
  ('22222222-2222-2222-2222-222222222222', (SELECT id FROM treatments WHERE name = 'Profhilo Full Face'), '2026-05-28', '11:00', 'Booked', 'Session 2 of 2 — bio-remodelling maintenance', 'DenchClaw'),
  -- Zandile Khumalo
  ('33333333-3333-3333-3333-333333333333', (SELECT id FROM treatments WHERE name = 'Chemical Peel Series'), '2026-05-25', '09:30', 'Pending', 'Peel Session 2 + full consultation review', 'DenchClaw'),
  -- Amahle Dlamini
  ('44444444-4444-4444-4444-444444444444', (SELECT id FROM treatments WHERE name = 'Microneedling + PRP'), '2026-05-22', '16:00', 'Confirmed', 'PRP Session 3 — hair restoration protocol', 'Robusca'),
  -- Priya Naidoo
  ('55555555-5555-5555-5555-555555555555', (SELECT id FROM treatments WHERE name = 'Botox Touch-up'), '2026-06-02', '13:30', 'Booked', '4-month touch-up — forehead + glabella', 'DenchClaw'),
  -- Jacques Marais
  ('66666666-6666-6666-6666-666666666666', (SELECT id FROM treatments WHERE name = 'Full Face Rejuvenation'), '2026-05-20', '09:00', 'Confirmed', 'Annual laser resurfacing — VIP suite booked', 'Robusca'),
  ('66666666-6666-6666-6666-666666666666', (SELECT id FROM treatments WHERE name = 'Dermal Fillers'), '2026-06-10', '11:30', 'Booked', 'Cheek augmentation top-up — 0.8ml per side', 'DenchClaw'),
  -- Thandiwe Mbatha
  ('77777777-7777-7777-7777-777777777777', (SELECT id FROM treatments WHERE name = 'Hydrafacial Signature'), '2026-05-21', '15:00', 'Confirmed', 'Monthly signature — summer prep', 'DenchClaw'),
  ('77777777-7777-7777-7777-777777777777', (SELECT id FROM treatments WHERE name = 'Chemical Peel Series'), '2026-06-05', '10:30', 'Booked', 'Introductory glycolic peel package', 'Robusca'),
  -- Sarah Jenkins
  ('88888888-8888-8888-8888-888888888888', (SELECT id FROM treatments WHERE name = 'Thread Lift'), '2026-05-19', '08:30', 'Confirmed', 'Annual thread maintenance — full face', 'Robusca'),
  ('88888888-8888-8888-8888-888888888888', (SELECT id FROM treatments WHERE name = 'Botox Touch-up'), '2026-06-01', '14:00', 'Booked', 'Touch-up before Cape Town holiday', 'DenchClaw');

-- =============================================================================
-- TRANSACTIONS (15 revenue records — mix of paid, pending, membership)
-- =============================================================================
INSERT INTO transactions (client_id, treatment_id, amount, payment_status, payment_method, invoice_number, description, paid_at) VALUES
  -- Lebohang
  ('11111111-1111-1111-1111-111111111111', (SELECT id FROM treatments WHERE name = 'Full Face Rejuvenation'), 24500, 'Paid', 'Card', 'INV-2026-8890', 'Laser + PRP combo', '2026-05-05 16:30:00+02'),
  ('11111111-1111-1111-1111-111111111111', (SELECT id FROM treatments WHERE name = 'Chemical Peel Series'), 12000, 'Paid', 'Card', 'INV-2026-8754', '3-session TCA package', '2026-04-12 15:45:00+02'),
  ('11111111-1111-1111-1111-111111111111', (SELECT id FROM treatments WHERE name = 'Dermal Fillers'), 8200, 'Paid', 'Card', 'INV-2026-8601', 'Cheek augmentation', '2026-03-20 14:20:00+02'),
  ('11111111-1111-1111-1111-111111111111', (SELECT id FROM treatments WHERE name = 'Botox Touch-up'), 3500, 'Paid', 'Card', 'INV-2026-8423', 'Forehead + crow\'s feet', '2026-02-08 13:00:00+02'),
  -- Catherine
  ('22222222-2222-2222-2222-222222222222', (SELECT id FROM treatments WHERE name = 'Elite Membership'), 8200, 'Paid', 'EFT', 'INV-2026-8892', 'Annual membership renewal', '2026-05-16 10:00:00+02'),
  ('22222222-2222-2222-2222-222222222222', (SELECT id FROM treatments WHERE name = 'Thread Lift'), 18500, 'Paid', 'Card', 'INV-2026-8721', 'Mid-face PDO suspension', '2026-05-02 11:30:00+02'),
  ('22222222-2222-2222-2222-222222222222', (SELECT id FROM treatments WHERE name = 'Profhilo Full Face'), 6800, 'Paid', 'Card', 'INV-2026-8550', 'Bio-remodelling session 1', '2026-04-10 09:15:00+02'),
  -- Zandile
  ('33333333-3333-3333-3333-333333333333', (SELECT id FROM treatments WHERE name = 'Chemical Peel Series'), 12000, 'Paid', 'Payment Link', 'INV-2026-8120', 'Introductory peel package', '2026-04-05 11:00:00+02'),
  -- Amahle
  ('44444444-4444-4444-4444-444444444444', (SELECT id FROM treatments WHERE name = 'Microneedling + PRP'), 4500, 'Paid', 'Card', 'INV-2026-8834', 'Hair restoration session 2', '2026-05-12 17:00:00+02'),
  ('44444444-4444-4444-4444-444444444444', (SELECT id FROM treatments WHERE name = 'Laser Hair Removal'), 15000, 'Paid', 'Medical Aid', 'INV-2026-8445', 'Full legs — 6 session package', '2026-04-22 10:00:00+02'),
  ('44444444-4444-4444-4444-444444444444', (SELECT id FROM treatments WHERE name = 'Hydrafacial Signature'), 2800, 'Paid', 'Card', 'INV-2026-8301', 'Signature treatment', '2026-03-15 14:30:00+02'),
  -- Priya
  ('55555555-5555-5555-5555-555555555555', (SELECT id FROM treatments WHERE name = 'Dermal Fillers'), 7200, 'Paid', 'Card', 'INV-2026-8655', 'Lip augmentation + glabella botox', '2026-04-28 16:00:00+02'),
  ('55555555-5555-5555-5555-555555555555', (SELECT id FROM treatments WHERE name = 'Chemical Peel Series'), 3500, 'Paid', 'Card', 'INV-2026-8210', 'Glycolic acid 35%', '2026-03-30 11:00:00+02'),
  -- Jacques
  ('66666666-6666-6666-6666-666666666666', (SELECT id FROM treatments WHERE name = 'Full Face Rejuvenation'), 24500, 'Pending', 'Card', 'INV-2026-8901', 'Annual protocol — invoice sent', NULL),
  -- Sarah
  ('88888888-8888-8888-8888-888888888888', (SELECT id FROM treatments WHERE name = 'Elite Membership'), 8200, 'Paid', 'EFT', 'INV-2026-8893', 'Annual membership renewal', '2026-05-18 09:00:00+02');

-- =============================================================================
-- AGENTS (6 Agents — matching the LAISA Agent OS dashboard)
-- =============================================================================
INSERT INTO agents (id, agent_key, name, role, status, current_task, model, config_json, last_heartbeat, is_enabled) VALUES
  ('a1a1a1a1-a1a1-a1a1-a1a1-a1a1a1a1a1a1', 'denchclaw', 'DenchClaw', 'Patient Support', 'Active', 'Monitoring WhatsApp bookings', 'Claude Haiku',
   '{"channels": ["whatsapp", "telegram"], "language": "en-ZA", "auto_reply": true}', now(), true),
  ('a2a2a2a2-a2a2-a2a2-a2a2-a2a2a2a2a2a2', 'cashclaw', 'CashClaw', 'Revenue & Billing', 'Idle', 'Sage Sync Pending', 'Claude Haiku',
   '{"integrations": ["sage", "stripe"], "currency": "ZAR", "auto_invoice": true}', now(), true),
  ('a3a3a3a3-a3a3-a3a3-a3a3-a3a3a3a3a3a3', 'naledi', 'Naledi', 'Content Engine', 'Active', 'Generating IG Post — Skin Longevity Series', 'Claude Sonnet',
   '{"platforms": ["instagram", "facebook"], "content_pipeline": "higgsfield", "posting_schedule": "daily"}', now(), true),
  ('a4a4a4a4-a4a4-a4a4-a4a4-a4a4a4a4a4a4', 'charlie', 'Charlie', 'Voice Agent', 'Active', 'Reminder Call: J. Smith — Booking Confirmation', 'ElevenLabs',
   '{"voice_id": "laisa_sophisticate", "languages": ["en-ZA"], "call_window": "08:00-18:00"}', now(), true),
  ('a5a5a5a5-a5a5-a5a5-a5a5-a5a5a5a5a5a5', 'robusca', 'Robusca', 'Clinic Coordinator', 'Active', 'Updating Daily Schedule to Obsidian', 'Claude Sonnet',
   '{"calendar_sync": "obsidian", "reminders": true, "staff_notifications": true}', now(), true),
  ('a6a6a6a6-a6a6-a6a6-a6a6-a6a6a6a6a6a6', 'general', 'General', 'Orchestrator', 'Active', 'Mission Dispatch — All Systems Nominal', 'Claude Opus',
   '{"supervisor": true, "escalation_threshold": "critical", "health_checks": true}', now(), true);

-- =============================================================================
-- AGENT ACTIVITIES (20 recent log entries — realistic mission stream)
-- =============================================================================
INSERT INTO agent_activities (agent_id, activity_type, message, metadata) VALUES
  ((SELECT id FROM agents WHERE agent_key = 'denchclaw'), 'booking', 'Confirmed booking for Sarah Jenkins — Thread Lift on 19 May 08:30', '{"client_id": "88888888-8888-8888-8888-888888888888", "appointment_id": "auto"}'),
  ((SELECT id FROM agents WHERE agent_key = 'cashclaw'), 'billing', 'Medical aid pre-authorisation verified for Amahle Dlamini — R15,000 laser package', '{"client_id": "44444444-4444-4444-4444-444444444444", "amount": 15000}'),
  ((SELECT id FROM agents WHERE agent_key = 'naledi'), 'content', 'Scheduled "3 Tips for Post-Op Care" carousel for Instagram at 14:00 SAST', '{"platform": "Instagram", "content_type": "carousel", "scheduled": "2026-05-19T14:00:00+02:00"}'),
  ((SELECT id FROM agents WHERE agent_key = 'charlie'), 'call', 'Voice call completed — Amahle Dlamini confirmed PRP Session 3 attendance', '{"client_id": "44444444-4444-4444-4444-444444444444", "duration_sec": 124, "outcome": "confirmed"}'),
  ((SELECT id FROM agents WHERE agent_key = 'robusca'), 'sync', 'Daily clinic schedule synced to Obsidian vault — 12 appointments, 3 VIP slots', '{"appointments_count": 12, "vip_slots": 3, "source": "obsidian"}'),
  ((SELECT id FROM agents WHERE agent_key = 'general'), 'health', 'ORGO VM-02 health check passed — CPU 34%, Memory 62%, Uptime 99.98%', '{"vm": "ORGO-VM-02", "cpu_pct": 34, "memory_pct": 62}'),
  ((SELECT id FROM agents WHERE agent_key = 'general'), 'system', 'Deployment of n8n v2.4 successful — 6 active workflows migrated', '{"version": "2.4", "workflows": 6}'),
  ((SELECT id FROM agents WHERE agent_key = 'cashclaw'), 'billing', 'Generated private payment link for invoice #INV-2026-8901 — Jacques Marais R24,500', '{"invoice": "INV-2026-8901", "payment_link": "https://pay.laisa.co/tx/a1b2c3", "amount": 24500}'),
  ((SELECT id FROM agents WHERE agent_key = 'denchclaw'), 'system', 'FAQ answered via WhatsApp: "Recovery time for Cataracts" — referred to SafeSight', '{"channel": "whatsapp", "topic": "referral", "destination": "safesight"}'),
  ((SELECT id FROM agents WHERE agent_key = 'naledi'), 'content', 'Content ingested from Higgsfield AI pipeline — "Skin Longevity Series" ready for review', '{"content_id": "higgs-2026-0519-01", "status": "ready"}'),
  ((SELECT id FROM agents WHERE agent_key = 'robusca'), 'booking', 'VIP suite reserved for Jacques Marais — 20 May 09:00 Full Face Rejuvenation', '{"room": "VIP-1", "client_id": "66666666-6666-6666-6666-666666666666"}'),
  ((SELECT id FROM agents WHERE agent_key = 'cashclaw'), 'billing', 'Elite membership renewal processed — Catherine Botha R8,200 via EFT', '{"membership_tier": "Elite", "client_id": "22222222-2222-2222-2222-222222222222"}'),
  ((SELECT id FROM agents WHERE agent_key = 'denchclaw'), 'booking', 'New enquiry from WhatsApp — Thandiwe Mbatha interested in summer Hydrafacial package', '{"lead_source": "whatsapp", "intent": "package_inquiry"}'),
  ((SELECT id FROM agents WHERE agent_key = 'naledi'), 'content', 'Facebook post published: "The Science Behind Profhilo" — 234 reach, 18 engagements', '{"platform": "Facebook", "reach": 234, "engagements": 18}'),
  ((SELECT id FROM agents WHERE agent_key = 'charlie'), 'call', 'Reminder call placed — Zandile Khumalo for 25 May peel session. Voicemail left.', '{"client_id": "33333333-3333-3333-3333-333333333333", "outcome": "voicemail", "retry_scheduled": "2026-05-20T10:00:00+02:00"}'),
  ((SELECT id FROM agents WHERE agent_key = 'general'), 'alert', 'CashClaw has been idle for 45 minutes — Sage sync job may require attention', '{"agent": "cashclaw", "idle_minutes": 45, "severity": "warning"}'),
  ((SELECT id FROM agents WHERE agent_key = 'robusca'), 'sync', 'ChromaDB vector index updated — 47 new client interaction embeddings stored', '{"vectors_added": 47, "index": "client-interactions"}'),
  ((SELECT id FROM agents WHERE agent_key = 'naledi'), 'insight', 'Weekly social report generated: Instagram +12% followers, best performing content: reels', '{"report_type": "weekly_social", "delivered_to": "ops@laisa.co"}'),
  ((SELECT id FROM agents WHERE agent_key = 'denchclaw'), 'booking', 'Appointment rescheduled — Priya Naidoo Botox moved from 30 May to 2 Jun 13:30', '{"client_id": "55555555-5555-5555-5555-555555555555", "old_date": "2026-05-30", "new_date": "2026-06-02"}'),
  ((SELECT id FROM agents WHERE agent_key = 'cashclaw'), 'billing', 'End-of-day reconciliation complete — R42,300 processed, 8 transactions, 0 discrepancies', '{"daily_total": 42300, "transaction_count": 8, "discrepancies": 0}');

-- =============================================================================
-- SOCIAL PLATFORMS (5 platforms — matching dashboard connections)
-- =============================================================================
INSERT INTO social_platforms (id, platform, account_handle, is_connected, followers, engagement_rate, posts_today, impressions_24h, last_sync_at) VALUES
  (gen_random_uuid(), 'Facebook', 'laisa.aesthetics', true, 3420, 4.2, 1, 1240, now()),
  (gen_random_uuid(), 'Instagram', '@laisa.skin', true, 8760, 6.8, 2, 3450, now()),
  (gen_random_uuid(), 'WhatsApp', 'LAISA Booking', true, 0, 0.0, 8, 156, now()),
  (gen_random_uuid(), 'Telegram', 'laisa_updates', true, 340, 12.5, 1, 89, now()),
  (gen_random_uuid(), 'Google Ads', 'laisa-clinic-jhb', false, 0, 0.0, 0, 0, NULL);

-- =============================================================================
-- CONTENT QUEUE (3 items — Higgsfield AI pipeline)
-- =============================================================================
INSERT INTO content_queue (id, title, content_type, status, duration_seconds, resolution, created_by_agent, platform_target, metadata, completed_at) VALUES
  (gen_random_uuid(), 'Skin Longevity Series — Episode 1', 'video', 'Ready', 15, 'HD', 'naledi', '{"Instagram", "Facebook"}',
   '{"theme": "education", "tone": "luxury", "music": "ambient", "thumbnail_ai": true}', '2026-05-18 16:00:00+02'),
  (gen_random_uuid(), 'Clinic Ambience Walkthrough', 'video', 'Rendering', 30, '4K', 'naledi', '{"Instagram", "TikTok"}',
   '{"theme": "brand", "tone": "cinematic", "music": "piano", "location": "sandton-clinic"}', NULL),
  (gen_random_uuid(), 'Before & After — Profhilo Transformation', 'carousel', 'Pending', 0, 'HD', 'naledi', '{"Instagram"}',
   '{"theme": "social_proof", "tone": "elegant", "client_consent": true, "blur_enabled": true}', NULL);

-- =============================================================================
-- AGENTMAIL DELIVERIES (4 items)
-- =============================================================================
INSERT INTO agentmail_deliveries (id, subject, recipient_email, delivery_type, status, sent_by_agent, body_text, sent_at) VALUES
  (gen_random_uuid(), 'Weekly Content Performance Report', 'ops@laisa.co', 'report', 'Delivered', 'naledi',
   'Instagram: +12% followers, 2 posts, 3.4K impressions. Facebook: 1 post, 1.2K reach. WhatsApp: 8 bookings handled.', '2026-05-19 07:00:00+02'),
  (gen_random_uuid(), 'VIP Client Briefing — Sarah Jenkins', 'dr.naicker@laisa.co', 'email', 'Drafting', 'general',
   'Annual thread lift maintenance scheduled 19 May. Lifetime value R112,000. Personal entrance requested.', NULL),
  (gen_random_uuid(), 'Payment Reminder — Invoice #INV-2026-8901', 'jacques.m@email.com', 'email', 'Queued', 'cashclaw',
   'Your payment of R24,500 for Full Face Rejuvenation is pending. Secure payment link: https://pay.laisa.co/tx/a1b2c3', '2026-05-18 17:00:00+02'),
  (gen_random_uuid(), 'Appointment Confirmation — Thandiwe Mbatha', '+27 73 012 3456', 'sms', 'Sent', 'denchclaw',
   'Hi Thandiwe, your Hydrafacial is confirmed for 21 May at 15:00. See you at LAISA Sandton. Reply STOP to opt out.', '2026-05-18 09:30:00+02');

-- =============================================================================
-- SYSTEM HEALTH (4 monitored services)
-- =============================================================================
INSERT INTO system_health (id, service_name, region, status, uptime_pct, latency_ms, memory_usage_pct, last_check, metadata) VALUES
  (gen_random_uuid(), 'ORGO VM-02', 'jnb', 'Healthy', 99.98, 24, 62, now(), '{"vm_host": "mac-mini-m4", "cpu_cores": 10, "disk_pct": 45}'),
  (gen_random_uuid(), 'Supabase DB', 'jnb', 'Healthy', 99.99, 12, 34, now(), '{"plan": "pro", "connections": 8, "replication_lag_ms": 0}'),
  (gen_random_uuid(), 'n8n Orchestrator', 'jnb', 'Healthy', 99.95, 45, 58, now(), '{"version": "2.4", "active_workflows": 6, "webhooks_active": 14}'),
  (gen_random_uuid(), 'Claude API Gateway', 'us-east-1', 'Healthy', 99.99, 180, 0, now(), '{"model": "claude-opus-4", "requests_1h": 47, "tokens_1h": 128400}');

-- =============================================================================
-- REFRESH SNAPSHOTS FOR TODAY
-- =============================================================================
SELECT refresh_daily_revenue_snapshot('2026-05-19');
SELECT refresh_daily_revenue_snapshot('2026-05-18');
SELECT refresh_daily_revenue_snapshot('2026-05-17');

-- =============================================================================
-- SEED COMPLETE
-- =============================================================================
