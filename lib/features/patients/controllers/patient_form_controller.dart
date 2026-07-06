/// Controller for the patient create/edit form.
///
/// Manages multi-step form state, field validation, and submission.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helpster_care/features/patients/repositories/patient_repository.dart';
import 'package:helpster_care/features/patients/states/patient_form_state.dart';
import 'package:helpster_care/features/patients/validators/patient_validators.dart';
import 'package:helpster_care/shared/models/patient.dart';

/// Notifier managing patient form state and submission.
class PatientFormController extends Notifier<PatientFormState> {
  @override
  PatientFormState build() => const PatientFormState();

  /// Initialise for editing an existing patient.
  void loadForEdit(
    Patient patient, {
    PatientContact? contact,
    PatientAddress? address,
    PatientGuardian? guardian,
  }) {
    state = PatientFormState.fromPatient(
      patient,
      contact: contact,
      address: address,
      guardian: guardian,
    );
  }

  /// Reset the form to initial state.
  void reset() => state = const PatientFormState();

  // ── Field setters ───────────────────────────────────────────────

  void setFullName(String value) {
    state = state.copyWith(fullName: value, errors: {
      ...state.errors,
      'fullName': PatientValidators.fullName(value),
    });
  }

  void setNationalId(String value) {
    state = state.copyWith(nationalId: value, errors: {
      ...state.errors,
      'nationalId': PatientValidators.nationalId(value),
    });
  }

  void setDateOfBirth(DateTime? value) {
    state = state.copyWith(
      dateOfBirth: value,
      clearDateOfBirth: value == null,
      errors: {
        ...state.errors,
        'dateOfBirth': PatientValidators.dateOfBirth(value),
      },
    );
  }

  void setGender(String? value) {
    state = state.copyWith(gender: value);
  }

  void setBloodGroup(String? value) {
    state = state.copyWith(bloodGroup: value);
  }

  void setReligion(String? value) {
    state = state.copyWith(religion: value);
  }

  void setOccupation(String value) {
    state = state.copyWith(occupation: value);
  }

  void setPhotoPath(String? path) {
    state = state.copyWith(photoPath: path);
  }

  void setPhone(String value) {
    state = state.copyWith(
      phone: value,
      errors: {...state.errors, 'phone': PatientValidators.phone(value)},
    );
  }

  void setEmail(String value) {
    state = state.copyWith(
      email: value,
      errors: {...state.errors, 'email': PatientValidators.email(value)},
    );
  }

  void setIsEmergency(bool value) {
    state = state.copyWith(isEmergency: value);
  }

  void setAddressType(String value) {
    state = state.copyWith(addressType: value);
  }

  void setDivision(String? value) {
    state = state.copyWith(division: value);
  }

  void setDistrict(String? value) {
    state = state.copyWith(district: value);
  }

  void setUpazila(String? value) {
    state = state.copyWith(upazila: value);
  }

  void setUnionOrCity(String? value) {
    state = state.copyWith(unionOrCity: value);
  }

  void setVillageOrWard(String? value) {
    state = state.copyWith(villageOrWard: value);
  }

  void setStreet(String value) {
    state = state.copyWith(street: value);
  }

  void setPostCode(String value) {
    state = state.copyWith(
      postCode: value,
      errors: {...state.errors, 'postCode': PatientValidators.postCode(value)},
    );
  }

  void setGuardianName(String value) {
    final hasGuardianData = value.isNotEmpty ||
        (state.guardianPhone != null && state.guardianPhone!.isNotEmpty);
    state = state.copyWith(
      guardianName: value,
      errors: {
        ...state.errors,
        'guardianName': PatientValidators.guardianName(
          value,
          isRequired: hasGuardianData,
        ),
      },
    );
  }

  void setGuardianRelationship(String? value) {
    state = state.copyWith(guardianRelationship: value);
  }

  void setGuardianPhone(String value) {
    state = state.copyWith(guardianPhone: value);
  }

  void setGuardianEmail(String value) {
    state = state.copyWith(guardianEmail: value);
  }

  void setGuardianAddress(String value) {
    state = state.copyWith(guardianAddress: value);
  }

  void setGuardianIsMinor(bool value) {
    state = state.copyWith(guardianIsMinor: value);
  }

