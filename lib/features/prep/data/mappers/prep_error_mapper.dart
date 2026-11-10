import 'dart:async';

import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps Supabase PostgREST, Storage, Auth, and network errors into typed
/// [PrepFailure]s.
abstract final class PrepErrorMapper {
  static const Set<String> _validationCodes = {
    '23514', // check_violation
    '23502', // not_null_violation
    '23503', // foreign_key_violation
    '23505', // unique_violation
    '22P02', // invalid_text_representation
  };

  /// Converts an arbitrary [error] into a typed [PrepFailure].
  static PrepFailure map(Object error) {
    if (error is PrepFailure) return error;

    if (error is TimeoutException) {
      return PrepNetworkFailure(
        message: error.message ?? 'Request timed out.',
        code: 'request_timeout',
      );
    }

    if (error is supabase.AuthRetryableFetchException) {
      return PrepNetworkFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (error is supabase.AuthException) {
      return PrepPermissionFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (error is supabase.StorageException) {
      return _mapStorageException(error);
    }

    if (error is supabase.PostgrestException) {
      return _mapPostgrestException(error);
    }

    final raw = error.toString().toLowerCase();
    final typeName = error.runtimeType.toString().toLowerCase();
    if (_looksLikeNetworkMessage(raw) || typeName.contains('socket')) {
      return const PrepNetworkFailure();
    }

    return const UnknownPrepFailure();
  }

  static PrepFailure _mapPostgrestException(supabase.PostgrestException error) {
    final code = error.code?.trim();
    final normalizedCode = code?.toUpperCase();
    final msgLower = error.message.toLowerCase();

    if (normalizedCode == 'PGRST116' ||
        msgLower.contains('json object requested, multiple (or no) rows')) {
      return PrepNotFoundFailure(message: error.message, code: code);
    }

    if (normalizedCode == '42501' ||
        normalizedCode == 'PGRST301' ||
        msgLower.contains('row-level security') ||
        msgLower.contains('permission denied') ||
        msgLower.contains('jwt expired')) {
      return PrepPermissionFailure(message: error.message, code: code);
    }

    if (normalizedCode != null && _validationCodes.contains(normalizedCode)) {
      return PrepValidationFailure(message: error.message, code: code);
    }

    if (_looksLikeNetworkMessage(msgLower)) {
      return PrepNetworkFailure(message: error.message, code: code);
    }

    return UnknownPrepFailure(message: error.message, code: code);
  }

  static PrepFailure _mapStorageException(supabase.StorageException error) {
    final status = error.statusCode?.trim();
    final msgLower = error.message.toLowerCase();

    if (status == '401' ||
        status == '403' ||
        msgLower.contains('unauthorized') ||
        msgLower.contains('row-level security') ||
        msgLower.contains('permission')) {
      return PrepPermissionFailure(
        message: error.message,
        code: status ?? error.error,
      );
    }

    if (status == '404' || msgLower.contains('not found')) {
      return PrepNotFoundFailure(
        message: error.message,
        code: status ?? error.error,
      );
    }

    if (status == '400' || status == '413' || status == '415') {
      return PrepValidationFailure(
        message: error.message,
        code: status ?? error.error,
      );
    }

    if (_looksLikeNetworkMessage(msgLower)) {
      return PrepNetworkFailure(
        message: error.message,
        code: status ?? error.error,
      );
    }

    return UnknownPrepFailure(
      message: error.message,
      code: status ?? error.error,
    );
  }

  static bool _looksLikeNetworkMessage(String msgLower) {
    return msgLower.contains('socketexception') ||
        msgLower.contains('failed host lookup') ||
        msgLower.contains('network') ||
        msgLower.contains('connection') ||
        msgLower.contains('timed out') ||
        msgLower.contains('xmlhttprequest') ||
        msgLower.contains('clientexception');
  }
}
