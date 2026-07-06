import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/features/patients/states/patient_list_state.dart';
import 'package:helpster_care/shared/models/models.dart';
import 'package:helpster_care/shared/widgets/section_header.dart';

/// Displays patient personal information in a structured section.
class PatientInfoSection extends StatelessWidget {
  const PatientInfoSection({
    super.key,
    required this.patient,
    this.contacts = const [],
    this.addresses = const [],
    this.guardians = const [],
  });

  final Patient patient;
  final List<PatientContact> contacts;
  final List<PatientAddress> addresses;
  final List<PatientGuardian> guardians;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Personal Information ──────────────────────────────
          const SectionHeader(title: 'Personal Information'),
          _InfoRow(label: 'Patient ID', value: patient.patientId),
          _InfoRow(label: 'Full Name', value: patient.fullName),
          _InfoRow(
            label: 'Date of Birth',
            value: patient.dateOfBirth != null
                ? '${patient.dateOfBirth!.day}/${patient.dateOfBirth!.month}/${patient.dateOfBirth!.year}'
                : '—',
          ),
          if (patient.gender != null)
            _InfoRow(label: 'Gender', value: patient.gender!),
          if (patient.bloodGroup != null)
            _InfoRow(label: 'Blood Group', value: patient.bloodGroup!),
          if (patient.religion != null)
            _InfoRow(label: 'Religion', value: patient.religion!),
          if (patient.occupation != null)
            _InfoRow(label: 'Occupation', value: patient.occupation!),
          if (patient.nationalId != null)
            _InfoRow(label: 'National ID', value: patient.nationalId!),
          const Divider(height: AppSpacing.lg),

          // ── Contact Information ───────────────────────────────
          const SectionHeader(title: 'Contact Information'),
          if (contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'No contact information recorded.',
                style: textStyle?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...contacts.map((c) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (c.phone != null)
                      _InfoRow(label: 'Phone', value: c.phone!),
                    if (c.email != null)
                      _InfoRow(label: 'Email', value: c.email!),
                    if (c.isEmergency)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Chip(
                          label: const Text('Emergency Contact'),
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(Icons.warning, size: 16),
                        ),
                      ),
                  ],
                )),
          const Divider(height: AppSpacing.lg),

          // ── Address ───────────────────────────────────────────
          const SectionHeader(title: 'Address'),
          if (addresses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'No address recorded.',
                style: textStyle?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...addresses.map((a) => _buildAddressDetails(context, a)),
          const Divider(height: AppSpacing.lg),

          // ── Guardian ──────────────────────────────────────────
          const SectionHeader(title: 'Guardian / Next of Kin'),
          if (guardians.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'No guardian recorded.',
                style: textStyle?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...guardians.map((g) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Name', value: g.fullName),
                    if (g.relationship != null)
                      _InfoRow(label: 'Relationship', value: g.relationship!),
                    if (g.phone != null)
                      _InfoRow(label: 'Phone', value: g.phone!),
                    if (g.email != null)
                      _InfoRow(label: 'Email', value: g.email!),
                    if (g.address != null)
                      _InfoRow(label: 'Address', value: g.address!),
                    if (g.isMinor)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Chip(
                          label: const Text('Minor - Guardian Required'),
                          visualDensity: VisualDensity.compact,
                          avatar: const Icon(Icons.child_care, size: 16),
                        ),
                      ),
                  ],
                )),
        ],
      ),
    );
  }

  Widget _buildAddressDetails(BuildContext context, PatientAddress a) {
    final parts = <String>[];
    if (a.street != null && a.street!.isNotEmpty) parts.add(a.street!);
    if (a.villageOrWard != null && a.villageOrWard!.isNotEmpty) {
      parts.add(a.villageOrWard!);
    }
    if (a.unionOrCity != null && a.unionOrCity!.isNotEmpty) {
      parts.add(a.unionOrCity!);
    }
    if (a.upazila != null && a.upazila!.isNotEmpty) parts.add(a.upazila!);
    if (a.district != null && a.district!.isNotEmpty) parts.add(a.district!);
    if (a.division != null && a.division!.isNotEmpty) parts.add(a.division!);
    if (a.postCode != null && a.postCode!.isNotEmpty) parts.add(a.postCode!);
    parts.add(a.country);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (a.addressType != 'PRESENT')
            Chip(
              label: Text(a.addressType),
              visualDensity: VisualDensity.compact,
            ),
          Text(
            parts.join(', '),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// A single info row with label and value.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
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
