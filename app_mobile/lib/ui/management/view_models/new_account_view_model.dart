import 'package:flutter/foundation.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/utils/result.dart';

class NewAccountViewModel extends ChangeNotifier {
  NewAccountViewModel({required this._accountRepository, String initialOwner = ''})
    : _owner = initialOwner;

  final AccountRepository _accountRepository;

  String _accountNumber = '';
  String _holderName = '';
  String _owner;
  int _initialBalanceInCents = 0;

  bool _isSubmitting = false;
  String? _accountError;
  String? _holderError;
  String? _ownerError;
  String? _formError;
  Account? _createdAccount;

  String get owner => _owner;
  bool get isSubmitting => _isSubmitting;
  String? get accountError => _accountError;
  String? get holderError => _holderError;
  String? get ownerError => _ownerError;
  String? get formError => _formError;
  Account? get createdAccount => _createdAccount;

  int? get accountId => int.tryParse(_accountNumber);

  int? get agencyId {
    final id = accountId;
    return id == null ? null : AgencyEndpoints.agencyFor(id);
  }

  Account get preview {
    return Account(
      id: accountId ?? 0,
      holderName: _holderName.trim().isEmpty ? 'Nome do titular' : _holderName.trim(),
      owner: _owner.trim().isEmpty ? 'usuario' : _owner.trim(),
      balance: _initialBalanceInCents / 100,
      agencyId: agencyId ?? 0,
    );
  }

  void updateAccountNumber(String value) {
    _accountNumber = value;
    _accountError = null;
    _formError = null;
    notifyListeners();
  }

  void updateHolderName(String value) {
    _holderName = value;
    _holderError = null;
    _formError = null;
    notifyListeners();
  }

  void updateOwner(String value) {
    _owner = value;
    _ownerError = null;
    _formError = null;
    notifyListeners();
  }

  void updateInitialBalance(int cents) {
    _initialBalanceInCents = cents;
    _formError = null;
    notifyListeners();
  }

  Future<void> submit() async {
    if (_isSubmitting) return;

    final id = accountId;
    final holderName = _holderName.trim();
    final owner = _owner.trim();

    _accountError = id == null ? 'Informe o número da conta.' : null;
    _holderError = holderName.isEmpty ? 'Informe o nome do titular.' : null;
    _ownerError = owner.isEmpty ? 'Informe o usuário dono da conta.' : null;
    _formError = null;

    if (_accountError != null || _holderError != null || _ownerError != null || id == null) {
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    final result = await _accountRepository.createAccount(
      accountId: id,
      holderName: holderName,
      owner: owner,
      initialBalance: _initialBalanceInCents / 100,
    );

    _isSubmitting = false;
    switch (result) {
      case Ok(:final value):
        _createdAccount = value;
      case Failure(:final error):
        _assignError(error);
    }
    notifyListeners();
  }

  void _assignError(Exception error) {
    final message = error is ApiException ? error.message : const ApiException.unexpected().message;

    if (error is ApiException && error.statusCode == 409) {
      _accountError = message;
    } else if (message.contains("'dono'")) {
      _ownerError = 'Esse usuário não existe. Cadastre o correntista antes de abrir a conta.';
    } else {
      _formError = message;
    }
  }
}
