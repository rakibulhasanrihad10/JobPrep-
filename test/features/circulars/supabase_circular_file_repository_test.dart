import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/data/repositories/supabase_circular_file_repository.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';

import '../../contracts/mock_supabase_http_client.dart';

void main() {
  group('SupabaseCircularFileRepository', () {
    late MockSupabaseHttpClient mockHttp;
    late SupabaseCircularFileRepository repo;

    setUp(() {
      mockHttp = MockSupabaseHttpClient();
      final client = MockSupabaseClient(mockHttpClient: mockHttp);
      repo = SupabaseCircularFileRepository(client);
    });

    test('getFilesForCircular returns empty list on empty circularId',
        () async {
      final files = await repo.getFilesForCircular('   ');
      expect(files, isEmpty);
    });

    test('uploadFile rejects empty circularId', () async {
      expect(
        () => repo.uploadFile(
          circularId: '',
          fileName: 'doc.pdf',
          mimeType: 'application/pdf',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(isA<CircularValidationFailure>()),
      );
    });

    test('uploadFile rejects invalid file extension or oversized file',
        () async {
      expect(
        () => repo.uploadFile(
          circularId: 'c-1',
          fileName: 'malicious.exe',
          mimeType: 'application/octet-stream',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(isA<CircularValidationFailure>()),
      );
    });
  });
}
