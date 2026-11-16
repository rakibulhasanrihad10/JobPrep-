import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/mock_test_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_template_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_plan_providers.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_tab_switcher.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_material_and_log_repositories.dart';
import 'fake_mock_test_repository.dart';
import 'fake_prep_template_repository.dart';
import 'fake_revision_item_repository.dart';
import 'fake_study_plan_repository.dart';
import 'fake_subject_and_topic_repositories.dart';

class _EmptyCircularRepository implements CircularRepository {
  @override
  Future<Circular> createCircular(Circular circular) =>
      throw UnimplementedError();
  @override
  Future<void> deleteCircular(String id) async {}
  @override
  Future<Circular?> getCircularById(String id) async => null;
  @override
  Future<List<Circular>> getCirculars({CircularFilter? filter}) async =>
      const [];
  @override
  Future<Circular> updateCircular(Circular circular) =>
      throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSubjectRepository subjectRepo;
  late FakeChapterRepository chapterRepo;
  late FakeTopicRepository topicRepo;
  late FakeMaterialRepository materialRepo;
  late FakeProgressLogRepository logRepo;
  late FakeStudyPlanRepository planRepo;
  late FakeRevisionItemRepository revisionRepo;
  late FakeMockTestRepository mockRepo;
  late FakePrepTemplateRepository templateRepo;

  setUp(() {
    subjectRepo = FakeSubjectRepository();
    chapterRepo = FakeChapterRepository();
    topicRepo = FakeTopicRepository();
    materialRepo = FakeMaterialRepository();
    logRepo = FakeProgressLogRepository();
    planRepo = FakeStudyPlanRepository();
    revisionRepo = FakeRevisionItemRepository();
    mockRepo = FakeMockTestRepository();
    templateRepo = FakePrepTemplateRepository();
  });

