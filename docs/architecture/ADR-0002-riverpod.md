# ADR-0002 — Riverpod 3 as the Sole State Management Solution

- **Status:** Accepted
- **Date:** 2026-07-02
- **Decision Makers:** Dr. Tapash Paul (Owner), Engineering
- **References:** `AGENTS.md` §23–§27, Appendix F

## Context

Consistent, testable state management is required across all features. Mixing
paradigms increases cognitive load and makes AI-assisted contributions
inconsistent.

## Problem Statement

Multiple competing state solutions (Bloc, Provider, GetX, etc.) would fragment
the codebase and blur the controller/repository boundary.

## Decision

Use **Riverpod 3 exclusively**. The following are **forbidden**: the `provider`
package, Bloc, Cubit, MobX, Redux, GetX, and stateful global singletons.

Recommended pattern:

```
UI → Notifier (Controller) → Repository → Datasource → PowerSync → Supabase
```

- Controllers coordinate. Repositories retrieve. Datasources communicate.
  Widgets display.
- Each feature exposes `providers/`, `controllers/`, and `states/`.
- **Repositories must NOT expose Riverpod** — they remain framework-independent.

## Async State Contract

Every async request exposes: `Loading`, `Success`, `Error`, `Refreshing`,
`Offline`, `Conflict`, `PermissionDenied`, `SynchronizationPending`.
Background synchronization must never be hidden from the user.

## Alternatives Considered

1. **Bloc/Cubit** — rejected; more boilerplate, weaker DI story for this design.
2. **Provider (legacy)** — rejected; superseded by Riverpod, weaker compile-time
   safety.
3. **GetX** — rejected; encourages global singletons and hidden behavior.

## Consequences

**Positive:** compile-safe DI, easy testing/overrides, consistent patterns.

**Negative:** team must standardize on Riverpod 3 idioms (AsyncNotifier,
codegen); learning curve for contributors new to Riverpod.

## Migration Plan

Greenfield. Use the templates in `AGENTS.md` Appendix F and
[`docs/riverpod/`](../riverpod). `riverpod_generator` produces provider code via
`build_runner`.

## Implementation Notes

- Prefer `AutoDispose` providers to avoid leaks.
- Immutable state objects (Freezed); never store UI widgets in state.
