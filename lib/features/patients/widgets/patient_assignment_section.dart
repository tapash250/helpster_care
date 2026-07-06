import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/models/models.dart';
import 'package:helpster_care/shared/widgets/section_header.dart';

/// Displays patient assignments (doctors, volunteers, etc.).
class PatientAssignmentSection extends StatelessWidget {
  const PatientAssignmentSection({
    super.key,
    required this.assignments,
  });

  final List<PatientAssignment> assignments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (assignments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'No assignments yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final activeAssignments =
        assignments.where((a) => a.isActive).toList();
    final pastAssignments =
        assignments.where((a) => !a.isActive).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const SectionHeader(title: 'Active Assignments'),
        if (activeAssignments.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'No active assignments.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...activeAssignments.map((a) => _AssignmentCard(assignment: a)),

        if (pastAssignments.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Past Assignments'),
          ...pastAssignments.map((a) => _AssignmentCard(
                assignment: a,
                isPast: true,
              )),
        ],
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.assignment,
    this.isPast = false,
  });

  final PatientAssignment assignment;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _iconForType(assignment.assignmentType);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPast
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: isPast
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          assignment.userName ?? assignment.userId,
          style: TextStyle(
            fontWeight: isPast ? FontWeight.normal : FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _humanizeType(assignment.assignmentType),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: isPast
            ? Chip(
                label: const Text('Inactive'),
                visualDensity: VisualDensity.compact,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              )
            : Chip(
                label: const Text('Active'),
                visualDensity: VisualDensity.compact,
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'DOCTOR':
      case 'PRIMARY_DOCTOR':
        return Icons.medical_services;
      case 'VOLUNTEER':
        return Icons.volunteer_activism;
      case 'CASE_WORKER':
        return Icons.assignment_ind;
      case 'NURSE':
        return Icons.local_hospital;
      case 'COUNSELOR':
        return Icons.psychology;
      default:
        return Icons.person;
    }
  }

  String _humanizeType(String type) {
    return type
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}
