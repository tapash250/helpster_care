import 'dart:collection';
import 'package:helpster_care/features/dashboard/models/dashboard_metrics.dart';
import 'package:helpster_care/features/dashboard/datasources/remote/dashboard_datasource.dart';

/// Repository that fetches and caches dashboard analytics data.
///
/// Coordinates multiple Supabase queries and transforms raw results
/// into a single [DashboardMetrics] value.
class DashboardRepository {
  DashboardRepository({DashboardRemoteDataSource? dataSource})
      : _dataSource = dataSource ?? DashboardRemoteDataSource();

  final DashboardRemoteDataSource _dataSource;

  DashboardMetrics? _cached;
  DateTime? _lastFetch;

  /// Whether a fresh fetch is needed (stale after 60 seconds).
  bool get _isStale =>
      _lastFetch == null ||
      DateTime.now().difference(_lastFetch!).inSeconds > 60;

  /// Fetches all dashboard metrics, using cache when fresh.
  Future<DashboardMetrics> fetchMetrics({bool forceRefresh = false}) async {
    if (!forceRefresh && !_isStale && _cached != null) return _cached!;

    final results = await Future.wait([
      _dataSource.fetchTotalPatients(),
      _dataSource.fetchActiveTreatments(),
      _dataSource.fetchPendingApprovals(),
      _dataSource.fetchTodaySurgeries(),
      _dataSource.fetchRecentFollowups(),
      _dataSource.fetchHospitalCount(),
      _dataSource.fetchDepartmentCount(),
      _dataSource.fetchBedStats(),
      _dataSource.fetchTreatmentsByType(),
      _dataSource.fetchPatientsByStatus(),
      _dataSource.fetchRecentActivities(),
      _dataSource.fetchSurgeriesByDay(),
    ]);

    final totalPatients = results[0] as int;
    final activeTreatments = results[1] as int;
    final pendingApprovals = results[2] as int;
    final todaySurgeries = results[3] as int;
    final recentFollowups = results[4] as int;
    final hospitalCount = results[5] as int;
    final departmentCount = results[6] as int;
    final bedStats = results[7] as Map<String, int>;
    final treatmentsByType = results[8] as Map<String, int>;
    final patientsByStatus = results[9] as Map<String, int>;
    final rawActivities = results[10] as List<Map<String, dynamic>>;
    final rawSurgeries = results[11] as List<Map<String, dynamic>>;

    final activities = rawActivities.map((row) {
      return ActivitySummary(
        id: row['id'] as String,
        description: row['description'] as String? ?? '',
        timestamp: DateTime.parse(row['created_at'] as String),
        type: row['activity_type'] as String? ?? 'info',
        userName: row['user_name'] as String?,
      );
    }).toList();

    // Aggregate surgeries by day
    final dayCounts = <String, int>{};
    for (final row in rawSurgeries) {
      final createdAt = DateTime.parse(row['created_at'] as String);
      final dayKey =
          '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
      dayCounts[dayKey] = (dayCounts[dayKey] ?? 0) + 1;
    }
    final surgeriesByDay = dayCounts.entries
        .map((e) => DayCount(day: e.key, count: e.value))
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));

    final metrics = DashboardMetrics(
      totalPatients: totalPatients,
      activeTreatments: activeTreatments,
      pendingApprovals: pendingApprovals,
      todaySurgeries: todaySurgeries,
      recentFollowups: recentFollowups,
      hospitalCount: hospitalCount,
      departmentCount: departmentCount,
      availableBeds: bedStats['available'] ?? 0,
      occupiedBeds: bedStats['occupied'] ?? 0,
      totalBeds: bedStats['total'] ?? 0,
      treatmentsByType: UnmodifiableMapView(treatmentsByType),
      patientsByStatus: UnmodifiableMapView(patientsByStatus),
      recentActivities: activities,
      surgeriesByDay: surgeriesByDay,
    );

    _cached = metrics;
    _lastFetch = DateTime.now();
    return metrics;
  }
}
