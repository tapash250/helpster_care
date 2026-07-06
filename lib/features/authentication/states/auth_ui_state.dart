/// UI states for the authentication flow.
///
/// Represents the current status of an auth operation so screens can render
/// loading indicators, error banners, and success navigation consistently.
library;

/// States that the authentication UI can be in.
sealed class AuthUiState {
  const AuthUiState();

  /// Initial idle state — no operation in progress.
  const factory AuthUiState.idle() = _AuthIdle;

  /// An auth operation is in progress (sign in, sign up, or password reset).
  const factory AuthUiState.submitting() = _AuthSubmitting;

  /// The last operation completed successfully.
  const factory AuthUiState.success([String message = '']) = _AuthSuccess;

  /// The last operation failed with an error.
  const factory AuthUiState.error(String message) = _AuthError;
}

class _AuthIdle extends AuthUiState {
  const _AuthIdle();
}

class _AuthSubmitting extends AuthUiState {
  const _AuthSubmitting();
}

class _AuthSuccess extends AuthUiState {
  const _AuthSuccess([this.message = '']);
  final String message;
}

class _AuthError extends AuthUiState {
  const _AuthError(this.message);
  final String message;
}
