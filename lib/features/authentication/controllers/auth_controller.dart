/// Riverpod notifier for authentication actions.
///
/// Uses the `@riverpod` annotation (riverpod_generator) to produce the
/// provider. After running `dart run build_runner build`, the generated
/// `auth_controller.g.dart` file is created automatically.
///
/// This notifier manages form submission lifecycle — idle → submitting →
/// success | error — and delegates actual auth work to [AuthRepository].
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/auth_providers.dart';
import '../repositories/auth_repository.dart';
import '../states/auth_ui_state.dart';

part 'auth_controller.g.dart';

/// Notifier that manages authentication UI state transitions.
///
/// Exposes [signIn], [signUp], [resetPassword], and [resetState] for
/// screens to call. Each method sets [state] to inform the UI about
/// loading, success, or error conditions.
@riverpod
class AuthController extends _$AuthController {
  @override
  AuthUiState build() => const AuthUiState.idle();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  /// Sign in with [email] and [password].
  ///
  /// On success, the caller should navigate to '/' (handled by the screen).
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthUiState.submitting();
    final result = await _repository.signIn(email: email, password: password);
    switch (result) {
      case AuthSuccess _:
        state = const AuthUiState.success('Signed in successfully');
      case AuthFailure(:final message):
        state = AuthUiState.error(message);
    }
  }

  /// Sign up with [fullName], [email], and [password].
  ///
  /// On success, the caller should navigate to '/' (handled by the screen).
  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AuthUiState.submitting();
    final result = await _repository.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
    switch (result) {
      case AuthSuccess _:
        state = const AuthUiState.success('Account created successfully');
      case AuthFailure(:final message):
        state = AuthUiState.error(message);
    }
  }

  /// Send a password reset email to [email].
  Future<void> resetPassword(String email) async {
    state = const AuthUiState.submitting();
    final error = await _repository.resetPassword(email);
    if (error != null) {
      state = AuthUiState.error(error);
    } else {
      state = const AuthUiState.success(
        'Password reset email sent. Check your inbox.',
      );
    }
  }

  /// Reset state back to idle (e.g. after dismissing an error or success).
  void resetState() {
    state = const AuthUiState.idle();
  }
}
