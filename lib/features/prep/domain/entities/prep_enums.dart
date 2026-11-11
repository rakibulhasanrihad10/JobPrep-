/// Kind categories matching `public.materials.kind` check constraint.
enum MaterialKind {
  book('book'),
  videoCourse('video_course'),
  lectureSheet('lecture_sheet'),
  questionBank('question_bank'),
  notes('notes'),
  mockTest('mock_test'),
  other('other');

  const MaterialKind(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into a [MaterialKind], or returns `null` when unrecognized.
  static MaterialKind? tryParse(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in MaterialKind.values) {
      if (item.value == normalized) return item;
    }
    return null;
  }

  /// Parses [raw] into a [MaterialKind], falling back to [fallback].
  static MaterialKind fromValue(
    String? raw, {
    MaterialKind fallback = MaterialKind.book,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Topic study statuses matching `public.topics.status` check constraint.
enum TopicStatus {
  notStarted('not_started'),
  inProgress('in_progress'),
  needsRevision('needs_revision'),
  completed('completed');

  const TopicStatus(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into a [TopicStatus], or returns `null` when unrecognized.
  static TopicStatus? tryParse(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in TopicStatus.values) {
      if (item.value == normalized) return item;
    }
    return null;
  }

  /// Parses [raw] into a [TopicStatus], falling back to [fallback].
  static TopicStatus fromValue(
    String? raw, {
    TopicStatus fallback = TopicStatus.notStarted,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Entry classification matching `public.progress_logs.entry_type` constraint.
enum ProgressLogEntryType {
  study('study'),
  correction('correction');

  const ProgressLogEntryType(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into a [ProgressLogEntryType], or returns `null` when
  /// unrecognized.
  static ProgressLogEntryType? tryParse(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in ProgressLogEntryType.values) {
      if (item.value == normalized) return item;
    }
    return null;
  }

  /// Parses [raw] into a [ProgressLogEntryType], falling back to [fallback].
  static ProgressLogEntryType fromValue(
    String? raw, {
    ProgressLogEntryType fallback = ProgressLogEntryType.study,
  }) {
    return tryParse(raw) ?? fallback;
  }
}
