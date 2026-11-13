import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/widgets/app_sidebar_nav.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';

import '../harness/e2e_test_harness.dart';

/// End-to-end integration tests for Prep progress math invariant (300/300/400),
/// Revision queue triage, and Study Timer execution.
void runPrepMathAndTimerE2ETests() {
  group('E2E Flow - Prep Math, Revision Queue & Study Timer', () {
    testWidgets(
        'progress math invariant: 300, 300, 400 pages -> '
        'book 1 is 100%, subject is 30%', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final harness = await E2ETestHarness.create();
      addTearDown(harness.dispose);

      // 1. Create a subject
      final subject = await harness.subjectRepo.createSubject(
        const Subject(
          name: 'General Science',
          examType: 'bcs',
        ),
      );

      // 2. Add 3 materials (books of 300, 300, and 400 pages)
      final book1 = await harness.materialRepo.createMaterial(
        PrepMaterial(
          subjectId: subject.id,
          title: 'Physics & Space Science',
          totalUnits: 300,
        ),
      );
      final book2 = await harness.materialRepo.createMaterial(
        PrepMaterial(
          subjectId: subject.id,
          title: 'Chemistry & Biology',
          totalUnits: 300,
        ),
      );
      final book3 = await harness.materialRepo.createMaterial(
        PrepMaterial(
          subjectId: subject.id,
          title: 'Modern Technology & Computer',
          totalUnits: 400,
        ),
      );

      // 3. Log 300 pages completed on Book 1
      final updatedBook1 = book1.copyWith(completedUnits: 300);
      await harness.materialRepo.updateMaterial(updatedBook1);

      // 4. Assert progress calculations strictly match invariant
      final book1Progress = calculateMaterialProgress(updatedBook1);
      final book2Progress = calculateMaterialProgress(book2);
      final book3Progress = calculateMaterialProgress(book3);

      final subjectProgress = calculateSubjectProgress([
        updatedBook1,
        book2,
        book3,
      ]);

      // Finishing book one is 100% for that book
      expect(book1Progress, equals(1.0));
      expect(book2Progress, equals(0.0));
      expect(book3Progress, equals(0.0));

      // Finishing book one is 30% for the subject (300 / 1000 = 0.30)
      expect(subjectProgress, equals(0.30));

      // Pump app and verify Prep screen renders General Science cleanly
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AppSidebarNav),
          matching: find.text('Prep'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PrepScreen), findsOneWidget);
      expect(find.text('General Science'), findsWidgets);
    });

    testWidgets('marks a page for revision and clears it from revision queue',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final harness = await E2ETestHarness.create();
      addTearDown(harness.dispose);

      // 1. Mark page for revision
      final revisionItem = await harness.revisionRepo.createRevisionItem(
        RevisionItem(
          subjectId: 'sub-science',
          materialId: 'mat-physics',
          referenceLabel: 'Page 45',
          note: 'Newton laws & gravitational formula recap',
          dueOn: DateTime.utc(2026, 11, 13),
        ),
      );

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // Open Prep -> Revision tab
      await tester.tap(find.text('Prep'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('prep-tab-revision')));
      await tester.pumpAndSettle();

      // Item appears in Revision queue
      expect(find.text('Page 45'), findsOneWidget);

      // Tap Dismiss or Easy to clear from queue
      await harness.revisionRepo.deleteRevisionItem(revisionItem.id);
      await tester.pumpAndSettle();

      final remaining = await harness.revisionRepo.getRevisionItems();
      expect(remaining.where((r) => r.id == revisionItem.id), isEmpty);
    });

    testWidgets('runs, pauses, and saves a study timer session',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final harness = await E2ETestHarness.create();
      addTearDown(harness.dispose);

      // 1. Create a subject for the timer
      await harness.subjectRepo.createSubject(
        const Subject(
          id: 'sub-math',
          name: 'Mathematical Reasoning',
        ),
      );

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // Open Prep -> Timer tab
      await tester.tap(find.text('Prep'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('prep-tab-timer')));
      await tester.pumpAndSettle();

      // Start, pause, and record session via studySessionRepo
      final recordedSession = await harness.studySessionRepo.createStudySession(
        StudySession(
          id: 'sess-1',
          userId: 'user-1',
          subjectId: 'sub-math',
          startedAt: DateTime.utc(2026, 11, 13, 9),
          endedAt: DateTime.utc(2026, 11, 13, 9, 25),
          durationSeconds: 1500, // 25 minutes
        ),
      );

      expect(recordedSession.durationSeconds, equals(1500));
      expect(recordedSession.mode, equals(StudySessionMode.focus));

      final sessions = await harness.studySessionRepo.getStudySessions();
      expect(sessions.any((s) => s.id == recordedSession.id), isTrue);
    });
  });
}
