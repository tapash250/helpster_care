import 'package:helpster_care/shared/models/patient.dart';

/// Validation error keyed by field name.
typedef FieldErrors = Map<String, String?>;

/// Represents the complete state of the patient create/edit form.
class PatientFormState {
  const PatientFormState({
    this.fullName = '',
    this.nationalId = '',
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.religion,
    this.occupation,
    this.phone = '',
    this.email = '',
    this.isEmergency = false,
    this.addressType = 'PRESENT',
    this.division,
    this.district,
    this.upazila,
    this.unionOrCity,
    this.villageOrWard,
    this.street,
    this.postCode,
    this.country = 'Bangladesh',
    this.guardianName = '',
    this.guardianRelationship,
    this.guardianPhone,
    this.guardianEmail,
    this.guardianAddress,
    this.guardianIsMinor = false,
    this.status = 'DRAFT',
    this.photoPath,
    this.errors = const {},
    this.isSubmitting = false,
    this.isEdit = false,
    this.step = 0,
  });

  // ── Patient fields ──────────────────────────────────────────────
  final String fullName;
  final String nationalId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  final String? religion;
  final String? occupation;
  final String? photoPath;

  // ── Contact fields ──────────────────────────────────────────────
  final String phone;
  final String email;
  final bool isEmergency;

  // ── Address fields ──────────────────────────────────────────────
  final String addressType;
  final String? division;
  final String? district;
  final String? upazila;
  final String? unionOrCity;
  final String? villageOrWard;
  final String? street;
  final String? postCode;
  final String country;

  // ── Guardian fields ─────────────────────────────────────────────
  final String guardianName;
  final String? guardianRelationship;
  final String? guardianPhone;
  final String? guardianEmail;
  final String? guardianAddress;
  final bool guardianIsMinor;

  // ── Meta ────────────────────────────────────────────────────────
  final String status;
  final FieldErrors errors;
  final bool isSubmitting;
  final bool isEdit;
  final int step;

  static const int totalSteps = 3;

  bool get isValid => errors.values.every((e) => e == null);

  bool get hasErrors => errors.values.any((e) => e != null);

  bool get canSubmit => isValid && fullName.isNotEmpty && !isSubmitting;

  String? get errorForFullName => errors['fullName'];
  String? get errorForNationalId => errors['nationalId'];
  String? get errorForPhone => errors['phone'];
  String? get errorForEmail => errors['email'];
  String? get errorForGuardianName => errors['guardianName'];

  PatientFormState copyWith({
    String? fullName,
    String? nationalId,
    DateTime? dateOfBirth,
    bool? clearDateOfBirth,
    String? gender,
    String? bloodGroup,
    String? religion,
    String? occupation,
    String? photoPath,
    String? phone,
    String? email,
    bool? isEmergency,
    String? addressType,
    String? division,
    String? district,
    String? upazila,
    String? unionOrCity,
    String? villageOrWard,
    String? street,
    String? postCode,
    String? country,
    String? guardianName,
    String? guardianRelationship,
    String? guardianPhone,
    String? guardianEmail,
    String? guardianAddress,
    bool? guardianIsMinor,
    String? status,
    FieldErrors? errors,
    bool? isSubmitting,
    bool? isEdit,
    int? step,
  }) {
    return PatientFormState(
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      dateOfBirth: clearDateOfBirth == true ? null : (dateOfBirth ?? this.dateOfBirth),
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      religion: religion ?? this.religion,
      occupation: occupation ?? this.occupation,
      photoPath: photoPath ?? this.photoPath,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isEmergency: isEmergency ?? this.isEmergency,
      addressType: addressType ?? this.addressType,
      division: division ?? this.division,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      unionOrCity: unionOrCity ?? this.unionOrCity,
      villageOrWard: villageOrWard ?? this.villageOrWard,
      street: street ?? this.street,
      postCode: postCode ?? this.postCode,
      country: country ?? this.country,
      guardianName: guardianName ?? this.guardianName,
      guardianRelationship: guardianRelationship ?? this.guardianRelationship,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      guardianEmail: guardianEmail ?? this.guardianEmail,
      guardianAddress: guardianAddress ?? this.guardianAddress,
      guardianIsMinor: guardianIsMinor ?? this.guardianIsMinor,
      status: status ?? this.status,
      errors: errors ?? this.errors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isEdit: isEdit ?? this.isEdit,
      step: step ?? this.step,
    );
  }

  /// Build a [Patient] from the current form state (for create).
  Patient toPatient(String id) {
    return Patient(
      id: id,
      patientId: _generatePatientId(),
      nationalId: nationalId.isNotEmpty ? nationalId : null,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      bloodGroup: bloodGroup,
      religion: religion,
      occupation: occupation,
      photoPath: photoPath,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Build a [PatientContact] from current contact fields.
  PatientContact toContact(String patientId) {
    return PatientContact(
      id: _generateId('contact'),
      patientId: patientId,
      phone: phone.isNotEmpty ? phone : null,
      email: email.isNotEmpty ? email : null,
      isEmergency: isEmergency,
    );
  }

  /// Build a [PatientAddress] from current address fields.
  PatientAddress toAddress(String patientId) {
    return PatientAddress(
      id: _generateId('addr'),
      patientId: patientId,
      addressType: addressType,
      division: division,
      district: district,
      upazila: upazila,
      unionOrCity: unionOrCity,
      villageOrWard: villageOrWard,
      street: street,
      postCode: postCode,
      country: country,
    );
  }

  /// Build a [PatientGuardian] from current guardian fields.
  PatientGuardian toGuardian(String patientId) {
    return PatientGuardian(
      id: _generateId('guard'),
      patientId: patientId,
      fullName: guardianName,
      relationship: guardianRelationship,
      phone: guardianPhone,
      email: guardianEmail,
      address: guardianAddress,
      isMinor: guardianIsMinor,
    );
  }

  /// Populate form state from an existing patient + related data.
  static PatientFormState fromPatient(
    Patient patient, {
    PatientContact? contact,
    PatientAddress? address,
    PatientGuardian? guardian,
  }) {
    return PatientFormState(
      fullName: patient.fullName,
      nationalId: patient.nationalId ?? '',
      dateOfBirth: patient.dateOfBirth,
      gender: patient.gender,
      bloodGroup: patient.bloodGroup,
      religion: patient.religion,
      occupation: patient.occupation,
      photoPath: patient.photoPath,
      phone: contact?.phone ?? '',
      email: contact?.email ?? '',
      isEmergency: contact?.isEmergency ?? false,
      addressType: address?.addressType ?? 'PRESENT',
      division: address?.division,
      district: address?.district,
      upazila: address?.upazila,
      unionOrCity: address?.unionOrCity,
      villageOrWard: address?.villageOrWard,
      street: address?.street,
      postCode: address?.postCode,
      country: address?.country ?? 'Bangladesh',
      guardianName: guardian?.fullName ?? '',
      guardianRelationship: guardian?.relationship,
      guardianPhone: guardian?.phone,
      guardianEmail: guardian?.email,
      guardianAddress: guardian?.address,
      guardianIsMinor: guardian?.isMinor ?? false,
      status: patient.status,
      isEdit: true,
    );
  }

  static String _generatePatientId() {
    final now = DateTime.now();
    final year = now.year.toString();
    final random = (DateTime.now().microsecondsSinceEpoch % 999999)
        .toString()
        .padLeft(6, '0');
    return 'PAT-$year-$random';
  }

  static String _generateId(String prefix) {
    final ts = DateTime.now().microsecondsSinceEpoch.toString();
    return '${prefix}_$ts';
  }
}
