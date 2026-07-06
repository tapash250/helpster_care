import 'package:freezed_annotation/freezed_annotation.dart';

part 'department.freezed.dart';
part 'department.g.dart';

/// Hospital department.
@freezed
class Department with _$Department {
  const factory Department({
    required String id,
    required String hospitalId,
    required String name,
    String? description,
    @Default(true) bool isActive,
  }) = _Department;

  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);
}
