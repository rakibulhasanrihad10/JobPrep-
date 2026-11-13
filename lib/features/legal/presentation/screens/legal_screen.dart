import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:job_prep/core/localization/app_localizations_extension.dart';
import 'package:job_prep/core/theme/app_theme_tokens.dart';
import 'package:job_prep/core/widgets/fade_slide_in.dart';
import 'package:job_prep/core/widgets/glass_card.dart';
import 'package:job_prep/features/auth/domain/entities/auth_session_state.dart';
import 'package:job_prep/features/auth/presentation/navigation/auth_redirect.dart';
import 'package:job_prep/features/auth/presentation/providers/auth_providers.dart';

/// Document types supported by the [LegalScreen].
enum LegalDocType {
  /// Privacy Policy and data security declaration.
  privacy,

  /// Terms of Service and acceptable use conditions.
  terms,
}

/// Presentation screen rendering Privacy Policy and Terms of Service documents
/// with glassmorphism design tokens, bilingual ARB strings, and responsive
/// layout.
class LegalScreen extends ConsumerWidget {
  /// Creates a [LegalScreen] for [type].
  const LegalScreen({
    required this.type,
    super.key,
  });

  /// The active legal document type to display.
  final LegalDocType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;
    final l10n = context.l10n;

    final isPrivacy = type == LegalDocType.privacy;
    final title = isPrivacy
        ? l10n.legalPrivacyPolicyTitle
        : l10n.legalTermsOfServiceTitle;
    final subtitle = isPrivacy
        ? l10n.legalPrivacyPolicySubtitle
        : l10n.legalTermsOfServiceSubtitle;

    final sections = isPrivacy
        ? <_LegalSectionData>[
            _LegalSectionData(
              title: l10n.legalPrivacySection1Title,
              body: l10n.legalPrivacySection1Body,
              icon: Icons.shield_outlined,
            ),
            _LegalSectionData(
              title: l10n.legalPrivacySection2Title,
              body: l10n.legalPrivacySection2Body,
              icon: Icons.lock_outline,
            ),
            _LegalSectionData(
              title: l10n.legalPrivacySection3Title,
              body: l10n.legalPrivacySection3Body,
              icon: Icons.table_chart_outlined,
            ),
            _LegalSectionData(
              title: l10n.legalPrivacySection4Title,
              body: l10n.legalPrivacySection4Body,
              icon: Icons.download_outlined,
            ),
          ]
        : <_LegalSectionData>[
            _LegalSectionData(
              title: l10n.legalTermsSection1Title,
              body: l10n.legalTermsSection1Body,
              icon: Icons.menu_book_outlined,
            ),
            _LegalSectionData(
              title: l10n.legalTermsSection2Title,
              body: l10n.legalTermsSection2Body,
              icon: Icons.verified_user_outlined,
            ),
            _LegalSectionData(
              title: l10n.legalTermsSection3Title,
              body: l10n.legalTermsSection3Body,
              icon: Icons.key_outlined,
            ),
          ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: SingleChildScrollView(
              key: ValueKey('legal-scroll-view-${type.name}'),
              padding: spacing.insetsAllXl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeSlideIn(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        key: const ValueKey('legal-back-button'),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                            return;
                          }
                          final auth = ref.read(authSessionProvider);
                          if (auth.status == AuthStatus.signedIn) {
                            context.go('/settings');
                          } else {
                            context.go(AppRoutePaths.login);
                          }
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          size: spacing.lg,
                          color: colors.goldAccent,
                        ),
                        label: Text(
                          l10n.legalBackToApp,
                          style: textStyles.labelLarge.copyWith(
                            color: colors.goldAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  FadeSlideIn(
                    index: 1,
                    child: Text(
                      title,
                      key: ValueKey('legal-title-${type.name}'),
                      style: textStyles.headlineMedium,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  FadeSlideIn(
                    index: 2,
                    child: Text(
                      subtitle,
                      key: ValueKey('legal-subtitle-${type.name}'),
                      style: textStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.xl),
                  for (var i = 0; i < sections.length; i++) ...[
                    FadeSlideIn(
                      index: i + 3,
                      child: _LegalSectionCard(
                        data: sections[i],
                        key: ValueKey('legal-section-${type.name}-$i'),
                      ),
                    ),
                    SizedBox(height: spacing.md),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalSectionData {
  const _LegalSectionData({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

class _LegalSectionCard extends StatelessWidget {
  const _LegalSectionCard({
    required this.data,
    super.key,
  });

  final _LegalSectionData data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final spacing = tokens.spacing;
    final textStyles = tokens.textStyles;
    final colors = tokens.colors;

    return GlassCard(
      padding: spacing.insetsAllLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: spacing.insetsAllSm,
                decoration: BoxDecoration(
                  color: colors.goldAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(tokens.radii.sm),
                ),
                child: Icon(
                  data.icon,
                  size: spacing.lg,
                  color: colors.goldAccent,
                ),
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Text(
                  data.title,
                  style: textStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.md),
          Text(
            data.body,
            style: textStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
