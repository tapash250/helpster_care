# Offline Queue

> Reference: `AGENTS.md` §57, Appendix G.

Operations performed offline are **queued** and applied when connectivity
returns.

## Queued Operations (§57)

- Create patient
- Update treatment
- Upload notes
- Upload documents (metadata queued; binary uploaded on reconnect)
- Assignments
- Approvals (only if permitted for the role)

## Requirements

- **The queue must survive app restarts** (persisted locally via Drift/PowerSync).
- **Automatic retry** with backoff.
- Operations replay in a deterministic order that respects dependencies
  (e.g., a patient must exist before its documents are uploaded).

## Lifecycle

```
User action (offline)
        │
        ▼
Enqueue operation (persisted)
        │
   connectivity restored
        ▼
Replay in order → Edge Function → PostgreSQL
        │
   success? ── yes ─▶ dequeue + update local state
        │
        └── no ─▶ retry (backoff) / surface Conflict or Error
```

## Permissions Offline

Offline permissions must be respected (§85 checklist: "Offline permissions
respected"). The local replica only contains records within the user's
authorized scope (sync rules mirror RLS), so queued operations cannot exceed
that scope. Final authorization is always re-validated server-side by the Edge
Function (§47, zero trust).

## User Feedback

Show `Sync Pending` while operations are queued and `Synchronizing` during
replay. If an operation ultimately fails or conflicts, surface a clear,
actionable message — never discard the user's input silently (§56).
