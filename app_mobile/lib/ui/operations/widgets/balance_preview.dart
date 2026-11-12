import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/utils/currency.dart';

class BalancePreview extends StatelessWidget {
  const BalancePreview({
    super.key,
    required this.balance,
    required this.resultingBalance,
    required this.hasAmount,
    required this.isOverdrawn,
  });

  final double balance;
  final double resultingBalance;
  final bool hasAmount;
  final bool isOverdrawn;

  @override
  Widget build(BuildContext context) {
    final secondary = context.resolve(AppColors.textSecondary);
    final style = AppTypography.subheadline.copyWith(color: secondary);

    if (isOverdrawn) {
      return Text(
        'Saldo insuficiente. Disponível: ${formatCurrency(balance)}',
        textAlign: TextAlign.center,
        style: style.copyWith(color: context.resolve(AppColors.danger)),
      );
    }

    if (!hasAmount) {
      return Text('Saldo atual ${formatCurrency(balance)}', style: style);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(formatCurrency(balance), style: style),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Icon(CupertinoIcons.arrow_right, size: 14, color: secondary),
        ),
        Text(
          formatCurrency(resultingBalance),
          style: style.copyWith(
            color: context.resolve(AppColors.text),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
