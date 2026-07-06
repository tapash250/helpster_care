-- Migration: organizations
-- Purpose:   Hospital, department, ward, bed, OT, and assignment tables (AGENTS.md §70, §94–§96)
-- Reversible: yes

-- === UP =====================================================================

-- Hospital type lookup
CREATE TABLE IF NOT EXISTS hospital_type (
    code  TEXT PRIMARY KEY,
    label TEXT NOT NULL
);

-- Hospitals
CREATE TABLE IF NOT EXISTS hospitals (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name          TEXT NOT NULL,
    hospital_type TEXT REFERENCES hospital_type (code),
    address       TEXT,
    phone         TEXT,
    email         TEXT,
    website       TEXT,
    registration_no TEXT,
    is_active     BOOLEAN NOT NULL DEFAULT true,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by    UUID REFERENCES users (id),
    updated_by    UUID REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_hospitals_name ON hospitals (name);

-- Departments
CREATE TABLE IF NOT EXISTS departments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals (id) ON DELETE CASCADE,
    name        TEXT NOT NULL,
    description TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_departments_hospital ON departments (hospital_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_departments_hospital_name ON departments (hospital_id, name);

-- Wards
CREATE TABLE IF NOT EXISTS wards (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals (id) ON DELETE CASCADE,
    name        TEXT NOT NULL,
    description TEXT,
    capacity    INT NOT NULL DEFAULT 0,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wards_hospital ON wards (hospital_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_wards_hospital_name ON wards (hospital_id, name);

-- Beds
CREATE TABLE IF NOT EXISTS beds (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ward_id       UUID NOT NULL REFERENCES wards (id) ON DELETE CASCADE,
    department_id UUID REFERENCES departments (id),
    bed_number    TEXT NOT NULL,
    patient_id    UUID, -- soft reference; FK is added in patients migration
    status        TEXT NOT NULL DEFAULT 'AVAILABLE'
                    CHECK (status IN ('AVAILABLE','OCCUPIED','RESERVED','CLEANING','MAINTENANCE')),
    last_updated  TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_beds_ward_number UNIQUE (ward_id, bed_number)
);

CREATE INDEX IF NOT EXISTS idx_beds_ward    ON beds (ward_id);
CREATE INDEX IF NOT EXISTS idx_beds_status  ON beds (status);

-- Operating theatres
CREATE TABLE IF NOT EXISTS operating_theatres (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hospital_id UUID NOT NULL REFERENCES hospitals (id) ON DELETE CASCADE,
    ot_room     TEXT NOT NULL,
    floor       TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_ot_hospital_room UNIQUE (hospital_id, ot_room)
);

CREATE INDEX IF NOT EXISTS idx_ot_hospital ON operating_theatres (hospital_id);

-- Hospital assignments (ReBAC)
CREATE TABLE IF NOT EXISTS hospital_assignments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    hospital_id UUID NOT NULL REFERENCES hospitals (id) ON DELETE CASCADE,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    assigned_by UUID REFERENCES users (id),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_hospital_assignment UNIQUE (user_id, hospital_id)
);

CREATE INDEX IF NOT EXISTS idx_hospital_assignments_user     ON hospital_assignments (user_id);
CREATE INDEX IF NOT EXISTS idx_hospital_assignments_hospital ON hospital_assignments (hospital_id);

-- === DOWN ===================================================================
-- DROP TABLE IF EXISTS hospital_assignments CASCADE;
-- DROP TABLE IF EXISTS operating_theatres CASCADE;
-- DROP TABLE IF EXISTS beds CASCADE;
-- DROP TABLE IF EXISTS wards CASCADE;
-- DROP TABLE IF EXISTS departments CASCADE;
-- DROP TABLE IF EXISTS hospitals CASCADE;
-- DROP TABLE IF EXISTS hospital_type CASCADE;
