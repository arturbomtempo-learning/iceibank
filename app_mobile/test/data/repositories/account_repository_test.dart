import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/domain/models/statement.dart';
import 'package:iceibank/utils/result.dart';

import '../../support/in_memory_offline_store.dart';

void main() {
  const statementJson = {
    'usuario': 'bomtempo',
    'contas': [
      {'id': 7, 'nomeAluno': 'Artur Bomtempo', 'dono': 'bomtempo', 'saldo': 800.5, 'agencia': 1},
      {'id': 6, 'nomeAluno': null, 'dono': 'bomtempo', 'saldo': 2500, 'agencia': 0},
    ],
    'saldoTotal': 3300.5,
    'agenciasIndisponiveis': [2],
  };

  late InMemoryOfflineStore store;

  setUp(() => store = InMemoryOfflineStore());

  http.Response json(Object body, [int status = 200]) {
    return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
  }

  AccountRepository buildRepository(MockClient client, {int? pinnedAgency}) {
    return AccountRepository(
      offlineStore: store,
      apiClient: ApiClient(
        readToken: () => 'jwt',
        onUnauthorized: () {},
        pinnedAgency: () => pinnedAgency,
        httpClient: client,
      ),
    );
  }

  Future<http.Response> onlineHandler(http.Request request) async {
    return switch (request.url.path) {
      '/extrato' => json(statementJson),
      '/contas/7' => json({
        'id': 7,
        'nomeAluno': 'Artur Bomtempo',
        'dono': 'bomtempo',
        'saldo': 800.5,
        'vetorAtual': [0, 5, 2],
      }),
      _ => json({'erro': 'Conta não encontrada nesta agência.'}, 404),
    };
  }

  test('lê o extrato consolidado, ordena as contas e usa o dono quando falta o nome', () async {
    final repository = buildRepository(MockClient(onlineHandler));

    final result = await repository.fetchStatement(username: 'bomtempo');
    final statement = (result as Ok<Statement>).value;

    expect(statement.accounts.map((account) => account.id), [6, 7]);
    expect(statement.accounts.first.holderName, 'bomtempo');
    expect(statement.accounts.last.balance, 800.5);
    expect(statement.totalBalance, 3300.5);
    expect(statement.unavailableAgencies, [2]);
    expect(statement.holderCount, 1);
    expect(statement.isOffline, isFalse);
  });

  test('guarda saldo e vetor de cada conta consultada no armazenamento local', () async {
    final repository = buildRepository(MockClient(onlineHandler));

    final result = await repository.fetchStatement(username: 'bomtempo');
    final statement = (result as Ok<Statement>).value;
    final cached = await store.readAccounts('bomtempo');

    expect(statement.accounts.last.vector, [0, 5, 2]);
    expect(statement.accounts.first.vector, isNull);
    expect(cached.map((account) => account.id), [6, 7]);
    expect(cached.last.vector, [0, 5, 2]);
  });

  test('mostra o último saldo conhecido quando nenhuma agência responde', () async {
    var online = true;
    final repository = buildRepository(
      MockClient((request) async {
        if (!online) throw http.ClientException('Connection refused');
        return onlineHandler(request);
      }),
    );
    await repository.fetchStatement(username: 'bomtempo');

    online = false;
    final result = await repository.fetchStatement(username: 'bomtempo');
    final statement = (result as Ok<Statement>).value;

    expect(statement.isOffline, isTrue);
    expect(statement.unavailableAgencies, [0, 1, 2]);
    expect(statement.accounts.map((account) => account.balance), [2500, 800.5]);
    expect(statement.accounts.every((account) => account.isStale), isTrue);
    expect(statement.cachedAt, isNotNull);
  });

  test('completa o extrato com as contas guardadas da agência que caiu', () async {
    var agencyOneDown = false;
    final repository = buildRepository(
      MockClient((request) async {
        if (request.url.path == '/extrato' && agencyOneDown) {
          return json({
            'contas': [
              {'id': 6, 'nomeAluno': null, 'dono': 'bomtempo', 'saldo': 2500, 'agencia': 0},
            ],
            'agenciasIndisponiveis': [1, 2],
          });
        }
        return onlineHandler(request);
      }),
    );
    await repository.fetchStatement(username: 'bomtempo');

    agencyOneDown = true;
    final result = await repository.fetchStatement(username: 'bomtempo');
    final statement = (result as Ok<Statement>).value;

    expect(statement.accounts.map((account) => account.id), [6, 7]);
    expect(statement.accounts.first.isStale, isFalse);
    expect(statement.accounts.last.isStale, isTrue);
    expect(statement.accounts.last.vector, [0, 5, 2]);
    expect(statement.isOffline, isFalse);
  });

  test('falha quando não há conexão nem dados guardados', () async {
    final repository = buildRepository(
      MockClient((_) async => throw http.ClientException('Connection refused')),
    );

    final result = await repository.fetchStatement(username: 'bomtempo');

    expect(result, isA<Failure<Statement>>());
  });

  test('atualiza saldo e vetor da conta depois de uma operação', () async {
    final repository = buildRepository(
      MockClient((request) async {
        if (request.url.path == '/contas/7/depositar') {
          return json({'id': 7, 'nomeAluno': 'Artur', 'dono': 'bomtempo', 'saldo': 900.5});
        }
        return json({
          'id': 7,
          'nomeAluno': 'Artur',
          'dono': 'bomtempo',
          'saldo': 900.5,
          'vetorAtual': [0, 6, 2],
        });
      }),
    );
    const account = Account(
      id: 7,
      holderName: 'Artur',
      owner: 'bomtempo',
      balance: 800.5,
      agencyId: 1,
      vector: [0, 5, 2],
    );

    final result = await repository.applyOperation(
      username: 'bomtempo',
      type: OperationType.deposit,
      account: account,
      amount: 100,
    );
    final updated = (result as Ok<Account>).value;

    expect(updated.balance, 900.5);
    expect(updated.vector, [0, 6, 2]);
    expect((await store.readAccounts('bomtempo')).single.vector, [0, 6, 2]);
  });

  test('envia tudo para a agência fixada, sem tentar as outras', () async {
    final requestedPorts = <int>[];
    final repository = buildRepository(
      MockClient((request) async {
        requestedPorts.add(request.url.port);
        throw http.ClientException('Connection refused');
      }),
      pinnedAgency: 2,
    );

    final statement = await repository.fetchStatement(username: 'ana');
    const account = Account(id: 6, holderName: 'Ana', owner: 'ana', balance: 10, agencyId: 0);
    final deposit = await repository.applyOperation(
      username: 'ana',
      type: OperationType.deposit,
      account: account,
      amount: 5,
    );

    expect(statement, isA<Failure<Statement>>());
    expect(requestedPorts, [4037, 4037]);
    expect(
      deposit,
      isA<Failure<Account>>().having(
        (failure) => (failure.error as ApiException).message,
        'message',
        startsWith('A Agência 2, fixada como destino das chamadas, não respondeu.'),
      ),
    );
  });
}
