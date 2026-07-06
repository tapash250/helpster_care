import 'package:helpster_care/shared/models/hospital.dart';
import 'package:helpster_care/shared/models/department.dart';
import 'package:helpster_care/shared/models/ward.dart';
import 'package:helpster_care/shared/models/bed.dart';
import 'package:helpster_care/features/hospitals/models/hospital_filter.dart';

/// Immutable state container for the hospital list feature.
class HospitalListState {
  const HospitalListState({
    this.hospitals = const [],
    this.isLoading = false,
    this.error,
    this.filter = const HospitalFilter(),
  });

  /// Loaded hospitals.
  final List<Hospital> hospitals;

  /// Whether a fetch is in progress.
  final bool isLoading;

  /// Optional error message.
  final String? error;

  /// Current filter/sort criteria.
  final HospitalFilter filter;

  /// Whether data has been loaded at least once.
  bool get hasData => hospitals.isNotEmpty;

  HospitalListState copyWith({
    List<Hospital>? hospitals,
    bool? isLoading,
    String? error,
    HospitalFilter? filter,
  }) {
    return HospitalListState(
      hospitals: hospitals ?? this.hospitals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }
}

/// Immutable state container for a single hospital detail view.
class HospitalDetailState {
  const HospitalDetailState({
    this.hospital,
    this.departments = const [],
    this.wards = const [],
    this.beds = const [],
    this.isLoading = false,
    this.error,
    this.selectedTab = 0,
  });

  /// The loaded hospital, or null if not yet loaded.
  final Hospital? hospital;

  /// Departments belonging to this hospital.
  final List<Department> departments;

  /// Wards belonging to this hospital.
  final List<Ward> wards;

  /// Beds belonging to this hospital's wards.
  final List<Bed> beds;

  /// Whether a fetch is in progress.
  final bool isLoading;

  /// Optional error message.
  final String? error;

  /// Currently selected tab index.
  final int selectedTab;

  bool get hasData => hospital != null;

  int get totalBeds => beds.length;
  int get availableBeds => beds.where((b) => b.status == 'AVAILABLE').length;
  int get occupiedBeds => beds.where((b) => b.status == 'OCCUPIED').length;

  HospitalDetailState copyWith({
    Hospital? hospital,
    List<Department>? departments,
    List<Ward>? wards,
    List<Bed>? beds,
    bool? isLoading,
    String? error,
    int? selectedTab,
  }) {
    return HospitalDetailState(
      hospital: hospital ?? this.hospital,
      departments: departments ?? this.departments,
      wards: wards ?? this.wards,
      beds: beds ?? this.beds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

/// Form submission state for create/edit hospital.
class HospitalFormState {
  const HospitalFormState({
    this.isSubmitting = false,
    this.error,
    this.isSuccess = false,
  });

  final bool isSubmitting;
  final String? error;
  final bool isSuccess;

  HospitalFormState copyWith({
    bool? isSubmitting,
    String? error,
    bool? isSuccess,
  }) {
    return HospitalFormState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
