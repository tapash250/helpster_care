# Riverpod Feature Template

> Reference: `AGENTS.md` §18, §23–§26, Appendix F.

The canonical skeleton for a new feature. Copy this layout under
`lib/features/<feature>/`.

```
<feature>/
├── controllers/     # Riverpod Notifiers / AsyncNotifiers (thin coordination)
├── datasources/
│   ├── local/       # Drift / PowerSync
│   └── remote/      # Supabase / Edge Functions / Storage
├── models/          # Freezed immutable domain models
├── providers/       # Provider declarations & DI
├── repositories/    # Sole public data interface (framework-independent)
├── routes/          # Go Router route constants + builders
├── screens/         # Presentation (renders state only)
├── services/        # Feature-scoped domain services
├── states/          # Immutable state objects
├── validators/      # Client-side validation
├── widgets/         # Reusable widgets (< 300 lines)
└── README.md
```

## Layer Flow (§25)

```
UI → Notifier → Repository → Datasource → PowerSync → Supabase
```

Controllers coordinate · Repositories retrieve · Datasources communicate ·
Widgets display.

## State Example (§26)

```dart
@freezed
class PatientState with _$PatientState {
  const factory PatientState({
    @Default([]) List<Patient> patients,
    @Default(false) bool loading,
    @Default(false) bool saving,
    @Default(false) bool syncing,
    Patient? selectedPatient,
    Object? error,
    DateTime? lastUpdated,
  }) = _PatientState;
}
```

State objects never contain UI widgets.

## Rules

- Repositories must **not** import Riverpod.
- Every async request exposes Loading / Success / Error / Refreshing / Offline /
  Conflict / PermissionDenied / SynchronizationPending (§27).
- Prefer `AutoDispose` providers; do not hide background sync.
