import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class AgencyRoutingTile extends StatelessWidget {
  const AgencyRoutingTile({super.key, required this.pinnedAgencyId, required this.onSelected});

  final int? pinnedAgencyId;
  final Future<void> Function(int? agencyId) onSelected;

  Future<void> _choose(BuildContext context) async {
    final choice = await showCupertinoModalPopup<_AgencyChoice>(
      context: context,
      builder: (context) => _AgencyRoutingSheet(pinnedAgencyId: pinnedAgencyId),
    );
    if (choice == null) return;

    unawaited(HapticFeedback.selectionClick());
    await onSelected(choice.agencyId);
  }

  @override
  Widget build(BuildContext context) {
    final pinned = pinnedAgencyId;
    final isAutomatic = pinned == null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: ColoredBox(
        color: context.resolve(AppColors.surface),
        child: CupertinoListTile(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          leadingSize: 40,
          leading: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.resolve(isAutomatic ? AppColors.primarySoft : AppColors.fill),
            ),
            child: Icon(
              isAutomatic ? CupertinoIcons.arrow_branch : CupertinoIcons.pin_fill,
              size: 18,
              color: context.resolve(isAutomatic ? AppColors.onPrimarySoft : AppColors.text),
            ),
          ),
          title: Text(
            'Agência de destino',
            style: AppTypography.callout.copyWith(
              color: context.resolve(AppColors.text),
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            isAutomatic ? 'Segue a agência da conta' : 'Fixada para testes',
            style: AppTypography.footnote.copyWith(color: context.resolve(AppColors.textSecondary)),
          ),
          additionalInfo: Text(
            isAutomatic ? 'Automática' : 'Agência $pinned',
            style: AppTypography.subheadline.copyWith(
              color: context.resolve(AppColors.textSecondary),
            ),
          ),
          trailing: const CupertinoListTileChevron(),
          onTap: () => _choose(context),
        ),
      ),
    );
  }
}

class _AgencyChoice {
  const _AgencyChoice(this.agencyId);

  final int? agencyId;
}

class _AgencyRoutingSheet extends StatelessWidget {
  const _AgencyRoutingSheet({required this.pinnedAgencyId});

  final int? pinnedAgencyId;

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('Agência de destino das chamadas'),
      message: const Text(
        'No modo automático, cada operação vai para a agência que guarda a conta. '
        'Fixe uma agência apenas se quiser testar o comportamento da partição.',
      ),
      actions: [
        _option(context, agencyId: null, label: 'Automática'),
        for (final agencyId in AgencyEndpoints.ids)
          _option(context, agencyId: agencyId, label: 'Agência $agencyId'),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancelar'),
      ),
    );
  }

  Widget _option(BuildContext context, {required int? agencyId, required String label}) {
    final isSelected = agencyId == pinnedAgencyId;

    return CupertinoActionSheetAction(
      isDefaultAction: isSelected,
      onPressed: () => Navigator.of(context).pop(_AgencyChoice(agencyId)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (isSelected) ...[
            const SizedBox(width: AppSpacing.sm),
            const Icon(CupertinoIcons.checkmark_alt, size: 20),
          ],
        ],
      ),
    );
  }
}
