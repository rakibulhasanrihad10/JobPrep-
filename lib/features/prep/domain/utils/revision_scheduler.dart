import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';

/// Queue actions available on an active [RevisionItem].
enum RevisionReviewAction {
  easy,
  stillHard,
  snooze,
  dismiss,
}

/// Queue tabs rendered on the Revision screen.
enum RevisionQueueTab {
  dueToday,
  overdue,
  upcoming,
  done,
}

/// Item counts per [RevisionQueueTab] for display on tab chips.
@immutable
class RevisionTabCounts {
  /// Creates a [RevisionTabCounts].
  const RevisionTabCounts({
    this.dueToday = 0,
    this.overdue = 0,
    this.upcoming = 0,
    this.done = 0,
  });

  /// Items due strictly today.
  final int dueToday;

  /// Items whose scheduled `dueOn` is strictly before today.
  final int overdue;

  /// Active items scheduled after today.
  final int upcoming;

  /// Terminal mastered or dismissed items.
  final int done;

  /// Total items still awaiting active review today or overdue.
  int get actionNeeded => dueToday + overdue;

  /// Returns count corresponding to [tab].
  int countFor(RevisionQueueTab tab) {
    return switch (tab) {
      RevisionQueueTab.dueToday => dueToday,
      RevisionQueueTab.overdue => overdue,
      RevisionQueueTab.upcoming => upcoming,
      RevisionQueueTab.done => done,
    };
  }
}

/// Pure spaced-repetition scheduling, queue bucketing, reference extraction,
/// and filtering logic for `revision_items`.
abstract final class RevisionScheduler {
  /// Progressive day gaps traversed when reviewed as
  /// [RevisionReviewAction.easy].
  ///
  /// Review 0 -> +3 days
  /// Review 1 -> +7 days
  /// Review 2 -> +14 days
  /// Review 3 -> +30 days
  /// Review >= 4 -> `RevisionStatus.mastered`
  static const List<int> easyGapDays = <int>[3, 7, 14, 30];

  /// Initial delay applied when flagging a brand-new item (1 day later).
  static const int initialDelayDays = 1;

  /// Normalizes [value] to a UTC midnight date matching SQL `date` columns.
  static DateTime normalizeUtcDate(DateTime value) {
    return DateTime.utc(value.year, value.month, value.day);
  }

  /// Adds calendar [days] to [date] without DST drift.
  static DateTime addCalendarDays(DateTime date, int days) {
    final normalized = normalizeUtcDate(date);
    return DateTime.utc(
      normalized.year,
      normalized.month,
      normalized.day + days,
    );
  }

  /// Computes the initial due date for a newly flagged item (`1` day after
  /// [flaggedOn]).
  static DateTime initialDueDate(DateTime flaggedOn) {
    return addCalendarDays(flaggedOn, initialDelayDays);
  }

  /// Applies [action] on [item] relative to [today] and returns the updated
  /// [RevisionItem] snapshot.
  static RevisionItem applyAction(
    RevisionItem item,
    RevisionReviewAction action, {
    required DateTime today,
  }) {
    final todayOnly = normalizeUtcDate(today);
    final currentDue = normalizeUtcDate(item.dueOn);

    switch (action) {
      case RevisionReviewAction.easy:
        final nextCount = item.reviewCount + 1;
        if (item.reviewCount >= easyGapDays.length) {
          return item.copyWith(
            status: RevisionStatus.mastered,
            reviewCount: nextCount,
            lastReviewedOn: todayOnly,
          );
        }
        final gapDays = easyGapDays[item.reviewCount];
        return item.copyWith(
          status: RevisionStatus.revised,
          reviewCount: nextCount,
          dueOn: addCalendarDays(todayOnly, gapDays),
          lastReviewedOn: todayOnly,
        );

      case RevisionReviewAction.stillHard:
        return item.copyWith(
          status: RevisionStatus.revised,
          reviewCount: 0,
          dueOn: addCalendarDays(todayOnly, initialDelayDays),
          lastReviewedOn: todayOnly,
        );

      case RevisionReviewAction.snooze:
        final baseDate =
            currentDue.isBefore(todayOnly) ? todayOnly : currentDue;
        return item.copyWith(
          dueOn: addCalendarDays(baseDate, 1),
        );

      case RevisionReviewAction.dismiss:
        return item.copyWith(
          status: RevisionStatus.dismissed,
        );
    }
  }

  /// Returns how many days ahead an [RevisionReviewAction.easy] tap will
  /// schedule next, or `null` when the next Easy pass promotes to `mastered`.
  static int? nextEasyGapDays(RevisionItem item) {
    if (item.reviewCount >= easyGapDays.length) return null;
    return easyGapDays[item.reviewCount];
  }

