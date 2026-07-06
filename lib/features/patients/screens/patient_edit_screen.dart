import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/models/patient.dart';
import 'package:helpster_care/shared/widgets/async_value_widget.dart';
import 'package:helpster_care/shared/widgets/loading_overlay.dart';
import 'package:helpster_care/features/patients/controllers/patient_detail_controller.dart';
import 'package:helpster_care/features/patients/controllers/patient_form_controller.dart';
import 'package:helpster_care/features/patients/controllers/patient_list_controller.dart';
import 'package:helpster_care/features/patients/routes/patient_routes.dart';
import 'package:helpster_care/features/patients/states/patient_form_state.dart';
import 'package:helpster_care/features/patients/validators/patient_validators.dart';

/// Screen for editing an existing patient.
class PatientEditScreen extends ConsumerStatefulWidget {
  const PatientEditScreen({
    super.key,
    required this.patientId,
  });

  final String patientId;

  @override
  ConsumerState<PatientEditScreen> createState() => _PatientEditScreenState();
}

class _PatientEditScreenState extends ConsumerState<PatientEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadPatientData();
      _initialized = true;
    }
  }

  void _loadPatientData() {
    final detailAsync = ref.read(
      patientDetailControllerProvider(widget.patientId),
    );
    detailAsync.whenData((detail) {
      if (!mounted) return;
      final controller = ref.read(patientFormControllerProvider.notifier);
      controller.loadForEdit(
        detail.patient,
        contact: detail.contacts.isNotEmpty ? detail.contacts.first : null,
        address: detail.addresses.isNotEmpty ? detail.addresses.first : null,
        guardian: detail.guardians.isNotEmpty ? detail.guardians.first : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(patientFormControllerProvider);
    final detailAsync = ref.watch(
      patientDetailControllerProvider(widget.patientId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: AsyncValueWidget<PatientDetailData>(
        value: detailAsync,
        loading: const Center(child: CircularProgressIndicator()),
        data: (_) => _buildEditForm(formState, theme),
      ),
    );
  }

  Widget _buildEditForm(PatientFormState formState, ThemeData theme) {
    final controller = ref.read(patientFormControllerProvider.notifier);

    if (formState.fullName.isEmpty && formState.isEdit) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section: Basic Info ────────────────────────────────
            Text('Basic Information',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              initialValue: formState.fullName,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                errorText: formState.errorForFullName,
                border: const OutlineInputBorder(),
              ),
              onChanged: controller.setFullName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              initialValue: formState.nationalId,
              decoration: InputDecoration(
                labelText: 'National ID',
                errorText: formState.errorForNationalId,
                border: const OutlineInputBorder(),
              ),
              onChanged: controller.setNationalId,
            ),
            const SizedBox(height: AppSpacing.md),

            // Status dropdown
            DropdownButtonFormField<String>(
              value: formState.status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                DropdownMenuItem(
                    value: 'PENDING_DOCUMENTS',
                    child: Text('Pending Documents')),
                DropdownMenuItem(
                    value: 'SUBMITTED', child: Text('Submitted')),
                DropdownMenuItem(
                    value: 'UNDER_REVIEW', child: Text('Under Review')),
                DropdownMenuItem(
                    value: 'MEDICAL_REVIEW',
                    child: Text('Medical Review')),
                DropdownMenuItem(value: 'APPROVED', child: Text('Approved')),
                DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                DropdownMenuItem(
                    value: 'IN_TREATMENT', child: Text('In Treatment')),
                DropdownMenuItem(
                    value: 'DISCHARGED', child: Text('Discharged')),
                DropdownMenuItem(value: 'FOLLOWUP', child: Text('Follow-up')),
                DropdownMenuItem(value: 'CLOSED', child: Text('Closed')),
                DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                DropdownMenuItem(
                    value: 'CANCELLED', child: Text('Cancelled')),
              ],
              onChanged: controller.setStatus,
            ),
            const SizedBox(height: AppSpacing.md),

            // Date of birth
            _EditDatePickerField(
              label: 'Date of Birth',
              value: formState.dateOfBirth,
              onChanged: controller.setDateOfBirth,
            ),
            const SizedBox(height: AppSpacing.md),

            // Gender
            DropdownButtonFormField<String>(
              value: formState.gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Select...')),
                DropdownMenuItem(value: 'MALE', child: Text('Male')),
                DropdownMenuItem(value: 'FEMALE', child: Text('Female')),
                DropdownMenuItem(value: 'OTHER', child: Text('Other')),
              ],
              onChanged: controller.setGender,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              initialValue: formState.occupation ?? '',
              decoration: const InputDecoration(
                labelText: 'Occupation',
                border: OutlineInputBorder(),
              ),
              onChanged: controller.setOccupation,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),

            // ── Section: Contact ──────────────────────────────────
            Text('Contact Information',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              initialValue: formState.phone,
              decoration: InputDecoration(
                labelText: 'Phone',
                errorText: formState.errorForPhone,
                border: const OutlineInputBorder(),
              ),
              onChanged: controller.setPhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              initialValue: formState.email,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: formState.errorForEmail,
                border: const OutlineInputBorder(),
              ),
              onChanged: controller.setEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppSpacing.md),

            SwitchListTile(
              title: const Text('Emergency Contact'),
              value: formState.isEmergency,
              onChanged: controller.setIsEmergency,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),

            // ── Section: Address ───────────────────────────────────
            Text('Address', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              initialValue: formState.street,
              decoration: const InputDecoration(
                labelText: 'Street / Road',
                border: OutlineInputBorder(),
              ),
              onChanged: controller.setStreet,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              initialValue: formState.division ?? '',
              decoration: const InputDecoration(
                labelText: 'Division',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => controller.setDivision(v),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: formState.district ?? '',
                    decoration: const InputDecoration(
                      labelText: 'District',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => controller.setDistrict(v),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    initialValue: formState.upazila ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Upazila',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => controller.setUpazila(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),

            // ── Section: Guardian ──────────────────────────────────
            Text('Guardian / Next of Kin',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              initialValue: formState.guardianName,
              decoration: InputDecoration(
                labelText: 'Guardian Name',
                errorText: formState.errorForGuardianName,
                border: const OutlineInputBorder(),
              ),
              onChanged: controller.setGuardianName,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              initialValue: formState.guardianRelationship ?? '',
              decoration: const InputDecoration(
                labelText: 'Relationship',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => controller.setGuardianRelationship(v),
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              initialValue: formState.guardianPhone ?? '',
              decoration: const InputDecoration(
                labelText: 'Guardian Phone',
                border: OutlineInputBorder(),
              ),
              onChanged: controller.setGuardianPhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Submit button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSubmitting ? null : () => _handleSubmit(controller),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSubmitting ? 'Saving...' : 'Save Changes'),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(PatientFormController controller) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final patient = await controller.submit();
      ref.invalidate(patientListControllerProvider);
      ref.invalidate(patientDetailControllerProvider(widget.patientId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient ${patient.fullName} updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _EditDatePickerField extends StatelessWidget {
  const _EditDatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final void Function(DateTime?) onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate:
              value ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
          firstDate: DateTime(1880),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => onChanged(null),
                ),
              const Icon(Icons.calendar_today),
            ],
          ),
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : 'Not set',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value != null
                    ? null
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
