import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/providers/inbox_controller.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_states.dart';
import 'package:job_prep/features/circulars/presentation/widgets/inbox_item_card.dart';
import 'package:job_prep/features/circulars/presentation/widgets/inbox_states.dart';
import 'package:job_prep/features/circulars/presentation/widgets/quick_capture_dialog.dart';

/// Triage queue listing quick-captured circulars waiting for details, skipping,
/// or deletion.
class InboxScreen extends ConsumerWidget {
  /// Creates an [InboxScreen].
  const InboxScreen({
    super.key,
    this.onCompleteDetails,
    this.onQuickCapture,
  });

  /// Optional callback invoked when the user taps `Complete details`.
  final ValueChanged<Circular>? onCompleteDetails;

  /// Optional callback invoked when the user taps `Quick capture`.
  final VoidCallback? onQuickCapture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);

    final inboxAsync = ref.watch(inboxCircularsProvider);
    final actionState = ref.watch(inboxControllerProvider);
    final inboxController = ref.read(inboxControllerProvider.notifier);

    final itemCount = inboxAsync.asData?.value.length ?? 0;
    final formattedCount = AppFormatters.formatNumber(
      itemCount,
      locale: locale,
      useBanglaDigits: useBanglaDigits,
    );

    void refresh() {
      inboxController.clearError();
      unawaited(ref.read(circularsListProvider.notifier).refresh());
    }

    void triggerQuickCapture() {
      if (onQuickCapture != null) {
        onQuickCapture!();
        return;
      }
      unawaited(showQuickCaptureDialog(context));
    }

    void openCompleteDetails(Circular circular) {
      ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
      if (onCompleteDetails != null) {
        onCompleteDetails!(circular);
        return;
      }
      unawaited(
        GoRouter.maybeOf(context)?.push(
              '/circulars/${circular.id}/edit',
              extra: circular,
            ) ??
            Future<void>.value(),
      );
    }

    Future<void> handleSkip(Circular circular) async {
      final ok = await inboxController.skip(circular);
      if (!context.mounted || !ok) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.inboxActionSkipped(circular.title))),
      );
    }

    Future<void> handleDelete(Circular circular) async {
      final ok = await inboxController.delete(circular);
      if (!context.mounted || !ok) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.inboxActionDeleted(circular.title))),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        spacing.xl,
        spacing.xl,
        spacing.xl,
        spacing.xl + spacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: spacing.insetsAllLg,
            child: FadeSlideIn(
              child: Wrap(
                spacing: spacing.md,
                runSpacing: spacing.sm,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.inboxTitle,
                        style: textStyles.headlineMedium,
                      ),
                      SizedBox(height: spacing.xs),
                      Text(
                        l10n.inboxCount(itemCount, formattedCount),
                        style: textStyles.bodyMedium,
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: spacing.sm,
                    runSpacing: spacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      IconButton(
                        key: const ValueKey('inbox-refresh-btn'),
                        tooltip: l10n.inboxRefreshTooltip,
                        onPressed: refresh,
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: colors.goldAccent,
                        ),
                      ),
                      GlassButton(
                        key: const ValueKey('inbox-quick-capture-btn'),
                        variant: GlassButtonVariant.primary,
                        onPressed: triggerQuickCapture,
                        leading: Icon(
                          Icons.add_link_rounded,
                          size: spacing.lg,
                        ),
                        child: Text(l10n.quickCaptureButton),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (actionState.lastFailure != null) ...[
            SizedBox(height: spacing.md),
            InboxFailureBanner(
              failure: actionState.lastFailure!,
              onDismiss: inboxController.clearError,
            ),
          ],
          SizedBox(height: spacing.lg),
          inboxAsync.when(
            loading: () => const CircularsLoadingState(),
            error: (error, _) => CircularsErrorState(
              error: error,
              onRetry: refresh,
            ),
            data: (items) {
              if (items.isEmpty) {
                return InboxEmptyState(
                  onQuickCapture: triggerQuickCapture,
                );
              }

              return ListView.separated(
                key: const ValueKey('inbox-list'),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: spacing.md),
                itemBuilder: (context, index) {
                  final circular = items[index];
                  return InboxItemCard(
                    circular: circular,
                    index: index,
                    isBusy: actionState.isBusy(circular.id),
                    onCompleteDetails: () => openCompleteDetails(circular),
                    onSkip: () => unawaited(handleSkip(circular)),
                    onDelete: () => unawaited(handleDelete(circular)),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
