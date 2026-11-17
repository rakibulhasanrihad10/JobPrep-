import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/features/prep/domain/entities/mock_test.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/mock_test_post_save_helper.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_revision_item_repository.dart';
import 'fake_subject_and_topic_repositories.dart';
import 'fake_topic_links_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final testDate = DateTime.utc(2026, 11, 12, 10);

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  Widget buildTestApp({
    required Widget child,
    required SharedPreferences prefs,
    required FakeMockTestTopicRepository mockTopicRepo,
    required FakeTopicRepository topicRepo,
    required FakeRevisionItemRepository revisionRepo,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        mockTestTopicRepositoryProvider.overrideWithValue(mockTopicRepo),
        topicRepositoryProvider.overrideWithValue(topicRepo),
        revisionItemRepositoryProvider.overrideWithValue(revisionRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('auto-marks model test checkpoint when pref is true',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      MockTestPostSaveHelper.autoMarkCheckpointPrefKey: true,
    });
    final prefs = await SharedPreferences.getInstance();

    final topic = Topic(
      id: 't1',
      subjectId: 's1',
      title: 'Grammar',
      studyDoneAt: DateTime.utc(2026, 11, 10),
    );

    final mockTopicRepo = FakeMockTestTopicRepository();
    final topicRepo = FakeTopicRepository(initialTopics: [topic]);
    final revisionRepo = FakeRevisionItemRepository();

    final testItem = MockTest(
      id: 'm1',
      subjectId: 's1',
      title: 'BCS Model 1',
      takenOn: testDate,
      marksObtained: 80,
      totalMarks: 100,
    );

    await tester.pumpWidget(
      buildTestApp(
        prefs: prefs,
        mockTopicRepo: mockTopicRepo,
        topicRepo: topicRepo,
        revisionRepo: revisionRepo,
        child: Consumer(
          builder: (context, ref, _) {
            return ElevatedButton(
              onPressed: () {
                unawaited(
                  MockTestPostSaveHelper.handlePostSaveAutomations(
                    context,
                    ref,
                    test: testItem,
                    linkedTopicIds: const ['t1'],
                    weakTopics: const [],
                  ),
                );
              },
              child: const Text('Trigger'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();

    // Verify topic links persisted
    final linked = await mockTopicRepo.getTopicsForMockTest('m1');
    expect(linked.length, 1);
    expect(linked.first.topicId, 't1');

    // Verify model test checkpoint marked automatically
    final updatedTopics = await topicRepo.getTopicsForSubject('s1');
    expect(updatedTopics.first.modelTestDoneAt, testDate);
  });

  testWidgets(
      'offers checkpoint dialog when pref is false and marks upon confirm',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      MockTestPostSaveHelper.autoMarkCheckpointPrefKey: false,
    });
    final prefs = await SharedPreferences.getInstance();

    final topic = Topic(
      id: 't2',
      subjectId: 's1',
      title: 'Literature',
      studyDoneAt: DateTime.utc(2026, 11, 10),
    );

    final mockTopicRepo = FakeMockTestTopicRepository();
    final topicRepo = FakeTopicRepository(initialTopics: [topic]);
    final revisionRepo = FakeRevisionItemRepository();

    final testItem = MockTest(
      id: 'm2',
      subjectId: 's1',
      title: 'BCS Model 2',
      takenOn: testDate,
      marksObtained: 75,
      totalMarks: 100,
    );

    await tester.pumpWidget(
      buildTestApp(
        prefs: prefs,
        mockTopicRepo: mockTopicRepo,
        topicRepo: topicRepo,
        revisionRepo: revisionRepo,
        child: Consumer(
          builder: (context, ref, _) {
            return ElevatedButton(
              onPressed: () {
                unawaited(
                  MockTestPostSaveHelper.handlePostSaveAutomations(
                    context,
                    ref,
                    test: testItem,
                    linkedTopicIds: const ['t2'],
                    weakTopics: const [],
                  ),
                );
              },
              child: const Text('Trigger'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();

    // Dialog appears
    expect(
      find.byKey(const ValueKey('confirm-model-test-checkpoint-dialog')),
      findsOneWidget,
    );

    // Tap Yes
    await tester.tap(find.byKey(const ValueKey('mark-checkpoint-yes-btn')));
    await tester.pumpAndSettle();

    // Checkpoint marked
    final updatedTopics = await topicRepo.getTopicsForSubject('s1');
    expect(updatedTopics.first.modelTestDoneAt, testDate);
  });

  testWidgets(
      'offers revision dialog for weak topics and adds them upon confirm',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      MockTestPostSaveHelper.autoMarkCheckpointPrefKey: true,
    });
    final prefs = await SharedPreferences.getInstance();

    const topic = Topic(
      id: 't3',
      subjectId: 's1',
      title: 'Synonyms',
    );

    final mockTopicRepo = FakeMockTestTopicRepository();
    final topicRepo = FakeTopicRepository(initialTopics: const [topic]);
    final revisionRepo = FakeRevisionItemRepository();

    final testItem = MockTest(
      id: 'm3',
      subjectId: 's1',
      title: 'BCS Model 3',
      takenOn: testDate,
      marksObtained: 70,
      totalMarks: 100,
    );

    await tester.pumpWidget(
      buildTestApp(
        prefs: prefs,
        mockTopicRepo: mockTopicRepo,
        topicRepo: topicRepo,
        revisionRepo: revisionRepo,
        child: Consumer(
          builder: (context, ref, _) {
            return ElevatedButton(
              onPressed: () {
                unawaited(
                  MockTestPostSaveHelper.handlePostSaveAutomations(
                    context,
                    ref,
                    test: testItem,
                    linkedTopicIds: const [],
                    weakTopics: const [topic],
                  ),
                );
              },
              child: const Text('Trigger'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();

    // Dialog appears
    expect(
      find.byKey(const ValueKey('confirm-add-to-revision-dialog')),
      findsOneWidget,
    );
    expect(find.text('Synonyms'), findsOneWidget);

    // Confirm adding to revision
    await tester.tap(find.byKey(const ValueKey('add-revision-yes-btn')));
    await tester.pumpAndSettle();

    // Revision item created
    final items = revisionRepo.items;
    expect(items.length, 1);
    expect(items.first.topicId, 't3');
    expect(items.first.source, RevisionSource.mockTest);
    expect(items.first.reason, RevisionReason.mistake);
  });
}
