import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpster_care/features/hospitals/repositories/hospital_repository.dart';
import 'package:helpster_care/features/hospitals/controllers/hospital_controller.dart';

/// Provider for the hospital repository.
final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  return HospitalRepository();
});

/// Provider for the hospital list controller.
final hospitalListControllerProvider =
    StateNotifierProvider<HospitalListController, HospitalListState>((ref) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return HospitalListController(repo);
});

/// Provider for hospital detail (takes a hospital ID parameter).
final hospitalDetailControllerProvider = StateNotifierProvider.family
    .autoDispose<HospitalDetailController, HospitalDetailState, String>(
  (ref, hospitalId) {
    final repo = ref.watch(hospitalRepositoryProvider);
    return HospitalDetailController(repo);
  },
);

/// Provider for hospital form controller.
final hospitalFormControllerProvider =
    StateNotifierProvider<HospitalFormController, HospitalFormState>((ref) {
  final repo = ref.watch(hospitalRepositoryProvider);
  return HospitalFormController(repo);
});
