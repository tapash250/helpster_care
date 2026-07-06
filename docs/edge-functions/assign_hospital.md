# Edge Function — `assign_hospital`

> Reference: `AGENTS.md` §46, §70, §94, Appendix D, Appendix I.

Assigns a patient to a hospital (and optionally reserves a bed). Enforces ReBAC
scope and preserves historical assignments.

## Contract

| Field | Value |
| --- | --- |
| Route | `POST /functions/v1/assign-hospital` |
| Auth | Supabase JWT required |
| Permission | `hospital.assign` |

## Request Schema

```json
{
  "patient_id": "uuid (required)",
  "hospital_id": "uuid (required)",
  "bed_id": "uuid?"
}
```

## Processing Steps

1. Authenticate & validate JWT.
2. Verify permission `hospital.assign`, `can_access_patient`, `can_access_hospital`.
3. Validate hospital & (optional) bed availability.
4. **Transaction:**
   - Update `patients.hospital_id`.
   - If `bed_id` provided: set `beds.status = 'RESERVED'`/`OCCUPIED`, link patient.
   - Insert `activity_timeline` event (`Hospital Assigned`).
   - Insert `audit_logs` entry.
   - Enqueue notification (`Hospital Assignment`).
5. Return typed response.

## Success Response

```json
{ "success": true, "data": { "patient_id": "uuid", "hospital_id": "uuid" }, "message": "Hospital assigned", "error": null }
```

## Error Codes

| Code | HTTP | Meaning |
| --- | --- | --- |
| `PERMISSION_DENIED` | 403 | Missing permission / scope |
| `HOSPITAL_NOT_FOUND` | 404 | Unknown hospital |
| `INVALID_ASSIGNMENT` | 403 | User not scoped to hospital |
| `BED_UNAVAILABLE` | 409 | Bed not available |
