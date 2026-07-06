import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/widgets.dart';
import 'package:helpster_care/features/clinical/providers/treatment_providers.dart';
import 'package:helpster_care/features/clinical/controllers/followup_controller.dart';
import 'package:helpster_care/features/clinical/widgets/followup_card.dart';

/// Screen listing follow-ups with overdue highlighting and completion action.
class FollowupListScreen extends ConsumerStatefulWidget {
  const FollowupListScreen({super.key, this.patientId});

  /// Optional patient ID to scope follow-ups to a single patient.
  final String? patientId;

  @override
  ConsumerState<FollowupListScreen> createState() =>
      _FollowupListScreenState();
}

class _FollowupListScreenState extends ConsumerState<FollowupListScreen> {
  String? _selectedPatientId;
  Set<String> _selectedStatuses = {};

  static const _statusOptions = [
    FilterChipOption(label: 'Scheduled', value: 'SCHEDULED'),
    FilterChipOption(label: 'Completed', value: 'COMPLETED'),
    FilterChipOption(label: 'Missed', value: 'MISSED'),
    FilterChipOption(label: 'Cancelled', value: 'CANCELLED'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.patientId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // When no patient ID is provided, show a helpful message
    if (_selectedPatientId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Follow-ups'),
          centerTitle: false,
        ),
        body: const EmptyState(
          title: 'Select a Patient',
          subtitle: 'View follow-ups from a patient or treatment detail screen.',
          icon: Icons.follow_the_signs_outlined,
        ),
      );
    }

    final followupsAsync = ref.watch(followupListProvider(_selectedPatientId!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow-ups'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(followupListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          if (_selectedPatientId == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: FilterChips(
                label: 'Status',
                options: _statusOptions,
                selected: _selectedStatuses,
                onSelected: (selected) {
                  setState(() => _selectedStatuses = selected);
                },
              ),
            ),

          // Summary bar
          AsyncValueWidget<List<Map<String, dynamic>>>(
            value: followupsAsync,
            data: (followups) {
              final overdueCount =
                  followups.where((f) => _isOverdue(f)).length;
              final scheduledCount =
                  followups.where((f) => f['status'] == 'SCHEDULED').length;

              if (followups.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: overdueCount > 0
                      ? Colors.red.withOpacity(0.08)
                      : theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.summarize,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '$scheduledCount scheduled',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (overdueCount > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '$overdueCount overdue',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          // Follow-up list
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final followupsAsync2 =
                    ref.watch(followupListProvider(_selectedPatientId!));
                return AsyncValueWidget<List<Map<String, dynamic>>>(
                  value: followupsAsync2,
                  data: (followups) {
                    var filtered = followups.toList();

                    // Apply status filter
                    if (_selectedStatuses.isNotEmpty) {
                      filtered = filtered
                          .where((f) =>
                              _selectedStatuses
                                  .contains(f['status'] as String? ?? ''))
                          .toList();
                    }

                    if (filtered.isEmpty) {
                      return const EmptyState(
                        title: 'No follow-ups found',
                        subtitle:
                            'Follow-up visits will appear here once scheduled.',
                        icon: Icons.follow_the_signs_outlined,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(followupListProvider);
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.xxl,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final f = filtered[index];
                          final isOverdue = _isOverdue(f);
                          final followupDate =
                              f['followup_date'] as String?;

                          return Opacity(
                            opacity: f['status'] == 'COMPLETED' ? 0.6 : 1.0,
                            child: FollowupCard(
                              patientName:
                                  f['patients']?['full_name'] as String? ??
                                      f['patient_id'] as String? ??
                                      'Unknown',
                              followupDate: followupDate != null
                                  ? DateTime.parse(followupDate)
                                  : DateTime.now(),
                              status:
                                  f['status'] as String? ?? 'SCHEDULED',
                              doctorName:
                                  f['doctor_name'] as String?,
                              instructions:
                                  f['instructions'] as String?,
                              outcome: f['outcome'] as String?,
                              onTap: () =>
                                  _showFollowupActions(f),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isOverdue(Map<String, dynamic> followup) {
    if (followup['status'] != 'SCHEDULED') return false;
    final dateStr = followup['followup_date'] as String?;
    if (dateStr == null) return false;
    final date = DateTime.tryParse(dateStr);
    return date != null && date.isBefore(DateTime.now());
  }

  void _showFollowupActions(Map<String, dynamic> followup) {
    final id = followup['id'] as String? ?? '';
    final status = followup['status'] as String? ?? '';
    final outcome = followup['outcome'] as String?;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Follow-up Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (status == 'SCHEDULED') ...[
                ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: Colors.green),
                  title: const Text('Mark as Completed'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _completeFollowup(id);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.refresh, color: Colors.orange),
                  title: const Text('Reschedule'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _rescheduleFollowup(id);
                  },
                ),
              ],
              if (outcome != null && outcome.isNotEmpty) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notes),
                  title: const Text('Outcome'),
                  subtitle: Text(outcome),
                ),
              ],
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: const Text('Cancel Follow-up'),
                onTap: () {
                  Navigator.pop(ctx);
                  _cancelFollowup(id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeFollowup(String id) async {
    final outcomeController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Follow-up'),
        content: TextField(
          controller: outcomeController,
          decoration: const InputDecoration(
            labelText: 'Outcome / Notes',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, outcomeController.text),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    outcomeController.dispose();

    if (result != null) {
      final success = await ref
          .read(followupControllerProvider.notifier)
          .completeFollowup(id, result, null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Follow-up completed'
                : 'Failed to complete follow-up',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _rescheduleFollowup(String id) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      final success = await ref
          .read(followupControllerProvider.notifier)
          .rescheduleFollowup(id, date);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Follow-up rescheduled'
                : 'Failed to reschedule',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelFollowup(String id) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Cancel Follow-up',
      message: 'Are you sure you want to cancel this follow-up?',
      confirmLabel: 'Cancel',
      isDestructive: true,
    );
    if (confirmed == true) {
      // Cancel by marking as cancelled via the treatment repo
      final success = await ref
          .read(followupControllerProvider.notifier)
          .completeFollowup(id, 'Cancelled', null);
      if (!mounted) return;
      if (success) {
        ref.invalidate(followupListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Follow-up cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
