import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/widgets.dart';
import 'package:helpster_care/features/clinical/providers/treatment_providers.dart';
import 'package:helpster_care/features/clinical/controllers/ot_controller.dart';
import 'package:helpster_care/features/clinical/widgets/ot_timeline.dart';

/// Calendar-like schedule screen for OT slots with status actions.
class OTScheduleScreen extends ConsumerStatefulWidget {
  const OTScheduleScreen({super.key});

  @override
  ConsumerState<OTScheduleScreen> createState() => _OTScheduleScreenState();
}

class _OTScheduleScreenState extends ConsumerState<OTScheduleScreen> {
  String? _hospitalId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schedulesAsync = ref.watch(otScheduleListProvider(_hospitalId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('OT Schedule'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(otScheduleListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.today,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Today - ${_todayDate()}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_scheduleCount} surgeries',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Status legend
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                _LegendDot(color: Colors.teal, label: 'In Progress'),
                const SizedBox(width: AppSpacing.sm),
                _LegendDot(color: Colors.blue, label: 'Scheduled'),
                const SizedBox(width: AppSpacing.sm),
                _LegendDot(color: Colors.green, label: 'Completed'),
                const SizedBox(width: AppSpacing.sm),
                _LegendDot(color: Colors.red, label: 'Cancelled'),
              ],
            ),
          ),

          const Divider(height: 1),

          // OT schedule list
          Expanded(
            child: AsyncValueWidget<List<Map<String, dynamic>>>(
              value: schedulesAsync,
              data: (schedules) {
                final count = _scheduleCount = schedules.length;
                if (count == 0) {
                  return const EmptyState(
                    title: 'No OT schedules',
                    subtitle:
                        'There are no scheduled surgeries for today or upcoming.',
                    icon: Icons.schedule,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(otScheduleListProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      bottom: AppSpacing.xxl,
                    ),
                    itemCount: schedules.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final s = schedules[index];
                      final patient =
                          s['patients'] as Map<String, dynamic>?;
                      final theatre = s['operating_theatres']
                          as Map<String, dynamic>?;
                      final status =
                          s['status'] as String? ?? 'SCHEDULED';
                      final scheduledStart = s['scheduled_start'] as String?;

                      return _OTScheduleItem(
                        patientName:
                            patient?['full_name'] as String? ??
                                'Unknown',
                        patientId:
                            patient?['patient_id'] as String? ?? '',
                        procedure:
                            s['procedure'] as String? ?? 'No procedure',
                        theatreRoom:
                            theatre?['theatre_room'] as String?,
                        scheduledStart: scheduledStart != null
                            ? DateTime.tryParse(scheduledStart)
                            : null,
                        scheduledEnd: s['scheduled_end'] != null
                            ? DateTime.tryParse(
                                s['scheduled_end'] as String)
                            : null,
                        status: status,
                        primarySurgeon:
                            s['primary_surgeon_name'] as String?,
                        onStart: status == 'SCHEDULED'
                            ? () => _startOT(s['id'] as String)
                            : null,
                        onComplete: status == 'IN_PROGRESS'
                            ? () => _completeOT(s['id'] as String)
                            : null,
                        onCancel: status != 'COMPLETED' &&
                                status != 'CANCELLED'
                            ? () => _cancelOT(s['id'] as String)
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _scheduleCount = 0;

  String _todayDate() {
    final now = DateTime.now();
    final days = [
      'Sun',
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
    ];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[now.weekday % 7]}, '
        '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _startOT(String scheduleId) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Start Surgery',
      message: 'Mark this OT as in-progress?',
      confirmLabel: 'Start',
    );
    if (confirmed == true) {
      final success =
          await ref.read(otControllerProvider.notifier).startOT(scheduleId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'OT marked as in-progress'
                : 'Failed to start OT',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _completeOT(String scheduleId) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Complete Surgery',
      message: 'Mark this OT as completed?',
      confirmLabel: 'Complete',
    );
    if (confirmed == true) {
      final success = await ref
          .read(otControllerProvider.notifier)
          .completeOT(scheduleId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'OT marked as completed'
                : 'Failed to complete OT',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelOT(String scheduleId) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Cancel Surgery',
      message: 'Are you sure you want to cancel this OT?',
      confirmLabel: 'Cancel',
      isDestructive: true,
    );
    if (confirmed == true) {
      final success = await ref
          .read(otControllerProvider.notifier)
          .cancelOT(scheduleId, 'Cancelled by clinician');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'OT cancelled'
                : 'Failed to cancel OT',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}

class _OTScheduleItem extends StatelessWidget {
  const _OTScheduleItem({
    required this.patientName,
    required this.patientId,
    required this.procedure,
    this.theatreRoom,
    this.scheduledStart,
    this.scheduledEnd,
    required this.status,
    this.primarySurgeon,
    this.onStart,
    this.onComplete,
    this.onCancel,
  });

  final String patientName;
  final String patientId;
  final String procedure;
  final String? theatreRoom;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String status;
  final String? primarySurgeon;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(scheduledStart),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (scheduledEnd != null)
                  Text(
                    _formatTime(scheduledEnd),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),

          // Vertical line
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _statusColor(status),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: theme.dividerColor.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            patientName,
                            style:
                                theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        StatusBadge(label: status, small: true),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Procedure
                    Text(
                      procedure,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),

                    // Details
                    if (theatreRoom != null || primarySurgeon != null)
                      Text(
                        [
                          if (theatreRoom != null) 'Room $theatreRoom',
                          if (primarySurgeon != null) primarySurgeon,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                    // Action buttons
                    if (onStart != null ||
                        onComplete != null ||
                        onCancel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Row(
                          children: [
                            if (onStart != null)
                              _ActionChip(
                                label: 'Start',
                                icon: Icons.play_arrow,
                                color: Colors.teal,
                                onTap: onStart!,
                              ),
                            if (onComplete != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              _ActionChip(
                                label: 'Complete',
                                icon: Icons.check,
                                color: Colors.green,
                                onTap: onComplete!,
                              ),
                            ],
                            if (onCancel != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              _ActionChip(
                                label: 'Cancel',
                                icon: Icons.close,
                                color: Colors.red,
                                onTap: onCancel!,
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
        return Colors.teal;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
