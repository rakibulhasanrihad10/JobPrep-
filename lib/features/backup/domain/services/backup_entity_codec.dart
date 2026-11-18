import 'package:job_prep/features/circulars/data/mappers/circular_exam_date_mapper.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_mapper.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/notifications/data/mappers/notification_mapper.dart';
import 'package:job_prep/features/notifications/domain/entities/app_notification.dart';
import 'package:job_prep/features/prep/data/mappers/chapter_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/material_chapter_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/mock_test_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/mock_test_topic_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_material_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/progress_log_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/revision_item_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/study_plan_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/study_session_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/subject_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/topic_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/material_chapter.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test_topic.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_plan.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/settings/data/mappers/user_settings_mapper.dart';
import 'package:job_prep/features/settings/domain/entities/user_app_settings.dart';
import 'package:job_prep/features/vault/data/mappers/portal_account_mapper.dart';
import 'package:job_prep/features/vault/domain/entities/portal_account.dart';

/// Helper mapping domain models to and from JSON maps for backup tables.
abstract final class BackupEntityCodec {
  /// Converts [Circular] to backup JSON map.
  static Map<String, dynamic> circularToJson(Circular c) =>
      CircularMapper.toInsertJson(c);

  /// Parses [Circular] from backup JSON map.
  static Circular circularFromJson(Map<String, dynamic> json) =>
      CircularMapper.fromJson(json);

  /// Converts [CircularExamDate] to backup JSON map.
  static Map<String, dynamic> examDateToJson(CircularExamDate d) =>
      CircularExamDateMapper.toInsertJson(d);

  /// Parses [CircularExamDate] from backup JSON map.
  static CircularExamDate examDateFromJson(Map<String, dynamic> json) =>
      CircularExamDateMapper.fromJson(json);

  /// Converts [Subject] to backup JSON map.
  static Map<String, dynamic> subjectToJson(Subject s) =>
      SubjectMapper.toInsertJson(s);

  /// Parses [Subject] from backup JSON map.
  static Subject subjectFromJson(Map<String, dynamic> json) =>
      SubjectMapper.fromJson(json);

  /// Converts [Chapter] to backup JSON map.
  static Map<String, dynamic> chapterToJson(Chapter c) =>
      ChapterMapper.toInsertJson(c);

  /// Parses [Chapter] from backup JSON map.
  static Chapter chapterFromJson(Map<String, dynamic> json) =>
      ChapterMapper.fromJson(json);

  /// Converts [PrepMaterial] to backup JSON map.
  static Map<String, dynamic> materialToJson(PrepMaterial m) =>
      PrepMaterialMapper.toInsertJson(m);

  /// Parses [PrepMaterial] from backup JSON map.
  static PrepMaterial materialFromJson(Map<String, dynamic> json) =>
      PrepMaterialMapper.fromJson(json);

  /// Converts [ProgressLog] to backup JSON map.
  static Map<String, dynamic> progressLogToJson(ProgressLog p) =>
      ProgressLogMapper.toInsertJson(p);

  /// Parses [ProgressLog] from backup JSON map.
  static ProgressLog progressLogFromJson(Map<String, dynamic> json) =>
      ProgressLogMapper.fromJson(json);

  /// Converts [Topic] to backup JSON map.
  static Map<String, dynamic> topicToJson(Topic t) =>
      TopicMapper.toInsertJson(t);

  /// Parses [Topic] from backup JSON map.
  static Topic topicFromJson(Map<String, dynamic> json) =>
      TopicMapper.fromJson(json);

  /// Converts [StudyPlan] to backup JSON map.
  static Map<String, dynamic> studyPlanToJson(StudyPlan s) =>
      StudyPlanMapper.toInsertJson(s);

  /// Parses [StudyPlan] from backup JSON map.
  static StudyPlan studyPlanFromJson(Map<String, dynamic> json) =>
      StudyPlanMapper.fromJson(json);

  /// Converts [MockTest] to backup JSON map.
  static Map<String, dynamic> mockTestToJson(MockTest m) =>
      MockTestMapper.toInsertJson(m);

  /// Parses [MockTest] from backup JSON map.
  static MockTest mockTestFromJson(Map<String, dynamic> json) =>
      MockTestMapper.fromJson(json);

  /// Converts [MockTestTopic] to backup JSON map.
  static Map<String, dynamic> mockTestTopicToJson(MockTestTopic m) =>
      MockTestTopicMapper.toInsertJson(m);

  /// Parses [MockTestTopic] from backup JSON map.
  static MockTestTopic mockTestTopicFromJson(Map<String, dynamic> json) =>
      MockTestTopicMapper.fromJson(json);

  /// Converts [MaterialChapter] to backup JSON map.
  static Map<String, dynamic> materialChapterToJson(MaterialChapter m) =>
      MaterialChapterMapper.toInsertJson(m);

  /// Parses [MaterialChapter] from backup JSON map.
  static MaterialChapter materialChapterFromJson(Map<String, dynamic> json) =>
      MaterialChapterMapper.fromJson(json);

  /// Converts [RevisionItem] to backup JSON map.
  static Map<String, dynamic> revisionItemToJson(RevisionItem r) =>
      RevisionItemMapper.toInsertJson(r);

  /// Parses [RevisionItem] from backup JSON map.
  static RevisionItem revisionItemFromJson(Map<String, dynamic> json) =>
      RevisionItemMapper.fromJson(json);

  /// Converts [StudySession] to backup JSON map.
  static Map<String, dynamic> studySessionToJson(StudySession s) =>
      StudySessionMapper.toInsertJson(s);

  /// Parses [StudySession] from backup JSON map.
  static StudySession studySessionFromJson(Map<String, dynamic> json) =>
      StudySessionMapper.fromJson(json);

  /// Converts [AppNotification] to backup JSON map.
  static Map<String, dynamic> notificationToJson(AppNotification n) =>
      NotificationMapper.toJson(n);

  /// Parses [AppNotification] from backup JSON map.
  static AppNotification notificationFromJson(Map<String, dynamic> json) =>
      NotificationMapper.fromJson(json);

  /// Converts [PortalAccount] to backup JSON map (ciphertext only).
  static Map<String, dynamic> portalAccountToJson(PortalAccount p) =>
      PortalAccountMapper.toInsertJson(p);

  /// Parses [PortalAccount] from backup JSON map.
  static PortalAccount portalAccountFromJson(Map<String, dynamic> json) =>
      PortalAccountMapper.fromJson(json);

  /// Converts [UserAppSettings] to backup JSON map.
  static Map<String, dynamic> userSettingsToJson(UserAppSettings u) =>
      UserSettingsMapper.toUpsertJson(userId: u.userId, settings: u);

  /// Parses [UserAppSettings] from backup JSON map.
  static UserAppSettings userSettingsFromJson(Map<String, dynamic> json) =>
      UserSettingsMapper.fromJson(json);
}
