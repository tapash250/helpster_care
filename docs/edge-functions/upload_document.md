# Edge Function — `upload_document` (`uploadMedicalDocument`)

> Reference: `AGENTS.md` §49–§51, §79, §101, ADR-0005, Appendix D.

Handles secure upload of a medical document: validates the file, stores the
binary in a private Storage bucket, and records only metadata in PostgreSQL.

## Contract

| Field | Value |
| --- | --- |
| Route | `POST /functions/v1/upload-medical-document` |
| Auth | Supabase JWT required |
| Permission | `document.upload` |

## Request Schema (multipart or signed-upload flow)

```json
{
  "patient_id": "uuid (required)",
  "category": "PRESCRIPTION | LAB | CT | MRI | XRAY | BILL | CONSENT | DISCHARGE | PHOTO",
  "file": "binary (validated)",
  "mime_type": "string",
  "size_bytes": "int"
}
```

## Processing Steps (§51)

1. Authenticate & validate JWT.
2. Verify `document.upload` and `can_access_patient`.
3. Validate MIME type (never trust the extension) and file size.
4. Compress images; generate thumbnail; calculate checksum.
5. Store binary at `patients/PAT000001/<category>/<uuid>.<ext>` (private bucket).
6. **Transaction:**
   - Insert `documents` metadata (path, checksum, size, type, category).
   - Insert `activity_timeline` event (`Document Uploaded`).
   - Insert `audit_logs` entry.
7. Return metadata + short-lived signed URL.

## Success Response

```json
{ "success": true, "data": { "document_id": "uuid", "signed_url": "https://...", "expires_in": 900 }, "message": "Document uploaded", "error": null }
```

## Error Codes

| Code | HTTP | Meaning |
| --- | --- | --- |
| `PERMISSION_DENIED` | 403 | Missing permission / scope |
| `DOCUMENT_TOO_LARGE` | 413 | Exceeds size budget |
| `UNSUPPORTED_MEDIA_TYPE` | 415 | Disallowed MIME type |
| `VALIDATION_FAILED` | 422 | Bad metadata |

Never store PHI in public buckets. Never expose permanent URLs.
