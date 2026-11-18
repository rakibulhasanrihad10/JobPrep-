import 'dart:io';

import 'release_notes_lib.dart';

/// Generates Markdown release notes combining `CHANGELOG.md` and Conventional
/// Commits between the previous tag and `--tag=<tag>`.
Future<void> main(List<String> args) async {
  var tag = _readArg(args, '--tag');
  final outputPath = _readArg(args, '--output');
  final changelogPath = _readArg(args, '--changelog') ?? 'CHANGELOG.md';
  var previousTag = _readArg(args, '--previous-tag');
  final repoSlug =
      _readArg(args, '--repo') ?? Platform.environment['GITHUB_REPOSITORY'];

  tag ??= await _runGit(['describe', '--tags', '--exact-match', 'HEAD']);
  if (tag == null || tag.isEmpty) {
    stderr.writeln('Pass --tag=<vX.Y.Z> or run from an exact tagged commit.');
    exit(64);
  }

  previousTag ??= await _findPreviousTag(tag);

  final range = (previousTag != null && previousTag.isNotEmpty)
      ? '$previousTag..$tag'
      : tag;
  final rawLog = await _runGit(
        ['log', '--no-merges', '--format=%h\t%s', range],
      ) ??
      await _runGit(['log', '--no-merges', '--format=%h\t%s', '-n', '30']) ??
      '';

  final commits = parseConventionalCommits(rawLog.split(RegExp(r'\r?\n')));

  var changelogSection = '';
  final changelogFile = File(changelogPath);
  if (changelogFile.existsSync()) {
    changelogSection = extractChangelogSection(
      changelogFile.readAsStringSync(),
      tag,
    );
  }

  final notes = renderReleaseNotes(
    tag: tag,
    commits: commits,
    previousTag: previousTag,
    changelogSection: changelogSection,
    repositorySlug: repoSlug,
  );

  if (outputPath != null && outputPath.isNotEmpty) {
    final outFile = File(outputPath);
    outFile.parent.createSync(recursive: true);
    outFile.writeAsStringSync(notes);
    stdout.writeln('Wrote release notes to $outputPath');
  } else {
    stdout.write(notes);
  }
}

String? _readArg(List<String> args, String prefix) {
  final withEq = '$prefix=';
  for (final arg in args) {
    if (arg.startsWith(withEq)) {
      return arg.substring(withEq.length).trim();
    }
  }
  return null;
}

Future<String?> _findPreviousTag(String currentTag) async {
  final raw = await _runGit(['tag', '--sort=-v:refname']);
  if (raw == null || raw.isEmpty) return null;
  final tags = raw
      .split(RegExp(r'\r?\n'))
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty && t != currentTag)
      .toList();
  return tags.isEmpty ? null : tags.first;
}

Future<String?> _runGit(List<String> gitArgs) async {
  final res = await Process.run('git', gitArgs);
  if (res.exitCode != 0) return null;
  return (res.stdout as String).trim();
}
