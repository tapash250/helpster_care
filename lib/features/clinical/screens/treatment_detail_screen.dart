import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/widgets.dart';
import 'package:helpster_care/features/clinical/providers/treatment_providers.dart';
import 'package:helpster_care/features/clinical/widgets/diagnosis_section.dart';
import 'package:helpster_care/features/clinical/widgets/prescription_section.dart';
import 'package:helpster_care/features/clinical/widgets/ot_timeline.dart';
import 'package:helpster_care/features/clinical/widgets/followup_card.dart';
import 'package:helpster_care/features/clinical/controllers/treatment_controller.dart';

/// Treatment detail screen with tabbed sections.
class TreatmentDetailScreen extends ConsumerWidget {
  const TreatmentDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treatmentAsync = ref.watch(treatmentDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Details'),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'discharge') {
                final confirmed = await showConfirmDialog(
                  context,
                  title: 'Discharge Treatment',
                  message:
                      'Are you sure you want to discharge this treatment?',
                  confirmLabel: 'Discharge',
                  isDestructive: true,
                );
                if (confirmed == true) {
                  await ref
                      .read(treatmentControllerProvider.notifier)
                      .dischargeTreatment(id);
                  if (context.mounted) context.pop();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'discharge',
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Discharge'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: AsyncValueWidget<Map<String, dynamic>?>(
        value: treatmentAsync,
        data: (treatment) {
          if (treatment == null) {
            return const EmptyState(
              title: 'Treatment not found',
              icon: Icons.medical_services_outlined,
            );
          }
          return _TreatmentDetailContent(treatment: treatment);
        },
      ),
    );
  }
}

class _TreatmentDetailContent extends StatelessWidget {
  const _TreatmentDetailContent({required this.treatment});

  final Map<String, dynamic> treatment;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          // Header card
          _TreatmentHeader(treatment: treatment),

