import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/storage/preferences_provider.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_file_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_cover_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/settings/data/repositories/unconfigured_user_settings_repository.dart';
import 'package:job_prep/features/vault/presentation/providers/portal_vault_providers.dart';

/// Coordinates authenticated account actions in Settings: password updates,
/// vault-safe sign out, and full self-service account deletion.
class SettingsAccountController extends Notifier<bool> {
  @override
  bool build() => false;

  /// Updates the current user's login password cleanly (`null` on success,
  /// error object on failure).
  Future<Object?> updatePassword(String newPassword) async {
    state = true;
    try {
      await ref.read(authRepositoryProvider).updatePassword(
            newPassword: newPassword,
          );
      return null;
    } on Object catch (error) {
      return error;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Locks the zero-knowledge vault cleanly before signing the user out.
  Future<void> signOut() async {
    if (state) return;
    state = true;
    try {
      ref.read(portalVaultControllerProvider.notifier).lockVault();
      await ref.read(authRepositoryProvider).signOut();
    } finally {
      if (ref.mounted) state = false;
    }
  }

  /// Permanently deletes the signed-in user account and cleans up attachments,
  /// covers, vault keys, and cached local settings. Returns `null` on success
  /// or the thrown error if deletion failed.
  Future<Object?> deleteAccount() async {
    if (state) return null;
    state = true;
    try {
      await _cleanupStorageObjectsBestEffort();
      ref.read(portalVaultControllerProvider.notifier).lockVault();
      await ref.read(authRepositoryProvider).deleteMyAccount();
      await _clearLocalUserCaches();
      return null;
    } on Object catch (error) {
      return error;
    } finally {
      if (ref.mounted) state = false;
    }
  }

  Future<void> _cleanupStorageObjectsBestEffort() async {
    try {
      final circulars =
          await ref.read(circularRepositoryProvider).getCirculars();
      final fileRepo = ref.read(circularFileRepositoryProvider);
      for (final c in circulars) {
        final files = await fileRepo.getFilesForCircular(c.id);
        for (final file in files) {
          try {
            await fileRepo.deleteFile(file);
          } on Object {
            // Continue cleaning remaining objects cleanly.
          }
        }
      }
    } on Object {
      // Best-effort storage cleanup never blocks account deletion.
    }

    try {
      final materials =
          await ref.read(materialRepositoryProvider).getAllMaterials();
      final coverRepo = ref.read(materialCoverRepositoryProvider);
      for (final mat in materials) {
        final coverPath = mat.coverImagePath;
        if (coverPath == null || coverPath.trim().isEmpty) continue;
        try {
          await coverRepo.deleteCover(coverPath);
        } on Object {
          // Continue cleaning remaining objects cleanly.
        }
      }
    } on Object {
      // Best-effort cover cleanup never blocks account deletion.
    }
  }

  Future<void> _clearLocalUserCaches() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(kUserAppSettingsCacheKey);
    final onboardingKeys = prefs
        .getKeys()
        .where((key) => key.startsWith('jobprep_unconfigured_onboarding_'))
        .toList(growable: false);
    for (final key in onboardingKeys) {
      await prefs.remove(key);
    }
    await prefs.remove(kPomodoroFocusMinutesKey);
    await prefs.remove(kPomodoroShortBreakMinutesKey);
    await prefs.remove(kPomodoroLongBreakMinutesKey);
    await prefs.remove(kTimerSoundEnabledKey);
  }
}

/// Provides [SettingsAccountController] for Profile & Data account operations.
final NotifierProvider<SettingsAccountController, bool>
    settingsAccountControllerProvider =
    NotifierProvider<SettingsAccountController, bool>(
  SettingsAccountController.new,
);
