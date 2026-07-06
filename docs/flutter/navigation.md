# Navigation

> Reference: `AGENTS.md` §28–§30.

Navigation uses **Go Router exclusively**.

## Forbidden

- `Navigator.push()`
- `Navigator.popUntil()`
- Anonymous routes
- Magic route strings

## Route Naming (§29)

Every route has a constant — avoid hardcoded paths:

```dart
class DashboardRoute { static const path = '/dashboard'; static const name = 'dashboard'; }
class PatientsRoute { static const path = '/patients'; static const name = 'patients'; }
class PatientDetailsRoute { static const path = '/patients/:id'; static const name = 'patientDetails'; }
class HospitalRoute { static const path = '/hospitals'; static const name = 'hospitals'; }
class ReportsRoute { static const path = '/reports'; static const name = 'reports'; }
class SettingsRoute { static const path = '/settings'; static const name = 'settings'; }
```

Each feature declares its routes under `lib/features/<feature>/routes/`. The
aggregate `GoRouter` is configured in `lib/app/router/`.

## Navigation Rules (§30)

- Navigation must **never** contain business logic.
- Navigation decisions belong inside **controllers**.
- **Authentication redirects** belong inside **router guards** (`redirect`).
- **Permission redirects** belong inside **router guards**.

## Example Router Skeleton

```dart
final router = GoRouter(
  initialLocation: DashboardRoute.path,
  redirect: (context, state) {
    // Auth + permission guards live here — not in widgets.
    return null;
  },
  routes: [
    GoRoute(
      path: DashboardRoute.path,
      name: DashboardRoute.name,
      builder: (context, state) => const DashboardScreen(),
    ),
    // ... feature routes composed from each feature's routes/ folder
  ],
);
```

Guards should use the resolved permission set (loaded from the database, never
from JWT claims — see [ADR-0004](../architecture/ADR-0004-rbac-rebac.md)).
