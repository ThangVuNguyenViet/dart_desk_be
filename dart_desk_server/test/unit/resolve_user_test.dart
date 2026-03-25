import 'package:dart_desk_server/src/auth/resolve_user.dart';
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('resolveUser', (sessionBuilder, endpoints) {
    test('returns existing user by serverpodUserId', () async {
      final session = sessionBuilder.build();
      await User.db.insertRow(
        session,
        User(
          clientId: null,
          email: 'test@example.com',
          name: 'Test',
          role: 'admin',
          isActive: true,
          serverpodUserId: 'user-1',
        ),
      );

      final authed = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'user-1',
              {},
            ),
          )
          .build();

      final user = await resolveUser(authed);
      expect(user.email, equals('test@example.com'));
      expect(user.role, equals('admin'));
    });

    test('throws when user record does not exist', () async {
      final session = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'nonexistent-user',
              {},
            ),
          )
          .build();

      expect(
        () => resolveUser(session),
        throwsA(isA<Exception>()),
      );
    });

    test('throws when not authenticated', () async {
      final session = sessionBuilder.build();
      expect(
        () => resolveUser(session),
        throwsA(isA<Exception>()),
      );
    });
  });
}
