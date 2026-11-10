import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/circulars/data/mappers/circular_error_mapper.dart';
import 'package:job_prep/features/circulars/data/repositories/unconfigured_circular_repository.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() {
  group('CircularErrorMapper', () {
    test('maps PostgREST, timeout, auth, and network errors accurately', () {
      expect(
        CircularErrorMapper.map(
          const supabase.PostgrestException(
            message: 'No rows',
            code: 'PGRST116',
          ),
        ),
        isA<CircularNotFoundFailure>(),
      );
      expect(
        CircularErrorMapper.map(
          const supabase.PostgrestException(
            message: 'new row violates row-level security policy',
            code: '42501',
          ),
        ),
        isA<CircularPermissionFailure>(),
      );
      expect(
        CircularErrorMapper.map(
          const supabase.PostgrestException(
            message: 'jwt expired',
            code: 'PGRST301',
          ),
        ),
        isA<CircularPermissionFailure>(),
      );
      for (final code in ['23514', '23502', '23503', '22P02']) {
        expect(
          CircularErrorMapper.map(
            supabase.PostgrestException(message: 'invalid', code: code),
          ),
          isA<CircularValidationFailure>(),
        );
      }
      expect(
        CircularErrorMapper.map(TimeoutException('Timed out')),
        isA<CircularNetworkFailure>(),
      );
      expect(
        CircularErrorMapper.map(
          supabase.AuthRetryableFetchException(message: 'offline'),
        ),
        isA<CircularNetworkFailure>(),
      );
      expect(
        CircularErrorMapper.map(Exception('SocketException: Failed host')),
        isA<CircularNetworkFailure>(),
      );
      expect(
        CircularErrorMapper.map(const supabase.AuthException('JWT expired')),
        isA<CircularPermissionFailure>(),
      );
      expect(
        CircularErrorMapper.map(StateError('unexpected')),
        isA<UnknownCircularFailure>(),
      );
    });
  });

  group('UnconfiguredCircularRepository', () {
    const repo = UnconfiguredCircularRepository();

    test('returns empty reads and rejects writes with typed failure', () async {
      expect(await repo.getCirculars(), isEmpty);
      expect(await repo.getCircularById('id-1'), isNull);

      const draft = Circular(title: 'Draft');
      await expectLater(
        () => repo.createCircular(draft),
        throwsA(isA<UnknownCircularFailure>()),
      );
      await expectLater(
        () => repo.updateCircular(draft.copyWith(id: 'id-1')),
        throwsA(isA<UnknownCircularFailure>()),
      );
      await expectLater(
        () => repo.deleteCircular('id-1'),
        throwsA(isA<UnknownCircularFailure>()),
      );
    });
  });
}
