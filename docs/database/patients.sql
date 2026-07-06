-- =============================================================================
-- Helpster Care — Patient Management schema (reference DDL)
-- Reference: AGENTS.md §40, §71, §90-§93, Appendix B
-- Note: This is a documentation reference. Production changes MUST go through
--       chronological migrations in /supabase/migrations (see migrations.md).
-- =============================================================================

-- Canonical patient record --------------------------------------------------
CREATE TABLE IF NOT EXISTS patients (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id    TEXT NOT NULL UNIQUE,              -- human-readable: PAT-2026-000001
    national_id   TEXT,
    full_name     TEXT NOT NULL,
    date_of_birth DATE,
    gender        TEXT CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
    blood_group   TEXT,
    religion      TEXT,
    photo_path    TEXT,                              -- Supabase Storage path
    status        TEXT NOT NULL DEFAULT 'DRAFT'
                    REFERENCES patient_status (code),
    hospital_id   UUID REFERENCES hospitals (id),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by    UUID REFERENCES users (id),
    updated_by    UUID REFERENCES users (id),
    deleted_at    TIMESTAMPTZ,
    deleted_by    UUID REFERENCES users (id),
    is_deleted    BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_patients_patient_id  ON patients (patient_id);
CREATE INDEX IF NOT EXISTS idx_patients_hospital_id ON patients (hospital_id);
CREATE INDEX IF NOT EXISTS idx_patients_status      ON patients (status);
CREATE INDEX IF NOT EXISTS idx_patients_created_at  ON patients (created_at);

-- Assignments (ReBAC) — historical assignments must be preserved -------------
CREATE TABLE IF NOT EXISTS patient_assignments (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id     UUID NOT NULL REFERENCES patients (id),
    user_id        UUID NOT NULL REFERENCES users (id),
    assignment_type TEXT NOT NULL
                     CHECK (assignment_type IN ('DOCTOR','VOLUNTEER','CASE_MANAGER','COORDINATOR')),
    is_active      BOOLEAN NOT NULL DEFAULT true,
    assigned_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    unassigned_at  TIMESTAMPTZ,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by     UUID REFERENCES users (id),
    updated_by     UUID REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_patient_assignments_patient ON patient_assignments (patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_assignments_user    ON patient_assignments (user_id);

-- Supporting patient tables --------------------------------------------------
CREATE TABLE IF NOT EXISTS patient_contacts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id  UUID NOT NULL REFERENCES patients (id),
    phone       TEXT,
    email       TEXT,
    is_emergency BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS patient_guardians (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id   UUID NOT NULL REFERENCES patients (id),
    full_name    TEXT NOT NULL,
    relationship TEXT,
    phone        TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS patient_status_history (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id  UUID NOT NULL REFERENCES patients (id),
    from_status TEXT,
    to_status   TEXT NOT NULL,
    changed_by  UUID REFERENCES users (id),
    changed_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Lookup: patient status -----------------------------------------------------
CREATE TABLE IF NOT EXISTS patient_status (
    code  TEXT PRIMARY KEY,   -- DRAFT, PENDING, APPROVED, ADMITTED, DISCHARGED, CLOSED ...
    label TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
);

-- RLS is enabled and policed separately — see rls/patients.sql.
