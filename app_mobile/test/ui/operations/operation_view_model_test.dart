import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/ui/operations/view_models/operation_view_model.dart';

void main() {
  const account = Account(
    id: 7,
    holderName: 'Artur Bomtempo',
    owner: 'bomtempo',
    balance: 100,
    agencyId: 1,
  );

  late List<http.Request> requests;

  OperationViewModel buildViewModel(
    OperationType type,
    Future<http.Response> Function(http.Request request) handler,
  ) {
    requests = [];
    final apiClient = ApiClient(
      readToken: () => 'jwt',
      onUnauthorized: () {},
      httpClient: MockClient((request) {
        requests.add(request);
        return handler(request);
      }),
    );

    return OperationViewModel(
      type: type,
      accounts: const [account],
      accountRepository: AccountRepository(apiClient: apiClient),
    );
  }

  http.Response json(Object body, int status) {
    return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
  }

  test('monta o valor em centavos a partir dos dígitos do teclado', () {
    final viewModel = buildViewModel(OperationType.deposit, (_) async => json({}, 200));

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

  test('recusa dígitos além do limite', () {
    final viewModel = buildViewModel(OperationType.deposit, (_) async => json({}, 200));

    for (var index = 0; index < OperationViewModel.maxDigits; index++) {
      expect(viewModel.appendDigit(9), isTrue);
    }

    expect(viewModel.appendDigit(9), isFalse);
    expect(viewModel.amountInCents, 999999999);
  });

  test('bloqueia um saque maior que o saldo', () {
    final viewModel = buildViewModel(OperationType.withdraw, (_) async => json({}, 200));

    viewModel.setAmount(150);

    expect(viewModel.isOverdrawn, isTrue);
    expect(viewModel.resultingBalance, -50);
    expect(viewModel.canSubmit, isFalse);
  });

  test('deposita na agência dona da conta e guarda o novo saldo', () async {
    final viewModel = buildViewModel(
      OperationType.deposit,
      (_) async => json({'id': 7, 'nomeAluno': 'Artur', 'dono': 'bomtempo', 'saldo': 125.5}, 200),
    );

    viewModel.setAmount(25.5);
    final succeeded = await viewModel.submit();

    expect(succeeded, isTrue);
    expect(requests.single.url.port, 4036);
    expect(requests.single.url.path, '/contas/7/depositar');
    expect(jsonDecode(requests.single.body), {'valor': 25.5});
    expect(viewModel.receipt!.newBalance, 125.5);
    expect(viewModel.selectedAccount!.balance, 125.5);
  });

  test('mostra a mensagem da API quando o saque é recusado', () async {
    final viewModel = buildViewModel(
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

  test('explica qual agência não respondeu quando ela está fora do ar', () async {
    final viewModel = buildViewModel(
      OperationType.deposit,
      (_) async => throw http.ClientException('Connection refused'),
    );

    viewModel.setAmount(10);
    await viewModel.submit();

    expect(requests, hasLength(1));
    expect(viewModel.errorMessage, contains('Agência 1'));
  });
}
