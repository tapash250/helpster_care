/// Controller for the patient list with search, filter, and pagination.
///
/// Uses Riverpod [AsyncNotifier] for reactive state management. The list is
/// automatically refreshed on filter changes.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpster_care/shared/models/patient.dart';
import 'package:helpster_care/features/patients/models/patient_filter.dart';
import 'package:helpster_care/features/patients/repositories/patient_repository.dart';
import 'package:helpster_care/features/patients/states/patient_list_state.dart';

/// Notifier that manages the patient list and filter/search configuration.
class PatientListController extends AsyncNotifier<List<Patient>> {
  PatientListConfig _config = const PatientListConfig();

  /// The current filter/search configuration.
  PatientListConfig get config => _config;

  @override
  Future<List<Patient>> build() async {
    final repo = ref.watch(patientRepositoryProvider);
    return repo.getPatients(filter: _config.filter);
  }

  /// Reload the patient list with the current filter.
  Future<void> refresh() async => ref.invalidateSelf();

  /// Update the search query and refresh.
  Future<void> setSearchQuery(String query) async {
    _config = _config.copyWith(
      filter: _config.filter.copyWith(
        searchQuery: query.isNotEmpty ? query : null,
        clearSearch: query.isEmpty,
      ),
      isSearching: query.isNotEmpty,
    );
    ref.invalidateSelf();
  }

  /// Toggle a status filter chip.
  Future<void> toggleStatusFilter(String status) async {
    final current = Set<String>.from(_config.filter.statusFilter);
    if (current.contains(status)) {
      current.remove(status);
    } else {
      current.add(status);
    }
    _config = _config.copyWith(
      filter: _config.filter.copyWith(statusFilter: current),
    );
    ref.invalidateSelf();
  }

  /// Set a specific set of status filters.
  Future<void> setStatusFilter(Set<String> statuses) async {
    _config = _config.copyWith(
      filter: _config.filter.copyWith(statusFilter: statuses),
    );
    ref.invalidateSelf();
  }

  /// Clear all filters.
  Future<void> clearFilters() async {
    _config = const PatientListConfig();
    ref.invalidateSelf();
  }

  /// Remove a single status from the filter.
  Future<void> removeStatusFilter(String status) async {
    final current = Set<String>.from(_config.filter.statusFilter);
    current.remove(status);
    _config = _config.copyWith(
      filter: _config.filter.copyWith(statusFilter: current),
    );
    ref.invalidateSelf();
  }
}

/// Provider for the patient list controller.
final patientListControllerProvider =
    AsyncNotifierProvider<PatientListController, List<Patient>>(
  PatientListController.new,
);

/// Provider for the patient list configuration state.
final patientListConfigProvider = Provider<PatientListConfig>((ref) {
  final controller = ref.watch(patientListControllerProvider.notifier);
  return controller.config;
});

/// Provider for the filtered patient list with auto-refresh.
final patientListProvider =
    Provider<AsyncValue<List<Patient>>>((ref) {
  return ref.watch(patientListControllerProvider);
});

/// Repository provider (shared across controllers).
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  // In production, this would resolve the datasource dependencies.
  // Here we throw — the app must override this provider during setup.
  throw UnimplementedError(
    'PatientRepository must be provided. '
    'Override patientRepositoryProvider in your app setup.',
  );
});
