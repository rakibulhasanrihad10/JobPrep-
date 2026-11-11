import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/core/theme/app_radii.dart';
import 'package:job_prep/core/theme/app_spacing.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/notifications/presentation/utils/notification_message_formatter.dart';
import 'package:job_prep/features/settings/domain/entities/reminder_settings.dart';
import 'package:job_prep/features/settings/presentation/providers/reminder_settings_providers.dart';

/// Settings card managing per-type in-app notification generation toggles
/// and preferred weekday for Weekly Review digests.
class InAppNotificationsCard extends ConsumerStatefulWidget {
  /// Creates an [InAppNotificationsCard].
  const InAppNotificationsCard({super.key});

  @override
  ConsumerState<InAppNotificationsCard> createState() =>
      _InAppNotificationsCardState();
}

class _InAppNotificationsCardState
    extends ConsumerState<InAppNotificationsCard> {
  bool _showSaveError = false;

  Future<void> _updatePreferences({
    bool? deadlineSoonEnabled,
    bool? examSoonEnabled,
    bool? revisionDueEnabled,
    bool? behindScheduleEnabled,
    bool? weeklyReviewEnabled,
    int? weeklyReviewDay,
  }) async {
    setState(() => _showSaveError = false);
    final saved = await ref
        .read(reminderSettingsProvider.notifier)
        .setNotificationPreferences(
          deadlineSoonEnabled: deadlineSoonEnabled,
          examSoonEnabled: examSoonEnabled,
          revisionDueEnabled: revisionDueEnabled,
          behindScheduleEnabled: behindScheduleEnabled,
          weeklyReviewEnabled: weeklyReviewEnabled,
          weeklyReviewDay: weeklyReviewDay,
        );
    if (!mounted) return;
    if (!saved) {
      setState(() => _showSaveError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final settingsAsync = ref.watch(reminderSettingsProvider);
    final settings = settingsAsync.asData?.value ?? const ReminderSettings();
    final isLoading = settingsAsync.isLoading && !settingsAsync.hasValue;

    return GlassCard(
      key: const ValueKey('settings-in-app-notifications-card'),
      padding: spacing.insetsAllXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: colors.goldAccent,
                size: spacing.xl,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  l10n.settingsInAppNotificationsTitle,
                  style: tokens.textStyles.titleLarge,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.settingsInAppNotificationsSubtitle,
            style: tokens.textStyles.bodyMedium,
          ),
          if (_showSaveError) ...[
            SizedBox(height: spacing.sm),
            Text(
              l10n.settingsRemindersSaveError,
              key: const ValueKey('settings-notif-save-error'),
              style: tokens.textStyles.bodySmall.copyWith(color: colors.danger),
            ),
          ],
          SizedBox(height: spacing.md),
          _PreferenceToggleRow(
            switchKey: const ValueKey('settings-notif-switch-deadline'),
            title: l10n.settingsNotifDeadlineSoonTitle,
            value: settings.deadlineSoonEnabled,
            enabled: !isLoading,
            onChanged: (next) =>
                unawaited(_updatePreferences(deadlineSoonEnabled: next)),
          ),
          _PreferenceToggleRow(
            switchKey: const ValueKey('settings-notif-switch-exam'),
            title: l10n.settingsNotifExamSoonTitle,
            value: settings.examSoonEnabled,
            enabled: !isLoading,
            onChanged: (next) =>
                unawaited(_updatePreferences(examSoonEnabled: next)),
          ),
          _PreferenceToggleRow(
            switchKey: const ValueKey('settings-notif-switch-revision'),
            title: l10n.settingsNotifRevisionDueTitle,
            value: settings.revisionDueEnabled,
            enabled: !isLoading,
            onChanged: (next) =>
                unawaited(_updatePreferences(revisionDueEnabled: next)),
          ),
          _PreferenceToggleRow(
            switchKey: const ValueKey('settings-notif-switch-behind'),
            title: l10n.settingsNotifBehindScheduleTitle,
            value: settings.behindScheduleEnabled,
            enabled: !isLoading,
            onChanged: (next) =>
                unawaited(_updatePreferences(behindScheduleEnabled: next)),
          ),
          _PreferenceToggleRow(
            switchKey: const ValueKey('settings-notif-switch-weekly'),
            title: l10n.settingsNotifWeeklyReviewTitle,
            value: settings.weeklyReviewEnabled,
            enabled: !isLoading,
            onChanged: (next) =>
                unawaited(_updatePreferences(weeklyReviewEnabled: next)),
          ),
          SizedBox(height: spacing.md),
          Text(
            l10n.settingsNotifWeeklyReviewDayLabel,
            style: tokens.textStyles.labelLarge,
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: [
              for (var day = 0; day < 7; day++)
                _WeekdayButton(
                  key: ValueKey('settings-notif-review-day-$day'),
                  label: NotificationMessageFormatter.formatWeekdayName(
                    day,
                    locale: locale,
                    abbreviated: true,
                  ),
                  selected: settings.weeklyReviewDay == day,
                  enabled: !isLoading && settings.weeklyReviewEnabled,
                  colors: colors,
                  spacing: spacing,
                  radii: radii,
                  onTap: () =>
                      unawaited(_updatePreferences(weeklyReviewDay: day)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreferenceToggleRow extends StatelessWidget {
  const _PreferenceToggleRow({
    required this.switchKey,
    required this.title,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final ValueKey<String> switchKey;
  final String title;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: tokens.textStyles.bodyMedium.copyWith(
                color: tokens.colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: tokens.spacing.sm),
          Switch(
            key: switchKey,
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}

class _WeekdayButton extends StatelessWidget {
  const _WeekdayButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.colors,
    required this.spacing,
    required this.radii,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final AppColorsToken colors;
  final AppSpacingToken spacing;
  final AppRadiiToken radii;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: selected ? colors.goldAccentSubtle : colors.surfaceElevated,
      borderRadius: radii.buttonRadius,
      child: InkWell(
        borderRadius: radii.buttonRadius,
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: radii.buttonRadius,
            border: Border.all(
              color: selected ? colors.goldAccent : colors.glassBorder,
            ),
          ),
          child: Text(
            label,
            style: tokens.textStyles.labelMedium.copyWith(
              color: !enabled
                  ? colors.textMuted
                  : (selected ? colors.goldAccent : colors.textPrimary),
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
