import 'package:job_prep/features/migration/domain/repositories/cloud_repositories.dart';
import '../circulars/fake_circular_repository.dart';
import '../circulars/fake_exam_date_repository.dart';
import '../prep/fake_material_and_log_repositories.dart';
import '../prep/fake_mock_test_repository.dart';
import '../prep/fake_revision_item_repository.dart';
import '../prep/fake_study_plan_repository.dart';
import '../prep/fake_study_session_repository.dart';
import '../prep/fake_subject_and_topic_repositories.dart';
import '../settings/fake_user_settings_repository.dart';
import '../vault/fake_portal_account_repository.dart';

/// Helper creating an in-memory [CloudRepositories] bundle backed by fakes.
class FakeCloudRepositoriesBundle {
  FakeCloudRepositoriesBundle({
    FakeSubjectRepository? subjectRepo,
    FakeChapterRepository? chapterRepo,
    FakeTopicRepository? topicRepo,
    FakeMaterialRepository? materialRepo,
    FakeProgressLogRepository? progressLogRepo,
    FakeCircularRepository? circularRepo,
    FakeExamDateRepository? examDateRepo,
    FakeStudyPlanRepository? studyPlanRepo,
    FakeMockTestRepository? mockTestRepo,
    FakeRevisionItemRepository? revisionItemRepo,
    FakeStudySessionRepository? studySessionRepo,
    FakePortalAccountRepository? portalAccountRepo,
    FakeUserSettingsRepository? userSettingsRepo,
  })  : subjectRepo = subjectRepo ?? FakeSubjectRepository(),
        chapterRepo = chapterRepo ?? FakeChapterRepository(),
        topicRepo = topicRepo ?? FakeTopicRepository(),
        materialRepo = materialRepo ?? FakeMaterialRepository(),
        progressLogRepo = progressLogRepo ?? FakeProgressLogRepository(),
        circularRepo = circularRepo ?? FakeCircularRepository(),
        examDateRepo = examDateRepo ?? FakeExamDateRepository(),
        studyPlanRepo = studyPlanRepo ?? FakeStudyPlanRepository(),
        mockTestRepo = mockTestRepo ?? FakeMockTestRepository(),
        revisionItemRepo = revisionItemRepo ?? FakeRevisionItemRepository(),
        studySessionRepo = studySessionRepo ?? FakeStudySessionRepository(),
        portalAccountRepo = portalAccountRepo ?? FakePortalAccountRepository(),
        userSettingsRepo = userSettingsRepo ?? FakeUserSettingsRepository();

  final FakeSubjectRepository subjectRepo;
  final FakeChapterRepository chapterRepo;
  final FakeTopicRepository topicRepo;
  final FakeMaterialRepository materialRepo;
  final FakeProgressLogRepository progressLogRepo;
  final FakeCircularRepository circularRepo;
  final FakeExamDateRepository examDateRepo;
  final FakeStudyPlanRepository studyPlanRepo;
  final FakeMockTestRepository mockTestRepo;
  final FakeRevisionItemRepository revisionItemRepo;
  final FakeStudySessionRepository studySessionRepo;
  final FakePortalAccountRepository portalAccountRepo;
  final FakeUserSettingsRepository userSettingsRepo;

  CloudRepositories toCloudRepositories() {
    return CloudRepositories(
      subjectRepo: subjectRepo,
      chapterRepo: chapterRepo,
      topicRepo: topicRepo,
      materialRepo: materialRepo,
      circularRepo: circularRepo,
      examDateRepo: examDateRepo,
      studyPlanRepo: studyPlanRepo,
      mockTestRepo: mockTestRepo,
      progressLogRepo: progressLogRepo,
      revisionItemRepo: revisionItemRepo,
      studySessionRepo: studySessionRepo,
      portalAccountRepo: portalAccountRepo,
      userSettingsRepo: userSettingsRepo,
    );
  }
}
