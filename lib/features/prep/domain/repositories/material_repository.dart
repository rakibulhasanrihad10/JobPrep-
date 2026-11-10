import 'package:job_prep/features/prep/domain/entities/prep_material.dart';

/// Contract for managing study materials (`public.materials`).
abstract interface class MaterialRepository {
  /// Fetches all study materials across all subjects for the current user.
  Future<List<PrepMaterial>> getAllMaterials();

  /// Fetches all materials belonging to [subjectId].
  Future<List<PrepMaterial>> getMaterialsForSubject(String subjectId);

  /// Fetches a single [PrepMaterial] by [id], or `null` if absent.
  Future<PrepMaterial?> getMaterialById(String id);

  /// Inserts a new [material] and returns the persisted record.
  Future<PrepMaterial> createMaterial(PrepMaterial material);

  /// Updates an existing [material] and returns the persisted record.
  Future<PrepMaterial> updateMaterial(PrepMaterial material);

  /// Permanently deletes the material identified by [id].
  Future<void> deleteMaterial(String id);
}
