import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/migration/domain/services/guest_migration_service.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';

import 'fake_cloud_repositories.dart';

void main() {
  late GuestMigrationService service;
  late FakeCloudRepositoriesBundle fakeCloud;

  setUp(() {
    service = const GuestMigrationService();
    fakeCloud = FakeCloudRepositoriesBundle();
  });

  group('GuestMigrationService Unit & Contract Tests', () {
    test(
      'interrupted upload resumed later creates no duplicates in cloud',
      () async {
        const tables = BackupDataTables(
          subjects: [
            {
              'id': 'sub-math',
              'name': 'Mathematics',
              'color_hex': '#1E88E5',
              'created_at': '2026-11-10T10:00:00.000Z',
              'updated_at': '2026-11-10T10:00:00.000Z',
            },
          ],
          materials: [
            {
              'id': 'mat-1',
              'subject_id': 'sub-math',
              'title': 'Higher Math Vol 1',
              'total_units': 300,
              'completed_units': 300,
              'created_at': '2026-11-10T10:00:00.000Z',
              'updated_at': '2026-11-10T10:00:00.000Z',
            },
          ],
          circulars: [
            {
              'id': 'circ-1',
              'title': '46th BCS Preliminary',
              'organization': 'BPSC',
              'created_at': '2026-11-10T10:00:00.000Z',
              'updated_at': '2026-11-10T10:00:00.000Z',
            },
          ],
        );

        // 1. First run: uploads all records
        final result1 = await service.migrate(
          tables: tables,
          cloud: fakeCloud.toCloudRepositories(),
        );

        expect(result1.isSuccess, isTrue);
        expect(result1.uploadedCount, 3);
        expect(result1.skippedCount, 0);

        // Verify count in cloud
        final subjectsAfterFirst = await fakeCloud.subjectRepo.getSubjects();
        final materialsAfterFirst =
            await fakeCloud.materialRepo.getMaterialsForSubject('sub-math');
        final circularsAfterFirst = await fakeCloud.circularRepo.getCirculars();

        expect(subjectsAfterFirst.length, 1);
        expect(materialsAfterFirst.length, 1);
        expect(circularsAfterFirst.length, 1);

        // 2. Second run (simulate resuming after interruption):
        // all items already exist
        final result2 = await service.migrate(
          tables: tables,
          cloud: fakeCloud.toCloudRepositories(),
        );

        expect(result2.isSuccess, isTrue);
        expect(result2.uploadedCount, 0);
        expect(result2.skippedCount, 3);

        // Verify no duplicates were created
        final subjectsAfterSecond = await fakeCloud.subjectRepo.getSubjects();
        final materialsAfterSecond =
            await fakeCloud.materialRepo.getMaterialsForSubject('sub-math');
        final circularsAfterSecond =
            await fakeCloud.circularRepo.getCirculars();

        expect(subjectsAfterSecond.length, 1);
        expect(materialsAfterSecond.length, 1);
        expect(circularsAfterSecond.length, 1);
      },
    );

    test(
      'counts and progress totals verified with 300, 300, 400 invariant',
      () async {
        const tables = BackupDataTables(
          subjects: [
            {
              'id': 'sub-invariant',
              'name': 'Combined Math',
              'color_hex': '#D4AF37',
              'created_at': '2026-11-10T10:00:00.000Z',
              'updated_at': '2026-11-10T10:00:00.000Z',
            },
          ],
          materials: [
            {
              'id': 'book-1',
              'subject_id': 'sub-invariant',
              'title': 'Book 1 (300 pages)',
              'total_units': 300,
              'completed_units': 300,
              'created_at': '2026-11-10T10:00:00.000Z',
              'updated_at': '2026-11-10T10:00:00.000Z',
            },
            {
              'id': 'book-2',
              'subject_id': 'sub-invariant',
              'title': 'Book 2 (300 pages)',
              'total_units': 300,
              'completed_units': 0,
              'created_at': '2026-11-10T10:00:00.000Z',
              'updated_at': '2026-11-10T10:00:00.000Z',
            },
            {
              'id': 'book-3',
              'subject_id': 'sub-invariant',
              'title': 'Book 3 (400 pages)',
              'total_units': 400,
              'completed_units': 0,
              'created_at': '2026-11-10T10:00:00.000Z',
              'updated_at': '2026-11-10T10:00:00.000Z',
            },
          ],
        );

        final result = await service.migrate(
          tables: tables,
          cloud: fakeCloud.toCloudRepositories(),
        );

        expect(result.isSuccess, isTrue);
        expect(result.progressTotalsMatch, isTrue);

        // Verify mathematical invariant on cloud materials
        final cloudMaterials = await fakeCloud.materialRepo
            .getMaterialsForSubject('sub-invariant');
        expect(cloudMaterials.length, 3);

        final book1 = cloudMaterials.firstWhere((m) => m.id == 'book-1');
        expect(book1.completedUnits, 300);
        expect(book1.totalUnits, 300);
        expect(book1.completedUnits / book1.totalUnits, 1.0); // 100%

        final subjectProgress = calculateSubjectProgress(cloudMaterials);
        // (300 + 0 + 0) / (300 + 300 + 400) = 300 / 1000 = 0.30 (30%)
        expect((subjectProgress * 100).round(), 30);
      },
    );

    test(
      'existing account data is never overwritten: merge keeps account version',
      () async {
        // Pre-populate cloud repository with an existing subject
        await fakeCloud.subjectRepo.createSubject(
          Subject(
            id: 'sub-existing',
            name: 'Original Account Subject',
            color: '#00FF00',
            createdAt: DateTime.utc(2026, 11),
            updatedAt: DateTime.utc(2026, 11),
          ),
        );

        // Guest attempts to migrate item with same ID but conflicting contents
        const tables = BackupDataTables(
          subjects: [
            {
              'id': 'sub-existing',
              'name': 'Overwritten Guest Name Attempt',
              'color_hex': '#FF0000',
              'created_at': '2026-11-12T10:00:00.000Z',
              'updated_at': '2026-11-12T10:00:00.000Z',
            },
            {
              'id': 'sub-new',
              'name': 'Brand New Guest Subject',
              'color_hex': '#1E88E5',
              'created_at': '2026-11-12T10:00:00.000Z',
              'updated_at': '2026-11-12T10:00:00.000Z',
            },
          ],
        );

        final result = await service.migrate(
          tables: tables,
          cloud: fakeCloud.toCloudRepositories(),
        );

        expect(result.isSuccess, isTrue);
        expect(result.uploadedCount, 1);
        expect(result.skippedCount, 1);

        // Verify account version is kept exactly as it was
        final cloudSub =
            await fakeCloud.subjectRepo.getSubjectById('sub-existing');
        expect(cloudSub, isNotNull);
        expect(cloudSub!.name, 'Original Account Subject');
        expect(cloudSub.color, '#00FF00');

        // Verify new subject was added
        final newSub = await fakeCloud.subjectRepo.getSubjectById('sub-new');
        expect(newSub, isNotNull);
        expect(newSub!.name, 'Brand New Guest Subject');
      },
    );
  });
}
