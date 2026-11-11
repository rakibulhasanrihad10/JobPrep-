import 'dart:async';

import 'package:job_prep/features/settings/domain/errors/reminder_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps Supabase and transport exceptions into typed [ReminderFailure]s.
abstract final class ReminderErrorMapper {
  static const Set<String> _validationCodes = {
    '23514',
    '23502',
    '22P02',
  };

  /// Maps an arbitrary thrown [error] into a typed [ReminderFailure].
  static ReminderFailure map(Object error) {
    if (error is ReminderFailure) return error;

    if (error is TimeoutException) {
      return ReminderNetworkFailure(
        message: error.message ?? 'Request timed out.',
        code: 'request_timeout',
      );
    }

    if (error is supabase.AuthRetryableFetchException) {
      return ReminderNetworkFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (error is supabase.AuthException) {
      return ReminderPermissionFailure(
        message: error.message,
        code: error.code,
      );
    }

    if (error is supabase.PostgrestException) {
      return _mapPostgrest(error);
    }

    final raw = error.toString().toLowerCase();
    final typeName = error.runtimeType.toString().toLowerCase();
    if (_looksLikeNetworkMessage(raw) || typeName.contains('socket')) {
      return const ReminderNetworkFailure();
    }

    return const UnknownReminderFailure();
  }

  static ReminderFailure _mapPostgrest(supabase.PostgrestException error) {
    final code = error.code;
    if (code == '42501') {
      return ReminderPermissionFailure(message: error.message, code: code);
    }
    if (code != null && _validationCodes.contains(code)) {
      return ReminderValidationFailure(message: error.message, code: code);
    }
    if (_looksLikeNetworkMessage(error.message.toLowerCase())) {
      return ReminderNetworkFailure(message: error.message, code: code);
    }
    return UnknownReminderFailure(message: error.message, code: code);
  }

  static bool _looksLikeNetworkMessage(String lower) {
    return lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection refused') ||
        lower.contains('connection reset') ||
        lower.contains('network is unreachable') ||
        lower.contains('timed out');
  }
}
