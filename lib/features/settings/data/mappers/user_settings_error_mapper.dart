import 'dart:async';
import 'dart:io';

import 'package:job_prep/features/settings/domain/errors/settings_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps raw persistence/network exceptions into typed [SettingsFailure] values
/// without exposing sensitive details.
abstract final class UserSettingsErrorMapper {
  /// Converts [error] into a [SettingsFailure].
  static SettingsFailure map(Object error) {
    if (error is SettingsFailure) return error;

    if (error is TimeoutException || error is SocketException) {
      return const SettingsNetworkFailure();
    }

    if (error is supabase.AuthException) {
      return SettingsPermissionFailure(
        message: error.message,
        code: error.statusCode,
      );
    }

    if (error is supabase.PostgrestException) {
      final code = error.code?.trim();
      if (code == '42501') {
        return SettingsPermissionFailure(code: code);
      }
      if (code == '23514' || code == '22P02' || code == '23502') {
        return SettingsValidationFailure(
          message: error.message,
          code: code,
        );
      }
      return UnknownSettingsFailure(message: error.message, code: code);
    }

    return const UnknownSettingsFailure();
  }
}
