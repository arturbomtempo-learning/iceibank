import 'package:flutter/cupertino.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/animated_check.dart';
import 'package:iceibank/ui/core/widgets/app_button.dart';
import 'package:iceibank/ui/core/widgets/fade_slide_in.dart';
import 'package:iceibank/ui/core/widgets/receipt_card.dart';
import 'package:iceibank/ui/operations/view_models/operation_view_model.dart';
import 'package:iceibank/utils/currency.dart';

class OperationSuccess extends StatelessWidget {
  const OperationSuccess({
    super.key,
    required this.type,
    required this.receipt,
    required this.onDone,
    required this.onAnother,
  });

  final OperationType type;
  final OperationReceipt receipt;
  final VoidCallback onDone;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
    final isDeposit = type == OperationType.deposit;
    final signedAmount = '${isDeposit ? '+' : '−'} ${formatCurrency(receipt.amount)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        children: [
          const Spacer(),
          const AnimatedCheck(),
          const SizedBox(height: AppSpacing.xl),
          FadeSlideIn(
            delay: const Duration(milliseconds: 350),
            child: Column(
              children: [
                Text(
                  type.successTitle,
                  style: AppTypography.title1.copyWith(color: context.resolve(AppColors.text)),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  signedAmount,
                  style: AppTypography.amount(30).copyWith(
                    color: context.resolve(isDeposit ? AppColors.primary : AppColors.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          FadeSlideIn(
            delay: const Duration(milliseconds: 480),
            child: ReceiptCard(
              rows: [
                ReceiptRow(label: 'Conta', value: '${receipt.account.id}'),
                ReceiptRow(label: 'Agência', value: '${receipt.account.agencyId}'),
                ReceiptRow(label: 'Titular', value: receipt.account.holderName),
                ReceiptRow(
                  label: 'Novo saldo',
                  value: formatCurrency(receipt.newBalance),
                  isEmphasized: true,
                  isLast: true,
                ),
              ],
            ),
          ),
          const Spacer(),
          AppButton(label: 'Concluir', onPressed: onDone),
          CupertinoButton(
            onPressed: onAnother,
            child: Text(isDeposit ? 'Fazer outro depósito' : 'Fazer outro saque'),
          ),
        ],
      ),
    );
  }
}
