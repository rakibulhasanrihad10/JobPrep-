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
import 'package:job_prep/features/settings/domain/utils/data_export_snapshot.dart';

/// Builds structured JSON maps from a [DataExportSnapshot].
abstract final class DataExportJson {
  /// Export format version for forward compatibility.
  static const int schemaVersion = 1;

  /// Converts [snapshot] to a JSON-serializable map without vault secrets.
  static Map<String, dynamic> buildMap(DataExportSnapshot snapshot) {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'exportedAt': snapshot.exportedAt.toUtc().toIso8601String(),
      'counts': <String, int>{
        'circulars': snapshot.circulars.length,
        'examDates': snapshot.examDates.length,
        'subjects': snapshot.subjects.length,
        'materials': snapshot.materials.length,
        'topics': snapshot.topics.length,
        'progressLogs': snapshot.progressLogs.length,
        'studyPlans': snapshot.studyPlans.length,
        'mockTests': snapshot.mockTests.length,
        'revisionItems': snapshot.revisionItems.length,
        'studySessions': snapshot.studySessions.length,
      },
      'circulars': snapshot.circulars.map(_circularJson).toList(),
      'circularExamDates': snapshot.examDates.map(_examDateJson).toList(),
      'subjects': snapshot.subjects.map(_subjectJson).toList(),
      'materials': snapshot.materials.map(_materialJson).toList(),
      'topics': snapshot.topics.map(_topicJson).toList(),
      'progressLogs': snapshot.progressLogs.map(_logJson).toList(),
      'studyPlans': snapshot.studyPlans.map(_planJson).toList(),
      'mockTests': snapshot.mockTests.map(_mockTestJson).toList(),
      'revisionItems': snapshot.revisionItems.map(_revisionJson).toList(),
      'studySessions': snapshot.studySessions.map(_sessionJson).toList(),
    };
  }

  static Map<String, dynamic> _circularJson(Circular c) => <String, dynamic>{
        'id': c.id,
        'title': c.title,
        'sector': c.sector.value,
        'organizationName': c.organizationName,
        'organizationWebsite': c.organizationWebsite,
        'circularUrl': c.circularUrl,
        'applicationUrl': c.applicationUrl,
        'deadline': c.deadline?.toUtc().toIso8601String(),
        'vacancies': c.vacancies,
        'salaryMin': c.salaryMin,
        'salaryMax': c.salaryMax,
        'salaryNote': c.salaryNote,
        'applicationFee': c.applicationFee,
        'feeNote': c.feeNote,
        'applicationStatus': c.applicationStatus.value,
        'admitCardStatus': c.admitCardStatus.value,
        'priority': c.priority.value,
        'workflowStatus': c.workflowStatus.value,
        'isQuickCapture': c.isQuickCapture,
        'instructions': c.instructions,
        'notes': c.notes,
        'syllabus': c.syllabus,
        'checklist': <String, bool>{
          'photo': c.checklist.photo,
          'certificates': c.checklist.certificates,
          'feePaid': c.checklist.feePaid,
          'submitted': c.checklist.submitted,
          'admitCardDownloaded': c.checklist.admitCardDownloaded,
        },
        'createdAt': c.createdAt?.toUtc().toIso8601String(),
        'updatedAt': c.updatedAt?.toUtc().toIso8601String(),
      };

  static Map<String, dynamic> _examDateJson(CircularExamDate e) =>
      <String, dynamic>{
        'id': e.id,
        'circularId': e.circularId,
        'stage': e.stage,
        'examDate': e.examDate.toUtc().toIso8601String(),
        'venue': e.venue,
        'notes': e.notes,
      };

  static Map<String, dynamic> _subjectJson(Subject s) => <String, dynamic>{
        'id': s.id,
        'name': s.name,
        'color': s.color,
        'icon': s.icon,
        'examType': s.examType,
        'sortOrder': s.sortOrder,
      };

  static Map<String, dynamic> _materialJson(PrepMaterial m) =>
      <String, dynamic>{
        'id': m.id,
        'subjectId': m.subjectId,
        'title': m.title,
        'kind': m.kind.value,
        'unitLabel': m.unitLabel,
        'totalUnits': m.totalUnits,
        'completedUnits': m.completedUnits,
      };

  static Map<String, dynamic> _topicJson(Topic t) => <String, dynamic>{
        'id': t.id,
        'subjectId': t.subjectId,
        'name': t.name,
        'status': t.status.value,
      };

  static Map<String, dynamic> _logJson(ProgressLog l) => <String, dynamic>{
        'id': l.id,
        'materialId': l.materialId,
        'unitsDone': l.unitsDone,
        'entryType': l.entryType.value,
        'loggedOn': l.loggedOn.toUtc().toIso8601String(),
        'note': l.note,
      };

  static Map<String, dynamic> _planJson(StudyPlan p) => <String, dynamic>{
        'id': p.id,
        'subjectId': p.subjectId,
        'circularId': p.circularId,
        'examDateId': p.examDateId,
        'startDate': p.startDate.toUtc().toIso8601String(),
        'targetDate': p.targetDate.toUtc().toIso8601String(),
        'finishBufferDays': p.finishBufferDays,
        'restDaysPerWeek': p.restDaysPerWeek,
        'extraStudyDays': p.extraStudyDays,
        'maxDailyPace': p.maxDailyPace,
        'initialCompletedUnits': p.initialCompletedUnits,
        'postponedMaterialIds': p.postponedMaterialIds,
      };

  static Map<String, dynamic> _mockTestJson(MockTest t) => <String, dynamic>{
        'id': t.id,
        'subjectId': t.subjectId,
        'circularId': t.circularId,
        'materialId': t.materialId,
        'topicId': t.topicId,
        'title': t.title,
        'source': t.source,
        'takenOn': t.takenOn.toUtc().toIso8601String(),
        'marksObtained': t.marksObtained,
        'totalMarks': t.totalMarks,
        'negativeMarks': t.negativeMarks,
        'timeTakenMinutes': t.timeTakenMinutes,
        'timeLimitMinutes': t.timeLimitMinutes,
        'weakTopics': t.weakTopics,
        'notes': t.notes,
      };

  static Map<String, dynamic> _revisionJson(RevisionItem r) =>
      <String, dynamic>{
        'id': r.id,
        'subjectId': r.subjectId,
        'materialId': r.materialId,
        'topicId': r.topicId,
        'referenceLabel': r.referenceLabel,
        'pageNumber': r.pageNumber,
        'reason': r.reason.value,
        'source': r.source.value,
        'status': r.status.value,
        'dueOn': r.dueOn.toUtc().toIso8601String(),
        'reviewCount': r.reviewCount,
        'lastReviewedOn': r.lastReviewedOn?.toUtc().toIso8601String(),
        'note': r.note,
      };

  static Map<String, dynamic> _sessionJson(StudySession s) => <String, dynamic>{
        'id': s.id,
        'subjectId': s.subjectId,
        'materialId': s.materialId,
        'mode': s.mode.value,
        'startedAt': s.startedAt.toUtc().toIso8601String(),
        'endedAt': s.endedAt?.toUtc().toIso8601String(),
        'durationSeconds': s.durationSeconds,
        'note': s.note,
      };
}
