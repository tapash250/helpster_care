-- =============================================================================
-- Helpster Care — Organization / Hospital schema (reference DDL)
-- Reference: AGENTS.md §70, §94-§96, §184
-- Production changes MUST go through /supabase/migrations (see migrations.md).
-- =============================================================================

CREATE TABLE IF NOT EXISTS hospitals (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name         TEXT NOT NULL,
    hospital_type TEXT REFERENCES hospital_type (code),
    address      TEXT,
    phone        TEXT,
    is_active    BOOLEAN NOT NULL DEFAULT true,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by   UUID REFERENCES users (id),
    updated_by   UUID REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_hospitals_name ON hospitals (name);

CREATE TABLE IF NOT EXISTS departments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals (id),
    name        TEXT NOT NULL,                 -- General Surgery, Orthopedics, ...
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_departments_hospital ON departments (hospital_id);

CREATE TABLE IF NOT EXISTS wards (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals (id),
    name        TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS beds (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ward_id       UUID NOT NULL REFERENCES wards (id),
    department_id UUID REFERENCES departments (id),
    bed_number    TEXT NOT NULL,
    patient_id    UUID REFERENCES patients (id),
    status        TEXT NOT NULL DEFAULT 'AVAILABLE'
                    CHECK (status IN ('AVAILABLE','OCCUPIED','RESERVED','CLEANING','MAINTENANCE')),
    last_updated  TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_beds_ward_number UNIQUE (ward_id, bed_number)
);

CREATE INDEX IF NOT EXISTS idx_beds_ward   ON beds (ward_id);
CREATE INDEX IF NOT EXISTS idx_beds_status ON beds (status);

CREATE TABLE IF NOT EXISTS operating_theatres (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals (id),
    ot_room     TEXT NOT NULL,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_ot_hospital_room UNIQUE (hospital_id, ot_room)
);

-- ReBAC: which users may access which hospitals (§70) ------------------------
CREATE TABLE IF NOT EXISTS hospital_assignments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users (id),
    hospital_id UUID NOT NULL REFERENCES hospitals (id),
    is_active   BOOLEAN NOT NULL DEFAULT true,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_hospital_assignment UNIQUE (user_id, hospital_id)
);

CREATE INDEX IF NOT EXISTS idx_hospital_assignments_user     ON hospital_assignments (user_id);
CREATE INDEX IF NOT EXISTS idx_hospital_assignments_hospital ON hospital_assignments (hospital_id);

-- Lookup: hospital type ------------------------------------------------------
CREATE TABLE IF NOT EXISTS hospital_type (
    code  TEXT PRIMARY KEY,
    label TEXT NOT NULL
);

-- RLS is enabled and policed separately — see rls/hospitals.sql.
