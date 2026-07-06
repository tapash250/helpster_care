/// Field-level validators for patient forms.
///
/// Every method returns `null` when the value is valid, or a non-null
/// error message string when invalid.
class PatientValidators {
  const PatientValidators._();

  /// Validates a full name (required, 2-200 chars).
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 200) {
      return 'Name must be less than 200 characters';
    }
    return null;
  }

  /// Validates a national ID (optional, alphanumeric).
  static String? nationalId(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 50) {
      return 'National ID must be less than 50 characters';
    }
    return null;
  }

  /// Validates a phone number (optional, basic format check).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.length < 7 || digits.length > 15) {
      return 'Enter a valid phone number (7-15 digits)';
    }
    return null;
  }

  /// Validates an email address (optional, basic format check).
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final pattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates guardian name (required if guardian fields are filled).
  static String? guardianName(String? value, {bool isRequired = false}) {
    if (isRequired && (value == null || value.trim().isEmpty)) {
      return 'Guardian name is required when guardian info is provided';
    }
    if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
      return 'Guardian name must be at least 2 characters';
    }
    return null;
  }

  /// Validates date of birth (must not be in the future).
  static String? dateOfBirth(DateTime? value) {
    if (value == null) return null;
    if (value.isAfter(DateTime.now())) {
      return 'Date of birth cannot be in the future';
    }
    if (value.year < 1880) {
      return 'Date of birth seems too far in the past';
    }
    return null;
  }

  /// Validates a patient status.
  static String? status(String? value) {
    const validStatuses = [
      'DRAFT',
      'PENDING_DOCUMENTS',
      'SUBMITTED',
      'UNDER_REVIEW',
      'MEDICAL_REVIEW',
      'APPROVED',
      'ACTIVE',
      'IN_TREATMENT',
      'DISCHARGED',
      'FOLLOWUP',
      'CLOSED',
      'REJECTED',
      'CANCELLED',
    ];
    if (value == null || !validStatuses.contains(value)) {
      return 'Please select a valid status';
    }
    return null;
  }

  /// Validates a post code (optional, alphanumeric).
  static String? postCode(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 10) {
      return 'Post code must be less than 10 characters';
    }
    return null;
  }
}
