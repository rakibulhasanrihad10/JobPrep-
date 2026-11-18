import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/local/local_database_provider.dart';
import 'package:job_prep/core/storage/persistent_storage_service.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level operating mode of the application.
enum AppMode {
  /// User signed in with an authenticated account (backed by Supabase cloud).
  signedIn,

  /// User continuing without an account (backed by device-local Drift).
  guest;

  /// Whether current mode is guest mode.
  bool get isGuest => this == AppMode.guest;

  /// Whether current mode is signed-in account mode.
  bool get isSignedIn => this == AppMode.signedIn;
}

/// Riverpod notifier persisting and coordinating [AppMode].
class AppModeNotifier extends Notifier<AppMode?> {
  /// SharedPreferences key for persisted application mode.
  static const String storageKey = 'jobprep_app_mode';

  @override
  AppMode? build() {
    SharedPreferences? prefs;
    try {
      prefs = ref.watch(sharedPreferencesProvider);
    } on Object catch (_) {
      prefs = null;
    }
    final saved = prefs?.getString(storageKey);
    final authState = ref.watch(authSessionProvider);

    if (saved == 'guest') {
      return AppMode.guest;
    }

    if (authState.status == AuthStatus.signedIn || saved == 'signedIn') {
      return AppMode.signedIn;
    }

    return null;
  }

  /// Sets the app mode to guest, switches DataSourceMode to local,
  /// saves the mode in shared_preferences, and requests web persistent storage.
  Future<void> enterGuestMode() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(storageKey, 'guest');
    await ref.read(persistentStorageServiceProvider).requestPersistence();
    state = AppMode.guest;
  }

  /// Sets the app mode to signedIn, switches DataSourceMode to cloud,
  /// and saves the mode in shared_preferences.
  Future<void> setSignedIn() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(storageKey, 'signedIn');
    state = AppMode.signedIn;
  }

  /// Clears persisted app mode (e.g. on sign out or full data reset).
  Future<void> clearMode() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(storageKey);
    state = null;
  }

  /// Wipes all local SQLite tables, removes saved mode, and resets state.
  Future<void> eraseAllData() async {
    final db = ref.read(appDatabaseProvider);
    await db.eraseAllData();
    await clearMode();
  }
}

/// Provides the active [AppMode] (`signedIn`, `guest`, or `null`).
final appModeProvider = NotifierProvider<AppModeNotifier, AppMode?>(
  AppModeNotifier.new,
);
