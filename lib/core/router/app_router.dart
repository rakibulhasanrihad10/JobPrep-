import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/features/dashboard/presentation/screens/dashboard_screen.dart';

/// Provider for application routing using [GoRouter].
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
