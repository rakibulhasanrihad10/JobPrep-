import 'dart:async';

import 'package:job_prep/features/notifications/domain/errors/notification_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps Supabase and network exceptions into typed [NotificationFailure]s.
abstract final class NotificationErrorMapper {
  static const Set<String> _validationCodes = {
    '23514',
    '23502',
    '22P02',
  };

  /// Maps an arbitrary thrown [error] into a typed [NotificationFailure].
  static NotificationFailure map(Object error) {
    if (error is NotificationFailure) return error;

    if (error is TimeoutException) {
      return NotificationNetworkFailure(
        message: error.message ?? 'Request timed out.',
        code: 'request_timeout',
      );
    }

    if (error is supabase.AuthRetryableFetchException) {
      return NotificationNetworkFailure(
        message: error.message,
        code: error.code ?? 'auth_retry_error',
      );
    }

    if (error is supabase.AuthException) {
      return NotificationPermissionFailure(
        message: error.message,
        code: error.code ?? 'auth_error',
      );
    }

    if (error is supabase.PostgrestException) {
      return _mapPostgrest(error);
    }

    final raw = error.toString().toLowerCase();
    final typeName = error.runtimeType.toString().toLowerCase();
    if (_looksLikeNetworkMessage(raw) || typeName.contains('socket')) {
      return const NotificationNetworkFailure();
    }

    return const UnknownNotificationFailure();
  }

  static NotificationFailure _mapPostgrest(supabase.PostgrestException error) {
    final code = error.code;
    if (code == '42501') {
      return NotificationPermissionFailure(
        message: error.message,
        code: '42501',
      );
    }
    if (code != null && _validationCodes.contains(code)) {
      return NotificationValidationFailure(
        message: error.message,
        code: code,
      );
    }
    if (_looksLikeNetworkMessage(error.message.toLowerCase())) {
      return NotificationNetworkFailure(
        message: error.message,
        code: code ?? 'network_error',
      );
    }
    return UnknownNotificationFailure(
      message: error.message,
      code: code ?? 'postgrest_error',
    );
  }

  static bool _looksLikeNetworkMessage(String lower) {
    return lower.contains('socket') ||
        lower.contains('network') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection') ||
        lower.contains('timeout');
  }
}
