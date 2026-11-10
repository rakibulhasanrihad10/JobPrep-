import 'package:flutter/foundation.dart' show immutable, setEquals;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/utils/deadline_countdown.dart';

/// Immutable search, filter, and sort specification for job circulars.
@immutable
class CircularFilter {
  /// Creates a [CircularFilter].
  const CircularFilter({
    this.searchQuery = '',
    this.sectors = const {},
    this.workflowStatuses = const {},
    this.applicationStatuses = const {},
    this.priorities = const {},
    this.deadlineBand,
    this.deadlineFrom,
    this.deadlineTo,
    this.onlyQuickCapture,
    this.includeArchived = true,
    this.sortBy = CircularSortOption.deadlineAsc,
  });

  static const _unset = Object();

  /// Free-text search query matched against title, organization, and notes.
  final String searchQuery;

  /// Selected sectors; empty matches all sectors.
  final Set<CircularSector> sectors;

  /// Selected workflow statuses; empty matches all workflow statuses.
  final Set<CircularWorkflowStatus> workflowStatuses;

  /// Selected application statuses; empty matches all application statuses.
  final Set<ApplicationStatus> applicationStatuses;

  /// Selected priority levels; empty matches all priorities.
  final Set<CircularPriority> priorities;

  /// Optional urgency band filter derived from deadline countdown.
  final DeadlineColorBand? deadlineBand;

  /// Optional inclusive lower bound calendar date for deadlines.
  final DateTime? deadlineFrom;

  /// Optional inclusive upper bound calendar date for deadlines.
  final DateTime? deadlineTo;

  /// When non-null, restricts results to matching quick-capture flag.
  final bool? onlyQuickCapture;

  /// Whether archived circulars are retained when not explicitly selected.
  final bool includeArchived;

  /// Active sort order for matching circulars.
  final CircularSortOption sortBy;

  /// Whether any search or filter criterion is active.
  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      sectors.isNotEmpty ||
      workflowStatuses.isNotEmpty ||
      applicationStatuses.isNotEmpty ||
      priorities.isNotEmpty ||
      deadlineBand != null ||
      deadlineFrom != null ||
      deadlineTo != null ||
      onlyQuickCapture != null ||
      !includeArchived;

