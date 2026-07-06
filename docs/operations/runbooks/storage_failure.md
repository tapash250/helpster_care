# Runbook — Storage Failure

> Reference: `AGENTS.md` §49–§51, §79, Appendix O.

## Symptoms

- Document uploads fail (`uploadMedicalDocument` errors).
- Signed URLs return 403/404; documents won't open.
- Thumbnails missing; `exportPatientPDF` fails.

## Diagnosis

1. Check Supabase Storage status and logs.
2. Verify bucket existence and **privacy** settings (PHI buckets must be
   private — §79).
3. Check signed-URL generation and expiry (expired URLs are expected to fail;
   regenerate on demand).
4. Confirm the upload pipeline (MIME/size validation, compression, checksum)
   is functioning.
5. Verify metadata rows in `documents` still reference valid paths.

## Recovery

- **Service outage:** queue uploads offline; the binary uploads on reconnect
  while metadata syncs immediately (§55, §57).
- **Misconfigured bucket:** restore correct privacy (never public for PHI);
  reissue signed URLs.
- **Orphaned metadata / missing object:** restore the object from
  [backup](../backup_strategy.md); if unrecoverable, flag the document and
  notify the case owner — never expose a broken/public link.
- **Corrupted upload:** re-validate checksum; request re-upload.

## Validation

- Upload → metadata row + private object + short-lived signed URL.
- Signed URLs work for authorized users and fail for unauthorized ones.
- No PHI served from a public URL; no PHI in logs (§80).

## Escalation

1. On-call engineer → 2. Backend lead → 3. Project Owner.
Any exposure of PHI → immediately follow the Security Incident Playbook (§206).
