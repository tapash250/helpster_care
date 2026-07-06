import 'package:flutter/material.dart';
import 'package:helpster_care/app/theme/spacing.dart';
import 'package:helpster_care/app/theme/radius.dart';

/// A reusable confirmation dialog.
///
/// Use this instead of raw [AlertDialog] to ensure consistent styling
/// (AGENTS.md §32 — no hardcoded values).
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// A confirm/cancel dialog for destructive actions.
Future<bool?> showDeleteConfirmDialog(
  BuildContext context, {
  String itemName = 'this item',
}) {
  return showConfirmDialog(
    context,
    title: 'Delete $itemName?',
    message: 'This action cannot be undone. Are you sure you want to delete $itemName?',
    confirmLabel: 'Delete',
    isDestructive: true,
  );
}
