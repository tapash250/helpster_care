import 'package:freezed_annotation/freezed_annotation.dart';

part 'role.freezed.dart';
part 'role.g.dart';

/// A role in the RBAC system.
@freezed
class Role with _$Role {
  const factory Role({
    required String id,
    required String code,
    required String label,
    String? description,
    @Default(true) bool isActive,
    @Default(0) int sortOrder,
  }) = _Role;

  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);
}

/// Permission in the RBAC system.
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

/// User-role assignment.
@freezed
class UserRole with _$UserRole {
  const factory UserRole({
    required String id,
    required String userId,
    required String roleId,
    String? roleCode,
    String? roleLabel,
    String? grantedBy,
    required DateTime grantedAt,
    DateTime? revokedAt,
    @Default(true) bool isActive,
  }) = _UserRole;

  factory UserRole.fromJson(Map<String, dynamic> json) =>
      _$UserRoleFromJson(json);
}
