import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';
import 'package:helpster_care/shared/models/hospital.dart';
import 'package:helpster_care/shared/widgets/loading_overlay.dart';
import 'package:helpster_care/shared/widgets/error_banner.dart';
import 'package:helpster_care/features/hospitals/validators/hospital_validators.dart';
import 'package:helpster_care/features/hospitals/providers/hospital_list_provider.dart';
import 'package:helpster_care/features/hospitals/controllers/hospital_controller.dart';
import 'package:helpster_care/features/hospitals/routes/hospital_routes.dart';

/// Screen for creating or editing a hospital.
class HospitalFormScreen extends ConsumerStatefulWidget {
  const HospitalFormScreen({
    super.key,
    this.hospitalId,
  });

  /// If provided, the form is in edit mode.
  final String? hospitalId;

  bool get isEditing => hospitalId != null;

  @override
  ConsumerState<HospitalFormScreen> createState() =>
      _HospitalFormScreenState();
}

class _HospitalFormScreenState extends ConsumerState<HospitalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _registrationController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExisting();
    }
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(hospitalRepositoryProvider);
      final hospital = await repo.fetchHospitalById(widget.hospitalId!);
      if (hospital != null && mounted) {
        _nameController.text = hospital.name;
        _typeController.text = hospital.hospitalType ?? '';
        _addressController.text = hospital.address ?? '';
        _phoneController.text = hospital.phone ?? '';
        _emailController.text = hospital.email ?? '';
        _websiteController.text = hospital.website ?? '';
        _registrationController.text = hospital.registrationNo ?? '';
        _isActive = hospital.isActive;
      }
    } catch (_) {
      // Silently fail — form starts empty
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final formState = ref.read(hospitalFormControllerProvider);
    if (formState.isSubmitting) return;

    // Build hospital object via the Freezed constructor.
    final now = DateTime.now();
    final hospital = Hospital(
      id: '', // will be replaced by the DB on insert
      name: _nameController.text.trim(),
      hospitalType: _typeController.text.trim().isEmpty
          ? null
          : _typeController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      registrationNo: _registrationController.text.trim().isEmpty
          ? null
          : _registrationController.text.trim(),
      isActive: _isActive,
      createdAt: now,
      updatedAt: now,
    );

    final controller = ref.read(hospitalFormControllerProvider.notifier);

    String? resultId;
    if (widget.isEditing) {
      final success = await controller.updateHospital(
        hospital.copyWith(id: widget.hospitalId!),
      );
      if (success && mounted) context.pop();
    } else {
      resultId = await controller.createHospital(hospital);
      if (resultId != null && mounted) {
        context.replace(HospitalRoutes.detailPath(resultId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(hospitalFormControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Hospital' : 'New Hospital'),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Error banner
                  if (formState.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ErrorBanner(
                        message: formState.error!,
                        onDismiss: () =>
                            ref
                                .read(hospitalFormControllerProvider.notifier)
                                .reset(),
                      ),
                    ),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital Name *',
                      prefixIcon: Icon(Icons.local_hospital_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: HospitalValidators.validateName,
                    textCapitalization: TextCapitalization.words,
                    enabled: !formState.isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Type field
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital Type',
                      hintText: 'e.g., General, Teaching, Specialized',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: HospitalValidators.validateHospitalType,
                    textCapitalization: TextCapitalization.words,
                    enabled: !formState.isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Address field
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: HospitalValidators.validateAddress,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    enabled: !formState.isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: HospitalValidators.validatePhone,
                    keyboardType: TextInputType.phone,
                    enabled: !formState.isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: HospitalValidators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !formState.isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Website field
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website',
                      prefixIcon: Icon(Icons.language_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: HospitalValidators.validateWebsite,
                    keyboardType: TextInputType.url,
                    enabled: !formState.isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Registration No field
                  TextFormField(
                    controller: _registrationController,
                    decoration: const InputDecoration(
                      labelText: 'Registration No.',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: HospitalValidators.validateRegistrationNo,
                    enabled: !formState.isSubmitting,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Active toggle
                  SwitchListTile(
                    title: const Text('Active'),
                    subtitle: const Text('Hospital is active and operational'),
                    value: _isActive,
                    onChanged: formState.isSubmitting
                        ? null
                        : (val) => setState(() => _isActive = val),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Submit button
                  FilledButton(
                    onPressed: formState.isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    child: Text(
                      widget.isEditing ? 'Update Hospital' : 'Create Hospital',
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (formState.isSubmitting)
            const LoadingOverlay(message: 'Saving...'),
        ],
      ),
    );
  }
}
