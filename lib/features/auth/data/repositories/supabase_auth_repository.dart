import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:job_prep/features/auth/data/mappers/auth_error_mapper.dart';
import 'package:job_prep/features/auth/data/mappers/auth_user_mapper.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/domain/entities/auth_user.dart';
import 'package:job_prep/features/auth/domain/errors/auth_failure.dart';
import 'package:job_prep/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase-backed implementation of [AuthRepository].
class SupabaseAuthRepository implements AuthRepository {
  /// Creates a [SupabaseAuthRepository].
  ///
  /// Optional [isWeb], [appOriginUri], [oauthRedirectUrl],
  /// [passwordResetRedirectUrl], and [oauthLauncher] parameters allow
  /// deterministic testing of platform-specific redirect URLs and OAuth launch.
  SupabaseAuthRepository(
    this._client, {
    bool isWeb = kIsWeb,
    Uri? appOriginUri,
    String? oauthRedirectUrl,
    String? passwordResetRedirectUrl,
    Future<bool> Function(
      supabase.OAuthProvider provider, {
      String? redirectTo,
    })? oauthLauncher,
  })  : _isWeb = isWeb,
        _appOriginUri = appOriginUri,
        _oauthRedirectUrl = oauthRedirectUrl,
        _passwordResetRedirectUrl = passwordResetRedirectUrl,
        _oauthLauncher = oauthLauncher;

  static const String _mobileOAuthRedirect =
      'io.supabase.jobprep://login-callback';
  static const String _mobileResetRedirect =
      'io.supabase.jobprep://reset-password';

  final supabase.SupabaseClient _client;
  final bool _isWeb;
  final Uri? _appOriginUri;
  final String? _oauthRedirectUrl;
  final String? _passwordResetRedirectUrl;
  final Future<bool> Function(
    supabase.OAuthProvider provider, {
    String? redirectTo,
  })? _oauthLauncher;

  bool _inPasswordRecovery = false;

  @override
  AuthSessionState get currentSession {
    final user = _client.auth.currentSession?.user;
    if (user == null) {
      return const AuthSessionState.signedOut();
    }
    final mappedUser = AuthUserMapper.fromSupabase(user);
    if (_inPasswordRecovery) {
      return AuthSessionState.passwordRecovery(user: mappedUser);
    }
    return AuthSessionState.signedIn(mappedUser);
  }

  @override
  Stream<AuthSessionState> get onSessionStateChange {
    return _client.auth.onAuthStateChange.map(_mapAuthState);
  }

  @override
  Future<AuthUser?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
    String? emailRedirectTo,
  }) async {
    try {
      final trimmedName = displayName?.trim();
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: (trimmedName != null && trimmedName.isNotEmpty)
            ? {'full_name': trimmedName}
            : null,
        emailRedirectTo: emailRedirectTo ?? _resolveOAuthRedirectUrl(),
      );

      final user = response.user;
      if (user == null) return null;

      // Supabase returns an empty identities list with a null session when
      // email confirmation is enabled and the address is already registered.
      final identities = user.identities;
      if (identities != null &&
          identities.isEmpty &&
          response.session == null) {
        throw const AccountAlreadyExistsFailure();
      }

      return AuthUserMapper.fromSupabase(user);
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw const InvalidCredentialsFailure();
      }

      _inPasswordRecovery = false;
      return AuthUserMapper.fromSupabase(user);
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<void> signInWithGoogle({String? redirectTo}) async {
    try {
      final resolvedRedirect = redirectTo ?? _resolveOAuthRedirectUrl();
      final launcher = _oauthLauncher;
      final launched = launcher != null
          ? await launcher(
              supabase.OAuthProvider.google,
              redirectTo: resolvedRedirect,
            )
          : await _client.auth.signInWithOAuth(
              supabase.OAuthProvider.google,
              redirectTo: resolvedRedirect,
            );
      if (!launched) {
        throw const UnknownAuthFailure(
          message: 'Unable to open Google sign-in flow.',
        );
      }
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<void> sendPasswordReset({
    required String email,
    String? redirectTo,
  }) async {
    try {
      final resolvedRedirect = redirectTo ?? _resolvePasswordResetRedirectUrl();
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: resolvedRedirect,
      );
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<AuthUser> updatePassword({required String newPassword}) async {
    try {
      final response = await _client.auth.updateUser(
        supabase.UserAttributes(password: newPassword),
      );
      final user = response.user;
      if (user == null) {
        throw const UnknownAuthFailure(
          message: 'Password update completed without a user payload.',
        );
      }
      _inPasswordRecovery = false;
      return AuthUserMapper.fromSupabase(user);
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _inPasswordRecovery = false;
    } catch (error) {
      throw AuthErrorMapper.map(error);
    }
  }

  AuthSessionState _mapAuthState(supabase.AuthState authState) {
    final user = authState.session?.user;
    final mappedUser = user != null ? AuthUserMapper.fromSupabase(user) : null;

    switch (authState.event) {
      case supabase.AuthChangeEvent.passwordRecovery:
        _inPasswordRecovery = true;
        return AuthSessionState.passwordRecovery(user: mappedUser);

      case supabase.AuthChangeEvent.signedOut:
        _inPasswordRecovery = false;
        return const AuthSessionState.signedOut();

      case supabase.AuthChangeEvent.signedIn:
      case supabase.AuthChangeEvent.userUpdated:
      case supabase.AuthChangeEvent.mfaChallengeVerified:
        _inPasswordRecovery = false;
        if (mappedUser == null) return const AuthSessionState.signedOut();
        return AuthSessionState.signedIn(mappedUser);

      case supabase.AuthChangeEvent.initialSession:
        if (mappedUser == null) {
          _inPasswordRecovery = false;
          return const AuthSessionState.signedOut();
        }
        if (_inPasswordRecovery) {
          return AuthSessionState.passwordRecovery(user: mappedUser);
        }
        return AuthSessionState.signedIn(mappedUser);

      case supabase.AuthChangeEvent.tokenRefreshed:
        if (mappedUser == null) {
          _inPasswordRecovery = false;
          return const AuthSessionState.signedOut();
        }
        if (_inPasswordRecovery) {
          return AuthSessionState.passwordRecovery(user: mappedUser);
        }
        return AuthSessionState.signedIn(mappedUser);

      // Exhaustive switch must handle deprecated enum value until removed by
      // gotrue.
      // ignore: deprecated_member_use
      case supabase.AuthChangeEvent.userDeleted:
        _inPasswordRecovery = false;
        return const AuthSessionState.signedOut();
    }
  }

  String _resolveOAuthRedirectUrl() {
    if (_oauthRedirectUrl != null) return _oauthRedirectUrl;
    if (_isWeb) {
      final base = _appOriginUri ?? Uri.base;
      if (base.scheme == 'http' || base.scheme == 'https') {
        return base.origin;
      }
    }
    return _mobileOAuthRedirect;
  }

  String _resolvePasswordResetRedirectUrl() {
    if (_passwordResetRedirectUrl != null) return _passwordResetRedirectUrl;
    if (_isWeb) {
      final base = _appOriginUri ?? Uri.base;
      if (base.scheme == 'http' || base.scheme == 'https') {
        return '${base.origin}/reset-password';
      }
    }
    return _mobileResetRedirect;
  }
}
