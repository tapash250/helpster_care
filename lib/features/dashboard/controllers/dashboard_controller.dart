import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpster_care/features/dashboard/models/dashboard_metrics.dart';
import 'package:helpster_care/features/dashboard/repositories/dashboard_repository.dart';

/// Notifier that manages dashboard analytics state.
///
/// Exposes loading, error, and data states for the dashboard screen.
/// Supports manual refresh via [refresh()].
class DashboardController extends AutoDisposeAsyncNotifier<DashboardMetrics> {
  @override
  Future<DashboardMetrics> build() async {
    final repo = ref.read(dashboardRepositoryProvider);
    return repo.fetchMetrics();
  }

  /// Force-refresh dashboard data from the backend.
  Future<void> refresh() async {
    final repo = ref.read(dashboardRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.fetchMetrics(forceRefresh: true));
  }
}

/// Riverpod provider for the dashboard controller.
final dashboardControllerProvider =
    AutoDisposeAsyncNotifierProvider<DashboardController, DashboardMetrics>(
  DashboardController.new,
);

/// Provider for the dashboard repository.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});
