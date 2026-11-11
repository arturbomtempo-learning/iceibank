import 'package:iceibank/domain/models/user_role.dart';

class Session {
  const Session({
    required this.token,
    required this.username,
    required this.role,
    required this.expiresAt,
  });

  final String token;
  final String username;
  final UserRole role;
  final DateTime expiresAt;

  bool get isExpired => !DateTime.now().isBefore(expiresAt);

  bool get isManager => role == UserRole.manager;

  Map<String, Object> toJson() {
    return {
      'token': token,
      'username': username,
      'role': role.apiValue,
      'expiresAt': expiresAt.millisecondsSinceEpoch,
    };
  }

  static Session? fromJson(Object? json) {
    if (json case {
      'token': final String token,
      'username': final String username,
      'role': final String roleValue,
      'expiresAt': final int expiresAt,
    }) {
      final role = UserRole.fromApiValue(roleValue);
      if (role == null) return null;

      return Session(
        token: token,
        username: username,
        role: role,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAt),
      );
    }
    return null;
  }
}
