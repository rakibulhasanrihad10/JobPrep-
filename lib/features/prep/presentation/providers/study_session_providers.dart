import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/core/supabase/supabase_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/prep/data/repositories/supabase_study_session_repository.dart';
import 'package:job_prep/features/prep/data/repositories/unconfigured_study_session_repository.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/repositories/study_session_repository.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_progress_log_controller.dart';

Duration? _noRetry(int retryCount, Object error) => null;

/// Storage keys persisting study timer preferences cleanly across reloads.
const String kPomodoroFocusMinutesKey = 'prep_pomodoro_focus_min';
const String kPomodoroShortBreakMinutesKey = 'prep_pomodoro_short_break_min';
const String kPomodoroLongBreakMinutesKey = 'prep_pomodoro_long_break_min';
const String kTimerSoundEnabledKey = 'prep_timer_sound_enabled';

/// Injectable clock for Study Timer calculations & timestamp assertions.
final Provider<DateTime Function()> studyTimerNowProvider =
    Provider<DateTime Function()>((ref) => ref.watch(prepNowProvider));

/// Repository provider resolving `study_sessions` storage cleanly.
final Provider<StudySessionRepository> studySessionRepositoryProvider =
    Provider<StudySessionRepository>((ref) {
  final client = ref.watch(optionalSupabaseClientProvider);
  if (client == null) {
    return const UnconfiguredStudySessionRepository();
  }
  return SupabaseStudySessionRepository(client);
});

/// Loads and caches all saved/active [StudySession] records for the user.
class StudySessionsNotifier extends AsyncNotifier<List<StudySession>> {
  @override
  Future<List<StudySession>> build() {
    ref.watch(currentUserProvider.select((user) => user?.id));
    final repo = ref.watch(studySessionRepositoryProvider);
    return repo.getStudySessions();
  }

  /// Refreshes the study sessions list from persistence.
  Future<void> refresh() async {
    state = const AsyncLoading<List<StudySession>>();
    state = await AsyncValue.guard(() {
      final repo = ref.read(studySessionRepositoryProvider);
      return repo.getStudySessions();
    });
  }

  /// Inserts or updates [session] in the local cached list cleanly.
  void upsertLocal(StudySession session) {
    final current = state.asData?.value;
    if (current == null) {
      state = AsyncData<List<StudySession>>([session]);
      return;
    }
    final next = <StudySession>[
      for (final existing in current)
        if (existing.id != session.id) existing,
      session,
    ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    state =
        AsyncData<List<StudySession>>(List<StudySession>.unmodifiable(next));
  }

  /// Removes session with [id] from the local cached list.
  void removeLocal(String id) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData<List<StudySession>>(
      List<StudySession>.unmodifiable(
        current.where((s) => s.id != id),
      ),
    );
  }
}

/// Provides all persisted [StudySession] rows ordered newest-first.
final AsyncNotifierProvider<StudySessionsNotifier, List<StudySession>>
    studySessionsProvider =
    AsyncNotifierProvider<StudySessionsNotifier, List<StudySession>>(
  StudySessionsNotifier.new,
  retry: _noRetry,
);

/// Manages persisted Pomodoro duration settings (defaults: 25 / 5 / 15 min).
class PomodoroConfigNotifier extends Notifier<PomodoroConfig> {
  @override
  PomodoroConfig build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final focus = prefs.getInt(kPomodoroFocusMinutesKey) ?? 25;
    final shortBreak = prefs.getInt(kPomodoroShortBreakMinutesKey) ?? 5;
    final longBreak = prefs.getInt(kPomodoroLongBreakMinutesKey) ?? 15;
    return const PomodoroConfig().copyWith(
      focusMinutes: focus,
      shortBreakMinutes: shortBreak,
      longBreakMinutes: longBreak,
    );
  }

  /// Updates and persists Pomodoro interval lengths cleanly.
  Future<void> updateConfig(PomodoroConfig next) async {
    final normalized = next.copyWith();
    state = normalized;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(kPomodoroFocusMinutesKey, normalized.focusMinutes);
    await prefs.setInt(
      kPomodoroShortBreakMinutesKey,
      normalized.shortBreakMinutes,
    );
    await prefs.setInt(
      kPomodoroLongBreakMinutesKey,
      normalized.longBreakMinutes,
    );
  }
}

/// Provides configurable [PomodoroConfig] persisted across restarts.
final NotifierProvider<PomodoroConfigNotifier, PomodoroConfig>
    pomodoroConfigProvider =
    NotifierProvider<PomodoroConfigNotifier, PomodoroConfig>(
  PomodoroConfigNotifier.new,
);

/// Persists optional gentle alert chime toggle (`true` by default).
class TimerSoundEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(kTimerSoundEnabledKey) ?? true;
  }

  /// Sets whether completing a Pomodoro phase plays a soft sound.
  Future<void> setEnabled({required bool enabled}) async {
    state = enabled;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(kTimerSoundEnabledKey, enabled);
  }
}

/// Provides the optional soft sound preference (`true` by default).
final NotifierProvider<TimerSoundEnabledNotifier, bool>
    timerSoundEnabledProvider =
    NotifierProvider<TimerSoundEnabledNotifier, bool>(
  TimerSoundEnabledNotifier.new,
);
