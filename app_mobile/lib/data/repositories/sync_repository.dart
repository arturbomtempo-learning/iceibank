import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/data/services/offline_store.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/domain/models/pending_operation.dart';
import 'package:iceibank/utils/result.dart';

class SyncReport {
  const SyncReport({
    required this.appliedCount,
    required this.conflictCount,
    required this.rejectedCount,
    required this.finishedAt,
  });

  final int appliedCount;
  final int conflictCount;
  final int rejectedCount;
  final DateTime finishedAt;

  bool get changedBalances => appliedCount > 0 || conflictCount > 0;
}

class SyncRepository extends ChangeNotifier {
  SyncRepository({
    required this._apiClient,
    required this._offlineStore,
    this.retryInterval = const Duration(seconds: 4),
  });

  final ApiClient _apiClient;
  final OfflineStore _offlineStore;
  final Duration retryInterval;

  String? _username;
  List<PendingOperation> _operations = const [];
  SyncReport? _lastReport;
  Timer? _timer;
  bool _isRunning = false;
  bool _isSyncing = false;

  List<PendingOperation> get operations => _operations;
  SyncReport? get lastReport => _lastReport;
  bool get isSyncing => _isSyncing;

  double pendingEffectFor(int accountId) {
    return _operations
        .where((operation) => operation.isWaiting && operation.accountId == accountId)
        .fold(0, (sum, operation) => sum + operation.balanceEffect);
  }

  bool hasWaitingFor(int agencyId) {
    return _operations.any((operation) => operation.isWaiting && operation.agencyId == agencyId);
  }

  Future<void> attach(String username) async {
    if (_username == username) return;
    _username = username;
    _operations = await _offlineStore.readOperations(username);
    notifyListeners();
  }

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(retryInterval, (_) => unawaited(synchronize()));
    unawaited(synchronize());
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<Result<PendingOperation>> enqueue({
    required Account account,
    required OperationType type,
    required int amountInCents,
  }) async {
    final username = _username;
    final knownVector = account.vector;
    if (username == null || knownVector == null) {
      return Result.failure(
        ApiException(
          'A Agência ${account.agencyId} está fora do ar e o app ainda não tem dados '
          'desta conta para guardar a operação. Tente quando a agência voltar.',
        ),
      );
    }

    final operation = await _offlineStore.insertOperation(
      PendingOperation(
        username: username,
        accountId: account.id,
        agencyId: account.agencyId,
        type: type,
        amountInCents: amountInCents,
        knownVector: knownVector,
        createdAt: DateTime.now(),
      ),
    );

    _operations = [..._operations, operation];
    notifyListeners();
    return Result.ok(operation);
  }

