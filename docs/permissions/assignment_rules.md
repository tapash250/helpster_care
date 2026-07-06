# Assignment Rules (ReBAC)

> Reference: `AGENTS.md` §69–§73, Appendix I.

Roles determine **what** a user can do (RBAC). ReBAC determines **which records**
they may access, via assignment tables.

## Assignment Tables

| Table | Purpose |
| --- | --- |
| `hospital_assignments` | Which hospitals a user may access (§70). |
| `patient_assignments` | Which patients a user is responsible for (§71). |

## Hospital Access Rules (§70)

| Role | Hospital scope |
| --- | --- |
| Doctor | Assigned hospitals only |
| Case Manager | Assigned hospitals only |
| Volunteer | Assigned hospitals only |
| Admin | Assigned hospitals |
| Super Admin | All hospitals |

## Patient Assignment (§71)

- Assignment types: `DOCTOR`, `VOLUNTEER`, `CASE_MANAGER`, `COORDINATOR`.
- Multiple users may be assigned to one patient.
- Assignments are **auditable** and **may change over time**.
- **Historical assignments must be preserved** (`is_active` + `unassigned_at`,
  never hard-deleted).

## Permission Resolution Chain (§73)

Every access decision evaluates, in order — and **every step must succeed**:

```
User → Active Roles → Permissions → Hospital Assignment
     → Patient Assignment → Business Rule → RLS Policy → Allow / Deny
```

## Helper Functions (Appendix I)

Implemented in SQL and used by RLS policies:

- `has_permission(permission)` — RBAC check.
- `can_access_hospital(hospital_id)` — hospital ReBAC.
- `can_access_patient(patient_id)` — patient ReBAC (assignment or admin-in-hospital).
- `assigned_doctor(patient_id)` / `assigned_case_manager(patient_id)` — resolve
  responsible staff.

See the implementations in
[`../database/rls/patients.sql`](../database/rls/patients.sql) and
[`../database/rls/hospitals.sql`](../database/rls/hospitals.sql).

## Offline

Sync rules mirror these assignment rules so a user's local replica never
contains records outside their scope (§85; see
[../powersync/synchronization.md](../powersync/synchronization.md)).
