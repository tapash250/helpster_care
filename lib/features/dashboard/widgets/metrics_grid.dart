import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/features/dashboard/widgets/metric_card.dart';

/// A responsive grid of [MetricCard] widgets.
///
/// Adapts columns based on screen width: 4 on large, 2 on medium, 2 on small.
class MetricsGrid extends StatelessWidget {
  const MetricsGrid({
    super.key,
    required this.metrics,
  });

  /// List of metric card data to display.
  final List<_MetricItem> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.1,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final m = metrics[index];
            return MetricCard(
              icon: m.icon,
              value: m.value,
              label: m.label,
              color: m.color,
              subtitle: m.subtitle,
              onTap: m.onTap,
            );
          },
        );
      },
    );
  }
}

/// Data for a single metric card in the grid.
class _MetricItem {
  const _MetricItem({
    required this.icon,
    required this.value,
    required this.label,
    this.color,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;
}

/// Helper to build metric items from [DashboardMetrics].
_MetricItem _buildMetricItem({
  required IconData icon,
  required String value,
  required String label,
  Color? color,
  String? subtitle,
  VoidCallback? onTap,
}) {
  return _MetricItem(
    icon: icon,
    value: value,
    label: label,
    color: color,
    subtitle: subtitle,
    onTap: onTap,
  );
}

/// Constructs the standard list of dashboard metric items.
List<_MetricItem> buildDashboardMetrics({
  required String totalPatients,
  required String activeTreatments,
  required String pendingApprovals,
  required String todaySurgeries,
  required String recentFollowups,
  required String availableBeds,
  String? occupancyRate,
  Color? occupancyColor,
}) {
  return [
    _buildMetricItem(
      icon: Icons.people_outline,
      value: totalPatients,
      label: 'Total Patients',
      color: Colors.blue,
    ),
    _buildMetricItem(
      icon: Icons.medical_services_outlined,
      value: activeTreatments,
      label: 'Active Treatments',
      color: Colors.teal,
    ),
    _buildMetricItem(
      icon: Icons.pending_actions,
      value: pendingApprovals,
      label: 'Pending Approvals',
      color: Colors.orange,
    ),
    _buildMetricItem(
      icon: Icons.local_hospital_outlined,
      value: todaySurgeries,
      label: "Today's Surgeries",
      color: Colors.indigo,
    ),
    _buildMetricItem(
      icon: Icons.event_note_outlined,
      value: recentFollowups,
      label: 'Upcoming Follow-ups',
      color: Colors.purple,
    ),
    _buildMetricItem(
      icon: Icons.hotel_outlined,
      value: availableBeds,
      label: 'Available Beds',
      color: Colors.green,
      subtitle: occupancyRate,
    ),
  ];
}

/// Public helper to build metric items from dashboard data.
List<_MetricItem> buildMetricItems({
  required String totalPatients,
  required String activeTreatments,
  required String pendingApprovals,
  required String todaySurgeries,
  required String recentFollowups,
  required String availableBeds,
  String? occupancyRate,
  Color? occupancyColor,
}) {
  return buildDashboardMetrics(
    totalPatients: totalPatients,
    activeTreatments: activeTreatments,
    pendingApprovals: pendingApprovals,
    todaySurgeries: todaySurgeries,
    recentFollowups: recentFollowups,
    availableBeds: availableBeds,
    occupancyRate: occupancyRate,
    occupancyColor: occupancyColor,
  );
}
