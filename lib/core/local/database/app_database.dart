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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}
