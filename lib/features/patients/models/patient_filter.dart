/// Filter criteria for the patient list.
///
/// Immutable value object used to parameterise list queries.
class PatientFilter {
  const PatientFilter({
    this.searchQuery,
    this.statusFilter = const {},
    this.sortField = 'created_at',
    this.ascending = false,
  });

  /// Text search across name / patient ID / national ID.
  final String? searchQuery;

  /// One or more status values to filter by (empty = all).
  final Set<String> statusFilter;

  /// Database column to sort by.
  final String sortField;

  /// Sort direction.
  final bool ascending;

  /// Copy with optional field overrides.
  PatientFilter copyWith({
    String? searchQuery,
    Set<String>? statusFilter,
    String? sortField,
    bool? ascending,
    bool clearSearch = false,
    bool clearStatus = false,
  }) {
    return PatientFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      statusFilter: clearStatus ? const {} : (statusFilter ?? this.statusFilter),
      sortField: sortField ?? this.sortField,
      ascending: ascending ?? this.ascending,
    );
  }

  /// Whether any filter is active.
  bool get hasActiveFilter =>
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      statusFilter.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientFilter &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery &&
          statusFilter == other.statusFilter &&
          sortField == other.sortField &&
          ascending == other.ascending;

  @override
  int get hashCode =>
      Object.hash(searchQuery, statusFilter, sortField, ascending);

  @override
  String toString() =>
      'PatientFilter(searchQuery: $searchQuery, statusFilter: $statusFilter)';
}
