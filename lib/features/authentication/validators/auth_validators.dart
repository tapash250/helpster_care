/// Form validation functions for authentication flows.
///
/// Each function returns `null` when valid, or a user-facing error [String]
/// when invalid. These are pure functions — no side effects, no dependencies.
library;

/// Validates an email address.
///
/// Returns `null` when the email is non-empty and matches a basic email format.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

/// Validates a password.
///
/// Requires at least 6 characters. Returns `null` when valid.
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

/// Validates that [confirmPassword] matches [password].
///
/// Returns `null` when they match.
String? validateConfirmPassword(String? confirmPassword, String password) {
  if (confirmPassword == null || confirmPassword.isEmpty) {
    return 'Please confirm your password';
  }
  if (confirmPassword != password) {
    return 'Passwords do not match';
  }
  return null;
}

/// Validates a full name / display name.
///
/// Requires at least 2 characters. Returns `null` when valid.
String? validateFullName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Full name is required';
  }
  if (value.trim().length < 2) {
    return 'Name must be at least 2 characters';
  }
  return null;
}
