import 'package:freezed_annotation/freezed_annotation.dart';

part 'bed.freezed.dart';
part 'bed.g.dart';

/// Hospital bed.
@freezed
class Bed with _$Bed {
  const factory Bed({
    required String id,
    required String wardId,
    String? departmentId,
    required String bedNumber,
    String? patientId,
    @Default('AVAILABLE') String status,
    required DateTime lastUpdated,
  }) = _Bed;

  factory Bed.fromJson(Map<String, dynamic> json) => _$BedFromJson(json);
}
