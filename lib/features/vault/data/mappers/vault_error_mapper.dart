import 'dart:async';

import 'package:job_prep/features/vault/domain/errors/vault_feature_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps Supabase and network exceptions into typed [VaultFeatureFailure]s.
abstract final class VaultErrorMapper {
  static const Set<String> _validationCodes = {
    '23514',
    '23502',
    '23503',
    '22P02',
  };

  /// Converts an arbitrary thrown [error] into a typed [VaultFeatureFailure].
  static VaultFeatureFailure map(Object error) {
    if (error is VaultFeatureFailure) return error;

    if (error is TimeoutException) {
      return VaultNetworkFailure(
        message: error.message ?? 'Request timed out.',
        code: 'request_timeout',
      );
    }

    if (error is supabase.AuthRetryableFetchException) {
      return VaultNetworkFailure(message: error.message, code: error.code);
    }

    if (error is supabase.AuthException) {
      return VaultPermissionFailure(message: error.message, code: error.code);
    }

    if (error is supabase.PostgrestException) {
      return _mapPostgrest(error);
    }

    final raw = error.toString().toLowerCase();
    final typeName = error.runtimeType.toString().toLowerCase();
    if (_looksLikeNetworkMessage(raw) || typeName.contains('socket')) {
      return const VaultNetworkFailure();
    }

    return const UnknownVaultFailure();
  }

  static VaultFeatureFailure _mapPostgrest(supabase.PostgrestException error) {
    final code = error.code;
    if (code == '42501') {
      return VaultPermissionFailure(message: error.message, code: code);
    }
    if (code == 'PGRST116') {
      return VaultNotFoundFailure(message: error.message, code: code);
    }
    if (code != null && _validationCodes.contains(code)) {
      return VaultValidationFailure(message: error.message, code: code);
    }
    if (_looksLikeNetworkMessage(error.message.toLowerCase())) {
      return VaultNetworkFailure(message: error.message, code: code);
    }
    return UnknownVaultFailure(message: error.message, code: code);
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
