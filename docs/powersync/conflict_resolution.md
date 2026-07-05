# Conflict Resolution

> Reference: `AGENTS.md` §56, Appendix G.

## Golden Rule

> **Newest timestamp is NOT always correct.**

Blind last-write-wins can destroy clinically important data.

## Strategy Order

1. **Business-specific merge** (preferred) — merge non-conflicting fields;
   apply domain rules (e.g., append progress notes rather than overwrite).
2. **Server wins** (fallback) — when a safe merge is not possible, the
   server (source of truth) prevails.

## Non-Negotiable Rules

- **Never silently discard user data.**
- **Record every conflict** (who, what, when, both values).
- **Notify users** when manual resolution is required.

## Example: Merge vs Server-Wins

| Field | Strategy |
| --- | --- |
| `progress_notes` (append-only) | Business merge — union both sides chronologically. |
| `status` (state machine) | Server wins — transitions validated by Edge Functions. |
| `phone` (simple scalar) | Server wins unless local edit is newer *and* server unchanged. |

## Recording Conflicts

Persist a conflict record (local value, server value, entity, field, timestamps,
resolution) so it can be audited and, if needed, resolved manually. Surface a
`Conflict Detected` state to the user (§27, §135).

## Workflow State Conflicts

Workflow transitions are decided exclusively by Edge Functions (§84). If a local
transition conflicts with the server, the server state is authoritative and the
user is notified to retry from the current valid state
(`INVALID_WORKFLOW_STATE`).
