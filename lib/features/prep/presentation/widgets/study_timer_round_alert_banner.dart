import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_state.dart';

/// Gentle non-intrusive banner displayed when a Pomodoro focus or break round
/// reaches zero so the user can start the next phase, finish, or dismiss.
class StudyTimerRoundAlertBanner extends StatelessWidget {
  /// Creates a [StudyTimerRoundAlertBanner].
  const StudyTimerRoundAlertBanner({
    required this.alert,
    required this.config,
    required this.locale,
    required this.useBanglaDigits,
    required this.isBusy,
    required this.onAdvancePhase,
    required this.onFinish,
    required this.onDismiss,
    super.key,
  });

  /// Round completion event details.
  final StudyTimerRoundAlert alert;

  /// Active Pomodoro configuration to format suggested break duration.
  final PomodoroConfig config;

  /// Active UI locale.
  final Locale locale;

  /// Whether Bangla numerals are active.
  final bool useBanglaDigits;

  /// Disables actions while a repository write is running.
  final bool isBusy;

  /// Transitions to suggested next break or focus round.
  final VoidCallback onAdvancePhase;

  /// Opens the finish sheet to save the session.
  final VoidCallback onFinish;

  /// Dismisses this gentle banner cleanly.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    String fmtInt(int v) => AppFormatters.formatNumber(
          v,
          locale: locale,
          useBanglaDigits: useBanglaDigits,
        );

    final wasFocus = alert.completedPhase == PomodoroPhase.focus;
    final title = wasFocus
        ? l10n.prepTimerAlertFocusDone(fmtInt(alert.round))
        : l10n.prepTimerAlertBreakDone(fmtInt(alert.suggestedNextRound));

    final nextLabel = switch (alert.suggestedNextPhase) {
      PomodoroPhase.shortBreak =>
        l10n.prepTimerStartShortBreak(fmtInt(config.shortBreakMinutes)),
      PomodoroPhase.longBreak =>
        l10n.prepTimerStartLongBreak(fmtInt(config.longBreakMinutes)),
      PomodoroPhase.focus =>
        l10n.prepTimerStartNextRound(fmtInt(alert.suggestedNextRound)),
    };

    return GlassCard(
      key: const ValueKey('timer-round-alert-banner'),
      padding: spacing.insetsAllMd,
      borderColor: colors.success.withValues(alpha: 0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: colors.success,
                size: spacing.xl,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: tokens.textStyles.titleMedium.copyWith(
                    color: colors.success,
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('timer-alert-dismiss-btn'),
                tooltip: l10n.prepTimerDismissAlert,
                onPressed: onDismiss,
                icon: Icon(Icons.close, size: spacing.lg),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            children: [
              GlassButton(
                key: const ValueKey('timer-alert-advance-btn'),
                variant: GlassButtonVariant.primary,
                onPressed: isBusy ? null : onAdvancePhase,
                leading: Icon(
                  wasFocus ? Icons.coffee_outlined : Icons.play_arrow_rounded,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
                child: Text(nextLabel),
              ),
              GlassButton(
                key: const ValueKey('timer-alert-finish-btn'),
                onPressed: isBusy ? null : onFinish,
                child: Text(l10n.prepTimerFinishButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