  void setStatus(String value) {
    state = state.copyWith(status: value);
  }

  // ── Navigation ──────────────────────────────────────────────────

  void nextStep() {
    if (state.step < PatientFormState.totalSteps - 1) {
      state = state.copyWith(step: state.step + 1);
    }
  }

  void previousStep() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < PatientFormState.totalSteps) {
      state = state.copyWith(step: step);
    }
  }

  // ── Validation ──────────────────────────────────────────────────

  /// Validate the current step. Returns true if valid.
  bool validateCurrentStep() {
    final errors = <String, String?>{};

    // Step 0: Personal info
    if (state.step == 0) {
      errors['fullName'] = PatientValidators.fullName(state.fullName);
      errors['nationalId'] = PatientValidators.nationalId(state.nationalId);
      errors['email'] = PatientValidators.email(state.email);
    }

    // Step 1: Contact & Address
    if (state.step == 1) {
      errors['phone'] = PatientValidators.phone(state.phone);
      errors['email'] = PatientValidators.email(state.email);
    }

    // Step 2: Guardian
    if (state.step == 2) {
      final hasGuardianData = state.guardianName.isNotEmpty ||
          (state.guardianPhone != null && state.guardianPhone!.isNotEmpty);
      errors['guardianName'] = PatientValidators.guardianName(
        state.guardianName,
        isRequired: hasGuardianData,
      );
    }

    state = state.copyWith(errors: errors);
    return errors.values.every((e) => e == null);
  }

  /// Validate the entire form. Returns true if valid.
  bool validateAll() {
    final errors = <String, String?>{
      'fullName': PatientValidators.fullName(state.fullName),
      'nationalId': PatientValidators.nationalId(state.nationalId),
      'phone': PatientValidators.phone(state.phone),
      'email': PatientValidators.email(state.email),
      'guardianName': PatientValidators.guardianName(
        state.guardianName,
        isRequired: state.guardianName.isNotEmpty ||
            (state.guardianPhone != null && state.guardianPhone!.isNotEmpty),
      ),
    };
    state = state.copyWith(errors: errors);
    return errors.values.every((e) => e == null);
  }

  // ── Submission ──────────────────────────────────────────────────

  /// Submit the form — create or update the patient.
  ///
  /// Returns the created/updated patient on success, or throws on failure.
  Future<Patient> submit() async {
    if (!state.canSubmit) {
      throw StateError('Form is not valid or already submitting');
    }

    if (!validateAll()) {
      // Find the first step with errors and navigate there
      if (state.errorForFullName != null ||
          state.errorForNationalId != null) {
        state = state.copyWith(step: 0);
      } else if (state.errorForPhone != null) {
        state = state.copyWith(step: 1);
      } else if (state.errorForGuardianName != null) {
        state = state.copyWith(step: 2);
      }
      throw StateError('Please fix the form errors before submitting');
    }

    state = state.copyWith(isSubmitting: true);

    try {
      final repo = ref.read(patientRepositoryProvider);
      final patientId = state.isEdit
          ? '' // Will be overwritten by caller for edits
          : 'pat_${DateTime.now().microsecondsSinceEpoch}';

      final patient = state.toPatient(patientId);
      final contact = state.toContact(patient.id);
      final address = state.toAddress(patient.id);
      final guardian = state.toGuardian(patient.id);

      Patient result;
      if (state.isEdit) {
        result = await repo.updatePatient(
          patient,
          contact: contact,
          address: address,
          guardian: guardian,
        );
      } else {
        final statusHistory = PatientStatusHistory(
          id: 'sh_${DateTime.now().microsecondsSinceEpoch}',
          patientId: patient.id,
          fromStatus: null,
          toStatus: patient.status,
          changedAt: DateTime.now(),
          changedBy: null,
          reason: 'Initial registration',
        );

        result = await repo.createPatient(
          patient,
          contact: contact,
          address: address,
          guardian: guardian,
          statusHistory: statusHistory,
        );
      }

      state = state.copyWith(isSubmitting: false);
      return result;
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}

/// Provider for the patient form controller.
final patientFormControllerProvider =
    NotifierProvider<PatientFormController, PatientFormState>(
  PatientFormController.new,
);
