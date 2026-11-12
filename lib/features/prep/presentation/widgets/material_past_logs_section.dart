import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/prep/domain/entities/progress_log.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';

/// Displays past [ProgressLog] entries for a material with edit and delete
/// controls.
class MaterialPastLogsSection extends StatelessWidget {
  /// Creates a [MaterialPastLogsSection].
  const MaterialPastLogsSection({
    required this.logsAsync,
    required this.unitLabel,
    required this.isBusy,
    required this.onEditLog,
    required this.onDeleteLog,
    super.key,
  });

  /// Async list of past logs ordered newest first.
  final AsyncValue<List<ProgressLog>> logsAsync;

  /// Unit label displayed beside each log entry (`pages`, `lectures`, etc.).
  final String unitLabel;

  /// Disables actions while a log mutation is active.
  final bool isBusy;

  /// Begins editing the tapped past log.
  final ValueChanged<ProgressLog> onEditLog;

  /// Deletes the tapped past log.
  final ValueChanged<ProgressLog> onDeleteLog;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text(
        PrepL10n.failureMessage(error, l10n),
        style: tokens.textStyles.bodySmall.copyWith(color: colors.danger),
      ),
      data: (logs) {
        if (logs.isEmpty) {
          return Text(
            l10n.prepNoPastLogs,
            style: tokens.textStyles.bodySmall,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final entry in logs)
              Container(
                key: ValueKey('log-row-${entry.id}'),
                margin: EdgeInsets.only(bottom: spacing.sm),
                padding: spacing.insetsAllMd,
                decoration: BoxDecoration(
                  color: colors.surfaceElevated,
                  borderRadius: radii.buttonRadius,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: spacing.xs,
                            runSpacing: spacing.xxs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                l10n.prepLogUnitsSummary(
                                  PrepL10n.formatInt(entry.unitsDone, locale),
                                  unitLabel,
                                ),
                                style: tokens.textStyles.labelLarge,
                              ),
                              if (entry.isCorrection)
                                Container(
                                  key: ValueKey('log-correction-${entry.id}'),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: spacing.xs,
                                    vertical: spacing.xxs,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        colors.warning.withValues(alpha: 0.16),
                                    borderRadius: radii.smRadius,
                                    border: Border.all(
                                      color: colors.warning.withValues(
                                        alpha: 0.55,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.prepLogEntryTypeCorrectionBadge,
                                    style:
                                        tokens.textStyles.labelSmall.copyWith(
                                      color: colors.warning,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: spacing.xxs),
                          Text(
                            AppFormatters.formatDate(
                              entry.loggedOn,
                              locale: locale,
                              pattern: 'yMMMd',
                            ),
                            style: tokens.textStyles.bodySmall,
                          ),
                          if (entry.note != null &&
                              entry.note!.trim().isNotEmpty) ...[
                            SizedBox(height: spacing.xs),
                            Text(
                              entry.note!.trim(),
                              style: tokens.textStyles.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!entry.isCorrection)
                      IconButton(
                        key: ValueKey('log-edit-${entry.id}'),
                        tooltip: l10n.prepEditAction,
                        visualDensity: VisualDensity.compact,
                        onPressed: isBusy ? null : () => onEditLog(entry),
                        icon: Icon(
                          Icons.edit_outlined,
                          size: spacing.lg + spacing.xxs,
                        ),
                      ),
                    IconButton(
                      key: ValueKey('log-delete-${entry.id}'),
                      tooltip: l10n.prepDeleteAction,
                      visualDensity: VisualDensity.compact,
                      onPressed: isBusy ? null : () => onDeleteLog(entry),
                      icon: Icon(
                        Icons.delete_outline,
                        color: colors.danger,
                        size: spacing.lg + spacing.xxs,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
