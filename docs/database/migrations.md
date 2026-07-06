# Migration Policy

> Reference: `AGENTS.md` §42, §62, §183, Appendix M.

Every database change is implemented through a migration. **Never** modify
production tables manually.

## Rules

- **One logical change per migration.**
- **Always reversible when possible** (provide a `down`/rollback path).
- **Never edit an applied migration** — create a new one instead.
- **Always include comments** explaining intent.
- **Always test against staging** before production.
- Migration filenames are **chronological**.

## File Location & Naming

Migrations live in [`/supabase/migrations/`](../../supabase/migrations).
Supabase CLI convention:

```
supabase/migrations/<YYYYMMDDHHMMSS>_<description>.sql
```

Example:

```
20260702093000_create_patients_table.sql
20260702093500_enable_rls_patients.sql
```

## Migration Template

```sql
-- Migration: create_patients_table
-- Purpose:   Canonical patient record (AGENTS.md §90, Appendix B).
-- Author:    <name>
-- Date:      2026-07-02
-- Reversible: yes

-- === UP =====================================================================
CREATE TABLE IF NOT EXISTS patients (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id    TEXT NOT NULL UNIQUE,          -- e.g. PAT-2026-000001
    full_name     TEXT NOT NULL,
    date_of_birth DATE,
    gender        TEXT,
    phone         TEXT,
    hospital_id   UUID REFERENCES hospitals(id),
    status        TEXT NOT NULL DEFAULT 'DRAFT',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by    UUID REFERENCES users(id),
    updated_by    UUID REFERENCES users(id),
    deleted_at    TIMESTAMPTZ,
    deleted_by    UUID REFERENCES users(id),
    is_deleted    BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_patients_hospital_id ON patients (hospital_id);
CREATE INDEX IF NOT EXISTS idx_patients_status      ON patients (status);
CREATE INDEX IF NOT EXISTS idx_patients_created_at  ON patients (created_at);

-- === DOWN (manual rollback) =================================================
-- DROP TABLE IF EXISTS patients;
```

## CI Validation (Appendix M)

The pipeline validates: static analysis, migration validation, RLS validation,
and Edge Function build before any deployment. Deployment is blocked until the
§62 Backend Validation Checklist passes:

- [ ] Migration tested
- [ ] RLS enabled
- [ ] Policies validated
- [ ] Edge Functions tested
- [ ] Storage secured
- [ ] Audit logging enabled
- [ ] Background jobs configured
- [ ] PowerSync synchronization verified
- [ ] Conflict resolution tested
- [ ] Realtime subscriptions optimized

## Related

- Reference DDL: [`patients.sql`](./patients.sql), [`hospitals.sql`](./hospitals.sql),
  [`treatments.sql`](./treatments.sql), [`approvals.sql`](./approvals.sql)
- RLS: [`rls/`](./rls)
