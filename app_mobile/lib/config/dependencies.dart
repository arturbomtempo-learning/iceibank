import 'dart:async';

import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/data/repositories/user_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/session_storage.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.accountRepository,
    required this.userRepository,
  });

  final AuthRepository authRepository;
  final AccountRepository accountRepository;
  final UserRepository userRepository;

  static Future<AppDependencies> create() async {
    final sessionStorage = SessionStorage();
    await sessionStorage.clearIfFreshInstall();

    late final AuthRepository authRepository;

    final apiClient = ApiClient(
      readToken: () => authRepository.token,
      onUnauthorized: () => unawaited(authRepository.signOut()),
    );

    authRepository = AuthRepository(apiClient: apiClient, sessionStorage: sessionStorage);
    await authRepository.restore();

    return AppDependencies(
      authRepository: authRepository,
      accountRepository: AccountRepository(apiClient: apiClient),
      userRepository: UserRepository(apiClient: apiClient),
    );
  }
}
