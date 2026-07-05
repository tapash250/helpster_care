-- =============================================================================
-- Helpster Care — Workflow / Approval schema (reference DDL)
-- Reference: AGENTS.md §84, §104, §184
-- Production changes MUST go through /supabase/migrations (see migrations.md).
-- =============================================================================

-- Workflow state catalogue (lookup) -----------------------------------------
CREATE TABLE IF NOT EXISTS workflow_states (
    code       TEXT PRIMARY KEY,   -- DRAFT, PENDING_DOCUMENTS, SUBMITTED, MEDICAL_REVIEW, APPROVED, REJECTED ...
    label      TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
);

-- Allowed transitions (explicit; Flutter never decides validity) -------------
CREATE TABLE IF NOT EXISTS workflow_transitions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_state  TEXT NOT NULL REFERENCES workflow_states (code),
    to_state    TEXT NOT NULL REFERENCES workflow_states (code),
    required_permission TEXT NOT NULL REFERENCES permissions (code),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_workflow_transition UNIQUE (from_state, to_state)
);

-- Approval record ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS approvals (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id     UUID NOT NULL REFERENCES patients (id),
    current_state  TEXT NOT NULL REFERENCES workflow_states (code) DEFAULT 'DRAFT',
    priority       TEXT DEFAULT 'NORMAL',
    submitted_by   UUID REFERENCES users (id),
    reviewed_by    UUID REFERENCES users (id),
    decided_at     TIMESTAMPTZ,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by     UUID REFERENCES users (id),
    updated_by     UUID REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_approvals_patient ON approvals (patient_id);
CREATE INDEX IF NOT EXISTS idx_approvals_state   ON approvals (current_state);

-- Immutable transition log (every transition → timeline + notification + audit)
CREATE TABLE IF NOT EXISTS approval_history (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    approval_id  UUID NOT NULL REFERENCES approvals (id),
    from_state   TEXT REFERENCES workflow_states (code),
    to_state     TEXT NOT NULL REFERENCES workflow_states (code),
    actor_id     UUID REFERENCES users (id),
    reason       TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_approval_history_approval ON approval_history (approval_id);

-- NOTE: Only Edge Functions may perform state transitions (AGENTS.md §84).
--       Each transition validates the required permission via
--       workflow_transitions and writes an audit entry. RLS: rls/approvals.sql.
