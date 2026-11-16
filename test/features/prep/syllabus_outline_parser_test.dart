import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/features/prep/domain/utils/syllabus_outline_parser.dart';

void main() {
  group('SyllabusOutlineParser', () {
    test('parses empty input to empty outline', () {
      final outline = SyllabusOutlineParser.parse('');
      expect(outline.isEmpty, isTrue);
      expect(outline.totalTopics, 0);
      expect(outline.chapters, isEmpty);
      expect(outline.unassignedTopics, isEmpty);
    });

    test('parses chapters and dashed topics correctly', () {
      const input = '''
Chapter 1: Number Systems
- Prime Numbers
- Divisibility Rules
- Greatest Common Divisor (GCD)

Chapter 2: Geometry
* Triangles and Pythagoras Theorem
• Circles and Tangents
''';

      final outline = SyllabusOutlineParser.parse(input);
      expect(outline.isEmpty, isFalse);
      expect(outline.chapters.length, 2);
      expect(outline.totalTopics, 5);

      final c1 = outline.chapters[0];
      expect(c1.title, 'Chapter 1: Number Systems');
      expect(c1.topics, [
        'Prime Numbers',
        'Divisibility Rules',
        'Greatest Common Divisor (GCD)',
      ]);

      final c2 = outline.chapters[1];
      expect(c2.title, 'Chapter 2: Geometry');
      expect(c2.topics, [
        'Triangles and Pythagoras Theorem',
        'Circles and Tangents',
      ]);
      expect(outline.unassignedTopics, isEmpty);
    });

    test('collects topics before any chapter header into unassignedTopics', () {
      const input = '''
- Introduction & Warm-up
- Basic Diagnostic Test

First Real Chapter
- Subtopic 1
''';

      final outline = SyllabusOutlineParser.parse(input);
      expect(outline.unassignedTopics, [
        'Introduction & Warm-up',
        'Basic Diagnostic Test',
      ]);
      expect(outline.chapters.length, 1);
      expect(outline.chapters[0].title, 'First Real Chapter');
      expect(outline.chapters[0].topics, ['Subtopic 1']);
      expect(outline.totalTopics, 3);
    });

    test(
        'handles empty lines, extra spaces, and empty topic bullets gracefully',
        () {
      const input = '''


Chapter with empty bullets
- 
* Valid Topic
• 


''';

      final outline = SyllabusOutlineParser.parse(input);
      expect(outline.chapters.length, 1);
      expect(outline.chapters[0].title, 'Chapter with empty bullets');
      expect(outline.chapters[0].topics, ['Valid Topic']);
    });
  });
}
