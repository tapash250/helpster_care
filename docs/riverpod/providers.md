# Providers

> Reference: `AGENTS.md` §23, §24, Appendix F.

Providers declare dependencies and wire the object graph. They live in each
feature's `providers/` folder.

## Repository Provider

```dart
@riverpod
PatientRepository patientRepository(PatientRepositoryRef ref) {
  return PatientRepository(
    local: ref.watch(patientLocalDatasourceProvider),
    remote: ref.watch(patientRemoteDatasourceProvider),
  );
}
```

## Family Provider

```dart
@riverpod
Future<Patient> patientById(PatientByIdRef ref, String id) {
  return ref.watch(patientRepositoryProvider).findById(id);
}
```

## AutoDispose

Prefer `autoDispose` (the default with codegen) so provider state is released
when no longer watched. Use `keepAlive` deliberately and rarely.

## Dependency Injection & Testing

Override providers in tests to inject fakes/mocks:

```dart
ProviderContainer(
  overrides: [
    patientRepositoryProvider.overrideWithValue(FakePatientRepository()),
  ],
);
```

## Rules

- Providers belong in `providers/`; controllers in `controllers/`; state in
  `states/`.
- Repositories are framework-independent — a provider *constructs* a repository,
  but the repository never imports Riverpod.
- Generate provider code with `dart run build_runner build`.
