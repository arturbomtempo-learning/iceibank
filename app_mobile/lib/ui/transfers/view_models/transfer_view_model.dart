import 'package:flutter/foundation.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/utils/result.dart';

enum TransferStep { destination, amount, review }

class TransferReceipt {
  const TransferReceipt({
    required this.source,
    required this.targetAccountId,
    required this.amount,
    required this.message,
    required this.isInterAgency,
  });

  final Account source;
  final int targetAccountId;
  final double amount;
  final String message;
  final bool isInterAgency;

  double get remainingBalance => source.balance - amount;
}

class TransferViewModel extends ChangeNotifier {
  TransferViewModel({required List<Account> accounts, required this._accountRepository})
    : _accounts = List.of(accounts),
      _source = accounts.isEmpty ? null : accounts.first;

  static const int maxDigits = 9;

  final AccountRepository _accountRepository;
  final List<Account> _accounts;

  Account? _source;
  String _targetInput = '';
  int _amountInCents = 0;
  TransferStep _step = TransferStep.destination;
  bool _isSubmitting = false;
  String? _errorMessage;
  TransferReceipt? _receipt;

  List<Account> get accounts => List.unmodifiable(_accounts);
  Account? get source => _source;
  String get targetInput => _targetInput;
  int get amountInCents => _amountInCents;
  double get amount => _amountInCents / 100;
  TransferStep get step => _step;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  TransferReceipt? get receipt => _receipt;

  int? get targetAccountId => int.tryParse(_targetInput);

  Account? get knownTarget {
    final targetId = targetAccountId;
    return _accounts.where((account) => account.id == targetId).firstOrNull;
  }

  List<Account> get suggestedTargets {
    return _accounts.where((account) => account.id != _source?.id).toList();
  }

  int? get sourceAgency => _source == null ? null : AgencyEndpoints.agencyFor(_source!.id);

  int? get targetAgency {
    final targetId = targetAccountId;
    return targetId == null ? null : AgencyEndpoints.agencyFor(targetId);
  }

  bool get isInterAgency => sourceAgency != null && sourceAgency != targetAgency;

  String? get targetError {
    if (targetAccountId != null && targetAccountId == _source?.id) {
      return 'A conta de destino deve ser diferente da origem.';
    }
    return null;
  }

  bool get hasValidTarget => targetAccountId != null && targetError == null;

  double get resultingBalance => (_source?.balance ?? 0) - amount;

  bool get isOverdrawn => resultingBalance < 0;

  bool get canContinue {
    return switch (_step) {
      TransferStep.destination => _source != null && hasValidTarget,
      TransferStep.amount => _amountInCents > 0 && !isOverdrawn,
      TransferStep.review => !_isSubmitting,
    };
  }

  void selectSource(Account account) {
    if (_source?.id == account.id) return;
    _source = account;
    _errorMessage = null;
    notifyListeners();
  }

  void updateTarget(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits == _targetInput) return;
    _targetInput = digits;
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

  void next() {
    if (!canContinue || _step == TransferStep.review) return;
    _step = TransferStep.values[_step.index + 1];
    notifyListeners();
  }

  bool back() {
    if (_step == TransferStep.destination || _isSubmitting) return false;
    _step = TransferStep.values[_step.index - 1];
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  Future<bool> submit() async {
    final source = _source;
    final targetId = targetAccountId;
    if (source == null || targetId == null || _isSubmitting) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _accountRepository.transfer(
      source: source,
      targetAccountId: targetId,
      amount: amount,
    );

    _isSubmitting = false;
    switch (result) {
      case Ok(:final value):
        _receipt = TransferReceipt(
          source: source,
          targetAccountId: targetId,
          amount: amount,
          message: value,
          isInterAgency: isInterAgency,
        );
      case Failure(:final error):
        _errorMessage = error is ApiException
            ? error.message
            : const ApiException.unexpected().message;
    }
    notifyListeners();
    return _receipt != null;
  }
}
