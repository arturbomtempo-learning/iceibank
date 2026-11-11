import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iceibank/domain/models/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  SessionStorage({FlutterSecureStorage? secureStorage, this._preferences})
    : _secureStorage = secureStorage ?? _defaultSecureStorage;

  static const String _sessionKey = 'iceibank.session';
  static const String _installedKey = 'iceibank.installed';

  static const FlutterSecureStorage _defaultSecureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  final FlutterSecureStorage _secureStorage;
  final SharedPreferencesAsync? _preferences;

  Future<void> clearIfFreshInstall() async {
    final preferences = _preferences ?? SharedPreferencesAsync();
    final isInstalled = await preferences.getBool(_installedKey) ?? false;
    if (isInstalled) return;

    await clear();
    await preferences.setBool(_installedKey, true);
  }

  Future<Session?> read() async {
    try {
      final rawSession = await _secureStorage.read(key: _sessionKey);
      if (rawSession == null) return null;

      final session = Session.fromJson(jsonDecode(rawSession));
      if (session == null || session.isExpired) {
        await clear();
        return null;
      }
      return session;
    } on FormatException {
      await clear();
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<void> write(Session session) {
    return _secureStorage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
  }

  Future<void> clear() => _secureStorage.delete(key: _sessionKey);
}
