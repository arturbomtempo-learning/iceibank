import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/account_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/ui/transfers/view_models/transfer_view_model.dart';

void main() {
  const accounts = [
    Account(id: 6, holderName: 'Artur Bomtempo', owner: 'bomtempo', balance: 500, agencyId: 0),
    Account(id: 9, holderName: 'Artur Bomtempo', owner: 'bomtempo', balance: 80, agencyId: 0),
  ];

  late List<http.Request> requests;

  TransferViewModel buildViewModel(Future<http.Response> Function(http.Request) handler) {
    requests = [];
    final apiClient = ApiClient(
      readToken: () => 'jwt',
      onUnauthorized: () {},
      httpClient: MockClient((request) {
        requests.add(request);
        return handler(request);
      }),
    );
    return TransferViewModel(
      accounts: accounts,
      accountRepository: AccountRepository(apiClient: apiClient),
    );
  }

  http.Response json(Object body, int status) {
    return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
  }

  test('não aceita a própria conta de origem como destino', () {
    final viewModel = buildViewModel((_) async => json({}, 200));

    viewModel.updateTarget('6');

    expect(viewModel.targetError, 'A conta de destino deve ser diferente da origem.');
    expect(viewModel.canContinue, isFalse);
  });

  test('identifica transferência na mesma agência e entre agências', () {
    final viewModel = buildViewModel((_) async => json({}, 200));

    viewModel.updateTarget('9');
    expect(viewModel.isInterAgency, isFalse);
    expect(viewModel.knownTarget?.id, 9);

    viewModel.updateTarget('7');
    expect(viewModel.isInterAgency, isTrue);
    expect(viewModel.targetAgency, 1);
    expect(viewModel.knownTarget, isNull);
  });

  test('avança e volta entre os passos respeitando as validações', () {
    final viewModel = buildViewModel((_) async => json({}, 200));

    viewModel.next();
    expect(viewModel.step, TransferStep.destination);

    viewModel.updateTarget('7');
    viewModel.next();
    expect(viewModel.step, TransferStep.amount);

    viewModel.setAmount(600);
    expect(viewModel.isOverdrawn, isTrue);
    viewModel.next();
    expect(viewModel.step, TransferStep.amount);

    viewModel.setAmount(120);
    viewModel.next();
    expect(viewModel.step, TransferStep.review);

    expect(viewModel.back(), isTrue);
    expect(viewModel.step, TransferStep.amount);
  });

  test('envia a transferência para a agência da conta de origem', () async {
    final viewModel = buildViewModel(
      (_) async => json({
        'mensagem': 'Transferência publicada para a agência de destino (entrega assíncrona).',
      }, 200),
    );

    viewModel
      ..updateTarget('7')
      ..setAmount(120.5);
    final succeeded = await viewModel.submit();

    expect(succeeded, isTrue);
    expect(requests.single.url.port, 4035);
    expect(requests.single.url.path, '/transferencias');
    expect(jsonDecode(requests.single.body), {'idOrigem': 6, 'idDestino': 7, 'valor': 120.5});
    expect(viewModel.receipt!.isInterAgency, isTrue);
    expect(viewModel.receipt!.remainingBalance, 379.5);
  });

  test('mostra a mensagem da API quando a transferência falha', () async {
    final viewModel = buildViewModel(
      (_) async => json({'erro': 'Conta de destino não encontrada.'}, 404),
    );

    viewModel
      ..updateTarget('12')
      ..setAmount(10);
    final succeeded = await viewModel.submit();

    expect(succeeded, isFalse);
    expect(viewModel.errorMessage, 'Conta de destino não encontrada.');
    expect(viewModel.receipt, isNull);
  });
}
