/// Centralized corner-radius tokens (AGENTS.md §33).
///
/// Never hardcode radii. Use these tokens, e.g. `AppRadius.lg`.
class AppRadius {
  const AppRadius._();

  /// 4.0 logical pixels.
  static const double sm = 4;

  /// 8.0 logical pixels.
  static const double md = 8;

  /// 16.0 logical pixels.
  static const double lg = 16;

  /// 24.0 logical pixels.
  static const double xl = 24;

  /// Fully rounded (pill) radius.
  static const double pill = 999;
}
