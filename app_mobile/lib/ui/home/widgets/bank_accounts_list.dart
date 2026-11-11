import 'package:flutter/cupertino.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/home/widgets/account_sheet.dart';
import 'package:iceibank/utils/currency.dart';

class BankAccountsList extends StatelessWidget {
  const BankAccountsList({super.key, required this.accounts, required this.isBalanceVisible});

  final List<Account> accounts;
  final bool isBalanceVisible;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: ColoredBox(
        color: context.resolve(AppColors.surface),
        child: Column(
          children: [
            for (final account in accounts) ...[
              _AccountTile(account: account, isBalanceVisible: isBalanceVisible),
              if (account != accounts.last)
                Padding(
                  padding: const EdgeInsets.only(left: 68),
                  child: Container(height: 0.5, color: context.resolve(AppColors.fill)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, required this.isBalanceVisible});

  final Account account;
  final bool isBalanceVisible;

  String get _initials {
    final words = account.holderName.split(RegExp(r'\s+'));
    final letters = words.length > 1 ? '${words.first[0]}${words.last[0]}' : words.first;
    return letters.substring(0, letters.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      leadingSize: 40,
      leading: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.resolve(AppColors.primarySoft),
        ),
        child: Text(
          _initials,
          style: AppTypography.caption.copyWith(
            color: context.resolve(AppColors.onPrimarySoft),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(
        account.holderName,
        style: AppTypography.callout.copyWith(
          color: context.resolve(AppColors.text),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Conta ${account.id} · Agência ${account.agencyId}',
        style: AppTypography.footnote.copyWith(color: context.resolve(AppColors.textSecondary)),
      ),
      additionalInfo: Text(
        isBalanceVisible ? formatCurrency(account.balance) : 'R\$ ••••',
        style: AppTypography.amount(15).copyWith(color: context.resolve(AppColors.text)),
      ),
      trailing: const CupertinoListTileChevron(),
      onTap: () => showAccountSheet(context, account: account, isBalanceVisible: isBalanceVisible),
    );
  }
}
