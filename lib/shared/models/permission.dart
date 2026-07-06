import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission.freezed.dart';
part 'permission.g.dart';

/// Permission entity from the database.
@freezed
class Permission with _$Permission {
  const factory Permission({
    required String id,
    required String code,
    required String label,
    required String module,
    String? description,
  }) = _Permission;

  factory Permission.fromJson(Map<String, dynamic> json) =>
      _$PermissionFromJson(json);
}
