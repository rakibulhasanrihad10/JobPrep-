import 'package:drift/drift.dart';

/// Local SQLite table schema for tracked job circulars.
class LocalCirculars extends Table {
  @override
  String get tableName => 'circulars';

  /// Primary key UUID.
  TextColumn get id => text()();

  /// Job circular title or designation name.
  TextColumn get title => text()();

  /// Employment sector category (`government`, `bank`, `private`, etc.).
  TextColumn get sector => text().withDefault(const Constant('government'))();

  /// Hiring organization or department.
  TextColumn get organizationName => text().nullable()();

  /// Official website of the recruiting entity.
  TextColumn get organizationWebsite => text().nullable()();

  /// Original circular notice URL.
  TextColumn get circularUrl => text().nullable()();

  /// Online application submission URL.
  TextColumn get applicationUrl => text().nullable()();

  /// Application deadline timestamp.
  DateTimeColumn get deadline => dateTime().nullable()();

  /// Number of published vacancies.
  IntColumn get vacancies => integer().nullable()();

  /// Minimum monthly salary or grade.
  RealColumn get salaryMin => real().nullable()();

  /// Maximum monthly salary or grade.
  RealColumn get salaryMax => real().nullable()();

  /// Additional salary scale notes.
  TextColumn get salaryNote => text().nullable()();

  /// Required application fee.
  RealColumn get applicationFee => real().nullable()();

  /// Fee payment instructions or notes.
  TextColumn get feeNote => text().nullable()();

  /// Current application progression stage.
  TextColumn get applicationStatus =>
      text().withDefault(const Constant('not_applied'))();

  /// Admit card availability status.
  TextColumn get admitCardStatus =>
      text().withDefault(const Constant('not_available'))();

  /// User priority level (`low`, `medium`, `high`, `urgent`).
  TextColumn get priority => text().withDefault(const Constant('medium'))();

  /// Workflow queue status (`inbox`, `saved`, `applied`, `archived`).
  TextColumn get workflowStatus =>
      text().withDefault(const Constant('saved'))();

  /// Application instructions or requirements.
  TextColumn get instructions => text().nullable()();

  /// User personal notes.
  TextColumn get notes => text().nullable()();

  /// Syllabus outline.
  TextColumn get syllabus => text().nullable()();

  /// Whether created via one-tap Quick Capture.
  BoolColumn get isQuickCapture =>
      boolean().withDefault(const Constant(false))();

  /// Checklist: photo prepared.
  BoolColumn get checklistPhoto =>
      boolean().withDefault(const Constant(false))();

  /// Checklist: certificates gathered.
  BoolColumn get checklistCertificates =>
      boolean().withDefault(const Constant(false))();

  /// Checklist: application fee paid.
  BoolColumn get checklistFeePaid =>
      boolean().withDefault(const Constant(false))();

  /// Checklist: application submitted.
  BoolColumn get checklistSubmitted =>
      boolean().withDefault(const Constant(false))();

  /// Checklist: admit card downloaded.
  BoolColumn get checklistAdmitCardDownloaded =>
      boolean().withDefault(const Constant(false))();

  /// Creation timestamp.
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// Last modification timestamp.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local SQLite table schema for circular exam dates and stages.
class LocalCircularExamDates extends Table {
  @override
  String get tableName => 'circular_exam_dates';

  /// Primary key UUID.
  TextColumn get id => text()();

  /// Parent circular foreign key.
  TextColumn get circularId => text()();

  /// Exam stage name (e.g., Preliminary, Written, Viva).
  TextColumn get stage => text()();

  /// Scheduled date of the exam.
  DateTimeColumn get examDate => dateTime()();

  /// Exam center or venue description.
  TextColumn get venue => text().nullable()();

  /// Notes or instructions for this exam stage.
  TextColumn get notes => text().nullable()();

  /// Creation timestamp.
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// Last update timestamp.
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
