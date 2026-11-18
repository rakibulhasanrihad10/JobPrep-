import 'dart:io';

/// Enforces the test baseline safety rule:
/// 1. The total automated test count must not drop below the baseline stored in
///    `test/test_count_baseline.txt`.
/// 2. Test files in `test/` must never be deleted without documented rationale.
void main(List<String> args) {
  final baselineFile = File('test/test_count_baseline.txt');
  if (!baselineFile.existsSync()) {
    stderr.writeln('Error: test/test_count_baseline.txt not found.');
    exit(1);
  }

  final baselineContent = baselineFile.readAsStringSync();
  final baselineMatch =
      RegExp(r'BASELINE\s*=\s*(\d+)').firstMatch(baselineContent);
  if (baselineMatch == null) {
    stderr.writeln(
      'Error: test/test_count_baseline.txt must contain BASELINE=<integer>.',
    );
    exit(1);
  }

  final baselineCount = int.parse(baselineMatch.group(1)!);

  // Check 1: Ensure no test file was deleted in git working tree
  final gitStatusResult = Process.runSync('git', ['status', '--porcelain']);
  if (gitStatusResult.exitCode == 0) {
    final output = gitStatusResult.stdout.toString();
    final deletedLines = output
        .split('\n')
        .where((line) => line.trim().startsWith('D ') && line.contains('test/'))
        .toList();

    if (deletedLines.isNotEmpty) {
      stderr
        ..writeln(
          'SECURITY CHECK FAILED: Deleted test file(s) in working tree:\n'
          '${deletedLines.join('\n')}',
        )
        ..writeln(
          'Rule in AGENTS.md: An existing test must never be deleted, '
          'skipped, loosened, or edited to make it pass.',
        );
      exit(1);
    }
  }

  // Check 2: Parse test count if passed via --count or --log
  int? observedCount;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--count' && i + 1 < args.length) {
      observedCount = int.tryParse(args[i + 1]);
    } else if (args[i] == '--log' && i + 1 < args.length) {
      final logFile = File(args[i + 1]);
      if (logFile.existsSync()) {
        final content = logFile.readAsStringSync();
        final match =
            RegExp(r'\+(\d+)(?::\s*All tests passed!)?').allMatches(content);
        if (match.isNotEmpty) {
          observedCount = int.tryParse(match.last.group(1)!);
        }
      }
    }
  }

  // If no runner count passed, dynamically count test declarations
  if (observedCount == null) {
    var staticCount = 0;
    final testDir = Directory('test');
    final files = testDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('_test.dart'));

    final testDeclRegex = RegExp(
      r'^\s*(test|testWidgets|testGoldens)\s*\(',
      multiLine: true,
    );

    for (final file in files) {
      final content = file.readAsStringSync();
      staticCount += testDeclRegex.allMatches(content).length;
    }
    observedCount = staticCount;
  }

  stdout
    ..writeln('========================================')
    ..writeln('Automated Test Count Baseline Guard')
    ..writeln('========================================')
    ..writeln('Baseline Required: $baselineCount')
    ..writeln('Observed Count:    $observedCount')
    ..writeln('========================================');

  if (observedCount < baselineCount) {
    stderr
      ..writeln(
        'GATE FAILED: Test count ($observedCount) dropped below '
        'baseline ($baselineCount).',
      )
      ..writeln(
        'No test weakening or test deletion is permitted without '
        'explicit justification.',
      );
    exit(1);
  }

  stdout.writeln('GATE PASSED: Test count satisfies baseline requirements.');
}
