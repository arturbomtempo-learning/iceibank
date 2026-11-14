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
    final unreachable = <int>[];

    for (final agencyId in AgencyEndpoints.ids) {
      try {
        final data = await _apiClient.get(
          agencyId,
          '/bully/lider',
          authenticated: false,
          timeout: requestTimeout,
        );

        final leaderId = data['liderAtual'];
        return Result.ok(
          LeaderStatus(
            leaderId: leaderId is int && AgencyEndpoints.ids.contains(leaderId) ? leaderId : null,
            sourceAgencyId: agencyId,
            unreachableAgencies: List.unmodifiable(unreachable),
            checkedAt: DateTime.now(),
          ),
        );
      } on ApiException {
        unreachable.add(agencyId);
      }
    }

    return const Result.failure(
      ApiException('Nenhuma das 3 agências respondeu. Tentando de novo em instantes.'),
    );
  }
}
