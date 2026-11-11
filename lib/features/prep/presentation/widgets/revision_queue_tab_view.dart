import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_enums.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/entities/revision_item.dart';
import 'package:job_prep/features/prep/domain/entities/subject.dart';
import 'package:job_prep/features/prep/domain/utils/revision_scheduler.dart';
import 'package:job_prep/features/prep/presentation/providers/prep_providers.dart';
import 'package:job_prep/features/prep/presentation/providers/revision_providers.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_style_tokens.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_filter_bar.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_flag_dialog.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_item_card.dart';
import 'package:job_prep/features/prep/presentation/widgets/revision_queue_banners.dart';

/// Revision Queue tab inside `PrepScreen` organizing spaced revision marks
/// across `Due today`, `Overdue`, `Upcoming`, and `Done` with subject/material
/// filters and reversible per-item actions (`Easy`, `Still hard`, `Snooze`,
/// `Dismiss`, plus Undo).
class RevisionQueueTabView extends ConsumerWidget {
  /// Creates a [RevisionQueueTabView].
  const RevisionQueueTabView({
    required this.visitId,
    super.key,
  });

  /// Monotonically incremented counter replaying animations when opening tab.
  final int visitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final subjects = List<Subject>.of(
      ref.watch(subjectsProvider).asData?.value ?? const <Subject>[],
    )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final materials =
        ref.watch(allMaterialsProvider).asData?.value ?? const <PrepMaterial>[];
    final allItems = ref.watch(revisionItemsProvider).asData?.value ??
        const <RevisionItem>[];

    final activeTab = ref.watch(revisionQueueTabProvider);
    final filter = ref.watch(revisionFilterProvider);
    final counts = ref.watch(revisionTabCountsProvider);
    final filteredAsync = ref.watch(filteredRevisionItemsProvider);
    final mutationState = ref.watch(revisionControllerProvider);
    final today = ref.watch(revisionNowProvider)();

    final subjectsById = <String, Subject>{
      for (final s in subjects) s.id: s,
    };
    final materialsById = <String, PrepMaterial>{
      for (final m in materials) m.id: m,
    };
    final masteredCount =
        allItems.where((item) => item.status == RevisionStatus.mastered).length;
    final totalCounts = RevisionScheduler.countTabs(allItems, today: today);
    final replayKey = 'revision-tab-$visitId-${activeTab.name}';

    return FadeSlideIn(
      key: ValueKey('revision-fade-$visitId'),
      child: Column(
        key: const ValueKey('revision-queue-tab-view'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: spacing.insetsAllXl,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: spacing.lg,
              runSpacing: spacing.md,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.prepRevisionTitle,
                      style: tokens.textStyles.headlineMedium,
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      l10n.prepRevisionSubtitle,
                      style: tokens.textStyles.bodyMedium,
                    ),
                  ],
                ),
                Wrap(
                  spacing: spacing.lg,
                  runSpacing: spacing.md,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RevisionHeaderStat(
                      label: l10n.prepRevisionDueCountStat,
                      value: totalCounts.actionNeeded,
                      color: totalCounts.overdue > 0
                          ? colors.danger
                          : colors.goldAccent,
                      replayKey: replayKey,
                    ),
                    RevisionHeaderStat(
                      label: l10n.prepRevisionMasteredStat,
                      value: masteredCount,
                      color: colors.success,
                      replayKey: replayKey,
                    ),
                    GlassButton(
                      key: const ValueKey('revision-add-manual-button'),
                      variant: GlassButtonVariant.primary,
                      onPressed: subjects.isEmpty
                          ? null
                          : () => unawaited(showRevisionFlagDialog(context)),
                      leading: Icon(
                        Icons.flag_outlined,
                        size: spacing.lg,
                        color: colors.goldAccent,
                      ),
                      child: Text(l10n.prepRevisionFlagItemButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.lg),
          RevisionFilterBar(
            activeTab: activeTab,
            counts: counts,
            filter: filter,
            subjects: subjects,
            materials: materials,
            locale: locale,
            useBanglaDigits: useBanglaDigits,
            onSelectTab: (tab) =>
                ref.read(revisionQueueTabProvider.notifier).selectTab(tab),
            onSelectSubject: (id) =>
                ref.read(revisionFilterProvider.notifier).setSubject(id),
            onSelectMaterial: (id) =>
                ref.read(revisionFilterProvider.notifier).setMaterial(id),
            onClearFilters: () =>
                ref.read(revisionFilterProvider.notifier).clear(),
          ),
          if (mutationState.lastUndo != null) ...[
            SizedBox(height: spacing.md),
            RevisionUndoBanner(
              record: mutationState.lastUndo!,
              locale: locale,
              useBanglaDigits: useBanglaDigits,
              isBusy: mutationState.isSaving,
              onUndo: () => unawaited(
                ref.read(revisionControllerProvider.notifier).undoLastAction(),
              ),
              onDismiss: () =>
                  ref.read(revisionControllerProvider.notifier).clearUndo(),
            ),
          ],
          if (mutationState.error != null) ...[
            SizedBox(height: spacing.md),
            Text(
              PrepL10n.failureMessage(mutationState.error!, l10n),
              style:
                  tokens.textStyles.bodyMedium.copyWith(color: colors.danger),
            ),
          ],
          SizedBox(height: spacing.lg),
          filteredAsync.when(
            loading: () => Padding(
              padding: spacing.insetsAllXl,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => GlassCard(
              padding: spacing.insetsAllLg,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final retryButton = GlassButton(
                    onPressed: () => unawaited(
                      ref.read(revisionItemsProvider.notifier).refresh(),
                    ),
                    child: Text(l10n.calendarRetry),
                  );
                  final errorText = Text(
                    PrepL10n.failureMessage(error, l10n),
                    style: tokens.textStyles.bodyMedium,
                  );
                  if (constraints.maxWidth >= 420) {
                    return Row(
                      children: [
                        Expanded(child: errorText),
                        SizedBox(width: spacing.md),
                        retryButton,
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      errorText,
                      SizedBox(height: spacing.sm),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: retryButton,
                      ),
                    ],
                  );
                },
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return RevisionEmptyQueueCard(
                  tab: activeTab,
                  hasFilters: filter.hasActiveFilters,
                  onClearFilters: () =>
                      ref.read(revisionFilterProvider.notifier).clear(),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) SizedBox(height: spacing.sm),
                    FadeSlideIn(
                      key: ValueKey('rev-fade-$replayKey-${items[i].id}'),
                      delay: Duration(milliseconds: (i * 35).clamp(0, 210)),
                      child: RevisionItemCard(
                        item: items[i],
                        subjectName:
                            subjectsById[items[i].subjectId]?.name ?? '',
                        subjectColor: PrepStyleTokens.resolveSubjectColor(
                          subjectsById[items[i].subjectId]?.color ?? 'gold',
                          colors,
                        ),
                        materialTitle:
                            materialsById[items[i].materialId]?.title,
                        today: today,
                        locale: locale,
                        useBanglaDigits: useBanglaDigits,
                        isBusy: mutationState.isSaving &&
                            mutationState.activeItemId == items[i].id,
                        onReviewAction: (action) => unawaited(
                          ref
                              .read(revisionControllerProvider.notifier)
                              .applyAction(item: items[i], action: action),
                        ),
                        onDelete: () => unawaited(
                          ref
                              .read(revisionControllerProvider.notifier)
                              .deleteItem(items[i].id),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
