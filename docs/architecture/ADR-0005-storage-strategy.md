# ADR-0005 — Supabase Storage Strategy for Medical Documents

- **Status:** Accepted
- **Date:** 2026-07-02
- **Decision Makers:** Dr. Tapash Paul (Owner), Security, Engineering
- **References:** `AGENTS.md` §49–§51, §79, §197, §141

## Context

Patients accumulate medical documents (prescriptions, lab reports, imaging,
bills, consent forms, clinical photographs). These are large binaries and PHI.

## Problem Statement

Storing binaries in PostgreSQL bloats the database and harms performance.
Public URLs would expose PHI. Files must be secured and access-controlled the
same way records are.

## Decision

Store binaries in **Supabase Storage**; store only **metadata** in PostgreSQL
(checksum, storage path, size, type, URL reference).

### Buckets & Privacy

| Bucket | Privacy |
| --- | --- |
| `patients` | Private |
| `avatars` | Authenticated |
| `hospital_documents` | Private |
| `reports` | Private |
| `exports` | Temporary signed URLs |
| `system` | Private |

- **Never use public buckets for PHI / medical records.**
- Access requires: Authentication + Permission + Patient Assignment +
  Hospital Assignment + **signed URL**. Never expose permanent URLs.

### Folder Structure

```
patients/PAT000001/{prescriptions,lab,ct,mri,xray,bills,consent,discharge}/
```

Prefer immutable UUID filenames over user-generated names.

### Upload Pipeline

Before upload: validate MIME type, validate size, compress images, generate
thumbnails, calculate checksum (virus scan — future). Never trust file
extensions. Only document **metadata** synchronizes via PowerSync; the binary is
downloaded on demand.

## Alternatives Considered

1. **BYTEA / large objects in PostgreSQL** — rejected; DB bloat, poor perf,
   expensive backups.
2. **Public storage buckets** — rejected; exposes PHI, violates §79/§80.
3. **Third-party object store (S3 direct)** — rejected; duplicates Supabase
   Storage and complicates signed-URL auth integration.

## Consequences

**Positive:** lean database, PHI-safe access via signed URLs, offline-friendly
(metadata syncs, binaries on demand).

**Negative:** signed-URL lifecycle management and scheduled cleanup of expired
URLs (`AGENTS.md` §53); upload pipeline complexity.

## Migration Plan

Greenfield. Create buckets with correct privacy on provisioning; enforce access
through Edge Functions (`uploadMedicalDocument`) and Storage RLS.

## Implementation Notes

- Signed URLs are short-lived; regenerate on demand.
- Document RLS for storage in [`docs/database/rls/documents.sql`](../database/rls/documents.sql).
