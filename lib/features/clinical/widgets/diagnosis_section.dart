import 'package:flutter/material.dart';
import '../../../app/theme/spacing.dart';
import '../../../shared/widgets/data_card.dart';

/// Diagnosis section for treatment detail screen.
class DiagnosisSection extends StatelessWidget {
  const DiagnosisSection({
    super.key,
    required this.diagnoses,
    this.onAdd,
  });

  final List<Map<String, dynamic>> diagnoses;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Diagnoses',
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
        if (diagnoses.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text('No diagnoses recorded',
                style: theme.textTheme.bodySmall),
          )
        else
          ...diagnoses.asMap().entries.map((entry) {
            final d = entry.value;
            final isPrimary = d['diagnosis_type'] == 'PRIMARY';
            return DataCard(
              title: d['diagnosis'] as String? ?? '',
              subtitle: '${d['diagnosed_by_name'] ?? 'Unknown'}'
                  ' · ${_formatDate(d['diagnosed_at'] as String?)}',
              trailing: isPrimary
                  ? StatusBadge(label: 'PRIMARY', small: true)
                  : null,
            );
          }),
      ],
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

import '../../../shared/widgets/status_badge.dart';
