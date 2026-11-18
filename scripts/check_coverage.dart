import 'dart:io';

/// Enforces the coverage gate: test coverage for domain and data layers
/// (`lib/core/`, `lib/features/*/domain/`, `lib/features/*/data/`)
/// must be at least 80%.
void main(List<String> args) {
  final lcovFile = File('coverage/lcov.info');
  if (!lcovFile.existsSync()) {
    stderr.writeln(
      'Error: coverage/lcov.info not found. '
      'Run `flutter test --coverage` before running this check.',
    );
    exit(1);
  }

  final lines = lcovFile.readAsLinesSync();
  String? currentFile;
  var currentFound = 0;
  var currentHit = 0;

  var totalFound = 0;
  var totalHit = 0;

  final featureStats = <String, ({int found, int hit})>{};

  bool isTargetLayer(String path) {
    final normalized = path.replaceAll(r'\', '/');
    if (normalized.endsWith('.g.dart') ||
        normalized.endsWith('.freezed.dart') ||
        normalized.contains('/core/local/tables/') ||
        normalized.contains('/l10n/')) {
      return false;
    }

    if (normalized.startsWith('lib/core/')) {
      return true;
    }

    final match =
        RegExp('^lib/features/([^/]+)/(domain|data)/').firstMatch(normalized);
    return match != null;
  }

  String extractCategory(String path) {
    final normalized = path.replaceAll(r'\', '/');
    if (normalized.startsWith('lib/core/')) {
      return 'core';
    }
    final match = RegExp('^lib/features/([^/]+)/').firstMatch(normalized);
    if (match != null) {
      return match.group(1)!;
    }
    return 'other';
  }

  void processRecord() {
    if (currentFile != null && isTargetLayer(currentFile!)) {
      totalFound += currentFound;
      totalHit += currentHit;

      final cat = extractCategory(currentFile!);
      final prev = featureStats[cat] ?? (found: 0, hit: 0);
      featureStats[cat] = (
        found: prev.found + currentFound,
        hit: prev.hit + currentHit,
      );
    }
    currentFile = null;
    currentFound = 0;
    currentHit = 0;
  }

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).trim();
    } else if (line.startsWith('LF:')) {
      currentFound = int.tryParse(line.substring(3).trim()) ?? 0;
    } else if (line.startsWith('LH:')) {
      currentHit = int.tryParse(line.substring(3).trim()) ?? 0;
    } else if (line == 'end_of_record') {
      processRecord();
    }
  }

  if (totalFound == 0) {
    stderr.writeln('Error: No target domain/data layer lines found in lcov.');
    exit(1);
  }

  final percentage = (totalHit / totalFound) * 100;
  stdout
    ..writeln('========================================')
    ..writeln('Domain & Data Layers Coverage Gate')
    ..writeln('========================================');
  featureStats.forEach((cat, stat) {
    final catPct = stat.found == 0 ? 0.0 : (stat.hit / stat.found) * 100;
    stdout.writeln(
      '  - ${cat.padRight(16)}: ${catPct.toStringAsFixed(1)}% '
      '(${stat.hit}/${stat.found} lines)',
    );
  });
  stdout
    ..writeln('----------------------------------------')
    ..writeln(
      'Overall Target Coverage: ${percentage.toStringAsFixed(2)}% '
      '($totalHit / $totalFound lines)',
    )
    ..writeln('Required Threshold:      80.00%')
    ..writeln('========================================');

  if (percentage < 80.0) {
    stderr.writeln(
      'GATE FAILED: Test coverage of domain and data layers '
      '(${percentage.toStringAsFixed(2)}%) is below the 80.0% threshold.',
    );
    exit(1);
  }

  stdout.writeln('GATE PASSED: Coverage satisfies >= 80% requirement.');
}
