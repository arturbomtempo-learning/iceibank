import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/utils/result.dart';

class UserRepository {
  UserRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<Result<String>> createCustomer({
    required String username,
    required String password,
  }) async {
    try {
      final data = await _apiClient.withFailover(
        (agencyId) =>
            _apiClient.post(agencyId, '/usuarios', body: {'usuario': username, 'senha': password}),
      );

      final created = data['usuario'];
      return Result.ok(created is String ? created : username);
    } on ApiException catch (error) {
      return Result.failure(error);
    }
  }
}
