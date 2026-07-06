import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/treatment_repository.dart';
import '../providers/treatment_providers.dart';

/// Controller for treatment operations.
class TreatmentController extends StateNotifier<AsyncValue<void>> {
  TreatmentController(this.ref)
      : _repo = ref.read(treatmentRepositoryProvider),
        super(const AsyncValue.data(null));

  final Ref ref;
  final TreatmentRepository _repo;

  /// Create a new treatment (with optional conservative/surgical detail).
  Future<Map<String, dynamic>?> createTreatment({
    required String patientId,
    required String treatmentType,
    String? hospitalId,
    String? diagnosis,
    String? consultantId,
    DateTime? admissionDate,
    String? expectedOutcome,
    Map<String, dynamic>? conservativeData,
    Map<String, dynamic>? surgicalData,
  }) async {
    state = const AsyncValue.loading();
    try {
      final treatment = await _repo.createTreatment({
        'patient_id': patientId,
        'treatment_type': treatmentType,
        'hospital_id': hospitalId,
        'diagnosis': diagnosis,
        'consultant_id': consultantId,
        'admission_date': admissionDate?.toIso8601String(),
        'expected_outcome': expectedOutcome,
        'status': 'ACTIVE',
      });

      // Create extension record
      if (treatmentType == 'CONSERVATIVE' && conservativeData != null) {
        conservativeData['treatment_id'] = treatment['id'];
        conservativeData['patient_id'] = patientId;
        await _repo.createConservativeTreatment(conservativeData);
      } else if (treatmentType == 'SURGICAL' && surgicalData != null) {
        surgicalData['treatment_id'] = treatment['id'];
        surgicalData['patient_id'] = patientId;
        await _repo.createSurgicalTreatment(surgicalData);
      }

      state = const AsyncValue.data(null);
      return treatment;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Discharge (complete) a treatment.
  Future<bool> dischargeTreatment(String treatmentId) async {
    try {
      await _repo.updateTreatment(treatmentId, {
        'status': 'DISCHARGED',
        'discharge_date': DateTime.now().toIso8601String(),
      });
      ref.invalidate(treatmentListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for TreatmentController.
final treatmentControllerProvider =
    StateNotifierProvider<TreatmentController, AsyncValue<void>>((ref) {
  return TreatmentController(ref);
});
