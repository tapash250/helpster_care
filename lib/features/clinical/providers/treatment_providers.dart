import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../repositories/treatment_repository.dart';
import '../models/treatment_filter.dart';

/// Provider for the TreatmentRepository.
final treatmentRepositoryProvider = Provider<TreatmentRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return TreatmentRepository(supabaseClient: supabase.client);
});

/// Provider for the filtered treatment list.
final treatmentListProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, TreatmentFilter>((ref, filter) async {
  final repo = ref.watch(treatmentRepositoryProvider);
  return repo.listTreatments(filter: filter);
});

/// Provider for a single treatment by ID.
final treatmentDetailProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>?, String>(
        (ref, id) async {
  final repo = ref.watch(treatmentRepositoryProvider);
  return repo.getTreatment(id);
});

/// Provider for OT schedules (today+upcoming).
final otScheduleListProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String?>((ref, hospitalId) async {
  final repo = ref.watch(treatmentRepositoryProvider);
  return repo.listOTSchedules(hospitalId: hospitalId);
});

/// Provider for follow-ups by patient.
final followupListProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, patientId) async {
  final repo = ref.watch(treatmentRepositoryProvider);
  return repo.listFollowups(patientId: patientId);
});
