import 'package:flutter/foundation.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/repositories/agency_repository.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/account.dart';
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
  });

  final AuthRepository _authRepository;
  final AccountRepository _accountRepository;
  final AgencyRepository _agencyRepository;

  Statement? _statement;
  bool _isLoading = false;
  bool _isBalanceVisible = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isBalanceVisible => _isBalanceVisible;
  String? get errorMessage => _errorMessage;
  bool get hasLoaded => _statement != null;

  bool get isManager => _authRepository.session?.isManager ?? false;
  String get username => _authRepository.session?.username ?? '';

  List<Account> get accounts => _statement?.accounts ?? const [];
  double get totalBalance => _statement?.totalBalance ?? 0;
  int get holderCount => _statement?.holderCount ?? 0;
  List<int> get unavailableAgencies => _statement?.unavailableAgencies ?? const [];

  int? get pinnedAgencyId => _agencyRepository.pinnedAgencyId;

  int get availableAgencyCount => AgencyEndpoints.count - unavailableAgencies.length;

  String get greetingName {
    final ownAccount = accounts.where((account) => account.owner == username).firstOrNull;
    final fullName = ownAccount?.holderName ?? username;
    final firstName = fullName.trim().split(RegExp(r'\s+')).first;
    if (firstName.isEmpty) return firstName;
    return '${firstName[0].toUpperCase()}${firstName.substring(1)}';
  }

  String get initials {
    final ownAccount = accounts.where((account) => account.owner == username).firstOrNull;
    final words = (ownAccount?.holderName ?? username).trim().split(RegExp(r'\s+'));
    final letters = words.length > 1 ? '${words.first[0]}${words.last[0]}' : words.first;
    return letters.substring(0, letters.length.clamp(0, 2)).toUpperCase();
  }

  List<AgencySummary> get agencySummaries {
    return [
      for (final agencyId in AgencyEndpoints.ids)
        AgencySummary(
          agencyId: agencyId,
          accountCount: accounts.where((account) => account.agencyId == agencyId).length,
          balance: accounts
              .where((account) => account.agencyId == agencyId)
              .fold(0, (sum, account) => sum + account.balance),
          isAvailable: !unavailableAgencies.contains(agencyId),
        ),
    ];
  }

  Future<void> load() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    final result = await _accountRepository.fetchStatement();

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
  }

  Future<void> selectAgency(int? agencyId) async {
    if (agencyId == pinnedAgencyId) return;

    await _agencyRepository.select(agencyId);
    notifyListeners();
    await load();
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  Future<void> signOut() => _authRepository.signOut();
}
