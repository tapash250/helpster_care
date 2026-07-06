import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/shared/widgets/search_field.dart';
import 'package:helpster_care/shared/widgets/empty_state.dart';
import 'package:helpster_care/shared/widgets/error_banner.dart';
import 'package:helpster_care/shared/widgets/loading_overlay.dart';
import 'package:helpster_care/features/hospitals/states/hospital_state.dart';
import 'package:helpster_care/features/hospitals/widgets/hospital_card.dart';
import 'package:helpster_care/features/hospitals/routes/hospital_routes.dart';
import 'package:helpster_care/features/hospitals/providers/hospital_list_provider.dart';
import 'package:helpster_care/features/hospitals/controllers/hospital_controller.dart';

/// Screen displaying a list of hospitals with search and filter.
class HospitalListScreen extends ConsumerStatefulWidget {
  const HospitalListScreen({super.key});

  @override
  ConsumerState<HospitalListScreen> createState() => _HospitalListScreenState();
}

class _HospitalListScreenState extends ConsumerState<HospitalListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hospitalListControllerProvider.notifier).loadHospitals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hospitalListControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hospitals'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(HospitalRoutes.create),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: SearchField(
              hint: 'Search hospitals...',
              controller: _searchController,
              onChanged: (query) {
                ref
                    .read(hospitalListControllerProvider.notifier)
                    .search(query);
              },
            ),
          ),

          // Sort chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _SortChip(
                  label: 'Name',
                  selected: state.filter.sortBy == 'name',
                  ascending: state.filter.sortAscending,
                  onTap: () => ref
                      .read(hospitalListControllerProvider.notifier)
                      .sortBy('name'),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SortChip(
                  label: 'Recent',
                  selected: state.filter.sortBy == 'updated_at',
                  ascending: state.filter.sortAscending,
                  onTap: () => ref
                      .read(hospitalListControllerProvider.notifier)
                      .sortBy('updated_at'),
                ),
                const Spacer(),
                if (state.filter.isActive)
                  TextButton(
                    onPressed: () {
                      ref
                          .read(hospitalListControllerProvider.notifier)
                          .loadHospitals(filter: const HospitalFilter());
                    },
                    child: const Text('Clear filters'),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(state, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HospitalListState state, ThemeData theme) {
    if (state.isLoading && !state.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && !state.hasData) {
      return ErrorBanner(
        message: state.error!,
        onRetry: () =>
            ref.read(hospitalListControllerProvider.notifier).refresh(),
      );
    }

    if (state.hospitals.isEmpty) {
      if (state.filter.searchQuery.isNotEmpty) {
        return EmptyState(
          title: 'No Results',
          subtitle: 'No hospitals match "${state.filter.searchQuery}".',
          icon: Icons.search_off,
        );
      }
      return EmptyState(
        title: 'No Hospitals',
        subtitle: 'Add your first hospital to get started.',
        icon: Icons.local_hospital_outlined,
        actionLabel: 'Add Hospital',
        onAction: () => context.push(HospitalRoutes.create),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(hospitalListControllerProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 80),
        itemCount: state.hospitals.length,
        itemBuilder: (context, index) {
          final hospital = state.hospitals[index];
          return HospitalCard(
            hospital: hospital,
            onTap: () => context.push(HospitalRoutes.detailPath(hospital.id)),
          );
        },
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.ascending,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool ascending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.secondaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 4),
                Icon(
                  ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
