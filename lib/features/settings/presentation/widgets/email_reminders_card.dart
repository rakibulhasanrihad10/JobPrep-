import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:job_prep/features/settings/presentation/providers/reminder_settings_providers.dart';

/// Settings card controlling daily circular & exam email reminder opt-in and
/// bilingual email language (`en` or `bn`).
class EmailRemindersCard extends ConsumerStatefulWidget {
  /// Creates an [EmailRemindersCard].
  const EmailRemindersCard({super.key});

  @override
  ConsumerState<EmailRemindersCard> createState() => _EmailRemindersCardState();
}

class _EmailRemindersCardState extends ConsumerState<EmailRemindersCard> {
  bool _hasSaveError = false;

  Future<void> _setEnabled(bool enabled) async {
    setState(() => _hasSaveError = false);
    final ok = await ref
        .read(reminderSettingsProvider.notifier)
        .setEnabled(enabled: enabled);
    if (!ok && mounted) {
      setState(() => _hasSaveError = true);
    }
  }

  Future<void> _setLanguage(ReminderEmailLanguage language) async {
    setState(() => _hasSaveError = false);
    final ok = await ref
        .read(reminderSettingsProvider.notifier)
        .setEmailLanguage(language);
    if (!ok && mounted) {
      setState(() => _hasSaveError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(reminderSettingsProvider);
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    return Container(
      key: const ValueKey('settings-email-reminders-card'),
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
                Icons.notifications_active_outlined,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.settingsRemindersTitle,
                  style: textStyles.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.settingsRemindersSubtitle,
            style: textStyles.bodySmall,
          ),
          SizedBox(height: spacing.md),
          settingsAsync.when(
            loading: () => Padding(
              padding: spacing.insetsVerticalMd,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.settingsRemindersLoadError,
                    style: textStyles.bodySmall.copyWith(color: colors.danger),
                  ),
                ),
                SizedBox(width: spacing.md),
                GlassButton(
                  onPressed: () => unawaited(
                    ref.read(reminderSettingsProvider.notifier).refresh(),
                  ),
                  child: Text(l10n.calendarRetry),
                ),
              ],
            ),
            data: (settings) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  key: const ValueKey('settings-reminders-toggle-row'),
                  borderRadius: radii.mdRadius,
                  onTap: () => unawaited(_setEnabled(!settings.enabled)),
                  child: Padding(
                    padding:
                        spacing.insetsVerticalSm + spacing.insetsHorizontalSm,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.settingsRemindersToggleLabel,
                                style: textStyles.bodyMedium.copyWith(
                                  color: colors.textPrimary,
                                ),
                              ),
                              SizedBox(height: spacing.xxs),
                              Text(
                                settings.enabled
                                    ? l10n.settingsRemindersToggleHintEnabled
                                    : l10n.settingsRemindersToggleHintDisabled,
                                style: textStyles.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: spacing.md),
                        Switch(
                          key: const ValueKey('settings-reminders-switch'),
                          value: settings.enabled,
                          activeThumbColor: colors.goldAccent,
                          onChanged: (value) => unawaited(_setEnabled(value)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing.md),
                Text(
                  l10n.settingsRemindersLanguageTitle,
                  style: textStyles.labelLarge,
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  l10n.settingsRemindersLanguageSubtitle,
                  style: textStyles.bodySmall,
                ),
                SizedBox(height: spacing.sm),
                RadioGroup<ReminderEmailLanguage>(
                  groupValue: settings.emailLanguage,
                  onChanged: (lang) {
                    if (lang != null) {
                      unawaited(_setLanguage(lang));
                    }
                  },
                  child: Column(
                    children: [
                      _EmailLanguageOptionTile(
                        key: const ValueKey('settings-reminders-lang-en'),
                        label: l10n.languageEnglish,
                        value: ReminderEmailLanguage.english,
                        onTap: () => unawaited(
                          _setLanguage(ReminderEmailLanguage.english),
                        ),
                      ),
                      _EmailLanguageOptionTile(
                        key: const ValueKey('settings-reminders-lang-bn'),
                        label: l10n.languageBangla,
                        value: ReminderEmailLanguage.bangla,
                        onTap: () => unawaited(
                          _setLanguage(ReminderEmailLanguage.bangla),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_hasSaveError) ...[
                  SizedBox(height: spacing.sm),
                  Text(
                    l10n.settingsRemindersSaveError,
                    key: const ValueKey('settings-reminders-save-error'),
                    style: textStyles.bodySmall.copyWith(color: colors.danger),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailLanguageOptionTile extends StatelessWidget {
  const _EmailLanguageOptionTile({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String label;
  final ReminderEmailLanguage value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final textStyles = context.textStyles;

    return InkWell(
      onTap: onTap,
      borderRadius: context.radii.mdRadius,
      child: Padding(
        padding: spacing.insetsVerticalSm + spacing.insetsHorizontalSm,
        child: Row(
          children: [
            Radio<ReminderEmailLanguage>(
              value: value,
              activeColor: colors.goldAccent,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                label,
                style: textStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
