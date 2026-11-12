import 'package:flutter/cupertino.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/utils/currency.dart';

class AccountSelector extends StatelessWidget {
  const AccountSelector({
    super.key,
    required this.label,
    required this.accounts,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
  });

  final String label;
  final List<Account> accounts;
  final Account selected;
  final ValueChanged<Account> onSelected;
  final bool enabled;

  bool get _canChange => enabled && accounts.length > 1;

  Future<void> _openPicker(BuildContext context) async {
    final chosen = await showCupertinoModalPopup<Account>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(label),
        actions: [
          for (final account in accounts)
            CupertinoActionSheetAction(
              isDefaultAction: account.id == selected.id,
              onPressed: () => Navigator.of(context).pop(account),
              child: Text(
                'Conta ${account.id} · ${account.holderName} · ${formatCurrency(account.balance)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ),
    );

    if (chosen != null) onSelected(chosen);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: _canChange,
      label: '$label: conta ${selected.id}, agência ${selected.agencyId}',
      hint: _canChange ? 'Toque para trocar de conta' : null,
      child: ExcludeSemantics(
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _canChange ? () => _openPicker(context) : null,
          disabledColor: const Color(0x00000000),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.resolve(AppColors.surface),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Row(
              children: [
                const _MiniCard(),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: AppTypography.eyebrow.copyWith(
                          color: context.resolve(AppColors.textSecondary),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Conta ${selected.id} · Agência ${selected.agencyId}',
                        style: AppTypography.headline.copyWith(
                          color: context.resolve(AppColors.text),
                        ),
                      ),
                      Text(
                        selected.holderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.footnote.copyWith(
                          color: context.resolve(AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_canChange)
                  Icon(
                    CupertinoIcons.chevron_up_chevron_down,
                    size: 18,
                    color: context.resolve(AppColors.textTertiary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 32,
      padding: const EdgeInsets.all(5),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF124A3E), Color(0xFF03251F)],
        ),
      ),
      child: Container(
        width: 11,
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          gradient: const LinearGradient(colors: [Color(0xFFE2E6E5), Color(0xFFA9AFAE)]),
        ),
      ),
    );
  }
}
