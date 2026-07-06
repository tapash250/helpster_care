/// Authentication service wrapping Supabase Auth.
///
/// All auth operations (sign in, sign up, sign out, session management) are
/// centralized here. Widgets never call Supabase Auth directly
/// (AGENTS.md §46–§48).
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'supabase_service.dart';

/// Authentication states exposed to the UI layer.
sealed class AuthState {
  const AuthState();

  /// Initial (loading) state.
  const factory AuthState.initial() = _AuthInitial;

  /// User is authenticated.
  const factory AuthState.authenticated(User user) = _AuthAuthenticated;

  /// No active session.
  const factory AuthState.unauthenticated() = _AuthUnauthenticated;

  /// An error occurred during authentication.
  const factory AuthState.error(String message) = _AuthError;
}

class _AuthInitial extends AuthState {
  const _AuthInitial();
}

class _AuthAuthenticated extends AuthState {
  const _AuthAuthenticated(this.user);
  final User user;
}

class _AuthUnauthenticated extends AuthState {
  const _AuthUnauthenticated();
}

class _AuthError extends AuthState {
  const _AuthError(this.message);
  final String message;
}

/// Service for authentication operations.
class AuthService {
  AuthService({required SupabaseService supabase})
      : _supabase = supabase;

  final SupabaseService _supabase;

  GoTrueClient get _auth => _supabase.auth;

  /// Stream of auth state changes for Riverpod providers.
  Stream<AuthState> get authStateChanges {
    return _auth.onAuthStateChange.map((event) {
      if (event.session?.user != null) {
        return AuthState.authenticated(event.session!.user!);
      }
      return AuthState.unauthenticated();
    });
  }

  /// Current session user.
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password.
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithPassword(email: email, password: password);
  }

  /// Sign up with email and password.
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return _auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Send password reset email.
  Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(email);
  }

  /// Update user profile.
  Future<UserResponse> updateUser(UserAttributes attributes) async {
    return _auth.updateUser(attributes);
  }

  /// Get the current session, or null.
  Session? get currentSession => _auth.currentSession;
}

/// Riverpod provider for AuthService.
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return AuthService(supabase: supabase);
});

/// Riverpod provider that streams auth state changes.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for the current authenticated user (nullable).
final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser;
});
