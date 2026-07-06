import 'package:helpster_care/features/patients/models/patient_filter.dart';
import 'package:helpster_care/shared/models/patient.dart';

/// Configuration state for the patient list screen.
///
/// This is separate from the async data state (which lives in the
/// [AsyncNotifier] via [AsyncValue]) and captures the filter/search
/// configuration the user has chosen.
class PatientListConfig {
  const PatientListConfig({
    this.filter = const PatientFilter(),
    this.isSearching = false,
  });

  /// Active filter criteria.
  final PatientFilter filter;

  /// Whether the user is currently typing in the search field.
  final bool isSearching;

  /// Copy with overrides.
  PatientListConfig copyWith({
    PatientFilter? filter,
    bool? isSearching,
  }) {
    return PatientListConfig(
      filter: filter ?? this.filter,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

/// Human-readable status options for the patient list filter chips.
class PatientStatusOption {
  const PatientStatusOption._();

  static const Map<String, String> all = {
    'DRAFT': 'Draft',
    'PENDING_DOCUMENTS': 'Pending Docs',
    'UNDER_REVIEW': 'Under Review',
    'MEDICAL_REVIEW': 'Medical Review',
    'APPROVED': 'Approved',
    'ACTIVE': 'Active',
    'IN_TREATMENT': 'In Treatment',
    'DISCHARGED': 'Discharged',
    'CLOSED': 'Closed',
    'REJECTED': 'Rejected',
  };

  /// Default statuses to show on first load.
  static const List<String> defaultStatuses = [
    'DRAFT',
    'PENDING_DOCUMENTS',
    'UNDER_REVIEW',
    'MEDICAL_REVIEW',
    'APPROVED',
    'ACTIVE',
    'IN_TREATMENT',
  ];
}
