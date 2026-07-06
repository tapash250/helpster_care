import 'package:freezed_annotation/freezed_annotation.dart';

part 'clinical.freezed.dart';
part 'clinical.g.dart';

/// Conservative treatment.
@freezed
class ConservativeTreatment with _$ConservativeTreatment {
  const factory ConservativeTreatment({
    required String id,
    required String treatmentId,
    required String patientId,
    String? wardId,
    String? wardName,
    String? bedId,
    String? bedNumber,
    String? medication,
    String? investigations,
    DateTime? expectedDischarge,
    String? dischargeSummary,
  }) = _ConservativeTreatment;

  factory ConservativeTreatment.fromJson(Map<String, dynamic> json) =>
      _$ConservativeTreatmentFromJson(json);
}

/// Surgical treatment.
@freezed
class SurgicalTreatment with _$SurgicalTreatment {
  const factory SurgicalTreatment({
    required String id,
    required String treatmentId,
    required String patientId,
    String? procedure,
    String? surgeonId,
    String? surgeonName,
    String? assistantSurgeonId,
    String? anaesthetistId,
    String? implants,
    String? operationNotes,
    @Default(false) bool icuTransfer,
    String? postOpNotes,
    String? dischargeSummary,
  }) = _SurgicalTreatment;

  factory SurgicalTreatment.fromJson(Map<String, dynamic> json) =>
      _$SurgicalTreatmentFromJson(json);
}

/// Surgery record (individual procedure).
@freezed
class Surgery with _$Surgery {
  const factory Surgery({
    required String id,
    required String surgicalTreatmentId,
    required String patientId,
    String? procedureName,
    DateTime? performedAt,
    int? durationMinutes,
    String? outcome,
    String? notes,
  }) = _Surgery;

  factory Surgery.fromJson(Map<String, dynamic> json) =>
      _$SurgeryFromJson(json);
}

/// OT schedule.
@freezed
class OTSchedule with _$OTSchedule {
  const factory OTSchedule({
    required String id,
    required String operatingTheatreId,
    String? theatreRoom,
    String? surgeryId,
    required String patientId,
    String? procedure,
    String? primarySurgeonId,
    String? primarySurgeonName,
    String? assistantSurgeonId,
    String? anaesthetistId,
    String? anaesthesiaType,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    DateTime? actualStart,
    DateTime? actualEnd,
    @Default('SCHEDULED') String status,
    String? notes,
  }) = _OTSchedule;

  factory OTSchedule.fromJson(Map<String, dynamic> json) =>
      _$OTScheduleFromJson(json);
}

/// Follow-up visit.
@freezed
class Followup with _$Followup {
  const factory Followup({
    required String id,
    required String patientId,
    String? hospitalId,
    String? hospitalName,
    String? doctorId,
    String? doctorName,
    String? treatmentId,
    required DateTime followupDate,
    String? instructions,
    String? outcome,
    DateTime? nextVisit,
    @Default('SCHEDULED') String status,
  }) = _Followup;

  factory Followup.fromJson(Map<String, dynamic> json) =>
      _$FollowupFromJson(json);
}

/// Diagnosis.
@freezed
class Diagnosis with _$Diagnosis {
  const factory Diagnosis({
    required String id,
    required String patientId,
    String? treatmentId,
    required String diagnosis,
    @Default('PRIMARY') String diagnosisType,
    String? diagnosedBy,
    String? diagnosedByName,
    required DateTime diagnosedAt,
    String? notes,
    @Default(true) bool isActive,
  }) = _Diagnosis;

  factory Diagnosis.fromJson(Map<String, dynamic> json) =>
      _$DiagnosisFromJson(json);
}

/// Prescription.
@freezed
class Prescription with _$Prescription {
  const factory Prescription({
    required String id,
    required String patientId,
    String? treatmentId,
    String? prescribedBy,
    String? prescribedByName,
    required String medication,
    String? dosage,
    String? frequency,
    String? duration,
    String? route,
    String? notes,
    @Default(true) bool isActive,
    required DateTime prescribedAt,
  }) = _Prescription;

  factory Prescription.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionFromJson(json);
}
