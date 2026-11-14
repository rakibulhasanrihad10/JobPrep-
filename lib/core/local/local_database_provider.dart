import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/local/database/app_database.dart';

/// Provides the singleton [AppDatabase] instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() {
    unawaited(db.close());
  });
  return db;
});
