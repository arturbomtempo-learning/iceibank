import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iceibank/data/repositories/leadership_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/ui/leadership/view_models/leadership_view_model.dart';

void main() {
  late List<Object?> leaders;
  late LeadershipViewModel viewModel;

  setUp(() {
    leaders = [];
    viewModel = LeadershipViewModel(
      interval: const Duration(milliseconds: 5),
      leadershipRepository: LeadershipRepository(
        apiClient: ApiClient(
          readToken: () => null,
          onUnauthorized: () {},
          httpClient: MockClient((request) async {
            final leader = leaders.length > 1 ? leaders.removeAt(0) : leaders.first;
            if (leader == 'offline') throw http.ClientException('Connection refused');
            return http.Response.bytes(
              utf8.encode(jsonEncode({'idAgencia': 0, 'liderAtual': leader})),
              200,
            );
          }),
        ),
      ),
    );
  });

  tearDown(() => viewModel.dispose());

  Future<void> pollUntil(bool Function() condition) async {
    for (var attempt = 0; attempt < 200 && !condition(); attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  test('consulta sozinho e detecta a troca de líder, mesmo passando por uma eleição', () async {
    leaders = [2, 2, null, 1];
    viewModel.start();

    await pollUntil(() => viewModel.lastChange != null);
    viewModel.stop();

    final change = viewModel.lastChange!;
    expect(change.previousLeaderId, 2);
    expect(change.newLeaderId, 1);
    expect(viewModel.status!.leaderId, 1);
    expect(viewModel.errorMessage, isNull);
  });

  test('mostra o erro quando nenhuma agência responde e se recupera depois', () async {
    leaders = ['offline', 'offline', 'offline', 0];
    viewModel.start();

    await pollUntil(() => viewModel.errorMessage != null);
    expect(viewModel.errorMessage, contains('Nenhuma das 3 agências respondeu'));

    await pollUntil(() => viewModel.status?.leaderId == 0);
    viewModel.stop();

    expect(viewModel.errorMessage, isNull);
    expect(viewModel.lastChange, isNull);
  });

  test('para de consultar quando pausado', () async {
    leaders = [0];
    viewModel.start();
    await pollUntil(() => viewModel.status != null);
    viewModel.stop();

    final checkedAt = viewModel.status!.checkedAt;
    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(viewModel.isRunning, isFalse);
    expect(viewModel.status!.checkedAt, checkedAt);
  });
}
