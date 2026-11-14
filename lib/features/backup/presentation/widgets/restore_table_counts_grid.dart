import 'package:flutter/material.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';

/// Renders a wrapped grid of pill badges showing record counts per table.
class RestoreTableCountsGrid extends StatelessWidget {
  /// Creates a [RestoreTableCountsGrid].
  const RestoreTableCountsGrid({
    required this.data,
    super.key,
  });

  /// Tables data to display.
  final BackupDataTables data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;

    return Container(
      padding: spacing.insetsAllSm,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Wrap(
        spacing: spacing.md,
        runSpacing: spacing.xs,
        children: [
          _CountPill(label: 'Circulars', count: data.circulars.length),
          _CountPill(label: 'Subjects', count: data.subjects.length),
          _CountPill(label: 'Materials', count: data.materials.length),
          _CountPill(label: 'Progress', count: data.progressLogs.length),
          _CountPill(label: 'Topics', count: data.topics.length),
          _CountPill(label: 'Study Plans', count: data.studyPlans.length),
          _CountPill(label: 'Mock Tests', count: data.mockTests.length),
          _CountPill(label: 'Revisions', count: data.revisionItems.length),
          _CountPill(label: 'Sessions', count: data.studySessions.length),
          _CountPill(label: 'Vault Logins', count: data.portalAccounts.length),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.label,
    required this.count,
  });

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final textStyles = tokens.textStyles;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: textStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
        Text(
          '$count',
          style: textStyles.labelSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
