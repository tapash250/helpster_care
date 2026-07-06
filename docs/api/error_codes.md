# API — Error Catalogue

> Reference: `AGENTS.md` §48, Appendix J.

Every API error carries a stable `code`, an HTTP status, a description, a
user-facing message, developer notes, and a retry strategy. Internal SQL errors
are never surfaced.

## Envelope

```json
{ "success": false, "data": null, "message": "<user message>", "error": { "code": "<CODE>" } }
```

## Catalogue

| Code | HTTP | Description | User Message | Retry |
| --- | --- | --- | --- | --- |
| `PATIENT_NOT_FOUND` | 404 | Patient id does not exist / not accessible. | "Patient not found." | No |
| `HOSPITAL_NOT_FOUND` | 404 | Hospital id invalid. | "Hospital not found." | No |
| `INVALID_ASSIGNMENT` | 403 | User not scoped to the resource. | "You are not assigned to this resource." | No |
| `PERMISSION_DENIED` | 403 | Missing required permission. | "You don't have permission to do this." | No |
| `DOCUMENT_TOO_LARGE` | 413 | File exceeds size budget. | "File is too large." | No |
| `UNSUPPORTED_MEDIA_TYPE` | 415 | Disallowed MIME type. | "Unsupported file type." | No |
| `SYNC_CONFLICT` | 409 | Synchronization conflict detected. | "This record changed elsewhere. Please review." | Manual |
| `OT_ALREADY_BOOKED` | 409 | Theatre slot overlaps another booking. | "That OT slot is already booked." | No |
| `PATIENT_ALREADY_ADMITTED` | 409 | Patient already admitted. | "Patient is already admitted." | No |
| `INVALID_WORKFLOW_STATE` | 409 | Transition not allowed from current state. | "This action isn't allowed right now." | No |
| `DUPLICATE_PATIENT` | 409 | Duplicate national id in hospital. | "A patient with this ID already exists." | No |
| `VALIDATION_FAILED` | 422 | Input failed validation. | "Please check the form and try again." | No |
| `RATE_LIMITED` | 429 | Too many requests. | "Please wait and try again." | Backoff |
| `INTERNAL_ERROR` | 500 | Unexpected server error (details logged, not exposed). | "Something went wrong. Please try again." | Backoff |

## Retry Guidance

- **No** — client bug or authorization issue; do not auto-retry.
- **Backoff** — transient; retry with exponential backoff (offline queue).
- **Manual** — user must resolve (e.g., sync conflict).

## Client Mapping

Map codes to Riverpod async states: `PERMISSION_DENIED → PermissionDenied`,
`SYNC_CONFLICT → Conflict`, network failures → `Offline`, everything else →
`Error` (§27).
