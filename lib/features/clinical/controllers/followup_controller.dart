import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/treatment_repository.dart';
import '../providers/treatment_providers.dart';

/// Controller for follow-up operations.
class FollowupController extends StateNotifier<AsyncValue<void>> {
  FollowupController(this.ref)
      : _repo = ref.read(treatmentRepositoryProvider),
        super(const AsyncValue.data(null));

  final Ref ref;
  final TreatmentRepository _repo;

  /// Schedule a follow-up visit.
  Future<Map<String, dynamic>?> scheduleFollowup({
    required String patientId,
    required DateTime followupDate,
    String? hospitalId,
    String? doctorId,
    String? treatmentId,
    String? instructions,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repo.createFollowup({
        'patient_id': patientId,
        'hospital_id': hospitalId,
        'doctor_id': doctorId,
        'treatment_id': treatmentId,
        'followup_date': followupDate.toIso8601String(),
        'instructions': instructions,
        'status': 'SCHEDULED',
      });
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Complete a follow-up with outcome and optional next visit.
  Future<bool> completeFollowup(
      String id, String outcome, DateTime? nextVisit) async {
    try {
      await _repo.completeFollowup(id, outcome, nextVisit);
      ref.invalidate(followupListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Re-schedule a follow-up.
  Future<bool> rescheduleFollowup(String id, DateTime newDate) async {
    try {
      await ref.read(treatmentRepositoryProvider).createFollowup({
        'id': id,
        'followup_date': newDate.toIso8601String(),
      });
      ref.invalidate(followupListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Provider for FollowupController.
final followupControllerProvider =
    StateNotifierProvider<FollowupController, AsyncValue<void>>((ref) {
  return FollowupController(ref);
});
