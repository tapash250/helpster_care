# Widgets

> Reference: `AGENTS.md` §21, §22, §31, §121–§135, §143, §159.

## Widget Design Rules

Widgets must be **reusable, composable, small, testable, focused**, and
stateless whenever possible. One responsibility per widget. Prefer composition
over inheritance. Avoid deeply nested trees. Keep widgets **< 300 lines** and
extract repeated UI immediately.

## Shared Components (§31)

Reusable widgets live in `lib/shared/widgets/`:

`LoadingIndicator`, `PermissionGate`, `OfflineBanner`, `AppCard`, `SearchBar`,
`PrimaryButton`, `Avatar`, `PatientTile`, `HospitalTile`, `TimelineCard`.

Avoid duplicate widgets — extract to `shared/` when logic appears more than
twice (§148).

## Required Screen States (§22)

Every screen must handle all of:

- Loading State
- Empty State
- Offline State
- Permission Denied State
- Error State
- Success State

**Never show a blank screen.** Every async operation must provide feedback.

## State Widgets

| State | Guidance (§132–§135) |
| --- | --- |
| Loading | Skeletons / shimmer / progress — avoid indefinite spinners. |
| Empty | Meaningful message + primary action (e.g., "Register your first patient"). |
| Error | Clear explanation + suggested action + retry; never expose stack traces. |
| Offline | Persistent indicator: `Offline`, `Sync Pending`, `Synchronizing`, `Conflict Detected`. |

## Screen Composition (§122)

`App Bar · Body · Floating Action · Bottom Navigation (if required) · Loading
Overlay · Offline Banner · Error Handler`. Every screen supports scrolling.

## Cards & Tables (§124, §128)

Cards: `Title · Primary Metric · Secondary Info · Status Indicator · Action?`.
Large datasets use pagination, sorting, filtering, search, sticky headers, and
selectable rows — never render thousands of rows at once.

## Testing (§143)

Every reusable widget includes widget tests, golden tests (where appropriate),
accessibility verification, and responsive verification.
