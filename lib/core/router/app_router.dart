import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/widgets/app_scaffold.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/auth/presentation/screens/login_screen.dart';
import 'package:job_prep/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:job_prep/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:job_prep/features/circulars/presentation/screens/circulars_screen.dart';
import 'package:job_prep/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/settings/presentation/screens/settings_screen.dart';

class _AuthRouterRefreshListenable extends ChangeNotifier {
  _AuthRouterRefreshListenable(this._ref) {
    _subscription = _ref.listen<AuthSessionState>(
      authSessionProvider,
      (previous, next) {
        if (previous != next) {
          notifyListeners();
        }
      },
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AuthSessionState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

/// Provider for application routing using [GoRouter] configured with
/// [ShellRoute] and reactive auth redirects.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthRouterRefreshListenable(ref);
  ref.onDispose(refreshListenable.dispose);

  final router = GoRouter(
    initialLocation: AppRoutePaths.dashboard,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      return resolveAuthRedirect(
        authState: ref.read(authSessionProvider),
        location: state.uri.path,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.root,
        redirect: (context, state) => AppRoutePaths.dashboard,
      ),
      GoRoute(
        path: AppRoutePaths.login,
        name: 'login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutePaths.resetPassword,
        name: 'reset_password',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: ResetPasswordScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(
            currentPath: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutePaths.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/circulars',
            name: 'circulars',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CircularsScreen(),
            ),
          ),
          GoRoute(
            path: '/prep',
            name: 'prep',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrepScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
