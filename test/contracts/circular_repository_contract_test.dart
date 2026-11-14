import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/circulars/data/repositories/local_circular_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';

void testCircularRepositoryContract({
  required Future<CircularRepository> Function() createRepository,
  Future<void> Function()? tearDownRepository,
}) {
  group('CircularRepository Contract Tests', () {
    late CircularRepository repo;

    setUp(() async {
      repo = await createRepository();
    });

    tearDown(() async {
      if (tearDownRepository != null) {
        await tearDownRepository();
      }
    });

    test('creates circular with client-generated id and retrieves it',
        () async {
      const circular = Circular(
        title: 'Assistant Director',
      );

      final created = await repo.createCircular(circular);
      expect(created.id, isNotEmpty);
      expect(created.title, equals('Assistant Director'));

      final fetched = await repo.getCircularById(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, equals(created.id));
      expect(fetched.title, equals('Assistant Director'));
    });

    test('getCirculars retrieves all stored circulars', () async {
      await repo.createCircular(
        const Circular(
          title: 'Circular One',
          sector: CircularSector.bank,
        ),
      );
      await repo.createCircular(
        const Circular(
          title: 'Circular Two',
          sector: CircularSector.private,
        ),
      );

      final all = await repo.getCirculars();
      expect(all.length, greaterThanOrEqualTo(2));
    });

    test('updateCircular modifies fields cleanly', () async {
      final created = await repo.createCircular(
        const Circular(
          title: 'Original Title',
          vacancies: 10,
        ),
      );

      final updated = await repo.updateCircular(
        created.copyWith(title: 'Updated Title', vacancies: 25),
      );

      expect(updated.title, equals('Updated Title'));
      expect(updated.vacancies, equals(25));

      final fetched = await repo.getCircularById(created.id);
      expect(fetched!.title, equals('Updated Title'));
      expect(fetched.vacancies, equals(25));
    });

    test('deleteCircular removes row', () async {
      final created = await repo.createCircular(
        const Circular(
          title: 'To Be Deleted',
        ),
      );

      await repo.deleteCircular(created.id);
      final fetched = await repo.getCircularById(created.id);
      expect(fetched, isNull);
    });

    test('createCircular validates non-empty title', () async {
      expect(
        () => repo.createCircular(const Circular(title: '   ')),
        throwsA(isA<CircularValidationFailure>()),
      );
    });
  });
}

void main() {
  late AppDatabase db;

  testCircularRepositoryContract(
    createRepository: () async {
      db = AppDatabase(NativeDatabase.memory());
      return LocalCircularRepository(db);
    },
    tearDownRepository: () async {
      await db.close();
    },
  );
}