  Future<void> pumpSyllabusScreen(
    WidgetTester tester, {
    Size viewport = const Size(1280, 900),
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({kReduceEffectsStorageKey: true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          subjectRepositoryProvider.overrideWithValue(subjectRepo),
          chapterRepositoryProvider.overrideWithValue(chapterRepo),
          topicRepositoryProvider.overrideWithValue(topicRepo),
          materialRepositoryProvider.overrideWithValue(materialRepo),
          progressLogRepositoryProvider.overrideWithValue(logRepo),
          studyPlanRepositoryProvider.overrideWithValue(planRepo),
          revisionItemRepositoryProvider.overrideWithValue(revisionRepo),
          mockTestRepositoryProvider.overrideWithValue(mockRepo),
          prepTemplateRepositoryProvider.overrideWithValue(templateRepo),
          circularRepositoryProvider
              .overrideWithValue(_EmptyCircularRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: PrepScreen(initialTab: PrepSectionTab.syllabus),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapping checkpoint stamps timestamp and updates progress ring',
      (tester) async {
    final subject = await subjectRepo.createSubject(
      const Subject(name: 'General Math'),
    );
    final chapter = await chapterRepo.createChapter(
      Chapter(subjectId: subject.id, title: 'Algebra'),
    );
    final topic = await topicRepo.createTopic(
      Topic(
        subjectId: subject.id,
        chapterId: chapter.id,
        title: 'Linear Equations',
      ),
    );

    await pumpSyllabusScreen(tester);

    // Initial state: 0% on syllabus ring
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('syllabus-progress-ring')),
        matching: find.text('0%'),
      ),
      findsOneWidget,
    );

    // Find and tap study checkbox for the topic
    final studyCheckbox = find.byKey(ValueKey('topic-${topic.id}-study'));
    expect(studyCheckbox, findsOneWidget);
    await tester.tap(studyCheckbox);
    await tester.pumpAndSettle();

    // Progress ring should now show 40% (study checkpoint weight = 40/100)
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('syllabus-progress-ring')),
        matching: find.text('40%'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('bulk chapter mark-all-done marks all topics inside chapter',
      (tester) async {
    final subject = await subjectRepo.createSubject(
      const Subject(name: 'Physics'),
    );
    final chapter = await chapterRepo.createChapter(
      Chapter(subjectId: subject.id, title: 'Mechanics'),
    );
    await topicRepo.createTopic(
      Topic(
        subjectId: subject.id,
        chapterId: chapter.id,
        title: 'Newtonian Motion',
      ),
    );
    await topicRepo.createTopic(
      Topic(
        subjectId: subject.id,
        chapterId: chapter.id,
        title: 'Work & Energy',
      ),
    );

    await pumpSyllabusScreen(tester);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('syllabus-progress-ring')),
        matching: find.text('0%'),
      ),
      findsOneWidget,
    );

    // Open chapter menu
    final menuBtn = find.byKey(ValueKey('chapter-menu-${chapter.id}'));
    expect(menuBtn, findsOneWidget);
    await tester.tap(menuBtn);
    await tester.pumpAndSettle();

    // Tap "Mark all Study done"
    final markStudy = find.text('Mark all Study done');
    expect(markStudy, findsOneWidget);
    await tester.tap(markStudy);
    await tester.pumpAndSettle();

    // Both topics marked study done -> 40%
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('syllabus-progress-ring')),
        matching: find.text('40%'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('quick add pasted outline creates chapters and topics',
      (tester) async {
    await subjectRepo.createSubject(
      const Subject(name: 'English Grammar'),
    );

    await pumpSyllabusScreen(tester);

    // Tap quick add button
    final quickAddBtn =
        find.byKey(const ValueKey('syllabus-quick-add-outline-btn'));
    expect(quickAddBtn, findsOneWidget);
    await tester.tap(quickAddBtn);
    await tester.pumpAndSettle();

    // Enter multi-line outline
    const outlineText = '''
Chapter 1: Tenses
- Present Simple
- Past Continuous

Chapter 2: Voice
- Active to Passive
''';
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    await tester.enterText(textField, outlineText);
    await tester.pumpAndSettle();

    // Preview should display 2 chapters, 3 topics
    expect(find.text('Preview: 2 chapter(s), 3 topic(s)'), findsOneWidget);

    // Tap Import
    final importBtn = find.text('Import Outline');
    await tester.tap(importBtn);
    await tester.pumpAndSettle();

    // Verify created chapters appear on screen
    expect(find.text('Chapter 1: Tenses'), findsOneWidget);
    expect(find.text('Chapter 2: Voice'), findsOneWidget);
    expect(find.text('Present Simple'), findsOneWidget);
  });

  testWidgets('deleting chapter confirms and removes chapter and topics',
      (tester) async {
    final subject = await subjectRepo.createSubject(
      const Subject(name: 'Chemistry'),
    );
    final chapter = await chapterRepo.createChapter(
      Chapter(subjectId: subject.id, title: 'Organic Chemistry'),
    );
    await topicRepo.createTopic(
      Topic(
        subjectId: subject.id,
        chapterId: chapter.id,
        title: 'Hydrocarbons',
      ),
    );

    await pumpSyllabusScreen(tester);
    expect(find.text('Organic Chemistry'), findsOneWidget);

    // Open chapter menu and choose delete
    await tester.tap(find.byKey(ValueKey('chapter-menu-${chapter.id}')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete Chapter'));
    await tester.pumpAndSettle();

    // Confirmation dialog appears
    expect(
      find.text(
        'Are you sure you want to delete chapter "Organic Chemistry"? '
        'All 1 topic(s) inside will be lost.',
      ),
      findsOneWidget,
    );

    // Tap delete in dialog
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Chapter is gone, empty state shown
    expect(find.text('Organic Chemistry'), findsNothing);
    expect(find.text('No Chapters Yet'), findsOneWidget);
  });

  testWidgets('configuring subject checkpoints updates tracked checkboxes',
      (tester) async {
    final subject = await subjectRepo.createSubject(
      const Subject(name: 'Bangla'),
    );
    final chapter = await chapterRepo.createChapter(
      Chapter(subjectId: subject.id, title: 'Grammar'),
    );
    final topic = await topicRepo.createTopic(
      Topic(subjectId: subject.id, chapterId: chapter.id, title: 'Sandhi'),
    );

    await pumpSyllabusScreen(tester);

    // All 4 checkboxes initially visible for topic
    expect(find.byKey(ValueKey('topic-${topic.id}-study')), findsOneWidget);
    expect(find.byKey(ValueKey('topic-${topic.id}-practice')), findsOneWidget);
    expect(
      find.byKey(ValueKey('topic-${topic.id}-model_test')),
      findsOneWidget,
    );
    expect(find.byKey(ValueKey('topic-${topic.id}-revision')), findsOneWidget);

    // Tap configure checkpoints button
    await tester
        .tap(find.byKey(const ValueKey('syllabus-configure-checkpoints-btn')));
    await tester.pumpAndSettle();

    // Uncheck revision and model test
    await tester.tap(find.byKey(const ValueKey('checkpoint-config-revision')));
    await tester
        .tap(find.byKey(const ValueKey('checkpoint-config-model_test')));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Now only study and practice are visible
    expect(find.byKey(ValueKey('topic-${topic.id}-study')), findsOneWidget);
    expect(find.byKey(ValueKey('topic-${topic.id}-practice')), findsOneWidget);
    expect(find.byKey(ValueKey('topic-${topic.id}-model_test')), findsNothing);
    expect(find.byKey(ValueKey('topic-${topic.id}-revision')), findsNothing);
  });
}
