import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_exam_date_mapper.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_file_mapper.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_mapper.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_enums.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_exam_date.dart';
import 'package:job_prep/features/circulars/domain/entities/circular_file.dart';

void main() {
  group('Circular Entity & Enums', () {
    test('copyWith updates values and explicitly clears nullable fields', () {
      final original = Circular(
        id: 'c-1',
        userId: 'u-1',
        title: '47th BCS',
        sector: CircularSector.bcs,
        organizationName: 'BPSC',
        deadline: DateTime.utc(2026, 12, 2),
        salaryMin: 22000,
        salaryMax: 53060,
        notes: 'Apply before evening',
      );

      final updated = original.copyWith(
        title: '47th BCS General Cadre',
        deadline: null,
        notes: null,
        salaryMin: null,
        priority: CircularPriority.urgent,
      );

      expect(updated.id, equals('c-1'));
      expect(updated.title, equals('47th BCS General Cadre'));
      expect(updated.sector, equals(CircularSector.bcs));
      expect(updated.organizationName, equals('BPSC'));
      expect(updated.deadline, isNull);
      expect(updated.notes, isNull);
      expect(updated.salaryMin, isNull);
      expect(updated.salaryMax, equals(53060));
      expect(updated.priority, equals(CircularPriority.urgent));
      expect(original.deadline, isNotNull);
    });

    test('enums parse database values and fall back gracefully on unknowns',
        () {
      expect(CircularSector.tryParse('bank'), equals(CircularSector.bank));
      expect(CircularSector.tryParse('unknown'), isNull);
      expect(
        CircularSector.fromValue('unknown'),
        equals(CircularSector.government),
      );

      expect(
        ApplicationStatus.fromValue('fee_paid'),
        equals(ApplicationStatus.feePaid),
      );
      expect(
        ApplicationStatus.fromValue(null),
        equals(ApplicationStatus.notApplied),
      );

      expect(
        AdmitCardStatus.fromValue('available'),
        equals(AdmitCardStatus.available),
      );
      expect(
        AdmitCardStatus.fromValue('unexpected'),
        equals(AdmitCardStatus.notAvailable),
      );

      expect(CircularPriority.fromValue('urgent'), CircularPriority.urgent);
      expect(CircularPriority.fromValue('bad'), CircularPriority.medium);

      expect(
        CircularWorkflowStatus.fromValue('exam_upcoming'),
        equals(CircularWorkflowStatus.examUpcoming),
      );
      expect(
        CircularWorkflowStatus.fromValue('bad'),
        equals(CircularWorkflowStatus.saved),
      );
    });
  });

  group('Circular JSON Mappers', () {
    test('round-trips complete Circular with nested exam dates and files', () {
      final circular = Circular(
        id: 'circ-1',
        userId: 'user-1',
        title: 'Assistant Director (General)',
        sector: CircularSector.bank,
        organizationName: 'Bangladesh Bank',
        organizationWebsite: 'https://www.bb.org.bd',
        circularUrl: 'https://erecruitment.bb.org.bd/circular/1',
        applicationUrl: 'https://erecruitment.bb.org.bd/apply/1',
        deadline: DateTime.utc(2026, 11, 25, 17),
        vacancies: 150,
        salaryMin: 22000,
        salaryMax: 53060,
        salaryNote: 'Grade 9 National Pay Scale',
        applicationFee: 200,
        feeNote: 'Payable via Rocket',
        applicationStatus: ApplicationStatus.applied,
        admitCardStatus: AdmitCardStatus.downloaded,
        priority: CircularPriority.high,
        workflowStatus: CircularWorkflowStatus.examUpcoming,
        instructions: 'Upload 300x300 photo',
        notes: 'Need analytical practice',
        syllabus: 'English, Math, General Knowledge',
        createdAt: DateTime.utc(2026, 11, 1, 9),
        updatedAt: DateTime.utc(2026, 11, 5, 14),
        examDates: [
          CircularExamDate(
            id: 'ed-1',
            circularId: 'circ-1',
            userId: 'user-1',
            stage: 'Preliminary',
            examDate: DateTime.utc(2026, 12, 12, 10),
            venue: 'Dhaka College',
            notes: 'Bring calculator',
            createdAt: DateTime.utc(2026, 11, 2, 8),
            updatedAt: DateTime.utc(2026, 11, 2, 8),
          ),
          CircularExamDate(
            id: 'ed-2',
            circularId: 'circ-1',
            userId: 'user-1',
            stage: 'Written',
            examDate: DateTime.utc(2027, 1, 20, 10),
          ),
        ],
        files: [
          CircularFile(
            id: 'file-1',
            circularId: 'circ-1',
            userId: 'user-1',
            storagePath: 'user-1/circ-1/admit.pdf',
            fileName: 'admit.pdf',
            mimeType: 'application/pdf',
            sizeBytes: 245760,
            createdAt: DateTime.utc(2026, 11, 4, 12),
            updatedAt: DateTime.utc(2026, 11, 4, 12),
          ),
        ],
      );

      final json = CircularMapper.toJson(circular);
      final decoded = CircularMapper.fromJson(json);

      expect(decoded, equals(circular));
    });

    test('parses PostgREST numeric strings, unsorts child exam dates, defaults',
        () {
      final rawJson = <String, dynamic>{
        'id': 'circ-2',
        'user_id': 'user-2',
        'title': 'Quick Capture Role',
        'sector': 'unknown_sector',
        'vacancies': '25',
        'salary_min': '35500.50',
        'salary_max': 70000,
        'application_fee': '112.00',
        'is_quick_capture': true,
        'circular_exam_dates': [
          <String, dynamic>{
            'id': 'ed-late',
            'circular_id': 'circ-2',
            'user_id': 'user-2',
            'stage': 'Viva',
            'exam_date': '2027-02-01T09:00:00Z',
          },
          <String, dynamic>{
            'id': 'ed-early',
            'circular_id': 'circ-2',
            'user_id': 'user-2',
            'stage': 'Preliminary',
            'exam_date': '2026-12-01T09:00:00Z',
          },
        ],
        'circular_files': [
          <String, dynamic>{
            'id': 'f-1',
            'circular_id': 'circ-2',
            'user_id': 'user-2',
            'storage_path': 'user-2/notice.pdf',
            'file_name': 'notice.pdf',
            'mime_type': 'application/pdf',
            'size_bytes': '1024',
          },
        ],
      };

      final mapped = CircularMapper.fromJson(rawJson);

      expect(mapped.sector, equals(CircularSector.government));
      expect(mapped.applicationStatus, equals(ApplicationStatus.notApplied));
      expect(mapped.vacancies, equals(25));
      expect(mapped.salaryMin, equals(35500.5));
      expect(mapped.salaryMax, equals(70000.0));
      expect(mapped.applicationFee, equals(112.0));
      expect(mapped.isQuickCapture, isTrue);
      expect(mapped.examDates.map((e) => e.stage), ['Preliminary', 'Viva']);
      expect(mapped.files.single.sizeBytes, equals(1024));
    });

    test('toInsertJson omits blank id/user_id and toUpdateJson keeps nulls',
        () {
      const draft = Circular(
        title: '  Ministry Officer  ',
        sector: CircularSector.autonomous,
      );

      final insertJson = CircularMapper.toInsertJson(draft);
      expect(insertJson.containsKey('id'), isFalse);
      expect(insertJson.containsKey('user_id'), isFalse);
      expect(insertJson['title'], equals('Ministry Officer'));
      expect(insertJson['sector'], equals('autonomous'));

      final insertWithUser = CircularMapper.toInsertJson(
        draft,
        userId: 'user-9',
      );
      expect(insertWithUser['user_id'], equals('user-9'));

      final updateJson = CircularMapper.toUpdateJson(
        draft.copyWith(id: 'circ-9', userId: 'user-9'),
      );
      expect(updateJson.containsKey('id'), isFalse);
      expect(updateJson.containsKey('user_id'), isFalse);
      expect(updateJson.containsKey('notes'), isTrue);
      expect(updateJson['notes'], isNull);
      expect(updateJson.containsKey('deadline'), isTrue);
      expect(updateJson['deadline'], isNull);
    });

    test('CircularExamDateMapper & CircularFileMapper round-trip and insert',
        () {
      final examDate = CircularExamDate(
        id: 'ed-1',
        circularId: 'c-1',
        userId: 'u-1',
        stage: 'Written',
        examDate: DateTime.utc(2026, 12, 15, 10),
        venue: 'BUET',
      );
      expect(
        CircularExamDateMapper.fromJson(
          CircularExamDateMapper.toJson(examDate),
        ),
        equals(examDate),
      );
      expect(
        CircularExamDateMapper.toInsertJson(
          CircularExamDate(
            circularId: 'c-1',
            stage: 'Viva',
            examDate: DateTime.utc(2027, 1, 5, 9),
          ),
          userId: 'u-1',
        ),
        containsPair('user_id', 'u-1'),
      );

      const file = CircularFile(
        id: 'f-1',
        circularId: 'c-1',
        userId: 'u-1',
        storagePath: 'u-1/c-1/circular.pdf',
        fileName: 'circular.pdf',
        mimeType: 'application/pdf',
        sizeBytes: 5120,
      );
      expect(
        CircularFileMapper.fromJson(CircularFileMapper.toJson(file)),
        equals(file),
      );
      expect(
        CircularFileMapper.toInsertJson(file).containsKey('id'),
        isTrue,
      );
    });
  });
}
