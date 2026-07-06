import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/shared/models/patient.dart';
import 'package:helpster_care/shared/widgets/status_badge.dart';
import 'package:helpster_care/features/patients/routes/patient_routes.dart';

/// A card widget for displaying a patient in a list.
class PatientCard extends StatelessWidget {
  const PatientCard({
    super.key,
    required this.patient,
  });

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: () => context.push(PatientRoutes.detailPath(patient.id)),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Avatar / photo
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: patient.photoPath != null
                    ? ClipOval(
                        child: Image.network(
                          patient.photoPath!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _defaultAvatar(theme),
                        ),
                      )
                    : _defaultAvatar(theme),
              ),
              const SizedBox(width: AppSpacing.md),
              // Patient info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      patient.patientId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (patient.dateOfBirth != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatAge(patient.dateOfBirth!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              StatusBadge(label: _humanizeStatus(patient.status)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar(ThemeData theme) {
    return Icon(
      Icons.person,
      size: 28,
      color: theme.colorScheme.onPrimaryContainer,
    );
  }

  String _formatAge(DateTime dob) {
    final now = DateTime.now();
    int years = now.year - dob.year;
    int months = now.month - dob.month;
    if (months < 0) {
      years--;
      months += 12;
    }
    if (years > 0) {
      return '$years years, $months months';
    }
    return '$months months';
  }

  /// Convert snake_case status to human-readable.
  static String humanizeStatus(String status) {
    return status
        .split('_')
        .map((word) =>
            word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '')
        .join(' ');
  }

  String _humanizeStatus(String status) => humanizeStatus(status);
}
