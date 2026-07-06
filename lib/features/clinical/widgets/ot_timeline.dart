import 'package:flutter/material.dart';
import '../../../app/theme/spacing.dart';
import '../../../app/theme/radius.dart';
import '../../../shared/widgets/status_badge.dart';

/// OT Timeline widget showing scheduled surgeries.
class OTTimeline extends StatelessWidget {
  const OTTimeline({
    super.key,
    required this.schedules,
    this.onScheduleTap,
    this.emptyMessage = 'No scheduled surgeries',
  });

  final List<Map<String, dynamic>> schedules;
  final void Function(Map<String, dynamic>)? onScheduleTap;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Icon(Icons.schedule, size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
              const SizedBox(height: AppSpacing.sm),
              Text(emptyMessage,
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: schedules.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final patient = schedule['patients'] as Map<String, dynamic>?;
        final theatre = schedule['operating_theatres'] as Map<String, dynamic>?;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              _timeLabel(schedule['scheduled_start'] as String?),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          title: Text(
            patient?['full_name'] as String? ?? 'Unknown Patient',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${schedule['procedure'] ?? 'No procedure'}'
            '${theatre?['theatre_room'] != null ? ' · ${theatre!['theatre_room']}' : ''}',
          ),
          trailing: StatusBadge(
            label: schedule['status'] as String? ?? 'SCHEDULED',
          ),
          onTap: onScheduleTap != null
              ? () => onScheduleTap!(schedule)
              : null,
        );
      },
    );
  }

  String _timeLabel(String? iso) {
    if (iso == null) return '--:--';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
