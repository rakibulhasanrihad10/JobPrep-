import 'dart:io';

/// Quality Gate: Detects hardcoded user-facing strings in presentation widgets.
///
/// Scans UI widget files in `lib/features/.../presentation` and `lib/shared`
/// to ensure all user-visible strings come from `AppLocalizations` (ARB files).
void main(List<String> args) {
  final targetDirs = args.isNotEmpty
      ? args.map(Directory.new).toList()
      : [
          Directory('lib/features'),
          Directory('lib/shared'),
        ];

  final violations = findHardcodedStrings(targetDirs);

  if (violations.isNotEmpty) {
    stderr.writeln(
      '❌ Hardcoded user-facing string check failed! '
      'Found ${violations.length} violation(s):',
    );
    for (final violation in violations) {
      stderr.writeln('  $violation');
    }
    stderr.writeln(
      '\nUse AppLocalizations (ARB files: lib/l10n/app_en.arb and app_bn.arb) '
      'instead of hardcoded strings in widgets.',
    );
    exit(1);
  }

  stdout.writeln(
    '✅ Hardcoded user-facing strings check passed '
    '(no hardcoded strings in widgets).',
  );
  exit(0);
}

/// Scans [targetDirs] and returns a list of error strings for each hardcoded
/// user-facing string found.
List<String> findHardcodedStrings(List<Directory> targetDirs) {
  final violations = <String>[];

  // Regex patterns detecting hardcoded string literals in UI widgets.
  final textPattern = RegExp(
    r'''(?:const\s+)?Text\(\s*['"]([^'"]+)['"]''',
  );
  final textSpanPattern = RegExp(
    r'''TextSpan\(\s*text:\s*['"]([^'"]+)['"]''',
  );
  final tooltipPattern = RegExp(
    r'''Tooltip\(\s*message:\s*['"]([^'"]+)['"]''',
  );

  for (final dir in targetDirs) {
    if (!dir.existsSync()) continue;

    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;

      // Only check presentation files or shared widgets
      final normalizedPath = entity.path.replaceAll(r'\', '/');
      final isPresentation = normalizedPath.contains('/presentation/') ||
          normalizedPath.contains('lib/shared/');
      if (!isPresentation) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trim();

        // Allow explicit suppression comments
        if (trimmed.contains('// ignore: hardcoded_strings') ||
            trimmed.contains('// hardcoded-ok')) {
          continue;
        }

        // Check Text('...')
        final textMatch = textPattern.firstMatch(line);
        if (textMatch != null) {
          final textContent = textMatch.group(1) ?? '';
          if (_isUserFacingText(textContent)) {
            violations.add(
              '${entity.path}:${i + 1} Hardcoded Text("$textContent") found.',
            );
          }
        }

        // Check TextSpan(text: '...')
        final spanMatch = textSpanPattern.firstMatch(line);
        if (spanMatch != null) {
          final spanContent = spanMatch.group(1) ?? '';
          if (_isUserFacingText(spanContent)) {
            violations.add(
              '${entity.path}:${i + 1} '
              'Hardcoded TextSpan(text: "$spanContent") found.',
            );
          }
        }

        // Check Tooltip(message: '...')
        final tooltipMatch = tooltipPattern.firstMatch(line);
        if (tooltipMatch != null) {
          final tooltipContent = tooltipMatch.group(1) ?? '';
          if (_isUserFacingText(tooltipContent)) {
            violations.add(
              '${entity.path}:${i + 1} '
              'Hardcoded Tooltip(message: "$tooltipContent") found.',
            );
          }
        }
      }
    }
  }

  return violations;
}

/// Returns true if [content] contains human-readable alphabetic or
/// Bengali characters.
bool _isUserFacingText(String content) {
  final trimmed = content.trim();
  if (trimmed.isEmpty) return false;
  // Exclude single symbols, pure punctuation, or format symbols
  return RegExp(r'[a-zA-Z\u0980-\u09FF]').hasMatch(trimmed);
}
