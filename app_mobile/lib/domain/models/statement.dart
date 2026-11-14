import 'package:iceibank/domain/models/account.dart';

class Statement {
  const Statement({
    required this.accounts,
    required this.unavailableAgencies,
    this.isOffline = false,
  });

  final List<Account> accounts;
  final List<int> unavailableAgencies;
  final bool isOffline;

  double get totalBalance => accounts.fold(0, (sum, account) => sum + account.balance);

  int get holderCount => accounts.map((account) => account.owner).toSet().length;

  DateTime? get cachedAt {
    final dates = accounts.map((account) => account.cachedAt).nonNulls;
    if (dates.isEmpty) return null;
    return dates.reduce((latest, date) => date.isAfter(latest) ? date : latest);
  }

  bool get hasStaleAccounts => accounts.any((account) => account.isStale);

  Statement copyWith({List<Account>? accounts}) {
    return Statement(
      accounts: accounts ?? this.accounts,
      unavailableAgencies: unavailableAgencies,
      isOffline: isOffline,
    );
  }

  static Statement? fromJson(Map<String, Object?> json) {
    if (json case {
      'contas': final List<Object?> rawAccounts,
      'agenciasIndisponiveis': final List<Object?> rawUnavailable,
    }) {
      return Statement(
        accounts: sortAccounts(rawAccounts.map(Account.fromJson).nonNulls),
        unavailableAgencies: List.unmodifiable(rawUnavailable.whereType<int>()),
      );
    }
    return null;
  }

  static List<Account> sortAccounts(Iterable<Account> accounts) {
    return List.unmodifiable(
      accounts.toList()..sort((first, second) => first.id.compareTo(second.id)),
    );
  }
}
