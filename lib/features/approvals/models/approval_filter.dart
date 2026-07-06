/// Approval filter model.
class ApprovalFilter {
  const ApprovalFilter({
    this.searchQuery = '',
    this.states = const [],
    this.priority,
    this.patientId,
  });

  /// Search text for patient name or ID.
  final String searchQuery;

  /// Filter by workflow states (e.g., 'DRAFT', 'SUBMITTED', etc.).
  final List<String> states;

  /// Filter by priority level.
  final String? priority;

  /// Filter by patient ID.
  final String? patientId;

  ApprovalFilter copyWith({
    String? searchQuery,
    List<String>? states,
    String? priority,
    String? patientId,
  }) {
    return ApprovalFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      states: states ?? this.states,
      priority: priority ?? this.priority,
      patientId: patientId ?? this.patientId,
    );
  }
}
