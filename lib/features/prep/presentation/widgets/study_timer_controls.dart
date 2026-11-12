import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_ring.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/study_timer_calculator.dart';
import 'package:job_prep/features/prep/presentation/utils/study_timer_l10n.dart';

/// Circular progress ring showing phase label, clock text, and timer status.
class StudyTimerClockRing extends StatelessWidget {
  /// Creates a [StudyTimerClockRing].
  const StudyTimerClockRing({
    required this.activeSession,
    required this.evaluation,
    required this.selectedMode,
    required this.replayKey,
    required this.displaySeconds,
    required this.phaseLabel,
    required this.statusLabel,
    required this.isPaused,
    required this.locale,
    required this.useBanglaDigits,
    super.key,
  });

  /// Active session if running or paused.
  final StudySession? activeSession;

  /// Latest timestamp evaluation of the active session.
  final StudyTimerEvaluation? evaluation;

  /// Currently selected or active session mode.
  final StudySessionMode selectedMode;

  /// Key replaying progress ring animation when opening the tab.
  final Object replayKey;

  /// Seconds to show inside the clock readout.
  final int displaySeconds;

  /// Localized label for Focus round, break, or Stopwatch.
  final String phaseLabel;

  /// Localized status text (Ready / Running / Paused).
  final String statusLabel;

  /// Whether the active session is currently paused.
  final bool isPaused;

  /// Current active locale.
  final Locale locale;

  /// Whether to render Bangla numerals.
  final bool useBanglaDigits;

  double _resolveRingProgress() {
    final session = activeSession;
    final eval = evaluation;
    if (session == null || eval == null) return 0;
    if (selectedMode == StudySessionMode.focus) {
      if (eval.targetSeconds <= 0) return 0;
      return (1.0 - (eval.phaseRemainingSeconds / eval.targetSeconds))
          .clamp(0.0, 1.0);
    }
    return ((eval.studiedSeconds % 3600) / 3600.0).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final ringColor =
        (evaluation?.isOnBreak ?? false) ? colors.success : colors.goldAccent;

    return Center(
      child: AnimatedProgressRing(
        value: _resolveRingProgress(),
        replayKey: 'timer-ring-$replayKey-${selectedMode.value}',
        size: 176,
        strokeWidth: 10,
        progressColor: ringColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              phaseLabel,
              style: tokens.textStyles.labelMedium.copyWith(color: ringColor),
            ),
            SizedBox(height: spacing.xxs),
            Text(
              StudyTimerL10n.formatClock(
                displaySeconds,
                locale: locale,
                useBanglaDigits: useBanglaDigits,
              ),
              key: const ValueKey('timer-clock-display'),
              style: tokens.textStyles.headlineLarge.copyWith(
                color: colors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(height: spacing.xxs),
            Text(
              statusLabel,
              key: const ValueKey('timer-status-label'),
              style: tokens.textStyles.bodySmall.copyWith(
                color: isPaused ? colors.warning : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Primary Start/Pause/Resume/Finish/Discard action bar for `StudyTimer`.
class StudyTimerActionBar extends StatelessWidget {
  /// Creates a [StudyTimerActionBar].
  const StudyTimerActionBar({
    required this.hasActiveSession,
    required this.isRunning,
    required this.isBusy,
    required this.canStart,
    required this.canLogManual,
    required this.onStart,
    required this.onManualEntry,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.onDiscard,
    super.key,
  });

  /// Whether a session row is currently active.
  final bool hasActiveSession;

  /// Whether the active session is currently ticking.
  final bool isRunning;

  /// Whether a controller persistence operation is in progress.
  final bool isBusy;

  /// Whether a subject is selected to start a live session.
  final bool canStart;

  /// Whether at least one subject exists for manual entry.
  final bool canLogManual;

  /// Callback when Start is pressed.
  final VoidCallback onStart;

  /// Callback when Manual entry is pressed.
  final VoidCallback onManualEntry;

  /// Callback when Pause is pressed.
  final VoidCallback onPause;

  /// Callback when Resume is pressed.
  final VoidCallback onResume;

  /// Callback when Finish is pressed.
  final VoidCallback onFinish;

  /// Callback when Discard is pressed.
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: [
        if (!hasActiveSession) ...[
          GlassButton(
            key: const ValueKey('timer-start-button'),
            variant: GlassButtonVariant.primary,
            onPressed: (isBusy || !canStart) ? null : onStart,
            leading: Icon(
              Icons.play_arrow_rounded,
              size: spacing.lg,
              color: colors.goldAccent,
            ),
            child: Text(l10n.prepTimerStartButton),
          ),
          GlassButton(
            key: const ValueKey('timer-manual-button'),
            onPressed: (isBusy || !canLogManual) ? null : onManualEntry,
            leading: Icon(Icons.edit_calendar_outlined, size: spacing.lg),
            child: Text(l10n.prepTimerManualEntryButton),
          ),
        ] else ...[
          if (isRunning)
            GlassButton(
              key: const ValueKey('timer-pause-button'),
              onPressed: isBusy ? null : onPause,
              leading: Icon(Icons.pause_rounded, size: spacing.lg),
              child: Text(l10n.prepTimerPauseButton),
            )
          else
            GlassButton(
              key: const ValueKey('timer-resume-button'),
              variant: GlassButtonVariant.primary,
              onPressed: isBusy ? null : onResume,
              leading: Icon(
                Icons.play_arrow_rounded,
                size: spacing.lg,
                color: colors.goldAccent,
              ),
              child: Text(l10n.prepTimerResumeButton),
            ),
          GlassButton(
            key: const ValueKey('timer-finish-button'),
            variant: GlassButtonVariant.primary,
            onPressed: isBusy ? null : onFinish,
            leading: Icon(
              Icons.stop_circle_outlined,
              size: spacing.lg,
              color: colors.success,
            ),
            child: Text(l10n.prepTimerFinishButton),
          ),
          GlassButton(
            key: const ValueKey('timer-discard-button'),
            onPressed: isBusy ? null : onDiscard,
            child: Text(
              l10n.prepTimerDiscardButton,
              style: tokens.textStyles.labelLarge.copyWith(
                color: colors.danger,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
