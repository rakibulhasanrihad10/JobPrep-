import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:job_prep/core/local/tables/auxiliary_tables.dart';
import 'package:job_prep/core/local/tables/circular_tables.dart';
import 'package:job_prep/core/local/tables/prep_tables.dart';

part 'app_database.g.dart';

/// Local SQLite database backed by Drift on Android and WebAssembly on Web.
@DriftDatabase(
  tables: [
    LocalCirculars,
    LocalCircularExamDates,
    LocalSubjects,
    LocalChapters,
    LocalMaterials,
    LocalProgressLogs,
    LocalTopics,
    LocalCircularSubjects,
    LocalStudyPlans,
    LocalMockTests,
    LocalRevisionItems,
    LocalStudySessions,
    LocalNotifications,
    LocalPortalAccounts,
    LocalUserSettings,
    LocalUserReminderSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates an [AppDatabase] optionally accepting a custom [executor]
  /// (for example in-memory for testing).
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _defaultExecutor());

  static QueryExecutor _defaultExecutor() {
    return driftDatabase(
      name: 'job_prep_local',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(localChapters);
            await m.addColumn(localSubjects, localSubjects.enabledCheckpoints);
            await m.addColumn(localTopics, localTopics.chapterId);
            await m.addColumn(localTopics, localTopics.title);
            await m.addColumn(localTopics, localTopics.sortOrder);
            await m.addColumn(localTopics, localTopics.weight);
            await m.addColumn(localTopics, localTopics.studyDoneAt);
            await m.addColumn(localTopics, localTopics.practiceDoneAt);
            await m.addColumn(localTopics, localTopics.modelTestDoneAt);
            await m.addColumn(localTopics, localTopics.revisionDoneAt);
            await m.addColumn(localTopics, localTopics.notes);
          }
        },
      );

  /// Completely wipes all local tables in a single transaction.
  Future<void> eraseAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}
