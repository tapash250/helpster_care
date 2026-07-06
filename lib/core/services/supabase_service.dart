/// Centralized Supabase client.
///
/// Provides a single [SupabaseClient] instance initialized from environment
/// configuration. All Supabase operations go through this service — never
/// create raw clients (AGENTS.md §47, §167).
library;

import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton wrapper around the Supabase client.
class SupabaseService {
  SupabaseService._();

  static final SupabaseService _instance = SupabaseService._();
  static SupabaseService get instance => _instance;

  SupabaseClient? _client;

  /// Whether the service has been initialized.
  bool get isInitialized => _client != null;

  /// The [SupabaseClient] instance. Throws if not initialized.
  SupabaseClient get client {
    if (_client == null) {
      throw StateError(
        'SupabaseService not initialized. Call init() before accessing client.',
      );
    }
    return _client!;
  }

  /// Initialize the Supabase connection.
  ///
  /// [supabaseUrl] and [supabaseAnonKey] come from environment configuration.
  Future<void> init({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Convenience accessor for the auth instance.
  GoTrueClient get auth => client.auth;

  /// Convenience accessor for the current user id (or null).
  String? get currentUserId => auth.currentUser?.id;

  /// Disconnect and clean up.
  Future<void> dispose() async {
    await client.dispose();
    _client = null;
  }
}
