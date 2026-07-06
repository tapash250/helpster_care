# Contributing to Helpster Care

Thank you for contributing. Helpster Care is a long-term **enterprise healthcare
platform**, not a prototype. Every contribution must leave the codebase better
than it was found.

Before doing anything, read [`AGENTS.md`](./AGENTS.md) — it is the highest
technical authority in this repository. This guide summarizes the workflow; the
constitution is authoritative.

---

## Engineering Principles

1. Patient Safety
2. Security by Default
3. Privacy by Design
4. Offline First
5. Simplicity over Cleverness
6. Maintainability over Speed
7. Consistency over Personal Preference
8. Documentation as Code
9. Test Before Merge
10. Continuous Improvement

## Non-Negotiable Rules

- Never bypass RLS.
- Never expose PHI.
- Never hardcode secrets.
- Never trust client validation.
- Never call Supabase directly from widgets.
- Never commit failing tests.
- Never merge with analyzer warnings.
- Never disable audit logging.
- Never skip code review.
- Never ignore synchronization conflicts.

---

## Development Lifecycle

```
Understand → Analyse → Plan → Validate Architecture →
Implement → Test → Review → Document → Complete
```

Skipping any step is prohibited.

## Feature Development Playbook

Never start with UI. Always begin with the domain model.

1. Requirements
2. Architecture
3. Database Design
4. RLS Design
5. Repository
6. PowerSync
7. Controllers
8. UI
9. Testing
10. Documentation
11. Review
12. Deployment

---

## Branch Strategy

```
main        # protected; never commit directly
develop
feature/*
bugfix/*
hotfix/*
release/*
```

## Commit Convention

Use Conventional Commits:

```
feat:     fix:      refactor:  docs:   test:
perf:     security: build:     ci:     chore:
```

Example:

```
feat(patient): implement patient assignment workflow
```

## Pull Requests

Every PR must include:

- Purpose
- Screenshots (if UI)
- Testing Notes
- Migration Notes
- Security Impact
- Breaking Changes
- Checklist

No undocumented PRs.

---

## Definition of Done

A task is complete only when:

- [ ] Code implemented
- [ ] Architecture respected
- [ ] Tests passing
- [ ] RLS verified
- [ ] Offline verified
- [ ] Documentation updated
- [ ] No analyzer warnings
- [ ] No TODOs
- [ ] Code reviewed
- [ ] Approved

## Local Quality Gate

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

All three must pass before you open a PR.

---

## Code Style

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables / methods: `camelCase` (methods begin with a verb)
- No hardcoded colors, sizes, or spacing — use theme tokens.
- Widgets < 300 lines; methods 20–40 lines (max 80); classes ≤ 300 lines (max 500).
- Prefer `final` / `const`; prefer immutable objects.
- Comment **why**, not **what**.

Thank you for helping build a safe, reliable platform for patients in need.
