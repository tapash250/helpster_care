import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';

/// A banner that shows an error message with a dismiss or retry action.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                icon: Icon(Icons.close, color: theme.colorScheme.onErrorContainer),
                onPressed: onDismiss,
                visualDensity: VisualDensity.compact,
              ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text('Retry',
                    style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              ),
          ],
        ),
      ),
    );
  }
}
