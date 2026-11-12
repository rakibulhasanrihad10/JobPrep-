import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/features/prep/data/mappers/study_session_mapper.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/utils/study_timer_calculator.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_timer_controller.dart';
import 'package:job_prep/features/prep/presentation/utils/timer_platform_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_study_session_repository.dart';

class _RecordingPlatformAdapter implements StudyTimerPlatformAdapter {
  final List<String> titles = <String>[];
  int restoreCalls = 0;
  int chimeCalls = 0;

  @override
  void setTabTitle(String title) => titles.add(title);

  @override
  void restoreTabTitle() => restoreCalls += 1;

  @override
  Future<void> playGentleChime() async => chimeCalls += 1;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StudyTimerCalculator pure duration, pauses & Pomodoro', () {
    test('computes active seconds from timestamps excluding pause intervals',
        () {
      final start = DateTime.utc(2026, 11, 11, 10);
      final now = DateTime.utc(2026, 11, 11, 10, 40); // 40m elapsed wall time
      final pauses = [
        PauseInterval(
          pausedAt: DateTime.utc(2026, 11, 11, 10, 10),
          resumedAt: DateTime.utc(2026, 11, 11, 10, 15), // 5m
        ),
        PauseInterval(
          pausedAt: DateTime.utc(2026, 11, 11, 10, 14), // overlaps previous!
          resumedAt: DateTime.utc(2026, 11, 11, 10, 20), // +5m net = 10m paused
        ),
      ];

      expect(
        StudyTimerCalculator.calculateActiveSeconds(
          startedAt: start,
          pauseIntervals: pauses,
          now: now,
        ),
        30 * 60,
      );

      // Open pause interval freezes elapsed time cleanly at pausedAt.
      final withOpenPause = [
        ...pauses,
        PauseInterval(pausedAt: DateTime.utc(2026, 11, 11, 10, 35)),
      ];
      expect(
        StudyTimerCalculator.calculateActiveSeconds(
          startedAt: start,
          pauseIntervals: withOpenPause,
          now: DateTime.utc(2026, 11, 11, 11, 30),
        ),
        25 * 60,
      );

      // Clamps safely to 0 when now precedes start.
      expect(
        StudyTimerCalculator.calculateActiveSeconds(
          startedAt: start,
          now: start.subtract(const Duration(minutes: 5)),
        ),
        0,
      );
    });

    test(
        'splits midnight-crossing sessions accurately by user local date and '
        'pause intervals', () {
      // Asia/Dhaka = UTC+6.
      // Start 2026-11-10T17:30:00Z = 2026-11-10 23:30:00 local.
      // End   2026-11-10T18:45:00Z = 2026-11-11 00:45:00 local.
      // Paused across midnight 23:45 -> 00:15 local (17:45Z -> 18:15Z):
      // Day 1 active = [23:30, 23:45] = 15m (900s)
      // Day 2 active = [00:15, 00:45] = 30m (1800s)
      const dhaka = Duration(hours: 6);
      final session = StudySession(
        id: 's-mid',
        userId: 'u-1',
        subjectId: 'sub-1',
        startedAt: DateTime.utc(2026, 11, 10, 17, 30),
        endedAt: DateTime.utc(2026, 11, 10, 18, 45),
        durationSeconds: 45 * 60,
        mode: StudySessionMode.stopwatch,
        pauseIntervals: [
          PauseInterval(
            pausedAt: DateTime.utc(2026, 11, 10, 17, 45),
            resumedAt: DateTime.utc(2026, 11, 10, 18, 15),
          ),
        ],
      );

      final splitDhaka = StudyTimerCalculator.splitSessionByLocalDate(
        session,
        localOffset: dhaka,
      );
      expect(splitDhaka[DateTime(2026, 11, 10)], 15 * 60);
      expect(splitDhaka[DateTime(2026, 11, 11)], 30 * 60);
      expect(
        splitDhaka.values.fold<int>(0, (a, b) => a + b),
        session.durationSeconds,
      );

      // In America/New_York (UTC-5), 17:30Z..18:45Z is afternoon of Nov 10.
      final splitNy = StudyTimerCalculator.splitSessionByLocalDate(
        session,
        localOffset: const Duration(hours: -5),
      );
      expect(splitNy.keys, [DateTime(2026, 11, 10)]);
      expect(splitNy[DateTime(2026, 11, 10)], 45 * 60);
    });

    test('executes exact Pomodoro sequence with long break after 4 rounds', () {
      var round = 1;
      var phase = PomodoroPhase.focus;
      final visited = <(int, PomodoroPhase, int)>[];

      for (var step = 0; step < 8; step++) {
        final next = StudyTimerCalculator.nextPomodoroStep(
          currentRound: round,
          currentPhase: phase,
        );
        visited.add((next.round, next.phase, next.targetSeconds));
        round = next.round;
        phase = next.phase;
      }

      expect(visited, [
        (1, PomodoroPhase.shortBreak, 5 * 60),
        (2, PomodoroPhase.focus, 25 * 60),
        (2, PomodoroPhase.shortBreak, 5 * 60),
        (3, PomodoroPhase.focus, 25 * 60),
        (3, PomodoroPhase.shortBreak, 5 * 60),
        (4, PomodoroPhase.focus, 25 * 60),
        (4, PomodoroPhase.longBreak, 15 * 60),
        (5, PomodoroPhase.focus, 25 * 60),
      ]);
    });

