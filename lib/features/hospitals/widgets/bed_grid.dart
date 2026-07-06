import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/models/bed.dart';
import 'package:helpster_care/shared/widgets/empty_state.dart';

/// Displays a grid of hospital beds.
///
/// Each bed is shown as a colored tile: green for available, red for occupied,
/// orange for reserved. Tapping a bed triggers [onBedTap].
class BedGrid extends StatelessWidget {
  const BedGrid({
    super.key,
    required this.beds,
    this.onBedTap,
    this.onAdd,
    this.onEdit,
    this.isLoading = false,
  });

  final List<Bed> beds;
  final void Function(Bed)? onBedTap;
  final VoidCallback? onAdd;
  final void Function(Bed)? onEdit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (beds.isEmpty) {
      return EmptyState(
        title: 'No Beds',
        subtitle: 'Add a bed to this ward.',
        icon: Icons.hotel_outlined,
        actionLabel: 'Add Bed',
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
                  '${beds.length} bed${beds.length == 1 ? '' : 's'}',
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
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemCount: beds.length,
            itemBuilder: (context, index) {
              final bed = beds[index];
              return _BedTile(
                bed: bed,
                onTap: onBedTap != null ? () => onBedTap!(bed) : null,
                onEdit: onEdit != null ? () => onEdit!(bed) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BedTile extends StatelessWidget {
  const _BedTile({
    required this.bed,
    this.onTap,
    this.onEdit,
  });

  final Bed bed;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AVAILABLE':
        return Colors.green;
      case 'OCCUPIED':
        return Colors.red;
      case 'RESERVED':
        return Colors.orange;
      case 'MAINTENANCE':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(bed.status);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onEdit,
      child: Container(
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.10),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: statusColor.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              bed.status == 'OCCUPIED'
                  ? Icons.person
                  : Icons.hotel_outlined,
              size: 18,
              color: statusColor,
            ),
            const SizedBox(height: 2),
            Text(
              bed.bedNumber,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
