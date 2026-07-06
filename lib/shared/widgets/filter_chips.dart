import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';

/// A row of filter chips for selecting from a list of options.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    this.onSelected,
    this.label,
    this.allowMultiple = true,
  });

  /// Option items with label and value.
  final List<FilterChipOption> options;

  /// Currently selected value(s).
  final Set<String> selected;

  /// Callback when selection changes.
  final void Function(Set<String>)? onSelected;

  /// Label displayed above the chips.
  final String? label;

  /// Whether multiple chips can be selected.
  final bool allowMultiple;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xs),
            child: Text(
              label!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: options.map((option) {
            final isSelected = selected.contains(option.value);
            return FilterChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (isSelected) {
                if (onSelected == null) return;
                final newSelection = Set<String>.from(selected);
                if (allowMultiple) {
                  if (isSelected) {
                    newSelection.add(option.value);
                  } else {
                    newSelection.remove(option.value);
                  }
                } else {
                  newSelection.clear();
                  if (isSelected) newSelection.add(option.value);
                }
                onSelected!(newSelection);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// A single filter chip option.
class FilterChipOption {
  const FilterChipOption({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}
