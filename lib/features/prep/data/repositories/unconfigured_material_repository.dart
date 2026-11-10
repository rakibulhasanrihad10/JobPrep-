import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/errors/prep_failure.dart';
import 'package:job_prep/features/prep/domain/repositories/material_repository.dart';

/// Safe fallback [MaterialRepository] used when Supabase is unconfigured.
class UnconfiguredMaterialRepository implements MaterialRepository {
  /// Creates an [UnconfiguredMaterialRepository].
  const UnconfiguredMaterialRepository();

  static const _failure = UnknownPrepFailure(
    code: 'supabase_not_configured',
    message: 'Supabase environment variables are not configured.',
  );

  @override
  Future<List<PrepMaterial>> getAllMaterials() async => const [];

  @override
  Future<List<PrepMaterial>> getMaterialsForSubject(String subjectId) async =>
      const [];

  @override
  Future<PrepMaterial?> getMaterialById(String id) async => null;

  @override
  Future<PrepMaterial> createMaterial(PrepMaterial material) =>
      Future.error(_failure);

  @override
  Future<PrepMaterial> updateMaterial(PrepMaterial material) =>
      Future.error(_failure);

  @override
  Future<void> deleteMaterial(String id) => Future.error(_failure);
}
