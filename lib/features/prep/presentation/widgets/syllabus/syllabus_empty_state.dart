import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/template_outline_finder.dart';
import 'package:job_prep/features/prep/presentation/providers/syllabus_providers.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/chapter_form_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/syllabus/quick_add_outline_dialog.dart';

/// Friendly empty view shown when a subject has no chapters configured.
class SyllabusEmptyState extends ConsumerWidget {
  const SyllabusEmptyState({
    required this.subject,
    super.key,
  });

  final Subject subject;

  void _startFromTemplate(BuildContext context, WidgetRef ref) {
    final outline = TemplateOutlineFinder.findExampleOutline(subject.name);
    unawaited(
      ref.read(syllabusControllerProvider).importPastedOutline(
            subjectId: subject.id,
            outline: outline,
          ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;
    final l10n = context.l10n;

    return GlassCard(
      padding: spacing.insetsAllXl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 48,
            color: colors.goldAccent,
          ),
          SizedBox(height: spacing.md),
          Text(
            l10n.syllabusNoChapters,
            style: textStyles.titleMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.syllabusNoChaptersDesc(subject.name),
            style: textStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing.lg),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            alignment: WrapAlignment.center,
            children: [
              GlassButton(
                key: const ValueKey('syllabus-quick-add-btn'),
                onPressed: () => QuickAddOutlineDialog.show(
                  context,
                  subjectId: subject.id,
                ),
                leading: const Icon(Icons.playlist_add_rounded, size: 18),
                variant: GlassButtonVariant.primary,
                child: Text(l10n.syllabusQuickAdd),
              ),
              GlassButton(
                key: const ValueKey('syllabus-template-outline-btn'),
                onPressed: () => _startFromTemplate(context, ref),
                leading: const Icon(Icons.auto_awesome_rounded, size: 18),
                child: Text(l10n.syllabusStartFromTemplate),
              ),
              GlassButton(
                key: const ValueKey('syllabus-add-chapter-btn'),
                onPressed: () => ChapterFormDialog.show(
                  context,
                  subjectId: subject.id,
                ),
                leading: const Icon(Icons.add_rounded, size: 18),
                child: Text(l10n.syllabusAddChapter),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
