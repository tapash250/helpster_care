# Backup Strategy

> Reference: `AGENTS.md` §198, Appendix P.

## Schedule

| Frequency | Scope | Retention |
| --- | --- | --- |
| Daily | Full database + storage manifest | 30 days |
| Weekly | Full database + storage snapshot | 12 weeks |
| Monthly | Full database + storage snapshot | 12 months |
| Continuous | WAL / point-in-time recovery | Provider window (≥ 7 days) |

## What Is Backed Up

- **PostgreSQL** — full logical + physical backups; continuous WAL for PITR.
- **Supabase Storage** — patient documents, avatars, reports, exports.
- **Configuration** — migrations, RLS policies, Edge Functions (in Git).

## Verification (§198)

- Backup verification is **mandatory**.
- **Recovery testing is quarterly.**
- A backup without a successful restore test is considered **invalid**.

## Restore Procedure (summary)

1. Provision a staging instance.
2. Restore the target backup / PITR timestamp.
3. Run consistency checks (row counts, FK integrity, audit continuity).
4. Verify RLS policies and helper functions behave correctly.
5. Promote to production only after validation.

## PHI Handling

Backups may contain PHI and must be encrypted at rest and access-controlled the
same as production (§80, §81). Never copy production backups to unsecured or
public locations. Never store secrets alongside backups.

## Related

- [`disaster_recovery.md`](./disaster_recovery.md)
- [`runbooks/database_failure.md`](./runbooks/database_failure.md)
