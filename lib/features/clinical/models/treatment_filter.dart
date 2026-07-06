/// Treatment filter model.
class TreatmentFilter {
  const TreatmentFilter({
    this.searchQuery = '',
    this.status = const [],
    this.treatmentType,
    this.patientId,
  });

  final String searchQuery;
  final List<String> status;
  final String? treatmentType;
  final String? patientId;

  TreatmentFilter copyWith({
    String? searchQuery,
    List<String>? status,
    String? treatmentType,
    String? patientId,
  }) {
    return TreatmentFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      treatmentType: treatmentType ?? this.treatmentType,
      patientId: patientId ?? this.patientId,
    );
  }
}
