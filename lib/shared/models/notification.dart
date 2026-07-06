import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

/// Notification entity.
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String recipientId,
    String? templateCode,
    required String title,
    required String body,
    @Default('IN_APP') String channel,
    String? referenceType,
    String? referenceId,
    @Default(false) bool isRead,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
