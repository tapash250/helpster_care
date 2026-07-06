import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/treatment_repository.dart';
import '../providers/treatment_providers.dart';

/// Controller for OT schedule operations.
class OTController extends StateNotifier<AsyncValue<void>> {
  OTController(this.ref)
      : _repo = ref.read(treatmentRepositoryProvider),
        super(const AsyncValue.data(null));

  final Ref ref;
  final TreatmentRepository _repo;

  /// Schedule a new OT slot.
  Future<Map<String, dynamic>?> scheduleOT({
    required String operatingTheatreId,
    required String patientId,
    required String procedure,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    String? primarySurgeonId,
    String? assistantSurgeonId,
    String? anaesthetistId,
    String? anaesthesiaType,
    String? notes,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repo.createOTSchedule({
        'operating_theatre_id': operatingTheatreId,
        'patient_id': patientId,
        'procedure': procedure,
        'scheduled_start': scheduledStart.toIso8601String(),
        'scheduled_end': scheduledEnd.toIso8601String(),
        'primary_surgeon_id': primarySurgeonId,
        'assistant_surgeon_id': assistantSurgeonId,
        'anaesthetist_id': anaesthetistId,
        'anaesthesia_type': anaesthesiaType,
        'notes': notes,
        'status': 'SCHEDULED',
      });
      state = const AsyncValue.data(null);
      ref.invalidate(otScheduleListProvider);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Start an OT (mark as in-progress).
  Future<bool> startOT(String scheduleId) async {
    try {
      await _repo.updateOTScheduleStatus(scheduleId, 'IN_PROGRESS', null);
      ref.invalidate(otScheduleListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Complete an OT.
  Future<bool> completeOT(String scheduleId) async {
    try {
      await _repo.updateOTScheduleStatus(scheduleId, 'COMPLETED', null);
      ref.invalidate(otScheduleListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Cancel an OT.
  Future<bool> cancelOT(String scheduleId, String reason) async {
    try {
      await _repo.updateOTScheduleStatus(
          scheduleId, 'CANCELLED', {'notes': reason});
      ref.invalidate(otScheduleListProvider);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Provider for OTController.
final otControllerProvider =
    StateNotifierProvider<OTController, AsyncValue<void>>((ref) {
  return OTController(ref);
});
