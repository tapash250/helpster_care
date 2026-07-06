import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/features/patients/controllers/patient_form_controller.dart';
import 'package:helpster_care/features/patients/controllers/patient_list_controller.dart';
import 'package:helpster_care/features/patients/routes/patient_routes.dart';
import 'package:helpster_care/features/patients/states/patient_form_state.dart';

/// Multi-step form screen for creating a new patient.
class PatientCreateScreen extends ConsumerStatefulWidget {
  const PatientCreateScreen({super.key});

  @override
  ConsumerState<PatientCreateScreen> createState() =>
      _PatientCreateScreenState();
}

class _PatientCreateScreenState extends ConsumerState<PatientCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Reset form state when entering this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(patientFormControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(patientFormControllerProvider);
    final controller = ref.read(patientFormControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Patient'),
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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // ── Step indicator ──────────────────────────────────
            _StepIndicator(
              currentStep: formState.step,
              totalSteps: PatientFormState.totalSteps,
              onStepTap: (step) => controller.goToStep(step),
            ),

            // ── Step content ────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildStepContent(formState, controller, theme),
              ),
            ),

            // ── Navigation buttons ──────────────────────────────
            _StepNavigation(
              currentStep: formState.step,
              totalSteps: PatientFormState.totalSteps,
              isSubmitting: _isSubmitting,
              onPrevious: () => controller.previousStep(),
              onNext: () {
                if (controller.validateCurrentStep()) {
                  controller.nextStep();
                }
              },
              onSubmit: () => _handleSubmit(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
    PatientFormState state,
    PatientFormController controller,
    ThemeData theme,
  ) {
    switch (state.step) {
      case 0:
        return _PersonalInfoStep(state: state, controller: controller);
      case 1:
        return _ContactAddressStep(state: state, controller: controller);
      case 2:
        return _GuardianStep(state: state, controller: controller);
      default:
        return const SizedBox();
    }
  }

  Future<void> _handleSubmit(PatientFormController controller) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final patient = await controller.submit();
      ref.invalidate(patientListControllerProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient ${patient.fullName} created successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(PatientRoutes.detailPath(patient.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create patient: $e'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

// ── Step Indicator ───────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    this.onStepTap,
  });

  final int currentStep;
  final int totalSteps;
  final void Function(int)? onStepTap;

  static const _labels = ['Personal Info', 'Contact & Address', 'Guardian'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;
          final label = index < _labels.length ? _labels[index] : 'Step ${index + 1}';

          return Expanded(
            child: GestureDetector(
              onTap: onStepTap != null ? () => onStepTap!(index) : null,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive || isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Step 0: Personal Info ───────────────────────────────────────────

class _PersonalInfoStep extends StatelessWidget {
  const _PersonalInfoStep({
    required this.state,
    required this.controller,
  });

  final PatientFormState state;
  final PatientFormController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('step0'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.fullName,
            decoration: InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter patient full name',
              errorText: state.errorForFullName,
              border: const OutlineInputBorder(),
            ),
            onChanged: controller.setFullName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.nationalId,
            decoration: InputDecoration(
              labelText: 'National ID',
              hintText: 'Optional',
              errorText: state.errorForNationalId,
              border: const OutlineInputBorder(),
            ),
            onChanged: controller.setNationalId,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          // Date of birth
          _DatePickerField(
            label: 'Date of Birth',
            value: state.dateOfBirth,
            onChanged: controller.setDateOfBirth,
          ),
          const SizedBox(height: AppSpacing.md),
          // Gender dropdown
          DropdownButtonFormField<String>(
            value: state.gender,
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
          // Blood group
          DropdownButtonFormField<String>(
            value: state.bloodGroup,
            decoration: const InputDecoration(
              labelText: 'Blood Group',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('Select...')),
              DropdownMenuItem(value: 'A+', child: Text('A+')),
              DropdownMenuItem(value: 'A-', child: Text('A-')),
              DropdownMenuItem(value: 'B+', child: Text('B+')),
              DropdownMenuItem(value: 'B-', child: Text('B-')),
              DropdownMenuItem(value: 'AB+', child: Text('AB+')),
              DropdownMenuItem(value: 'AB-', child: Text('AB-')),
              DropdownMenuItem(value: 'O+', child: Text('O+')),
              DropdownMenuItem(value: 'O-', child: Text('O-')),
            ],
            onChanged: controller.setBloodGroup,
          ),
          const SizedBox(height: AppSpacing.md),
          // Religion
          TextFormField(
            initialValue: state.religion ?? '',
            decoration: const InputDecoration(
              labelText: 'Religion',
              hintText: 'Optional',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => controller.setReligion(v),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          // Occupation
          TextFormField(
            initialValue: state.occupation ?? '',
            decoration: const InputDecoration(
              labelText: 'Occupation',
              hintText: 'Optional',
              border: OutlineInputBorder(),
            ),
            onChanged: controller.setOccupation,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ── Step 1: Contact & Address ───────────────────────────────────────

class _ContactAddressStep extends StatelessWidget {
  const _ContactAddressStep({
    required this.state,
    required this.controller,
  });

  final PatientFormState state;
  final PatientFormController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Contact ────────────────────────────────────────────
          Text('Contact Information',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'e.g. +8801XXXXXXXXX',
              errorText: state.errorForPhone,
              border: const OutlineInputBorder(),
            ),
            onChanged: controller.setPhone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.email,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'patient@example.com',
              errorText: state.errorForEmail,
              border: const OutlineInputBorder(),
            ),
            onChanged: controller.setEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            title: const Text('Emergency Contact'),
            subtitle: const Text('Mark this contact as emergency'),
            value: state.isEmergency,
            onChanged: controller.setIsEmergency,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: AppSpacing.lg),

          // ── Address ────────────────────────────────────────────
          Text('Address Information',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: state.addressType,
            decoration: const InputDecoration(
              labelText: 'Address Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'PRESENT', child: Text('Present')),
              DropdownMenuItem(value: 'PERMANENT', child: Text('Permanent')),
              DropdownMenuItem(value: 'WORK', child: Text('Work')),
              DropdownMenuItem(value: 'OTHER', child: Text('Other')),
            ],
            onChanged: controller.setAddressType,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.division ?? '',
            decoration: const InputDecoration(
              labelText: 'Division',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => controller.setDivision(v),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.district ?? '',
                  decoration: const InputDecoration(
                    labelText: 'District',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => controller.setDistrict(v),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  initialValue: state.upazila ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Upazila',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => controller.setUpazila(v),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.unionOrCity ?? '',
            decoration: const InputDecoration(
              labelText: 'Union / City',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => controller.setUnionOrCity(v),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.villageOrWard ?? '',
            decoration: const InputDecoration(
              labelText: 'Village / Ward',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => controller.setVillageOrWard(v),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.street,
            decoration: const InputDecoration(
              labelText: 'Street / Road',
              border: OutlineInputBorder(),
            ),
            onChanged: controller.setStreet,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: state.postCode,
                  decoration: InputDecoration(
                    labelText: 'Post Code',
                    errorText: state.errors['postCode'],
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: controller.setPostCode,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  initialValue: state.country,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => controller.setCountry(v),
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ── Step 2: Guardian ────────────────────────────────────────────────

class _GuardianStep extends StatelessWidget {
  const _GuardianStep({
    required this.state,
    required this.controller,
  });

  final PatientFormState state;
  final PatientFormController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Guardian / Next of Kin',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Provide guardian details if the patient is a minor or requires a nominated representative.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.guardianName,
            decoration: InputDecoration(
              labelText: 'Guardian Full Name',
              hintText: 'Enter guardian name',
              errorText: state.errorForGuardianName,
              border: const OutlineInputBorder(),
            ),
            onChanged: controller.setGuardianName,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.guardianRelationship ?? '',
            decoration: const InputDecoration(
              labelText: 'Relationship',
              hintText: 'e.g. Father, Mother, Spouse',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => controller.setGuardianRelationship(v),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.guardianPhone ?? '',
            decoration: const InputDecoration(
              labelText: 'Guardian Phone',
              hintText: 'e.g. +8801XXXXXXXXX',
              border: OutlineInputBorder(),
            ),
            onChanged: controller.setGuardianPhone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.guardianEmail ?? '',
            decoration: const InputDecoration(
              labelText: 'Guardian Email',
              hintText: 'guardian@example.com',
              border: OutlineInputBorder(),
            ),
            onChanged: controller.setGuardianEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            initialValue: state.guardianAddress ?? '',
            decoration: const InputDecoration(
              labelText: 'Guardian Address',
              hintText: 'Full address',
              border: OutlineInputBorder(),
            ),
            onChanged: controller.setGuardianAddress,
            maxLines: 2,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            title: const Text('Patient is a Minor'),
            subtitle: const Text(
                'A guardian is required for patients under 18'),
            value: state.guardianIsMinor,
            onChanged: controller.setGuardianIsMinor,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ── Date Picker Field ───────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
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
          initialDate: value ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
          firstDate: DateTime(1880),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : 'Not set',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: value != null ? null : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

// ── Step Navigation ─────────────────────────────────────────────────

class _StepNavigation extends StatelessWidget {
  const _StepNavigation({
    required this.currentStep,
    required this.totalSteps,
    required this.isSubmitting,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
  });

  final int currentStep;
  final int totalSteps;
  final bool isSubmitting;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep > 0)
              OutlinedButton.icon(
                onPressed: isSubmitting ? null : onPrevious,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Previous'),
              )
            else
              const SizedBox(),
            const Spacer(),
            if (currentStep < totalSteps - 1)
              FilledButton.icon(
                onPressed: isSubmitting ? null : onNext,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Next'),
              )
            else
              FilledButton.icon(
                onPressed: isSubmitting ? null : onSubmit,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(isSubmitting ? 'Saving...' : 'Create Patient'),
              ),
          ],
        ),
      ),
    );
  }
}
