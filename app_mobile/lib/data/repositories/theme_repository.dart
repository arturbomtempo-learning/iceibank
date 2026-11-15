import 'package:flutter/foundation.dart';
import 'package:iceibank/domain/models/theme_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository extends ChangeNotifier {
  ThemeRepository({this._preferences});

  static const String _storageKey = 'iceibank.theme';

  final SharedPreferencesAsync? _preferences;

  ThemePreference _preference = ThemePreference.system;

  ThemePreference get preference => _preference;

  SharedPreferencesAsync get _storage => _preferences ?? SharedPreferencesAsync();

  Future<void> restore() async {
    _preference = ThemePreference.fromStorage(await _storage.getString(_storageKey));
    notifyListeners();
  }

  Future<void> select(ThemePreference preference) async {
    if (preference == _preference) return;

    _preference = preference;
    notifyListeners();
    await _storage.setString(_storageKey, preference.storageValue);
  }
}
