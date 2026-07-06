/// Shared domain models for Helpster Care.
///
/// All models use Freezed for immutability, JSON serialization, and
/// equality (AGENTS.md §25, §170). Models are framework-agnostic — they
/// never import Flutter or Riverpod.
library;

export 'user.dart';
export 'role.dart';
export 'permission.dart';
export 'hospital.dart';
export 'department.dart';
export 'ward.dart';
export 'bed.dart';
export 'patient.dart';
export 'patient_status.dart';
export 'treatment.dart';
export 'clinical.dart';
export 'document.dart';
export 'approval.dart';
export 'notification.dart';
export 'activity.dart';
