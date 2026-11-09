import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/main.dart';

void main() {
  testWidgets('JobPrepApp smoke test renders title', (tester) async {
    await tester.pumpWidget(const JobPrepApp());
    expect(find.text('Job Circular Tracker & Exam Prep'), findsOneWidget);
  });
}
