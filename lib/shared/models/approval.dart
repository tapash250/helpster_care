import 'package:freezed_annotation/freezed_annotation.dart';

part 'approval.freezed.dart';
part 'approval.g.dart';

/// Workflow state.
@freezed
class WorkflowState with _$WorkflowState {
  const factory WorkflowState({
    required String code,
    required String label,
    @Default(0) int sortOrder,
  }) = _WorkflowState;

  factory WorkflowState.fromJson(Map<String, dynamic> json) =>
      _$WorkflowStateFromJson(json);
}

/// Approval record.
@freezed
class Approval with _$Approval {
  const factory Approval({
    required String id,
    required String patientId,
    @Default('DRAFT') String currentState,
    @Default('NORMAL') String priority,
    String? submittedBy,
    String? submittedByName,
    String? reviewedBy,
    String? reviewedByName,
    String? reviewNotes,
    DateTime? decidedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdBy,
    String? updatedBy,
  }) = _Approval;

  factory Approval.fromJson(Map<String, dynamic> json) =>
      _$ApprovalFromJson(json);
}

/// Approval history (immutable transition log).
@freezed
class ApprovalHistory with _$ApprovalHistory {
  const factory ApprovalHistory({
    required String id,
    required String approvalId,
    String? fromState,
    required String toState,
    String? actorId,
    String? actorName,
    String? reason,
    required DateTime createdAt,
  }) = _ApprovalHistory;

  factory ApprovalHistory.fromJson(Map<String, dynamic> json) =>
      _$ApprovalHistoryFromJson(json);
}
