# ADR-0004 — Hybrid Authorization: RBAC + ReBAC + RLS

- **Status:** Accepted
- **Date:** 2026-07-02
- **Decision Makers:** Dr. Tapash Paul (Owner), Security, Engineering
- **References:** `AGENTS.md` §63–§86, Appendix H, Appendix I

## Context

Healthcare data is highly sensitive (PHI). Access must be restricted both by
**what** a user can do and **which records** they may touch. A single mechanism
is insufficient.

## Problem Statement

Role checks alone leak data (e.g., a doctor seeing patients they are not
assigned to). Client-side checks are untrusted. Authorization must be enforced
in depth.

## Decision

Adopt a **hybrid authorization model**:

```
RBAC (Role-Based) + ReBAC (Resource-Based) + Supabase RLS + JWT Claims + Business Rules
```

- **Role alone is never enough to grant access.**
- **RBAC** — permissions in the format `module.action` (e.g., `patient.read`),
  stored in the database (`roles`, `permissions`, `role_permissions`,
  `user_roles`). Never hardcode permissions.
- **ReBAC** — determines *which records* via `user_hospital_assignments` and
  `patient_assignments`.
- **RLS** — every business table has SELECT/INSERT/UPDATE/DELETE policies backed
  by helper functions: `has_permission()`, `can_access_hospital()`,
  `can_access_patient()`. RLS is never disabled — even for administrators.
- **JWT** carries only lightweight identity (`sub`, `email`, `role_version`,
  `session_id`). **Permissions are never placed in the JWT** — they are loaded
  from the database to prevent stale authorization.

Authorization is enforced at multiple layers (defense in depth):

```
Flutter UI → Controller → Repository → Edge Function → Supabase RLS → PostgreSQL Constraints
```

## Alternatives Considered

1. **Pure RBAC** — rejected; cannot express per-record (hospital/patient) scope.
2. **Permissions embedded in JWT** — rejected; causes stale authorization and
   forces re-login on permission change.
3. **Application-layer authorization only** — rejected; client is untrusted and
   a single layer is never sufficient.

## Consequences

**Positive:** least privilege, zero trust, immutable audit, safe multi-tenant
hospital isolation.

**Negative:** more complex policy authoring; requires helper functions and
thorough RLS testing before every deploy (`AGENTS.md` §85 checklist).

## Migration Plan

Greenfield. Ship RLS policies with every table migration. Document each policy
in [`docs/database/rls/`](../database/rls) and each permission in
[`docs/permissions/`](../permissions).

## Implementation Notes

- Keep RLS policies small, composable, and reusable via helper functions.
- `patient.delete` / hospital delete are restricted to Super Admin.