    test('serializes and parses StudySession JSON round-trip accurately', () {
      final session = StudySession(
        id: 'sess-1',
        userId: 'u-1',
        subjectId: 'sub-math',
        materialId: 'mat-1',
        startedAt: DateTime.utc(2026, 11, 11, 8),
        endedAt: DateTime.utc(2026, 11, 11, 8, 30),
        durationSeconds: 1500,
        note: 'Chapter 4 problems',
        pauseIntervals: [
          PauseInterval(
            pausedAt: DateTime.utc(2026, 11, 11, 8, 12),
            resumedAt: DateTime.utc(2026, 11, 11, 8, 17),
          ),
        ],
        phaseStartedAt: DateTime.utc(2026, 11, 11, 8),
        targetDurationSeconds: 1500,
        pomodoroRound: 1,
        pomodoroPhase: PomodoroPhase.focus,
      );

      final parsed = StudySessionMapper.fromJson(
        StudySessionMapper.toJson(session),
      );
      expect(parsed, session);
    });
  });

  group('StudyTimerController timestamp persistence & background recovery', () {
    test(
        'restores running session after reload, updates tab title, handles '
        'pause/resume and triggers chime when round completes', () async {
      var now = DateTime.utc(2026, 11, 11, 9);
      SharedPreferences.setMockInitialValues({
        kTimerSoundEnabledKey: true,
        kPomodoroFocusMinutesKey: 25,
        kPomodoroShortBreakMinutesKey: 5,
        kPomodoroLongBreakMinutesKey: 15,
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = FakeStudySessionRepository(clock: () => now);
      final platform1 = _RecordingPlatformAdapter();

      final container1 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          studyTimerNowProvider.overrideWithValue(() => now),
          studySessionRepositoryProvider.overrideWithValue(repo),
          studyTimerPlatformProvider.overrideWithValue(platform1),
        ],
      );
      addTearDown(container1.dispose);

      container1.read(studyTimerControllerProvider);
      await Future<void>.delayed(Duration.zero);

      final started = await container1
          .read(studyTimerControllerProvider.notifier)
          .startSession(
            subjectId: 'sub-math',
            materialId: 'mat-1',
            mode: StudySessionMode.focus,
          );
      expect(started, isTrue);
      expect(repo.sessions.single.endedAt, isNull);
      expect(platform1.titles.last, contains('25:00'));

      // Pause 10m in, advance 5m while paused, then resume at 09:15.
      now = DateTime.utc(2026, 11, 11, 9, 10);
      await container1.read(studyTimerControllerProvider.notifier).pause();
      expect(container1.read(studyTimerControllerProvider).isPaused, isTrue);
      expect(
        container1
            .read(studyTimerControllerProvider)
            .evaluation!
            .studiedSeconds,
        10 * 60,
      );

      now = DateTime.utc(2026, 11, 11, 9, 15);
      await container1.read(studyTimerControllerProvider.notifier).resume();
      expect(container1.read(studyTimerControllerProvider).isRunning, isTrue);

      // Simulate browser tab refresh/reload while in background for 15 minutes
      // (total active: 10m + 15m = 25m -> round 1 complete!).
      container1.dispose();
      now = DateTime.utc(2026, 11, 11, 9, 30);
      final platform2 = _RecordingPlatformAdapter();
      final container2 = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          studyTimerNowProvider.overrideWithValue(() => now),
          studySessionRepositoryProvider.overrideWithValue(repo),
          studyTimerPlatformProvider.overrideWithValue(platform2),
        ],
      );
      addTearDown(container2.dispose);

      container2.read(studyTimerControllerProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final restoredState = container2.read(studyTimerControllerProvider);
      expect(restoredState.hasActiveSession, isTrue);
      expect(restoredState.evaluation!.studiedSeconds, 25 * 60);
      expect(restoredState.evaluation!.phaseRemainingSeconds, 0);
      expect(restoredState.evaluation!.isRoundComplete, isTrue);
      expect(restoredState.roundAlert, isNotNull);
      expect(
        restoredState.roundAlert!.suggestedNextPhase,
        PomodoroPhase.shortBreak,
      );
      expect(platform2.chimeCalls, 1);

      // Advance to short break without losing studied seconds, then finish.
      await container2
          .read(studyTimerControllerProvider.notifier)
          .advancePomodoroPhase();
      now = DateTime.utc(2026, 11, 11, 9, 32);
      container2.read(studyTimerControllerProvider.notifier).refreshTick();
      expect(
        container2
            .read(studyTimerControllerProvider)
            .evaluation!
            .studiedSeconds,
        25 * 60,
      );

      final completed = await container2
          .read(studyTimerControllerProvider.notifier)
          .finishActiveSession(note: 'Completed focus round 1');
      expect(completed, isNotNull);
      expect(completed!.endedAt, isNotNull);
      expect(completed.durationSeconds, 25 * 60);
      expect(
        container2.read(studyTimerControllerProvider).hasActiveSession,
        isFalse,
      );
      expect(platform2.restoreCalls, greaterThanOrEqualTo(1));
    });
  });
}
