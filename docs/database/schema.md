# Database Schema

> Canonical PostgreSQL schema for Helpster Care.
> Source of truth: `AGENTS.md` §40–§45, §184–§197, Appendix B.

Supabase PostgreSQL is the **single source of truth**. PowerSync maintains
local replicas. Flutter never becomes the source of truth.

## Mandatory Columns

Every table:

```sql
id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
created_by  UUID REFERENCES users(id),
updated_by  UUID REFERENCES users(id)
```

Soft-delete tables additionally include:

```sql
deleted_at  TIMESTAMPTZ,
deleted_by  UUID REFERENCES users(id),
is_deleted  BOOLEAN NOT NULL DEFAULT false
```

Patient data is **never permanently deleted** unless explicitly approved.

## Design Rules (§185)

Every table shall: have a UUID PK · have timestamps · have FK constraints ·
have indexes · support auditing · support RLS · use `snake_case` · be documented.

## Naming Standards (§41)

| Object | Convention | Example |
| --- | --- | --- |
| Table | `snake_case` plural | `patients`, `patient_documents` |
| Column | `snake_case` | `hospital_id` |
| Function | `snake_case()` | `has_permission()` |
| View | `vw_` | `vw_patient_summary` |
| Materialized view | `mv_` | `mv_dashboard_statistics` |
| Index | `idx_` | `idx_patients_hospital_id` |
| Constraint | `fk_` / `pk_` / `uq_` | `fk_patients_hospital` |
| Trigger | `trg_` | `trg_patients_set_updated_at` |
| Policy | `rls_` | `rls_patients_select` |

## Canonical Entities (§184)

### Identity
`users`, `roles`, `permissions`, `role_permissions`, `user_roles`, `sessions`

### Organization
`hospitals`, `departments`, `wards`, `beds`, `operating_theatres`,
`hospital_assignments`

### Patient Management
`patients`, `patient_assignments`, `patient_contacts`, `patient_addresses`,
`patient_guardians`, `patient_history`, `patient_notes`, `patient_status_history`

### Clinical
`treatments`, `conservative_treatments`, `surgical_treatments`, `surgeries`,
`ot_schedules`, `followups`, `diagnoses`, `prescriptions`

### Documents
`documents`, `document_categories`, `document_versions`, `attachments`

### Workflow
`approvals`, `approval_history`, `workflow_states`, `workflow_transitions`

### Communication
`notifications`, `notification_templates`, `emails`, `push_notifications`

### Audit
`audit_logs`, `activity_timeline`, `system_events`

### Analytics
`dashboard_cache`, `analytics_daily`, `analytics_monthly`, `statistics`

## Lookup Tables (§44)

Avoid hardcoded values; use lookup tables: `roles`, `permissions`,
`patient_status`, `approval_status`, `treatment_type`, `document_type`,
`hospital_type`, `notification_type`.

## Constraints & Integrity (§43)

Prefer database constraints over application logic: `NOT NULL`, `CHECK`,
`UNIQUE`, `FOREIGN KEY`, `ENUM`, generated columns. Database integrity always
takes precedence over client validation.

## Storage of Binaries (§197)

Large binary objects are **not** stored in PostgreSQL — only metadata
(checksum, storage path, size, type, URL reference). Files live in Supabase
Storage. See [ADR-0005](../architecture/ADR-0005-storage-strategy.md).

## Related Files

- [`er-diagram.md`](./er-diagram.md) — entity relationships.
- [`migrations.md`](./migrations.md) — migration policy.
- Reference DDL: [`patients.sql`](./patients.sql), [`hospitals.sql`](./hospitals.sql),
  [`treatments.sql`](./treatments.sql), [`approvals.sql`](./approvals.sql).
- RLS policies: [`rls/`](./rls).
