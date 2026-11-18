import 'package:job_prep/features/prep/domain/utils/syllabus_outline_parser.dart';

/// Finds sample/example syllabus outlines for subjects based on starter templates.
abstract final class TemplateOutlineFinder {
  static const Map<String, List<ParsedOutlineChapter>> _knownOutlines = {
    'bengali': [
      ParsedOutlineChapter(
        title: 'Bengali Grammar (Example Outline)',
        topics: [
          'Phonetics, Sound Changes & Pronunciation Rules',
          'Sandhi, Samas & Word Formation',
          'Spelling Accuracy (Bangla Academy Rules)',
          'Sentence Structures, Transformations & Idioms',
          'Vocabulary: Synonyms, Antonyms & One-Word Substitutions',
        ],
      ),
      ParsedOutlineChapter(
        title: 'Bengali Literature (Example Outline)',
        topics: [
          'Ancient & Medieval Period (Charyapada, Mangalkavya)',
          'Modern Period Classics (Tagore, Nazrul, Madhusudan)',
          'Notable Literary Journals, Periodicals & Dramas',
        ],
      ),
    ],
    'general knowledge': [
      ParsedOutlineChapter(
        title: 'Bangladesh Affairs (Example Outline)',
        topics: [
          'Historical Evolution & Liberation War (1947–1971)',
          'Constitution, Governance & Administrative Structure',
          'Geography, Resources & Economic Indicators',
        ],
      ),
      ParsedOutlineChapter(
        title: 'International Affairs (Example Outline)',
        topics: [
          'Global Geopolitics, Alliances & Treaties',
          'International Organizations (UN, WTO, IMF, World Bank)',
          'Major Environmental Treaties & Global Summits',
        ],
      ),
    ],
    'data structures': [
      ParsedOutlineChapter(
        title: 'Core Data Structures (Example Outline)',
        topics: [
          'Arrays, Dynamic Sizing & Strings',
          'Hash Maps, Sets & Collision Handling',
          'Singly & Doubly Linked Lists',
          'Stacks, Monotonic Queues & Deques',
          'Trees, Heaps & Priority Queues',
        ],
      ),
      ParsedOutlineChapter(
        title: 'Algorithmic Techniques (Example Outline)',
        topics: [
          'Two Pointers & Sliding Window',
          'Binary Search on Value Spaces',
          'Breadth-First Search & Depth-First Search',
          'Dynamic Programming Memoization & Tabulation',
        ],
      ),
    ],
    'system design': [
      ParsedOutlineChapter(
        title: 'Distributed Building Blocks (Example Outline)',
        topics: [
          'Load Balancers, Reverse Proxies & CDN Caching',
          'Database Sharding, Replication & CAP Theorem',
          'Message Brokers & Event-Driven Pipelines (Kafka, RabbitMQ)',
        ],
      ),
      ParsedOutlineChapter(
        title: 'Real-World Architecture Scenarios (Example Outline)',
        topics: [
          'Designing a Distributed Rate Limiter',
          'Designing a URL Shortener with High Availability',
          'Designing a Scalable Notification Service',
        ],
      ),
    ],
  };

  /// Finds an example outline for [subjectName]. Falls back to a structured
  /// default starter outline if no specific match is found.
  static ParsedSyllabusOutline findExampleOutline(String subjectName) {
    final normalized = subjectName.trim().toLowerCase();

    for (final entry in _knownOutlines.entries) {
      if (normalized.contains(entry.key)) {
        return ParsedSyllabusOutline(chapters: entry.value);
      }
    }

    if (normalized.contains('gk') || normalized.contains('bangladesh')) {
      return const ParsedSyllabusOutline(
        chapters: [
          ParsedOutlineChapter(
            title: 'Foundational Concepts (Example Outline)',
            topics: [
              'Core Principles & Key Terminology',
              'Historical Milestones & Frameworks',
              'Applications & Case Studies',
            ],
          ),
          ParsedOutlineChapter(
            title: 'Advanced Applications (Example Outline)',
            topics: [
              'Standard Problem Formulations',
              'Past Exam Question Patterns',
              'High-Yield Quick Revision Points',
            ],
          ),
        ],
      );
    }

    return ParsedSyllabusOutline(
      chapters: [
        ParsedOutlineChapter(
          title: '$subjectName Foundations (Example Outline)',
          topics: const [
            'Core Fundamentals & Definitions',
            'Standard Methodologies & Concepts',
            'Practice Problems & Exercises',
          ],
        ),
        ParsedOutlineChapter(
          title: '$subjectName Advanced Topics (Example Outline)',
          topics: const [
            'In-Depth Analysis & Complex Problem Solving',
            'Past Exam Patterns & Common Pitfalls',
            'Speed Drills & Final Review',
          ],
        ),
      ],
    );
  }
}
