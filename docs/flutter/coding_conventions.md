# Flutter Coding Conventions

> Reference: `AGENTS.md` §113, §145–§164, Appendix E.

Flutter is the **presentation** framework only. It never owns business logic,
permissions, synchronization, or security.

## Naming

| Kind | Convention | Example |
| --- | --- | --- |
| File | `snake_case.dart` | `patient_repository.dart` |
| Class | `PascalCase` | `PatientController` |
| Variable | `camelCase` | `selectedHospital` |
| Constant | `camelCase` | `defaultPageSize` |
| Method | `verbFirst()` | `loadPatients()` |

Avoid abbreviations (`pt`, `usr`, `obj`). Never use `ALL_CAPS` or PascalCase
filenames.

## Size Budgets

| Unit | Recommended | Maximum |
| --- | --- | --- |
| Method | 20–40 lines | 80 |
| Class | ≤ 300 lines | 500 |
| Widget | < 300 lines | — |

Extract dialogs, cards, forms, sections, tables, and timeline widgets early.

## Dart Rules

- Enable `analysis_options.yaml`; **treat warnings as errors**.
- Prefer `final` / `const`; use `late` / `required` appropriately.
- Prefer immutable objects; avoid mutable global state.

## Error Handling (§162)

Never swallow exceptions (`catch (_) {}`). Every failure must be intentional:
Handle → Log → Recover → Notify. Use domain-specific exceptions
(`PatientNotFoundException`, `PermissionDeniedException`, …), not generic
`Exception`.

## Logging (§163)

Structured logs only. Include timestamp, feature, operation, duration, result,
correlation id. **Never log** passwords, tokens, PHI, personal identifiers, or
medical records.

## Comments (§160)

Comment **why**, not **what**. Prefer self-documenting code. Public classes and
methods carry doc comments (purpose, params, returns, throws, side effects).

## Forbidden in Presentation (§16, §19)

SQL · HTTP · Supabase queries · business rules · permission evaluation · file
uploads · database transactions. All data access goes through repositories.
