import 'package:flutter/material.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/radius.dart';
import '../../../shared/widgets/status_badge.dart';

/// Treatment card widget for list display.
class TreatmentCard extends StatelessWidget {
  const TreatmentCard({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.treatmentType,
    required this.status,
    this.hospitalName,
    this.diagnosis,
    this.admissionDate,
    this.onTap,
  });

  final String patientName;
  final String patientId;
  final String treatmentType;
  final String status;
  final String? hospitalName;
  final String? diagnosis;
  final DateTime? admissionDate;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DataCard(
      onTap: onTap,
      title: patientName,
      subtitle: diagnosis ?? 'No diagnosis recorded',
      trailing: StatusBadge(label: status),
      children: [
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            _InfoChip(
              icon: Icons.medical_services_outlined,
              label: treatmentType,
            ),
            const SizedBox(width: AppSpacing.sm),
            if (hospitalName != null)
              _InfoChip(
                icon: Icons.local_hospital_outlined,
                label: hospitalName!,
              ),
          ],
        ),
        if (admissionDate != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                _formatDate(admissionDate!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
            label[0].toUpperCase() + label.substring(1).toLowerCase(),
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
