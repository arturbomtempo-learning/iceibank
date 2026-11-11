import 'dart:async';

import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/session_storage.dart';

class AppDependencies {
  const AppDependencies._({required this.authRepository});

  final AuthRepository authRepository;

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

    return AppDependencies._(authRepository: authRepository);
  }
}