  Future<void> synchronize() async {
    final username = _username;
    if (_isSyncing || username == null) return;
    if (!_operations.any((operation) => operation.isWaiting)) return;

    _isSyncing = true;
    notifyListeners();

    final unreachableAgencies = <int>{};
    var applied = 0;
    var conflicts = 0;
    var rejected = 0;

    for (final queued in List.of(_operations)) {
      final operation = _current(queued.id);
      if (operation == null || !operation.isWaiting) continue;
      if (unreachableAgencies.contains(operation.agencyId)) continue;

      switch (await _send(operation)) {
        case _Applied(:final account):
          applied++;
          await _onApplied(username, operation, account);
        case _Conflict(:final account):
          conflicts++;
          await _replace(
            operation.copyWith(
              status: PendingStatus.conflict,
              serverBalance: account.balance,
              serverVector: account.vector,
            ),
          );
          await _offlineStore.saveAccount(username, account);
        case _Rejected(:final message):
          rejected++;
          await _replace(operation.copyWith(status: PendingStatus.rejected, message: message));
        case _Unreachable():
          unreachableAgencies.add(operation.agencyId);
        case _SessionEnded():
          _isSyncing = false;
          notifyListeners();
          return;
      }
    }

    _isSyncing = false;
    if (applied + conflicts + rejected > 0) {
      _lastReport = SyncReport(
        appliedCount: applied,
        conflictCount: conflicts,
        rejectedCount: rejected,
        finishedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<void> retryWithLatestState(PendingOperation operation) async {
    final serverVector = operation.serverVector;
    if (operation.status != PendingStatus.conflict || serverVector == null) return;

    await _replace(
      operation.copyWith(
        status: PendingStatus.waiting,
        knownVector: serverVector,
        clearResolution: true,
      ),
    );
    notifyListeners();
    await synchronize();
  }

  Future<void> discard(PendingOperation operation) async {
    final id = operation.id;
    if (id == null) return;

    await _offlineStore.deleteOperation(id);
    _operations = _operations.where((candidate) => candidate.id != id).toList();
    notifyListeners();
  }

  PendingOperation? _current(int? id) {
    return _operations.where((operation) => operation.id == id).firstOrNull;
  }

  Future<void> _replace(PendingOperation operation) async {
    await _offlineStore.updateOperation(operation);
    _operations = [
      for (final candidate in _operations)
        if (candidate.id == operation.id) operation else candidate,
    ];
  }

  Future<void> _onApplied(String username, PendingOperation operation, Account account) async {
    final id = operation.id;
    if (id != null) await _offlineStore.deleteOperation(id);

    final usedVector = operation.knownVector;
    final nextVector = List<int>.unmodifiable([
      for (var index = 0; index < usedVector.length; index++)
        index == operation.agencyId ? usedVector[index] + 1 : usedVector[index],
    ]);

    final remaining = <PendingOperation>[];
    for (final candidate in _operations) {
      if (candidate.id == id) continue;
      if (candidate.isWaiting &&
          candidate.agencyId == operation.agencyId &&
          listEquals(candidate.knownVector, usedVector)) {
        final chained = candidate.copyWith(knownVector: nextVector);
        await _offlineStore.updateOperation(chained);
        remaining.add(chained);
      } else {
        remaining.add(candidate);
      }
    }
    _operations = remaining;

    await _offlineStore.saveAccount(username, account.copyWith(vector: nextVector));
  }

  Future<_SyncOutcome> _send(PendingOperation operation) async {
    try {
      final data = await _apiClient.post(
        _apiClient.agencyForAccount(operation.accountId),
        '/contas/${operation.accountId}/sincronizar',
        body: {
          'tipo': operation.type.syncType,
          'valor': operation.amount,
          'vetorConhecido': operation.knownVector,
        },
      );

      final account = Account.fromJson({...data, 'agencia': operation.agencyId});
      if (account == null) return _Rejected(const ApiException.unexpected().message);
      return _Applied(account);
    } on ApiException catch (error) {
      if (error.isNetworkFailure) return const _Unreachable();
      if (error.isUnauthorized) return const _SessionEnded();
      if (error.statusCode == 409) {
        final account = _conflictAccount(error.body, operation.agencyId);
        if (account != null) return _Conflict(account);
      }
      return _Rejected(error.message);
    }
  }

  Account? _conflictAccount(JsonMap? body, int agencyId) {
    final current = body?['contaAtual'];
    if (current is! JsonMap) return null;
    return Account.fromJson({...current, 'agencia': agencyId, 'vetorAtual': body?['vetorAtual']});
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

sealed class _SyncOutcome {
  const _SyncOutcome();
}

class _Applied extends _SyncOutcome {
  const _Applied(this.account);

  final Account account;
}

class _Conflict extends _SyncOutcome {
  const _Conflict(this.account);

  final Account account;
}

class _Rejected extends _SyncOutcome {
  const _Rejected(this.message);

  final String message;
}

class _Unreachable extends _SyncOutcome {
  const _Unreachable();
}

class _SessionEnded extends _SyncOutcome {
  const _SessionEnded();
}
