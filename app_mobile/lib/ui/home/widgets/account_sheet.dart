import 'package:flutter/cupertino.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/home/widgets/account_card.dart';

Future<void> showAccountSheet(
  BuildContext context, {
  required Account account,
  required bool isBalanceVisible,
}) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (context) => _AccountSheet(account: account, isBalanceVisible: isBalanceVisible),
  );
}

class _AccountSheet extends StatelessWidget {
  const _AccountSheet({required this.account, required this.isBalanceVisible});

  final Account account;
  final bool isBalanceVisible;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: context.resolve(AppColors.background),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.card + 8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: context.resolve(AppColors.textTertiary).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            account.holderName,
            style: AppTypography.title2.copyWith(color: context.resolve(AppColors.text)),
          ),
          const SizedBox(height: 2),
          Text(
            'Conta ${account.id} · Agência ${account.agencyId} · @${account.owner}',
            style: AppTypography.subheadline.copyWith(
              color: context.resolve(AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AccountCard(account: account, isBalanceVisible: isBalanceVisible),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Toque no cartão para ver os dados da conta',
            textAlign: TextAlign.center,
            style: AppTypography.footnote.copyWith(color: context.resolve(AppColors.textTertiary)),
          ),
          const SizedBox(height: AppSpacing.sm),
          CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
