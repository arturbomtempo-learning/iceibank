import 'package:flutter/foundation.dart';
import 'package:iceibank/data/repositories/theme_repository.dart';
import 'package:iceibank/domain/models/theme_preference.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required this._themeRepository}) {
    _themeRepository.addListener(notifyListeners);
  }

  final ThemeRepository _themeRepository;

  ThemePreference get themePreference => _themeRepository.preference;

  Future<void> selectTheme(ThemePreference preference) => _themeRepository.select(preference);

  @override
  void dispose() {
    _themeRepository.removeListener(notifyListeners);
    super.dispose();
  }
}
