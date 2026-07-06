import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/shared/widgets/widgets.dart';
import 'package:helpster_care/features/approvals/providers/approval_providers.dart';
import 'package:helpster_care/features/approvals/models/approval_filter.dart';
import 'package:helpster_care/features/approvals/widgets/approval_card.dart';
import 'package:helpster_care/features/approvals/routes/approval_routes.dart';

/// Screen listing all approvals with filtering by state and priority.
class ApprovalListScreen extends ConsumerStatefulWidget {
  const ApprovalListScreen({super.key});

  @override
  ConsumerState<ApprovalListScreen> createState() =>
      _ApprovalListScreenState();
}

class _ApprovalListScreenState extends ConsumerState<ApprovalListScreen> {
  ApprovalFilter _filter = const ApprovalFilter();
  Set<String> _selectedStates = {};
  String? _selectedPriority;

  static const _stateOptions = [
    FilterChipOption(label: 'Draft', value: 'DRAFT'),
    FilterChipOption(label: 'Submitted', value: 'SUBMITTED'),
    FilterChipOption(label: 'Under Review', value: 'UNDER_REVIEW'),
    FilterChipOption(label: 'Approved', value: 'APPROVED'),
    FilterChipOption(label: 'Rejected', value: 'REJECTED'),
  ];

  static const _priorityOptions = [
    FilterChipOption(label: 'All', value: ''),
    FilterChipOption(label: 'Normal', value: 'NORMAL'),
    FilterChipOption(label: 'High', value: 'HIGH'),
    FilterChipOption(label: 'Urgent', value: 'URGENT'),
  ];

  void _applyFilter() {
    setState(() {
      _filter = _filter.copyWith(
        states: _selectedStates.toList(),
        priority:
            _selectedPriority != null && _selectedPriority!.isNotEmpty
                ? _selectedPriority
                : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final approvalsAsync = ref.watch(approvalListProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approvals'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(approvalListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterChips(
                  label: 'State',
                  options: _stateOptions,
                  selected: _selectedStates,
                  onSelected: (selected) {
                    setState(() => _selectedStates = selected);
                    _applyFilter();
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                FilterChips(
                  label: 'Priority',
                  options: _priorityOptions,
                  selected: _selectedPriority != null
                      ? {_selectedPriority!}
                      : {''},
                  allowMultiple: false,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPriority =
                          selected.contains('') ? null : selected.first;
                    });
                    _applyFilter();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Approval list
          Expanded(
            child: AsyncValueWidget<List<Map<String, dynamic>>>(
              value: approvalsAsync,
              data: (approvals) {
                if (approvals.isEmpty) {
                  return const EmptyState(
                    title: 'No approvals found',
                    subtitle:
                        'Approvals will appear here once submitted.',
                    icon: Icons.approval_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(approvalListProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                    itemCount: approvals.length,
                    itemBuilder: (context, index) {
                      final a = approvals[index];
                      final patient =
                          a['patients'] as Map<String, dynamic>?;

                      return ApprovalCard(
                        patientName:
                            patient?['full_name'] as String? ??
                                'Unknown',
                        patientId:
                            patient?['patient_id'] as String? ?? '',
                        currentState:
                            a['current_state'] as String? ?? 'DRAFT',
                        priority: a['priority'] as String? ?? 'NORMAL',
                        submittedByName:
                            a['submitted_by_name'] as String?,
                        createdAt: a['created_at'] != null
                            ? DateTime.tryParse(
                                a['created_at'] as String)
                            : null,
                        onTap: () => context.go(
                          ApprovalRoutes.approvalDetail(
                              a['id'] as String),
                        ),
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
}
