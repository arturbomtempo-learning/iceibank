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

  AccountRepository buildRepository(MockClient client) {
    return AccountRepository(
      apiClient: ApiClient(readToken: () => 'jwt', onUnauthorized: () {}, httpClient: client),
    );
  }

  test('lê o extrato consolidado, ordena as contas e usa o dono quando falta o nome', () async {
    final repository = buildRepository(
      MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer jwt');
        return http.Response.bytes(utf8.encode(jsonEncode(statementJson)), 200);
      }),
    );

    final result = await repository.fetchStatement();
    final statement = (result as Ok<Statement>).value;

    expect(statement.accounts.map((account) => account.id), [6, 7]);
    expect(statement.accounts.first.holderName, 'bomtempo');
    expect(statement.accounts.last.balance, 800.5);
    expect(statement.totalBalance, 3300.5);
    expect(statement.unavailableAgencies, [2]);
    expect(statement.holderCount, 1);
  });

  test('busca o extrato em outra agência quando a primeira está fora do ar', () async {
    final ports = <int>[];
    final repository = buildRepository(
      MockClient((request) async {
        ports.add(request.url.port);
        if (request.url.port == 4035) throw http.ClientException('Connection refused');
        return http.Response.bytes(utf8.encode(jsonEncode(statementJson)), 200);
      }),
    );

    final result = await repository.fetchStatement();

    expect(result, isA<Ok<Statement>>());
    expect(ports, [4035, 4036]);
  });

  test('envia tudo para a agência fixada, sem tentar as outras', () async {
    final requestedPorts = <int>[];
    final repository = AccountRepository(
      apiClient: ApiClient(
        readToken: () => 'jwt',
        onUnauthorized: () {},
        pinnedAgency: () => 2,
        httpClient: MockClient((request) async {
          requestedPorts.add(request.url.port);
          throw http.ClientException('Connection refused');
        }),
      ),
    );

    final statement = await repository.fetchStatement();
    final account = Account(id: 6, holderName: 'Ana', owner: 'ana', balance: 10, agencyId: 0);
    final deposit = await repository.applyOperation(
      type: OperationType.deposit,
      account: account,
      amount: 5,
    );

    expect(statement, isA<Failure<Statement>>());
    expect(requestedPorts, [4037, 4037]);
    expect(
      deposit,
      isA<Failure<double>>().having(
        (failure) => (failure.error as ApiException).message,
        'message',
        startsWith('A Agência 2, fixada como destino das chamadas, não respondeu.'),
      ),
    );
  });
}
