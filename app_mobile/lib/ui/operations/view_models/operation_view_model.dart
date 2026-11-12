import 'package:flutter/foundation.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/utils/result.dart';

class OperationReceipt {
  const OperationReceipt({required this.account, required this.amount, required this.newBalance});

  final Account account;
  final double amount;
  final double newBalance;
}

class OperationViewModel extends ChangeNotifier {
  OperationViewModel({
    required this.type,
    required List<Account> accounts,
    required this._accountRepository,
  }) : _accounts = List.of(accounts),
       _selectedAccount = accounts.isEmpty ? null : accounts.first;

  static const int maxDigits = 9;

  final OperationType type;
  final AccountRepository _accountRepository;
  final List<Account> _accounts;

  Account? _selectedAccount;
  int _amountInCents = 0;
  bool _isSubmitting = false;
  String? _errorMessage;
  OperationReceipt? _receipt;

  List<Account> get accounts => List.unmodifiable(_accounts);
  Account? get selectedAccount => _selectedAccount;
  int get amountInCents => _amountInCents;
  double get amount => _amountInCents / 100;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  OperationReceipt? get receipt => _receipt;

  double? get resultingBalance {
    final account = _selectedAccount;
    if (account == null) return null;
    return type.apply(account.balance, amount);
  }

  bool get isOverdrawn => (resultingBalance ?? 0) < 0;

  bool get canSubmit {
    return _selectedAccount != null && _amountInCents > 0 && !isOverdrawn && !_isSubmitting;
  }

  void selectAccount(Account account) {
    if (_selectedAccount?.id == account.id) return;
    _selectedAccount = account;
    _errorMessage = null;
    notifyListeners();
  }

  bool appendDigit(int digit) {
    final next = _amountInCents * 10 + digit;
    if (next.toString().length > maxDigits) return false;

    _setAmount(next);
    return true;
  }

  void removeDigit() => _setAmount(_amountInCents ~/ 10);

  void clearAmount() => _setAmount(0);

  void setAmount(double value) => _setAmount((value * 100).round());

  void _setAmount(int cents) {
    if (cents == _amountInCents) return;
    _amountInCents = cents;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> submit() async {
    final account = _selectedAccount;
    if (account == null || !canSubmit) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _accountRepository.applyOperation(
      type: type,
      account: account,
      amount: amount,
    );

    _isSubmitting = false;
    switch (result) {
      case Ok(:final value):
        _receipt = OperationReceipt(account: account, amount: amount, newBalance: value);
        _replaceAccount(account, value);
      case Failure(:final error):
        _errorMessage = error is ApiException
            ? error.message
            : const ApiException.unexpected().message;
    }
    notifyListeners();
    return _receipt != null;
  }

  void startAnother() {
    _receipt = null;
    _amountInCents = 0;
    notifyListeners();
  }

  void _replaceAccount(Account account, double newBalance) {
    final updated = account.copyWith(balance: newBalance);
    final index = _accounts.indexWhere((candidate) => candidate.id == account.id);
    if (index >= 0) _accounts[index] = updated;
    _selectedAccount = updated;
  }
}
