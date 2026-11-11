import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
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
}
