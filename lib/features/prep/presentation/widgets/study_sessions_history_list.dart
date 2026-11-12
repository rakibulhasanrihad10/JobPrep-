import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/core/widgets/glass_dialog.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/study_session.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_crud_controller.dart';
import 'package:job_prep/features/prep/presentation/providers/study_session_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';
import 'package:job_prep/features/prep/presentation/utils/study_timer_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/study_session_form_dialog.dart';

/// Lists completed and manually entered [StudySession] entries with Edit &
/// Delete actions cleanly updated across history and Study Analytics.
class StudySessionsHistoryList extends ConsumerWidget {
  /// Creates a [StudySessionsHistoryList].
  const StudySessionsHistoryList({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    StudySession session,
  ) async {
    final confirmed = await showGlassDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return GlassDialog(
          title: Text(l10n.prepTimerDeleteConfirmTitle),
          content: Text(
            l10n.prepTimerDeleteConfirmBody,
            style: ctx.tokens.textStyles.bodyMedium,
          ),
          actions: [
            GlassButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.prepCancelButton),
            ),
            GlassButton(
              key: ValueKey('session-delete-confirm-${session.id}'),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                l10n.prepDeleteAction,
                style: ctx.tokens.textStyles.labelLarge.copyWith(
                  color: ctx.tokens.colors.danger,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref
          .read(studySessionCrudControllerProvider.notifier)
          .deleteSession(session.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final sessions = (ref.watch(studySessionsProvider).asData?.value ??
            const <StudySession>[])
        .where((s) => s.isCompleted)
        .toList(growable: false);
    final subjects =
        ref.watch(subjectsProvider).asData?.value ?? const <Subject>[];
    final materials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];
    final crudState = ref.watch(studySessionCrudControllerProvider);

    final subjectsById = <String, Subject>{for (final s in subjects) s.id: s};
    final materialsById = <String, PrepMaterial>{
      for (final m in materials) m.id: m,
    };

    return GlassCard(
      key: const ValueKey('study-sessions-history-card'),
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: spacing.sm,
            runSpacing: spacing.xs,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: spacing.lg,
                    color: colors.goldAccent,
                  ),
                  SizedBox(width: spacing.xs),
                  Flexible(
                    child: Text(
                      l10n.prepTimerHistoryTitle,
                      style: tokens.textStyles.titleMedium,
                    ),
                  ),
                ],
              ),
              if (subjects.isNotEmpty)
                GlassButton(
                  key: const ValueKey('history-add-manual-btn'),
                  onPressed: crudState.isSaving
                      ? null
                      : () => unawaited(showStudySessionFormDialog(context)),
                  leading: Icon(Icons.add, size: spacing.lg),
                  child: Text(l10n.prepTimerManualEntryButton),
                ),
            ],
          ),
          SizedBox(height: spacing.md),
          if (sessions.isEmpty)
            Text(
              l10n.prepTimerHistoryEmpty,
              key: const ValueKey('study-sessions-empty-text'),
              style: tokens.textStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < sessions.length; i++) ...[
                  if (i > 0)
                    Divider(height: spacing.lg, color: colors.glassBorder),
                  _SessionHistoryRow(
                    session: sessions[i],
                    subject: subjectsById[sessions[i].subjectId],
                    material: materialsById[sessions[i].materialId],
                    locale: locale,
                    useBanglaDigits: useBanglaDigits,
                    isBusy: crudState.isSaving &&
                        crudState.activeSessionId == sessions[i].id,
                    onEdit: () => unawaited(
                      showStudySessionFormDialog(
                        context,
                        existing: sessions[i],
                      ),
                    ),
                    onDelete: () =>
                        unawaited(_confirmDelete(context, ref, sessions[i])),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _SessionHistoryRow extends StatelessWidget {
  const _SessionHistoryRow({
    required this.session,
    required this.subject,
    required this.material,
    required this.locale,
    required this.useBanglaDigits,
    required this.isBusy,
    required this.onEdit,
    required this.onDelete,
  });

  final StudySession session;
  final Subject? subject;
  final PrepMaterial? material;
  final Locale locale;
  final bool useBanglaDigits;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    final accent = PrepStyleTokens.resolveSubjectColor(
      subject?.color ?? 'gold',
      colors,
    );
    final durationStr = StudyTimerL10n.formatClock(
      session.durationSeconds,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );
    final dateStr = AppFormatters.formatDate(
      session.startedAt.toLocal(),
      locale: locale,
      pattern: 'yMMMd',
      useBanglaDigits: useBanglaDigits,
    );

    return Row(
      key: ValueKey('session-row-${session.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: spacing.sm,
          height: spacing.sm,
          margin: EdgeInsets.only(top: spacing.xs, right: spacing.sm),
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.xxs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    subject?.name ?? '',
                    style: tokens.textStyles.titleMedium,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: tokens.radii.smRadius,
                      border: Border.all(color: colors.glassBorder),
                    ),
                    child: Text(
                      StudyTimerL10n.modeLabel(session.mode, l10n),
                      style: tokens.textStyles.labelSmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    durationStr,
                    style: tokens.textStyles.labelLarge.copyWith(
                      color: colors.goldAccent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.xxs),
              Text(
                material != null ? '$dateStr • ${material!.title}' : dateStr,
                style: tokens.textStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (session.note != null && session.note!.trim().isNotEmpty) ...[
                SizedBox(height: spacing.xxs),
                Text(
                  session.note!.trim(),
                  style: tokens.textStyles.bodySmall,
                ),
              ],
            ],
          ),
        ),
        IconButton(
          key: ValueKey('session-edit-${session.id}'),
          tooltip: l10n.prepTimerEditTooltip,
          visualDensity: VisualDensity.compact,
          onPressed: isBusy ? null : onEdit,
          icon: Icon(Icons.edit_outlined, size: spacing.lg),
        ),
        IconButton(
          key: ValueKey('session-delete-${session.id}'),
          tooltip: l10n.prepTimerDeleteTooltip,
          visualDensity: VisualDensity.compact,
          onPressed: isBusy ? null : onDelete,
          icon: Icon(
            Icons.delete_outline,
            size: spacing.lg,
            color: colors.danger,
          ),
        ),
      ],
    );
  }
}
