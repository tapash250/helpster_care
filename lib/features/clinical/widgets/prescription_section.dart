import 'package:flutter/material.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/widgets/data_card.dart';

/// Prescription section for treatment detail screen.
class PrescriptionSection extends StatelessWidget {
  const PrescriptionSection({
    super.key,
    required this.prescriptions,
    this.onAdd,
  });

  final List<Map<String, dynamic>> prescriptions;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Prescriptions',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            if (onAdd != null)
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
          ],
        ),
        if (prescriptions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text('No prescriptions recorded',
                style: theme.textTheme.bodySmall),
          )
        else
          ...prescriptions.asMap().entries.map((entry) {
            final p = entry.value;
            return DataCard(
              title: p['medication'] as String? ?? '',
              subtitle: [
                if (p['dosage'] != null) p['dosage'],
                if (p['frequency'] != null) p['frequency'],
                if (p['duration'] != null) p['duration'],
              ].where((s) => s!.isNotEmpty).join(' · '),
            );
          }),
      ],
    );
  }
}
