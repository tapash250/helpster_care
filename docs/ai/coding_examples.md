# AI Coding Examples

> Reference: `AGENTS.md` Appendix E, Appendix F. Every convention shows a Good
> example, a Bad example, and an explanation.

## 1. Data Access from Presentation

**Bad**

```dart
// Widget calling Supabase directly — forbidden (§16, §19).
final data = await Supabase.instance.client.from('patients').select();
```

**Good**

```dart
// Widget reads state; controller → repository handles data.
final state = ref.watch(patientControllerProvider);
```

*Widgets render state only. Data access flows through the repository.*

## 2. Colors & Spacing

**Bad**

```dart
Container(color: Colors.red, padding: const EdgeInsets.all(13));
```

**Good**

```dart
Container(
  color: Theme.of(context).colorScheme.error,
  padding: const EdgeInsets.all(AppSpacing.md),
);
```

*No hardcoded colors or magic numbers — use theme tokens (§33, §118, §120).*

## 3. Permissions

**Bad**

```dart
if (user.role == 'admin') { showDeleteButton(); } // hardcoded role check
```

**Good**

```dart
PermissionGate(
  permission: 'patient.delete',
  child: const DeletePatientButton(),
);
```

*Permissions come from the database, never hardcoded roles (§67, §74).*

## 4. Error Handling

**Bad**

```dart
try { await repo.save(); } catch (_) {} // swallowed
```

**Good**

```dart
try {
  await repo.save();
} on PermissionDeniedException catch (e, s) {
  logger.warning('save denied', e, s);
  state = const AsyncError(PermissionDenied(), StackTrace.empty);
}
```

*Never ignore exceptions; use domain-specific exceptions (§162, §164).*

## 5. Repository Independence

**Bad**

```dart
class PatientRepository { final Ref ref; /* imports Riverpod */ }
```

**Good**

```dart
class PatientRepository {
  PatientRepository({required this.local, required this.remote});
  final PatientLocalDatasource local;
  final PatientRemoteDatasource remote;
}
```

*Repositories are framework-independent — they never import Riverpod (§24).*

## 6. Widget Size

**Bad:** a 600-line screen with dialogs, cards, and forms inlined.

**Good:** extract `PatientCard`, `PatientForm`, `PatientFilterDialog` into
`widgets/`; keep each < 300 lines (§121, §159).
