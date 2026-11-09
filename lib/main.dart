import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: JobPrepApp()));
}

/// Root application widget.
class JobPrepApp extends ConsumerWidget {
  /// Creates the [JobPrepApp].
  const JobPrepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'JobPrep',
      routerConfig: router,
    );
  }
}
