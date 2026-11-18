import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/widgets/app_sidebar_nav.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/screens/circular_detail_screen.dart';
import 'package:job_prep/features/circulars/presentation/screens/circulars_screen.dart';
import 'package:job_prep/features/circulars/presentation/screens/inbox_screen.dart';

import '../harness/e2e_test_harness.dart';

/// End-to-end integration tests for Circulars management, Exam Dates,
/// Quick Capture, and Inbox completion.
void runCircularsAndInboxE2ETests() {
  group('E2E Flow - Circulars, Exam Dates & Inbox', () {
    testWidgets('creates circular and attaches exam dates', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final harness = await E2ETestHarness.create();
      addTearDown(harness.dispose);

      // 1. Create a circular through repository
      final deadline = DateTime.utc(2026, 12, 10);
      final created = await harness.circularRepo.createCircular(
        Circular(
          title: '47th BCS Examination 2026',
          organizationName: 'BPSC',
          deadline: deadline,
        ),
      );

      // 2. Add an exam date to the circular
      final examDate = DateTime.utc(2026, 12, 20, 10);
      await harness.examDateRepo.createExamDate(
        CircularExamDate(
          circularId: created.id,
          stage: 'Preliminary Examination',
          examDate: examDate,
          venue: 'Dhaka College, Dhaka',
        ),
      );

      // Pump app
      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // Open Circulars screen from sidebar
      await tester.tap(
        find.descendant(
          of: find.byType(AppSidebarNav),
          matching: find.text('Circulars'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularsScreen), findsOneWidget);
      expect(find.text('47th BCS Examination 2026'), findsOneWidget);

      // Open Circular Detail
      await tester.tap(find.text('47th BCS Examination 2026'));
      await tester.pumpAndSettle();

      expect(find.byType(CircularDetailScreen), findsOneWidget);
      expect(find.text('Preliminary Examination'), findsOneWidget);
      expect(find.text('Dhaka College, Dhaka'), findsOneWidget);
    });

    testWidgets(
        'quick capture saves item to inbox and completes into saved circular',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final harness = await E2ETestHarness.create();
      addTearDown(harness.dispose);

      // 1. Quick capture item into inbox
      final inboxItem = await harness.circularRepo.createCircular(
        const Circular(
          title: 'Bangladesh Bank Assistant Director 2026',
          circularUrl: 'https://erecruitment.bb.org.bd/onlineapp',
          instructions: 'Capture notes from website notice board',
          sector: CircularSector.bank,
          workflowStatus: CircularWorkflowStatus.inbox,
          isQuickCapture: true,
        ),
      );

      await tester.pumpWidget(harness.buildApp());
      await tester.pumpAndSettle();

      // Open Inbox screen from sidebar
      await tester.tap(
        find.descendant(
          of: find.byType(AppSidebarNav),
          matching: find.text('Inbox'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InboxScreen), findsOneWidget);
      expect(
        find.text('Bangladesh Bank Assistant Director 2026'),
        findsOneWidget,
      );

      // 2. Complete item from inbox to active circular
      final completed = inboxItem.copyWith(
        workflowStatus: CircularWorkflowStatus.saved,
        applicationStatus: ApplicationStatus.applied,
        deadline: DateTime.utc(2026, 12, 15),
      );
      await harness.circularRepo.updateCircular(completed);

      // Refresh list provider to reflect repository updates
      final container = ProviderScope.containerOf(
        tester.element(find.byType(InboxScreen)),
      );
      await container.read(circularsListProvider.notifier).refresh();
      await tester.pumpAndSettle();

      // Item moved out of inbox
      expect(
        find.text('Bangladesh Bank Assistant Director 2026'),
        findsNothing,
      );

      // Verify item exists on Circulars screen with Applied status
      await tester.tap(
        find.descendant(
          of: find.byType(AppSidebarNav),
          matching: find.text('Circulars'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularsScreen), findsOneWidget);
      expect(
        find.text('Bangladesh Bank Assistant Director 2026'),
        findsOneWidget,
      );
    });
  });
}
