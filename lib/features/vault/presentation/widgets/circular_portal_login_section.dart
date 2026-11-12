import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/security/vault_providers.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';
import 'package:job_prep/features/vault/presentation/widgets/portal_account_form_dialog.dart';
import 'package:job_prep/features/vault/presentation/widgets/portal_account_tile.dart';
import 'package:job_prep/features/vault/presentation/widgets/vault_unlock_dialog.dart';

/// Portal Login section inside CircularDetailView.
///
/// The portal login credentials section stays hidden while the vault is locked
/// and only renders decrypted accounts and management actions after unlock.
class CircularPortalLoginSection extends ConsumerWidget {
  /// Creates a [CircularPortalLoginSection].
  const CircularPortalLoginSection({
    required this.circular,
    super.key,
  });

  /// Active circular owning the displayed portal accounts.
  final Circular circular;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final isUnlocked = ref.watch(
      vaultSessionProvider.select((session) => session.isUnlocked),
    );
    final hasVerifier = ref.watch(vaultVerifierProvider).asData?.value != null;

    if (!isUnlocked) {
      return GlassCard(
        key: const ValueKey('circular-portal-vault-gate'),
        padding: spacing.insetsAllLg,
        child: FadeSlideIn(
          index: 7,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = tokens.breakpoints.isCompact(
                constraints.maxWidth,
              );
              final infoRow = Row(
                crossAxisAlignment: isCompact
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: colors.goldAccent,
                    size: spacing.lg,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.vaultTitle, style: textStyles.titleMedium),
                        SizedBox(height: spacing.xxs),
                        Text(
                          l10n.vaultPortalLockedHint,
                          style: textStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final unlockButton = GlassButton(
                key: const ValueKey('circular-portal-unlock-button'),
                onPressed: () => unawaited(showVaultUnlockDialog(context)),
                leading: Icon(Icons.lock_open_rounded, size: spacing.lg),
                child: Text(
                  hasVerifier ? l10n.vaultUnlockButton : l10n.vaultSetupButton,
                ),
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    infoRow,
                    SizedBox(height: spacing.md),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: unlockButton,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: infoRow),
                  SizedBox(width: spacing.md),
                  unlockButton,
                ],
              );
            },
          ),
        ),
      );
    }

    final accountsAsync =
        ref.watch(circularPortalAccountsProvider(circular.id));

    return GlassCard(
      key: const ValueKey('circular-portal-login-section'),
      padding: spacing.insetsAllLg,
      child: FadeSlideIn(
        index: 7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = tokens.breakpoints.isCompact(
                  constraints.maxWidth,
                );
                final titleGroup = Row(
                  children: [
                    Icon(
                      Icons.vpn_key_outlined,
                      color: colors.goldAccent,
                      size: spacing.lg,
                    ),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: Text(
                        l10n.portalSectionTitle,
                        style: textStyles.titleMedium,
                      ),
                    ),
                  ],
                );

                final lockButton = IconButton(
                  key: const ValueKey('portal-vault-lock-button'),
                  tooltip: l10n.vaultLockButton,
                  onPressed: () => ref
                      .read(portalVaultControllerProvider.notifier)
                      .lockVault(),
                  icon: const Icon(Icons.lock_outline_rounded),
                );

                final addButton = GlassButton(
                  key: const ValueKey('portal-add-button'),
                  variant: GlassButtonVariant.primary,
                  onPressed: () => unawaited(
                    showPortalAccountFormDialog(
                      context,
                      circularId: circular.id,
                      suggestedPortalUrl: circular.applicationUrl,
                    ),
                  ),
                  leading: Icon(Icons.add_rounded, size: spacing.lg),
                  child: Text(l10n.portalAddAccountButton),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: titleGroup),
                          lockButton,
                        ],
                      ),
                      SizedBox(height: spacing.sm),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: addButton,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: titleGroup),
                    lockButton,
                    SizedBox(width: spacing.xs),
                    addButton,
                  ],
                );
              },
            ),
            Divider(color: colors.glassBorder, height: spacing.xl),
            accountsAsync.when(
              loading: () => Padding(
                padding: spacing.insetsVerticalMd,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.portalLoadError,
                      style: textStyles.bodySmall.copyWith(
                        color: colors.danger,
                      ),
                    ),
                  ),
                  SizedBox(width: spacing.md),
                  GlassButton(
                    onPressed: () => ref.invalidate(
                      circularPortalAccountsProvider(circular.id),
                    ),
                    child: Text(l10n.circularsRetryButton),
                  ),
                ],
              ),
              data: (accounts) {
                if (accounts.isEmpty) {
                  return Text(
                    l10n.portalEmptyState,
                    key: const ValueKey('portal-empty-state'),
                    style: textStyles.bodyMedium,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < accounts.length; i++) ...[
                      if (i > 0) SizedBox(height: spacing.md),
                      PortalAccountTile(
                        entry: accounts[i],
                        onEdit: () => unawaited(
                          showPortalAccountFormDialog(
                            context,
                            circularId: circular.id,
                            existing: accounts[i],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
