import 'package:flutter/foundation.dart' show immutable;
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';

/// Supported user data export formats.
enum DataExportFormat {
  csv('csv', 'text/csv'),
  json('json', 'application/json');

  const DataExportFormat(this.extension, this.mimeType);

  /// File extension without leading dot.
  final String extension;

  /// Standard MIME type for file download/save.
  final String mimeType;
}

/// Complete read-only snapshot of user circulars and prep progress ready for
/// CSV or JSON export. Never includes vault passphrases or encrypted secrets.
@immutable
class DataExportSnapshot {
  /// Creates a [DataExportSnapshot].
  const DataExportSnapshot({
    required this.exportedAt,
    this.circulars = const <Circular>[],
    this.examDates = const <CircularExamDate>[],
    this.subjects = const <Subject>[],
    this.materials = const <PrepMaterial>[],
    this.topics = const <Topic>[],
    this.progressLogs = const <ProgressLog>[],
    this.studyPlans = const <StudyPlan>[],
    this.mockTests = const <MockTest>[],
    this.revisionItems = const <RevisionItem>[],
    this.studySessions = const <StudySession>[],
  });

  /// Timestamp recorded on export generation.
  final DateTime exportedAt;

  /// All tracked job circulars (including archived/inbox).
  final List<Circular> circulars;

  /// All scheduled circular exam sittings.
  final List<CircularExamDate> examDates;

  /// All preparation subjects.
  final List<Subject> subjects;

  /// All study materials across subjects.
  final List<PrepMaterial> materials;

  /// All syllabus topics across subjects.
  final List<Topic> topics;

  /// All study & correction progress logs across materials.
  final List<ProgressLog> progressLogs;

  /// All per-subject and all-subjects study plans.
  final List<StudyPlan> studyPlans;

  /// All logged mock tests.
  final List<MockTest> mockTests;

  /// All spaced revision items.
  final List<RevisionItem> revisionItems;

  /// All study timer and manual study sessions.
  final List<StudySession> studySessions;
}
