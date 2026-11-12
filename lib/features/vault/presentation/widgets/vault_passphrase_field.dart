import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';

/// Masked passphrase input with localized visibility toggle tooltip.
class VaultPassphraseField extends StatelessWidget {
  /// Creates a [VaultPassphraseField].
  const VaultPassphraseField({
    required this.fieldKey,
    required this.controller,
    required this.labelText,
    required this.obscureText,
    required this.enabled,
    required this.onToggleObscure,
    required this.textInputAction,
    required this.validator,
    this.autofocus = false,
    this.onSubmitted,
    super.key,
  });

  /// Key applied to the inner [GlassTextField] for focus and testing.
  final Key fieldKey;

  /// Controller storing the passphrase characters.
  final TextEditingController controller;

  /// Localized field label.
  final String labelText;

  /// Whether input text is masked.
  final bool obscureText;

  /// Whether user input is currently enabled.
  final bool enabled;

  /// Callback toggling masking state.
  final VoidCallback onToggleObscure;

  /// Soft-keyboard action button type.
  final TextInputAction textInputAction;

  /// Field validation function.
  final FormFieldValidator<String> validator;

  /// Whether this field should focus immediately on mount.
  final bool autofocus;

  /// Optional submit callback for `TextInputAction.done`.
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GlassTextField(
      key: fieldKey,
      controller: controller,
      labelText: labelText,
      obscureText: obscureText,
      autofocus: autofocus,
      enabled: enabled,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      suffixIcon: IconButton(
        tooltip: obscureText
            ? l10n.portalRevealPasswordTooltip
            : l10n.portalHidePasswordTooltip,
        onPressed: onToggleObscure,
        icon: Icon(
          obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
      validator: validator,
    );
  }
}
