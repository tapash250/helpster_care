# Testing Playbook

> Reference: `AGENTS.md` §174–§177, Appendix K.

## Testing Pyramid

```
Unit Tests → Widget Tests → Integration Tests → End-to-End Tests
```

Favor many unit tests; use integration tests for workflows.

## Coverage Targets (§175, §177)

| Scope | Target |
| --- | --- |
| Overall unit coverage | ≥ 85% |
| Critical modules | ≥ 95% |
| Analyzer warnings | 0 |
| Build success | 100% |

## What Must Have Unit Tests (§175)

Repositories · Controllers · Validators · Utilities · Business rules.

## Test Types (Appendix K)

| Type | Location | Focus |
| --- | --- | --- |
| Unit | `test/unit/` | Pure logic; no Flutter binding needed for repos. |
| Widget | `test/widget/` | Rendering, interaction, state widgets. |
| Golden | `test/golden/` | Visual regression (`golden_toolkit`). |
| Integration | `integration_test/` | End-to-end workflows on device/emulator. |
| Helpers | `test/helpers/` | Fakes, fixtures, `ProviderContainer` builders. |

## Required Integration Workflows (§176)

Authentication · Patient Registration · Hospital Assignment · Approval Workflow ·
Treatment Updates · Document Upload · Offline Sync · Discharge.

## Commands

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test                    # unit + widget + golden
flutter test integration_test   # e2e
flutter test --coverage         # coverage report -> coverage/lcov.info
```

## PowerSync / Edge Function / Database Testing

- **PowerSync:** simulate offline, enqueue operations, reconnect, assert
  convergence and conflict handling.
- **Edge Functions:** test auth, permission checks, validation, audit writes,
  and typed error codes.
- **Database:** test constraints, RLS policies (positive + negative), and
  helper functions with different role/assignment fixtures.

## Definition of Test Completion

Every feature ships with unit + widget tests, relevant integration coverage,
zero analyzer warnings, and updated docs (§173 Definition of Done).
