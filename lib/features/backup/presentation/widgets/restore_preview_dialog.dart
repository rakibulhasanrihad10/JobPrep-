import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/data/app_mode.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/backup/domain/entities/backup_manifest.dart';
import 'package:job_prep/features/backup/domain/entities/backup_validation_result.dart';
import 'package:job_prep/features/backup/presentation/providers/backup_providers.dart';
import 'package:job_prep/features/backup/presentation/widgets/restore_table_counts_grid.dart';

/// Opens the restore preview dialog allowing strategy selection and execution.
Future<int?> showRestorePreviewDialog(
  BuildContext context, {
  required BackupManifest manifest,
}) {
  return showGlassDialog<int>(
    context: context,
    builder: (_) => RestorePreviewDialog(manifest: manifest),
  );
}

/// Dialog displaying table entity counts, strategy selection, and restore
/// action.
class RestorePreviewDialog extends ConsumerStatefulWidget {
  /// Creates a [RestorePreviewDialog].
  const RestorePreviewDialog({
    required this.manifest,
    super.key,
  });

  /// Validated manifest to restore.
  final BackupManifest manifest;

  @override
  ConsumerState<RestorePreviewDialog> createState() =>
      _RestorePreviewDialogState();
}

class _RestorePreviewDialogState extends ConsumerState<RestorePreviewDialog> {
  RestoreStrategy _strategy = RestoreStrategy.merge;
  final _confirmWordController = TextEditingController();
  bool _isRestoring = false;
  String? _errorMessage;

  @override
  void dispose() {
    _confirmWordController.dispose();
    super.dispose();
  }

  bool get _isReplaceValid {
    if (_strategy.isMerge) return true;
    final target = context.l10n.restoreReplaceConfirmWord.trim().toUpperCase();
    return _confirmWordController.text.trim().toUpperCase() == target;
  }

  Future<void> _handleRestore() async {
    if (!_isReplaceValid || _isRestoring) return;
    final l10n = context.l10n;

    setState(() {
      _isRestoring = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(backupControllerProvider);
      final count = await controller.restoreBackup(
        manifest: widget.manifest,
        strategy: _strategy,
        onSaveSafetyBackup: (safety) async {
          // Automatic safety backup export before destructive replacement
          await controller.exportBackup();
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop(count);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const ValueKey('restore-success-snack'),
          content: Text(l10n.restoreSuccessMessage(count)),
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _isRestoring = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final isGuest = ref.watch(appModeProvider)?.isGuest ?? false;
    final data = widget.manifest.data;

    return GlassDialog(
      key: const ValueKey('restore-preview-dialog'),
      title: Text(l10n.restoreDialogTitle),
      content: Material(
        type: MaterialType.transparency,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.restorePreviewTitle,
                style: textStyles.titleMedium,
              ),
              SizedBox(height: spacing.xs),
              Text(
                l10n.restorePreviewTotalRecords(data.totalRecords),
                style:
                    textStyles.labelMedium.copyWith(color: colors.goldAccent),
              ),
              SizedBox(height: spacing.sm),
              RestoreTableCountsGrid(data: data),
              SizedBox(height: spacing.md),
              RadioGroup<RestoreStrategy>(
                groupValue: _strategy,
                onChanged: (s) {
                  if (_isRestoring || s == null) return;
                  setState(() => _strategy = s);
                },
                child: Column(
                  children: [
                    InkWell(
                      key: const ValueKey('restore-strategy-merge-radio'),
                      onTap: _isRestoring
                          ? null
                          : () => setState(
                                () => _strategy = RestoreStrategy.merge,
                              ),
                      borderRadius: tokens.radii.buttonRadius,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: spacing.xs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Radio<RestoreStrategy>(
                              value: RestoreStrategy.merge,
                            ),
                            SizedBox(width: spacing.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.restoreStrategyMergeTitle,
                                    style: textStyles.labelLarge,
                                  ),
                                  Text(
                                    l10n.restoreStrategyMergeDescription,
                                    style: textStyles.bodySmall.copyWith(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isGuest) ...[
                      SizedBox(height: spacing.xs),
                      InkWell(
                        key: const ValueKey('restore-strategy-replace-radio'),
                        onTap: _isRestoring
                            ? null
                            : () => setState(
                                  () => _strategy = RestoreStrategy.replace,
                                ),
                        borderRadius: tokens.radii.buttonRadius,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: spacing.xs),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Radio<RestoreStrategy>(
                                value: RestoreStrategy.replace,
                              ),
                              SizedBox(width: spacing.xs),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.restoreStrategyReplaceTitle,
                                      style: textStyles.labelLarge.copyWith(
                                        color: colors.danger,
                                      ),
                                    ),
                                    Text(
                                      l10n.restoreStrategyReplaceDescription,
                                      style: textStyles.bodySmall.copyWith(
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (_strategy.isReplace) ...[
                SizedBox(height: spacing.sm),
                Container(
                  padding: spacing.insetsAllSm,
                  decoration: BoxDecoration(
                    color: colors.danger.withValues(alpha: 0.1),
                    borderRadius: radii.buttonRadius,
                    border: Border.all(
                      color: colors.danger.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.restoreReplaceSafetyBackupNote,
                        style: textStyles.labelSmall.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: spacing.sm),
                      Text(
                        l10n.restoreReplaceConfirmPrompt,
                        style: textStyles.labelSmall.copyWith(
                          color: colors.danger,
                        ),
                      ),
                      SizedBox(height: spacing.xs),
                      TextFormField(
                        key: const ValueKey('restore-replace-confirm-input'),
                        controller: _confirmWordController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: l10n.restoreReplaceConfirmWord,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                SizedBox(height: spacing.sm),
                Text(
                  _errorMessage!,
                  key: const ValueKey('restore-error-text'),
                  style: textStyles.bodySmall.copyWith(color: colors.danger),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('restore-dialog-cancel-btn'),
          onPressed: _isRestoring ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.backupDialogCancel),
        ),
        GlassButton(
          key: const ValueKey('restore-dialog-submit-btn'),
          variant: _strategy.isReplace
              ? GlassButtonVariant.standard
              : GlassButtonVariant.primary,
          onPressed: (_isReplaceValid && !_isRestoring) ? _handleRestore : null,
          leading: _isRestoring
              ? SizedBox(
                  width: spacing.md,
                  height: spacing.md,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colors.textPrimary),
                  ),
                )
              : Icon(Icons.restore_page_outlined, size: spacing.lg),
          child: Text(l10n.restoreActionButton),
        ),
      ],
    );
  }
}
