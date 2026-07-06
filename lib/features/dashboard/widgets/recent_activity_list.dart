import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/features/dashboard/models/dashboard_metrics.dart';

/// Displays a timeline of recent activity entries.
class RecentActivityList extends StatelessWidget {
  const RecentActivityList({
    super.key,
    required this.activities,
  });

  /// Activity entries to display.
  final List<ActivitySummary> activities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            'No recent activity',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _ActivityTile(activity: activity);
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final ActivitySummary activity;

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'patient_created':
      case 'patient_registered':
        return Icons.person_add_outlined;
      case 'treatment_started':
        return Icons.medical_services_outlined;
      case 'approval_submitted':
        return Icons.task_alt;
      case 'surgery_scheduled':
        return Icons.calendar_month_outlined;
      case 'followup_scheduled':
        return Icons.event_note_outlined;
      case 'discharge':
        return Icons.exit_to_app;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _colorForType(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'patient_created':
      case 'patient_registered':
        return Colors.blue;
      case 'treatment_started':
        return Colors.teal;
      case 'approval_submitted':
        return Colors.orange;
      case 'surgery_scheduled':
        return Colors.indigo;
      case 'followup_scheduled':
        return Colors.purple;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _timeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.month}/${timestamp.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _iconForType(activity.type);
    final color = _colorForType(activity.type, theme);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activity.userName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      activity.userName!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              _timeAgo(activity.timestamp),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
