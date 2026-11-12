import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/app_notice.dart';
import 'package:iceibank/ui/core/widgets/receipt_card.dart';
import 'package:iceibank/ui/transfers/view_models/transfer_view_model.dart';
import 'package:iceibank/ui/transfers/widgets/agency_route.dart';
import 'package:iceibank/utils/currency.dart';

class TransferReview extends StatelessWidget {
  const TransferReview({super.key, required this.viewModel});

  final TransferViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final source = viewModel.source!;
    final target = viewModel.knownTarget;
    final errorMessage = viewModel.errorMessage;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Você está transferindo',
          textAlign: TextAlign.center,
          style: AppTypography.subheadline.copyWith(
            color: context.resolve(AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatCurrency(viewModel.amount),
            style: AppTypography.amount(44).copyWith(color: context.resolve(AppColors.text)),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AgencyRoute(sourceAgency: viewModel.sourceAgency!, targetAgency: viewModel.targetAgency),
        const SizedBox(height: AppSpacing.xl),
        ReceiptCard(
          rows: [
            ReceiptRow(
              label: 'De',
              value: 'Conta ${source.id} · Agência ${viewModel.sourceAgency}',
            ),
            ReceiptRow(
              label: 'Para',
              value: 'Conta ${viewModel.targetAccountId} · Agência ${viewModel.targetAgency}',
            ),
            if (target != null) ReceiptRow(label: 'Titular', value: target.holderName),
            ReceiptRow(
              label: 'Tipo',
              value: viewModel.isInterAgency ? 'Entre agências' : 'Mesma agência',
            ),
            ReceiptRow(
              label: 'Saldo depois',
              value: formatCurrency(viewModel.resultingBalance),
              isEmphasized: true,
              isLast: true,
            ),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.lg),
          AppNotice(message: errorMessage, tone: AppNoticeTone.danger),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