  /// Returns an updated copy of this [CircularFilter].
  CircularFilter copyWith({
    String? searchQuery,
    Set<CircularSector>? sectors,
    Set<CircularWorkflowStatus>? workflowStatuses,
    Set<ApplicationStatus>? applicationStatuses,
    Set<CircularPriority>? priorities,
    Object? deadlineBand = _unset,
    Object? deadlineFrom = _unset,
    Object? deadlineTo = _unset,
    Object? onlyQuickCapture = _unset,
    bool? includeArchived,
    CircularSortOption? sortBy,
  }) {
    return CircularFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      sectors: sectors != null ? Set.unmodifiable(sectors) : this.sectors,
      workflowStatuses: workflowStatuses != null
          ? Set.unmodifiable(workflowStatuses)
          : this.workflowStatuses,
      applicationStatuses: applicationStatuses != null
          ? Set.unmodifiable(applicationStatuses)
          : this.applicationStatuses,
      priorities:
          priorities != null ? Set.unmodifiable(priorities) : this.priorities,
      deadlineBand: identical(deadlineBand, _unset)
          ? this.deadlineBand
          : deadlineBand as DeadlineColorBand?,
      deadlineFrom: identical(deadlineFrom, _unset)
          ? this.deadlineFrom
          : deadlineFrom as DateTime?,
      deadlineTo: identical(deadlineTo, _unset)
          ? this.deadlineTo
          : deadlineTo as DateTime?,
      onlyQuickCapture: identical(onlyQuickCapture, _unset)
          ? this.onlyQuickCapture
          : onlyQuickCapture as bool?,
      includeArchived: includeArchived ?? this.includeArchived,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Filters and sorts [circulars] deterministically using [now] as reference.
  List<Circular> apply(
    List<Circular> circulars, {
    DateTime? now,
  }) {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final filtered = circulars.where((circular) {
      if (!includeArchived &&
          circular.workflowStatus == CircularWorkflowStatus.archived &&
          !workflowStatuses.contains(CircularWorkflowStatus.archived)) {
        return false;
      }
      if (sectors.isNotEmpty && !sectors.contains(circular.sector)) {
        return false;
      }
      if (workflowStatuses.isNotEmpty &&
          !workflowStatuses.contains(circular.workflowStatus)) {
        return false;
      }
      if (applicationStatuses.isNotEmpty &&
          !applicationStatuses.contains(circular.applicationStatus)) {
        return false;
      }
      if (priorities.isNotEmpty && !priorities.contains(circular.priority)) {
        return false;
      }
      if (onlyQuickCapture != null &&
          circular.isQuickCapture != onlyQuickCapture) {
        return false;
      }
      if (deadlineBand != null) {
        final countdown = computeDeadlineCountdown(circular.deadline, now: now);
        if (countdown.band != deadlineBand) {
          return false;
        }
      }
      if (!_matchesDateRange(circular.deadline, now: now)) {
        return false;
      }
      if (normalizedQuery.isNotEmpty &&
          !_matchesQuery(circular, normalizedQuery)) {
        return false;
      }
      return true;
    }).toList();

    return List.unmodifiable(filtered..sort(_comparator));
  }

  bool _matchesDateRange(DateTime? deadline, {DateTime? now}) {
    if (deadlineFrom == null && deadlineTo == null) return true;
    if (deadline == null) return false;

    final referenceNow = now ?? DateTime.now();
    final aligned = referenceNow.isUtc ? deadline.toUtc() : deadline.toLocal();
    final target = DateTime.utc(aligned.year, aligned.month, aligned.day);

    if (deadlineFrom != null) {
      final from = DateTime.utc(
        deadlineFrom!.year,
        deadlineFrom!.month,
        deadlineFrom!.day,
      );
      if (target.isBefore(from)) return false;
    }

    if (deadlineTo != null) {
      final to = DateTime.utc(
        deadlineTo!.year,
        deadlineTo!.month,
        deadlineTo!.day,
      );
      if (target.isAfter(to)) return false;
    }

    return true;
  }

  bool _matchesQuery(Circular circular, String query) {
    final fields = <String?>[
      circular.title,
      circular.organizationName,
      circular.notes,
      circular.syllabus,
      circular.instructions,
    ];
    for (final field in fields) {
      if (field != null && field.toLowerCase().contains(query)) {
        return true;
      }
    }
    return false;
  }

  int _comparator(Circular a, Circular b) {
    return switch (sortBy) {
      CircularSortOption.deadlineAsc => _compareDeadlineAsc(a, b),
      CircularSortOption.createdDesc => _compareCreatedDesc(a, b),
      CircularSortOption.updatedDesc => _compareUpdatedDesc(a, b),
      CircularSortOption.priorityDesc => _comparePriorityDesc(a, b),
      CircularSortOption.titleAsc =>
        a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    };
  }

  int _compareDeadlineAsc(Circular a, Circular b) {
    final aDeadline = a.deadline;
    final bDeadline = b.deadline;
    if (aDeadline == null && bDeadline == null) {
      return _compareUpdatedDesc(a, b);
    }
    if (aDeadline == null) return 1;
    if (bDeadline == null) return -1;
    final result = aDeadline.compareTo(bDeadline);
    if (result != 0) return result;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  int _compareCreatedDesc(Circular a, Circular b) {
    final aTime = a.createdAt ?? a.updatedAt;
    final bTime = b.createdAt ?? b.updatedAt;
    if (aTime == null && bTime == null) {
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    final diff = bTime.compareTo(aTime);
    if (diff != 0) return diff;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  int _compareUpdatedDesc(Circular a, Circular b) {
    final aTime = a.updatedAt ?? a.createdAt;
    final bTime = b.updatedAt ?? b.createdAt;
    if (aTime == null && bTime == null) {
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime);
  }

  int _comparePriorityDesc(Circular a, Circular b) {
    final weightDiff = b.priority.weight.compareTo(a.priority.weight);
    if (weightDiff != 0) return weightDiff;
    return _compareDeadlineAsc(a, b);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CircularFilter &&
        other.searchQuery == searchQuery &&
        setEquals(other.sectors, sectors) &&
        setEquals(other.workflowStatuses, workflowStatuses) &&
        setEquals(other.applicationStatuses, applicationStatuses) &&
        setEquals(other.priorities, priorities) &&
        other.deadlineBand == deadlineBand &&
        other.deadlineFrom == deadlineFrom &&
        other.deadlineTo == deadlineTo &&
        other.onlyQuickCapture == onlyQuickCapture &&
        other.includeArchived == includeArchived &&
        other.sortBy == sortBy;
  }

  @override
  int get hashCode => Object.hash(
        searchQuery,
        Object.hashAllUnordered(sectors),
        Object.hashAllUnordered(workflowStatuses),
        Object.hashAllUnordered(applicationStatuses),
        Object.hashAllUnordered(priorities),
        deadlineBand,
        deadlineFrom,
        deadlineTo,
        onlyQuickCapture,
        includeArchived,
        sortBy,
      );

  @override
  String toString() => 'CircularFilter('
      'searchQuery: $searchQuery, '
      'sectors: ${sectors.length}, '
      'sortBy: ${sortBy.name})';
}
