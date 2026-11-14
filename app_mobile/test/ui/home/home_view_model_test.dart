import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/repositories/agency_repository.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/data/repositories/sync_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/session_storage.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/domain/models/pending_operation.dart';
import 'package:iceibank/ui/home/view_models/home_view_model.dart';

import '../../support/in_memory_offline_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<HomeViewModel> buildViewModel({
    required String username,
    required String role,
    List<PendingOperation> pending = const [],
  }) async {
    FlutterSecureStorage.setMockInitialValues({});
    late final AuthRepository authRepository;

    final apiClient = ApiClient(
      readToken: () => authRepository.token,
      onUnauthorized: () {},
      httpClient: MockClient((request) async {
        final body = request.url.path == '/auth/login'
            ? {'token': 'jwt', 'usuario': username, 'papel': role, 'expiraEmSegundos': 3600}
            : {
                'usuario': username,
                'contas': [
                  {
                    'id': 6,
                    'nomeAluno': 'artur bomtempo',
                    'dono': 'bomtempo',
                    'saldo': 2500,
                    'agencia': 0,
                  },
                  {
                    'id': 9,
                    'nomeAluno': 'Maria Souza',
                    'dono': 'maria',
                    'saldo': 100,
                    'agencia': 0,
                  },
                  {
                    'id': 7,
                    'nomeAluno': 'artur bomtempo',
                    'dono': 'bomtempo',
                    'saldo': 800,
                    'agencia': 1,
                  },
                ],
                'saldoTotal': 3400,
                'agenciasIndisponiveis': [2],
              };
        return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
      }),
    );

    authRepository = AuthRepository(apiClient: apiClient, sessionStorage: SessionStorage());
    await authRepository.signIn(username: username, password: 'senha');

    final store = InMemoryOfflineStore();
    for (final operation in pending) {
      await store.insertOperation(operation);
    }
    final syncRepository = SyncRepository(apiClient: apiClient, offlineStore: store);
    await syncRepository.attach(username);

    final viewModel = HomeViewModel(
      authRepository: authRepository,
      accountRepository: AccountRepository(apiClient: apiClient, offlineStore: store),
      agencyRepository: AgencyRepository(),
      syncRepository: syncRepository,
    );
    await viewModel.load();
    return viewModel;
  }

  test('usa o primeiro nome da conta da própria pessoa na saudação', () async {
    final viewModel = await buildViewModel(username: 'bomtempo', role: 'cliente');

    expect(viewModel.greetingName, 'Artur');
    expect(viewModel.initials, 'AB');
    expect(viewModel.isManager, isFalse);
    expect(viewModel.isBalanceVisible, isFalse);
  });

  test('resume contas, correntistas e agências para o gerente', () async {
    final viewModel = await buildViewModel(username: 'admin', role: 'admin');

    expect(viewModel.isManager, isTrue);
    expect(viewModel.greetingName, 'Admin');
    expect(viewModel.holderCount, 2);
    expect(viewModel.availableAgencyCount, 2);

    final summaries = viewModel.agencySummaries;
    expect(summaries.map((summary) => summary.accountCount), [2, 1, 0]);
    expect(summaries.first.balance, 2600);
    expect(summaries.last.isAvailable, isFalse);
  });

  test('soma as operações pendentes ao saldo exibido, de forma otimista', () async {
    final viewModel = await buildViewModel(
      username: 'bomtempo',
      role: 'cliente',
      pending: [
        PendingOperation(
          username: 'bomtempo',
          accountId: 6,
          agencyId: 0,
          type: OperationType.deposit,
          amountInCents: 5000,
          knownVector: const [3, 1, 1],
          createdAt: DateTime(2026, 11, 14),
        ),
        PendingOperation(
          username: 'bomtempo',
          accountId: 7,
          agencyId: 1,
          type: OperationType.withdraw,
          amountInCents: 30000,
          knownVector: const [1, 4, 1],
          createdAt: DateTime(2026, 11, 14),
          status: PendingStatus.conflict,
          serverBalance: 800,
        ),
      ],
    );

    final balances = {for (final account in viewModel.accounts) account.id: account.balance};
    expect(balances[6], 2550);
    expect(balances[7], 800);
    expect(viewModel.accountsWithPending, {6});
    expect(viewModel.waitingCount, 1);
    expect(viewModel.pendingOperations, hasLength(2));
  });

  test('alterna a visibilidade do saldo', () async {
    final viewModel = await buildViewModel(username: 'bomtempo', role: 'cliente');

    viewModel.toggleBalanceVisibility();

    expect(viewModel.isBalanceVisible, isTrue);
  });
}
