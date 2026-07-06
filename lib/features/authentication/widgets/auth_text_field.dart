/// Reusable styled text field for auth forms.
///
/// Wraps [TextFormField] with Material 3 theming and consistent error handling.
/// Uses design tokens instead of hardcoded values (AGENTS.md §32–§33).
library;

import 'package:flutter/material.dart';

import '../../../app/theme/spacing.dart';
import '../../../app/theme/radius.dart';

/// A reusable [TextFormField] for authentication screens with consistent
/// Material 3 styling, leading icon, label, and validation error display.
class AuthTextField extends StatelessWidget {
  /// Creates an [AuthTextField].
  const AuthTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.onSaved,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.controller,
    this.suffix,
  });

  /// Label text displayed above the field and as the floating label.
  final String label;

  /// Leading icon shown inside the field.
  final IconData icon;

  /// Called with the validated value when the form is saved.
  final ValueChanged<String> onSaved;

  /// Optional validation function. Return an error [String] or `null`.
  final FormFieldValidator<String>? validator;

  /// Whether to obscure the text (password fields).
  final bool obscureText;

  /// Keyboard type for the field.
  final TextInputType keyboardType;

  /// Text input action for the field.
  final TextInputAction textInputAction;

  /// Autofill hints for platform autofill.
  final Iterable<String>? autofillHints;

  /// Optional external controller.
  final TextEditingController? controller;

  /// Optional suffix widget (e.g. visibility toggle).
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: theme.colorScheme.outline.withAlpha(100)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      validator: validator,
      onSaved: (value) {
        if (value != null) {
          onSaved(value);
        }
      },
    );
  }
}
