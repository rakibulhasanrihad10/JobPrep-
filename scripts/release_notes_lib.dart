/// Parsed Conventional Commit entry used to build release notes.
class ParsedCommit {
  /// Creates a [ParsedCommit].
  const ParsedCommit({
    required this.hash,
    required this.type,
    required this.description,
    this.scope,
    this.isBreaking = false,
  });

  /// Short git commit hash.
  final String hash;

  /// Conventional Commit type (`feat`, `fix`, `perf`, `docs`, etc.).
  final String type;

  /// Optional commit scope in parentheses.
  final String? scope;

  /// Commit subject summary after `<type>(<scope>): `.
  final String description;

  /// Whether commit header included `!` breaking indicator.
  final bool isBreaking;
}

final RegExp _conventionalHeaderPattern = RegExp(
  r'^([a-z]+)(?:\(([^)]+)\))?(!)?:\s+(.+)$',
);

/// Parses `git log --format=%h%x09%s` lines into structured [ParsedCommit]s.
List<ParsedCommit> parseConventionalCommits(Iterable<String> lines) {
  final commits = <ParsedCommit>[];
  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final tabIdx = line.indexOf('\t');
    final hash = tabIdx > 0 ? line.substring(0, tabIdx).trim() : '';
    final subject = tabIdx > 0 ? line.substring(tabIdx + 1).trim() : line;
    final match = _conventionalHeaderPattern.firstMatch(subject);
    if (match == null) {
      commits.add(
        ParsedCommit(
          hash: hash,
          type: 'other',
          description: subject,
        ),
      );
      continue;
    }

    commits.add(
      ParsedCommit(
        hash: hash,
        type: match.group(1)!.toLowerCase(),
        scope: match.group(2)?.trim(),
        isBreaking: match.group(3) == '!',
        description: match.group(4)!.trim(),
      ),
    );
  }
  return commits;
}

/// Extracts the section matching [versionTag] (or `Unreleased` fallback) from
/// a Keep-a-Changelog formatted [markdown] string.
String extractChangelogSection(String markdown, String versionTag) {
  final normalizedTarget =
      versionTag.trim().replaceFirst(RegExp('^v'), '').toLowerCase();
  final lines = markdown.split(RegExp(r'\r?\n'));
  final headingPattern = RegExp(r'^##\s+\[([^\]]+)\]');

  String? extractForHeading(bool Function(String heading) matcher) {
    var collecting = false;
    final buffer = <String>[];
    for (final line in lines) {
      final headingMatch = headingPattern.firstMatch(line.trim());
      if (headingMatch != null) {
        if (collecting) break;
        final label = headingMatch
            .group(1)!
            .trim()
            .replaceFirst(RegExp('^v'), '')
            .toLowerCase();
        if (matcher(label)) {
          collecting = true;
          continue;
        }
      } else if (collecting) {
        buffer.add(line);
      }
    }
    final text = buffer.join('\n').trim();
    return text.isEmpty ? null : text;
  }

  return extractForHeading((label) => label == normalizedTarget) ??
      extractForHeading((label) => label == 'unreleased') ??
      '';
}

/// Renders structured Markdown release notes combining [changelogSection] and
/// grouped Conventional Commits since [previousTag].
String renderReleaseNotes({
  required String tag,
  required List<ParsedCommit> commits,
  String? previousTag,
  String changelogSection = '',
  String? repositorySlug,
}) {
  final out = StringBuffer()..writeln('# JobPrep $tag');

  final cleanChangelog = changelogSection.trim();
  if (cleanChangelog.isNotEmpty) {
    out
      ..writeln()
      ..writeln('## Changelog Highlights')
      ..writeln()
      ..writeln(cleanChangelog);
  }

  final breaking = commits.where((c) => c.isBreaking).toList();
  final features = commits.where((c) => c.type == 'feat').toList();
  final fixes = commits.where((c) => c.type == 'fix').toList();
  final perfRefactor =
      commits.where((c) => c.type == 'perf' || c.type == 'refactor').toList();
  final maintenance = commits
      .where(
        (c) =>
            c.type != 'feat' &&
            c.type != 'fix' &&
            c.type != 'perf' &&
            c.type != 'refactor',
      )
      .toList();

  void writeGroup(String title, List<ParsedCommit> items) {
    if (items.isEmpty) return;
    out
      ..writeln()
      ..writeln('## $title')
      ..writeln();
    for (final item in items) {
      final scopePrefix = item.scope != null && item.scope!.isNotEmpty
          ? '**${item.scope}:** '
          : '';
      final hashSuffix = item.hash.isNotEmpty ? ' (`${item.hash}`)' : '';
      out.writeln('- $scopePrefix${item.description}$hashSuffix');
    }
  }

  writeGroup('Breaking Changes', breaking);
  writeGroup('Features', features);
  writeGroup('Bug Fixes', fixes);
  writeGroup('Performance & Refactoring', perfRefactor);
  writeGroup('Tests, CI & Maintenance', maintenance);

  if (previousTag != null && previousTag.isNotEmpty) {
    out.writeln();
    if (repositorySlug != null && repositorySlug.isNotEmpty) {
      out.writeln(
        '**Full Changelog:** https://github.com/$repositorySlug/compare/$previousTag...$tag',
      );
    } else {
      out.writeln('**Previous Release:** `$previousTag`');
    }
  }

  return '${out.toString().trimRight()}\n';
}
