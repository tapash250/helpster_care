import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/widgets.dart';
import 'package:helpster_care/features/approvals/providers/approval_providers.dart';
import 'package:helpster_care/features/approvals/widgets/approval_timeline.dart';

/// Approval detail screen showing approval info, history timeline, and actions.
class ApprovalDetailScreen extends ConsumerStatefulWidget {
  const ApprovalDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ApprovalDetailScreen> createState() =>
      _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends ConsumerState<ApprovalDetailScreen> {
  bool _actionInProgress = false;

  Future<void> _approve() async {
    final notesController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Request'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            labelText: 'Approval notes (optional)',
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
            onPressed: () =>
                Navigator.pop(ctx, notesController.text.trim()),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    notesController.dispose();

    if (result != null && mounted) {
      setState(() => _actionInProgress = true);
      try {
        await ref.read(approvalRepositoryProvider).updateApprovalState(
              approvalId: widget.id,
              newState: 'APPROVED',
              notes: result.isNotEmpty ? result : null,
            );
        ref.invalidate(approvalDetailProvider);
        ref.invalidate(approvalListProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request approved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to approve: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _actionInProgress = false);
      }
    }
  }

  Future<void> _reject() async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection *',
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () =>
                Navigator.pop(ctx, reasonController.text.trim()),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    reasonController.dispose();

    if (result != null && mounted) {
      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide a reason for rejection'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() => _actionInProgress = true);
      try {
        await ref.read(approvalRepositoryProvider).updateApprovalState(
              approvalId: widget.id,
              newState: 'REJECTED',
              notes: result,
            );
        ref.invalidate(approvalDetailProvider);
        ref.invalidate(approvalListProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _actionInProgress = false);
      }
    }
  }

  Future<void> _submit() async {
    setState(() => _actionInProgress = true);
    try {
      await ref.read(approvalRepositoryProvider).updateApprovalState(
            approvalId: widget.id,
            newState: 'SUBMITTED',
          );
      ref.invalidate(approvalDetailProvider);
      ref.invalidate(approvalListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request submitted for review'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final approvalAsync = ref.watch(approvalDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Details'),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          AsyncValueWidget<Map<String, dynamic>?>(
            value: approvalAsync,
            data: (approval) {
              if (approval == null) {
                return const EmptyState(
                  title: 'Approval not found',
                  icon: Icons.approval_outlined,
                );
              }
              return _ApprovalDetailContent(
                approval: approval,
                onApprove: _approve,
                onReject: _reject,
                onSubmit: _submit,
              );
            },
          ),
          if (_actionInProgress)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _ApprovalDetailContent extends StatelessWidget {
  const _ApprovalDetailContent({
    required this.approval,
    required this.onApprove,
    required this.onReject,
    required this.onSubmit,
  });

  final Map<String, dynamic> approval;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = approval['patients'] as Map<String, dynamic>?;
    final currentState =
        approval['current_state'] as String? ?? 'DRAFT';
    final history =
        approval['approval_history'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient info card
          DataCard(
            title: 'Patient Information',
            children: [
              _DetailRow(
                label: 'Name',
                value: patient?['full_name'] as String? ?? 'Unknown',
              ),
              _DetailRow(
                label: 'Patient ID',
                value: patient?['patient_id'] as String? ?? '-',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Approval details card
          DataCard(
            title: 'Approval Details',
            children: [
              _DetailRow(
                label: 'Current State',
                valueWidget: StatusBadge(label: currentState),
              ),
              _DetailRow(
                label: 'Priority',
                valueWidget: StatusBadge(
                  label: approval['priority'] as String? ?? 'NORMAL',
                  color: _priorityColor(
                      approval['priority'] as String? ?? 'NORMAL'),
                ),
              ),
              _DetailRow(
                label: 'Submitted By',
                value:
                    approval['submitted_by_name'] as String? ?? '-',
              ),
              if (approval['reviewed_by_name'] != null)
                _DetailRow(
                  label: 'Reviewed By',
                  value: approval['reviewed_by_name'] as String,
                ),
              if (approval['review_notes'] != null &&
                  (approval['review_notes'] as String).isNotEmpty)
                _DetailRow(
                  label: 'Review Notes',
                  value: approval['review_notes'] as String,
                ),
              _DetailRow(
                label: 'Created',
                value: approval['created_at'] != null
                    ? _formatDateTime(
                        DateTime.parse(approval['created_at'] as String))
                    : '-',
              ),
              if (approval['decided_at'] != null)
                _DetailRow(
                  label: 'Decided At',
                  value: _formatDateTime(
                      DateTime.parse(approval['decided_at'] as String)),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Action buttons
          if (currentState == 'DRAFT')
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.send),
                label: const Text('Submit for Approval'),
              ),
            ),

          if (currentState == 'SUBMITTED' ||
              currentState == 'UNDER_REVIEW')
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Reject'),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: AppSpacing.lg),

          // History timeline
          SectionHeader(title: 'Approval History'),
          const SizedBox(height: AppSpacing.sm),
          ApprovalTimeline(
            history: history.cast<Map<String, dynamic>>(),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'URGENT':
        return Colors.red;
      case 'HIGH':
        return Colors.deepOrange;
      case 'NORMAL':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: valueWidget ??
                Text(
                  value ?? '-',
                  style: theme.textTheme.bodyMedium,
                ),
          ),
        ],
      ),
    );
  }
}
