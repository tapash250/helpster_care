/// Centralized, type-safe access to environment configuration.
///
/// Values originate from `.env` (development) or platform secrets
/// (staging/production). Secrets are NEVER hardcoded here (AGENTS.md §81, §167).
library;

import 'dart:io';

/// Environment configuration loaded from environment variables or .env file.
class Environment {
  const Environment._();

  static String _appEnv = 'development';
  static String _supabaseUrl = '';
  static String _supabaseAnonKey = '';
  static String _powersyncUrl = '';
  static String _appName = 'Helpster Care';
  static String _defaultLocale = 'en';
  static int _sessionTimeoutMinutes = 30;

  /// The active environment: `development`, `staging`, or `production`.
  static String get appEnv => _appEnv;

  /// Whether the app is running in the production environment.
  static bool get isProduction => _appEnv == 'production';

  /// Supabase project URL.
  static String get supabaseUrl => _supabaseUrl;

  /// Supabase anonymous public key.
  static String get supabaseAnonKey => _supabaseAnonKey;

  /// PowerSync instance URL.
  static String get powersyncUrl => _powersyncUrl;

  /// Application display name.
  static String get appName => _appName;

  /// Default locale code.
  static String get defaultLocale => _defaultLocale;

  /// Session timeout in minutes.
  static int get sessionTimeoutMinutes => _sessionTimeoutMinutes;

  /// Loads environment configuration from environment variables or .env file.
  ///
  /// Priority: Platform env vars > .env file > defaults
  static Future<void> load() async {
    // Try to load from .env file
    try {
      final envFile = File('.env');
      if (await envFile.exists()) {
        final lines = await envFile.readAsLines();
        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
          final eqIdx = trimmed.indexOf('=');
          if (eqIdx < 0) continue;
          final key = trimmed.substring(0, eqIdx).trim();
          final value = trimmed.substring(eqIdx + 1).trim();
          if (key == 'APP_ENV') _appEnv = value;
          if (key == 'SUPABASE_URL') _supabaseUrl = value;
          if (key == 'SUPABASE_ANON_KEY') _supabaseAnonKey = value;
          if (key == 'POWERSYNC_URL') _powersyncUrl = value;
          if (key == 'APP_NAME') _appName = value;
          if (key == 'DEFAULT_LOCALE') _defaultLocale = value;
          if (key == 'SESSION_TIMEOUT_MINUTES') {
            _sessionTimeoutMinutes = int.tryParse(value) ?? 30;
          }
        }
      }
    } catch (_) {
      // If .env fails, use platform env or defaults
    }

    // Platform environment variables override .env
    _appEnv = Platform.environment['APP_ENV'] ?? _appEnv;
    _supabaseUrl = Platform.environment['SUPABASE_URL'] ?? _supabaseUrl;
    _supabaseAnonKey = Platform.environment['SUPABASE_ANON_KEY'] ?? _supabaseAnonKey;
    _powersyncUrl = Platform.environment['POWERSYNC_URL'] ?? _powersyncUrl;

    // Validate required keys in production
    if (_appEnv == 'production') {
      assert(_supabaseUrl.isNotEmpty, 'SUPABASE_URL must be set in production');
      assert(_supabaseAnonKey.isNotEmpty, 'SUPABASE_ANON_KEY must be set in production');
    }
  }
}
