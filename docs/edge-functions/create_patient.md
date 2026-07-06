# Edge Function — `create_patient`

> Reference: `AGENTS.md` §46–§48, §90–§91, Appendix D.

Privileged creation of a patient record and its initial timeline/audit entries.
Flutter must never perform this business logic directly.

## Contract

| Field | Value |
| --- | --- |
| Route | `POST /functions/v1/create-patient` |
| Auth | Supabase JWT (Bearer) required |
| Permission | `patient.create` |
| Idempotency | Duplicate check on `national_id` + hospital |

## Request Schema

```json
{
  "full_name": "string (required)",
  "national_id": "string?",
  "date_of_birth": "YYYY-MM-DD?",
  "gender": "MALE | FEMALE | OTHER?",
  "blood_group": "string?",
  "hospital_id": "uuid (required)",
  "guardian": { "full_name": "string", "phone": "string" }
}
```

## Processing Steps (§47)

1. Authenticate user & validate JWT.
2. Verify permission `patient.create`.
3. Validate inputs (types, required fields, hospital exists).
4. Duplicate check (national_id within hospital).
5. Validate hospital assignment / ReBAC scope.
6. **Transaction (§45):**
   - Generate human-readable `patient_id` (`PAT-2026-000001`) — backend only.
   - Insert `patients` row.
   - Insert initial `activity_timeline` event (`Registered`).
   - Insert `audit_logs` entry (action=`CREATE`, entity=`patient`).
7. Queue synchronization (PowerSync).
8. Return typed response.

## Success Response (§48)

```json
{ "success": true, "data": { "id": "uuid", "patient_id": "PAT-2026-000001" }, "message": "Patient created", "error": null }
```

## Error Codes

| Code | HTTP | Meaning |
| --- | --- | --- |
| `PERMISSION_DENIED` | 403 | Missing `patient.create` |
| `HOSPITAL_NOT_FOUND` | 404 | `hospital_id` invalid |
| `INVALID_ASSIGNMENT` | 403 | User not assigned to hospital |
| `VALIDATION_FAILED` | 422 | Bad/missing fields |
| `DUPLICATE_PATIENT` | 409 | Same national_id in hospital |

Internal SQL errors are never exposed.
