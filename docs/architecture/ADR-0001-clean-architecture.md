# ADR-0001 — Adopt Clean Architecture (Feature-First, Offline-First)

- **Status:** Accepted
- **Date:** 2026-07-02
- **Decision Makers:** Dr. Tapash Paul (Owner), Engineering
- **References:** `AGENTS.md` §14–§19, §36

## Context

Helpster Care is a long-term enterprise healthcare platform that must remain
maintainable for 10+ years, protect patient safety, and continue functioning
without reliable internet connectivity. The codebase will be worked on by
multiple humans and AI assistants, so architectural boundaries must be explicit
and enforceable.

## Problem Statement

Without strict layering, business rules leak into widgets, data access spreads
uncontrolled, and features become tightly coupled — making the system unsafe to
change and impossible to test.

## Decision

Adopt **Clean Architecture** with a **feature-first** organization and an
**offline-first** execution model.

Layer responsibilities and dependency direction:

```
Presentation → Controller → Repository → Datasource → PostgreSQL (source of truth)
```

- **Presentation** renders state and captures input. No SQL, HTTP, Supabase
  calls, business rules, or permission evaluation.
- **Controller** (Riverpod Notifier) coordinates use cases; stays thin.
- **Repository** is the *only* public interface to data; merges local + remote,
  handles caching and synchronization, returns domain models.
- **Datasource** (local: Drift/PowerSync, remote: Supabase/Edge/Storage) contains
  no business rules.
- **Database** owns persistence, RLS, triggers, constraints.

Dependencies always point **downward**. Reverse dependencies are prohibited.

Each feature lives under `lib/features/<feature>/` and owns: `controllers`,
`datasources/{local,remote}`, `models`, `providers`, `repositories`, `routes`,
`screens`, `services`, `states`, `validators`, `widgets`, plus a `README.md`.

## Alternatives Considered

1. **Layer-first (technical) folders** — rejected; scatters a single feature
   across the tree and encourages cross-feature coupling.
2. **MVC / MVVM without a repository boundary** — rejected; permits direct
   database access from presentation and breaks offline-first.
3. **Online-only architecture** — rejected; violates the offline-first mandate.

## Consequences

**Positive:** testable layers, enforceable boundaries, feature isolation,
offline-first by construction, safe for AI-assisted contributions.

**Negative:** more boilerplate per feature; requires discipline and code review
to keep controllers thin and widgets logic-free.

## Migration Plan

Greenfield. All new features follow the standard feature structure from day one.
The Architecture Validation Checklist (`AGENTS.md` §36) blocks any merge that
violates the layering.

## Implementation Notes

- Repositories must remain framework-independent (no Riverpod imports).
- Validate boundaries in code review using the §36 checklist.
