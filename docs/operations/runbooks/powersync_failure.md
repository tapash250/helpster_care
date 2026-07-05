# Runbook — PowerSync Failure

> Reference: `AGENTS.md` §54–§57, Appendix O.

## Symptoms

- Clients show persistent `Sync Pending` / `Synchronizing` without progress.
- Local changes are not appearing on the server (or vice versa).
- Rising offline-queue depth; `SYNC_CONFLICT` spikes.

## Diagnosis

1. Check PowerSync service status and logs.
2. Verify connectivity between PowerSync ↔ Supabase PostgreSQL.
3. Confirm sync rules are valid and mirror current RLS scope.
4. Check for schema drift (a migration not reflected in sync rules).
5. Inspect conflict records for a systemic cause.

## Recovery

- **Service down:** restart / restore the PowerSync service. Clients continue
  offline; the offline queue preserves writes and drains on reconnect (§57).
- **Sync-rule / schema drift:** update sync rules to match the new schema and
  RLS scope; redeploy.
- **Conflict storm:** identify the conflicting field(s); apply the
  business-specific merge or server-wins policy (§56); never discard user data;
  notify affected users.
- **Auth issues:** verify JWTs and that permissions still resolve from the DB
  (not JWT — §74).

## Validation

- New local edits sync to the server and back within expected latency.
- Offline queue depth returns to baseline.
- No records leak outside a user's authorized scope (sync rules == RLS).
- Conflict records are recorded and surfaced, not silently dropped.

## Escalation

1. On-call engineer → 2. Backend lead → 3. Project Owner.
Data-loss risk → treat as an incident and engage
[disaster recovery](../disaster_recovery.md).
