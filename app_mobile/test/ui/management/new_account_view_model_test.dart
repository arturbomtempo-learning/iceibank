import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/ui/management/view_models/new_account_view_model.dart';
import 'package:iceibank/utils/currency_input_formatter.dart';

void main() {
  late List<http.Request> requests;

  NewAccountViewModel buildViewModel(http.Response response, {String initialOwner = ''}) {
    requests = [];
    final apiClient = ApiClient(
      readToken: () => 'jwt',
      onUnauthorized: () {},
      httpClient: MockClient((request) async {
        requests.add(request);
        return response;
      }),
    );
    return NewAccountViewModel(
      accountRepository: AccountRepository(apiClient: apiClient),
      initialOwner: initialOwner,
    );
  }

  http.Response json(Object body, int status) {
    return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
  }

  test('exige número, titular e dono, como no web', () async {
    final viewModel = buildViewModel(json({}, 201));

    await viewModel.submit();

    expect(viewModel.accountError, 'Informe o número da conta.');
    expect(viewModel.holderError, 'Informe o nome do titular.');
    expect(viewModel.ownerError, 'Informe o usuário dono da conta.');
    expect(requests, isEmpty);
  });

  test('abre a conta na agência definida pelo número', () async {
    final viewModel = buildViewModel(
      json({'id': 8, 'nomeAluno': 'Maria Souza', 'dono': 'maria', 'saldo': 150.5}, 201),
      initialOwner: 'maria',
    );

    viewModel
      ..updateAccountNumber('8')
      ..updateHolderName('Maria Souza')
      ..updateInitialBalance(15050);
    expect(viewModel.agencyId, 2);

    await viewModel.submit();

    expect(requests.single.url.port, 4037);
    expect(jsonDecode(requests.single.body), {
      'id': 8,
      'nomeAluno': 'Maria Souza',
      'dono': 'maria',
      'saldoInicial': 150.5,
    });
    expect(viewModel.createdAccount!.agencyId, 2);
    expect(viewModel.createdAccount!.balance, 150.5);
  });

  test('aponta o campo certo quando a conta já existe ou o dono não existe', () async {
    final duplicated = buildViewModel(json({'erro': 'Conta já existe.'}, 409), initialOwner: 'ana')
      ..updateAccountNumber('3')
      ..updateHolderName('Ana');
    await duplicated.submit();
    expect(duplicated.accountError, 'Conta já existe.');

    final unknownOwner =
        buildViewModel(
            json({'erro': "O campo 'dono' deve ser um usuário existente."}, 400),
            initialOwner: 'fantasma',
          )
          ..updateAccountNumber('3')
          ..updateHolderName('Ana');
    await unknownOwner.submit();
    expect(unknownOwner.ownerError, contains('Cadastre o correntista'));
  });

  test('formata o saldo inicial como moeda enquanto a pessoa digita', () {
    const formatter = CurrencyInputFormatter();
    final value = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '25050'),
    );

    expect(value.text, r'R$ 250,50');
    expect(CurrencyInputFormatter.centsFrom(value.text), 25050);
  });
}
