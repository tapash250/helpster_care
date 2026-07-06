/// Remote authentication data source.
///
/// Abstracts Supabase Auth calls behind a simple interface. The UI layer never
/// depends on Supabase types directly — only this datasource and the repository
/// layer above it do (AGENTS.md §46–§48).
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/auth_service.dart';

/// Data source for authentication operations against Supabase Auth.
class AuthRemoteDataSource {
  /// Creates an [AuthRemoteDataSource] backed by [authService].
  AuthRemoteDataSource({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;

  /// Sign in with email and password.
  ///
  /// Returns an [AuthResponse] on success. Throws on failure.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signInWithEmail(email: email, password: password);
  }

  /// Sign up with email and password.
  ///
  /// [data] is optional extra metadata (e.g. display name). Returns an
  /// [AuthResponse] on success. Throws on failure.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return _authService.signUpWithEmail(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Send a password reset email to [email].
  Future<void> resetPassword(String email) {
    return _authService.resetPassword(email);
  }

  /// Sign out the current user.
  Future<void> signOut() {
    return _authService.signOut();
  }
}
