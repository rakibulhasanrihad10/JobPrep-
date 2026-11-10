import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/localization/formatters.dart';
import 'package:job_prep/core/localization/locale_controller.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';

/// Card widget demonstrating locale-aware formatting, plurals,
/// and placeholders.
class FormattersPreviewCard extends ConsumerWidget {
  /// Creates a [FormattersPreviewCard].
  const FormattersPreviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final useBanglaDigits = ref.watch(useBanglaDigitsProvider);
    final tokens = context.tokens;
    final colors = tokens.colors;
    final spacing = tokens.spacing;
    final radii = tokens.radii;
    final textStyles = tokens.textStyles;
    final l10n = context.l10n;

    final sampleFee = AppFormatters.formatCurrency(
      1500,
      locale: currentLocale,
      useBanglaDigits: useBanglaDigits,
    );
    final sampleDate = AppFormatters.formatDate(
      DateTime(2026, 12, 15),
      locale: currentLocale,
      useBanglaDigits: useBanglaDigits,
    );
    final currentPage = AppFormatters.formatNumber(
      150,
      locale: currentLocale,
      useBanglaDigits: useBanglaDigits,
    );
    final totalPages = AppFormatters.formatNumber(
      300,
      locale: currentLocale,
      useBanglaDigits: useBanglaDigits,
    );

    final shouldConvertDigits =
        currentLocale.languageCode == 'bn' || useBanglaDigits;

    final books1 = shouldConvertDigits
        ? AppFormatters.toBanglaDigits(l10n.booksCompleted(1))
        : l10n.booksCompleted(1);
    final books3 = shouldConvertDigits
        ? AppFormatters.toBanglaDigits(l10n.booksCompleted(3))
        : l10n.booksCompleted(3);
    final deadline5 = shouldConvertDigits
        ? AppFormatters.toBanglaDigits(l10n.deadlineDaysRemaining(5))
        : l10n.deadlineDaysRemaining(5);

    return Container(
      padding: spacing.insetsAllLg,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radii.cardRadius,
        border: Border.all(color: colors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.formattersTitle,
                  style: textStyles.titleMedium,
                ),
              ),
              Switch(
                value: useBanglaDigits,
                activeThumbColor: colors.goldAccent,
                onChanged: (val) {
                  unawaited(
                    ref
                        .read(useBanglaDigitsProvider.notifier)
                        .setUseBanglaDigits(enabled: val),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Text(
            l10n.sampleCurrency(sampleFee),
            style: textStyles.bodyMedium,
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.sampleDate(sampleDate),
            style: textStyles.bodyMedium,
          ),
          SizedBox(height: spacing.xs),
          Text(
            l10n.pageProgress(currentPage, totalPages),
            style: textStyles.bodyMedium,
          ),
          SizedBox(height: spacing.md),
          Text(
            books1,
            style: textStyles.bodySmall,
          ),
          SizedBox(height: spacing.xs),
          Text(
            books3,
            style: textStyles.bodySmall,
          ),
          SizedBox(height: spacing.xs),
          Text(
            deadline5,
            style: textStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
