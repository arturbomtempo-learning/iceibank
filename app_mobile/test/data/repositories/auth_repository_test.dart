import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/data/services/session_storage.dart';
import 'package:iceibank/domain/models/user_role.dart';
import 'package:iceibank/utils/result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<int> requestedPorts;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    requestedPorts = [];
  });

  AuthRepository buildRepository(Future<http.Response> Function(http.Request request) handler) {
    late final AuthRepository repository;

    final apiClient = ApiClient(
      readToken: () => repository.token,
      onUnauthorized: () => repository.expireSession(),
      httpClient: MockClient((request) {
        requestedPorts.add(request.url.port);
        return handler(request);
      }),
    );

    repository = AuthRepository(apiClient: apiClient, sessionStorage: SessionStorage());
    return repository;
  }

  http.Response jsonResponse(Object body, int status) {
    return http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json'},
    );
  }

  test('faz login, guarda a sessão e a restaura em uma nova inicialização', () async {
    final repository = buildRepository((request) async {
      expect(jsonDecode(request.body), {'usuario': 'admin', 'senha': 'admin1234'});
      return jsonResponse({
        'token': 'jwt',
        'usuario': 'admin',
        'papel': 'admin',
        'expiraEmSegundos': 3600,
      }, 200);
    });

    final result = await repository.signIn(username: 'admin', password: 'admin1234');

    expect(result, isA<Ok<Object>>());
    expect(repository.isAuthenticated, isTrue);
    expect(repository.session!.role, UserRole.manager);

    final restored = buildRepository((_) async => jsonResponse({}, 500));
    await restored.restore();

    expect(restored.isAuthenticated, isTrue);
    expect(restored.token, 'jwt');
  });

  test('mostra a mensagem da API quando a senha está errada', () async {
    final repository = buildRepository(
      (_) async => jsonResponse({'erro': 'Usuário ou senha inválidos.'}, 401),
    );

    final result = await repository.signIn(username: 'admin', password: 'errada');

    expect(repository.isAuthenticated, isFalse);
    expect(requestedPorts, [4035]);
    expect(
      result,
      isA<Failure<Object>>().having(
        (failure) => (failure.error as ApiException).message,
        'message',
        'Usuário ou senha inválidos.',
      ),
    );
  });

  test('tenta a próxima agência quando uma delas está fora do ar', () async {
    final repository = buildRepository((request) async {
      if (request.url.port == 4035) throw http.ClientException('Connection refused');
      return jsonResponse({
        'token': 'jwt',
        'usuario': 'ana',
        'papel': 'cliente',
        'expiraEmSegundos': 3600,
      }, 200);
    });

    final result = await repository.signIn(username: 'ana', password: 'segredo');

    expect(result, isA<Ok<Object>>());
    expect(requestedPorts, [4035, 4036]);
    expect(repository.session!.role, UserRole.customer);
  });

  test('encerra a sessão quando a API responde 401 em uma rota autenticada', () async {
    var loggedIn = false;
    final repository = buildRepository((request) async {
      if (!loggedIn) {
        loggedIn = true;
        return jsonResponse({
          'token': 'jwt',
          'usuario': 'admin',
          'papel': 'admin',
          'expiraEmSegundos': 3600,
        }, 200);
      }
      return jsonResponse({'erro': 'Token expirado.'}, 401);
    });

    await repository.signIn(username: 'admin', password: 'admin1234');
    expect(repository.isAuthenticated, isTrue);

    final apiClient = ApiClient(
      readToken: () => repository.token,
      onUnauthorized: () => repository.expireSession(),
      httpClient: MockClient((_) async => jsonResponse({'erro': 'Token expirado.'}, 401)),
    );

    await expectLater(apiClient.get(0, '/extrato'), throwsA(isA<ApiException>()));
    await pumpEventQueue();

    expect(repository.isAuthenticated, isFalse);
    expect(repository.wasSessionExpired, isTrue);
  });

  test('não marca a sessão como expirada quando a pessoa sai por conta própria', () async {
    final repository = buildRepository(
      (_) async => jsonResponse({
        'token': 'jwt',
        'usuario': 'ana',
        'papel': 'cliente',
        'expiraEmSegundos': 3600,
      }, 200),
    );

    await repository.signIn(username: 'ana', password: 'segredo');
    await repository.signOut();

    expect(repository.isAuthenticated, isFalse);
    expect(repository.wasSessionExpired, isFalse);
  });
}
