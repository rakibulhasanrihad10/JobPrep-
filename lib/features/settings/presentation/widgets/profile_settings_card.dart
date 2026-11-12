import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_text_field.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/settings/presentation/providers/settings_account_controller.dart';
import 'package:job_prep/features/settings/presentation/providers/user_settings_providers.dart';
import 'package:job_prep/features/settings/presentation/widgets/change_password_dialog.dart';

/// Profile section card managing display name, account email display, password
/// change dialog, and vault-safe sign out.
class ProfileSettingsCard extends ConsumerStatefulWidget {
  /// Creates a [ProfileSettingsCard].
  const ProfileSettingsCard({super.key});

  @override
  ConsumerState<ProfileSettingsCard> createState() =>
      _ProfileSettingsCardState();
}

class _ProfileSettingsCardState extends ConsumerState<ProfileSettingsCard> {
  final TextEditingController _nameController = TextEditingController();
  String? _seededName;
  bool _savingName = false;
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    setState(() {
      _savingName = true;
      _statusMessage = null;
    });
    final ok = await ref
        .read(userSettingsProvider.notifier)
        .saveDisplayName(_nameController.text);
    if (!mounted) return;
    final l10n = context.l10n;
    setState(() {
      _savingName = false;
      _statusIsError = !ok;
      _statusMessage = ok
          ? l10n.settingsDisplayNameSaved
          : l10n.settingsDisplayNameSaveError;
    });
  }

  Future<void> _openChangePassword() async {
    final updated = await showChangePasswordDialog(context);
    if (!mounted || !updated) return;
    setState(() {
      _statusIsError = false;
      _statusMessage = context.l10n.settingsPasswordSaved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final user = ref.watch(currentUserProvider);
    final syncedName = ref.watch(
      userSettingsProvider.select((async) => async.asData?.value.displayName),
    );
    final resolvedName = syncedName ?? user?.displayName ?? '';
    if (_seededName == null && resolvedName.isNotEmpty) {
      _seededName = resolvedName;
      _nameController.text = resolvedName;
    }

    final email = (user?.email?.trim().isNotEmpty ?? false)
        ? user!.email!
        : l10n.settingsEmailUnavailable;
    final isBusy = ref.watch(settingsAccountControllerProvider);

    return GlassCard(
      key: const ValueKey('settings-profile-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.settingsProfileTitle,
                  style: tokens.textStyles.titleMedium,
                ),
              ),
              Flexible(
                child: Text(
                  email,
                  key: const ValueKey('settings-profile-email'),
                  overflow: TextOverflow.ellipsis,
                  style: tokens.textStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: GlassTextField(
                  key: const ValueKey('settings-display-name-input'),
                  controller: _nameController,
                  enabled: !_savingName && !isBusy,
                  labelText: l10n.settingsDisplayNameLabel,
                  onSubmitted: (_) => unawaited(_saveName()),
                ),
              ),
              SizedBox(width: spacing.sm),
              GlassButton(
                key: const ValueKey('settings-save-display-name-btn'),
                variant: GlassButtonVariant.primary,
                onPressed: _savingName || isBusy ? null : _saveName,
                child: Text(l10n.settingsDisplayNameSaveButton),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              GlassButton(
                key: const ValueKey('settings-change-password-btn'),
                onPressed: isBusy ? null : _openChangePassword,
                leading: Icon(Icons.password_rounded, size: spacing.lg),
                child: Text(l10n.settingsChangePasswordButton),
              ),
              GlassButton(
                key: const ValueKey('settings-sign-out-btn'),
                onPressed: isBusy
                    ? null
                    : () => unawaited(
                          ref
                              .read(settingsAccountControllerProvider.notifier)
                              .signOut(),
                        ),
                leading: Icon(Icons.logout_rounded, size: spacing.lg),
                child: Text(l10n.settingsSignOutButton),
              ),
            ],
          ),
          if (_statusMessage != null) ...[
            SizedBox(height: spacing.sm),
            Text(
              _statusMessage!,
              key: const ValueKey('settings-profile-status'),
              style: tokens.textStyles.bodySmall.copyWith(
                color: _statusIsError ? colors.danger : colors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
