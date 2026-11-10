import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';

/// Canonical route paths for authentication and top-level destinations.
abstract final class AppRoutePaths {
  /// Root route.
  static const String root = '/';

  /// Login route.
  static const String login = '/login';

  /// Password recovery / reset route.
  static const String resetPassword = '/reset-password';

  /// Main dashboard route.
  static const String dashboard = '/dashboard';

  /// Quick-capture Inbox triage route.
  static const String inbox = '/inbox';
}

/// Computes the target redirect route for [location] given [authState], or
/// returns `null` when navigation should proceed without redirection.
///
/// Rules:
/// 1. Recovery sessions (`AuthStatus.passwordRecovery`) are directed to
///    `/reset-password`.
/// 2. Signed-out users (`AuthStatus.signedOut`) are directed to `/login`.
/// 3. Signed-in users (`AuthStatus.signedIn`) navigating to `/login` (or `/`)
///    are redirected to `/dashboard`.
String? resolveAuthRedirect({
  required AuthSessionState authState,
  required String location,
}) {
  final normalized = _normalizePath(location);

  switch (authState.status) {
    case AuthStatus.passwordRecovery:
      if (normalized == AppRoutePaths.resetPassword) {
        return null;
      }
      return AppRoutePaths.resetPassword;

    case AuthStatus.signedOut:
      if (normalized == AppRoutePaths.login) {
        return null;
      }
      return AppRoutePaths.login;

    case AuthStatus.signedIn:
      if (normalized == AppRoutePaths.login ||
          normalized == AppRoutePaths.root) {
        return AppRoutePaths.dashboard;
      }
      return null;
  }
}

String _normalizePath(String location) {
  if (location.isEmpty) return AppRoutePaths.root;
  if (location.length > 1 && location.endsWith('/')) {
    return location.substring(0, location.length - 1);
  }
  return location;
}
