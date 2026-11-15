import 'package:flutter_test/flutter_test.dart';
import 'package:iceibank/data/repositories/leadership_repository.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/domain/models/leader_status.dart';
import 'package:iceibank/ui/leadership/view_models/leadership_view_model.dart';
import 'package:iceibank/utils/result.dart';

class ScriptedLeadershipRepository extends LeadershipRepository {
  ScriptedLeadershipRepository(this.script)
    : super(
        apiClient: ApiClient(readToken: () => null, onUnauthorized: () {}),
      );

  final List<Object?> script;

  @override
  Future<Result<LeaderStatus>> fetchLeader() async {
    final leader = script.length > 1 ? script.removeAt(0) : script.first;
    if (leader == 'offline') {
      return const Result.failure(ApiException('Nenhuma das 3 agências respondeu.'));
    }
    return Result.ok(
      LeaderStatus(
        leaderId: leader as int?,
        sourceAgencyId: 0,
        probes: [
          for (final agencyId in [0, 1, 2])
            AgencyProbe.online(
              agencyId: agencyId,
              leaderId: leader,
              latency: const Duration(milliseconds: 4),
            ),
        ],
        checkedAt: DateTime.now(),
      ),
    );
  }
}

void main() {
  late List<Object?> leaders;
  late LeadershipViewModel viewModel;

  setUp(() {
    leaders = [];
    viewModel = LeadershipViewModel(
      interval: const Duration(milliseconds: 5),
      leadershipRepository: ScriptedLeadershipRepository(leaders),
    );
  });

  tearDown(() => viewModel.dispose());

  Future<void> pollUntil(bool Function() condition) async {
    for (var attempt = 0; attempt < 200 && !condition(); attempt++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  test('consulta sozinho e detecta a troca de líder, mesmo passando por uma eleição', () async {
    leaders.addAll([2, 2, null, 1]);
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
    leaders.addAll(['offline', 0]);
    viewModel.start();

    await pollUntil(() => viewModel.errorMessage != null);
    expect(viewModel.errorMessage, contains('Nenhuma das 3 agências respondeu'));

    await pollUntil(() => viewModel.status?.leaderId == 0);
    viewModel.stop();

    expect(viewModel.errorMessage, isNull);
    expect(viewModel.lastChange, isNull);
  });

  test('para de consultar quando pausado', () async {
    leaders.addAll([0]);
    viewModel.start();
    await pollUntil(() => viewModel.status != null);
    viewModel.stop();

    final checkedAt = viewModel.status!.checkedAt;
    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(viewModel.isRunning, isFalse);
    expect(viewModel.status!.checkedAt, checkedAt);
  });
}
