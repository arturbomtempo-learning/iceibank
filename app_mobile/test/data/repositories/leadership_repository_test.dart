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
    Set<int> offline = const {},
    Map<int, Object?> leaders = const {},
    int? pinnedAgency,
  }) {
    return LeadershipRepository(
      apiClient: ApiClient(
        readToken: () => 'jwt',
        onUnauthorized: () {},
        pinnedAgency: () => pinnedAgency,
        httpClient: MockClient((request) async {
          final agencyId = request.url.port - 4035;
          requestedPorts.add(request.url.port);
          expect(request.url.path, '/bully/lider');
          expect(request.headers.containsKey('Authorization'), isFalse);
          if (offline.contains(agencyId)) throw http.ClientException('Connection refused');
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'idAgencia': agencyId,
                'liderAtual': leaders.containsKey(agencyId) ? leaders[agencyId] : 2,
              }),
            ),
            200,
          );
        }),
      ),
    );
  }

  test('consulta as 3 agências e usa a primeira que responde como fonte da líder', () async {
    final result = await buildRepository().fetchLeader();

    final status = (result as Ok<LeaderStatus>).value;
    expect(requestedPorts..sort(), [4035, 4036, 4037]);
    expect(status.leaderId, 2);
    expect(status.sourceAgencyId, 0);
    expect(status.onlineProbes, hasLength(3));
    expect(status.probes.every((probe) => probe.latency != null), isTrue);
    expect(status.consensus, Consensus.agreed);
  });

  test('passa para a próxima agência quando a primeira está fora do ar', () async {
    final result = await buildRepository(offline: {0}).fetchLeader();

    final status = (result as Ok<LeaderStatus>).value;
    expect(status.sourceAgencyId, 1);
    expect(status.unreachableAgencies, [0]);
    expect(status.probeFor(0)!.isOnline, isFalse);
    expect(status.consensus, Consensus.agreed);
  });

  test('ignora a agência fixada e consulta todas', () async {
    final result = await buildRepository(pinnedAgency: 2).fetchLeader();

    expect(result, isA<Ok<LeaderStatus>>());
    expect(requestedPorts..sort(), [4035, 4036, 4037]);
  });

  test('detecta a líder reconhecida que parou de responder', () async {
    final result = await buildRepository(offline: {2}).fetchLeader();

    expect((result as Ok<LeaderStatus>).value.consensus, Consensus.leaderUnreachable);
  });

  test('detecta agências que discordam sobre a líder', () async {
    final result = await buildRepository(offline: {2}, leaders: {0: 2, 1: 1}).fetchLeader();

    final status = (result as Ok<LeaderStatus>).value;
    expect(status.consensus, Consensus.divergent);
    expect(status.leaderId, 2);
    expect(status.probeFor(1)!.leaderId, 1);
  });

  test('indica eleição em andamento quando nenhuma agência tem líder', () async {
    final result = await buildRepository(leaders: {0: null, 1: null, 2: null}).fetchLeader();

    final status = (result as Ok<LeaderStatus>).value;
    expect(status.isElecting, isTrue);
    expect(status.consensus, Consensus.electing);
  });

  test('desiste só quando nenhuma das 3 agências responde', () async {
    final result = await buildRepository(offline: {0, 1, 2}).fetchLeader();

    expect(requestedPorts, hasLength(3));
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
