import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

/// Activity timeline entry.
@freezed
class ActivityTimeline with _$ActivityTimeline {
  const factory ActivityTimeline({
    required String id,
    String? patientId,
    String? userId,
    String? userName,
    required String activityType,
    required String description,
    dynamic metadata,
    required DateTime createdAt,
  }) = _ActivityTimeline;

  factory ActivityTimeline.fromJson(Map<String, dynamic> json) =>
      _$ActivityTimelineFromJson(json);
}

/// Audit log entry.
@freezed
class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String id,
    String? userId,
    required String action,
    required String entityType,
    String? entityId,
    dynamic details,
    String? ipAddress,
    String? userAgent,
    required DateTime performedAt,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) =>
      _$AuditLogFromJson(json);
}
