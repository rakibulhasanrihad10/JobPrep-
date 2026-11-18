import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/migration/domain/services/migration_verifier.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';

import 'fake_cloud_repositories.dart';

void main() {
  group('MigrationVerifier Unit Tests', () {
    late FakeCloudRepositoriesBundle fakeCloud;

    setUp(() {
      fakeCloud = FakeCloudRepositoriesBundle();
    });

    test('returns failure when subject is missing in cloud', () async {
      const tables = BackupDataTables(
        subjects: [
          {
            'id': 's-missing',
            'name': 'Missing Subject',
            'color_hex': '#1E88E5',
          }
        ],
      );

      final result = await MigrationVerifier.verify(
        tables: tables,
        cloud: fakeCloud.toCloudRepositories(),
        uploadedCount: 1,
        skippedCount: 0,
      );

      expect(result.isSuccess, isFalse);
      expect(result.mismatchDetails, contains('missing in cloud'));
    });

    test('returns failure when circular is missing in cloud', () async {
      const sub = Subject(id: 's-1', name: 'Math');
      await fakeCloud.subjectRepo.createSubject(sub);

      const tables = BackupDataTables(
        subjects: [
          {
            'id': 's-1',
            'name': 'Math',
          }
        ],
        circulars: [
          {
            'id': 'c-missing',
            'title': 'Missing Circular',
          }
        ],
      );

      final result = await MigrationVerifier.verify(
        tables: tables,
        cloud: fakeCloud.toCloudRepositories(),
        uploadedCount: 2,
        skippedCount: 0,
      );

      expect(result.isSuccess, isFalse);
      expect(result.mismatchDetails, contains('missing in cloud'));
    });

    test(
        'returns success when subjects and circulars exist and '
        'progress matches', () async {
      const sub = Subject(id: 's-1', name: 'Math');
      await fakeCloud.subjectRepo.createSubject(sub);

      const mat = PrepMaterial(
        id: 'm-1',
        subjectId: 's-1',
        title: 'Algebra',
        totalUnits: 100,
        completedUnits: 50,
      );
      await fakeCloud.materialRepo.createMaterial(mat);

      const circ = Circular(id: 'c-1', title: 'Circular 1');
      await fakeCloud.circularRepo.createCircular(circ);

      const tables = BackupDataTables(
        subjects: [
          {
            'id': 's-1',
            'name': 'Math',
          }
        ],
        materials: [
          {
            'id': 'm-1',
            'subject_id': 's-1',
            'title': 'Algebra',
            'total_units': 100,
            'completed_units': 50,
          }
        ],
        circulars: [
          {
            'id': 'c-1',
            'title': 'Circular 1',
          }
        ],
      );

      final result = await MigrationVerifier.verify(
        tables: tables,
        cloud: fakeCloud.toCloudRepositories(),
        uploadedCount: 3,
        skippedCount: 0,
      );

      expect(result.isSuccess, isTrue);
      expect(result.progressTotalsMatch, isTrue);
    });
  });
}
