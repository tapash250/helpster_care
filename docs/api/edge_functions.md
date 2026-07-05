# API — Edge Functions Reference

> Reference: `AGENTS.md` §46–§48, Appendix D.

All privileged operations are performed by Supabase **Edge Functions**. Flutter
never performs privileged business logic directly. Every function authenticates
the user, validates the JWT, verifies permissions, validates inputs, executes
business logic, writes an audit log, and returns a typed response.

## Base URL

```
https://<project-ref>.supabase.co/functions/v1/<function-name>
```

All requests require `Authorization: Bearer <jwt>`.

## Standard Envelope (§48)

Success:

```json
{ "success": true, "data": {}, "message": "", "error": null }
```

Failure:

```json
{ "success": false, "data": null, "message": "Validation failed", "error": { "code": "PATIENT_NOT_FOUND" } }
```

Internal SQL errors are **never** exposed.

## Function Index

| Function | Route | Permission | Docs |
| --- | --- | --- | --- |
| `createPatient` | `create-patient` | `patient.create` | [create_patient](../edge-functions/create_patient.md) |
| `approvePatient` | `approve-patient` | `patient.approve` | [approve_patient](../edge-functions/approve_patient.md) |
| `rejectPatient` | `reject-patient` | `patient.reject` | — |
| `assignHospital` | `assign-hospital` | `hospital.assign` | [assign_hospital](../edge-functions/assign_hospital.md) |
| `assignDoctor` | `assign-doctor` | `doctor.assign` | — |
| `assignVolunteer` | `assign-volunteer` | `patient.assign` | — |
| `createOTSchedule` | `create-ot-schedule` | `patient.update` | [create_ot_schedule](../edge-functions/create_ot_schedule.md) |
| `uploadMedicalDocument` | `upload-medical-document` | `document.upload` | [upload_document](../edge-functions/upload_document.md) |
| `exportPatientPDF` | `export-patient-pdf` | `patient.export` | — |
| `generateDashboard` | `generate-dashboard` | `dashboard.view` | [dashboard_statistics](../edge-functions/dashboard_statistics.md) |
| `sendPushNotification` | `send-push-notification` | `notification.send` | — |
| `compressImages` | `compress-images` | (system) | — |
| `dailyAnalytics` | `daily-analytics` | (scheduled) | — |

Implementations live in [`/supabase/functions/`](../../supabase/functions).

## Conventions

- Typed request/response DTOs; never trust client input, always re-validate.
- Multi-table writes run inside a transaction (§45).
- Every mutating function writes to `audit_logs` and, where relevant,
  `activity_timeline` and `notifications`.
