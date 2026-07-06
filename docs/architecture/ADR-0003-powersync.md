# ADR-0003 — PowerSync for Offline-First Synchronization

- **Status:** Accepted
- **Date:** 2026-07-02
- **Decision Makers:** Dr. Tapash Paul (Owner), Engineering
- **References:** `AGENTS.md` §54–§57, Appendix G

## Context

Helpster Care operates in areas with unreliable connectivity. Critical
workflows (registration, treatment updates, assignments) must work offline and
synchronize automatically when connectivity returns.

## Problem Statement

A naive online-only client fails in the field. A hand-rolled sync engine is
error-prone and risks silent data loss.

## Decision

Adopt **PowerSync** to maintain local replicas synchronized with Supabase
PostgreSQL.

- **Supabase PostgreSQL remains the single source of truth.** Flutter never
  becomes the source of truth.
- Flutter communicates primarily with the **local database**; synchronization
  happens automatically in the background.
- **Synchronize:** patients, treatments, hospitals, assignments, notifications,
  timeline, document metadata, audit references.
- **Do NOT auto-synchronize large binary files** — download them on demand.

## Conflict Resolution

- Newest timestamp is **not** always correct.
- Prefer a **business-specific merge**; otherwise **server wins**.
- Never silently discard user data. Record every conflict and notify users when
  manual resolution is required.

## Offline Queue

Offline operations (create patient, update treatment, upload notes/documents,
assignments, permitted approvals) are queued. The queue must survive app
restarts and retry automatically.

## Alternatives Considered

1. **Custom sync layer over Supabase Realtime** — rejected; high risk, high
   maintenance, weak conflict handling.
2. **Drift-only local cache without server sync** — rejected; no reliable
   convergence to the source of truth.
3. **Firebase / Firestore offline** — rejected; conflicts with the Supabase +
   PostgreSQL + RLS decision.

## Consequences

**Positive:** robust offline-first UX, automatic sync, clear ownership model.

**Negative:** additional infrastructure (PowerSync service) and sync rules to
maintain; requires careful sync-rule authoring to respect RLS scope.

## Migration Plan

Greenfield. Define PowerSync sync rules alongside each table's RLS policy so the
synchronized replica never exceeds the user's authorized scope.

## Implementation Notes

- Sync rules must mirror RLS scope (hospital/patient assignment).
- Surface sync status in the UI (`Offline`, `Sync Pending`, `Synchronizing`,
  `Conflict Detected`).
