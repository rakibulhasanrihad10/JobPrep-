import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';

/// Canonical route paths for authentication and top-level destinations.
abstract final class AppRoutePaths {
  /// Root route.
  static const String root = '/';

  /// Login route.
  static const String login = '/login';

  /// Password recovery / reset route.
  static const String resetPassword = '/reset-password';

  /// Focused daily Today route (default signed-in home).
  static const String today = '/today';

  /// Overview Dashboard route.
  static const String dashboard = '/dashboard';

  /// Quick-capture Inbox triage route.
  static const String inbox = '/inbox';

  /// Full-screen first-run onboarding wizard route.
  static const String onboarding = '/onboarding';

  /// Privacy Policy declaration route.
  static const String privacy = '/privacy';

  /// Terms of Service declaration route.
  static const String terms = '/terms';
}

/// Computes the target redirect route for [location] given [authState],
/// optional [appMode], and optional [needsOnboarding], returning `null` when
/// the navigation is allowed.
///
/// Rules:
/// 1. Recovery sessions (`AuthStatus.passwordRecovery`) are directed to
///    `/reset-password`.
/// 2. Guest users (`appMode == AppMode.guest`) may use the whole app;
///    `/login` stays reachable from Settings; onboarding wizard runs if needed.
/// 3. Signed-in users (`AuthStatus.signedIn`) who need onboarding are directed
///    to `/onboarding`; after onboarding they are redirected away from `/login`,
///    `/`, and `/onboarding` to `/today`.
/// 4. Unauthenticated users are directed to `/login`.
/// 5. Legal pages (`/privacy`, `/terms`) are always accessible to all users.
String? resolveAuthRedirect({
  required AuthSessionState authState,
  required String location,
  bool needsOnboarding = false,
  AppMode? appMode,
}) {
  final normalized = _normalizePath(location);

  if (normalized == AppRoutePaths.privacy ||
      normalized == AppRoutePaths.terms) {
    return null;
  }

  if (authState.status == AuthStatus.passwordRecovery) {
    if (normalized == AppRoutePaths.resetPassword) {
      return null;
    }
    return AppRoutePaths.resetPassword;
  }

  if (appMode == AppMode.guest) {
    if (normalized == AppRoutePaths.login) {
      return null;
    }
    if (needsOnboarding) {
      if (normalized == AppRoutePaths.onboarding) {
        return null;
      }
      return AppRoutePaths.onboarding;
    }
    if (normalized == AppRoutePaths.root ||
        normalized == AppRoutePaths.onboarding) {
      return AppRoutePaths.today;
    }
    return null;
  }

  if (authState.status == AuthStatus.signedIn || appMode == AppMode.signedIn) {
    if (needsOnboarding) {
      if (normalized == AppRoutePaths.onboarding) {
        return null;
      }
      return AppRoutePaths.onboarding;
    }
    if (normalized == AppRoutePaths.login ||
        normalized == AppRoutePaths.root ||
        normalized == AppRoutePaths.onboarding) {
      return AppRoutePaths.today;
    }
    return null;
  }

  if (normalized == AppRoutePaths.login) {
    return null;
  }
  return AppRoutePaths.login;
}

String _normalizePath(String location) {
  if (location.isEmpty) return AppRoutePaths.root;
  if (location.length > 1 && location.endsWith('/')) {
    return location.substring(0, location.length - 1);
  }
  return location;
}
