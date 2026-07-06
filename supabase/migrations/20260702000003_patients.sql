-- Migration: patients
-- Purpose:   Patient management tables (AGENTS.md §90–§93, §184, Appendix B)
-- Reversible: yes

-- === UP =====================================================================

-- Patient status lookup
CREATE TABLE IF NOT EXISTS patient_status (
    code       TEXT PRIMARY KEY,
    label      TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
);

-- Canonical patient record
CREATE TABLE IF NOT EXISTS patients (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id    TEXT NOT NULL UNIQUE,          -- human-readable: PAT-2026-000001
    national_id   TEXT,
    full_name     TEXT NOT NULL,
    date_of_birth DATE,
    gender        TEXT CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
    blood_group   TEXT,
    religion      TEXT,
    occupation    TEXT,
    photo_path    TEXT,                          -- Supabase Storage path
    status        TEXT NOT NULL DEFAULT 'DRAFT' REFERENCES patient_status (code),
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
CREATE INDEX IF NOT EXISTS idx_patients_full_name   ON patients (full_name);

-- Add FK from beds to patients (deferred)
ALTER TABLE beds ADD CONSTRAINT fk_beds_patient
    FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE SET NULL;

-- Patient contacts
CREATE TABLE IF NOT EXISTS patient_contacts (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id   UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    phone        TEXT,
    email        TEXT,
    is_emergency BOOLEAN NOT NULL DEFAULT false,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_patient_contacts_patient ON patient_contacts (patient_id);

-- Patient addresses
CREATE TABLE IF NOT EXISTS patient_addresses (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id     UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    address_type   TEXT NOT NULL DEFAULT 'PRESENT'
                     CHECK (address_type IN ('PRESENT','PERMANENT','WORK')),
    division       TEXT,
    district       TEXT,
    upazila        TEXT,
    union_or_city  TEXT,
    village_or_ward TEXT,
    street         TEXT,
    post_code      TEXT,
    country        TEXT NOT NULL DEFAULT 'Bangladesh',
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_patient_addresses_patient ON patient_addresses (patient_id);

-- Patient guardians
CREATE TABLE IF NOT EXISTS patient_guardians (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id   UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    full_name    TEXT NOT NULL,
    relationship TEXT,
    phone        TEXT,
    email        TEXT,
    address      TEXT,
    is_minor     BOOLEAN NOT NULL DEFAULT false,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_patient_guardians_patient ON patient_guardians (patient_id);

-- Patient assignments (ReBAC)
CREATE TABLE IF NOT EXISTS patient_assignments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id      UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    user_id         UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    assignment_type TEXT NOT NULL
                      CHECK (assignment_type IN ('DOCTOR','VOLUNTEER','CASE_MANAGER','COORDINATOR')),
    is_active       BOOLEAN NOT NULL DEFAULT true,
    assigned_by     UUID REFERENCES users (id),
    assigned_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    unassigned_at   TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_patient_assignment UNIQUE (patient_id, user_id, assignment_type)
);

CREATE INDEX IF NOT EXISTS idx_patient_assignments_patient ON patient_assignments (patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_assignments_user    ON patient_assignments (user_id);

-- Patient status history (immutable)
CREATE TABLE IF NOT EXISTS patient_status_history (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id  UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    from_status TEXT,
    to_status   TEXT NOT NULL,
    changed_by  UUID REFERENCES users (id),
    reason      TEXT,
    changed_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_patient_status_history_patient ON patient_status_history (patient_id);

-- Patient notes
CREATE TABLE IF NOT EXISTS patient_notes (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    note       TEXT NOT NULL,
    note_type  TEXT DEFAULT 'GENERAL',
    author_id  UUID REFERENCES users (id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_patient_notes_patient ON patient_notes (patient_id);

-- === DOWN ===================================================================
-- DROP TABLE IF EXISTS patient_notes CASCADE;
-- DROP TABLE IF EXISTS patient_status_history CASCADE;
-- DROP TABLE IF EXISTS patient_assignments CASCADE;
-- DROP TABLE IF EXISTS patient_guardians CASCADE;
-- DROP TABLE IF EXISTS patient_addresses CASCADE;
-- DROP TABLE IF EXISTS patient_contacts CASCADE;
-- DROP TABLE IF EXISTS patients CASCADE;
-- DROP TABLE IF EXISTS patient_status CASCADE;
-- ALTER TABLE beds DROP CONSTRAINT IF EXISTS fk_beds_patient;
