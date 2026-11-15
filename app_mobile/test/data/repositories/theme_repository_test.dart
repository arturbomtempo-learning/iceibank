import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iceibank/data/repositories/theme_repository.dart';
import 'package:iceibank/domain/models/theme_preference.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
  });

  test('segue o tema do aparelho quando nada foi escolhido', () async {
    final repository = ThemeRepository();

    await repository.restore();

    expect(repository.preference, ThemePreference.system);
    expect(repository.preference.brightness, isNull);
  });

  test('salva a escolha e a recupera na próxima abertura do app', () async {
    final repository = ThemeRepository();
    await repository.restore();

    await repository.select(ThemePreference.dark);
    final reopened = ThemeRepository();
    await reopened.restore();

    expect(reopened.preference, ThemePreference.dark);
    expect(reopened.preference.brightness, Brightness.dark);
  });

  test('avisa a interface só quando o tema muda de fato', () async {
    final repository = ThemeRepository();
    var notifications = 0;
    repository.addListener(() => notifications++);

    await repository.select(ThemePreference.light);
    await repository.select(ThemePreference.light);

    expect(notifications, 1);
  });

  test('volta para o automático quando o valor salvo é desconhecido', () {
    expect(ThemePreference.fromStorage('roxo'), ThemePreference.system);
    expect(ThemePreference.fromStorage(null), ThemePreference.system);
  });
}
