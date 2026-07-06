# Runbook — Database Failure

> Reference: `AGENTS.md` Appendix O. Structure: Symptoms · Diagnosis · Recovery ·
> Validation · Escalation.

## Symptoms

- Edge Functions return `INTERNAL_ERROR` (500) at high rate.
- Connection timeouts / "too many connections".
- Realtime and PowerSync sync stalls.
- Dashboard/analytics queries time out.

## Diagnosis

1. Check Supabase project status & database health metrics (CPU, connections,
   disk).
2. Inspect slow query log and locks.
3. Confirm whether the issue is capacity (load) or availability (outage).
4. Check recent migrations/deployments for a correlating change.

## Recovery

- **Overload:** reduce load — throttle non-critical jobs (`dailyAnalytics`,
  cache refresh), scale the instance, kill runaway queries, add missing indexes.
- **Corruption / data loss:** invoke [disaster recovery](../disaster_recovery.md)
  — restore latest verified backup or PITR to staging, validate, promote
  (RPO ≤ 15 min, RTO ≤ 2 h).
- **Bad migration:** roll back via a new corrective migration (never edit an
  applied one — §42).
- Put the app into offline/read-only mode so the PowerSync offline queue absorbs
  writes until service returns (§57).

## Validation

- Row counts and FK integrity consistent.
- RLS policies and helper functions behave correctly (positive + negative).
- Audit log continuity intact (append-only, no gaps).
- PowerSync converges; offline queue drains cleanly.

## Escalation

1. On-call engineer → 2. Backend lead → 3. Project Owner (Dr. Tapash Paul).
Security implications → follow the Security Incident Playbook (§206).
