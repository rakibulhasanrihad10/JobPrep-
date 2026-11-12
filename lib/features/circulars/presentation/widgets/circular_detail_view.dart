import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/features/circulars/domain/entities/circular.dart';
import 'package:job_prep/features/circulars/domain/errors/circular_failure.dart';
import 'package:job_prep/features/circulars/presentation/providers/circular_detail_controller.dart';
import 'package:job_prep/features/circulars/presentation/providers/circulars_providers.dart';
import 'package:job_prep/features/circulars/presentation/utils/circular_l10n.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_header_card.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_links_card.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_overview_card.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_quick_actions.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_detail_text_card.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_exam_dates_section.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_files_section.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circular_form_chrome.dart';
import 'package:job_prep/features/circulars/presentation/widgets/circulars_states.dart';
import 'package:job_prep/features/vault/presentation/widgets/circular_portal_login_section.dart';

/// Complete detail body displaying circular header, quick actions & checklist,
/// launchable links, overview metadata, exam dates, and notes/syllabus.
///
/// Embedded inside the desktop right master-detail pane when [isPane] is true
/// and rendered full-screen on compact/tablet viewports.
class CircularDetailView extends ConsumerWidget {
  /// Creates a [CircularDetailView].
  const CircularDetailView({
    required this.circularId,
    super.key,
    this.initialCircular,
    this.isPane = false,
    this.onCloseOrBack,
    this.onEdit,
    this.onDeleted,
  });

  /// Identifier of the circular to display.
  final String circularId;

  /// Optional preloaded instance shown immediately while fresh data resolves.
  final Circular? initialCircular;

  /// True when rendered as the desktop master-detail right pane.
  final bool isPane;

  /// Callback when the back or pane-close button is pressed.
  final VoidCallback? onCloseOrBack;

  /// Optional custom handler for the Edit action.
  final ValueChanged<Circular>? onEdit;

  /// Callback triggered after deletion succeeds.
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.tokens.spacing;
    final detailAsync = ref.watch(circularDetailProvider(circularId));
    final actionState = ref.watch(circularDetailControllerProvider);
    final controller = ref.read(circularDetailControllerProvider.notifier);

    Future<void> handleDelete(Circular circular) async {
      final confirmed = await showDeleteCircularDialog(
        context,
        circular: circular,
      );
      if (!confirmed || !context.mounted) return;
      final ok = await controller.deleteCircular(circular);
      if (!ok || !context.mounted) return;
      if (onDeleted != null) {
        onDeleted!();
        return;
      }
      if (onCloseOrBack != null) {
        onCloseOrBack!();
        return;
      }
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        if (router.canPop()) {
          router.pop();
        } else {
          router.go('/circulars');
        }
      } else {
        Navigator.of(context).maybePop();
      }
    }

    void handleEdit(Circular circular) {
      if (onEdit != null) {
        onEdit!(circular);
        return;
      }
      unawaited(
        GoRouter.maybeOf(context)?.push<Object?>(
              '/circulars/${circular.id}/edit',
              extra: circular,
            ) ??
            Future<Object?>.value(),
      );
    }

    void handleBackOrClose() {
      if (onCloseOrBack != null) {
        onCloseOrBack!();
        return;
      }
      final router = GoRouter.maybeOf(context);
      if (router != null) {
        if (router.canPop()) {
          router.pop();
        } else {
          router.go('/circulars');
        }
      } else {
        Navigator.of(context).maybePop();
      }
    }

    Widget buildBody(Circular circular) {
      return Column(
        key: ValueKey('circular-detail-view-${circular.id}'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircularDetailHeaderCard(
            circular: circular,
            isPane: isPane,
            isBusy: actionState.isUpdating || actionState.isDeleting,
            onBackOrClose: handleBackOrClose,
            onEdit: () => handleEdit(circular),
            onDelete: () => unawaited(handleDelete(circular)),
          ),
          if (actionState.actionFailure != null) ...[
            SizedBox(height: spacing.md),
            _DetailFailureBanner(
              failure: actionState.actionFailure!,
              onDismiss: controller.clearError,
            ),
          ],
          SizedBox(height: spacing.lg),
          CircularDetailQuickActionsCard(circular: circular),
          SizedBox(height: spacing.lg),
          CircularDetailLinksCard(circular: circular),
          SizedBox(height: spacing.lg),
          CircularDetailOverviewCard(circular: circular),
          SizedBox(height: spacing.lg),
          CircularExamDatesSection(circular: circular),
          SizedBox(height: spacing.lg),
          CircularDetailTextCard(circular: circular),
          SizedBox(height: spacing.lg),
          CircularFilesSection(circular: circular),
          SizedBox(height: spacing.lg),
          CircularPortalLoginSection(circular: circular),
        ],
      );
    }

    return detailAsync.when(
      loading: () {
        if (initialCircular != null && initialCircular!.id == circularId) {
          return buildBody(initialCircular!);
        }
        return const CircularsLoadingState();
      },
      error: (error, _) => CircularsErrorState(
        error: error,
        onRetry: () {
          ref
            ..invalidate(circularByIdProvider(circularId))
            ..invalidate(circularsListProvider);
        },
      ),
      data: (circular) {
        final resolved = circular ??
            (initialCircular?.id == circularId ? initialCircular : null);
        if (resolved == null) {
          return CircularFormNotFoundCard(onBack: handleBackOrClose);
        }
        return buildBody(resolved);
      },
    );
  }
}

class _DetailFailureBanner extends StatelessWidget {
  const _DetailFailureBanner({
    required this.failure,
    required this.onDismiss,
  });

  final CircularFailure failure;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    return Container(
      key: const ValueKey('circular-detail-error-banner'),
      padding: spacing.insetsAllMd,
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.14),
        borderRadius: tokens.radii.buttonRadius,
        border: Border.all(color: colors.danger.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colors.danger,
            size: spacing.lg,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              CircularL10n.circularErrorMessage(failure, context.l10n),
              style: tokens.textStyles.bodySmall.copyWith(color: colors.danger),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(Icons.close_rounded, color: colors.danger),
          ),
        ],
      ),
    );
  }
}
