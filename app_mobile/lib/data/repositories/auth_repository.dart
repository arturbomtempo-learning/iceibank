import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/data/services/api_client.dart';
import 'package:iceibank/data/services/api_exception.dart';
import 'package:iceibank/data/services/session_storage.dart';
import 'package:iceibank/domain/models/session.dart';
import 'package:iceibank/domain/models/user_role.dart';
import 'package:iceibank/utils/result.dart';

class AuthRepository extends ChangeNotifier {
  AuthRepository({required this._apiClient, required this._sessionStorage});

  final ApiClient _apiClient;
  final SessionStorage _sessionStorage;

  Session? _session;
  Timer? _expirationTimer;

  Session? get session => _session;

  String? get token => _session?.token;

  bool get isAuthenticated => _session != null;

  Future<void> restore() async {
    _setSession(await _sessionStorage.read());
  }

  Future<Result<Session>> signIn({required String username, required String password}) async {
    ApiException? lastNetworkFailure;

    for (final agencyId in AgencyEndpoints.ids) {
      try {
        final data = await _apiClient.post(
          agencyId,
          '/auth/login',
          body: {'usuario': username, 'senha': password},
          authenticated: false,
        );

        final session = _sessionFromLogin(data);
        if (session == null) {
          return const Result.failure(ApiException.unexpected());
        }

        await _sessionStorage.write(session);
        _setSession(session);
        return Result.ok(session);
      } on ApiException catch (error) {
        if (!error.isNetworkFailure) return Result.failure(error);
        lastNetworkFailure = error;
      }
    }

    return Result.failure(lastNetworkFailure ?? const ApiException.unreachable());
  }

  Future<void> signOut() async {
    if (_session == null) return;

    _setSession(null);
    await _sessionStorage.clear();
  }

  Session? _sessionFromLogin(JsonMap data) {
    if (data case {
      'token': final String token,
      'usuario': final String username,
      'papel': final String roleValue,
      'expiraEmSegundos': final int expiresInSeconds,
    }) {
      final role = UserRole.fromApiValue(roleValue);
      if (role == null) return null;

      return Session(
        token: token,
        username: username,
        role: role,
        expiresAt: DateTime.now().add(Duration(seconds: expiresInSeconds)),
      );
    }
    return null;
  }

  void _setSession(Session? session) {
    _expirationTimer?.cancel();
    _session = session;

    if (session != null) {
      _expirationTimer = Timer(session.expiresAt.difference(DateTime.now()), signOut);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _expirationTimer?.cancel();
    super.dispose();
  }
}
