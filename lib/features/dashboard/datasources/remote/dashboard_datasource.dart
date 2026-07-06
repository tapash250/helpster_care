import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:helpster_care/core/services/supabase_service.dart';

/// Supabase data source for dashboard aggregate metrics.
///
/// Executes queries to compute real-time counts and analytics data.
class DashboardRemoteDataSource {
  DashboardRemoteDataSource({SupabaseService? supabaseService})
      : _supabase = supabaseService ?? SupabaseService.instance;

  final SupabaseService _supabase;

  SupabaseClient get _client => _supabase.client;

  /// Total patient count.
  Future<int> fetchTotalPatients() async {
    final result = await _client
        .from('patients')
        .count(CountOption.exact)
        .is_('deleted_at', null);
    return result.count ?? 0;
  }

  /// Active treatments count.
  Future<int> fetchActiveTreatments() async {
    final result = await _client
        .from('treatments')
        .count(CountOption.exact)
        .eq('status', 'ACTIVE');
    return result.count ?? 0;
  }

  /// Pending approvals count.
  Future<int> fetchPendingApprovals() async {
    final result = await _client
        .from('approvals')
        .count(CountOption.exact)
        .eq('current_state', 'DRAFT');
    return result.count ?? 0;
  }

  /// Today's surgeries count.
  Future<int> fetchTodaySurgeries() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay =
        startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));
    final result = await _client
        .from('surgical_treatments')
        .count(CountOption.exact)
        .gte('created_at', startOfDay.toUtc().toIso8601String())
        .lte('created_at', endOfDay.toUtc().toIso8601String());
    return result.count ?? 0;
  }

  /// Recent follow-ups count (next 7 days).
  Future<int> fetchRecentFollowups() async {
    final now = DateTime.now();
    final weekLater = now.add(const Duration(days: 7));
    final result = await _client
        .from('followups')
        .count(CountOption.exact)
        .gte('followup_date', now.toUtc().toIso8601String())
        .lte('followup_date', weekLater.toUtc().toIso8601String())
        .eq('status', 'SCHEDULED');
    return result.count ?? 0;
  }

  /// Total hospital count.
  Future<int> fetchHospitalCount() async {
    final result = await _client
        .from('hospitals')
        .count(CountOption.exact)
        .eq('is_active', true);
    return result.count ?? 0;
  }

  /// Total department count.
  Future<int> fetchDepartmentCount() async {
    final result = await _client
        .from('departments')
        .count(CountOption.exact)
        .eq('is_active', true);
    return result.count ?? 0;
  }

  /// Available and occupied beds.
  Future<Map<String, int>> fetchBedStats() async {
    final total = await _client
        .from('beds')
        .count(CountOption.exact);
    final occupied = await _client
        .from('beds')
        .count(CountOption.exact)
        .not('patient_id', 'is', null);
    final totalCount = total.count ?? 0;
    final occupiedCount = occupied.count ?? 0;
    return {
      'total': totalCount,
      'occupied': occupiedCount,
      'available': totalCount - occupiedCount,
    };
  }

  /// Treatments grouped by type.
  Future<Map<String, int>> fetchTreatmentsByType() async {
    final result = await _client
        .from('treatments')
        .select('treatment_type');
    final map = <String, int>{};
    for (final row in result) {
      final type = row['treatment_type'] as String? ?? 'UNKNOWN';
      map[type] = (map[type] ?? 0) + 1;
    }
    return map;
  }

  /// Patients grouped by status.
  Future<Map<String, int>> fetchPatientsByStatus() async {
    final result = await _client
        .from('patients')
        .select('status')
        .is_('deleted_at', null);
    final map = <String, int>{};
    for (final row in result) {
      final status = row['status'] as String? ?? 'DRAFT';
      map[status] = (map[status] ?? 0) + 1;
    }
    return map;
  }

  /// Recent activity entries.
  Future<List<Map<String, dynamic>>> fetchRecentActivities(
      {int limit = 10}) async {
    final result = await _client
        .from('activity_timeline')
        .select('id, activity_type, description, created_at, user_name')
        .order('created_at', ascending: false)
        .limit(limit);
    return result;
  }

  /// Surgery counts per day (last 7 days).
  Future<List<Map<String, dynamic>>> fetchSurgeriesByDay() async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final result = await _client
        .from('surgical_treatments')
        .select('created_at')
        .gte('created_at', weekAgo.toUtc().toIso8601String());
    return result;
  }
}
