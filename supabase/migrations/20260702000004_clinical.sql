-- Migration: clinical
-- Purpose:   Treatments, conservative/surgical, OT schedules, follow-ups (AGENTS.md §97–§103)
-- Reversible: yes

-- === UP =====================================================================

-- Treatment type lookup
CREATE TABLE IF NOT EXISTS treatment_type (
    code  TEXT PRIMARY KEY,   -- CONSERVATIVE | SURGICAL
    label TEXT NOT NULL
);

-- Abstract parent treatment
CREATE TABLE IF NOT EXISTS treatments (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id       UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    hospital_id      UUID REFERENCES hospitals (id),
    treatment_type   TEXT NOT NULL REFERENCES treatment_type (code),
    diagnosis        TEXT,
    consultant_id    UUID REFERENCES users (id),
    admission_date   DATE,
    expected_outcome TEXT,
    status           TEXT NOT NULL DEFAULT 'ACTIVE'
                       CHECK (status IN ('ACTIVE','COMPLETED','DISCHARGED','CANCELLED')),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by       UUID REFERENCES users (id),
    updated_by       UUID REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_treatments_patient ON treatments (patient_id);
CREATE INDEX IF NOT EXISTS idx_treatments_status  ON treatments (status);

-- Diagnoses
CREATE TABLE IF NOT EXISTS diagnoses (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id  UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    treatment_id UUID REFERENCES treatments (id),
    diagnosis   TEXT NOT NULL,
    diagnosis_type TEXT DEFAULT 'PRIMARY',
    diagnosed_by UUID REFERENCES users (id),
    diagnosed_at DATE NOT NULL DEFAULT CURRENT_DATE,
    notes       TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_diagnoses_patient ON diagnoses (patient_id);

-- Prescriptions
CREATE TABLE IF NOT EXISTS prescriptions (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id   UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    treatment_id UUID REFERENCES treatments (id),
    prescribed_by UUID REFERENCES users (id),
    medication   TEXT NOT NULL,
    dosage       TEXT,
    frequency    TEXT,
    duration     TEXT,
    route        TEXT,
    notes        TEXT,
    is_active    BOOLEAN NOT NULL DEFAULT true,
    prescribed_at DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_prescriptions_patient ON prescriptions (patient_id);

-- Conservative treatment
CREATE TABLE IF NOT EXISTS conservative_treatments (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    treatment_id       UUID NOT NULL REFERENCES treatments (id) ON DELETE CASCADE,
    ward_id            UUID REFERENCES wards (id),
    bed_id             UUID REFERENCES beds (id),
    medication         TEXT,
    investigations     TEXT,
    expected_discharge DATE,
    discharge_summary  TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_conservative_tx_treatment ON conservative_treatments (treatment_id);

-- Surgical treatment
CREATE TABLE IF NOT EXISTS surgical_treatments (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    treatment_id        UUID NOT NULL REFERENCES treatments (id) ON DELETE CASCADE,
    procedure           TEXT,
    surgeon_id          UUID REFERENCES users (id),
    assistant_surgeon_id UUID REFERENCES users (id),
    anaesthetist_id     UUID REFERENCES users (id),
    implants            TEXT,
    operation_notes     TEXT,
    icu_transfer        BOOLEAN NOT NULL DEFAULT false,
    post_op_notes       TEXT,
    discharge_summary   TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_surgical_tx_treatment ON surgical_treatments (treatment_id);

-- Surgeries (individual procedures within a surgical treatment)
CREATE TABLE IF NOT EXISTS surgeries (
    id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    surgical_treatment_id UUID NOT NULL REFERENCES surgical_treatments (id) ON DELETE CASCADE,
    patient_id            UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    procedure_name        TEXT,
    performed_at          TIMESTAMPTZ,
    duration_minutes      INT,
    outcome               TEXT,
    notes                 TEXT,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_surgeries_surgical_tx  ON surgeries (surgical_treatment_id);
CREATE INDEX IF NOT EXISTS idx_surgeries_patient       ON surgeries (patient_id);

-- OT scheduling (double-booking guard via exclusion constraint)
CREATE TABLE IF NOT EXISTS ot_schedules (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operating_theatre_id UUID NOT NULL REFERENCES operating_theatres (id),
    surgery_id           UUID REFERENCES surgeries (id),
    patient_id           UUID NOT NULL REFERENCES patients (id),
    procedure            TEXT,
    primary_surgeon_id   UUID REFERENCES users (id),
    assistant_surgeon_id UUID REFERENCES users (id),
    anaesthetist_id      UUID REFERENCES users (id),
    anaesthesia_type     TEXT,
    scheduled_start      TIMESTAMPTZ NOT NULL,
    scheduled_end        TIMESTAMPTZ NOT NULL,
    actual_start         TIMESTAMPTZ,
    actual_end           TIMESTAMPTZ,
    status               TEXT NOT NULL DEFAULT 'SCHEDULED'
                           CHECK (status IN ('SCHEDULED','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED')),
    notes                TEXT,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- Prevent double-booking in the same theatre at the same time
    CONSTRAINT no_ot_double_booking
        EXCLUDE USING gist (
            operating_theatre_id WITH =,
            tstzrange(scheduled_start, scheduled_end) WITH &&
        )
);

CREATE INDEX IF NOT EXISTS idx_ot_schedules_theatre ON ot_schedules (operating_theatre_id);
CREATE INDEX IF NOT EXISTS idx_ot_schedules_patient ON ot_schedules (patient_id);
CREATE INDEX IF NOT EXISTS idx_ot_schedules_status  ON ot_schedules (status);

-- Follow-ups
CREATE TABLE IF NOT EXISTS followups (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id    UUID NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    hospital_id   UUID REFERENCES hospitals (id),
    doctor_id     UUID REFERENCES users (id),
    treatment_id  UUID REFERENCES treatments (id),
    followup_date DATE NOT NULL,
    instructions  TEXT,
    outcome       TEXT,
    next_visit    DATE,
    status        TEXT NOT NULL DEFAULT 'SCHEDULED'
                    CHECK (status IN ('SCHEDULED','COMPLETED','MISSED','CANCELLED')),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_followups_patient ON followups (patient_id);
CREATE INDEX IF NOT EXISTS idx_followups_date    ON followups (followup_date);

-- === DOWN ===================================================================
-- DROP TABLE IF EXISTS followups CASCADE;
-- DROP TABLE IF EXISTS ot_schedules CASCADE;
-- DROP TABLE IF EXISTS surgeries CASCADE;
-- DROP TABLE IF EXISTS surgical_treatments CASCADE;
-- DROP TABLE IF EXISTS conservative_treatments CASCADE;
-- DROP TABLE IF EXISTS prescriptions CASCADE;
-- DROP TABLE IF EXISTS diagnoses CASCADE;
-- DROP TABLE IF EXISTS treatments CASCADE;
-- DROP TABLE IF EXISTS treatment_type CASCADE;
