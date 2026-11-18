import 'package:drift/drift.dart';

/// Local SQLite schema for preparation subjects.
class LocalSubjects extends Table {
  @override
  String get tableName => 'subjects';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('gold'))();
  TextColumn get icon => text().withDefault(const Constant('menu_book'))();
  TextColumn get examType => text().withDefault(const Constant('general'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get enabledCheckpoints => text().withDefault(
        const Constant('["study","practice","model_test","revision"]'),
      )();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for syllabus chapters.
class LocalChapters extends Table {
  @override
  String get tableName => 'chapters';

  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get title => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for study materials (books, courses, notes).
class LocalMaterials extends Table {
  @override
  String get tableName => 'materials';

  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get title => text()();
  TextColumn get kind => text().withDefault(const Constant('book'))();
  TextColumn get unitLabel => text().withDefault(const Constant('pages'))();
  IntColumn get totalUnits => integer().withDefault(const Constant(0))();
  IntColumn get completedUnits => integer().withDefault(const Constant(0))();
  TextColumn get coverImagePath => text().nullable()();
  TextColumn get coverImageUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for granular progress log entries.
class LocalProgressLogs extends Table {
  @override
  String get tableName => 'progress_logs';

  TextColumn get id => text()();
  TextColumn get materialId => text()();
  IntColumn get unitsDone => integer().withDefault(const Constant(0))();
  TextColumn get entryType => text().withDefault(const Constant('study'))();
  DateTimeColumn get loggedOn => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for topics inside subjects.
class LocalTopics extends Table {
  @override
  String get tableName => 'topics';

  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get chapterId => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get weight => integer().withDefault(const Constant(1))();
  DateTimeColumn get studyDoneAt => dateTime().nullable()();
  DateTimeColumn get practiceDoneAt => dateTime().nullable()();
  DateTimeColumn get modelTestDoneAt => dateTime().nullable()();
  DateTimeColumn get revisionDoneAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for mapping circulars to subjects.
class LocalCircularSubjects extends Table {
  @override
  String get tableName => 'circular_subjects';

  TextColumn get id => text()();
  TextColumn get circularId => text()();
  TextColumn get subjectId => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for study plans.
class LocalStudyPlans extends Table {
  @override
  String get tableName => 'study_plans';

  TextColumn get id => text()();
  TextColumn get subjectId => text().nullable()();
  TextColumn get circularId => text().nullable()();
  TextColumn get examDateId => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get targetDate => dateTime()();
  IntColumn get finishBufferDays => integer().withDefault(const Constant(7))();
  IntColumn get restDaysPerWeek => integer().withDefault(const Constant(0))();
  IntColumn get extraStudyDays => integer().withDefault(const Constant(0))();
  IntColumn get maxDailyPace => integer().nullable()();
  IntColumn get initialCompletedUnits =>
      integer().withDefault(const Constant(0))();
  TextColumn get postponedMaterialIds =>
      text().withDefault(const Constant('[]'))();
  TextColumn get planBasis =>
      text().withDefault(const Constant('reading_units'))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for mock tests.
class LocalMockTests extends Table {
  @override
  String get tableName => 'mock_tests';

  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get circularId => text().nullable()();
  TextColumn get materialId => text().nullable()();
  TextColumn get topicId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get source => text().nullable()();
  DateTimeColumn get takenOn => dateTime()();
  RealColumn get marksObtained => real()();
  RealColumn get totalMarks => real()();
  RealColumn get negativeMarks => real().nullable()();
  IntColumn get timeTakenMinutes => integer().nullable()();
  IntColumn get timeLimitMinutes => integer().nullable()();
  TextColumn get weakTopics => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for Leitner-style spaced revision items.
class LocalRevisionItems extends Table {
  @override
  String get tableName => 'revision_items';

  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get materialId => text().nullable()();
  TextColumn get topicId => text().nullable()();
  TextColumn get referenceLabel => text()();
  IntColumn get pageNumber => integer().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get reason => text().withDefault(const Constant('tricky'))();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get progressLogId => text().nullable()();
  TextColumn get mockTestId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get dueOn => dateTime()();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReviewedOn => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for study timer and Pomodoro sessions.
class LocalStudySessions extends Table {
  @override
  String get tableName => 'study_sessions';

  TextColumn get id => text()();
  TextColumn get subjectId => text()();
  TextColumn get materialId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  TextColumn get mode => text().withDefault(const Constant('focus'))();
  TextColumn get note => text().nullable()();
  TextColumn get pauseIntervals => text().withDefault(const Constant('[]'))();
  DateTimeColumn get phaseStartedAt => dateTime().nullable()();
  IntColumn get targetDurationSeconds => integer().nullable()();
  IntColumn get pomodoroRound => integer().nullable()();
  TextColumn get pomodoroPhase => text().nullable()();
  IntColumn get focusMinutes => integer().withDefault(const Constant(25))();
  IntColumn get shortBreakMinutes => integer().withDefault(const Constant(5))();
  IntColumn get longBreakMinutes => integer().withDefault(const Constant(15))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for mock test linked topics.
class LocalMockTestTopics extends Table {
  @override
  String get tableName => 'mock_test_topics';

  TextColumn get id => text()();
  TextColumn get mockTestId => text()();
  TextColumn get topicId => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite schema for material linked chapters.
class LocalMaterialChapters extends Table {
  @override
  String get tableName => 'material_chapters';

  TextColumn get id => text()();
  TextColumn get materialId => text()();
  TextColumn get chapterId => text()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
