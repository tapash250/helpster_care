import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpster_care/app/theme/animations.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/shared/models/patient.dart';
import 'package:helpster_care/shared/widgets/async_value_widget.dart';
import 'package:helpster_care/shared/widgets/empty_state.dart';
import 'package:helpster_care/shared/widgets/filter_chips.dart';
import 'package:helpster_care/shared/widgets/search_field.dart';
import 'package:helpster_care/features/patients/controllers/patient_list_controller.dart';
import 'package:helpster_care/features/patients/routes/patient_routes.dart';
import 'package:helpster_care/features/patients/states/patient_list_state.dart';
import 'package:helpster_care/features/patients/widgets/patient_card.dart';

/// Patient list screen with search, filter chips, pull-to-refresh, and FAB.
class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patientsAsync = ref.watch(patientListControllerProvider);
    final config = ref.watch(patientListConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          if (config.filter.hasActiveFilter)
            IconButton(
              icon: const Icon(Icons.filter_list_off),
              tooltip: 'Clear filters',
              onPressed: () {
                _searchController.clear();
                ref
                    .read(patientListControllerProvider.notifier)
                    .clearFilters();
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () =>
                ref.read(patientListControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: SearchField(
              hint: 'Search by name, ID, or national ID...',
              controller: _searchController,
              onChanged: (query) {
                ref
                    .read(patientListControllerProvider.notifier)
                    .setSearchQuery(query);
              },
            ),
          ),

          // ── Status filter chips ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.xs,
            ),
            child: FilterChips(
              label: 'Status',
              options: PatientStatusOption.all.entries
                  .map((e) => FilterChipOption(label: e.value, value: e.key))
                  .toList(),
              selected: config.filter.statusFilter,
              onSelected: (selected) {
                ref
                    .read(patientListControllerProvider.notifier)
                    .setStatusFilter(selected);
              },
            ),
          ),

          // ── Patient list ────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(patientListControllerProvider.notifier).refresh(),
              child: AsyncValueWidget<List<Patient>>(
                value: patientsAsync,
                loading: const Center(child: CircularProgressIndicator()),
                data: (patients) {
                  if (patients.isEmpty) {
                    if (config.filter.hasActiveFilter) {
                      return EmptyState(
                        title: 'No matching patients',
                        subtitle:
                            'Try adjusting your search or filter criteria.',
                        icon: Icons.search_off,
                      );
                    }
                    return EmptyState(
                      title: 'No patients yet',
                      subtitle: 'Tap the button below to register your first patient.',
                      icon: Icons.person_add_outlined,
                      actionLabel: 'Add Patient',
                      onAction: () => context.push(PatientRoutes.create),
                    );
                  }

                  return AnimatedSwitcher(
                    duration: AppAnimation.medium,
                    child: ListView.builder(
                      key: ValueKey(
                          '${patients.length}_${config.filter.hashCode}'),
                      padding: const EdgeInsets.only(
                        top: AppSpacing.xs,
                        bottom: AppSpacing.xxl,
                      ),
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        return PatientCard(patient: patients[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // ── FAB for create ───────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(PatientRoutes.create),
        icon: const Icon(Icons.add),
        label: const Text('Add Patient'),
      ),
    );
  }
}
