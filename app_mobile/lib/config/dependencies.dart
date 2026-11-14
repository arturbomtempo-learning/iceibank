import 'dart:async';

import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/repositories/agency_repository.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/data/repositories/leadership_repository.dart';
import 'package:iceibank/data/repositories/sync_repository.dart';
import 'package:iceibank/data/repositories/user_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/session_storage.dart';
import 'package:iceibank/data/services/sqlite_offline_store.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.accountRepository,
    required this.userRepository,
    required this.agencyRepository,
    required this.leadershipRepository,
    required this.syncRepository,
  });

  final AuthRepository authRepository;
  final AccountRepository accountRepository;
  final UserRepository userRepository;
  final AgencyRepository agencyRepository;
  final LeadershipRepository leadershipRepository;
  final SyncRepository syncRepository;

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

    final offlineStore = SqliteOfflineStore();

    return AppDependencies(
      authRepository: authRepository,
      accountRepository: AccountRepository(apiClient: apiClient, offlineStore: offlineStore),
      userRepository: UserRepository(apiClient: apiClient),
      agencyRepository: agencyRepository,
      leadershipRepository: LeadershipRepository(apiClient: apiClient),
      syncRepository: SyncRepository(apiClient: apiClient, offlineStore: offlineStore),
    );
  }
}
