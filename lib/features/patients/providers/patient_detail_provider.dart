/// Convenience providers for patient detail.
///
/// These wrap [patientDetailControllerProvider] for ergonomic access from
/// widgets, providing commonly derived states.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpster_care/features/patients/controllers/patient_detail_controller.dart';
import 'package:helpster_care/shared/models/patient.dart';

/// Provider that returns just the list of [PatientContact] for a patient.
final patientContactsProvider =
    FutureProvider.family<List<PatientContact>, String>((ref, id) async {
  final detail = await ref.watch(patientDetailControllerProvider(id).future);
  return detail.contacts;
});

/// Provider that returns just the list of [PatientAddress] for a patient.
final patientAddressesProvider =
    FutureProvider.family<List<PatientAddress>, String>((ref, id) async {
  final detail = await ref.watch(patientDetailControllerProvider(id).future);
  return detail.addresses;
});

/// Provider that returns just the list of [PatientGuardian] for a patient.
final patientGuardiansProvider =
    FutureProvider.family<List<PatientGuardian>, String>((ref, id) async {
  final detail = await ref.watch(patientDetailControllerProvider(id).future);
  return detail.guardians;
});

/// Provider that returns just the list of [PatientAssignment] for a patient.
final patientAssignmentsProvider =
    FutureProvider.family<List<PatientAssignment>, String>((ref, id) async {
  final detail = await ref.watch(patientDetailControllerProvider(id).future);
  return detail.assignments;
});

/// Provider that returns just the status history for a patient.
final patientStatusHistoryProvider =
    FutureProvider.family<List<PatientStatusHistory>, String>((ref, id) async {
  final detail = await ref.watch(patientDetailControllerProvider(id).future);
  return detail.statusHistory;
});

/// Provider that returns just the notes for a patient.
final patientNotesProvider =
    FutureProvider.family<List<PatientNote>, String>((ref, id) async {
  final detail = await ref.watch(patientDetailControllerProvider(id).future);
  return detail.notes;
});
