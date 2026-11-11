import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';

/// Sub-view selector inside a subject detail pane.
enum PrepSubjectViewMode {
  allMaterials,
  booksShelf,
}

/// Compact switcher allowing the user to view either all materials for a
/// subject or focus purely on the visual Books shelf.
class SubjectViewModeBar extends StatelessWidget {
  /// Creates a [SubjectViewModeBar].
  const SubjectViewModeBar({
    required this.activeMode,
    required this.bookCount,
    required this.onChanged,
    super.key,
  });

  /// Currently displayed subject view mode.
  final PrepSubjectViewMode activeMode;

  /// Number of `MaterialKind.book` materials in the active subject.
  final int bookCount;

  /// Invoked when the user toggles between All materials and Books shelf.
  final ValueChanged<PrepSubjectViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    return GlassCard(
      padding: spacing.insetsAllSm,
      child: Wrap(
        spacing: spacing.sm,
        runSpacing: spacing.sm,
        children: [
          GlassButton(
            key: const ValueKey('subject-tab-all-materials'),
            variant: activeMode == PrepSubjectViewMode.allMaterials
                ? GlassButtonVariant.primary
                : GlassButtonVariant.standard,
            leading: Icon(
              Icons.grid_view_outlined,
              size: spacing.lg,
              color: activeMode == PrepSubjectViewMode.allMaterials
                  ? colors.goldAccent
                  : colors.textSecondary,
            ),
            onPressed: () => onChanged(PrepSubjectViewMode.allMaterials),
            child: Text(l10n.prepSubjectViewAllMaterials),
          ),
          GlassButton(
            key: const ValueKey('subject-tab-books-shelf'),
            variant: activeMode == PrepSubjectViewMode.booksShelf
                ? GlassButtonVariant.primary
                : GlassButtonVariant.standard,
            leading: Icon(
              Icons.menu_book_outlined,
              size: spacing.lg,
              color: activeMode == PrepSubjectViewMode.booksShelf
                  ? colors.goldAccent
                  : colors.textSecondary,
            ),
            onPressed: () => onChanged(PrepSubjectViewMode.booksShelf),
            child: Text(
              l10n.prepSubjectViewBooksShelf(
                PrepL10n.formatInt(bookCount, locale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
