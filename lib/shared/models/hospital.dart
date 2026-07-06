import 'package:freezed_annotation/freezed_annotation.dart';

part 'hospital.freezed.dart';
part 'hospital.g.dart';

/// Hospital entity.
@freezed
class Hospital with _$Hospital {
  const factory Hospital({
    required String id,
    required String name,
    String? hospitalType,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? registrationNo,
    @Default(true) bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Hospital;

  factory Hospital.fromJson(Map<String, dynamic> json) =>
      _$HospitalFromJson(json);
}

/// Hospital assignment (ReBAC).
@freezed
class HospitalAssignment with _$HospitalAssignment {
  const factory HospitalAssignment({
    required String id,
    required String userId,
    required String hospitalId,
    String? hospitalName,
    @Default(true) bool isActive,
    String? assignedBy,
    required DateTime assignedAt,
    required DateTime createdAt,
  }) = _HospitalAssignment;

  factory HospitalAssignment.fromJson(Map<String, dynamic> json) =>
      _$HospitalAssignmentFromJson(json);
}
