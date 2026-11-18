import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/topic_detail_sheet.dart';
import 'package:job_prep/features/today/presentation/providers/today_next_topics_provider.dart';
import 'package:job_prep/features/today/presentation/widgets/today_next_topics_card.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../prep/fake_subject_and_topic_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  const subject = Subject(
    id: 'sub-1',
    name: 'English Grammar',
  );

  const topic1 = Topic(
    id: 'top-1',
    subjectId: 'sub-1',
    title: 'Parts of Speech',
  );

  const topic2 = Topic(
    id: 'top-2',
    subjectId: 'sub-1',
    title: 'Tenses',
    sortOrder: 1,
  );

  Widget buildHarness({
    required AsyncValue<List<NextTopicItem>> nextTopicsValue,
    required FakeTopicRepository topicRepo,
    required SharedPreferences prefs,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        topicRepositoryProvider.overrideWithValue(topicRepo),
        todayNextTopicsProvider.overrideWithValue(nextTopicsValue),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: TodayNextTopicsCard(),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'renders next topics card with up to 3 incomplete topics',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final topicRepo = FakeTopicRepository(initialTopics: [topic1, topic2]);

      final items = [
        const NextTopicItem(
          topic: topic1,
          subject: subject,
          progress: 0.40,
          enabledCheckpoints: ['study', 'practice', 'model_test', 'revision'],
        ),
        const NextTopicItem(
          topic: topic2,
          subject: subject,
          progress: 0,
          enabledCheckpoints: ['study', 'practice', 'model_test', 'revision'],
        ),
      ];

      await tester.pumpWidget(
        buildHarness(
          nextTopicsValue: AsyncData(items),
          topicRepo: topicRepo,
          prefs: prefs,
        ),
      );
      await tester.pumpAndSettle();

      // Verify card rendered
      expect(
        find.byKey(const ValueKey('today-next-topics-card')),
        findsOneWidget,
      );
      expect(find.text('Parts of Speech'), findsOneWidget);
      expect(find.text('Tenses'), findsOneWidget);
      expect(find.text('English Grammar'), findsNWidgets(2));
    },
  );

  testWidgets('tapping a topic in next topics card opens detail sheet', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final topicRepo = FakeTopicRepository(initialTopics: [topic1]);

    final items = [
      const NextTopicItem(
        topic: topic1,
        subject: subject,
        progress: 0.40,
        enabledCheckpoints: ['study', 'practice', 'model_test', 'revision'],
      ),
    ];

    await tester.pumpWidget(
      buildHarness(
        nextTopicsValue: AsyncData(items),
        topicRepo: topicRepo,
        prefs: prefs,
      ),
    );
    await tester.pumpAndSettle();

    // Tap on topic
    await tester.tap(find.text('Parts of Speech'));
    await tester.pumpAndSettle();

    // Detail sheet opens
    expect(find.byType(TopicDetailSheet), findsOneWidget);
  });

  testWidgets('hides card when items list is empty', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final topicRepo = FakeTopicRepository();

    await tester.pumpWidget(
      buildHarness(
        nextTopicsValue: const AsyncData([]),
        topicRepo: topicRepo,
        prefs: prefs,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('today-next-topics-card')), findsNothing);
  });
}
