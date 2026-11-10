import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/validators/circular_form_validators.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_form_controller.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';

import 'fake_circular_repository.dart';

void main() {
  final fixedNow = DateTime.utc(2026, 11, 10, 12);

  ProviderContainer createContainer(FakeCircularRepository repo) {
    final container = ProviderContainer(
      overrides: [
        circularRepositoryProvider.overrideWithValue(repo),
        circularNowProvider.overrideWithValue(() => fixedNow),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('CircularFormController', () {
    test('tracks dirty state accurately and validates before creating',
        () async {
      final repo = FakeCircularRepository(
        initialItems: const [
          Circular(
            id: 'existing-1',
            title: 'Existing Circular',
            circularUrl: 'https://bpsc.gov.bd/notices/47',
          ),
        ],
        clock: () => fixedNow,
      );
      final container = createContainer(repo);
      await container.read(circularsListProvider.future);

      final provider = circularFormControllerProvider(null);
      final sub = container.listen(provider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(provider).isEditMode, isFalse);
      expect(container.read(provider).isDirty, isFalse);

      // Failed submit shows validation errors and does not call repo
      final invalidSubmit = await container.read(provider.notifier).submit();
      expect(invalidSubmit, isNull);
      expect(
        container.read(provider).titleError,
        equals(CircularTitleValidationError.required),
      );
      expect(repo.createdItems, isEmpty);

      // Entering duplicate link triggers non-blocking warning
      container.read(provider.notifier)
        ..updateTitle('47th BCS Cadre')
        ..updateCircularUrl('https://BPSC.GOV.BD/notices/47/')
        ..updateSalaryMin('50000')
        ..updateSalaryMax('30000');

      var state = container.read(provider);
      expect(state.isDirty, isTrue);
      expect(state.duplicateCircular?.id, equals('existing-1'));
      expect(
        state.salaryRangeError,
        equals(CircularSalaryRangeValidationError.maxBelowMin),
      );

      // Invalid salary range blocks save
      expect(await container.read(provider.notifier).submit(), isNull);
      expect(repo.createdItems, isEmpty);

      // Fixing salary max permits saving cleanly
      container.read(provider.notifier)
        ..updateSalaryMax('65000')
        ..updatePriority(CircularPriority.urgent);

      final saved = await container.read(provider.notifier).submit();
      expect(saved, isNotNull);
      expect(saved!.title, equals('47th BCS Cadre'));
      expect(saved.priority, equals(CircularPriority.urgent));
      expect(repo.createdItems.length, equals(1));

      state = container.read(provider);
      expect(state.isDirty, isFalse);
      expect(state.savedCircular, equals(saved));
    });

    test('edit mode resets dirty state when reverted and updates record',
        () async {
      const existing = Circular(
        id: 'c-1',
        userId: 'u-1',
        title: 'Assistant Director',
        sector: CircularSector.bank,
        circularUrl: 'https://bb.org.bd/ad',
        salaryMin: 22000,
        salaryMax: 53060,
        notes: 'Initial note',
      );
      final repo = FakeCircularRepository(
        initialItems: const [existing],
        clock: () => fixedNow,
      );
      final container = createContainer(repo);
      await container.read(circularsListProvider.future);

      final provider = circularFormControllerProvider(existing);
      final sub = container.listen(provider, (_, __) {});
      addTearDown(sub.close);

      expect(container.read(provider).isEditMode, isTrue);
      expect(container.read(provider).isDirty, isFalse);
      // Same circular does not trigger duplicate warning against itself
      expect(container.read(provider).duplicateCircular, isNull);

      container.read(provider.notifier).updateNotes('Changed note');
      expect(container.read(provider).isDirty, isTrue);

      container.read(provider.notifier).updateNotes('Initial note');
      expect(container.read(provider).isDirty, isFalse);

      container.read(provider.notifier)
        ..updateNotes('Final edited note')
        ..updateWorkflowStatus(CircularWorkflowStatus.applied);

      final updated = await container.read(provider.notifier).submit();
      expect(updated, isNotNull);
      expect(updated!.notes, equals('Final edited note'));
      expect(updated.workflowStatus, equals(CircularWorkflowStatus.applied));
      expect(repo.updatedItems.length, equals(1));
    });
  });
}
