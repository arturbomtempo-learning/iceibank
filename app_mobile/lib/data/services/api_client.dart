import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/data/services/api_exception.dart';

typedef JsonMap = Map<String, Object?>;

class ApiClient {
  ApiClient({
    required this._readToken,
    required this._onUnauthorized,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 10),
  }) : _httpClient = httpClient ?? http.Client();

  final String? Function() _readToken;
  final void Function() _onUnauthorized;
  final http.Client _httpClient;
  final Duration timeout;

  Future<T> withFailover<T>(Future<T> Function(int agencyId) request) async {
    ApiException? lastNetworkFailure;

    for (final agencyId in AgencyEndpoints.ids) {
      try {
        return await request(agencyId);
      } on ApiException catch (error) {
        if (!error.isNetworkFailure) rethrow;
        lastNetworkFailure = error;
      }
    }

    throw lastNetworkFailure ?? const ApiException.unreachable();
  }

  Future<JsonMap> get(int agencyId, String path) {
    return _send('GET', agencyId, path, authenticated: true);
  }

  Future<JsonMap> post(int agencyId, String path, {JsonMap? body, bool authenticated = true}) {
    return _send('POST', agencyId, path, body: body, authenticated: authenticated);
  }

  Future<JsonMap> _send(
    String method,
    int agencyId,
    String path, {
    required bool authenticated,
    JsonMap? body,
  }) async {
    final request = http.Request(method, AgencyEndpoints.uriFor(agencyId, path))
      ..headers['Accept'] = 'application/json';

    final token = authenticated ? _readToken() : null;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await _httpClient.send(request).then(http.Response.fromStream).timeout(timeout);
    } on TimeoutException {
      throw const ApiException.timeout();
    } on http.ClientException {
      throw const ApiException.unreachable();
    }

    final data = _decode(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    if (response.statusCode == 401 && authenticated) {
      _onUnauthorized();
    }

    final message = data['erro'];
    if (message is String) {
      throw ApiException(message, statusCode: response.statusCode);
    }
    throw ApiException.unexpected(statusCode: response.statusCode);
  }

  JsonMap _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return const {};

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded is JsonMap ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }

  void close() => _httpClient.close();
}
