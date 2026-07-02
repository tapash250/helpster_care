/// Centralized, type-safe access to environment configuration.
///
/// Values originate from `.env` (development) or platform secrets
/// (staging/production). Secrets are NEVER hardcoded here (AGENTS.md §81, §167).
///
/// This is a skeleton: wire up an actual loader (e.g. `flutter_dotenv` or
/// `--dart-define`) inside [load] as part of the environment feature work.
class Environment {
  const Environment._();

  static String _appEnv = 'development';

  /// The active environment: `development`, `staging`, or `production`.
  static String get appEnv => _appEnv;

  /// Whether the app is running in the production environment.
  static bool get isProduction => _appEnv == 'production';

  /// Loads environment configuration. Must be awaited before [main] runs the
  /// app. Kept intentionally minimal in the skeleton.
  static Future<void> load() async {
    // TODO(env): load from .env / --dart-define and validate required keys.
  }
}
