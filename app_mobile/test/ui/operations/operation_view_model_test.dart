import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/repositories/sync_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/domain/models/pending_operation.dart';
import 'package:iceibank/ui/operations/view_models/operation_view_model.dart';

import '../../support/in_memory_offline_store.dart';

void main() {
  const account = Account(
    id: 7,
    holderName: 'Artur Bomtempo',
    owner: 'bomtempo',
    balance: 100,
    agencyId: 1,
    vector: [2, 5, 1],
  );

  late List<http.Request> requests;
  late InMemoryOfflineStore store;

  Future<OperationViewModel> buildViewModel(
    OperationType type,
    Future<http.Response> Function(http.Request request) handler, {
    Account selected = account,
    List<PendingOperation> pending = const [],
  }) async {
    requests = [];
    store = InMemoryOfflineStore();
    for (final operation in pending) {
      await store.insertOperation(operation);
    }
    final apiClient = ApiClient(
      readToken: () => 'jwt',
      onUnauthorized: () {},
      httpClient: MockClient((request) {
        requests.add(request);
        return handler(request);
      }),
    );

    final syncRepository = SyncRepository(apiClient: apiClient, offlineStore: store);
    await syncRepository.attach('bomtempo');

    return OperationViewModel(
      type: type,
      username: 'bomtempo',
      accounts: [selected],
      accountRepository: AccountRepository(apiClient: apiClient, offlineStore: store),
      syncRepository: syncRepository,
    );
  }

  http.Response json(Object body, int status) {
    return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
  }

  test('monta o valor em centavos a partir dos dígitos do teclado', () async {
    final viewModel = await buildViewModel(OperationType.deposit, (_) async => json({}, 200));

    for (final digit in [2, 5, 0, 0]) {
      viewModel.appendDigit(digit);
    }
    expect(viewModel.amount, 25);

    viewModel.removeDigit();
    expect(viewModel.amount, 2.5);

    viewModel.clearAmount();
    expect(viewModel.amountInCents, 0);
    expect(viewModel.canSubmit, isFalse);
  });

  test('recusa dígitos além do limite', () async {
    final viewModel = await buildViewModel(OperationType.deposit, (_) async => json({}, 200));

    for (var index = 0; index < OperationViewModel.maxDigits; index++) {
      expect(viewModel.appendDigit(9), isTrue);
    }

    expect(viewModel.appendDigit(9), isFalse);
    expect(viewModel.amountInCents, 999999999);
  });

  test('bloqueia um saque maior que o saldo', () async {
    final viewModel = await buildViewModel(OperationType.withdraw, (_) async => json({}, 200));

    viewModel.setAmount(150);

    expect(viewModel.isOverdrawn, isTrue);
    expect(viewModel.resultingBalance, -50);
    expect(viewModel.canSubmit, isFalse);
  });

  test('deposita na agência dona da conta e guarda o novo saldo', () async {
    final viewModel = await buildViewModel(
      OperationType.deposit,
      (_) async => json({'id': 7, 'nomeAluno': 'Artur', 'dono': 'bomtempo', 'saldo': 125.5}, 200),
    );

    viewModel.setAmount(25.5);
    final succeeded = await viewModel.submit();

    expect(succeeded, isTrue);
    expect(requests.first.url.port, 4036);
    expect(requests.first.url.path, '/contas/7/depositar');
    expect(jsonDecode(requests.first.body), {'valor': 25.5});
    expect(requests.last.method, 'GET');
    expect(viewModel.receipt!.newBalance, 125.5);
    expect(viewModel.receipt!.isPending, isFalse);
    expect(viewModel.selectedAccount!.balance, 125.5);
  });

  test('mostra a mensagem da API quando o saque é recusado', () async {
    final viewModel = await buildViewModel(
      OperationType.withdraw,
      (_) async => json({'erro': 'Saldo insuficiente.'}, 400),
    );

    viewModel.setAmount(40);
    final succeeded = await viewModel.submit();

    expect(succeeded, isFalse);
    expect(requests.single.url.path, '/contas/7/sacar');
    expect(viewModel.errorMessage, 'Saldo insuficiente.');
    expect(viewModel.receipt, isNull);
  });

  test(
    'guarda a operação na fila, com o vetor conhecido, quando a agência está fora do ar',
    () async {
      final viewModel = await buildViewModel(
        OperationType.deposit,
        (_) async => throw http.ClientException('Connection refused'),
      );

      viewModel.setAmount(10);
      final succeeded = await viewModel.submit();
      final queued = await store.readOperations('bomtempo');

      expect(succeeded, isTrue);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.receipt!.isPending, isTrue);
      expect(viewModel.receipt!.newBalance, 110);
      expect(queued.single.amountInCents, 1000);
      expect(queued.single.knownVector, [2, 5, 1]);
      expect(queued.single.status, PendingStatus.waiting);
    },
  );

  test('não guarda a operação quando ainda não conhece o vetor da conta', () async {
    final viewModel = await buildViewModel(
      OperationType.deposit,
      (_) async => throw http.ClientException('Connection refused'),
      selected: const Account(
        id: 7,
        holderName: 'Artur Bomtempo',
        owner: 'bomtempo',
        balance: 100,
        agencyId: 1,
      ),
    );

    viewModel.setAmount(10);
    final succeeded = await viewModel.submit();

    expect(succeeded, isFalse);
    expect(viewModel.errorMessage, contains('Agência 1'));
    expect(await store.readOperations('bomtempo'), isEmpty);
  });

  test('envia as pendências da agência antes de uma nova operação, preservando a ordem', () async {
    final viewModel = await buildViewModel(
      OperationType.deposit,
      (request) async =>
          json({'id': 7, 'nomeAluno': 'Artur', 'dono': 'bomtempo', 'saldo': 160}, 200),
      pending: [
        PendingOperation(
          username: 'bomtempo',
          accountId: 7,
          agencyId: 1,
          type: OperationType.deposit,
          amountInCents: 5000,
          knownVector: const [2, 5, 1],
          createdAt: DateTime(2026, 11, 14),
        ),
      ],
    );

    viewModel.setAmount(10);
    await viewModel.submit();

    expect(requests.first.url.path, '/contas/7/sincronizar');
    expect(requests[1].url.path, '/contas/7/depositar');
    expect(await store.readOperations('bomtempo'), isEmpty);
  });
}
