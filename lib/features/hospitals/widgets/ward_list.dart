import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/models/ward.dart';
import 'package:helpster_care/shared/widgets/empty_state.dart';

/// Displays a list of wards for a hospital.
///
/// Each ward row shows the ward name, capacity info, and actions.
class WardList extends StatelessWidget {
  const WardList({
    super.key,
    required this.wards,
    this.onTap,
    this.onAdd,
    this.onEdit,
    this.onDelete,
    this.isLoading = false,
  });

  final List<Ward> wards;
  final void Function(Ward)? onTap;
  final VoidCallback? onAdd;
  final void Function(Ward)? onEdit;
  final void Function(Ward)? onDelete;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wards.isEmpty) {
      return EmptyState(
        title: 'No Wards',
        subtitle: 'Add a ward to get started.',
        icon: Icons.bed_outlined,
        actionLabel: 'Add Ward',
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
                  '${wards.length} ward${wards.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
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
        ...wards.map((ward) => _WardTile(
              ward: ward,
              onTap: onTap != null ? () => onTap!(ward) : null,
              onEdit: onEdit != null ? () => onEdit!(ward) : null,
              onDelete: onDelete != null ? () => onDelete!(ward) : null,
            )),
      ],
    );
  }
}

class _WardTile extends StatelessWidget {
  const _WardTile({
    required this.ward,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Ward ward;
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
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.bed_outlined,
            color: theme.colorScheme.onTertiaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          ward.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: ward.description != null
            ? Text(
                ward.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Capacity badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'Cap: ${ward.capacity}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
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
