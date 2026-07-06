import 'package:flutter/material.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/widgets/status_badge.dart';

/// Follow-up card widget.
class FollowupCard extends StatelessWidget {
  const FollowupCard({
    super.key,
    required this.patientName,
    required this.followupDate,
    required this.status,
    this.doctorName,
    this.instructions,
    this.outcome,
    this.onTap,
  });

  final String patientName;
  final DateTime followupDate;
  final String status;
  final String? doctorName;
  final String? instructions;
  final String? outcome;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue =
        status == 'SCHEDULED' && followupDate.isBefore(DateTime.now());

    return DataCard(
      onTap: onTap,
      title: patientName,
      subtitle: doctorName != null ? 'Dr. $doctorName' : null,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(label: status),
          if (isOverdue) ...[
            const SizedBox(height: 4),
            StatusBadge(label: 'OVERDUE', color: Colors.red),
          ],
        ],
      ),
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today,
                size: 14, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              '${followupDate.day}/${followupDate.month}/${followupDate.year}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        if (instructions != null && instructions!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            instructions!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
