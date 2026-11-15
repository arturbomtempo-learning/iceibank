import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/leader_status.dart';
import 'package:iceibank/utils/result.dart';

class LeadershipRepository {
  LeadershipRepository({required this._apiClient});

  static const Duration requestTimeout = Duration(seconds: 2);

  final ApiClient _apiClient;

  Future<Result<LeaderStatus>> fetchLeader() async {
    final probes = await Future.wait(AgencyEndpoints.ids.map(_probe));
    final source = probes.where((probe) => probe.isOnline).firstOrNull;

    if (source == null) {
      return const Result.failure(
        ApiException('Nenhuma das 3 agências respondeu. Tentando de novo em instantes.'),
      );
    }

    return Result.ok(
      LeaderStatus(
        leaderId: source.leaderId,
        sourceAgencyId: source.agencyId,
        probes: List.unmodifiable(probes),
        checkedAt: DateTime.now(),
      ),
    );
  }

  Future<AgencyProbe> _probe(int agencyId) async {
    final stopwatch = Stopwatch()..start();
    try {
      final data = await _apiClient.get(
        agencyId,
        '/bully/lider',
        authenticated: false,
        timeout: requestTimeout,
      );
      final leaderId = data['liderAtual'];

      return AgencyProbe.online(
        agencyId: agencyId,
        leaderId: leaderId is int && AgencyEndpoints.ids.contains(leaderId) ? leaderId : null,
        latency: stopwatch.elapsed,
      );
    } on ApiException {
      return AgencyProbe.offline(agencyId: agencyId);
    }
  }
}
