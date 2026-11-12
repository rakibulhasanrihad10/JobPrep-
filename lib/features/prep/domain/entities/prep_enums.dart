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

/// Reason why a study point was flagged in `public.revision_items`.
enum RevisionReason {
  tricky('tricky'),
  forgot('forgot'),
  important('important'),
  mistake('mistake');

  const RevisionReason(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into a [RevisionReason], or returns `null` when unrecognized.
  static RevisionReason? tryParse(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in RevisionReason.values) {
      if (item.value == normalized) return item;
    }
    return null;
  }

  /// Parses [raw] into a [RevisionReason], falling back to [fallback].
  static RevisionReason fromValue(
    String? raw, {
    RevisionReason fallback = RevisionReason.tricky,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Origin surface creating a record in `public.revision_items`.
enum RevisionSource {
  log('log'),
  mockTest('mock_test'),
  manual('manual');

  const RevisionSource(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into a [RevisionSource], or returns `null` when unrecognized.
  static RevisionSource? tryParse(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in RevisionSource.values) {
      if (item.value == normalized) return item;
    }
    return null;
  }

  /// Parses [raw] into a [RevisionSource], falling back to [fallback].
  static RevisionSource fromValue(
    String? raw, {
    RevisionSource fallback = RevisionSource.manual,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Lifecycle state stored in `public.revision_items.status`.
enum RevisionStatus {
  pending('pending'),
  revised('revised'),
  mastered('mastered'),
  dismissed('dismissed');

  const RevisionStatus(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into a [RevisionStatus], or returns `null` when unrecognized.
  static RevisionStatus? tryParse(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in RevisionStatus.values) {
      if (item.value == normalized) return item;
    }
    return null;
  }

  /// Parses [raw] into a [RevisionStatus], falling back to [fallback].
  static RevisionStatus fromValue(
    String? raw, {
    RevisionStatus fallback = RevisionStatus.pending,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Tracking mode stored in `public.study_sessions.mode`.
enum StudySessionMode {
  focus('focus'),
  stopwatch('stopwatch'),
  manual('manual');

  const StudySessionMode(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into a [StudySessionMode], or returns `null` when invalid.
  static StudySessionMode? tryParse(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in StudySessionMode.values) {
      if (item.value == normalized) return item;
    }
    return null;
  }

  /// Parses [raw] into a [StudySessionMode], falling back to [fallback].
  static StudySessionMode fromValue(
    String? raw, {
    StudySessionMode fallback = StudySessionMode.focus,
  }) {
    return tryParse(raw) ?? fallback;
  }
}

/// Active Pomodoro interval phase stored in `public.study_sessions`.
enum PomodoroPhase {
  focus('focus'),
  shortBreak('short_break'),
  longBreak('long_break');

  const PomodoroPhase(this.value);

  /// Database string value persisted in PostgreSQL.
  final String value;

  /// Parses [raw] into a [PomodoroPhase], or returns `null` when invalid.
  static PomodoroPhase? tryParse(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return null;
    for (final item in PomodoroPhase.values) {
      if (item.value == normalized) return item;
    }
    return null;
  }
}
