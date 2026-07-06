import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/app/theme/spacing.dart';

/// Color-coded status badge for patient/appointment/workflow statuses.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.small = false,
  });

  final String label;
  final Color? color;
  final bool small;

  /// Returns a color for common status values.
  static Color colorForStatus(String status) {
    switch (status.toUpperCase()) {
      case 'DRAFT':
      case 'SCHEDULED':
        return Colors.grey;
      case 'PENDING_DOCUMENTS':
      case 'SUBMITTED':
      case 'UNDER_REVIEW':
      case 'MEDICAL_REVIEW':
        return Colors.orange;
      case 'APPROVED':
      case 'CONFIRMED':
      case 'ACTIVE':
        return Colors.blue;
      case 'ADMITTED':
      case 'IN_TREATMENT':
      case 'IN_PROGRESS':
        return Colors.teal;
      case 'COMPLETED':
      case 'DISCHARGED':
        return Colors.green;
      case 'REJECTED':
      case 'CANCELLED':
      case 'MISSED':
        return Colors.red;
      case 'CLOSED':
        return Colors.blueGrey;
      case 'FOLLOWUP':
        return Colors.purple;
      case 'AVAILABLE':
        return Colors.green;
      case 'OCCUPIED':
        return Colors.red;
      case 'RESERVED':
        return Colors.orange;
      case 'URGENT':
      case 'HIGH':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? colorForStatus(label);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? AppSpacing.sm : AppSpacing.sm + 2,
        vertical: small ? 2 : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: effectiveColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: effectiveColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
