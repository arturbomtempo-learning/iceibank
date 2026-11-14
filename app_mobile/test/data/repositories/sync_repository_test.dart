import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/sync_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/domain/models/pending_operation.dart';
import 'package:iceibank/utils/result.dart';

import '../../support/in_memory_offline_store.dart';

void main() {
  const account = Account(
    id: 300,
    holderName: 'Conta Offline',
    owner: 'admin',
    balance: 100,
    agencyId: 0,
    vector: [9, 4, 3],
  );

  late InMemoryOfflineStore store;
  late List<http.Request> requests;
  late Future<http.Response> Function(http.Request request) handler;

  setUp(() {
    store = InMemoryOfflineStore();
    requests = [];
    handler = (_) async => throw http.ClientException('Connection refused');
  });

  http.Response json(Object body, [int status = 200]) {
    return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
  }

  Future<SyncRepository> buildRepository() async {
    final repository = SyncRepository(
      offlineStore: store,
      apiClient: ApiClient(
        readToken: () => 'jwt',
        onUnauthorized: () {},
        httpClient: MockClient((request) {
          requests.add(request);
          return handler(request);
        }),
      ),
    );
    await repository.attach('admin');
    return repository;
  }

  Map<String, Object?> accountJson(double balance) {
    return {'id': 300, 'nomeAluno': 'Conta Offline', 'dono': 'admin', 'saldo': balance};
  }

  test('guarda a operação com o vetor conhecido e a mantém depois de reabrir o app', () async {
    final repository = await buildRepository();

    final result = await repository.enqueue(
      account: account,
      type: OperationType.deposit,
      amountInCents: 5000,
    );
    final reopened = await buildRepository();

    expect(result, isA<Ok<PendingOperation>>());
    expect(repository.pendingEffectFor(300), 50);
    expect(repository.hasWaitingFor(0), isTrue);
    expect(reopened.operations.single.knownVector, [9, 4, 3]);
  });

  test('mantém a operação na fila enquanto a agência não responde', () async {
    final repository = await buildRepository();
    await repository.enqueue(account: account, type: OperationType.deposit, amountInCents: 5000);

    await repository.synchronize();

    expect(requests, hasLength(1));
    expect(repository.operations.single.status, PendingStatus.waiting);
    expect(repository.lastReport, isNull);
  });

  test('sincroniza ao reconectar, enviando tipo, valor e vetor conhecido', () async {
    final repository = await buildRepository();
    await repository.enqueue(account: account, type: OperationType.withdraw, amountInCents: 3000);
    handler = (_) async => json(accountJson(70));

    await repository.synchronize();

    expect(requests.single.url.path, '/contas/300/sincronizar');
    expect(jsonDecode(requests.single.body), {
      'tipo': 'SAQUE',
      'valor': 30,
      'vetorConhecido': [9, 4, 3],
    });
    expect(repository.operations, isEmpty);
    expect(repository.lastReport!.appliedCount, 1);
    final cached = (await store.readAccounts('admin')).single;
    expect(cached.balance, 70);
    expect(cached.vector, [10, 4, 3]);
  });

  test('encadeia o vetor entre operações seguidas da mesma agência', () async {
    final repository = await buildRepository();
    await repository.enqueue(account: account, type: OperationType.deposit, amountInCents: 1000);
    await repository.enqueue(account: account, type: OperationType.deposit, amountInCents: 2000);
    var balance = 100.0;
    handler = (request) async {
      balance += (jsonDecode(request.body) as Map<String, Object?>)['valor']! as num;
      return json(accountJson(balance));
    };

    await repository.synchronize();

    final sentVectors = requests
        .map((request) => (jsonDecode(request.body) as Map<String, Object?>)['vetorConhecido'])
        .toList();
    expect(sentVectors, [
      [9, 4, 3],
      [10, 4, 3],
    ]);
    expect(repository.operations, isEmpty);
    expect(repository.lastReport!.appliedCount, 2);
  });

  test('marca o conflito 409 com o saldo e o vetor reais devolvidos pela agência', () async {
    final repository = await buildRepository();
    await repository.enqueue(account: account, type: OperationType.withdraw, amountInCents: 3000);
    handler = (_) async => json({
      'erro': 'Conflito detectado: o estado da conta mudou desde a última sincronização do app.',
      'vetorConhecido': [9, 4, 3],
      'vetorAtual': [10, 4, 3],
      'contaAtual': accountJson(150),
    }, 409);

    await repository.synchronize();

    final conflict = repository.operations.single;
    expect(conflict.status, PendingStatus.conflict);
    expect(conflict.serverBalance, 150);
    expect(conflict.serverVector, [10, 4, 3]);
    expect(repository.pendingEffectFor(300), 0);
    expect(repository.lastReport!.conflictCount, 1);
    expect((await store.readAccounts('admin')).single.balance, 150);
  });

  test('aplica o conflito com o vetor atual só quando a pessoa decide', () async {
    final repository = await buildRepository();
    await repository.enqueue(account: account, type: OperationType.withdraw, amountInCents: 3000);
    handler = (_) async => json({
      'erro': 'Conflito detectado.',
      'vetorAtual': [10, 4, 3],
      'contaAtual': accountJson(150),
    }, 409);
    await repository.synchronize();
    await repository.synchronize();
    expect(requests, hasLength(1));

    handler = (_) async => json(accountJson(120));
    await repository.retryWithLatestState(repository.operations.single);

    expect(jsonDecode(requests.last.body), containsPair('vetorConhecido', [10, 4, 3]));
    expect(repository.operations, isEmpty);
  });

  test('descarta a operação quando a pessoa escolhe', () async {
    final repository = await buildRepository();
    await repository.enqueue(account: account, type: OperationType.deposit, amountInCents: 1000);

    await repository.discard(repository.operations.single);

    expect(repository.operations, isEmpty);
    expect(await store.readOperations('admin'), isEmpty);
  });

  test('registra a recusa da agência para a pessoa decidir', () async {
    final repository = await buildRepository();
    await repository.enqueue(account: account, type: OperationType.withdraw, amountInCents: 3000);
    handler = (_) async => json({'erro': 'Saldo insuficiente.'}, 400);

    await repository.synchronize();

    expect(repository.operations.single.status, PendingStatus.rejected);
    expect(repository.operations.single.message, 'Saldo insuficiente.');
  });

  test('não guarda nada quando ainda não conhece o vetor da conta', () async {
    final repository = await buildRepository();

    final result = await repository.enqueue(
      account: const Account(id: 300, holderName: 'X', owner: 'admin', balance: 1, agencyId: 0),
      type: OperationType.deposit,
      amountInCents: 1000,
    );

    expect(result, isA<Failure<PendingOperation>>());
    expect(repository.operations, isEmpty);
  });
}
