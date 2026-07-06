import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/models/models.dart';
import 'package:helpster_care/shared/widgets/status_badge.dart';

/// Displays the timeline of patient status changes.
class PatientStatusTimeline extends StatelessWidget {
  const PatientStatusTimeline({
    super.key,
    required this.statusHistory,
  });

  final List<PatientStatusHistory> statusHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (statusHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'No status changes recorded.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: statusHistory.length,
      itemBuilder: (context, index) {
        final entry = statusHistory[index];
        final isFirst = index == 0;
        final isLast = index == statusHistory.length - 1;

        return _StatusTimelineItem(
          entry: entry,
          isFirst: isFirst,
          isLast: isLast,
        );
      },
    );
  }
}

class _StatusTimelineItem extends StatelessWidget {
  const _StatusTimelineItem({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final PatientStatusHistory entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final diff = now.difference(entry.changedAt);
    final timeAgo = _formatTimeAgo(diff);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
                Container(
                  width: isFirst ? 16 : 12,
                  height: isFirst ? 16 : 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFirst
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    border: isFirst
                        ? Border.all(
                            color: theme.colorScheme.primaryContainer,
                            width: 3,
                          )
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isFirst
                    ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                    : null,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (entry.fromStatus != null)
                        Flexible(
                          child: StatusBadge(
                            label: _humanize(entry.fromStatus!),
                            small: true,
                          ),
                        ),
                      if (entry.fromStatus != null) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Flexible(
                        child: StatusBadge(
                          label: _humanize(entry.toStatus),
                          small: true,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeAgo,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (entry.reason != null && entry.reason!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      entry.reason!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (entry.changedBy != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'by ${entry.changedBy}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _humanize(String status) {
    return status
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  String _formatTimeAgo(Duration diff) {
    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '${months}mo ago';
    }
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
