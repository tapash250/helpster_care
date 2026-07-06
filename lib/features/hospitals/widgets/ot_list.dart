import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/empty_state.dart';
import 'package:helpster_care/shared/widgets/status_badge.dart';

/// Displays a list of operating theatre schedules for a hospital.
///
/// Each OT entry shows the theatre room, procedure, patient, schedule time,
/// and status.
class OTList extends StatelessWidget {
  const OTList({
    super.key,
    required this.schedules,
    this.onTap,
    this.isLoading = false,
  });

  final List<Map<String, dynamic>> schedules;
  final void Function(Map<String, dynamic>)? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (schedules.isEmpty) {
      return const EmptyState(
        title: 'No OT Schedules',
        subtitle: 'No surgeries scheduled.',
        icon: Icons.surgical_outlined,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        return _OTTile(
          schedule: schedule,
          onTap: onTap != null ? () => onTap!(schedule) : null,
        );
      },
    );
  }
}

class _OTTile extends StatelessWidget {
  const _OTTile({
    required this.schedule,
    this.onTap,
  });

  final Map<String, dynamic> schedule;
  final VoidCallback? onTap;

  String _formatTime(String? isoString) {
    if (isoString == null) return '—';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return isoString;
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = schedule['theatre_room'] as String? ?? '—';
    final procedure = schedule['procedure'] as String? ?? 'Procedure';
    final surgeon = schedule['primary_surgeon_name'] as String?;
    final status = schedule['status'] as String? ?? 'SCHEDULED';
    final scheduledStart = schedule['scheduled_start'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.surgical_outlined,
                  color: theme.colorScheme.onErrorContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'OT: $room',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        StatusBadge(label: status, small: true),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      procedure,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (surgeon != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Surgeon: $surgeon',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (scheduledStart != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${_formatDate(scheduledStart)} ${_formatTime(scheduledStart)}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
