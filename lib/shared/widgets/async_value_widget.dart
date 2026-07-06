import 'package:flutter/material.dart';

/// Renders one of the four possible [AsyncValue] states:
/// [AsyncLoading], [AsyncData], [AsyncError], or [AsyncNothing].
///
/// Follows AGENTS.md §26 — every async request exposes Loading, Success, Error.
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
  });

  /// The async value to render.
  final AsyncValue<T> value;

  /// Widget builder for the data (success) state.
  final Widget Function(T data) data;

  /// Optional custom loading widget.
  final Widget? loading;

  /// Optional custom error widget builder.
  final Widget Function(Object error, StackTrace? stack)? error;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading ?? const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        if (error != null) return error!(err, stack);
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  err.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
