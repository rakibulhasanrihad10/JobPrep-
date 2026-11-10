import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/data/mappers/prep_error_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/prep_material_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/progress_log_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/subject_mapper.dart';
import 'package:job_prep/features/prep/data/mappers/topic_mapper.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_material_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_progress_log_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_subject_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_topic_repository.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/entities/topic.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('Prep JSON Mappers', () {
    test('SubjectMapper round-trips JSON, insert, and update payloads', () {
      final json = <String, dynamic>{
        'id': 'sub-1',
        'user_id': 'u-1',
        'name': 'Bangladesh Affairs',
        'color': '#E5A93C',
        'icon': 'flag',
        'exam_type': 'bcs',
        'sort_order': '2',
        'created_at': '2026-11-10T10:00:00Z',
        'updated_at': '2026-11-10T11:00:00Z',
      };
      final subject = SubjectMapper.fromJson(json);
      expect(subject.id, 'sub-1');
      expect(subject.name, 'Bangladesh Affairs');
      expect(subject.color, '#E5A93C');
      expect(subject.icon, 'flag');
      expect(subject.examType, 'bcs');
      expect(subject.sortOrder, 2);

      final roundTripped = SubjectMapper.fromJson(
        SubjectMapper.toJson(subject),
      );
      expect(roundTripped, subject);

      final insertJson = SubjectMapper.toInsertJson(
        const Subject(name: '  English  ', sortOrder: -1),
        userId: 'u-2',
      );
      expect(insertJson['user_id'], 'u-2');
      expect(insertJson['name'], 'English');
      expect(insertJson['sort_order'], 0);
      expect(insertJson.containsKey('id'), isFalse);

      final updateJson = SubjectMapper.toUpdateJson(subject);
      expect(updateJson['name'], 'Bangladesh Affairs');
      expect(updateJson.containsKey('user_id'), isFalse);
    });

    test('PrepMaterialMapper parses types and clamps insert bounds safely', () {
      final json = <String, dynamic>{
        'id': 'mat-1',
        'user_id': 'u-1',
        'subject_id': 'sub-1',
        'title': 'MP3 Bangla',
        'kind': 'lecture_sheet',
        'unit_label': 'chapters',
        'total_units': '12',
        'completed_units': 5,
        'cover_image_path': 'u-1/mat-1/cover.png',
        'cover_image_url': '   ',
        'created_at': '2026-11-10T10:00:00Z',
      };
      final material = PrepMaterialMapper.fromJson(json);
      expect(material.kind, MaterialKind.lectureSheet);
      expect(material.unitLabel, 'chapters');
      expect(material.totalUnits, 12);
      expect(material.completedUnits, 5);
      expect(material.coverImagePath, 'u-1/mat-1/cover.png');
      expect(material.coverImageUrl, isNull);

      final insertClamped = PrepMaterialMapper.toInsertJson(
        const PrepMaterial(
          subjectId: 'sub-1',
          title: 'Over',
          totalUnits: 100,
          completedUnits: 150,
        ),
        userId: 'u-1',
      );
      expect(insertClamped['completed_units'], 100);
      expect(
        PrepMaterialMapper.fromJson(
          PrepMaterialMapper.toJson(material),
        ),
        material,
      );
    });

    test('ProgressLogMapper & TopicMapper serialize SQL date-only and statuses',
        () {
      final logJson = <String, dynamic>{
        'id': 'log-1',
        'user_id': 'u-1',
        'material_id': 'mat-1',
        'units_done': 40,
        'logged_on': '2026-11-10',
        'note': 'Finished unit 2',
      };
      final log = ProgressLogMapper.fromJson(logJson);
      expect(log.unitsDone, 40);
      expect(log.loggedOn, DateTime(2026, 11, 10));
      expect(log.note, 'Finished unit 2');
      expect(ProgressLogMapper.toInsertJson(log)['logged_on'], '2026-11-10');
      expect(ProgressLogMapper.toJson(log)['logged_on'], '2026-11-10');

      final topicJson = <String, dynamic>{
        'id': 'top-1',
        'user_id': 'u-1',
        'subject_id': 'sub-1',
        'name': 'Constitutional Amendments',
        'status': 'needs_revision',
      };
      final topic = TopicMapper.fromJson(topicJson);
      expect(topic.status, TopicStatus.needsRevision);
      expect(
        TopicMapper.fromJson(TopicMapper.toJson(topic)),
        topic,
      );
      expect(
        TopicMapper.toUpdateJson(
          topic.copyWith(status: TopicStatus.completed),
        )['status'],
        'completed',
      );
    });
  });

  group('PrepErrorMapper & Unconfigured Repositories', () {
    test('maps PostgREST, Storage, Auth, timeout, and network exceptions', () {
      expect(
        PrepErrorMapper.map(
          const supabase.PostgrestException(
            message: 'Missing',
            code: 'PGRST116',
          ),
        ),
        isA<PrepNotFoundFailure>(),
      );
      expect(
        PrepErrorMapper.map(
          const supabase.PostgrestException(message: 'Denied', code: '42501'),
        ),
        isA<PrepPermissionFailure>(),
      );
      expect(
        PrepErrorMapper.map(
          const supabase.PostgrestException(message: 'Check', code: '23514'),
        ),
        isA<PrepValidationFailure>(),
      );
      expect(
        PrepErrorMapper.map(
          const supabase.StorageException('Forbidden', statusCode: '403'),
        ),
        isA<PrepPermissionFailure>(),
      );
      expect(
        PrepErrorMapper.map(TimeoutException('Timed out')),
        isA<PrepNetworkFailure>(),
      );
      expect(
        PrepErrorMapper.map(const supabase.AuthException('Expired')),
        isA<PrepPermissionFailure>(),
      );
      expect(
        PrepErrorMapper.map(StateError('unexpected')),
        isA<UnknownPrepFailure>(),
      );
    });

    test('unconfigured repositories return empty reads and reject writes',
        () async {
      const subjects = UnconfiguredSubjectRepository();
      const materials = UnconfiguredMaterialRepository();
      const logs = UnconfiguredProgressLogRepository();
      const topics = UnconfiguredTopicRepository();

      expect(await subjects.getSubjects(), isEmpty);
      expect(await subjects.getSubjectIdsForCircular('c-1'), isEmpty);
      expect(await materials.getAllMaterials(), isEmpty);
      expect(await materials.getMaterialsForSubject('s-1'), isEmpty);
      expect(await logs.getLogsForMaterial('m-1'), isEmpty);
      expect(await logs.getRecentLogs(), isEmpty);
      expect(await topics.getTopicsForSubject('s-1'), isEmpty);

      await expectLater(
        () => subjects.createSubject(const Subject(name: 'Test')),
        throwsA(isA<UnknownPrepFailure>()),
      );
      await expectLater(
        () => materials.createMaterial(const PrepMaterial(title: 'Test')),
        throwsA(isA<UnknownPrepFailure>()),
      );
      await expectLater(
        () => logs.createLog(ProgressLog(loggedOn: DateTime(2026, 11, 10))),
        throwsA(isA<UnknownPrepFailure>()),
      );
      await expectLater(
        () => topics.createTopic(const Topic(name: 'Test')),
        throwsA(isA<UnknownPrepFailure>()),
      );
    });
  });
}
