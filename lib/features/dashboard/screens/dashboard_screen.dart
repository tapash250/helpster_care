import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/widgets.dart';
import 'package:helpster_care/features/dashboard/models/dashboard_metrics.dart';
import 'package:helpster_care/features/dashboard/controllers/dashboard_controller.dart';
import 'package:helpster_care/features/dashboard/widgets/metric_card.dart';
import 'package:helpster_care/features/dashboard/widgets/metrics_grid.dart';
import 'package:helpster_care/features/dashboard/widgets/recent_activity_list.dart';
import 'package:helpster_care/features/dashboard/widgets/quick_actions.dart';

/// Main dashboard screen — landing page after authentication.
///
/// Displays analytics summary with metric cards, charts, recent activity,
/// and quick action buttons. All states are handled: loading → error → data → empty.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(dashboardControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: AsyncValueWidget<DashboardMetrics>(
        value: metricsAsync,
        loading: const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorBanner(
          message: err.toString(),
          onRetry: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),
        ),
        data: (metrics) => _DashboardContent(metrics: metrics),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.metrics});

  final DashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),

          // Quick actions row
          QuickActions(
            onCreatePatient: () {
              // TODO: Navigate to create patient
            },
            onViewHospitals: () {
              // TODO: Navigate to hospital list
            },
            onViewApprovals: () {
              // TODO: Navigate to approvals
            },
            onViewReports: () {
              // TODO: Navigate to reports
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          // Metrics grid
          MetricsGrid(
            metrics: buildMetricItems(
              totalPatients: _formatNum(metrics.totalPatients),
              activeTreatments: _formatNum(metrics.activeTreatments),
              pendingApprovals: _formatNum(metrics.pendingApprovals),
              todaySurgeries: _formatNum(metrics.todaySurgeries),
              recentFollowups: _formatNum(metrics.recentFollowups),
              availableBeds: _formatNum(metrics.availableBeds),
              occupancyRate:
                  '${(metrics.occupancyRate * 100).toStringAsFixed(0)}% occupancy',
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Charts section
          if (metrics.treatmentsByType.isNotEmpty ||
              metrics.patientsByStatus.isNotEmpty)
            _buildChartsSection(context, theme),

          if (metrics.surgeriesByDay.isNotEmpty) ...[
            SectionHeader(title: 'Surgeries (Last 7 Days)'),
            _buildSurgeriesChart(context, theme),
          ],

          // Recent activity section
          SectionHeader(
            title: 'Recent Activity',
            actionLabel: 'View all',
            onAction: () {
              // TODO: Navigate to activity log
            },
          ),
          RecentActivityList(activities: metrics.recentActivities),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Analytics'),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                if (metrics.treatmentsByType.isNotEmpty)
                  Expanded(
                    child: _buildPieChart(
                      context,
                      title: 'Treatments',
                      data: metrics.treatmentsByType.entries
                          .map((e) => _ChartData(e.key, e.value))
                          .toList(),
                    ),
                  ),
                if (metrics.treatmentsByType.isNotEmpty &&
                    metrics.patientsByStatus.isNotEmpty)
                  const SizedBox(width: AppSpacing.sm),
                if (metrics.patientsByStatus.isNotEmpty)
                  Expanded(
                    child: _buildPieChart(
                      context,
                      title: 'Patients',
                      data: metrics.patientsByStatus.entries
                          .map((e) => _ChartData(e.key, e.value))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    BuildContext context, {
    required String title,
    required List<_ChartData> data,
  }) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (d, _) => d.label,
                    yValueMapper: (d, _) => d.value,
                    dataLabelMapper: (d, _) => '${d.value}',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      connectorLineSettings: ConnectorLineSettings(
                        type: ConnectorType.curve,
                      ),
                    ),
                    radius: '65%',
                    explode: true,
                    explodeIndex: 0,
                    explodeOffset: '5%',
                  ),
                ],
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                margin: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurgeriesChart(BuildContext context, ThemeData theme) {
    final data = metrics.surgeriesByDay
        .map((d) => _ChartData(d.day.substring(5), d.count))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: SizedBox(
            height: 200,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelRotation: -45,
                axisLabelSettings: AxisLabelSettings(
                  style: theme.textTheme.labelSmall!,
                ),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0,
                axisLabelSettings: AxisLabelSettings(
                  style: theme.textTheme.labelSmall!,
                ),
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <CartesianSeries>[
                ColumnSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.label,
                  yValueMapper: (d, _) => d.value,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                  ),
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              margin: const EdgeInsets.all(AppSpacing.xs),
            ),
          ),
        ),
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

/// Simple chart data point.
class _ChartData {
  _ChartData(this.label, this.value);
  final String label;
  final int value;
}
