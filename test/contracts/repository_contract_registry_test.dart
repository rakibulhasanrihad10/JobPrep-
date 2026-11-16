import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Repository Contract Registry Tests', () {
    // Registered domain repository interfaces and contract test suites
    final repositoryContracts = <String, String>{
      'CircularRepository':
          'test/contracts/circular_repository_contract_test.dart',
      'ExamDateRepository':
          'test/contracts/exam_date_repository_contract_test.dart',
      'SubjectRepository':
          'test/contracts/prep_repositories_contract_test.dart',
      'ChapterRepository':
          'test/contracts/chapter_repository_contract_test.dart',
      'MaterialRepository':
          'test/contracts/prep_repositories_contract_test.dart',
      'ProgressLogRepository':
          'test/contracts/prep_repositories_contract_test.dart',
      'TopicRepository': 'test/contracts/prep_repositories_contract_test.dart',
      'StudyPlanRepository':
          'test/contracts/auxiliary_repositories_contract_test.dart',
      'MockTestRepository':
          'test/contracts/auxiliary_repositories_contract_test.dart',
      'RevisionItemRepository':
          'test/contracts/auxiliary_repositories_contract_test.dart',
      'StudySessionRepository':
          'test/contracts/auxiliary_repositories_contract_test.dart',
      'NotificationsRepository':
          'test/contracts/notifications_repository_contract_test.dart',
      'UserSettingsRepository':
          'test/contracts/settings_repository_contract_test.dart',
      'ReminderSettingsRepository':
          'test/contracts/settings_repository_contract_test.dart',
      'PortalAccountRepository':
          'test/contracts/vault_repository_contract_test.dart',
    };

    test(
      'every data repository interface is registered in the contract registry',
      () {
        final domainDir = Directory('lib');
        final repoFiles = domainDir
            .listSync(recursive: true)
            .whereType<File>()
            .where(
              (f) =>
                  f.path.contains('/domain/repositories/') &&
                  f.path.endsWith('_repository.dart'),
            )
            .toList();

        final interfaceRegex = RegExp(
          r'abstract\s+(?:interface\s+)?class\s+([A-Za-z0-9]+Repository)',
        );

        final discoveredInterfaces = <String>{};
        for (final file in repoFiles) {
          final content = file.readAsStringSync();
          for (final match in interfaceRegex.allMatches(content)) {
            final name = match.group(1)!;
            // Specialized account-only or asset-only repositories excluded
            if (name != 'AuthRepository' &&
                name != 'BackupRepository' &&
                name != 'CircularFileRepository' &&
                name != 'MaterialCoverRepository' &&
                name != 'PrepTemplateRepository' &&
                name != 'OnboardingRepository') {
              discoveredInterfaces.add(name);
            }
          }
        }

        for (final interfaceName in discoveredInterfaces) {
          expect(
            repositoryContracts.containsKey(interfaceName),
            isTrue,
            reason: 'Repository interface $interfaceName must have a '
                'registered contract suite',
          );
        }
      },
    );

    test(
      'every contract suite file exists and covers both implementations',
      () {
        final suiteFiles = repositoryContracts.values.toSet();

        for (final suitePath in suiteFiles) {
          final file = File(suitePath);
          expect(
            file.existsSync(),
            isTrue,
            reason: 'Contract suite file $suitePath must exist on disk',
          );

          final content = file.readAsStringSync();

          // Must run against Local implementation
          expect(
            content,
            contains('Local Implementation Contract'),
            reason: '$suitePath must execute contract tests against Local '
                'implementation',
          );

          // Must run against Supabase implementation
          expect(
            content,
            contains('Supabase Implementation Contract'),
            reason: '$suitePath must execute contract tests against Supabase '
                'implementation',
          );
        }
      },
    );
  });
}
