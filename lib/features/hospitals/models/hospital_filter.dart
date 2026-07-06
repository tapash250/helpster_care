/// Filter options for the hospital list.
///
/// Encapsulates search text and filter criteria used to query
/// the hospital list from the data source.
class HospitalFilter {
  const HospitalFilter({
    this.searchQuery = '',
    this.statusFilter,
    this.sortBy = 'name',
    this.sortAscending = true,
  });

  /// Text search query (matches name, address, phone, etc.).
  final String searchQuery;

  /// Optional status filter: 'active', 'inactive', or null for all.
  final String? statusFilter;

  /// Sort field: 'name', 'created_at', 'updated_at'.
  final String sortBy;

  /// Sort direction.
  final bool sortAscending;

  /// Creates a copy with optional field overrides.
  HospitalFilter copyWith({
    String? searchQuery,
    String? statusFilter,
    String? sortBy,
    bool? sortAscending,
  }) {
    return HospitalFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Whether the filter has any active criteria beyond defaults.
  bool get isActive =>
      searchQuery.isNotEmpty ||
      statusFilter != null ||
      sortBy != 'name' ||
      !sortAscending;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospitalFilter &&
          searchQuery == other.searchQuery &&
          statusFilter == other.statusFilter &&
          sortBy == other.sortBy &&
          sortAscending == other.sortAscending;

  @override
  int get hashCode => Object.hash(
        searchQuery,
        statusFilter,
        sortBy,
        sortAscending,
      );
}
