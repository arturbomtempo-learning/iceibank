import 'package:flutter/cupertino.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/domain/models/pending_operation.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/app_notice.dart';
import 'package:iceibank/utils/currency.dart';
import 'package:iceibank/utils/time.dart';

class PendingOperationsSection extends StatelessWidget {
  const PendingOperationsSection({
    super.key,
    required this.operations,
    required this.isSyncing,
    required this.onDecide,
  });

  final List<PendingOperation> operations;
  final bool isSyncing;
  final ValueChanged<PendingOperation> onDecide;

  @override
  Widget build(BuildContext context) {
    final undecided = operations.where((operation) => operation.needsDecision).length;
    final waiting = operations.length - undecided;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (undecided > 0) ...[
          AppNotice(
            tone: AppNoticeTone.danger,
            message: undecided == 1
                ? 'Uma operação não pôde ser aplicada automaticamente. '
                      'Toque nela para ver o saldo real e decidir.'
                : '$undecided operações não puderam ser aplicadas automaticamente. '
                      'Toque em cada uma para ver o saldo real e decidir.',
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: ColoredBox(
            color: context.resolve(AppColors.surface),
            child: Column(
              children: [
                if (waiting > 0) _Header(waitingCount: waiting, isSyncing: isSyncing),
                for (final operation in operations) ...[
                  if (operation != operations.first || waiting > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 68),
                      child: Container(height: 0.5, color: context.resolve(AppColors.fill)),
                    ),
                  _OperationTile(
                    operation: operation,
                    onTap: operation.needsDecision ? () => onDecide(operation) : null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.waitingCount, required this.isSyncing});

  final int waitingCount;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    final secondary = context.resolve(AppColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 18,
            child: isSyncing
                ? const CupertinoActivityIndicator(radius: 8)
                : Icon(CupertinoIcons.arrow_2_circlepath, size: 16, color: secondary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isSyncing
                  ? 'Tentando enviar às agências…'
                  : waitingCount == 1
                  ? 'Será enviada sozinha quando a agência voltar'
                  : 'Serão enviadas sozinhas quando as agências voltarem',
              style: AppTypography.footnote.copyWith(color: secondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({required this.operation, required this.onTap});

  final PendingOperation operation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDeposit = operation.type == OperationType.deposit;
    final needsDecision = operation.needsDecision;
    final danger = context.resolve(AppColors.danger);
    final secondary = context.resolve(AppColors.textSecondary);

    final (String status, Color statusColor) = switch (operation.status) {
      PendingStatus.waiting => (
        'Aguardando a Agência ${operation.agencyId}\nGuardada às ${formatClock(operation.createdAt).substring(0, 5)}',
        secondary,
      ),
      PendingStatus.conflict => (
        'Não aplicada\nSaldo real: ${formatCurrency(operation.serverBalance ?? 0)}',
        danger,
      ),
      PendingStatus.rejected => (operation.message ?? 'Recusada pela agência', danger),
    };

    return CupertinoListTile(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      leadingSize: 40,
      leading: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.resolve(needsDecision ? AppColors.dangerSoft : AppColors.fill),
        ),
        child: Icon(
          needsDecision
              ? CupertinoIcons.exclamationmark
              : isDeposit
              ? CupertinoIcons.arrow_down_to_line
              : CupertinoIcons.arrow_up_to_line,
          size: 18,
          color: needsDecision ? danger : context.resolve(AppColors.text),
        ),
      ),
      title: Text(
        '${operation.type.noun} · Conta ${operation.accountId}',
        style: AppTypography.callout.copyWith(
          color: context.resolve(AppColors.text),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        status,
        maxLines: 2,
        style: AppTypography.footnote.copyWith(color: statusColor),
      ),
      additionalInfo: Text(
        '${isDeposit ? '+' : '−'} ${formatCurrency(operation.amount)}',
        style: AppTypography.amount(15).copyWith(
          color: needsDecision ? secondary : context.resolve(AppColors.text),
          decoration: needsDecision ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: needsDecision ? const CupertinoListTileChevron() : null,
      onTap: onTap,
    );
  }
}
