import 'package:flutter/foundation.dart';
import 'package:iceibank/data/repositories/user_repository.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/utils/result.dart';

class NewCustomerViewModel extends ChangeNotifier {
  NewCustomerViewModel({required this._userRepository});

  static final RegExp _usernamePattern = RegExp(r'^[a-z0-9._-]+$');

  final UserRepository _userRepository;

  bool _isSubmitting = false;
  String? _usernameError;
  String? _passwordError;
  String? _formError;
  String? _createdUsername;

  bool get isSubmitting => _isSubmitting;
  String? get usernameError => _usernameError;
  String? get passwordError => _passwordError;
  String? get formError => _formError;
  String? get createdUsername => _createdUsername;

  static String? validateUsername(String username) {
    if (username.length < 3) return 'O usuário deve ter pelo menos 3 caracteres.';
    if (!_usernamePattern.hasMatch(username)) {
      return 'Use apenas letras minúsculas, números, ponto, hífen ou sublinhado.';
    }
    return null;
  }

  static String? validatePassword(String password) {
    return password.length < 6 ? 'A senha deve ter pelo menos 6 caracteres.' : null;
  }

  Future<void> submit({required String username, required String password}) async {
    if (_isSubmitting) return;

    final trimmedUsername = username.trim();
    _usernameError = validateUsername(trimmedUsername);
    _passwordError = validatePassword(password);
    _formError = null;

    if (_usernameError != null || _passwordError != null) {
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    final result = await _userRepository.createCustomer(
      username: trimmedUsername,
      password: password,
    );

    _isSubmitting = false;
    switch (result) {
      case Ok(:final value):
        _createdUsername = value;
      case Failure(:final error):
        final message = error is ApiException
            ? error.message
            : const ApiException.unexpected().message;
        if (error is ApiException && error.statusCode == 409) {
          _usernameError = message;
        } else {
          _formError = message;
        }
    }
    notifyListeners();
  }

  void clearUsernameError() => _clear(() => _usernameError = null, _usernameError);

  void clearPasswordError() => _clear(() => _passwordError = null, _passwordError);

  void _clear(VoidCallback clear, String? current) {
    if (current == null && _formError == null) return;
    clear();
    _formError = null;
    notifyListeners();
  }
}
