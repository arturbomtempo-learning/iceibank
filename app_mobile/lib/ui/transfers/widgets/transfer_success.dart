import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/animated_check.dart';
import 'package:iceibank/ui/core/widgets/app_button.dart';
import 'package:iceibank/ui/core/widgets/app_notice.dart';
import 'package:iceibank/ui/core/widgets/fade_slide_in.dart';
import 'package:iceibank/ui/core/widgets/receipt_card.dart';
import 'package:iceibank/ui/transfers/view_models/transfer_view_model.dart';
import 'package:iceibank/utils/currency.dart';

class TransferSuccess extends StatelessWidget {
  const TransferSuccess({super.key, required this.receipt, required this.onDone});

  final TransferReceipt receipt;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        const Center(child: AnimatedCheck()),
        const SizedBox(height: AppSpacing.xl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 350),
          child: Column(
            children: [
              Text(
                receipt.isInterAgency ? 'Transferência enviada' : 'Transferência concluída',
                textAlign: TextAlign.center,
                style: AppTypography.title1.copyWith(color: context.resolve(AppColors.text)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                formatCurrency(receipt.amount),
                style: AppTypography.amount(30).copyWith(color: context.resolve(AppColors.primary)),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                receipt.message,
                textAlign: TextAlign.center,
                style: AppTypography.footnote.copyWith(
                  color: context.resolve(AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        FadeSlideIn(
          delay: const Duration(milliseconds: 480),
          child: Column(
            children: [
              ReceiptCard(
                rows: [
                  ReceiptRow(label: 'De', value: 'Conta ${receipt.source.id}'),
                  ReceiptRow(label: 'Para', value: 'Conta ${receipt.targetAccountId}'),
                  ReceiptRow(
                    label: 'Tipo',
                    value: receipt.isInterAgency ? 'Entre agências' : 'Mesma agência',
                  ),
                  ReceiptRow(
                    label: 'Saldo restante',
                    value: formatCurrency(receipt.remainingBalance),
                    isEmphasized: true,
                    isLast: true,
                  ),
                ],
              ),
              if (receipt.isInterAgency) ...[
                const SizedBox(height: AppSpacing.lg),
                const AppNotice(
                  message:
                      'O crédito é entregue pela fila e chega à conta de destino em instantes. '
                      'Se ela não existir, o valor volta automaticamente para você.',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(label: 'Concluir', onPressed: onDone),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
