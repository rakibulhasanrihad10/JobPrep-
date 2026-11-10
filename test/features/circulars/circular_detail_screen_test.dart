import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme.dart';
import 'package:job_prep/core/theme/reduce_effects_controller.dart';
import 'package:job_prep/core/theme/theme_controller.dart';
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/url_launcher_provider.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_view.dart';
import 'package:job_prep/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_circular_repository.dart';
import 'fake_exam_date_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Circular sampleDetailCircular() {
    return Circular(
      id: 'c-detail',
      userId: 'u-1',
      title: '47th BCS General Cadre',
      sector: CircularSector.bcs,
      organizationName: 'Bangladesh Public Service Commission',
      organizationWebsite: 'https://bpsc.gov.bd',
      circularUrl: 'https://bpsc.gov.bd/notices/47',
      applicationUrl: 'https://bpsc.teletalk.com.bd',
      deadline: DateTime.utc(2026, 11, 15, 17), // 5 days -> amber
      vacancies: 1250,
      salaryMin: 22000,
      salaryMax: 53060,
      salaryNote: 'Grade 9 National Pay Scale',
      applicationFee: 700,
      feeNote: 'Payable via Teletalk SMS',
      applicationStatus: ApplicationStatus.inProgress,
      priority: CircularPriority.urgent,
      workflowStatus: CircularWorkflowStatus.preparing,
      instructions: 'Upload 300x300 photo and signature.',
      notes: 'Revise Constitution articles.',
      syllabus: 'Bangla, English, Bangladesh & International Affairs',
      isQuickCapture: true,
      checklist: const ApplicationChecklist(photo: true),
      createdAt: DateTime.utc(2026, 11, 1, 9),
      updatedAt: DateTime.utc(2026, 11, 9, 14),
    );
  }

  Future<List<Uri>> pumpDetailView(
    WidgetTester tester, {
    required FakeCircularRepository circularRepo,
    required FakeExamDateRepository examRepo,
    String circularId = 'c-detail',
    ThemeMode themeMode = ThemeMode.dark,
    String languageCode = 'en',
  }) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await prefs.setBool(kReduceEffectsStorageKey, true);
    await prefs.setString(kLocaleStorageKey, languageCode);

    final launchedUris = <Uri>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          circularRepositoryProvider.overrideWithValue(circularRepo),
          examDateRepositoryProvider.overrideWithValue(examRepo),
          circularNowProvider.overrideWithValue(() => fixedNow),
          circularUrlLauncherProvider.overrideWithValue((uri) async {
            launchedUris.add(uri);
            return true;
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          locale: Locale(languageCode),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: CircularDetailView(circularId: circularId),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return launchedUris;
  }

  group('CircularDetailView Sections & Actions', () {
    testWidgets(
        'renders all sections, countdown, tappable links, quick status, and '
        '5-step checklist', (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: [sampleDetailCircular()],
        clock: () => fixedNow,
      );
      final examRepo = FakeExamDateRepository(clock: () => fixedNow);

      final launched = await pumpDetailView(
        tester,
        circularRepo: circularRepo,
        examRepo: examRepo,
      );

      // All sections present with expected fields
      expect(
        find.byKey(const ValueKey('circular-detail-header-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('circular-detail-quick-actions-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('circular-detail-links-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('circular-detail-overview-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('circular-detail-exam-dates-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('circular-detail-notes-card')),
        findsOneWidget,
      );

      expect(find.text('47th BCS General Cadre'), findsOneWidget);
      expect(find.text('5 days left'), findsOneWidget);
      expect(find.text('Grade 9 National Pay Scale'), findsOneWidget);
      expect(find.text('Payable via Teletalk SMS'), findsOneWidget);
      expect(
        find.text('Upload 300x300 photo and signature.'),
        findsOneWidget,
      );
      expect(find.text('Revise Constitution articles.'), findsOneWidget);
      expect(
        find.text('Bangla, English, Bangladesh & International Affairs'),
        findsOneWidget,
      );

      // Tap all 3 external link buttons
      for (final keyStr in [
        'detail-open-circular-url',
        'detail-open-application-url',
        'detail-open-org-website',
      ]) {
        final btn = find.byKey(ValueKey(keyStr));
        await tester.ensureVisible(btn);
        await tester.tap(btn);
        await tester.pumpAndSettle();
      }
      expect(
        launched.map((u) => u.toString()).toList(),
        equals([
          'https://bpsc.gov.bd/notices/47',
          'https://bpsc.teletalk.com.bd',
          'https://bpsc.gov.bd',
        ]),
      );

      // Quick action: change Workflow Status to Applied
      final workflowDropdown = find.descendant(
        of: find.byKey(const ValueKey('detail-quick-workflow-status')),
        matching: find.byType(DropdownButton<CircularWorkflowStatus>),
      );
      await tester.ensureVisible(workflowDropdown);
      await tester.tap(workflowDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Applied').last);
      await tester.pumpAndSettle();
      expect(
        circularRepo.items.single.workflowStatus,
        equals(CircularWorkflowStatus.applied),
      );

      // Application checklist: initially 1 of 5 done -> tick remaining 4
      expect(find.text('1 of 5 done'), findsOneWidget);
      for (final item in const [
        ApplicationChecklistItem.certificates,
        ApplicationChecklistItem.feePaid,
        ApplicationChecklistItem.submitted,
        ApplicationChecklistItem.admitCardDownloaded,
      ]) {
        final row = find.byKey(ValueKey('checklist-item-${item.name}'));
        await tester.ensureVisible(row);
        await tester.tap(row);
        await tester.pumpAndSettle();
      }
      expect(find.text('5 of 5 done'), findsOneWidget);
      expect(circularRepo.items.single.checklist.completedCount, equals(5));
    });

    testWidgets('exam date add, edit, and delete manage circular_exam_dates',
        (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: [sampleDetailCircular()],
        clock: () => fixedNow,
      );
      final examRepo = FakeExamDateRepository(
        initialItems: [
          CircularExamDate(
            id: 'ed-pre',
            circularId: 'c-detail',
            userId: 'u-1',
            stage: 'preliminary',
            examDate: DateTime.utc(2026, 11, 20, 10),
            venue: 'Dhaka College',
          ),
          CircularExamDate(
            id: 'ed-past',
            circularId: 'c-detail',
            userId: 'u-1',
            stage: 'other',
            examDate: DateTime.utc(2026, 11, 1, 9),
            venue: 'Old Seminar',
          ),
        ],
        clock: () => fixedNow,
      );

      await pumpDetailView(
        tester,
        circularRepo: circularRepo,
        examRepo: examRepo,
        themeMode: ThemeMode.light,
      );

      // Upcoming & past headings displayed cleanly
      expect(
        find.byKey(const ValueKey('exam-date-upcoming-list')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('exam-date-past-list')), findsOneWidget);
      expect(find.text('Dhaka College'), findsOneWidget);

      // ADD a new exam date (Written)
      final addBtn = find.byKey(const ValueKey('detail-add-exam-date-btn'));
      await tester.ensureVisible(addBtn);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('exam-date-dialog')), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('exam-date-stage-field')),
          matching: find.byType(DropdownButton<ExamStage>),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Written').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('exam-date-venue-field')),
        'BUET Auditorium',
      );
      await tester.enterText(
        find.byKey(const ValueKey('exam-date-notes-field')),
        'Bring admit card',
      );
      await tester.tap(find.byKey(const ValueKey('exam-date-save-btn')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('exam-date-dialog')), findsNothing);
      expect(examRepo.createdItems, hasLength(1));
      expect(examRepo.createdItems.single.stage, equals('written'));
      expect(examRepo.createdItems.single.venue, equals('BUET Auditorium'));
      expect(find.text('BUET Auditorium'), findsOneWidget);
      expect(find.text('Bring admit card'), findsOneWidget);

      // EDIT existing Preliminary exam date -> change stage to Viva & venue
      final editBtn = find.byKey(const ValueKey('exam-date-edit-ed-pre'));
      await tester.ensureVisible(editBtn);
      await tester.tap(editBtn);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('exam-date-stage-field')),
          matching: find.byType(DropdownButton<ExamStage>),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Viva').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('exam-date-venue-field')),
        'BPSC Headquarters',
      );
      await tester.tap(find.byKey(const ValueKey('exam-date-save-btn')));
      await tester.pumpAndSettle();

      expect(examRepo.updatedItems, hasLength(1));
      expect(examRepo.updatedItems.single.stage, equals('viva'));
      expect(find.text('BPSC Headquarters'), findsOneWidget);

      // DELETE past exam date
      final deleteBtn = find.byKey(const ValueKey('exam-date-delete-ed-past'));
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(examRepo.deletedIds, equals(['ed-past']));
      expect(
        find.byKey(const ValueKey('exam-date-card-ed-past')),
        findsNothing,
      );
    });

    testWidgets('renders detail sections accurately in Bangla', (tester) async {
      final circularRepo = FakeCircularRepository(
        initialItems: [sampleDetailCircular()],
        clock: () => fixedNow,
      );
      final examRepo = FakeExamDateRepository(clock: () => fixedNow);

      await pumpDetailView(
        tester,
        circularRepo: circularRepo,
        examRepo: examRepo,
        languageCode: 'bn',
      );

      expect(find.text('দ্রুত অবস্থা ও চেকলিস্ট'), findsOneWidget);
      expect(find.text('অফিসিয়াল লিংক'), findsOneWidget);
      expect(find.text('সারসংক্ষেপ ও বেতন-ভাতা'), findsOneWidget);
      expect(find.text('পরীক্ষার তারিখ'), findsOneWidget);
      expect(find.text('৫টির মধ্যে ১টি সম্পন্ন'), findsOneWidget);
    });
  });
}
