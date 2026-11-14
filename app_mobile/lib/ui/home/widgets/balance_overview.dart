import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/home/widgets/balance_amount.dart';
import 'package:iceibank/ui/sync/widgets/pending_badge.dart';

class BalanceOverview extends StatelessWidget {
  const BalanceOverview({
    super.key,
    required this.label,
    required this.amount,
    required this.caption,
    required this.isVisible,
    required this.onToggleVisibility,
    this.isProvisional = false,
  });

  final String label;
  final double amount;
  final String caption;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final bool isProvisional;

  @override
  Widget build(BuildContext context) {
    final secondary = context.resolve(AppColors.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label.toUpperCase(), style: AppTypography.eyebrow.copyWith(color: secondary)),
            const SizedBox(width: AppSpacing.xs),
            BalanceVisibilityButton(
              isVisible: isVisible,
              onPressed: onToggleVisibility,
              color: secondary,
            ),
          ],
        ),
        BalanceAmount(
          amount: amount,
          isVisible: isVisible,
          style: AppTypography.amount(36).copyWith(color: context.resolve(AppColors.text)),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(caption, style: AppTypography.subheadline.copyWith(color: secondary)),
        if (isProvisional) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              PendingBadge(color: context.resolve(AppColors.primary)),
              const SizedBox(width: 6),
              Text(
                'Saldo provisório, com operações a sincronizar',
                style: AppTypography.footnote.copyWith(
                  color: context.resolve(AppColors.primary),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
