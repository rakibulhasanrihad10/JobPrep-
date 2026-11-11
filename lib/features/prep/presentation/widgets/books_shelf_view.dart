import 'package:flutter/material.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/animated_progress_bar.dart';
import 'package:job_prep/core/widgets/book_progress_3d_canvas.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_button.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/prep/domain/entities/prep_material.dart';
import 'package:job_prep/features/prep/domain/utils/prep_progress.dart';
import 'package:job_prep/features/prep/presentation/utils/prep_l10n.dart';
import 'package:job_prep/features/prep/presentation/widgets/material_cover_thumbnail.dart';

export 'subject_view_mode_bar.dart';

/// Side-by-side shelf displaying all books of a subject (`3` per row on
/// desktop, `2` per row on mobile) where tapping any book opens its 3D book
/// progress view.
class BooksShelfView extends StatelessWidget {
  /// Creates a [BooksShelfView].
  const BooksShelfView({
    required this.subjectName,
    required this.subjectColor,
    required this.books,
    required this.onOpenBook,
    required this.onAddBook,
    super.key,
    this.replayKey,
  });

  /// Owning subject display name for empty-state messaging.
  final String subjectName;

  /// Resolved subject accent color used behind 3D covers.
  final Color subjectColor;

  /// Filtered list of `MaterialKind.book` materials in this subject.
  final List<PrepMaterial> books;

  /// Invoked when tapping any shelf book item to open `BookProgressView`.
  final ValueChanged<PrepMaterial> onOpenBook;

  /// Invoked from the empty state CTA to add a new book material.
  final VoidCallback onAddBook;

  /// Replay key triggered when opening or switching to the Books shelf tab.
  final Object? replayKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final l10n = context.l10n;

    if (books.isEmpty) {
      return GlassCard(
        key: const ValueKey('books-shelf-empty-card'),
        padding: spacing.insetsAllXl,
        child: Column(
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: spacing.xxl,
              color: subjectColor,
            ),
            SizedBox(height: spacing.md),
            Text(
              l10n.prepBooksShelfEmptyTitle(subjectName),
              style: tokens.textStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.xs),
            Text(
              l10n.prepBooksShelfEmptyBody,
              style: tokens.textStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.lg),
            GlassButton(
              key: const ValueKey('books-shelf-add-book-button'),
              variant: GlassButtonVariant.primary,
              onPressed: onAddBook,
              child: Text(l10n.prepAddBookButton),
            ),
          ],
        ),
      );
    }

    return Column(
      key: const ValueKey('books-shelf-view'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.prepBooksShelfTitle,
          style: tokens.textStyles.titleMedium,
        ),
        SizedBox(height: spacing.xxs),
        Text(
          l10n.prepBooksShelfSubtitle,
          style: tokens.textStyles.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: spacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 560 ? 3 : 2;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < books.length; i += columns) ...[
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var col = 0; col < columns; col++) ...[
                          if (col > 0) SizedBox(width: spacing.md),
                          if (i + col < books.length)
                            Expanded(
                              child: FadeSlideIn(
                                key: ValueKey(
                                  'shelf-fade-$replayKey-${books[i + col].id}',
                                ),
                                delay: Duration(
                                  milliseconds: ((i + col) * 40).clamp(0, 240),
                                ),
                                child: _BooksShelfTile(
                                  book: books[i + col],
                                  subjectColor: subjectColor,
                                  replayKey: replayKey,
                                  onTap: () => onOpenBook(books[i + col]),
                                ),
                              ),
                            )
                          else
                            const Expanded(child: SizedBox.shrink()),
                        ],
                      ],
                    ),
                  ),
                  if (i + columns < books.length) SizedBox(height: spacing.md),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BooksShelfTile extends StatelessWidget {
  const _BooksShelfTile({
    required this.book,
    required this.subjectColor,
    required this.onTap,
    this.replayKey,
  });

  final PrepMaterial book;
  final Color subjectColor;
  final VoidCallback onTap;
  final Object? replayKey;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    final progress = calculateMaterialProgress(book);
    final percentText = l10n.bookProgressPercentLabel(
      PrepL10n.formatPercent(progress, locale),
    );
    final summary = l10n.prepMaterialProgressSummary(
      PrepL10n.formatInt(book.completedUnits, locale),
      PrepL10n.formatInt(book.totalUnits, locale),
      book.unitLabel,
    );
    final updatedAt = book.updatedAt ?? book.createdAt;

    return GlassCard(
      padding: spacing.insetsAllMd,
      onTap: onTap,
      child: KeyedSubtree(
        key: ValueKey('books-shelf-book-${book.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: BookProgress3dCanvas(
                title: book.title,
                accentColor: subjectColor,
                progressFraction: progress,
                percentLabel: percentText,
                width: 110,
                height: 152,
                compact: true,
                replayKey: '$replayKey-${book.id}',
                cover: MaterialCoverThumbnail(
                  title: book.title,
                  subjectColor: subjectColor,
                  coverImagePath: book.coverImagePath,
                  coverImageUrl: book.coverImageUrl,
                  expand: true,
                ),
              ),
            ),
            SizedBox(height: spacing.md),
            Text(
              book.title,
              style: tokens.textStyles.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: spacing.xs),
            AnimatedProgressBar(
              value: progress,
              replayKey: '$replayKey-${book.id}',
              height: spacing.xs,
              progressColor: colors.goldAccent,
            ),
            SizedBox(height: spacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    summary,
                    style: tokens.textStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: spacing.xs),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.xs,
                    vertical: spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.goldAccentSubtle,
                    borderRadius: radii.smRadius,
                  ),
                  child: Text(
                    percentText,
                    style: tokens.textStyles.labelSmall.copyWith(
                      color: colors.goldAccent,
                    ),
                  ),
                ),
              ],
            ),
            if (updatedAt != null) ...[
              SizedBox(height: spacing.xxs),
              Text(
                l10n.bookProgressUpdatedOn(
                  AppFormatters.formatDate(
                    updatedAt,
                    locale: locale,
                    pattern: 'yMMMd',
                  ),
                ),
                style: tokens.textStyles.labelSmall.copyWith(
                  color: colors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
