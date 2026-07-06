/// Authentication repository.
///
/// Mediates between the auth data source and the presentation layer. Exposes
/// typed result-like return values so callers can pattern-match without
/// try/catch (AGENTS.md §158, §164).
library;

import '../datasources/remote/auth_datasource.dart';

/// Result of a sign-in or sign-up operation.
sealed class AuthResult {
  const AuthResult();
}

/// Operation succeeded.
class AuthSuccess extends AuthResult {
  const AuthSuccess({this.userId});
  final String? userId;
}

/// Operation failed.
class AuthFailure extends AuthResult {
  const AuthFailure(this.message);
  final String message;
}

/// Repository for authentication operations.
class AuthRepository {
  /// Creates an [AuthRepository] backed by [dataSource].
  AuthRepository({required AuthRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final AuthRemoteDataSource _dataSource;

  /// Sign in with email and password.
  ///
  /// Returns an [AuthResult] — callers should pattern-match on [AuthSuccess]
  /// or [AuthFailure] instead of using try/catch.
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.signIn(
        email: email,
        password: password,
      );
      return AuthSuccess(userId: response.user?.id);
    } catch (e) {
      return AuthFailure(_mapError(e));
    }
  }

  /// Sign up with email and password.
  ///
  /// [fullName] is stored as user metadata. Returns an [AuthResult].
  Future<AuthResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      return AuthSuccess(userId: response.user?.id);
    } catch (e) {
      return AuthFailure(_mapError(e));
    }
  }

  /// Send a password reset email.
  ///
  /// Returns `null` on success or an error [String] on failure.
  Future<String?> resetPassword(String email) async {
    try {
      await _dataSource.resetPassword(email);
      return null;
    } catch (e) {
      return _mapError(e);
    }
  }

  /// Sign out the current user.
  Future<void> signOut() => _dataSource.signOut();

  /// Map an exception to a user-facing error message.
  String _mapError(Object error) {
    if (error is AuthException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
