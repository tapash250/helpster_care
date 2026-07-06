import 'package:flutter/material.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/radius.dart';
import '../../../shared/widgets/status_badge.dart';

/// Approval card widget for list display.
class ApprovalCard extends StatelessWidget {
  const ApprovalCard({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.currentState,
    required this.priority,
    this.submittedByName,
    this.createdAt,
    this.onTap,
  });

  final String patientName;
  final String patientId;
  final String currentState;
  final String priority;
  final String? submittedByName;
  final DateTime? createdAt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighPriority = priority.toUpperCase() == 'HIGH' ||
        priority.toUpperCase() == 'URGENT';

    return DataCard(
      onTap: onTap,
      title: patientName,
      subtitle: 'ID: $patientId',
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusBadge(label: currentState),
          if (isHighPriority) ...[
            const SizedBox(height: 4),
            StatusBadge(label: priority, color: Colors.deepOrange),
          ],
        ],
      ),
      children: [
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            if (submittedByName != null)
              _InfoChip(
                icon: Icons.person_outline,
                label: submittedByName!,
              ),
            if (submittedByName != null && createdAt != null)
              const SizedBox(width: AppSpacing.sm),
            if (createdAt != null)
              _InfoChip(
                icon: Icons.calendar_today,
                label:
                    '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}',
              ),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
