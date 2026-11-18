import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/circulars/data/repositories/local_circular_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/supabase_circular_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_filter.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/circular_repository.dart';

import 'mock_supabase_http_client.dart';

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

    test('saving same id twice results in 1 row (upsert idempotency)',
        () async {
      final initial = await repo.createCircular(
        const Circular(id: 'c-fixed-1', title: 'Initial Title', vacancies: 5),
      );
      expect(initial.id, equals('c-fixed-1'));

      final updated = await repo.createCircular(
        const Circular(
          id: 'c-fixed-1',
          title: 'Overwritten Title',
          vacancies: 10,
        ),
      );
      expect(updated.id, equals('c-fixed-1'));
      expect(updated.title, equals('Overwritten Title'));

      final all = await repo.getCirculars();
      final matching = all.where((c) => c.id == 'c-fixed-1').toList();
      expect(matching, hasLength(1));
      expect(matching.first.title, equals('Overwritten Title'));
      expect(matching.first.vacancies, equals(10));
    });

    test('getCirculars respects ordering and filters', () async {
      final c1 = await repo.createCircular(
        Circular(
          title: 'Govt Job A',
          deadline: DateTime.utc(2026, 12, 10),
        ),
      );
      final c2 = await repo.createCircular(
        Circular(
          title: 'Bank Job B',
          sector: CircularSector.bank,
          deadline: DateTime.utc(2026, 11, 20),
        ),
      );

      final bankOnly = await repo.getCirculars(
        filter: const CircularFilter(sectors: {CircularSector.bank}),
      );
      expect(bankOnly.any((c) => c.id == c2.id), isTrue);
      expect(bankOnly.any((c) => c.id == c1.id), isFalse);

      final searchA = await repo.getCirculars(
        filter: const CircularFilter(searchQuery: 'Govt Job A'),
      );
      expect(searchA.any((c) => c.id == c1.id), isTrue);
      expect(searchA.any((c) => c.id == c2.id), isFalse);
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
  group('Local Implementation Contract', () {
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
  });

  group('Supabase Implementation Contract', () {
    late MockSupabaseHttpClient mockHttp;
    late MockSupabaseClient client;

    testCircularRepositoryContract(
      createRepository: () async {
        mockHttp = MockSupabaseHttpClient();
        client = MockSupabaseClient(mockHttpClient: mockHttp);
        return SupabaseCircularRepository(client);
      },
      tearDownRepository: () async {
        mockHttp.clear();
      },
    );
  });
}
