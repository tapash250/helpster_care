# Controllers

> Reference: `AGENTS.md` §16 (Controller Layer), §25, §27, Appendix F.

Controllers are Riverpod `Notifier` / `AsyncNotifier` classes that **coordinate
business operations**, transform UI events, execute use cases, and manage state
transitions. **Controllers stay thin.**

## Forbidden in Controllers

- SQL
- Widget rendering
- Direct HTTP / Supabase calls

Controllers call **repositories**, never datasources or Supabase directly.

## AsyncNotifier Example

```dart
@riverpod
class PatientController extends _$PatientController {
  @override
  Future<PatientState> build() async {
    final patients = await ref.watch(patientRepositoryProvider).loadPatients();
    return PatientState(patients: patients, lastUpdated: DateTime.now());
  }

  Future<void> registerPatient(NewPatient input) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(patientRepositoryProvider);
      await repo.registerPatient(input);        // repo -> edge function
      final patients = await repo.loadPatients();
      return PatientState(patients: patients, lastUpdated: DateTime.now());
    });
  }
}
```

## Async State Contract (§27)

Surface all relevant states: Loading, Success, Error, Refreshing, Offline,
Conflict, PermissionDenied, SynchronizationPending. Never hide background
synchronization from the user.

## Method Guidelines

- Method names begin with verbs (`loadPatients`, `approvePatient`).
- 20–40 lines recommended (max 80). One action per method.
- Wrap fallible async work in `AsyncValue.guard` and map domain exceptions to
  user-facing states.
