import 'package:flutter/cupertino.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/home/view_models/home_view_model.dart';
import 'package:iceibank/utils/currency.dart';

class AgencyDistribution extends StatelessWidget {
  const AgencyDistribution({super.key, required this.summaries, required this.isBalanceVisible});

  final List<AgencySummary> summaries;
  final bool isBalanceVisible;

  @override
  Widget build(BuildContext context) {
    final totalAccounts = summaries.fold(0, (sum, summary) => sum + summary.accountCount);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl - 4),
      decoration: BoxDecoration(
        color: context.resolve(AppColors.surface),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contas por agência',
            style: AppTypography.headline.copyWith(color: context.resolve(AppColors.text)),
          ),
          const SizedBox(height: 2),
          Text(
            'Cada conta vive na agência definida por id % ${AgencyEndpoints.count}.',
            style: AppTypography.footnote.copyWith(color: context.resolve(AppColors.textSecondary)),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final summary in summaries) ...[
            _AgencyRow(
              summary: summary,
              share: totalAccounts == 0 ? 0 : summary.accountCount / totalAccounts,
              isBalanceVisible: isBalanceVisible,
            ),
            if (summary != summaries.last) const SizedBox(height: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _AgencyRow extends StatelessWidget {
  const _AgencyRow({required this.summary, required this.share, required this.isBalanceVisible});

  final AgencySummary summary;
  final double share;
  final bool isBalanceVisible;

  @override
  Widget build(BuildContext context) {
    final text = context.resolve(AppColors.text);
    final secondary = context.resolve(AppColors.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Agência ${summary.agencyId}',
              style: AppTypography.subheadline.copyWith(color: text, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (!summary.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: context.resolve(AppColors.dangerSoft),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'Fora do ar',
                  style: AppTypography.caption.copyWith(color: context.resolve(AppColors.danger)),
                ),
              ),
            const Spacer(),
            Text(
              summary.isAvailable
                  ? '${summary.accountCount} ${summary.accountCount == 1 ? 'conta' : 'contas'}'
                  : 'Sem resposta',
              style: AppTypography.footnote.copyWith(color: secondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            height: 8,
            color: context.resolve(AppColors.fill),
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: share),
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.brandLight, AppColors.brand]),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isBalanceVisible ? formatCurrency(summary.balance) : 'R\$ ••••',
          style: AppTypography.amount(15).copyWith(color: text),
        ),
      ],
    );
  }
}
