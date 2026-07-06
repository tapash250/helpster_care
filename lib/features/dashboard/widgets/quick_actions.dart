import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';

/// Quick action buttons for common dashboard tasks.
///
/// Displays a row of styled action chips that navigate to
/// key app sections.
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    this.onCreatePatient,
    this.onViewHospitals,
    this.onViewApprovals,
    this.onViewReports,
  });

  /// Create a new patient.
  final VoidCallback? onCreatePatient;

  /// Navigate to hospital list.
  final VoidCallback? onViewHospitals;

  /// Navigate to approval queue.
  final VoidCallback? onViewApprovals;

  /// Navigate to reports.
  final VoidCallback? onViewReports;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _ActionChip(
              icon: Icons.person_add_alt_1,
              label: 'New Patient',
              color: Colors.blue,
              onTap: onCreatePatient,
            ),
            const SizedBox(width: AppSpacing.sm),
            _ActionChip(
              icon: Icons.local_hospital_outlined,
              label: 'Hospitals',
              color: Colors.teal,
              onTap: onViewHospitals,
            ),
            const SizedBox(width: AppSpacing.sm),
            _ActionChip(
              icon: Icons.pending_outlined,
              label: 'Approvals',
              color: Colors.orange,
              onTap: onViewApprovals,
            ),
            const SizedBox(width: AppSpacing.sm),
            _ActionChip(
              icon: Icons.assessment_outlined,
              label: 'Reports',
              color: Colors.indigo,
              onTap: onViewReports,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        side: BorderSide(
          color: color.withOpacity(0.3),
        ),
      ),
      backgroundColor: color.withOpacity(0.08),
    );
  }
}
