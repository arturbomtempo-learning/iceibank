import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/domain/models/statement.dart';
import 'package:iceibank/utils/result.dart';

class AccountRepository {
  AccountRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<Result<Statement>> fetchStatement() async {
    try {
      final data = await _apiClient.withFailover(
        (agencyId) => _apiClient.get(agencyId, '/extrato'),
      );

      final statement = Statement.fromJson(data);
      if (statement == null) {
        return const Result.failure(ApiException.unexpected());
      }
      return Result.ok(statement);
    } on ApiException catch (error) {
      return Result.failure(error);
    }
  }

  Future<Result<double>> applyOperation({
    required OperationType type,
    required Account account,
    required double amount,
  }) async {
    final agencyId = AgencyEndpoints.agencyFor(account.id);

    try {
      final data = await _apiClient.post(
        agencyId,
        '/contas/${account.id}/${type.path}',
        body: {'valor': amount},
      );

      final newBalance = data['saldo'];
      if (newBalance is! num) {
        return const Result.failure(ApiException.unexpected());
      }
      return Result.ok(newBalance.toDouble());
    } on ApiException catch (error) {
      if (!error.isNetworkFailure) return Result.failure(error);

      return Result.failure(
        ApiException(
          'A Agência $agencyId, que guarda esta conta, não respondeu. Tente de novo em instantes.',
        ),
      );
    }
  }

  Future<Result<String>> transfer({
    required Account source,
    required int targetAccountId,
    required double amount,
  }) async {
    final agencyId = AgencyEndpoints.agencyFor(source.id);

    try {
      final data = await _apiClient.post(
        agencyId,
        '/transferencias',
        body: {'idOrigem': source.id, 'idDestino': targetAccountId, 'valor': amount},
      );

      final message = data['mensagem'];
      return Result.ok(message is String ? message : 'Transferência concluída.');
    } on ApiException catch (error) {
      if (!error.isNetworkFailure) return Result.failure(error);

      return Result.failure(
        ApiException(
          'A Agência $agencyId, que guarda a conta de origem, não respondeu. '
          'Nada foi debitado. Tente de novo em instantes.',
        ),
      );
    }
  }
}
