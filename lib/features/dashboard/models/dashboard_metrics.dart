/// Aggregate metrics for the dashboard analytics view.
///
/// This is a plain data class (not Freezed) because it's computed/derived
/// data that is never JSON-serialized to/from the backend directly.
class DashboardMetrics {
  const DashboardMetrics({
    this.totalPatients = 0,
    this.activeTreatments = 0,
    this.pendingApprovals = 0,
    this.todaySurgeries = 0,
    this.recentFollowups = 0,
    this.availableBeds = 0,
    this.occupiedBeds = 0,
    this.totalBeds = 0,
    this.hospitalCount = 0,
    this.departmentCount = 0,
    this.treatmentsByType = const {},
    this.patientsByStatus = const {},
    this.recentActivities = const [],
    this.surgeriesByDay = const [],
  });

  /// Total patient count.
  final int totalPatients;

  /// Number of active treatments.
  final int activeTreatments;

  /// Number of pending approval requests.
  final int pendingApprovals;

  /// Number of surgeries scheduled for today.
  final int todaySurgeries;

  /// Number of follow-ups due soon.
  final int recentFollowups;

  /// Number of available (free) beds.
  final int availableBeds;

  /// Number of occupied beds.
  final int occupiedBeds;

  /// Total hospital-wide bed capacity.
  final int totalBeds;

  /// Number of hospitals the user has access to.
  final int hospitalCount;

  /// Number of departments across hospitals.
  final int departmentCount;

  /// Treatments grouped by type (type → count).
  final Map<String, int> treatmentsByType;

  /// Patients grouped by status (status → count).
  final Map<String, int> patientsByStatus;

  /// Recent activity timeline entries.
  final List<ActivitySummary> recentActivities;

  /// Surgery counts per day for the chart.
  final List<DayCount> surgeriesByDay;

  /// Occupancy rate as a double between 0.0 and 1.0.
  double get occupancyRate =>
      totalBeds > 0 ? occupiedBeds / totalBeds : 0.0;
}

/// A single activity entry for the recent activity list.
class ActivitySummary {
  const ActivitySummary({
    required this.id,
    required this.description,
    required this.timestamp,
    this.type = 'info',
    this.userName,
  });

  final String id;
  final String description;
  final DateTime timestamp;
  final String type;
  final String? userName;
}

/// A count for a specific day (used in charts).
class DayCount {
  const DayCount({
    required this.day,
    required this.count,
  });

  final String day;
  final int count;
}
