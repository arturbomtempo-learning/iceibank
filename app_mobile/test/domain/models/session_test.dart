import 'package:flutter_test/flutter_test.dart';
import 'package:iceibank/domain/models/session.dart';
import 'package:iceibank/domain/models/user_role.dart';

void main() {
  group('Session', () {
    final session = Session(
      token: 'token-de-teste',
      username: 'admin',
      role: UserRole.manager,
      expiresAt: DateTime(2030, 1, 1, 12),
    );

    test('converte para JSON e volta sem perder dados', () {
      final restored = Session.fromJson(session.toJson());

      expect(restored, isNotNull);
      expect(restored!.token, session.token);
      expect(restored.username, session.username);
      expect(restored.role, UserRole.manager);
      expect(restored.expiresAt, session.expiresAt);
    });

    test('recusa JSON incompleto ou com papel desconhecido', () {
      expect(Session.fromJson({'token': 'abc'}), isNull);
      expect(Session.fromJson({...session.toJson(), 'role': 'hacker'}), isNull);
      expect(Session.fromJson('texto qualquer'), isNull);
    });

    test('identifica uma sessão expirada', () {
      final expired = Session(
        token: 'token',
        username: 'ana',
        role: UserRole.customer,
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      expect(expired.isExpired, isTrue);
      expect(session.isExpired, isFalse);
    });
  });
}
