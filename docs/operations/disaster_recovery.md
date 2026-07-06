# Disaster Recovery

> Reference: `AGENTS.md` §198, §199, §206, Appendix P.

## Recovery Objectives (§199)

| Objective | Target |
| --- | --- |
| **RPO** (max data loss) | ≤ 15 minutes |
| **RTO** (max downtime) | ≤ 2 hours |

Recovery procedures shall be documented **and tested** (quarterly, §198).

## Disaster Scenarios

- Database corruption / loss
- Storage loss or corruption
- PowerSync service outage
- Edge Function platform outage
- Region-wide provider outage

## Recovery Strategy

1. **Contain** — stop writes if data integrity is at risk; put the app in a safe
   read-only / offline mode where possible.
2. **Assess impact** — determine affected entities and time window.
3. **Restore** — use the most recent verified backup or point-in-time recovery.
4. **Validate** — run consistency checks; verify audit continuity and RLS.
5. **Resume** — re-enable writes; monitor sync convergence.
6. **Post-incident** — document, audit, and prevent recurrence (§206).

## Point-in-Time Recovery (PITR)

Supabase PITR restores the PostgreSQL database to a specific timestamp within
the retention window, satisfying the RPO target. Always restore to a staging
instance first, validate, then promote.

## Business Continuity

- Offline-first design (PowerSync) keeps field operations functional during
  backend outages; the offline queue drains once service is restored (§57).
- Backups without restore verification are **invalid** (§198).

## Related Runbooks

- [`runbooks/database_failure.md`](./runbooks/database_failure.md)
- [`runbooks/storage_failure.md`](./runbooks/storage_failure.md)
- [`runbooks/powersync_failure.md`](./runbooks/powersync_failure.md)
- [`runbooks/edge_function_failure.md`](./runbooks/edge_function_failure.md)
