import 'dart:io';

abstract final class AgencyEndpoints {
  static const int count = 3;

  static const String _hostOverride = String.fromEnvironment('API_HOST');
  static const int _basePort = int.fromEnvironment('API_BASE_PORT', defaultValue: 4035);

  static List<int> get ids => List.unmodifiable(List<int>.generate(count, (index) => index));

  static String get host {
    if (_hostOverride.isNotEmpty) return _hostOverride;
    return Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  }

  static Uri uriFor(int agencyId, String path) {
    return Uri(scheme: 'http', host: host, port: _basePort + agencyId, path: path);
  }
}
