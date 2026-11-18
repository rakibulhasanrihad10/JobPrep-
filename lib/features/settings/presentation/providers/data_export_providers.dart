import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/settings/domain/utils/data_export_builder.dart';
import 'package:job_prep/features/today/presentation/providers/today_providers.dart';

/// Platform file-save callback delivering exported CSV/JSON bytes cleanly.
typedef DataExportFileSaverFn = Future<Uri?> Function({
  required String fileName,
  required Uint8List bytes,
  required String mimeType,
});

/// Injectable file saver defaulting to `FilePicker.saveFile` (triggers browser
/// download on web and OS save dialog on desktop/mobile).
final Provider<DataExportFileSaverFn> dataExportFileSaverProvider =
    Provider<DataExportFileSaverFn>((ref) {
  return FilePicker.saveFile;
});

/// Clock callback timestamping exported archives cleanly.
final Provider<DateTime Function()> dataExportNowProvider =
    Provider<DateTime Function()>((ref) => ref.watch(todayNowProvider));

/// Immutable UI state for Settings data export actions.
@immutable
class DataExportState {
  /// Creates a [DataExportState].
  const DataExportState({
    this.isExporting = false,
    this.lastExportedFileName,
    this.lastFormat,
    this.lastRecordCount = 0,
    this.failed = false,
  });

  static const Object _unset = Object();

  /// True while gathering data and saving the export file.
  final bool isExporting;

  /// Filename of the most recent completed export.
  final String? lastExportedFileName;

  /// Format of the most recent completed export.
  final DataExportFormat? lastFormat;

  /// Total items included across circulars and prep tables in last export.
  final int lastRecordCount;

  /// True when the latest export attempt threw an unexpected error.
  final bool failed;

  /// Returns a copy with overridden properties.
  DataExportState copyWith({
    bool? isExporting,
    Object? lastExportedFileName = _unset,
    Object? lastFormat = _unset,
    int? lastRecordCount,
    bool? failed,
  }) {
    return DataExportState(
      isExporting: isExporting ?? this.isExporting,
      lastExportedFileName: identical(lastExportedFileName, _unset)
          ? this.lastExportedFileName
          : lastExportedFileName as String?,
      lastFormat: identical(lastFormat, _unset)
          ? this.lastFormat
          : lastFormat as DataExportFormat?,
      lastRecordCount: lastRecordCount ?? this.lastRecordCount,
      failed: failed ?? this.failed,
    );
  }
}

/// Aggregates all circulars and prep repositories into a CSV or JSON archive.
class DataExportController extends Notifier<DataExportState> {
  @override
  DataExportState build() => const DataExportState();

  /// Exports all user circulars and prep data in [format] and invokes the
  /// configured file saver. Returns `true` if export completed cleanly.
  Future<bool> exportAll(DataExportFormat format) async {
    if (state.isExporting) return false;
    state = state.copyWith(isExporting: true, failed: false);

    try {
      final snapshot = await _collectSnapshot();
      final bytes = DataExportBuilder.buildBytes(snapshot, format);
      final fileName = DataExportBuilder.buildFileName(
        snapshot.exportedAt,
        format,
      );

      await ref.read(dataExportFileSaverProvider)(
        fileName: fileName,
        bytes: bytes,
        mimeType: format.mimeType,
      );

      if (!ref.mounted) return true;
      final total = snapshot.circulars.length +
          snapshot.examDates.length +
          snapshot.subjects.length +
          snapshot.materials.length +
          snapshot.topics.length +
          snapshot.progressLogs.length +
          snapshot.studyPlans.length +
          snapshot.mockTests.length +
          snapshot.revisionItems.length +
          snapshot.studySessions.length;

      state = state.copyWith(
        isExporting: false,
        lastExportedFileName: fileName,
        lastFormat: format,
        lastRecordCount: total,
        failed: false,
      );
      return true;
    } on Object {
      if (ref.mounted) {
        state = state.copyWith(isExporting: false, failed: true);
      }
      return false;
    }
  }

  Future<DataExportSnapshot> _collectSnapshot() async {
    final now = ref.read(dataExportNowProvider)();
    final circularRepo = ref.read(circularRepositoryProvider);
    final examDateRepo = ref.read(examDateRepositoryProvider);
    final subjectRepo = ref.read(subjectRepositoryProvider);
    final materialRepo = ref.read(materialRepositoryProvider);
    final topicRepo = ref.read(topicRepositoryProvider);
    final logRepo = ref.read(progressLogRepositoryProvider);
    final planRepo = ref.read(studyPlanRepositoryProvider);
    final mockRepo = ref.read(mockTestRepositoryProvider);
    final revisionRepo = ref.read(revisionItemRepositoryProvider);
    final sessionRepo = ref.read(studySessionRepositoryProvider);

    final results = await Future.wait<Object>([
      circularRepo.getCirculars(),
      subjectRepo.getSubjects(),
      materialRepo.getAllMaterials(),
      planRepo.getPlans(),
      mockRepo.getTests(),
      revisionRepo.getRevisionItems(),
      sessionRepo.getStudySessions(),
    ]);

    final circulars = results[0] as List<Circular>;
    final subjects = results[1] as List<Subject>;
    final materials = results[2] as List<PrepMaterial>;
    final studyPlans = results[3] as List<StudyPlan>;
    final mockTests = results[4] as List<MockTest>;
    final revisionItems = results[5] as List<RevisionItem>;
    final studySessions = results[6] as List<StudySession>;

    final examDates = <CircularExamDate>[];
    for (final c in circulars) {
      examDates.addAll(await examDateRepo.getExamDatesForCircular(c.id));
    }

    final topics = <Topic>[];
    for (final s in subjects) {
      topics.addAll(await topicRepo.getTopicsForSubject(s.id));
    }

    final progressLogs = <ProgressLog>[];
    for (final m in materials) {
      progressLogs.addAll(await logRepo.getLogsForMaterial(m.id));
    }

    return DataExportSnapshot(
      exportedAt: now,
      circulars: circulars,
      examDates: examDates,
      subjects: subjects,
      materials: materials,
      topics: topics,
      progressLogs: progressLogs,
      studyPlans: studyPlans,
      mockTests: mockTests,
      revisionItems: revisionItems,
      studySessions: studySessions,
    );
  }
}

/// Provides [DataExportController] for CSV/JSON export controls in Settings.
final NotifierProvider<DataExportController, DataExportState>
    dataExportControllerProvider =
    NotifierProvider<DataExportController, DataExportState>(
  DataExportController.new,
);
