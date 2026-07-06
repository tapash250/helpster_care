/// Controller for viewing a single patient's detail.
///
/// Manages loading the full patient record plus all related data (contacts,
/// addresses, guardians, assignments, status history, notes).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpster_care/features/patients/repositories/patient_repository.dart';
import 'package:helpster_care/shared/models/patient.dart';

/// Aggregate data for the patient detail screen.
class PatientDetailData {
  const PatientDetailData({
    required this.patient,
    this.contacts = const [],
    this.addresses = const [],
    this.guardians = const [],
    this.assignments = const [],
    this.statusHistory = const [],
    this.notes = const [],
  });

  final Patient patient;
  final List<PatientContact> contacts;
  final List<PatientAddress> addresses;
  final List<PatientGuardian> guardians;
  final List<PatientAssignment> assignments;
  final List<PatientStatusHistory> statusHistory;
  final List<PatientNote> notes;
}

/// Notifier that loads full detail for a single patient.
class PatientDetailController
    extends FamilyAsyncNotifier<PatientDetailData, String> {
  @override
  Future<PatientDetailData> build(String arg) async {
    final repo = ref.watch(patientRepositoryProvider);
    final patient = await repo.getPatientById(arg);

    if (patient == null) {
      throw StateError('Patient not found: $arg');
    }

    final results = await Future.wait([
      repo.getContacts(arg),
      repo.getAddresses(arg),
      repo.getGuardians(arg),
      repo.getAssignments(arg),
      repo.getStatusHistory(arg),
      repo.getNotes(arg),
    ]);

    return PatientDetailData(
      patient: patient,
      contacts: results[0] as List<PatientContact>,
      addresses: results[1] as List<PatientAddress>,
      guardians: results[2] as List<PatientGuardian>,
      assignments: results[3] as List<PatientAssignment>,
      statusHistory: results[4] as List<PatientStatusHistory>,
      notes: results[5] as List<PatientNote>,
    );
  }

  /// Refresh the detail data.
  Future<void> refresh() async => ref.invalidateSelf();
}

/// Family provider for patient detail by id.
final patientDetailControllerProvider = AsyncNotifierProviderFamily<
    PatientDetailController, PatientDetailData, String>(
  PatientDetailController.new,
);

/// Convenience provider that returns the raw [Patient] from the detail.
final patientDetailProvider =
    Provider.family<AsyncValue<Patient?>, String>((ref, id) {
  final detail = ref.watch(patientDetailControllerProvider(id));
  return detail.whenData((d) => d.patient);
});
