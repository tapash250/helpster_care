import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/section_header.dart';
import 'package:helpster_care/shared/widgets/error_banner.dart';
import 'package:helpster_care/shared/widgets/status_badge.dart';
import 'package:helpster_care/features/hospitals/states/hospital_state.dart';
import 'package:helpster_care/features/hospitals/widgets/department_list.dart';
import 'package:helpster_care/features/hospitals/widgets/ward_list.dart';
import 'package:helpster_care/features/hospitals/widgets/bed_grid.dart';
import 'package:helpster_care/features/hospitals/widgets/ot_list.dart';
import 'package:helpster_care/features/hospitals/routes/hospital_routes.dart';
import 'package:helpster_care/features/hospitals/providers/hospital_list_provider.dart';
import 'package:helpster_care/features/hospitals/controllers/hospital_controller.dart';

/// Screen showing full detail of a hospital with tabbed content.
///
/// Tabs: Overview, Departments, Wards, Beds, OT, Staff.
class HospitalDetailScreen extends ConsumerStatefulWidget {
  const HospitalDetailScreen({
    super.key,
    required this.hospitalId,
  });

  final String hospitalId;

  @override
  ConsumerState<HospitalDetailScreen> createState() =>
      _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends ConsumerState<HospitalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(hospitalDetailControllerProvider(widget.hospitalId).notifier)
            .selectTab(_tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(hospitalDetailControllerProvider(widget.hospitalId).notifier)
          .loadHospitalDetail(widget.hospitalId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hospitalDetailControllerProvider(widget.hospitalId));
    final theme = Theme.of(context);
    final controller =
        ref.read(hospitalDetailControllerProvider(widget.hospitalId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.hospital?.name ?? 'Hospital'),
        centerTitle: false,
        actions: [
          if (state.hospital != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () =>
                  context.push(HospitalRoutes.editPath(widget.hospitalId)),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
        bottom: state.hospital != null
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Departments'),
                  Tab(text: 'Wards'),
                  Tab(text: 'Beds'),
                  Tab(text: 'OT'),
                ],
              )
            : null,
      ),
      body: _buildBody(state, theme, controller),
    );
  }

  Widget _buildBody(
    HospitalDetailState state,
    ThemeData theme,
    HospitalDetailController controller,
  ) {
    if (state.isLoading && !state.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && !state.hasData) {
      return ErrorBanner(
        message: state.error!,
        onRetry: controller.refresh,
      );
    }

    if (!state.hasData) {
      return const Center(child: Text('Hospital not found'));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _OverviewTab(state: state, theme: theme),
        _DepartmentsTab(state: state, theme: theme),
        _WardsTab(state: state, theme: theme),
        _BedsTab(state: state, theme: theme),
        _OTTab(state: state, theme: theme),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Overview Tab
// ---------------------------------------------------------------------------

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.state, required this.theme});
  final HospitalDetailState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final hospital = state.hospital!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hospital.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      StatusBadge(
                        label: hospital.isActive ? 'Active' : 'Inactive',
                        color: hospital.isActive ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                  if (hospital.hospitalType != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: hospital.hospitalType!,
                    ),
                  ],
                  if (hospital.address != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: hospital.address!,
                    ),
                  ],
                  if (hospital.phone != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: hospital.phone!,
                    ),
                  ],
                  if (hospital.email != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: hospital.email!,
                    ),
                  ],
                  if (hospital.registrationNo != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Reg: ${hospital.registrationNo}',
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Stats grid
          Row(
            children: [
              _StatCard(
                icon: Icons.meeting_room_outlined,
                value: '${state.departments.length}',
                label: 'Departments',
                color: Colors.blue,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatCard(
                icon: Icons.bed_outlined,
                value: '${state.wards.length}',
                label: 'Wards',
                color: Colors.teal,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatCard(
                icon: Icons.hotel_outlined,
                value: '${state.totalBeds}',
                label: 'Total Beds',
                color: Colors.indigo,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Occupancy info
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bed Occupancy',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _OccupancyDot(
                        color: Colors.green,
                        label: 'Available',
                        count: state.availableBeds,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _OccupancyDot(
                        color: Colors.red,
                        label: 'Occupied',
                        count: state.occupiedBeds,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LinearProgressIndicator(
                      value: state.totalBeds > 0
                          ? state.occupiedBeds / state.totalBeds
                          : 0,
                      backgroundColor: Colors.green.withOpacity(0.15),
                      color: Colors.red,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${state.totalBeds > 0 ? (state.occupiedBeds / state.totalBeds * 100).toStringAsFixed(1) : 0}% occupied',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OccupancyDot extends StatelessWidget {
  const _OccupancyDot({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: $count',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Departments Tab
// ---------------------------------------------------------------------------

class _DepartmentsTab extends StatelessWidget {
  const _DepartmentsTab({required this.state, required this.theme});
  final HospitalDetailState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: DepartmentList(
        departments: state.departments,
        isLoading: state.isLoading,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wards Tab
// ---------------------------------------------------------------------------

class _WardsTab extends StatelessWidget {
  const _WardsTab({required this.state, required this.theme});
  final HospitalDetailState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: WardList(
        wards: state.wards,
        isLoading: state.isLoading,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Beds Tab
// ---------------------------------------------------------------------------

class _BedsTab extends StatelessWidget {
  const _BedsTab({required this.state, required this.theme});
  final HospitalDetailState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: BedGrid(
        beds: state.beds,
        isLoading: state.isLoading,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OT Tab
// ---------------------------------------------------------------------------

class _OTTab extends ConsumerWidget {
  const _OTTab({required this.state, required this.theme});
  final HospitalDetailState state;
  final ThemeData theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: OTList(
        schedules: [],
        isLoading: state.isLoading,
      ),
    );
  }
}
