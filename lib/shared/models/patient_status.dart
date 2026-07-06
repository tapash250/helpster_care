import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_status.freezed.dart';
part 'patient_status.g.dart';

/// Patient status lookup.
@freezed
class PatientStatus with _$PatientStatus {
  const factory PatientStatus({
    required String code,
    required String label,
    @Default(0) int sortOrder,
  }) = _PatientStatus;

  factory PatientStatus.fromJson(Map<String, dynamic> json) =>
      _$PatientStatusFromJson(json);
}
