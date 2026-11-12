import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/user_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/ui/management/view_models/new_customer_view_model.dart';

void main() {
  late List<http.Request> requests;

  NewCustomerViewModel buildViewModel(http.Response response) {
    requests = [];
    final apiClient = ApiClient(
      readToken: () => 'jwt',
      onUnauthorized: () {},
      httpClient: MockClient((request) async {
        requests.add(request);
        return response;
      }),
    );
    return NewCustomerViewModel(userRepository: UserRepository(apiClient: apiClient));
  }

  http.Response json(Object body, int status) {
    return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
  }

  test('aplica as mesmas regras de usuário e senha do web', () async {
    final viewModel = buildViewModel(json({}, 201));

    await viewModel.submit(username: 'an', password: '123');
    expect(viewModel.usernameError, 'O usuário deve ter pelo menos 3 caracteres.');
    expect(viewModel.passwordError, 'A senha deve ter pelo menos 6 caracteres.');

    await viewModel.submit(username: 'Ana Silva', password: '123456');
    expect(
      viewModel.usernameError,
      'Use apenas letras minúsculas, números, ponto, hífen ou sublinhado.',
    );
    expect(requests, isEmpty);
  });

  test('cadastra o correntista e guarda o usuário criado', () async {
    final viewModel = buildViewModel(json({'usuario': 'ana.souza', 'papel': 'cliente'}, 201));

    await viewModel.submit(username: ' ana.souza ', password: 'segredo1');

    expect(viewModel.createdUsername, 'ana.souza');
    expect(requests.single.url.path, '/usuarios');
    expect(jsonDecode(requests.single.body), {'usuario': 'ana.souza', 'senha': 'segredo1'});
  });

  test('mostra no campo de usuário quando ele já existe', () async {
    final viewModel = buildViewModel(json({'erro': 'Já existe um usuário com esse nome.'}, 409));

    await viewModel.submit(username: 'ana', password: 'segredo1');

    expect(viewModel.usernameError, 'Já existe um usuário com esse nome.');
    expect(viewModel.formError, isNull);
    expect(viewModel.createdUsername, isNull);
  });
}
