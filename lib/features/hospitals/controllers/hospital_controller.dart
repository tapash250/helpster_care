import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpster_care/shared/models/hospital.dart';
import 'package:helpster_care/shared/models/department.dart';
import 'package:helpster_care/shared/models/ward.dart';
import 'package:helpster_care/shared/models/bed.dart';
import 'package:helpster_care/features/hospitals/models/hospital_filter.dart';
import 'package:helpster_care/features/hospitals/states/hospital_state.dart';
import 'package:helpster_care/features/hospitals/validators/hospital_validators.dart';
import 'package:helpster_care/features/hospitals/repositories/hospital_repository.dart';

/// Notifier that manages the hospital list state.
class HospitalListController extends StateNotifier<HospitalListState> {
  HospitalListController(this._repository) : super(const HospitalListState());

  final HospitalRepository _repository;

  /// Load hospitals with optional filter.
  Future<void> loadHospitals({HospitalFilter? filter}) async {
    state = state.copyWith(isLoading: true, error: null);
    if (filter != null) state = state.copyWith(filter: filter);

    try {
      final hospitals =
          await _repository.fetchHospitals(filter: state.filter);
      state = state.copyWith(
        hospitals: hospitals,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update search query and reload.
  void search(String query) {
    final newFilter = state.filter.copyWith(searchQuery: query);
    loadHospitals(filter: newFilter);
  }

  /// Update status filter and reload.
  void filterByStatus(String? status) {
    final newFilter = state.filter.copyWith(statusFilter: status);
    loadHospitals(filter: newFilter);
  }

  /// Update sort and reload.
  void sortBy(String field) {
    final ascending = state.filter.sortBy == field
        ? !state.filter.sortAscending
        : true;
    final newFilter = state.filter.copyWith(sortBy: field, sortAscending: ascending);
    loadHospitals(filter: newFilter);
  }

  /// Refresh the list.
  Future<void> refresh() => loadHospitals();
}

/// Notifier that manages a single hospital's detail state.
class HospitalDetailController extends StateNotifier<HospitalDetailState> {
  HospitalDetailController(this._repository)
      : super(const HospitalDetailState());

  final HospitalRepository _repository;

  /// Load full hospital detail: hospital + departments + wards + beds.
  Future<void> loadHospitalDetail(String hospitalId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _repository.fetchHospitalById(hospitalId),
        _repository.fetchDepartments(hospitalId),
        _repository.fetchWards(hospitalId),
        _repository.fetchBeds(hospitalId: hospitalId),
      ]);

      state = state.copyWith(
        hospital: results[0] as Hospital?,
        departments: results[1] as List<Department>,
        wards: results[2] as List<Ward>,
        beds: results[3] as List<Bed>,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Change the active tab.
  void selectTab(int index) {
    state = state.copyWith(selectedTab: index);
  }

  /// Refresh detail data.
  Future<void> refresh() {
    if (state.hospital == null) return Future.value();
    return loadHospitalDetail(state.hospital!.id);
  }
}

/// Notifier that manages hospital form submission state.
class HospitalFormController extends StateNotifier<HospitalFormState> {
  HospitalFormController(this._repository)
      : super(const HospitalFormState());

  final HospitalRepository _repository;

  /// Create a new hospital.
  Future<String?> createHospital(Hospital hospital) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final created = await _repository.createHospital(hospital);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return created.id;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Update an existing hospital.
  Future<bool> updateHospital(Hospital hospital) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _repository.updateHospital(hospital);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset the form state.
  void reset() {
    state = const HospitalFormState();
  }
}
