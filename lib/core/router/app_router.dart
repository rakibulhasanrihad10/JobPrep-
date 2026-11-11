import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/auth/presentation/screens/login_screen.dart';
import 'package:job_prep/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:job_prep/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/utils/quick_capture_helpers.dart';
import 'package:job_prep/features/circulars/presentation/screens/circular_detail_screen.dart';
import 'package:job_prep/features/circulars/presentation/screens/circular_form_screen.dart';
import 'package:job_prep/features/circulars/presentation/screens/circulars_screen.dart';
import 'package:job_prep/features/circulars/presentation/screens/inbox_screen.dart';
import 'package:job_prep/features/circulars/presentation/widgets/quick_capture_shell.dart';
import 'package:job_prep/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:job_prep/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:job_prep/features/notifications/presentation/screens/weekly_review_screen.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_screen.dart';
import 'package:job_prep/features/prep/presentation/screens/prep_subject_detail_screen.dart';
import 'package:job_prep/features/prep/presentation/widgets/books_shelf_view.dart';
import 'package:job_prep/features/prep/presentation/widgets/prep_tab_switcher.dart';
import 'package:job_prep/features/settings/presentation/screens/settings_screen.dart';
import 'package:job_prep/features/today/presentation/screens/today_screen.dart';

/// Optional initial location override used in widget and deep-link tests.
final initialRouteLocationProvider = Provider<String?>((ref) => null);

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
  final initialLocationOverride = ref.watch(initialRouteLocationProvider);

  final router = GoRouter(
    initialLocation: initialLocationOverride ?? AppRoutePaths.today,
    overridePlatformDefaultLocation: initialLocationOverride != null,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final targetPath = resolveAuthRedirect(
        authState: ref.read(authSessionProvider),
        location: state.uri.path,
      );
      if (targetPath == null) return null;
      if (targetPath == AppRoutePaths.login ||
          targetPath == AppRoutePaths.today ||
          targetPath == AppRoutePaths.dashboard) {
        return buildLocationWithCapture(targetPath, sourceUri: state.uri);
      }
      return targetPath;
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.root,
        redirect: (context, state) => buildLocationWithCapture(
          AppRoutePaths.today,
          sourceUri: state.uri,
        ),
      ),
      GoRoute(
        path: '/capture',
        redirect: (context, state) => buildLocationWithCapture(
          AppRoutePaths.inbox,
          sourceUri: state.uri,
        ),
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
          return QuickCaptureShell(
            currentUri: state.uri,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutePaths.today,
            name: 'today',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodayScreen(),
            ),
          ),
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
            routes: [
              GoRoute(
                path: 'new',
                name: 'circular_new',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CircularFormScreen(),
                ),
              ),
              GoRoute(
                path: ':id',
                name: 'circular_detail',
                pageBuilder: (context, state) {
                  final circularId = state.pathParameters['id']!;
                  final extra = state.extra;
                  return NoTransitionPage(
                    child: CircularDetailScreen(
                      circularId: circularId,
                      initialCircular: extra is Circular ? extra : null,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'circular_edit',
                    pageBuilder: (context, state) {
                      final circularId = state.pathParameters['id'];
                      final extra = state.extra;
                      return NoTransitionPage(
                        child: CircularFormScreen(
                          circularId: circularId,
                          initialCircular: extra is Circular ? extra : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutePaths.inbox,
            name: 'inbox',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InboxScreen(),
            ),
          ),
          GoRoute(
            path: '/prep',
            name: 'prep',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrepScreen(),
            ),
            routes: [
              GoRoute(
                path: 'analytics',
                name: 'prep_analytics',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PrepScreen(initialTab: PrepSectionTab.analytics),
                ),
              ),
              GoRoute(
                path: 'revision',
                name: 'prep_revision',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PrepScreen(initialTab: PrepSectionTab.revision),
                ),
              ),
              GoRoute(
                path: 'timer',
                name: 'prep_timer',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PrepScreen(initialTab: PrepSectionTab.timer),
                ),
              ),
              GoRoute(
                path: ':subjectId',
                name: 'prep_subject',
                pageBuilder: (context, state) {
                  final subjectId = state.pathParameters['subjectId']!;
                  final initialMaterialId =
                      state.uri.queryParameters['material'];
                  final initialView =
                      state.uri.queryParameters['view'] == 'books'
                          ? PrepSubjectViewMode.booksShelf
                          : PrepSubjectViewMode.allMaterials;
                  return NoTransitionPage(
                    child: PrepSubjectDetailScreen(
                      subjectId: subjectId,
                      initialMaterialId: initialMaterialId,
                      initialViewMode: initialView,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'books',
                    name: 'prep_subject_books',
                    pageBuilder: (context, state) {
                      final subjectId = state.pathParameters['subjectId']!;
                      return NoTransitionPage(
                        child: PrepSubjectDetailScreen(
                          subjectId: subjectId,
                          initialViewMode: PrepSubjectViewMode.booksShelf,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationsScreen(),
            ),
          ),
          GoRoute(
            path: '/weekly-review',
            name: 'weekly_review',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WeeklyReviewScreen(),
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
