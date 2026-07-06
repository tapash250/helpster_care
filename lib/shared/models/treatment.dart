import 'package:freezed_annotation/freezed_annotation.dart';

part 'treatment.freezed.dart';
part 'treatment.g.dart';

/// Treatment type lookup.
@freezed
class TreatmentType with _$TreatmentType {
  const factory TreatmentType({
    required String code,
    required String label,
  }) = _TreatmentType;

  factory TreatmentType.fromJson(Map<String, dynamic> json) =>
      _$TreatmentTypeFromJson(json);
}

/// Abstract parent treatment record.
@freezed
class Treatment with _$Treatment {
  const factory Treatment({
    required String id,
    required String patientId,
    String? hospitalId,
    String? hospitalName,
    required String treatmentType,
    String? diagnosis,
    String? consultantId,
    String? consultantName,
    DateTime? admissionDate,
    String? expectedOutcome,
    @Default('ACTIVE') String status,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdBy,
    String? updatedBy,
  }) = _Treatment;

  factory Treatment.fromJson(Map<String, dynamic> json) =>
      _$TreatmentFromJson(json);
}
