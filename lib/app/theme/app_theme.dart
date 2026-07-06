import 'package:flutter/material.dart';

/// Centralized Material 3 theme for Helpster Care.
///
/// The app uses Material 3 exclusively (AGENTS.md §115) with a single design
/// language. Widgets must consume theme/token values only — hardcoded colors,
/// spacing, radii, and typography are forbidden (§32, §33, §118).
///
/// Light and dark schemes are derived from a single seed color that expresses
/// the brand values: trust, professionalism, calmness (§116).
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF0E7C7B);

  /// Light theme.
  static ThemeData get light => _build(Brightness.light);

  /// Dark theme.
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
    );
  }
}
