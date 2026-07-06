/// Data classes for authentication forms.
///
/// Plain Dart classes (not freezed) per AGENTS.md — these are simple value
/// holders with no serialization or complex equality needs.
library;

/// Form data for the sign-in flow.
class LoginFormData {
  const LoginFormData({
    required this.email,
    required this.password,
  });

  /// User email address.
  final String email;

  /// User password.
  final String password;
}

/// Form data for the sign-up flow.
class SignUpFormData {
  const SignUpFormData({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  /// User's full display name.
  final String fullName;

  /// User email address.
  final String email;

  /// User password.
  final String password;

  /// Password confirmation (must match [password]).
  final String confirmPassword;
}
