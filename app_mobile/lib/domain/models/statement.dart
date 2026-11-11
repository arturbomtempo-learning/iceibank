import 'package:iceibank/domain/models/account.dart';

class Statement {
  const Statement({
    required this.accounts,
    required this.totalBalance,
    required this.unavailableAgencies,
  });

  final List<Account> accounts;
  final double totalBalance;
  final List<int> unavailableAgencies;

  int get holderCount => accounts.map((account) => account.owner).toSet().length;

  static Statement? fromJson(Map<String, Object?> json) {
    if (json case {
      'contas': final List<Object?> rawAccounts,
      'saldoTotal': final num totalBalance,
      'agenciasIndisponiveis': final List<Object?> rawUnavailable,
    }) {
      final accounts = rawAccounts.map(Account.fromJson).nonNulls.toList()
        ..sort((first, second) => first.id.compareTo(second.id));

      return Statement(
        accounts: List.unmodifiable(accounts),
        totalBalance: totalBalance.toDouble(),
        unavailableAgencies: List.unmodifiable(rawUnavailable.whereType<int>()),
      );
    }
    return null;
  }
}
