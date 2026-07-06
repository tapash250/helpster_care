import 'package:flutter/material.dart';

/// Full-screen loading overlay with semi-transparent background.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    this.message,
    this.opaque = false,
  });

  /// Optional loading message.
  final String? message;

  /// If true, uses a solid background instead of semi-transparent.
  final bool opaque;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: opaque
          ? theme.scaffoldBackgroundColor
          : Colors.black.withOpacity(0.3),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
