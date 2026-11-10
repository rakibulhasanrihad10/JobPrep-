import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_mapper.dart';
import 'package:job_prep/features/circulars/domain/entities/application_checklist.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/utils/exam_date_sorter.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_detail_controller.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/exam_date_providers.dart';

import 'fake_circular_repository.dart';
import 'fake_exam_date_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);

  group('ApplicationChecklist & Mapper Round-Trip', () {
    test('tracks completion counts, toggling, and mapper serialization', () {
      const initial = ApplicationChecklist();
      expect(initial.completedCount, equals(0));
      expect(initial.progress, equals(0.0));

      final updated = initial
          .toggle(ApplicationChecklistItem.photo)
          .toggle(ApplicationChecklistItem.certificates)
          .setItem(ApplicationChecklistItem.feePaid, checked: true);
      expect(updated.completedCount, equals(3));
      expect(updated.progress, equals(0.6));
      expect(updated.isChecked(ApplicationChecklistItem.photo), isTrue);
      expect(updated.isChecked(ApplicationChecklistItem.submitted), isFalse);

      final circular = Circular(
        id: 'c-chk',
        userId: 'u-1',
        title: 'Checklist Test Circular',
        checklist: updated.toggle(ApplicationChecklistItem.admitCardDownloaded),
      );
      final roundTrip =
          CircularMapper.fromJson(CircularMapper.toJson(circular));
      expect(roundTrip.checklist, equals(circular.checklist));
      expect(roundTrip.checklist.completedCount, equals(4));

      final updateMap = CircularMapper.toUpdateJson(circular);
      expect(updateMap['checklist_photo'], isTrue);
      expect(updateMap['checklist_certificates'], isTrue);
      expect(updateMap['checklist_fee_paid'], isTrue);
      expect(updateMap['checklist_submitted'], isFalse);
      expect(updateMap['checklist_admit_card_downloaded'], isTrue);
    });
  });

  group('ExamStage & Exam Date Partition/Sorting', () {
    test('ExamStage parses case-insensitively with clean fallback', () {
      expect(ExamStage.tryParse('preliminary'), equals(ExamStage.preliminary));
      expect(ExamStage.tryParse('Written'), equals(ExamStage.written));
      expect(ExamStage.tryParse('VIVA'), equals(ExamStage.viva));
      expect(ExamStage.tryParse('practical'), equals(ExamStage.practical));
      expect(ExamStage.fromValue('custom_stage'), equals(ExamStage.other));
    });

    test(
        'partitionExamDates orders upcoming chronologically and separates past',
        () {
      final dates = [
        CircularExamDate(
          id: 'viva',
          circularId: 'c-1',
          stage: 'viva',
          examDate: DateTime.utc(2026, 12, 20, 9),
        ),
        CircularExamDate(
          id: 'past-old',
          circularId: 'c-1',
          stage: 'other',
          examDate: DateTime.utc(2026, 11, 2, 10),
        ),
        CircularExamDate(
          id: 'today-preli',
          circularId: 'c-1',
          stage: 'preliminary',
          examDate: DateTime.utc(2026, 11, 10, 10), // Same day -> upcoming
        ),
        CircularExamDate(
          id: 'written',
          circularId: 'c-1',
          stage: 'written',
          examDate: DateTime.utc(2026, 11, 28, 10),
        ),
        CircularExamDate(
          id: 'past-recent',
          circularId: 'c-1',
          stage: 'preliminary',
          examDate: DateTime.utc(2026, 11, 8, 10),
        ),
      ];

      final result = partitionExamDates(dates, now: fixedNow);
      expect(
        result.upcoming.map((e) => e.id).toList(),
        equals(['today-preli', 'written', 'viva']),
      );
      expect(
        result.past.map((e) => e.id).toList(),
        equals(['past-recent', 'past-old']),
      );
    });
  });

  group('ExamDateRepository & ExamDateMutationNotifier', () {
    test('creates, updates, queries in order, and deletes via FakeExamDateRepo',
        () async {
      final circularRepo = FakeCircularRepository(
        initialItems: const [
          Circular(id: 'c-1', userId: 'u-1', title: '47th BCS'),
        ],
        clock: () => fixedNow,
      );
      final examRepo = FakeExamDateRepository(clock: () => fixedNow);

      final container = ProviderContainer(
        overrides: [
          circularRepositoryProvider.overrideWithValue(circularRepo),
          examDateRepositoryProvider.overrideWithValue(examRepo),
          circularNowProvider.overrideWithValue(() => fixedNow),
        ],
      );
      addTearDown(container.dispose);

      // Initially empty
      expect(
        await container.read(circularExamDatesProvider('c-1').future),
        isEmpty,
      );

      // Add Written later than Preliminary
      final notifier = container.read(examDateMutationProvider.notifier);
      final written = await notifier.createExamDate(
        CircularExamDate(
          circularId: 'c-1',
          stage: ExamStage.written.value,
          examDate: DateTime.utc(2026, 12, 15, 10),
          venue: 'BUET',
        ),
      );
      expect(written, isNotNull);

      final prelim = await notifier.createExamDate(
        CircularExamDate(
          circularId: 'c-1',
          stage: ExamStage.preliminary.value,
          examDate: DateTime.utc(2026, 11, 20, 10),
          venue: 'Dhaka College',
          notes: 'Bring black pen',
        ),
      );
      expect(prelim, isNotNull);

      final ordered =
          await container.read(circularExamDatesProvider('c-1').future);
      expect(
        ordered.map((e) => e.stage).toList(),
        equals(['preliminary', 'written']),
      );

      // Update exam date
      final updated = await notifier.updateExamDate(
        written!.copyWith(
          stage: ExamStage.viva.value,
          venue: 'BPSC HQ',
        ),
      );
      expect(updated?.stage, equals('viva'));
      expect(updated?.venue, equals('BPSC HQ'));

      // Delete exam date
      final deleted = await notifier.deleteExamDate(
        examDateId: prelim!.id,
        circularId: 'c-1',
      );
      expect(deleted, isTrue);

      final remaining =
          await container.read(circularExamDatesProvider('c-1').future);
      expect(remaining.map((e) => e.id).toList(), equals([written.id]));
    });
  });

  group('CircularDetailController', () {
    test('updates quick statuses, toggles checklist, and deletes circular',
        () async {
      const seed = Circular(
        id: 'c-det',
        userId: 'u-1',
        title: 'Bangladesh Bank AD',
      );
      final circularRepo = FakeCircularRepository(
        initialItems: const [seed],
        clock: () => fixedNow,
      );

      final container = ProviderContainer(
        overrides: [
          circularRepositoryProvider.overrideWithValue(circularRepo),
          circularNowProvider.overrideWithValue(() => fixedNow),
        ],
      );
      addTearDown(container.dispose);

      await container.read(circularsListProvider.future);
      final controller =
          container.read(circularDetailControllerProvider.notifier);

      final workflowUpdated = await controller.updateWorkflowStatus(
        seed,
        CircularWorkflowStatus.preparing,
      );
      expect(
        workflowUpdated?.workflowStatus,
        equals(CircularWorkflowStatus.preparing),
      );

      final appUpdated = await controller.updateApplicationStatus(
        workflowUpdated!,
        ApplicationStatus.applied,
      );
      expect(appUpdated?.applicationStatus, equals(ApplicationStatus.applied));

      final admitUpdated = await controller.updateAdmitCardStatus(
        appUpdated!,
        AdmitCardStatus.downloaded,
      );
      expect(admitUpdated?.admitCardStatus, equals(AdmitCardStatus.downloaded));

      final ticked = await controller.toggleChecklistItem(
        admitUpdated!,
        ApplicationChecklistItem.submitted,
      );
      expect(ticked?.checklist.submitted, isTrue);

      // Error surfaces cleanly without dropping previous data
      circularRepo.nextError = const CircularNetworkFailure();
      final failed = await controller.toggleChecklistItem(
        ticked!,
        ApplicationChecklistItem.photo,
      );
      expect(failed, isNull);
      expect(
        container.read(circularDetailControllerProvider).actionFailure,
        isA<CircularNetworkFailure>(),
      );

      controller.clearError();
      expect(
        container.read(circularDetailControllerProvider).actionFailure,
        isNull,
      );

      final deleted = await controller.deleteCircular(ticked);
      expect(deleted, isTrue);
      expect(circularRepo.deletedIds, equals(['c-det']));
    });
  });
}
