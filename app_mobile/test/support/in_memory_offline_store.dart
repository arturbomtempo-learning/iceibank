import 'package:iceibank/data/services/offline_store.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/pending_operation.dart';

class InMemoryOfflineStore implements OfflineStore {
  final Map<String, Map<int, Account>> accounts = {};
  final Map<int, PendingOperation> operations = {};
  int _nextId = 1;

  @override
  Future<List<Account>> readAccounts(String username) async {
    final stored = accounts[username]?.values.toList() ?? [];
    return stored..sort((first, second) => first.id.compareTo(second.id));
  }

  @override
  Future<void> replaceAccounts(
    String username,
    List<Account> replacement, {
    required Iterable<int> refreshedAgencies,
  }) async {
    final agencies = refreshedAgencies.toSet();
    final stored = accounts.putIfAbsent(username, () => {})
      ..removeWhere((_, account) => agencies.contains(account.agencyId));
    for (final account in replacement) {
      stored[account.id] = _cached(account);
    }
  }

  @override
  Future<void> saveAccount(String username, Account account) async {
    accounts.putIfAbsent(username, () => {})[account.id] = _cached(account);
  }

  @override
  Future<void> clearAccounts(String username) async => accounts.remove(username);

  @override
  Future<List<PendingOperation>> readOperations(String username) async {
    return operations.values.where((operation) => operation.username == username).toList()
      ..sort((first, second) => first.id!.compareTo(second.id!));
  }

  @override
  Future<PendingOperation> insertOperation(PendingOperation operation) async {
    final stored = operation.copyWith(id: _nextId++);
    operations[stored.id!] = stored;
    return stored;
  }

  @override
  Future<void> updateOperation(PendingOperation operation) async {
    operations[operation.id!] = operation;
  }

  @override
  Future<void> deleteOperation(int id) async => operations.remove(id);

  Account _cached(Account account) {
    return Account(
      id: account.id,
      holderName: account.holderName,
      owner: account.owner,
      balance: account.balance,
      agencyId: account.agencyId,
      vector: account.vector,
      cachedAt: DateTime(2026, 11, 14, 9, 30),
    );
  }
}
