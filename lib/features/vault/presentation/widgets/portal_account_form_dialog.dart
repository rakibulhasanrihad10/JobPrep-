import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/circulars/domain/validators/circular_form_validators.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';

/// Opens the add/edit dialog for a circular's encrypted portal account.
Future<PortalAccount?> showPortalAccountFormDialog(
  BuildContext context, {
  required String circularId,
  DecryptedPortalAccount? existing,
  String? suggestedPortalUrl,
}) {
  return showGlassDialog<PortalAccount>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PortalAccountFormDialog(
      circularId: circularId,
      existing: existing,
      suggestedPortalUrl: suggestedPortalUrl,
    ),
  );
}

/// Dialog capturing portal URL, user ID, password (encrypted client-side on
/// save via VaultService), and optional notes.
class PortalAccountFormDialog extends ConsumerStatefulWidget {
  /// Creates a [PortalAccountFormDialog].
  const PortalAccountFormDialog({
    required this.circularId,
    super.key,
    this.existing,
    this.suggestedPortalUrl,
  });

  /// Owning circular identifier.
  final String circularId;

  /// Existing decrypted account when editing, or `null` when creating new.
  final DecryptedPortalAccount? existing;

  /// Optional URL prefilled from circular's application link.
  final String? suggestedPortalUrl;

  @override
  ConsumerState<PortalAccountFormDialog> createState() =>
      _PortalAccountFormDialogState();
}

class _PortalAccountFormDialogState
    extends ConsumerState<PortalAccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _notesController;

  bool _obscurePassword = true;
  bool _isSaving = false;
  String? _saveError;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _urlController = TextEditingController(
      text: existing?.account.portalUrl ?? widget.suggestedPortalUrl ?? '',
    );
    _usernameController = TextEditingController(
      text: existing?.account.username ?? '',
    );
    _passwordController = TextEditingController(
      text: existing?.password ?? '',
    );
    _notesController = TextEditingController(
      text: existing?.account.notes ?? '',
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController
      ..clear()
      ..dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      final saved = await ref
          .read(portalVaultControllerProvider.notifier)
          .savePortalAccount(
            PortalAccountDraft(
              id: widget.existing?.account.id,
              circularId: widget.circularId,
              portalUrl: _urlController.text,
              username: _usernameController.text,
              password: _passwordController.text,
              notes: _notesController.text,
            ),
            existing: widget.existing?.account,
          );
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } on Object {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = l10n.portalSaveError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final isEdit = widget.existing != null;

    return GlassDialog(
      key: const ValueKey('portal-account-form-dialog'),
      title: Text(
        isEdit ? l10n.portalEditDialogTitle : l10n.portalAddDialogTitle,
        style: textStyles.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GlassTextField(
                key: const ValueKey('portal-form-url'),
                controller: _urlController,
                labelText: l10n.portalUrlLabel,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                enabled: !_isSaving,
                validator: (value) {
                  if (CircularFormValidators.validateOptionalUrl(value) !=
                      null) {
                    return l10n.circularValidationInvalidUrl;
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),
              GlassTextField(
                key: const ValueKey('portal-form-username'),
                controller: _usernameController,
                labelText: l10n.portalUsernameLabel,
                autofocus: !isEdit,
                textInputAction: TextInputAction.next,
                enabled: !_isSaving,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.portalUsernameRequiredError;
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),
              GlassTextField(
                key: const ValueKey('portal-form-password'),
                controller: _passwordController,
                labelText: l10n.portalPasswordLabel,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                enabled: !_isSaving,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword
                      ? l10n.portalRevealPasswordTooltip
                      : l10n.portalHidePasswordTooltip,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.portalPasswordRequiredError;
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),
              GlassTextField(
                key: const ValueKey('portal-form-notes'),
                controller: _notesController,
                labelText: l10n.portalNotesLabel,
                maxLines: 3,
                enabled: !_isSaving,
              ),
              if (_saveError != null) ...[
                SizedBox(height: spacing.sm),
                Text(
                  _saveError!,
                  style: textStyles.bodySmall.copyWith(color: colors.danger),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        GlassButton(
          key: const ValueKey('portal-form-cancel'),
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.circularFormCancelButton),
        ),
        GlassButton(
          key: const ValueKey('portal-form-save'),
          variant: GlassButtonVariant.primary,
          onPressed: _isSaving ? null : () => unawaited(_submit()),
          child: _isSaving
              ? SizedBox(
                  width: spacing.lg,
                  height: spacing.lg,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.prepSaveButton),
        ),
      ],
    );
  }
}
