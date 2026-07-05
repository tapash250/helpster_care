# Edge Function — `create_ot_schedule` (`createOTSchedule`)

> Reference: `AGENTS.md` §46, §100, Appendix D.

Books an operating theatre slot for a surgery. **Double booking must never
occur** — enforced by a database exclusion constraint and re-validated here.

## Contract

| Field | Value |
| --- | --- |
| Route | `POST /functions/v1/create-ot-schedule` |
| Auth | Supabase JWT required |
| Permission | `patient.update` + hospital scope |

## Request Schema

```json
{
  "operating_theatre_id": "uuid (required)",
  "patient_id": "uuid (required)",
  "surgery_id": "uuid?",
  "procedure": "string",
  "primary_surgeon_id": "uuid",
  "assistant_surgeon_id": "uuid?",
  "anaesthetist_id": "uuid?",
  "scheduled_start": "ISO-8601 (required)",
  "scheduled_end": "ISO-8601 (required)"
}
```

## Processing Steps

1. Authenticate & validate JWT.
2. Verify permission and `can_access_patient` / `can_access_hospital`.
3. Validate time range (`start < end`) and staff availability.
4. Check for overlapping bookings in the same theatre.
5. **Transaction:**
   - Insert `ot_schedules` (status `SCHEDULED`). The DB exclusion constraint
     `no_ot_double_booking` guarantees no overlap.
   - Insert `activity_timeline` event (`Surgery Scheduled`).
   - Insert `audit_logs` entry.
   - Enqueue notification.
6. Return typed response.

## Success Response

```json
{ "success": true, "data": { "ot_schedule_id": "uuid", "status": "SCHEDULED" }, "message": "OT scheduled", "error": null }
```

## Error Codes

| Code | HTTP | Meaning |
| --- | --- | --- |
| `OT_ALREADY_BOOKED` | 409 | Overlapping slot in theatre |
| `INVALID_TIME_RANGE` | 422 | `start >= end` |
| `PERMISSION_DENIED` | 403 | Missing permission / scope |