          // Tab bar
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Diagnoses'),
              Tab(text: 'Prescriptions'),
              Tab(text: 'Timeline'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _OverviewTab(treatment: treatment),
                _DiagnosesTab(treatment: treatment),
                _PrescriptionsTab(treatment: treatment),
                _TimelineTab(treatment: treatment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TreatmentHeader extends StatelessWidget {
  const _TreatmentHeader({required this.treatment});

  final Map<String, dynamic> treatment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final patient = treatment['patients'] as Map<String, dynamic>?;
    final hospital = treatment['hospitals'] as Map<String, dynamic>?;

    return Container(
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
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            radius: 24,
            child: Text(
              _initials(patient?['full_name'] as String? ?? '?'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient?['full_name'] as String? ?? 'Unknown Patient',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${patient?['patient_id'] as String? ?? '-'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (hospital?['name'] != null)
                  Text(
                    hospital!['name'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          StatusBadge(label: treatment['status'] as String? ?? 'ACTIVE'),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.treatment});

  final Map<String, dynamic> treatment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conservative =
        treatment['conservative_treatments'] as List<dynamic>?;
    final surgical =
        treatment['surgical_treatments'] as List<dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic info card
          DataCard(
            title: 'Treatment Information',
            children: [
              _InfoRow(
                label: 'Type',
                value: treatment['treatment_type'] as String? ?? '-',
              ),
              _InfoRow(
                label: 'Diagnosis',
                value: treatment['diagnosis'] as String? ?? 'Not set',
              ),
              _InfoRow(
                label: 'Consultant',
                value: treatment['consultant_name'] as String? ??
                    treatment['consultant_id'] as String? ??
                    'Not assigned',
              ),
              _InfoRow(
                label: 'Expected Outcome',
                value: treatment['expected_outcome'] as String? ?? 'Not set',
              ),
              _InfoRow(
                label: 'Admission Date',
                value: treatment['admission_date'] != null
                    ? _formatDate(
                        DateTime.parse(treatment['admission_date'] as String))
                    : 'Not set',
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Conservative details
          if (treatment['treatment_type'] == 'CONSERVATIVE' &&
              conservative != null &&
              conservative.isNotEmpty)
            _ExtensionCard(
              title: 'Conservative Treatment',
              data: conservative.first as Map<String, dynamic>,
              fields: const [
                ('Medication', 'medication'),
                ('Investigations', 'investigations'),
                ('Expected Discharge', 'expected_discharge'),
                ('Discharge Summary', 'discharge_summary'),
              ],
            ),

          // Surgical details
          if (treatment['treatment_type'] == 'SURGICAL' &&
              surgical != null &&
              surgical.isNotEmpty)
            _ExtensionCard(
              title: 'Surgical Treatment',
              data: surgical.first as Map<String, dynamic>,
              fields: const [
                ('Procedure', 'procedure'),
                ('Surgeon', 'surgeon_name'),
                ('Implants', 'implants'),
                ('Operation Notes', 'operation_notes'),
                ('ICU Transfer', 'icu_transfer'),
                ('Post-op Notes', 'post_op_notes'),
              ],
            ),

          const SizedBox(height: AppSpacing.sm),

          // Status timeline
          DataCard(
            title: 'Timeline',
            children: [
              _InfoRow(
                label: 'Created',
                value: treatment['created_at'] != null
                    ? _formatDateTime(
                        DateTime.parse(treatment['created_at'] as String))
                    : '-',
              ),
              _InfoRow(
                label: 'Last Updated',
                value: treatment['updated_at'] != null
                    ? _formatDateTime(
                        DateTime.parse(treatment['updated_at'] as String))
                    : '-',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
  String _formatDateTime(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _ExtensionCard extends StatelessWidget {
  const _ExtensionCard({
    required this.title,
    required this.data,
    required this.fields,
  });

  final String title;
  final Map<String, dynamic> data;
  final List<(String label, String key)> fields;

  @override
  Widget build(BuildContext context) {
    return DataCard(
      title: title,
      children: fields
          .where((f) => data[f.$2] != null)
          .map((f) => _InfoRow(
                label: f.$1,
                value: data[f.$2].toString(),
              ))
          .toList(),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosesTab extends StatelessWidget {
  const _DiagnosesTab({required this.treatment});

  final Map<String, dynamic> treatment;

  @override
  Widget build(BuildContext context) {
    final diagnoses =
        treatment['diagnoses'] as List<dynamic>? ?? [];
    final patientId = treatment['patient_id'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: DiagnosisSection(
        diagnoses: diagnoses.cast<Map<String, dynamic>>(),
        onAdd: () {
          // TODO: Navigate to add diagnosis
        },
      ),
    );
  }
}

class _PrescriptionsTab extends StatelessWidget {
  const _PrescriptionsTab({required this.treatment});

  final Map<String, dynamic> treatment;

  @override
  Widget build(BuildContext context) {
    final prescriptions =
        treatment['prescriptions'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: PrescriptionSection(
        prescriptions: prescriptions.cast<Map<String, dynamic>>(),
        onAdd: () {
          // TODO: Navigate to add prescription
        },
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.treatment});

  final Map<String, dynamic> treatment;

  @override
  Widget build(BuildContext context) {
    // This tab can show OT schedules and follow-ups related to this treatment
    final treatmentId = treatment['id'] as String? ?? '';
    final patientId = treatment['patient_id'] as String? ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'OT Schedules'),
          const SizedBox(height: AppSpacing.sm),
          // In a real app, we'd load OT schedules scoped to this treatment/patient
          // For now, show a placeholder
          DataCard(
            title: 'No OT schedules',
            subtitle: 'Scheduled surgeries will appear here.',
          ),

          const SizedBox(height: AppSpacing.md),
          SectionHeader(title: 'Follow-ups'),
          const SizedBox(height: AppSpacing.sm),
          DataCard(
            title: 'No follow-ups',
            subtitle:
                'Follow-up visits related to this treatment will appear here.',
          ),
        ],
      ),
    );
  }
}
