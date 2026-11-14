import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/data/services/offline_store.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/domain/models/statement.dart';
import 'package:iceibank/utils/result.dart';

class AccountRepository {
  AccountRepository({required this._apiClient, required this._offlineStore});

  final ApiClient _apiClient;
  final OfflineStore _offlineStore;

  Future<Result<Statement>> fetchStatement({required String username}) async {
    final JsonMap data;
    try {
      data = await _apiClient.withFailover((agencyId) => _apiClient.get(agencyId, '/extrato'));
    } on ApiException catch (error) {
      if (!error.isNetworkFailure) return Result.failure(error);
      return _cachedStatement(username, error);
    }

    final remote = Statement.fromJson(data);
    if (remote == null) {
      return const Result.failure(ApiException.unexpected());
    }

    final cached = {
      for (final account in await _offlineStore.readAccounts(username)) account.id: account,
    };
    final refreshed = await Future.wait(
      remote.accounts.map(
        (account) => _withLatestVector(account, fallbackVector: cached[account.id]?.vector),
      ),
    );

    final unavailable = remote.unavailableAgencies;
    await _offlineStore.replaceAccounts(
      username,
      refreshed,
      refreshedAgencies: AgencyEndpoints.ids.where((agencyId) => !unavailable.contains(agencyId)),
    );

    final stale = cached.values.where((account) => unavailable.contains(account.agencyId));
    return Result.ok(
      Statement(
        accounts: Statement.sortAccounts([...refreshed, ...stale]),
        unavailableAgencies: unavailable,
      ),
    );
  }

  Future<void> clearCache(String username) => _offlineStore.clearAccounts(username);

  Future<Result<Statement>> _cachedStatement(String username, ApiException error) async {
    final cached = await _offlineStore.readAccounts(username);
    if (cached.isEmpty) return Result.failure(error);

    return Result.ok(
      Statement(
        accounts: Statement.sortAccounts(cached),
        unavailableAgencies: AgencyEndpoints.ids,
        isOffline: true,
      ),
    );
  }

  Future<Account> _withLatestVector(Account account, {List<int>? fallbackVector}) async {
    try {
      final data = await _apiClient.get(
        _apiClient.agencyForAccount(account.id),
        '/contas/${account.id}',
      );
      final fresh = Account.fromJson({...data, 'agencia': account.agencyId});
      if (fresh == null) return account.copyWith(vector: fallbackVector);
      return fresh.vector == null ? fresh.copyWith(vector: fallbackVector) : fresh;
    } on ApiException {
      return account.copyWith(vector: fallbackVector);
    }
  }

  Future<Result<Account>> applyOperation({
    required String username,
    required OperationType type,
    required Account account,
    required double amount,
  }) async {
    final agencyId = _apiClient.agencyForAccount(account.id);

    try {
      final data = await _apiClient.post(
        agencyId,
        '/contas/${account.id}/${type.path}',
        body: {'valor': amount},
      );

      final newBalance = data['saldo'];
      if (newBalance is! num) {
        return const Result.failure(ApiException.unexpected());
      }

      final updated = await _withLatestVector(
        account.copyWith(balance: newBalance.toDouble(), fresh: true),
        fallbackVector: account.vector,
      );
      await _offlineStore.saveAccount(username, updated);
      return Result.ok(updated);
    } on ApiException catch (error) {
      if (!error.isNetworkFailure) return Result.failure(error);

      return Result.failure(
        ApiException(
          '${_describeAgency(agencyId, 'que guarda esta conta')} não respondeu. '
          'Tente de novo em instantes.',
        ),
      );
    }
  }

  Future<Result<String>> transfer({
    required Account source,
    required int targetAccountId,
    required double amount,
  }) async {
    final agencyId = _apiClient.agencyForAccount(source.id);

    try {
      final data = await _apiClient.post(
        agencyId,
        '/transferencias',
        body: {'idOrigem': source.id, 'idDestino': targetAccountId, 'valor': amount},
      );

      final message = data['mensagem'];
      return Result.ok(message is String ? message : 'Transferência concluída.');
    } on ApiException catch (error) {
      if (!error.isNetworkFailure) return Result.failure(error);

      return Result.failure(
        ApiException(
          '${_describeAgency(agencyId, 'que guarda a conta de origem')} não respondeu. '
          'Nada foi debitado. Tente de novo em instantes.',
        ),
      );
    }
  }

  Future<Result<Account>> createAccount({
    required int accountId,
    required String holderName,
    required String owner,
    required double initialBalance,
  }) async {
    final agencyId = _apiClient.agencyForAccount(accountId);

    try {
      final data = await _apiClient.post(
        agencyId,
        '/contas',
        body: {
          'id': accountId,
          'nomeAluno': holderName,
          'dono': owner,
          'saldoInicial': initialBalance,
        },
      );

      final account = Account.fromJson({...data, 'agencia': AgencyEndpoints.agencyFor(accountId)});
      if (account == null) {
        return const Result.failure(ApiException.unexpected());
      }
      return Result.ok(account);
    } on ApiException catch (error) {
      if (!error.isNetworkFailure) return Result.failure(error);

      return Result.failure(
        ApiException(
          '${_describeAgency(agencyId, 'que vai guardar a conta $accountId')} não respondeu. '
          'Tente de novo em instantes.',
        ),
      );
    }
  }

  String _describeAgency(int agencyId, String role) {
    if (_apiClient.isAgencyPinned) return 'A Agência $agencyId, fixada como destino das chamadas,';
    return 'A Agência $agencyId, $role,';
  }
}
