import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:job_prep/main.dart';

void main() {
  testWidgets(
    'JobPrepApp initializes with ProviderScope and renders Dashboard',
    (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: JobPrepApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.text('JobPrep Dashboard'), findsOneWidget);
    },
  );
}
