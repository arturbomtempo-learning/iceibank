import 'dart:async';

import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/repositories/agency_repository.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/data/repositories/leadership_repository.dart';
import 'package:iceibank/data/repositories/user_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/session_storage.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.accountRepository,
    required this.userRepository,
    required this.agencyRepository,
    required this.leadershipRepository,
  });

  final AuthRepository authRepository;
  final AccountRepository accountRepository;
  final UserRepository userRepository;
  final AgencyRepository agencyRepository;
  final LeadershipRepository leadershipRepository;

  static Future<AppDependencies> create() async {
    final sessionStorage = SessionStorage();
    await sessionStorage.clearIfFreshInstall();

    final agencyRepository = AgencyRepository();
    await agencyRepository.restore();

    late final AuthRepository authRepository;

    final apiClient = ApiClient(
      readToken: () => authRepository.token,
      onUnauthorized: () => unawaited(authRepository.expireSession()),
      pinnedAgency: () => agencyRepository.pinnedAgencyId,
    );

    authRepository = AuthRepository(apiClient: apiClient, sessionStorage: sessionStorage);
    await authRepository.restore();

    return AppDependencies(
      authRepository: authRepository,
      accountRepository: AccountRepository(apiClient: apiClient),
      userRepository: UserRepository(apiClient: apiClient),
      agencyRepository: agencyRepository,
      leadershipRepository: LeadershipRepository(apiClient: apiClient),
    );
  }
}
