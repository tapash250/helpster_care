# Runbook — Edge Function Failure

> Reference: `AGENTS.md` §46–§48, Appendix O.

## Symptoms

- Privileged operations fail (create/approve patient, assign hospital, upload).
- Elevated `INTERNAL_ERROR` (500) or timeouts from `/functions/v1/*`.
- Workflow transitions not applying; notifications/audit entries missing.

## Diagnosis

1. Check Edge Function logs (per-function) and platform status.
2. Confirm the function is deployed and on the expected version.
3. Verify environment secrets are present (service key, PowerSync URL, etc.).
4. Reproduce with a known-good request; inspect the typed error `code`.
5. Check downstream dependencies (database, storage) — the function may be fine
   while a dependency is failing.

## Recovery

- **Bad deploy:** redeploy the last known-good version of the function.
- **Missing/rotated secret:** re-set secrets (`supabase secrets set ...`) — never
  hardcode (§81); redeploy.
- **Dependency outage:** follow the relevant runbook
  ([database](./database_failure.md) / [storage](./storage_failure.md) /
  [powersync](./powersync_failure.md)); the offline queue absorbs writes (§57).
- **Validation/logic bug:** fix root cause, add a regression test (§205), ship
  through CI — never patch symptoms.

## Validation

- Function authenticates, checks permission, validates input, writes audit,
  returns typed response (§47).
- Multi-table operations remain transactional — no partial writes (§45).
- Workflow transitions produce timeline + notification + audit (§84, §104).
- No PHI or secrets in logs (§80, §163).

## Escalation

1. On-call engineer → 2. Backend lead → 3. Project Owner.
Authorization bypass or PHI exposure → Security Incident Playbook (§206),
highest priority.
