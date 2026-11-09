import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to persist reduce effects preference in [SharedPreferences].
const String kReduceEffectsStorageKey = 'jobprep_reduce_effects';

/// Riverpod notifier managing reduce effects preference.
class ReduceEffectsNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(kReduceEffectsStorageKey) ?? false;
  }

  /// Sets and persists reduce effects preference.
  Future<void> setReduceEffects({required bool enabled}) async {
    state = enabled;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(kReduceEffectsStorageKey, enabled);
  }

  /// Toggles reduce effects preference.
  Future<void> toggle() async {
    await setReduceEffects(enabled: !state);
  }
}

/// Provider for reduce effects preference.
final reduceEffectsProvider =
    NotifierProvider<ReduceEffectsNotifier, bool>(ReduceEffectsNotifier.new);
