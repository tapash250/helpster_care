-- Migration: audit_notifications_analytics
-- Purpose:   Audit logs, activity timeline, notifications, analytics (AGENTS.md §58–§61, §92, §107–§110)
-- Reversible: yes

-- === UP =====================================================================

-- Audit logs (immutable compliance record)
CREATE TABLE IF NOT EXISTS audit_logs (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID REFERENCES users (id),
    action       TEXT NOT NULL,
    entity_type  TEXT NOT NULL,
    entity_id    UUID,
    details      JSONB,
    ip_address   TEXT,
    user_agent   TEXT,
    performed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user       ON audit_logs (user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity     ON audit_logs (entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_performed  ON audit_logs (performed_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action     ON audit_logs (action);

-- Activity timeline (operational history, user-facing)
CREATE TABLE IF NOT EXISTS activity_timeline (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id   UUID REFERENCES patients (id) ON DELETE CASCADE,
    user_id      UUID REFERENCES users (id),
    activity_type TEXT NOT NULL,
    description  TEXT NOT NULL,
    metadata     JSONB,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_activity_timeline_patient  ON activity_timeline (patient_id);
CREATE INDEX IF NOT EXISTS idx_activity_timeline_user     ON activity_timeline (user_id);
CREATE INDEX IF NOT EXISTS idx_activity_timeline_created  ON activity_timeline (created_at);

-- System events
CREATE TABLE IF NOT EXISTS system_events (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type   TEXT NOT NULL,
    severity     TEXT NOT NULL DEFAULT 'INFO'
                   CHECK (severity IN ('DEBUG','INFO','WARNING','ERROR','CRITICAL')),
    source       TEXT,
    message      TEXT NOT NULL,
    details      JSONB,
    acknowledged BOOLEAN NOT NULL DEFAULT false,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_system_events_type ON system_events (event_type);
CREATE INDEX IF NOT EXISTS idx_system_events_severity ON system_events (severity);

-- Notification templates
CREATE TABLE IF NOT EXISTS notification_templates (
    code       TEXT PRIMARY KEY,
    title      TEXT NOT NULL,
    body       TEXT NOT NULL,
    channels   TEXT[] NOT NULL DEFAULT '{PUSH,IN_APP}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Notifications
CREATE TABLE IF NOT EXISTS notifications (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    template_code TEXT REFERENCES notification_templates (code),
    title        TEXT NOT NULL,
    body         TEXT NOT NULL,
    channel      TEXT NOT NULL DEFAULT 'IN_APP'
                   CHECK (channel IN ('IN_APP','PUSH','EMAIL','SMS')),
    reference_type TEXT,
    reference_id   UUID,
    is_read      BOOLEAN NOT NULL DEFAULT false,
    read_at      TIMESTAMPTZ,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_recipient ON notifications (recipient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read      ON notifications (recipient_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created   ON notifications (created_at);

-- Emails log
CREATE TABLE IF NOT EXISTS emails (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient   TEXT NOT NULL,
    subject     TEXT NOT NULL,
    body        TEXT NOT NULL,
    status      TEXT NOT NULL DEFAULT 'PENDING'
                  CHECK (status IN ('PENDING','SENT','DELIVERED','BOUNCED','FAILED')),
    sent_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_emails_status ON emails (status);

-- Push notifications log
CREATE TABLE IF NOT EXISTS push_notifications (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    device_token  TEXT NOT NULL,
    title         TEXT NOT NULL,
    body          TEXT NOT NULL,
    status        TEXT NOT NULL DEFAULT 'PENDING'
                    CHECK (status IN ('PENDING','SENT','DELIVERED','FAILED')),
    sent_at       TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_push_notifications_user ON push_notifications (user_id);

-- Dashboard cache (materialized)
CREATE TABLE IF NOT EXISTS dashboard_cache (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    cache_key   TEXT NOT NULL,
    cache_value JSONB NOT NULL,
    expires_at  TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_dashboard_cache UNIQUE (user_id, cache_key)
);

CREATE INDEX IF NOT EXISTS idx_dashboard_cache_user ON dashboard_cache (user_id);

-- Analytics daily snapshots
CREATE TABLE IF NOT EXISTS analytics_daily (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id      UUID REFERENCES hospitals (id),
    snapshot_date    DATE NOT NULL,
    total_patients   INT NOT NULL DEFAULT 0,
    new_patients     INT NOT NULL DEFAULT 0,
    active_treatments INT NOT NULL DEFAULT 0,
    surgeries_today  INT NOT NULL DEFAULT 0,
    pending_approvals INT NOT NULL DEFAULT 0,
    discharges       INT NOT NULL DEFAULT 0,
    followups_today  INT NOT NULL DEFAULT 0,
    metadata         JSONB,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_analytics_daily UNIQUE (hospital_id, snapshot_date)
);

CREATE INDEX IF NOT EXISTS idx_analytics_daily_date ON analytics_daily (snapshot_date);

-- Analytics monthly aggregations
CREATE TABLE IF NOT EXISTS analytics_monthly (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id      UUID REFERENCES hospitals (id),
    snapshot_month   DATE NOT NULL,  -- first day of month
    total_patients   INT NOT NULL DEFAULT 0,
    new_patients     INT NOT NULL DEFAULT 0,
    total_surgeries  INT NOT NULL DEFAULT 0,
    avg_treatment_days NUMERIC(6,1),
    metadata         JSONB,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_analytics_monthly UNIQUE (hospital_id, snapshot_month)
);

CREATE INDEX IF NOT EXISTS idx_analytics_monthly_month ON analytics_monthly (snapshot_month);

-- Statistics (arbitrary key-value stats)
CREATE TABLE IF NOT EXISTS statistics (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stat_key    TEXT NOT NULL UNIQUE,
    stat_value  JSONB NOT NULL,
    label       TEXT,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- === DOWN ===================================================================
-- DROP TABLE IF EXISTS statistics CASCADE;
-- DROP TABLE IF EXISTS analytics_monthly CASCADE;
-- DROP TABLE IF EXISTS analytics_daily CASCADE;
-- DROP TABLE IF EXISTS dashboard_cache CASCADE;
-- DROP TABLE IF EXISTS push_notifications CASCADE;
-- DROP TABLE IF EXISTS emails CASCADE;
-- DROP TABLE IF EXISTS notifications CASCADE;
-- DROP TABLE IF EXISTS notification_templates CASCADE;
-- DROP TABLE IF EXISTS system_events CASCADE;
-- DROP TABLE IF EXISTS activity_timeline CASCADE;
-- DROP TABLE IF EXISTS audit_logs CASCADE;
