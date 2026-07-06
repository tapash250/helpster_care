import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/widgets/widgets.dart';
import 'package:helpster_care/features/clinical/controllers/treatment_controller.dart';
import 'package:helpster_care/features/clinical/providers/treatment_providers.dart';

/// Screen to create a new treatment record.
class TreatmentFormScreen extends ConsumerStatefulWidget {
  const TreatmentFormScreen({
    super.key,
    this.patientId,
    this.patientName,
  });

  /// Pre-selected patient ID (when navigated from patient detail).
  final String? patientId;
  final String? patientName;

  @override
  ConsumerState<TreatmentFormScreen> createState() =>
      _TreatmentFormScreenState();
}

class _TreatmentFormScreenState extends ConsumerState<TreatmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _expectedOutcomeController = TextEditingController();
  final _consultantNameController = TextEditingController();

  // Patient
  String? _patientId;
  String? _patientName;

  // Treatment type
  String _treatmentType = 'CONSERVATIVE';

  // Conservative fields
  final _medicationController = TextEditingController();
  final _investigationsController = TextEditingController();

  // Surgical fields
  final _procedureController = TextEditingController();
  final _surgeonNameController = TextEditingController();
  final _implantsController = TextEditingController();
  final _operationNotesController = TextEditingController();
  bool _icuTransfer = false;

  // Dates
  DateTime? _admissionDate;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _patientId = widget.patientId;
    _patientName = widget.patientName;
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _expectedOutcomeController.dispose();
    _consultantNameController.dispose();
    _medicationController.dispose();
    _investigationsController.dispose();
    _procedureController.dispose();
    _surgeonNameController.dispose();
    _implantsController.dispose();
    _operationNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _admissionDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _admissionDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      Map<String, dynamic>? conservativeData;
      Map<String, dynamic>? surgicalData;

      if (_treatmentType == 'CONSERVATIVE') {
        conservativeData = {
          'medication': _medicationController.text.trim(),
          'investigations': _investigationsController.text.trim(),
        };
      } else {
        surgicalData = {
          'procedure': _procedureController.text.trim(),
          'surgeon_name': _surgeonNameController.text.trim(),
          'implants': _implantsController.text.trim(),
          'operation_notes': _operationNotesController.text.trim(),
          'icu_transfer': _icuTransfer,
        };
      }

      final result = await ref
          .read(treatmentControllerProvider.notifier)
          .createTreatment(
            patientId: _patientId!,
            treatmentType: _treatmentType,
            diagnosis:
                _diagnosisController.text.trim().isNotEmpty
                    ? _diagnosisController.text.trim()
                    : null,
            consultantId:
                _consultantNameController.text.trim().isNotEmpty
                    ? _consultantNameController.text.trim()
                    : null,
            admissionDate: _admissionDate,
            expectedOutcome:
                _expectedOutcomeController.text.trim().isNotEmpty
                    ? _expectedOutcomeController.text.trim()
                    : null,
            conservativeData: conservativeData,
            surgicalData: surgicalData,
          );

      if (result != null && mounted) {
        ref.invalidate(treatmentListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treatment created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create treatment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Treatment'),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient section
                  DataCard(
                    title: _patientName ?? 'Patient',
                    children: [
                      if (_patientId != null && _patientName != null)
                        _InfoText(
                          'Patient: $_patientName ($_patientId)',
                        )
                      else
                        _InfoText('Patient not selected'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Treatment type selector
                  DataCard(
                    title: 'Treatment Type',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _TypeOption(
                              icon: Icons.medical_services_outlined,
                              label: 'Conservative',
                              isSelected:
                                  _treatmentType == 'CONSERVATIVE',
                              onTap: () => setState(
                                  () => _treatmentType = 'CONSERVATIVE'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _TypeOption(
                              icon: Icons.surgery_outlined,
                              label: 'Surgical',
                              isSelected:
                                  _treatmentType == 'SURGICAL',
                              onTap: () => setState(
                                  () => _treatmentType = 'SURGICAL'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Basic details
                  DataCard(
                    title: 'Basic Details',
                    children: [
                      TextFormField(
                        controller: _diagnosisController,
                        decoration: const InputDecoration(
                          labelText: 'Diagnosis *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Diagnosis is required'
                                : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _consultantNameController,
                        decoration: const InputDecoration(
                          labelText: 'Consultant Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Admission Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _admissionDate != null
                                ? '${_admissionDate!.day}/${_admissionDate!.month}/${_admissionDate!.year}'
                                : 'Select date',
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _expectedOutcomeController,
                        decoration: const InputDecoration(
                          labelText: 'Expected Outcome',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Type-specific fields
                  if (_treatmentType == 'CONSERVATIVE')
                    DataCard(
                      title: 'Conservative Treatment Details',
                      children: [
                        TextFormField(
                          controller: _medicationController,
                          decoration: const InputDecoration(
                            labelText: 'Medication / Therapy',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _investigationsController,
                          decoration: const InputDecoration(
                            labelText: 'Investigations',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),

                  if (_treatmentType == 'SURGICAL')
                    DataCard(
                      title: 'Surgical Treatment Details',
                      children: [
                        TextFormField(
                          controller: _procedureController,
                          decoration: const InputDecoration(
                            labelText: 'Procedure *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Procedure is required'
                                  : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _surgeonNameController,
                          decoration: const InputDecoration(
                            labelText: 'Surgeon Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _implantsController,
                          decoration: const InputDecoration(
                            labelText: 'Implants',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _operationNotesController,
                          decoration: const InputDecoration(
                            labelText: 'Operation Notes',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        CheckboxListTile(
                          title: const Text('ICU Transfer Required'),
                          value: _icuTransfer,
                          onChanged: (v) =>
                              setState(() => _icuTransfer = v ?? false),
                          controlAffinity:
                              ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),

                  const SizedBox(height: AppSpacing.lg),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create Treatment'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  const _InfoText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}
