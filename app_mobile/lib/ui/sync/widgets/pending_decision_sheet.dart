import 'package:flutter/cupertino.dart';
import 'package:iceibank/domain/models/pending_operation.dart';
import 'package:iceibank/utils/currency.dart';

enum PendingDecision { retry, discard }

Future<PendingDecision?> showPendingDecisionSheet(
  BuildContext context, {
  required PendingOperation operation,
}) {
  final summary = '${operation.type.noun} de ${formatCurrency(operation.amount)}';
  final isConflict = operation.status == PendingStatus.conflict;

  return showCupertinoModalPopup<PendingDecision>(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Text(isConflict ? '$summary não aplicado' : '$summary recusado'),
      message: Text(
        isConflict
            ? 'O saldo da conta ${operation.accountId} mudou enquanto você estava sem conexão, '
                  'então a Agência ${operation.agencyId} não aplicou a operação às cegas.\n\n'
                  'Saldo real agora: ${formatCurrency(operation.serverBalance ?? 0)}'
            : operation.message ?? 'A agência recusou a operação.',
      ),
      actions: [
        if (isConflict)
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(PendingDecision.retry),
            child: const Text('Aplicar mesmo assim'),
          ),
        CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(PendingDecision.discard),
          child: const Text('Descartar operação'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Decidir depois'),
      ),
    ),
  );
}
