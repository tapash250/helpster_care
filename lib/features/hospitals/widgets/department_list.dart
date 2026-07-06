import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/models/department.dart';
import 'package:helpster_care/shared/widgets/empty_state.dart';

/// Displays a list of departments for a hospital.
///
/// Each department row shows the department name, description, and
/// an optional action to edit or delete.
class DepartmentList extends StatelessWidget {
  const DepartmentList({
    super.key,
    required this.departments,
    this.onTap,
    this.onAdd,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
  });

  final List<Department> departments;
  final void Function(Department)? onTap;
  final VoidCallback? onAdd;
  final void Function(Department)? onEdit;
  final void Function(Department)? onDelete;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (departments.isEmpty) {
      return EmptyState(
        title: 'No Departments',
        subtitle: 'Add a department to get started.',
        icon: Icons.business_outlined,
        actionLabel: 'Add Department',
        onAction: onAdd,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onAdd != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Text(
                  '${departments.length} department${departments.length == 1 ? '' : 's'}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        ...departments.map((dept) => _DepartmentTile(
              department: dept,
              onTap: onTap != null ? () => onTap!(dept) : null,
              onEdit: onEdit != null ? () => onEdit!(dept) : null,
              onDelete: onDelete != null ? () => onDelete!(dept) : null,
            )),
      ],
    );
  }
}

class _DepartmentTile extends StatelessWidget {
  const _DepartmentTile({
    required this.department,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Department department;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.meeting_room_outlined,
            color: theme.colorScheme.onSecondaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          department.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: department.description != null
            ? Text(
                department.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
              ),
            if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}
