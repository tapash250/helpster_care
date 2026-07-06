import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

/// Canonical patient record.
@freezed
class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String patientId,
    String? nationalId,
    required String fullName,
    DateTime? dateOfBirth,
    String? gender,
    String? bloodGroup,
    String? religion,
    String? occupation,
    String? photoPath,
    @Default('DRAFT') String status,
    String? hospitalId,
    String? hospitalName,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdBy,
    String? updatedBy,
    DateTime? deletedAt,
    String? deletedBy,
    @Default(false) bool isDeleted,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}

/// Patient contact information.
@freezed
class PatientContact with _$PatientContact {
  const factory PatientContact({
    required String id,
    required String patientId,
    String? phone,
    String? email,
    @Default(false) bool isEmergency,
  }) = _PatientContact;

  factory PatientContact.fromJson(Map<String, dynamic> json) =>
      _$PatientContactFromJson(json);
}

/// Patient address.
@freezed
class PatientAddress with _$PatientAddress {
  const factory PatientAddress({
    required String id,
    required String patientId,
    @Default('PRESENT') String addressType,
    String? division,
    String? district,
    String? upazila,
    String? unionOrCity,
    String? villageOrWard,
    String? street,
    String? postCode,
    @Default('Bangladesh') String country,
  }) = _PatientAddress;

  factory PatientAddress.fromJson(Map<String, dynamic> json) =>
      _$PatientAddressFromJson(json);
}

/// Patient guardian.
@freezed
class PatientGuardian with _$PatientGuardian {
  const factory PatientGuardian({
    required String id,
    required String patientId,
    required String fullName,
    String? relationship,
    String? phone,
    String? email,
    String? address,
    @Default(false) bool isMinor,
  }) = _PatientGuardian;

  factory PatientGuardian.fromJson(Map<String, dynamic> json) =>
      _$PatientGuardianFromJson(json);
}

/// Patient assignment (ReBAC).
@freezed
class PatientAssignment with _$PatientAssignment {
  const factory PatientAssignment({
    required String id,
    required String patientId,
    required String userId,
    required String assignmentType,
    String? userName,
    @Default(true) bool isActive,
    String? assignedBy,
    required DateTime assignedAt,
    DateTime? unassignedAt,
  }) = _PatientAssignment;

  factory PatientAssignment.fromJson(Map<String, dynamic> json) =>
      _$PatientAssignmentFromJson(json);
}

/// Patient status history entry.
@freezed
class PatientStatusHistory with _$PatientStatusHistory {
  const factory PatientStatusHistory({
    required String id,
    required String patientId,
    String? fromStatus,
    required String toStatus,
    String? changedBy,
    String? reason,
    required DateTime changedAt,
  }) = _PatientStatusHistory;

  factory PatientStatusHistory.fromJson(Map<String, dynamic> json) =>
      _$PatientStatusHistoryFromJson(json);
}

/// Patient note.
@freezed
class PatientNote with _$PatientNote {
  const factory PatientNote({
    required String id,
    required String patientId,
    required String note,
    @Default('GENERAL') String noteType,
    String? authorId,
    String? authorName,
    required DateTime createdAt,
  }) = _PatientNote;

  factory PatientNote.fromJson(Map<String, dynamic> json) =>
      _$PatientNoteFromJson(json);
}
