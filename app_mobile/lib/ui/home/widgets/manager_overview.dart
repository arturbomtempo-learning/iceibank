import 'package:flutter/cupertino.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/home/widgets/balance_amount.dart';

class ManagerOverview extends StatelessWidget {
  const ManagerOverview({
    super.key,
    required this.totalBalance,
    required this.accountCount,
    required this.holderCount,
    required this.availableAgencyCount,
    required this.isBalanceVisible,
    required this.onToggleVisibility,
  });

  final double totalBalance;
  final int accountCount;
  final int holderCount;
  final int availableAgencyCount;
  final bool isBalanceVisible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final muted = context.resolve(AppColors.inkSecondary);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: context.resolve(AppColors.ink),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.card),
          gradient: const RadialGradient(
            center: Alignment(0.95, -1.2),
            radius: 1.4,
            colors: [Color(0x4757E3A8), Color(0x0057E3A8)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('SALDO SOB GESTÃO', style: AppTypography.eyebrow.copyWith(color: muted)),
                const SizedBox(width: AppSpacing.xs),
                BalanceVisibilityButton(
                  isVisible: isBalanceVisible,
                  onPressed: onToggleVisibility,
                  color: muted,
                ),
              ],
            ),
            BalanceAmount(
              amount: totalBalance,
              isVisible: isBalanceVisible,
              style: AppTypography.amount(34).copyWith(color: AppColors.white),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _StatPill(
                  icon: CupertinoIcons.creditcard,
                  label: '$accountCount ${accountCount == 1 ? 'conta' : 'contas'}',
                ),
                _StatPill(
                  icon: CupertinoIcons.person_2,
                  label: '$holderCount ${holderCount == 1 ? 'correntista' : 'correntistas'}',
                ),
                _StatPill(
                  icon: CupertinoIcons.building_2_fill,
                  label: '$availableAgencyCount de ${AgencyEndpoints.count} agências no ar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.accent)),
        ],
      ),
    );
  }
}
