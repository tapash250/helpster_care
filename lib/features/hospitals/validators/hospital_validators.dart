/// Validators for hospital form fields.
///
/// Returns a non-null error message when validation fails, or null
/// when the value is valid.
class HospitalValidators {
  const HospitalValidators._();

  /// Validates hospital name (required, 2-200 chars).
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hospital name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 200) {
      return 'Name must not exceed 200 characters';
    }
    return null;
  }

  /// Validates phone number (optional, but valid format if provided).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleaned.length < 7 || cleaned.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validates email (optional, but valid format if provided).
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates website URL (optional, but valid format if provided).
  static String? validateWebsite(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final urlRegex = RegExp(
      r'^(https?:\/\/)?[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Enter a valid URL';
    }
    return null;
  }

  /// Validates registration number.
  static String? validateRegistrationNo(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < 3) {
      return 'Registration number is too short';
    }
    return null;
  }

  /// Validates address.
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 500) {
      return 'Address must not exceed 500 characters';
    }
    return null;
  }

  /// Validates hospital type.
  static String? validateHospitalType(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > 100) {
      return 'Type must not exceed 100 characters';
    }
    return null;
  }
}
