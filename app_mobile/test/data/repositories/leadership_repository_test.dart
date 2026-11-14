import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/leadership_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/leader_status.dart';
import 'package:iceibank/utils/result.dart';

void main() {
  late List<int> requestedPorts;

  setUp(() => requestedPorts = []);

  LeadershipRepository buildRepository({
    required Set<int> offlinePorts,
    Object? leader = 2,
    int? pinnedAgency,
  }) {
    return LeadershipRepository(
      apiClient: ApiClient(
        readToken: () => 'jwt',
        onUnauthorized: () {},
        pinnedAgency: () => pinnedAgency,
        httpClient: MockClient((request) async {
          requestedPorts.add(request.url.port);
          expect(request.url.path, '/bully/lider');
          expect(request.headers.containsKey('Authorization'), isFalse);
          if (offlinePorts.contains(request.url.port)) {
            throw http.ClientException('Connection refused');
          }
          return http.Response.bytes(
            utf8.encode(jsonEncode({'idAgencia': request.url.port - 4035, 'liderAtual': leader})),
            200,
          );
        }),
      ),
    );
  }

  test('consulta a primeira agência e devolve a líder atual', () async {
    final result = await buildRepository(offlinePorts: {}).fetchLeader();

    expect(requestedPorts, [4035]);
    final status = (result as Ok<LeaderStatus>).value;
    expect(status.leaderId, 2);
    expect(status.sourceAgencyId, 0);
    expect(status.unreachableAgencies, isEmpty);
  });

  test('tenta a próxima agência quando a consultada está fora do ar', () async {
    final result = await buildRepository(offlinePorts: {4035, 4036}).fetchLeader();

    expect(requestedPorts, [4035, 4036, 4037]);
    final status = (result as Ok<LeaderStatus>).value;
    expect(status.sourceAgencyId, 2);
    expect(status.unreachableAgencies, [0, 1]);
  });

  test('ignora a agência fixada e continua tentando as outras', () async {
    final result = await buildRepository(offlinePorts: {4035}, pinnedAgency: 2).fetchLeader();

    expect(requestedPorts, [4035, 4036]);
    expect(result, isA<Ok<LeaderStatus>>());
  });

  test('indica eleição em andamento quando ainda não há líder', () async {
    final result = await buildRepository(offlinePorts: {}, leader: null).fetchLeader();

    expect((result as Ok<LeaderStatus>).value.isElecting, isTrue);
  });

  test('desiste só depois de tentar as 3 agências', () async {
    final result = await buildRepository(offlinePorts: {4035, 4036, 4037}).fetchLeader();

    expect(requestedPorts, [4035, 4036, 4037]);
    expect(
      result,
      isA<Failure<LeaderStatus>>().having(
        (failure) => (failure.error as ApiException).message,
        'message',
        contains('Nenhuma das 3 agências respondeu'),
      ),
    );
  });
}
