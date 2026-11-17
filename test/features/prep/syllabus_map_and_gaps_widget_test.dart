import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/features/prep/domain/entities/chapter.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/syllabus_map_view.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/topic_detail_sheet.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_subject_and_topic_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime.utc(2026, 11, 10);

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('bn');
  });

  const subject = Subject(
    id: 'sub-1',
    name: 'General Science',
  );

  const chapter1 = Chapter(
    id: 'ch-1',
    subjectId: 'sub-1',
    title: 'Physics',
  );

  const chapter2 = Chapter(
    id: 'ch-2',
    subjectId: 'sub-1',
    title: 'Chemistry',
    sortOrder: 1,
  );

  final topic1 = Topic(
    id: 'top-1',
    subjectId: 'sub-1',
    chapterId: 'ch-1',
    title: 'Mechanics',
    studyDoneAt: now,
  );

  final topic2 = Topic(
    id: 'top-2',
    subjectId: 'sub-1',
    chapterId: 'ch-1',
    title: 'Optics',
    studyDoneAt: now,
    practiceDoneAt: now,
    modelTestDoneAt: now,
    revisionDoneAt: now, // Fully completed
  );

  const topic3 = Topic(
    id: 'top-3',
    subjectId: 'sub-1',
    chapterId: 'ch-2',
    title: 'Acids & Bases',
    // Unstarted
  );

  Widget buildHarness({
    required List<Topic> topics,
    required FakeTopicRepository topicRepo,
    required SharedPreferences prefs,
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        topicRepositoryProvider.overrideWithValue(topicRepo),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SyllabusMapView(
              subject: subject,
              chapters: const [chapter1, chapter2],
              topics: topics,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders topic grid, chapter table, and gaps list',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final topicRepo =
        FakeTopicRepository(initialTopics: [topic1, topic2, topic3]);

    await tester.pumpWidget(
      buildHarness(
        topics: [topic1, topic2, topic3],
        topicRepo: topicRepo,
        prefs: prefs,
      ),
    );
    await tester.pumpAndSettle();

    // Verify grid, table, and gaps list cards are displayed
    expect(
      find.byKey(const ValueKey('syllabus-topic-grid-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('syllabus-chapter-table-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('syllabus-gaps-list-card')),
      findsOneWidget,
    );

    // Verify topics in grid
    expect(find.text('Mechanics'), findsAtLeastNWidgets(1));
    expect(find.text('Optics'), findsAtLeastNWidgets(1));
    expect(find.text('Acids & Bases'), findsAtLeastNWidgets(1));

    // Verify chapter table shows chapter titles
    expect(find.text('Physics'), findsOneWidget);
    expect(find.text('Chemistry'), findsOneWidget);

    // Verify gap item appears for Mechanics
    expect(find.byKey(const ValueKey('gap-topic-top-1')), findsOneWidget);
  });

  testWidgets('tapping topic in grid or gaps opens topic detail sheet',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final topicRepo =
        FakeTopicRepository(initialTopics: [topic1, topic2, topic3]);

    await tester.pumpWidget(
      buildHarness(
        topics: [topic1, topic2, topic3],
        topicRepo: topicRepo,
        prefs: prefs,
      ),
    );
    await tester.pumpAndSettle();

    // Tap the gap item for Mechanics
    await tester.tap(find.byKey(const ValueKey('gap-topic-top-1')));
    await tester.pumpAndSettle();

    // Verify detail sheet opened
    expect(find.byType(TopicDetailSheet), findsOneWidget);
  });

  testWidgets('displays empty state when no topics have gaps', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final topicRepo = FakeTopicRepository(initialTopics: [topic2]);

    await tester.pumpWidget(
      buildHarness(
        topics: [topic2],
        topicRepo: topicRepo,
        prefs: prefs,
      ),
    );
    await tester.pumpAndSettle();

    // Empty state should be rendered in gaps list
    expect(find.byKey(const ValueKey('gap-topic-top-1')), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
  });
}
