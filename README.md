# Helpster Care

> Enterprise-grade, offline-first patient case management platform for
> humanitarian and charitable healthcare organizations.

Helpster Care enables volunteers, case managers, doctors, and administrators to
manage patient cases from registration to recovery — securely, transparently,
and even in areas with unreliable internet connectivity.

The repository is governed by [`AGENTS.md`](./AGENTS.md), the authoritative
Engineering Constitution & AI Development Contract. **Read it before writing any
code.**

---

## Tech Stack

| Layer | Technology |
| --- | --- |
| Frontend | Flutter 3.35+, Dart 3.9+, Material 3 |
| State | Riverpod 3, Flutter Hooks |
| Navigation | Go Router |
| Modelling | Freezed, json_serializable |
| Local / Offline | Drift, PowerSync |
| Backend | Supabase (Auth, PostgreSQL, Storage, Realtime, Edge Functions) |
| Database | PostgreSQL (single source of truth) |
| Security | RBAC + ReBAC + Row-Level Security (RLS) |
| CI/CD | GitHub Actions |

---

## Architecture

Clean Architecture with a **feature-first** organization and an
**offline-first** execution model. Dependencies always point downward:

```
Presentation → Controller → Repository → Datasource → Supabase → PostgreSQL
```

- Widgets render state only — no business logic, SQL, or direct Supabase calls.
- Repositories are the only public interface to data.
- PostgreSQL (via Supabase) is the single source of truth; PowerSync keeps
  synchronized local replicas.

See [`docs/architecture`](./docs/architecture) and the ADRs in
[`docs/adr`](./docs/adr).

---

## Repository Structure

```
helpster_care/
├── lib/
│   ├── app/                     # App bootstrap, router, theme, localization
│   │   ├── router/
│   │   ├── theme/
│   │   └── localization/
│   ├── core/                    # Cross-cutting concerns (framework-agnostic)
│   │   ├── config/  constants/  environment/  error/  exceptions/
│   │   ├── logging/ network/    security/     utils/  extensions/
│   │   ├── mixins/  typedefs/
│   ├── shared/                  # Reusable widgets, models, services
│   │   ├── widgets/ models/ services/ providers/ repositories/
│   ├── features/                # Feature-first modules (each self-contained)
│   │   ├── authentication/
│   │   ├── dashboard/
│   │   ├── patients/
│   │   ├── patient_timeline/
│   │   ├── treatments/
│   │   ├── hospitals/
│   │   ├── doctors/
│   │   ├── approvals/
│   │   ├── documents/
│   │   ├── notifications/
│   │   ├── reports/
│   │   ├── audit/
│   │   ├── settings/
│   │   └── analytics/
│   ├── l10n/                    # Localization ARB files (en, bn, …)
│   └── main.dart                # Application entry point
├── supabase/
│   ├── migrations/              # Chronological SQL migrations
│   ├── functions/               # Edge Functions (privileged operations)
│   ├── policies/                # RLS policy definitions
│   ├── seed/                    # Seed data (roles, permissions, lookups)
│   ├── tests/                   # Database / RLS tests
│   └── config.toml              # Supabase project configuration
├── powersync/                   # PowerSync sync-rules configuration
├── test/                        # unit / widget / integration / golden tests
├── integration_test/            # Flutter end-to-end tests
├── docs/                        # architecture, ADRs, API, runbooks
├── .github/workflows/           # CI/CD pipelines
├── assets/                      # images, icons, svg, fonts
├── pubspec.yaml                 # Protected — dependencies
├── analysis_options.yaml        # Protected — lints (warnings = errors)
├── AGENTS.md                    # Protected — engineering contract
└── README.md                    # Protected — this file
```

Every feature owns its `controllers/`, `datasources/`, `models/`, `providers/`,
`repositories/`, `routes/`, `screens/`, `services/`, `states/`, `validators/`,
and `widgets/` folders, plus a feature-level `README.md`.

---

## Getting Started

```bash
# 1. Install dependencies
flutter pub get

# 2. Configure environment
cp .env.example .env   # then fill in Supabase / PowerSync values

# 3. Generate code (Freezed, json_serializable, Riverpod, Drift)
dart run build_runner build --delete-conflicting-outputs

# 4. Run static analysis (must be zero warnings)
flutter analyze

# 5. Run tests
flutter test

# 6. Launch the app
flutter run
```

### Backend (Supabase)

```bash
supabase start                       # local stack
supabase db reset                    # apply migrations + seed
supabase functions serve             # run Edge Functions locally
```

---

## Quality Gates

Per `AGENTS.md`, code merges only when:

- ✅ Clean Architecture layers respected (no Supabase in widgets)
- ✅ RBAC + ReBAC + RLS enforced
- ✅ Offline-first behavior preserved
- ✅ Audit logging intact
- ✅ Zero analyzer warnings, zero TODOs
- ✅ Unit coverage ≥ 85% (critical modules ≥ 95%)
- ✅ Documentation updated

---

## License

MIT © Dr. Tapash Paul
