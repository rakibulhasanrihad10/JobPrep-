import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_material_cover_repository.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';

import '../../contracts/mock_supabase_http_client.dart';

void main() {
  group('SupabaseMaterialCoverRepository', () {
    late MockSupabaseHttpClient mockHttp;
    late SupabaseMaterialCoverRepository repo;

    setUp(() {
      mockHttp = MockSupabaseHttpClient();
      final client = MockSupabaseClient(mockHttpClient: mockHttp);
      repo = SupabaseMaterialCoverRepository(client);
    });

    test('uploadCover rejects empty folder key', () async {
      expect(
        () => repo.uploadCover(
          folderKey: '  ',
          fileName: 'cover.jpg',
          mimeType: 'image/jpeg',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(isA<PrepValidationFailure>()),
      );
    });

    test('uploadCover rejects unsupported extensions', () async {
      expect(
        () => repo.uploadCover(
          folderKey: 'mat-1',
          fileName: 'cover.exe',
          mimeType: 'application/octet-stream',
          bytes: Uint8List.fromList([1, 2, 3]),
        ),
        throwsA(isA<PrepValidationFailure>()),
      );
    });
  });
}
