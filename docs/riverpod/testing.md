# Riverpod Testing

> Reference: `AGENTS.md` §174–§176, Appendix F, Appendix K.

## Principles

- Favor many **unit tests** (repositories, controllers, validators, utilities,
  business rules). Coverage target **80%+**, critical modules **95%+**.
- Test controllers by overriding the repository provider with a fake/mock.
- Repositories are framework-independent → test them without Riverpod.

## Controller Test

```dart
void main() {
  test('registerPatient adds a patient and updates state', () async {
    final container = ProviderContainer(
      overrides: [
        patientRepositoryProvider.overrideWithValue(FakePatientRepository()),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(patientControllerProvider.notifier);
    await controller.registerPatient(const NewPatient(fullName: 'Test'));

    final state = container.read(patientControllerProvider);
    expect(state.value!.patients, isNotEmpty);
  });
}
```

## Mocking

Use `mocktail` for mocks; prefer hand-written fakes for repositories to keep
tests readable.

```dart
class MockPatientRepository extends Mock implements PatientRepository {}
```

## What to Assert

- State transitions: Loading → Success / Error.
- Error mapping: domain exceptions → `PermissionDenied` / `Conflict` / `Error`.
- Offline behavior: repository returns local data when remote is unavailable.

## Test Layout

```
test/
├── unit/        # repositories, controllers, validators, utils
├── widget/      # widget tests
├── golden/      # golden image tests
└── helpers/     # shared fakes, fixtures, ProviderContainer builders
integration_test/  # end-to-end workflow tests
```

Run with `flutter test` (unit/widget/golden) and
`flutter test integration_test` (e2e).
