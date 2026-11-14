import 'package:flutter/foundation.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/utils/result.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required this._authRepository}) {
    if (_authRepository.wasSessionExpired) {
      _sessionNotice = 'Sua sessão expirou por segurança. Entre de novo para continuar.';
    }
  }

  final AuthRepository _authRepository;

  bool _isSubmitting = false;
  String? _usernameError;
  String? _passwordError;
  String? _formError;
  String? _sessionNotice;

  bool get isSubmitting => _isSubmitting;
  String? get usernameError => _usernameError;
  String? get passwordError => _passwordError;
  String? get formError => _formError;
  String? get sessionNotice => _sessionNotice;

  Future<void> submit({required String username, required String password}) async {
    if (_isSubmitting) return;

    final trimmedUsername = username.trim();
    _usernameError = trimmedUsername.isEmpty ? 'Informe o usuário.' : null;
    _passwordError = password.isEmpty ? 'Informe a senha.' : null;
    _formError = null;
    _sessionNotice = null;

    if (_usernameError != null || _passwordError != null) {
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    final result = await _authRepository.signIn(username: trimmedUsername, password: password);

    _isSubmitting = false;
    if (result case Failure(:final error)) {
      _formError = error is ApiException ? error.message : const ApiException.unexpected().message;
    }
    notifyListeners();
  }

  void clearUsernameError() => _clearError(() => _usernameError = null, _usernameError);

  void clearPasswordError() => _clearError(() => _passwordError = null, _passwordError);

  void _clearError(VoidCallback clear, String? current) {
    if (current == null && _formError == null) return;
    clear();
    _formError = null;
    notifyListeners();
  }
}
