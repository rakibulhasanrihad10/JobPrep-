import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/domain/repositories/exam_date_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/material_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/mock_test_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/progress_log_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/revision_item_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/study_plan_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/study_session_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/subject_repository.dart';
import 'package:job_prep/features/prep/domain/repositories/topic_repository.dart';
import 'package:job_prep/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:job_prep/features/vault/domain/repositories/portal_account_repository.dart';

/// Aggregation of cloud repositories used as upload targets during migration.
class CloudRepositories {
  /// Creates a [CloudRepositories] bundle.
  const CloudRepositories({
    required this.subjectRepo,
    required this.topicRepo,
    required this.materialRepo,
    required this.circularRepo,
    required this.examDateRepo,
    required this.studyPlanRepo,
    required this.mockTestRepo,
    required this.progressLogRepo,
    required this.revisionItemRepo,
    required this.studySessionRepo,
    required this.portalAccountRepo,
    required this.userSettingsRepo,
  });

  /// Cloud subject repository.
  final SubjectRepository subjectRepo;

  /// Cloud topic repository.
  final TopicRepository topicRepo;

  /// Cloud material repository.
  final MaterialRepository materialRepo;

  /// Cloud circular repository.
  final CircularRepository circularRepo;

  /// Cloud exam date repository.
  final ExamDateRepository examDateRepo;

  /// Cloud study plan repository.
  final StudyPlanRepository studyPlanRepo;

  /// Cloud mock test repository.
  final MockTestRepository mockTestRepo;

  /// Cloud progress log repository.
  final ProgressLogRepository progressLogRepo;

  /// Cloud revision item repository.
  final RevisionItemRepository revisionItemRepo;

  /// Cloud study session repository.
  final StudySessionRepository studySessionRepo;

  /// Cloud portal account repository.
  final PortalAccountRepository portalAccountRepo;

  /// Cloud user settings repository.
  final UserSettingsRepository userSettingsRepo;
}
