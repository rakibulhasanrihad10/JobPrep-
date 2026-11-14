import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Supported data source execution targets for application repositories.
enum DataSourceMode {
  /// Cloud repository implementations communicating with Supabase PostgreSQL.
  cloud,

  /// Device-local repository implementations backed by Drift SQLite / Wasm.
  local,
}

/// Riverpod notifier managing the active [DataSourceMode].
class DataSourceModeNotifier extends Notifier<DataSourceMode> {
  @override
  DataSourceMode build() => DataSourceMode.cloud;

  /// Switches the active repository target mode.
  void setMode(DataSourceMode mode) {
    if (state != mode) {
      state = mode;
    }
  }

  /// Sets the active mode to local device storage.
  void useLocal() => setMode(DataSourceMode.local);

  /// Sets the active mode to cloud Supabase storage.
  void useCloud() => setMode(DataSourceMode.cloud);
}

/// Provides the active [DataSourceMode] consumed exclusively by repository
/// factory providers.
final dataSourceModeProvider =
    NotifierProvider<DataSourceModeNotifier, DataSourceMode>(
  DataSourceModeNotifier.new,
);
