import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Authenticated user.
@freezed
class User with _$User {
  const factory User({
    required String id,
    String? email,
    String? phone,
    required String fullName,
    String? avatarUrl,
    @Default(true) bool isActive,
    DateTime? lastLogin,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
