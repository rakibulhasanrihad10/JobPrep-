import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/local/database/app_database.dart';
import 'package:job_prep/features/circulars/data/repositories/local_exam_date_repository.dart';
import 'package:job_prep/features/circulars/data/repositories/supabase_exam_date_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/domain/repositories/exam_date_repository.dart';

import 'mock_supabase_http_client.dart';

void testExamDateRepositoryContract({
  required Future<ExamDateRepository> Function() createRepository,
  Future<void> Function()? tearDownRepository,
}) {
  group('ExamDateRepository Contract Tests', () {
    late ExamDateRepository repo;

    setUp(() async {
      repo = await createRepository();
    });

    tearDown(() async {
      if (tearDownRepository != null) {
        await tearDownRepository();
      }
    });

    test('creates exam date and fetches for circular', () async {
      final date = CircularExamDate(
        circularId: 'c-100',
        stage: 'Preliminary',
        examDate: DateTime.utc(2026, 12),
        venue: 'Dhaka College',
      );

      final created = await repo.createExamDate(date);
      expect(created.id, isNotEmpty);
      expect(created.stage, equals('Preliminary'));

      final list = await repo.getExamDatesForCircular('c-100');
      expect(list, hasLength(1));
      expect(list.first.venue, equals('Dhaka College'));
    });

    test('saving same id twice results in 1 row (upsert idempotency)',
        () async {
      final date = CircularExamDate(
        id: 'ed-fixed-1',
        circularId: 'c-100',
        stage: 'Preliminary',
        examDate: DateTime.utc(2026, 12),
        venue: 'Hall A',
      );

      final initial = await repo.createExamDate(date);
      expect(initial.id, equals('ed-fixed-1'));

      final updated = await repo.createExamDate(
        date.copyWith(venue: 'Hall B'),
      );
      expect(updated.id, equals('ed-fixed-1'));
      expect(updated.venue, equals('Hall B'));

      final list = await repo.getExamDatesForCircular('c-100');
      final matching = list.where((e) => e.id == 'ed-fixed-1').toList();
      expect(matching, hasLength(1));
      expect(matching.first.venue, equals('Hall B'));
    });

    test('updates exam date cleanly', () async {
      final created = await repo.createExamDate(
        CircularExamDate(
          circularId: 'c-200',
          stage: 'Written',
          examDate: DateTime.utc(2026, 12, 15),
        ),
      );

      final updated = await repo.updateExamDate(
        created.copyWith(stage: 'Written Exam', venue: 'BUET'),
      );
      expect(updated.stage, equals('Written Exam'));
      expect(updated.venue, equals('BUET'));

      final list = await repo.getExamDatesForCircular('c-200');
      expect(list.first.stage, equals('Written Exam'));
    });

    test('deletes exam date', () async {
      final created = await repo.createExamDate(
        CircularExamDate(
          circularId: 'c-300',
          stage: 'Viva',
          examDate: DateTime.utc(2027, 1, 10),
        ),
      );

      await repo.deleteExamDate(created.id);
      final list = await repo.getExamDatesForCircular('c-300');
      expect(list, isEmpty);
    });

    test('validates non-empty circular id and stage', () async {
      expect(
        () => repo.createExamDate(
          CircularExamDate(
            stage: 'Preliminary',
            examDate: DateTime.utc(2026, 12),
          ),
        ),
        throwsA(isA<CircularValidationFailure>()),
      );
    });
  });
}

void main() {
  group('Local Implementation Contract', () {
    late AppDatabase db;

    testExamDateRepositoryContract(
      createRepository: () async {
        db = AppDatabase(NativeDatabase.memory());
        return LocalExamDateRepository(db);
      },
      tearDownRepository: () async {
        await db.close();
      },
    );
  });

  group('Supabase Implementation Contract', () {
    late MockSupabaseHttpClient mockHttp;
    late MockSupabaseClient client;

    testExamDateRepositoryContract(
      createRepository: () async {
        mockHttp = MockSupabaseHttpClient();
        client = MockSupabaseClient(mockHttpClient: mockHttp);
        return SupabaseExamDateRepository(client);
      },
      tearDownRepository: () async {
        mockHttp.clear();
      },
    );
  });
}
