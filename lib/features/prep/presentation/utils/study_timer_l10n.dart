import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/study_timer_calculator.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Locale-aware clock formatting, labels, and browser tab titles for Phase 6H
/// study sessions and analytics hours.
abstract final class StudyTimerL10n {
  /// Formats [totalSeconds] as `MM:SS` or `H:MM:SS` with Bangla digits when
  /// [locale] or [useBanglaDigits] requests them.
  static String formatClock(
    int totalSeconds, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final base = StudyTimerCalculator.formatTimerClock(totalSeconds);
    if (useBanglaDigits || locale.languageCode == 'bn') {
      return AppFormatters.toBanglaDigits(base);
    }
    return base;
  }

  /// Formats [seconds] as a localized decimal hours count (e.g., `"1.5"`).
  static String formatHoursNumber(
    int seconds, {
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final hours = seconds / 3600.0;
    return AppFormatters.formatNumber(
      hours,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
      decimalDigits: hours >= 10 ? 1 : 2,
    );
  }

  /// Resolves localized label for a [StudySessionMode].
  static String modeLabel(StudySessionMode mode, AppLocalizations l10n) {
    return switch (mode) {
      StudySessionMode.focus => l10n.prepTimerModeFocus,
      StudySessionMode.stopwatch => l10n.prepTimerModeStopwatch,
      StudySessionMode.manual => l10n.prepTimerModeManual,
    };
  }

  /// Resolves localized label for a Pomodoro phase & round number.
  static String phaseLabel({
    required PomodoroPhase phase,
    required int round,
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final roundText = AppFormatters.formatNumber(
      round,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return switch (phase) {
      PomodoroPhase.focus => l10n.prepTimerPhaseFocus(roundText),
      PomodoroPhase.shortBreak => l10n.prepTimerPhaseShortBreak,
      PomodoroPhase.longBreak => l10n.prepTimerPhaseLongBreak,
    };
  }

  /// Builds localized browser tab title showing remaining Focus/Break time or
  /// elapsed Stopwatch time.
  static String buildBrowserTabTitle({
    required StudySession session,
    required StudyTimerEvaluation evaluation,
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final shownSeconds = session.mode == StudySessionMode.focus
        ? evaluation.phaseRemainingSeconds
        : evaluation.studiedSeconds;
    final clock = formatClock(
      shownSeconds,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    if (evaluation.isPaused) {
      return l10n.prepTimerTabPaused(clock);
    }
    if (session.mode == StudySessionMode.stopwatch) {
      return l10n.prepTimerTabStopwatch(clock);
    }
    if (evaluation.isOnBreak) {
      return l10n.prepTimerTabBreak(clock);
    }
    return l10n.prepTimerTabFocus(clock);
  }
}
