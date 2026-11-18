import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/settings/presentation/providers/settings_account_controller.dart';

/// Opens a confirmation dialog warning about permanent data removal before
/// calling self-service account deletion. Returns `true` when deleted.
Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final result = await showGlassDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const DeleteAccountDialog(),
  );
  return result ?? false;
}

/// Confirmation dialog guarding permanent self-service account deletion.
class DeleteAccountDialog extends ConsumerStatefulWidget {
  /// Creates a [DeleteAccountDialog].
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _acknowledged = false;
  bool _deleting = false;
  String? _errorText;

  Future<void> _confirmDelete() async {
    if (!_acknowledged || _deleting) return;
    setState(() {
      _deleting = true;
      _errorText = null;
    });

    final error = await ref
        .read(settingsAccountControllerProvider.notifier)
        .deleteAccount();

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _deleting = false;
      _errorText = context.l10n.settingsDeleteAccountError;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;

    return GlassDialog(
      key: const ValueKey('settings-delete-account-dialog'),
      title: Text(l10n.settingsDeleteAccountDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: spacing.insetsAllMd,
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.14),
                borderRadius: radii.cardRadius,
                border: Border.all(
                  color: colors.danger.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                l10n.settingsDeleteAccountWarning,
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: spacing.md),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                key: const ValueKey('settings-delete-account-ack'),
                borderRadius: radii.mdRadius,
                onTap: _deleting
                    ? null
                    : () => setState(() => _acknowledged = !_acknowledged),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing.xxs),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _acknowledged,
                        activeColor: colors.danger,
                        onChanged: _deleting
                            ? null
                            : (checked) => setState(
                                  () => _acknowledged = checked ?? false,
                                ),
                      ),
                      SizedBox(width: spacing.xs),
                      Expanded(
                        child: Text(
                          l10n.settingsDeleteAccountAckLabel,
                          style: tokens.textStyles.bodySmall.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_errorText != null) ...[
              SizedBox(height: spacing.sm),
              Text(
                _errorText!,
                key: const ValueKey('settings-delete-account-error'),
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.danger,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _deleting ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.prepCancelButton),
        ),
        GlassButton(
          key: const ValueKey('settings-delete-account-confirm-btn'),
          onPressed: (!_acknowledged || _deleting) ? null : _confirmDelete,
          child: Text(
            l10n.settingsDeleteAccountConfirmButton,
            style: tokens.textStyles.labelLarge.copyWith(color: colors.danger),
          ),
        ),
      ],
    );
  }
}
