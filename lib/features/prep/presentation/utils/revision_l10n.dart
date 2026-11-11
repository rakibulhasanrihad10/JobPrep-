import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_colors.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_state.dart';
import 'package:job_prep/l10n/app_localizations.dart';

/// Localization and semantic token helpers for Phase 6G Revision UI.
abstract final class RevisionL10n {
  /// Localized display label for a [RevisionReason].
  static String reasonLabel(RevisionReason reason, AppLocalizations l10n) {
    return switch (reason) {
      RevisionReason.tricky => l10n.prepRevisionReasonTricky,
      RevisionReason.forgot => l10n.prepRevisionReasonForgot,
      RevisionReason.important => l10n.prepRevisionReasonImportant,
      RevisionReason.mistake => l10n.prepRevisionReasonMistake,
    };
  }

  /// Semantic token color for a [RevisionReason] chip.
  static Color reasonColor(RevisionReason reason, AppColorsToken colors) {
    return switch (reason) {
      RevisionReason.tricky => colors.warning,
      RevisionReason.forgot => colors.info,
      RevisionReason.important => colors.goldAccent,
      RevisionReason.mistake => colors.danger,
    };
  }

  /// Localized display label for a [RevisionSource].
  static String sourceLabel(RevisionSource source, AppLocalizations l10n) {
    return switch (source) {
      RevisionSource.log => l10n.prepRevisionSourceLog,
      RevisionSource.mockTest => l10n.prepRevisionSourceMockTest,
      RevisionSource.manual => l10n.prepRevisionSourceManual,
    };
  }

  /// Localized display label including item count for a [RevisionQueueTab].
  static String tabLabel(
    RevisionQueueTab tab, {
    required int count,
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final formattedCount = AppFormatters.formatNumber(
      count,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    return switch (tab) {
      RevisionQueueTab.dueToday => l10n.prepRevisionTabDueToday(formattedCount),
      RevisionQueueTab.overdue => l10n.prepRevisionTabOverdue(formattedCount),
      RevisionQueueTab.upcoming => l10n.prepRevisionTabUpcoming(formattedCount),
      RevisionQueueTab.done => l10n.prepRevisionTabDone(formattedCount),
    };
  }

  /// Localized schedule status text for a [RevisionItem] relative to [today].
  static String scheduleBadgeText(
    RevisionItem item, {
    required DateTime today,
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    if (item.status == RevisionStatus.mastered) {
      return l10n.prepRevisionStatusMastered;
    }
    if (item.status == RevisionStatus.dismissed) {
      return l10n.prepRevisionStatusDismissed;
    }

    final todayOnly = RevisionScheduler.normalizeUtcDate(today);
    final dueOnly = RevisionScheduler.normalizeUtcDate(item.dueOn);
    final diffDays = dueOnly.difference(todayOnly).inDays;

    if (diffDays == 0) {
      return l10n.prepRevisionDueTodayLabel;
    }
    final formatted = AppFormatters.formatNumber(
      diffDays.abs(),
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    if (diffDays < 0) {
      return l10n.prepRevisionOverdueDaysLabel(diffDays.abs(), formatted);
    }
    return l10n.prepRevisionDueInDaysLabel(diffDays, formatted);
  }

  /// Localized banner copy explaining an executed [RevisionUndoRecord].
  static String undoBannerText(
    RevisionUndoRecord record, {
    required AppLocalizations l10n,
    required Locale locale,
    required bool useBanglaDigits,
  }) {
    final refLabel = record.previousItem.referenceLabel;
    return switch (record.action) {
      RevisionReviewAction.easy => switch (record.updatedItem.status) {
          RevisionStatus.mastered =>
            l10n.prepRevisionFeedbackMastered(refLabel),
          _ => l10n.prepRevisionFeedbackEasyNext(
              refLabel,
              AppFormatters.formatNumber(
                RevisionScheduler.nextEasyGapDays(record.previousItem) ?? 30,
                locale: locale,
                useBanglaDigits: useBanglaDigits,
              ),
            ),
        },
      RevisionReviewAction.stillHard =>
        l10n.prepRevisionFeedbackStillHard(refLabel),
      RevisionReviewAction.snooze => l10n.prepRevisionFeedbackSnoozed(refLabel),
      RevisionReviewAction.dismiss =>
        l10n.prepRevisionFeedbackDismissed(refLabel),
    };
  }
}
