import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/security/vault_clipboard_service.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/circulars/domain/validators/circular_form_validators.dart';
import 'package:job_prep/features/circulars/presentation/providers/url_launcher_provider.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';

/// Single portal login row shown only while the vault is unlocked.
class PortalAccountTile extends ConsumerStatefulWidget {
  /// Creates a [PortalAccountTile].
  const PortalAccountTile({
    required this.entry,
    required this.onEdit,
    super.key,
  });

  /// In-memory decrypted portal credential entry.
  final DecryptedPortalAccount entry;

  /// Callback invoked to open the edit dialog for [entry].
  final VoidCallback onEdit;

  @override
  ConsumerState<PortalAccountTile> createState() => _PortalAccountTileState();
}

class _PortalAccountTileState extends ConsumerState<PortalAccountTile> {
  static const String _maskedPassword = '••••••••';

  bool _revealPassword = false;

  Future<void> _copyValue(String value) async {
    final l10n = context.l10n;
    final locale = ref.read(localeProvider);
    final useBanglaDigits = ref.read(useBanglaDigitsProvider);
    final clearSeconds =
        ref.read(vaultClipboardClearDurationProvider).inSeconds;
    final messenger = ScaffoldMessenger.maybeOf(context);

    await ref
        .read(portalVaultControllerProvider.notifier)
        .copySensitiveField(value);

    if (!mounted) return;
    final formattedSeconds = AppFormatters.formatNumber(
      clearSeconds,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    messenger
      ?..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.portalCopiedClipboardNotice(formattedSeconds)),
        ),
      );
  }

  Future<void> _openPortalUrl(String rawUrl) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final uri = Uri.tryParse(rawUrl.trim());
    if (uri == null ||
        CircularFormValidators.validateOptionalUrl(rawUrl) != null) {
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.circularDetailLaunchFailed)),
      );
      return;
    }

    try {
      final ok = await ref.read(circularUrlLauncherProvider)(uri);
      if (!ok && mounted) {
        messenger?.showSnackBar(
          SnackBar(content: Text(l10n.circularDetailLaunchFailed)),
        );
      }
    } on Object {
      if (mounted) {
        messenger?.showSnackBar(
          SnackBar(content: Text(l10n.circularDetailLaunchFailed)),
        );
      }
    }
  }

  Future<void> _confirmAndDelete() async {
    final l10n = context.l10n;
    final account = widget.entry.account;
    final messenger = ScaffoldMessenger.maybeOf(context);

    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (dialogContext) => GlassDialog(
        title: Text(l10n.portalDeleteConfirmTitle),
        content: Text(l10n.portalDeleteConfirmMessage(account.username)),
        actions: [
          GlassButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.circularFormCancelButton),
          ),
          GlassButton(
            key: ValueKey('portal-confirm-delete-${account.id}'),
            variant: GlassButtonVariant.primary,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.circularDetailDeleteAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(portalVaultControllerProvider.notifier)
          .deletePortalAccount(
            id: account.id,
            circularId: account.circularId,
          );
    } on Object {
      if (mounted) {
        messenger?.showSnackBar(
          SnackBar(content: Text(l10n.portalSaveError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final account = widget.entry.account;
    final portalUrl = account.portalUrl?.trim();
    final notes = account.notes?.trim();

    return Container(
      key: ValueKey('portal-account-tile-${account.id}'),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.portalUsernameLabel, style: textStyles.bodySmall),
                    SizedBox(height: spacing.xxs),
                    Text(
                      account.username,
                      key: ValueKey('portal-account-username-${account.id}'),
                      style: textStyles.labelLarge,
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('portal-edit-${account.id}'),
                tooltip: l10n.portalEditDialogTitle,
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                key: ValueKey('portal-delete-${account.id}'),
                tooltip: l10n.circularDetailDeleteAction,
                onPressed: () => unawaited(_confirmAndDelete()),
                icon: Icon(Icons.delete_outline_rounded, color: colors.danger),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.portalPasswordLabel, style: textStyles.bodySmall),
                    SizedBox(height: spacing.xxs),
                    Text(
                      _revealPassword ? widget.entry.password : _maskedPassword,
                      key: ValueKey('portal-account-password-${account.id}'),
                      style: textStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('portal-toggle-password-${account.id}'),
                tooltip: _revealPassword
                    ? l10n.portalHidePasswordTooltip
                    : l10n.portalRevealPasswordTooltip,
                onPressed: () =>
                    setState(() => _revealPassword = !_revealPassword),
                icon: Icon(
                  _revealPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ],
          ),
          if (notes != null && notes.isNotEmpty) ...[
            SizedBox(height: spacing.sm),
            Text(notes, style: textStyles.bodySmall),
          ],
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              GlassButton(
                key: ValueKey('portal-copy-user-${account.id}'),
                onPressed: () => unawaited(_copyValue(account.username)),
                leading: Icon(Icons.person_outline_rounded, size: spacing.lg),
                child: Text(l10n.portalCopyUserIdAction),
              ),
              GlassButton(
                key: ValueKey('portal-copy-password-${account.id}'),
                variant: GlassButtonVariant.primary,
                onPressed: () => unawaited(_copyValue(widget.entry.password)),
                leading: Icon(Icons.copy_rounded, size: spacing.lg),
                child: Text(l10n.portalCopyPasswordAction),
              ),
              if (portalUrl != null && portalUrl.isNotEmpty)
                GlassButton(
                  key: ValueKey('portal-open-url-${account.id}'),
                  onPressed: () => unawaited(_openPortalUrl(portalUrl)),
                  leading: Icon(Icons.open_in_new_rounded, size: spacing.lg),
                  child: Text(l10n.portalOpenUrlAction),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
