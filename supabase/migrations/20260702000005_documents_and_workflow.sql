-- Migration: documents_and_workflow
-- Purpose:   Document management, workflow states, approvals (AGENTS.md §49–§51, §84, §101–§105)
-- Reversible: yes

-- === UP =====================================================================

-- Document category lookup
CREATE TABLE IF NOT EXISTS document_categories (
    code       TEXT PRIMARY KEY,
    label      TEXT NOT NULL,
    description TEXT,
    sort_order INT NOT NULL DEFAULT 0
);

-- Document metadata (binaries in Supabase Storage)
CREATE TABLE IF NOT EXISTS documents (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id    UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    category_id   TEXT REFERENCES document_categories (code),
    title         TEXT NOT NULL,
    description   TEXT,
    storage_path  TEXT NOT NULL,
    checksum      TEXT,
    size_bytes    BIGINT NOT NULL DEFAULT 0,
    mime_type     TEXT,
    is_verified   BOOLEAN NOT NULL DEFAULT false,
    verified_by   UUID REFERENCES users (id),
    verified_at   TIMESTAMPTZ,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by    UUID REFERENCES users (id),
    updated_by    UUID REFERENCES users (id),
    deleted_at    TIMESTAMPTZ,
    deleted_by    UUID REFERENCES users (id),
    is_deleted    BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_documents_patient   ON documents (patient_id);
CREATE INDEX IF NOT EXISTS idx_documents_category  ON documents (category_id);

-- Document versions
CREATE TABLE IF NOT EXISTS document_versions (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id  UUID NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
    version_num  INT NOT NULL,
    storage_path TEXT NOT NULL,
    checksum     TEXT,
    size_bytes   BIGINT NOT NULL DEFAULT 0,
    uploaded_by  UUID REFERENCES users (id),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_document_version UNIQUE (document_id, version_num)
);

CREATE INDEX IF NOT EXISTS idx_document_versions_document ON document_versions (document_id);

-- Attachments
CREATE TABLE IF NOT EXISTS attachments (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id  UUID NOT NULL REFERENCES documents (id) ON DELETE CASCADE,
    file_name    TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    size_bytes   BIGINT NOT NULL DEFAULT 0,
    mime_type    TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by   UUID REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_attachments_document ON attachments (document_id);

-- Workflow states (catalogue)
CREATE TABLE IF NOT EXISTS workflow_states (
    code       TEXT PRIMARY KEY,
    label      TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
);

-- Workflow transitions (explicit; Flutter never decides validity)
CREATE TABLE IF NOT EXISTS workflow_transitions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_state          TEXT NOT NULL REFERENCES workflow_states (code),
    to_state            TEXT NOT NULL REFERENCES workflow_states (code),
    required_permission TEXT NOT NULL REFERENCES permissions (code),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_workflow_transition UNIQUE (from_state, to_state)
);

CREATE INDEX IF NOT EXISTS idx_workflow_transitions_from ON workflow_transitions (from_state);

-- Approval records
CREATE TABLE IF NOT EXISTS approvals (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id     UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    current_state  TEXT NOT NULL REFERENCES workflow_states (code) DEFAULT 'DRAFT',
    priority       TEXT NOT NULL DEFAULT 'NORMAL'
                     CHECK (priority IN ('LOW','NORMAL','HIGH','URGENT')),
    submitted_by   UUID REFERENCES users (id),
    reviewed_by    UUID REFERENCES users (id),
    review_notes   TEXT,
    decided_at     TIMESTAMPTZ,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by     UUID REFERENCES users (id),
    updated_by     UUID REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_approvals_patient ON approvals (patient_id);
CREATE INDEX IF NOT EXISTS idx_approvals_state   ON approvals (current_state);

-- Approval history (immutable transition log)
CREATE TABLE IF NOT EXISTS approval_history (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    approval_id  UUID NOT NULL REFERENCES approvals (id) ON DELETE CASCADE,
    from_state   TEXT REFERENCES workflow_states (code),
    to_state     TEXT NOT NULL REFERENCES workflow_states (code),
    actor_id     UUID REFERENCES users (id),
    reason       TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_approval_history_approval ON approval_history (approval_id);

-- === DOWN ===================================================================
-- DROP TABLE IF EXISTS approval_history CASCADE;
-- DROP TABLE IF EXISTS approvals CASCADE;
-- DROP TABLE IF EXISTS workflow_transitions CASCADE;
-- DROP TABLE IF EXISTS workflow_states CASCADE;
-- DROP TABLE IF EXISTS attachments CASCADE;
-- DROP TABLE IF EXISTS document_versions CASCADE;
-- DROP TABLE IF EXISTS documents CASCADE;
-- DROP TABLE IF EXISTS document_categories CASCADE;
