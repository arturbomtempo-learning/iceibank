import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/pending_operation.dart';

abstract interface class OfflineStore {
  Future<List<Account>> readAccounts(String username);

  Future<void> replaceAccounts(
    String username,
    List<Account> accounts, {
    required Iterable<int> refreshedAgencies,
  });

  Future<void> saveAccount(String username, Account account);

  Future<void> clearAccounts(String username);

  Future<List<PendingOperation>> readOperations(String username);

  Future<PendingOperation> insertOperation(PendingOperation operation);

  Future<void> updateOperation(PendingOperation operation);

  Future<void> deleteOperation(int id);
}
