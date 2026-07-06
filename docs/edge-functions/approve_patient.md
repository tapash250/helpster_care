# Edge Function — `approve_patient`

> Reference: `AGENTS.md` §84, §104, Appendix D.

Transitions a patient's approval workflow to `APPROVED`. Only Edge Functions may
change workflow state — Flutter must never decide workflow validity.

## Contract

| Field | Value |
| --- | --- |
| Route | `POST /functions/v1/approve-patient` |
| Auth | Supabase JWT required |
| Permission | `patient.approve` |

## Request Schema

```json
{ "approval_id": "uuid (required)", "note": "string?" }
```

## Processing Steps

1. Authenticate & validate JWT.
2. Verify permission `patient.approve` and `can_access_patient`.
3. Load approval; verify current state permits transition using
   `workflow_transitions`.
4. **Transaction:**
   - Update `approvals.current_state = 'APPROVED'`, set `reviewed_by`, `decided_at`.
   - Insert `approval_history` (from_state → APPROVED).
   - Insert `activity_timeline` event (`Approval`).
   - Insert `audit_logs` entry.
   - Enqueue notification (`Approval`).
5. Return typed response.

## Success Response

```json
{ "success": true, "data": { "approval_id": "uuid", "state": "APPROVED" }, "message": "Patient approved", "error": null }
```

## Error Codes

| Code | HTTP | Meaning |
| --- | --- | --- |
| `PERMISSION_DENIED` | 403 | Missing permission / not accessible |
| `INVALID_WORKFLOW_STATE` | 409 | Transition not allowed from current state |
| `APPROVAL_NOT_FOUND` | 404 | Unknown `approval_id` |

Every transition generates a Timeline Event, Notification, and Audit Entry.
