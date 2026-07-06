-- =============================================================================
-- Helpster Care — Clinical / Treatment schema (reference DDL)
-- Reference: AGENTS.md §97-§103, §184
-- Production changes MUST go through /supabase/migrations (see migrations.md).
-- =============================================================================

-- Abstract parent treatment (§97) -------------------------------------------
CREATE TABLE IF NOT EXISTS treatments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id      UUID NOT NULL REFERENCES patients (id),
    hospital_id     UUID REFERENCES hospitals (id),
    treatment_type  TEXT NOT NULL REFERENCES treatment_type (code),  -- CONSERVATIVE | SURGICAL
    diagnosis       TEXT,
    consultant_id   UUID REFERENCES users (id),
    admission_date  DATE,
    expected_outcome TEXT,
    status          TEXT NOT NULL DEFAULT 'ACTIVE',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by      UUID REFERENCES users (id),
    updated_by      UUID REFERENCES users (id)
);

CREATE INDEX IF NOT EXISTS idx_treatments_patient ON treatments (patient_id);
CREATE INDEX IF NOT EXISTS idx_treatments_status  ON treatments (status);

-- Conservative treatment (§98) ----------------------------------------------
CREATE TABLE IF NOT EXISTS conservative_treatments (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    treatment_id      UUID NOT NULL REFERENCES treatments (id),
    ward_id           UUID REFERENCES wards (id),
    bed_id            UUID REFERENCES beds (id),
    medication        TEXT,
    investigations    TEXT,
    expected_discharge DATE,
    discharge_summary TEXT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Surgical treatment (§99) --------------------------------------------------
CREATE TABLE IF NOT EXISTS surgical_treatments (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    treatment_id       UUID NOT NULL REFERENCES treatments (id),
    procedure          TEXT,
    surgeon_id         UUID REFERENCES users (id),
    assistant_surgeon_id UUID REFERENCES users (id),
    anaesthetist_id    UUID REFERENCES users (id),
    implants           TEXT,
    operation_notes    TEXT,
    icu_transfer       BOOLEAN NOT NULL DEFAULT false,
    post_op_notes      TEXT,
    discharge_summary  TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS surgeries (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    surgical_treatment_id UUID NOT NULL REFERENCES surgical_treatments (id),
    patient_id           UUID NOT NULL REFERENCES patients (id),
    performed_at         TIMESTAMPTZ,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- OT scheduling (§100) — double booking must never occur --------------------
CREATE TABLE IF NOT EXISTS ot_schedules (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operating_theatre_id UUID NOT NULL REFERENCES operating_theatres (id),
    surgery_id           UUID REFERENCES surgeries (id),
    patient_id           UUID NOT NULL REFERENCES patients (id),
    procedure            TEXT,
    primary_surgeon_id   UUID REFERENCES users (id),
    assistant_surgeon_id UUID REFERENCES users (id),
    anaesthetist_id      UUID REFERENCES users (id),
    scheduled_start      TIMESTAMPTZ NOT NULL,
    scheduled_end        TIMESTAMPTZ NOT NULL,
    status               TEXT NOT NULL DEFAULT 'SCHEDULED'
                           CHECK (status IN ('SCHEDULED','CONFIRMED','IN_PROGRESS','COMPLETED','CANCELLED')),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- Prevent overlapping bookings in the same theatre (double-booking guard).
    CONSTRAINT no_ot_double_booking
        EXCLUDE USING gist (
            operating_theatre_id WITH =,
            tstzrange(scheduled_start, scheduled_end) WITH &&
        )
);

CREATE INDEX IF NOT EXISTS idx_ot_schedules_theatre ON ot_schedules (operating_theatre_id);
CREATE INDEX IF NOT EXISTS idx_ot_schedules_patient ON ot_schedules (patient_id);

-- Follow-ups (§103) ----------------------------------------------------------
CREATE TABLE IF NOT EXISTS followups (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id   UUID NOT NULL REFERENCES patients (id),
    hospital_id  UUID REFERENCES hospitals (id),
    doctor_id    UUID REFERENCES users (id),
    followup_date DATE NOT NULL,
    instructions TEXT,
    outcome      TEXT,
    next_visit   DATE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Lookup: treatment type -----------------------------------------------------
CREATE TABLE IF NOT EXISTS treatment_type (
    code  TEXT PRIMARY KEY,   -- CONSERVATIVE | SURGICAL
    label TEXT NOT NULL
);

-- RLS follows patient access (a treatment is visible iff its patient is).
