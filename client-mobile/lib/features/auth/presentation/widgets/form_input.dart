/// Form Input Widget
///
/// Modern text input with icon support and validation.
/// Matches the desktop client design system.
library;

import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

/// Modern form input field with icon and label
class FormInput extends StatefulWidget {
  /// Creates a form input field
  const FormInput({
    required this.label,
    required this.controller,
    this.hintText,
    this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction,
    this.onFieldSubmitted,
    super.key,
  });

  /// Label text above the input
  final String label;

  /// Text editing controller
  final TextEditingController controller;

  /// Placeholder text
  final String? hintText;

  /// Leading icon
  final IconData? icon;

  /// Whether this is a password field
  final bool isPassword;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Validation function
  final String? Function(String?)? validator;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether to autofocus this field
  final bool autofocus;

  /// Text input action (next, done, etc.)
  final TextInputAction? textInputAction;

  /// Callback when field is submitted
  final void Function(String)? onFieldSubmitted;

  @override
  State<FormInput> createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with required indicator
        Row(
          children: [
            Text(
              widget.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? GrayColors.gray300 : GrayColors.gray700,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: SemanticColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Input field
        Focus(
          onFocusChange: (focused) {
            setState(() => _isFocused = focused);
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            validator: widget.validator,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white : GrayColors.gray900,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: isDark ? GrayColors.gray500 : GrayColors.gray400,
              ),
              prefixIcon: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: _isFocused
                          ? GuardynColors.guardyn500
                          : (isDark ? GrayColors.gray500 : GrayColors.gray400),
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: isDark ? GrayColors.gray500 : GrayColors.gray400,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark
                  ? GrayColors.gray800.withValues(alpha: 0.5)
                  : GrayColors.gray50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? GrayColors.gray700 : GrayColors.gray200,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? GrayColors.gray700 : GrayColors.gray200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: GuardynColors.guardyn500,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: SemanticColors.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: SemanticColors.error,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? GrayColors.gray800 : GrayColors.gray100,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Primary submit button with loading state
class SubmitButton extends StatelessWidget {
  /// Creates a submit button
  const SubmitButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  /// Button text
  final String text;

  /// Callback when pressed
  final VoidCallback? onPressed;

  /// Whether the button is in loading state
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: GuardynColors.guardyn500,
          foregroundColor: Colors.white,
          disabledBackgroundColor: GuardynColors.guardyn500.withValues(
            alpha: 0.6,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Error alert banner
class ErrorAlert extends StatelessWidget {
  /// Creates an error alert
  const ErrorAlert({
    required this.message,
    this.onDismiss,
    super.key,
  });

  /// Error message to display
  final String message;

  /// Callback when dismissed
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SemanticColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SemanticColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: SemanticColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: SemanticColors.errorDark,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 18,
                color: SemanticColors.error,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
