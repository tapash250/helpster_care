/// Centralized animation-duration tokens (AGENTS.md §33, §139).
///
/// Durations stay within the 150–300 ms range recommended for state-communicating
/// motion. Respect reduced-motion accessibility settings at call sites.
class AppAnimation {
  const AppAnimation._();

  /// 150 ms — quick feedback.
  static const Duration fast = Duration(milliseconds: 150);

  /// 220 ms — default transition.
  static const Duration medium = Duration(milliseconds: 220);

  /// 300 ms — emphasized transition.
  static const Duration slow = Duration(milliseconds: 300);
}
