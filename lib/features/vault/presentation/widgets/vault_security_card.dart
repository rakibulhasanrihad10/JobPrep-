import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/security/vault_providers.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';
import 'package:job_prep/features/vault/presentation/widgets/vault_change_passphrase_dialog.dart';
import 'package:job_prep/features/vault/presentation/widgets/vault_setup_warning_banner.dart';
import 'package:job_prep/features/vault/presentation/widgets/vault_unlock_dialog.dart';

/// Settings card exposing Portal Vault passphrase setup, unlock, change
/// passphrase, and lock controls alongside unrecoverable warnings.
class VaultSecurityCard extends ConsumerStatefulWidget {
  /// Creates a [VaultSecurityCard].
  const VaultSecurityCard({super.key});

  @override
  ConsumerState<VaultSecurityCard> createState() => _VaultSecurityCardState();
}

class _VaultSecurityCardState extends ConsumerState<VaultSecurityCard> {
  bool _passphraseUpdated = false;

  Future<void> _openChangePassphrase() async {
    final changed = await showVaultChangePassphraseDialog(context);
    if (!mounted || !changed) return;
    setState(() => _passphraseUpdated = true);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final isUnlocked = ref.watch(
      vaultSessionProvider.select((session) => session.isUnlocked),
    );
    final verifierAsync = ref.watch(vaultVerifierProvider);
    final hasVerifier = verifierAsync.asData?.value != null;
    final statusColor = isUnlocked ? colors.success : colors.warning;

    return Container(
      key: const ValueKey('settings-vault-security-card'),
      padding: spacing.insetsAllLg,
      decoration: BoxDecoration(
        color: colors.glassFill,
        borderRadius: radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUnlocked
                    ? Icons.lock_open_rounded
                    : Icons.enhanced_encryption_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.vaultTitle,
                  style: textStyles.titleMedium,
                ),
              ),
              Container(
                key: const ValueKey('settings-vault-status-badge'),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.sm,
                  vertical: spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: radii.smRadius,
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  isUnlocked
                      ? l10n.vaultStatusUnlocked
                      : l10n.vaultStatusLocked,
                  style: textStyles.labelSmall.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(l10n.vaultSubtitle, style: textStyles.bodySmall),
          SizedBox(height: spacing.xxs),
          Text(l10n.vaultAutoLockNote, style: textStyles.bodySmall),
          SizedBox(height: spacing.md),
          const VaultSetupWarningBanner(),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              if (isUnlocked)
                GlassButton(
                  key: const ValueKey('settings-vault-lock-button'),
                  onPressed: () => ref
                      .read(portalVaultControllerProvider.notifier)
                      .lockVault(),
                  leading: Icon(Icons.lock_outline_rounded, size: spacing.lg),
                  child: Text(l10n.vaultLockButton),
                )
              else
                GlassButton(
                  key: const ValueKey('settings-vault-unlock-button'),
                  variant: GlassButtonVariant.primary,
                  onPressed: () => unawaited(showVaultUnlockDialog(context)),
                  leading: Icon(Icons.lock_open_rounded, size: spacing.lg),
                  child: Text(
                    hasVerifier
                        ? l10n.vaultUnlockButton
                        : l10n.vaultSetupButton,
                  ),
                ),
              if (hasVerifier)
                GlassButton(
                  key:
                      const ValueKey('settings-vault-change-passphrase-button'),
                  onPressed: _openChangePassphrase,
                  leading: Icon(Icons.key_rounded, size: spacing.lg),
                  child: Text(l10n.vaultChangePassphraseButton),
                ),
            ],
          ),
          if (_passphraseUpdated) ...[
            SizedBox(height: spacing.sm),
            Text(
              l10n.vaultChangePassphraseSuccess,
              key: const ValueKey('settings-vault-changed-status'),
              style: textStyles.bodySmall.copyWith(color: colors.success),
            ),
          ],
        ],
      ),
    );
  }
}
