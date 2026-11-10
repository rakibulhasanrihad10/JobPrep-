import 'dart:async';

import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps Supabase PostgREST and network exceptions into typed
/// [CircularFailure]s.
abstract final class CircularErrorMapper {
  static const Set<String> _validationCodes = {
    '23514', // check_violation
    '23502', // not_null_violation
    '23503', // foreign_key_violation
    '22P02', // invalid_text_representation (e.g. malformed UUID)
  };

  /// Converts an arbitrary [error] into a typed [CircularFailure].
  static CircularFailure map(Object error) {
    if (error is CircularFailure) return error;

    if (error is TimeoutException) {
      return CircularNetworkFailure(
        message: error.message ?? 'Request timed out.',
        code: 'request_timeout',
      );
    }

    if (error is supabase.AuthRetryableFetchException) {
      return CircularNetworkFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (error is supabase.AuthException) {
      return CircularPermissionFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (error is supabase.PostgrestException) {
      return _mapPostgrestException(error);
    }

    final raw = error.toString().toLowerCase();
    final typeName = error.runtimeType.toString().toLowerCase();
    if (_looksLikeNetworkMessage(raw) || typeName.contains('socket')) {
      return const CircularNetworkFailure();
    }

    return const UnknownCircularFailure();
  }

  static CircularFailure _mapPostgrestException(
    supabase.PostgrestException error,
  ) {
    final code = error.code?.trim();
    final normalizedCode = code?.toUpperCase();
    final msgLower = error.message.toLowerCase();

    if (normalizedCode == 'PGRST116' ||
        msgLower.contains('json object requested, multiple (or no) rows')) {
      return CircularNotFoundFailure(
        message: error.message,
        code: code,
      );
    }

    if (normalizedCode == '42501' ||
        normalizedCode == 'PGRST301' ||
        msgLower.contains('row-level security') ||
        msgLower.contains('permission denied') ||
        msgLower.contains('jwt expired')) {
      return CircularPermissionFailure(
        message: error.message,
        code: code,
      );
    }

    if (normalizedCode != null && _validationCodes.contains(normalizedCode)) {
      return CircularValidationFailure(
        message: error.message,
        code: code,
      );
    }

    if (_looksLikeNetworkMessage(msgLower)) {
      return CircularNetworkFailure(
        message: error.message,
        code: code,
      );
    }

    return UnknownCircularFailure(
      message: error.message,
      code: code,
    );
  }

  static bool _looksLikeNetworkMessage(String raw) {
    return raw.contains('socketexception') ||
        raw.contains('clientexception') ||
        raw.contains('failed host lookup') ||
        raw.contains('network is unreachable') ||
        raw.contains('connection refused') ||
        raw.contains('connection reset') ||
        raw.contains('xmlhttprequest error') ||
        raw.contains('failed to fetch');
  }
}
