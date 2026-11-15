import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/repositories/agency_repository.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/data/repositories/sync_repository.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/pending_operation.dart';
import 'package:iceibank/domain/models/statement.dart';
import 'package:iceibank/utils/result.dart';

class AgencySummary {
  const AgencySummary({
    required this.agencyId,
    required this.accountCount,
    required this.balance,
    required this.isAvailable,
  });

  final int agencyId;
  final int accountCount;
  final double balance;
  final bool isAvailable;
}

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._authRepository,
    required this._accountRepository,
    required this._agencyRepository,
    required this._syncRepository,
  }) {
    _syncRepository.addListener(_onSyncChanged);
  }

  final AuthRepository _authRepository;
  final AccountRepository _accountRepository;
  final AgencyRepository _agencyRepository;
  final SyncRepository _syncRepository;

  Statement? _statement;
  bool _isLoading = false;
  bool _isReloadQueued = false;
  bool _isBalanceVisible = false;
  String? _errorMessage;
  SyncReport? _handledReport;

  bool get isLoading => _isLoading;
  bool get isBalanceVisible => _isBalanceVisible;
  String? get errorMessage => _errorMessage;
  bool get hasLoaded => _statement != null;

  bool get isManager => _authRepository.session?.isManager ?? false;
  String get username => _authRepository.session?.username ?? '';

  bool get isOffline => _statement?.isOffline ?? false;
  DateTime? get cachedAt => _statement?.cachedAt;
  bool get hasStaleAccounts => _statement?.hasStaleAccounts ?? false;
  List<int> get unavailableAgencies => _statement?.unavailableAgencies ?? const [];

  List<PendingOperation> get pendingOperations => _syncRepository.operations;
  int get waitingCount => pendingOperations.where((operation) => operation.isWaiting).length;
  bool get isSyncing => _syncRepository.isSyncing;
  SyncReport? get lastSyncReport => _syncRepository.lastReport;

  Set<int> get accountsWithPending => {
    for (final operation in pendingOperations)
      if (operation.isWaiting) operation.accountId,
  };

  List<Account> get accounts {
    final base = _statement?.accounts ?? const <Account>[];
    final pending = accountsWithPending;
    if (pending.isEmpty) return base;

    return [
      for (final account in base)
        pending.contains(account.id)
            ? account.copyWith(
                balance: account.balance + _syncRepository.pendingEffectFor(account.id),
              )
            : account,
    ];
  }

  double get totalBalance => accounts.fold(0, (sum, account) => sum + account.balance);
  int get holderCount => accounts.map((account) => account.owner).toSet().length;
  int? get pinnedAgencyId => _agencyRepository.pinnedAgencyId;
  int get availableAgencyCount => AgencyEndpoints.count - unavailableAgencies.length;

  String get greetingName {
    final ownAccount = accounts.where((account) => account.owner == username).firstOrNull;
    final fullName = ownAccount?.holderName ?? username;
    final firstName = fullName.trim().split(RegExp(r'\s+')).first;
    if (firstName.isEmpty) return firstName;
    return '${firstName[0].toUpperCase()}${firstName.substring(1)}';
  }

  String get displayName {
    final ownAccount = accounts.where((account) => account.owner == username).firstOrNull;
    return ownAccount?.holderName ?? username;
  }

  String get roleLabel => isManager ? 'Gerente' : 'Correntista';

  String get initials {
    final ownAccount = accounts.where((account) => account.owner == username).firstOrNull;
    final words = (ownAccount?.holderName ?? username).trim().split(RegExp(r'\s+'));
    final letters = words.length > 1 ? '${words.first[0]}${words.last[0]}' : words.first;
    return letters.substring(0, letters.length.clamp(0, 2)).toUpperCase();
  }

  List<AgencySummary> get agencySummaries {
    final current = accounts;
    return [
      for (final agencyId in AgencyEndpoints.ids)
        AgencySummary(
          agencyId: agencyId,
          accountCount: current.where((account) => account.agencyId == agencyId).length,
          balance: current
              .where((account) => account.agencyId == agencyId)
              .fold(0, (sum, account) => sum + account.balance),
          isAvailable: !unavailableAgencies.contains(agencyId),
        ),
    ];
  }

  Future<void> start() async {
    if (username.isEmpty) return;
    await _syncRepository.attach(username);
    _syncRepository.start();
    await load();
  }

  void resumeSync() => _syncRepository.start();

  void pauseSync() => _syncRepository.stop();

  Future<void> load() async {
    if (_isLoading) {
      _isReloadQueued = true;
      return;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _accountRepository.fetchStatement(username: username);

    _isLoading = false;
    switch (result) {
      case Ok(:final value):
        _statement = value;
        _errorMessage = null;
      case Failure(:final error):
        _errorMessage = error is ApiException
            ? error.message
            : const ApiException.unexpected().message;
    }
    notifyListeners();

    if (_isReloadQueued) {
      _isReloadQueued = false;
      await load();
    }
  }

  Future<void> selectAgency(int? agencyId) async {
    if (agencyId == pinnedAgencyId) return;

    await _agencyRepository.select(agencyId);
    notifyListeners();
    await load();
  }

  Future<void> retryOperation(PendingOperation operation) {
    return _syncRepository.retryWithLatestState(operation);
  }

  Future<void> discardOperation(PendingOperation operation) {
    return _syncRepository.discard(operation);
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  Future<void> signOut() async {
    _syncRepository.stop();
    await _accountRepository.clearCache(username);
    await _authRepository.signOut();
  }

  void _onSyncChanged() {
    final report = _syncRepository.lastReport;
    if (report != null && !identical(report, _handledReport)) {
      _handledReport = report;
      if (report.changedBalances) unawaited(load());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _syncRepository
      ..removeListener(_onSyncChanged)
      ..stop();
    super.dispose();
  }
}