  /// Classifies [item] into its queue tab relative to [today].
  static RevisionQueueTab classifyTab(
    RevisionItem item, {
    required DateTime today,
  }) {
    if (item.isDone) {
      return RevisionQueueTab.done;
    }
    final todayOnly = normalizeUtcDate(today);
    final dueOnly = normalizeUtcDate(item.dueOn);
    if (dueOnly.isBefore(todayOnly)) {
      return RevisionQueueTab.overdue;
    }
    if (dueOnly == todayOnly) {
      return RevisionQueueTab.dueToday;
    }
    return RevisionQueueTab.upcoming;
  }

  /// Returns positive whole days overdue relative to [today], or `0` if due
  /// today or later.
  static int daysOverdue(
    RevisionItem item, {
    required DateTime today,
  }) {
    if (item.isDone) return 0;
    final todayOnly = normalizeUtcDate(today);
    final dueOnly = normalizeUtcDate(item.dueOn);
    final diff = todayOnly.difference(dueOnly).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Filters and sorts [items] for optional [subjectId], [materialId], and
  /// [tab].
  static List<RevisionItem> filterItems(
    Iterable<RevisionItem> items, {
    required DateTime today,
    RevisionQueueTab? tab,
    String? subjectId,
    String? materialId,
  }) {
    final trimmedSubject = subjectId?.trim();
    final trimmedMaterial = materialId?.trim();

    final matches = items.where((item) {
      if (trimmedSubject != null &&
          trimmedSubject.isNotEmpty &&
          item.subjectId != trimmedSubject) {
        return false;
      }
      if (trimmedMaterial != null &&
          trimmedMaterial.isNotEmpty &&
          item.materialId != trimmedMaterial) {
        return false;
      }
      if (tab != null && classifyTab(item, today: today) != tab) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        if (tab == RevisionQueueTab.done) {
          final bTime = b.lastReviewedOn ?? b.updatedAt ?? b.dueOn;
          final aTime = a.lastReviewedOn ?? a.updatedAt ?? a.dueOn;
          final byRecent = bTime.compareTo(aTime);
          if (byRecent != 0) return byRecent;
        }
        final byDue = a.dueOn.compareTo(b.dueOn);
        if (byDue != 0) return byDue;
        final aCreated = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bCreated = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aCreated.compareTo(bCreated);
      });

    return List<RevisionItem>.unmodifiable(matches);
  }

  /// Computes counts per tab across items matching optional [subjectId] and
  /// [materialId] filters.
  static RevisionTabCounts countTabs(
    Iterable<RevisionItem> items, {
    required DateTime today,
    String? subjectId,
    String? materialId,
  }) {
    final scoped = filterItems(
      items,
      today: today,
      subjectId: subjectId,
      materialId: materialId,
    );
    var dueToday = 0;
    var overdue = 0;
    var upcoming = 0;
    var done = 0;
    for (final item in scoped) {
      switch (classifyTab(item, today: today)) {
        case RevisionQueueTab.dueToday:
          dueToday += 1;
        case RevisionQueueTab.overdue:
          overdue += 1;
        case RevisionQueueTab.upcoming:
          upcoming += 1;
        case RevisionQueueTab.done:
          done += 1;
      }
    }
    return RevisionTabCounts(
      dueToday: dueToday,
      overdue: overdue,
      upcoming: upcoming,
      done: done,
    );
  }

  /// Splits free-text mock test `weakTopics` into clean trimmed topic strings.
  static List<String> extractWeakTopicLabels(String? rawWeakTopics) {
    final trimmed = rawWeakTopics?.trim() ?? '';
    if (trimmed.isEmpty) return const <String>[];
    final seen = <String>{};
    final result = <String>[];
    for (final part in trimmed.split(RegExp(r'[,;\n]+'))) {
      final clean = part.trim();
      if (clean.isEmpty) continue;
      final key = clean.toLowerCase();
      if (seen.add(key)) {
        result.add(clean);
      }
    }
    return List<String>.unmodifiable(result);
  }

  /// Attempts to extract a non-negative integer page number from references
  /// like `"p. 128"`, `"page ২৪৫"`, or `"128"`.
  static int? extractPageNumber(String rawReference) {
    final normalized = _normalizeDigits(rawReference);
    final match = RegExp(
      r'(?:^|\b)(?:p\.?|pg\.?|page)\s*(\d+)(?:\b|$)',
      caseSensitive: false,
    ).firstMatch(normalized);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    final exact = RegExp(r'^\s*(\d+)\s*$').firstMatch(normalized);
    if (exact != null) {
      return int.tryParse(exact.group(1)!);
    }
    return null;
  }

  static String _normalizeDigits(String raw) {
    if (raw.isEmpty) return raw;
    const banglaZero = 0x09E6;
    const banglaNine = 0x09EF;
    final buffer = StringBuffer();
    for (final rune in raw.runes) {
      if (rune >= banglaZero && rune <= banglaNine) {
        buffer.writeCharCode(0x30 + (rune - banglaZero));
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }
}
