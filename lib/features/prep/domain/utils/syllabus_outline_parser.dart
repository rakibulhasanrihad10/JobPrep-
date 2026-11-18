import 'package:flutter/foundation.dart' show immutable, listEquals;

/// A parsed chapter and its nested topics from a pasted syllabus text outline.
@immutable
class ParsedOutlineChapter {
  /// Creates a [ParsedOutlineChapter].
  const ParsedOutlineChapter({
    required this.title,
    this.topics = const [],
  });

  /// Chapter title parsed from an unindented header line.
  final String title;

  /// Ordered topic titles parsed under this chapter.
  final List<String> topics;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParsedOutlineChapter &&
        other.title == title &&
        listEquals(other.topics, topics);
  }

  @override
  int get hashCode => Object.hash(title, Object.hashAll(topics));
}

/// Structured outcome of parsing a line-delimited syllabus outline.
@immutable
class ParsedSyllabusOutline {
  /// Creates a [ParsedSyllabusOutline].
  const ParsedSyllabusOutline({
    this.chapters = const [],
    this.unassignedTopics = const [],
  });

  /// Chapters and their nested topics.
  final List<ParsedOutlineChapter> chapters;

  /// Topics appearing before the first chapter header.
  final List<String> unassignedTopics;

  /// Whether no valid chapters or topics were discovered in input.
  bool get isEmpty => chapters.isEmpty && unassignedTopics.isEmpty;

  /// Total count of topics across all chapters and unassigned sections.
  int get totalTopics =>
      unassignedTopics.length +
      chapters.fold(0, (sum, c) => sum + c.topics.length);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParsedSyllabusOutline &&
        listEquals(other.chapters, chapters) &&
        listEquals(other.unassignedTopics, unassignedTopics);
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(chapters), Object.hashAll(unassignedTopics));
}

/// Parses multi-line pasted plain text into structured chapters and topics.
///
/// Lines without a leading dash become chapters; lines starting with a dash
/// (`-`) or bullet point become topics under the preceding chapter.
abstract final class SyllabusOutlineParser {
  /// Parses [rawText] into a [ParsedSyllabusOutline].
  static ParsedSyllabusOutline parse(String rawText) {
    final lines = rawText.split('\n');
    final chapters = <ParsedOutlineChapter>[];
    final unassignedTopics = <String>[];

    String? currentChapterTitle;
    var currentTopics = <String>[];

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final isTopic =
          line.startsWith('-') || line.startsWith('*') || line.startsWith('•');

      if (isTopic) {
        final topicTitle = line.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim();
        if (topicTitle.isEmpty) continue;

        if (currentChapterTitle == null) {
          unassignedTopics.add(topicTitle);
        } else {
          currentTopics.add(topicTitle);
        }
      } else {
        if (currentChapterTitle != null) {
          chapters.add(
            ParsedOutlineChapter(
              title: currentChapterTitle,
              topics: List.unmodifiable(currentTopics),
            ),
          );
          currentTopics = <String>[];
        }
        currentChapterTitle = line;
      }
    }

    if (currentChapterTitle != null) {
      chapters.add(
        ParsedOutlineChapter(
          title: currentChapterTitle,
          topics: List.unmodifiable(currentTopics),
        ),
      );
    }

    return ParsedSyllabusOutline(
      chapters: List.unmodifiable(chapters),
      unassignedTopics: List.unmodifiable(unassignedTopics),
    );
  }
}
