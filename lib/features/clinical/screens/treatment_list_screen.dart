import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/widgets.dart';
import 'package:helpster_care/features/clinical/models/treatment_filter.dart';
import 'package:helpster_care/features/clinical/providers/treatment_providers.dart';
import 'package:helpster_care/features/clinical/widgets/treatment_card.dart';
import 'package:helpster_care/features/clinical/routes/treatment_routes.dart';

/// Screen displaying all treatments with search, filter, and pull-to-refresh.
class TreatmentListScreen extends ConsumerStatefulWidget {
  const TreatmentListScreen({super.key, this.patientId});

  /// Optional patient ID to scope the list to a single patient.
  final String? patientId;

  @override
  ConsumerState<TreatmentListScreen> createState() =>
      _TreatmentListScreenState();
}

class _TreatmentListScreenState extends ConsumerState<TreatmentListScreen> {
  final _searchController = TextEditingController();
  TreatmentFilter _filter = const TreatmentFilter();
  Set<String> _selectedStatuses = {};
  String? _selectedType;

  static const _statusOptions = [
    FilterChipOption(label: 'Active', value: 'ACTIVE'),
    FilterChipOption(label: 'Discharged', value: 'DISCHARGED'),
    FilterChipOption(label: 'Cancelled', value: 'CANCELLED'),
  ];

  static const _typeOptions = [
    FilterChipOption(label: 'All Types', value: ''),
    FilterChipOption(label: 'Conservative', value: 'CONSERVATIVE'),
    FilterChipOption(label: 'Surgical', value: 'SURGICAL'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _filter = _filter.copyWith(patientId: widget.patientId);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    setState(() {
      _filter = _filter.copyWith(
        searchQuery: _searchController.text.trim(),
        status: _selectedStatuses.toList(),
        treatmentType:
            _selectedType != null && _selectedType!.isNotEmpty
                ? _selectedType
                : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final treatmentsAsync = ref.watch(treatmentListProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatments'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(treatmentListProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: SearchField(
              hint: 'Search treatments...',
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              onSubmitted: (_) => _applyFilter(),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FilterChips(
                  label: 'Status',
                  options: _statusOptions,
                  selected: _selectedStatuses,
                  onSelected: (selected) {
                    setState(() => _selectedStatuses = selected);
                    _applyFilter();
                  },
                ),
                const SizedBox(height: AppSpacing.xs),
                FilterChips(
                  label: 'Type',
                  options: _typeOptions,
                  selected: _selectedType != null
                      ? {_selectedType!}
                      : {''},
                  allowMultiple: false,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType =
                          selected.contains('') ? null : selected.first;
                    });
                    _applyFilter();
                  },
                ),
              ],
            ),
          ),

          // Treatment list
          Expanded(
            child: AsyncValueWidget<List<Map<String, dynamic>>>(
              value: treatmentsAsync,
              data: (treatments) => _TreatmentListView(
                treatments: treatments,
                onRefresh: () =>
                    ref.refresh(treatmentListProvider(_filter)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(ClinicalRoutes.treatmentCreate),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TreatmentListView extends StatelessWidget {
  const _TreatmentListView({
    required this.treatments,
    required this.onRefresh,
  });

  final List<Map<String, dynamic>> treatments;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (treatments.isEmpty) {
      return const EmptyState(
        title: 'No treatments found',
        subtitle: 'Create a new treatment to get started.',
        icon: Icons.medical_services_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: AppSpacing.xs,
          bottom: AppSpacing.xxl,
        ),
        itemCount: treatments.length,
        itemBuilder: (context, index) {
          final t = treatments[index];
          final patient = t['patients'] as Map<String, dynamic>?;
          final hospital = t['hospitals'] as Map<String, dynamic>?;

          return TreatmentCard(
            patientName: patient?['full_name'] as String? ?? 'Unknown',
            patientId: patient?['patient_id'] as String? ?? '',
            treatmentType: t['treatment_type'] as String? ?? '',
            status: t['status'] as String? ?? 'ACTIVE',
            hospitalName: hospital?['name'] as String?,
            diagnosis: t['diagnosis'] as String?,
            admissionDate: t['admission_date'] != null
                ? DateTime.tryParse(t['admission_date'] as String)
                : null,
            onTap: () => context.go(
              ClinicalRoutes.treatmentDetail(t['id'] as String),
            ),
          );
        },
      ),
    );
  }
}
