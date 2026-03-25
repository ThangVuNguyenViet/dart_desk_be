import 'package:dart_desk_server/src/auth/resolve_user.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('resolveUser', (sessionBuilder, endpoints) {
    test('first user becomes admin', () async {
      final session = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'user-1',
              {},
            ),
          )
          .build();

      final user = await resolveUser(session);
      expect(user.role, equals('admin'));
      expect(user.serverpodUserId, equals('user-1'));
    });

    test('second user becomes viewer', () async {
      // Create first user (admin)
      final session1 = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'user-1',
              {},
            ),
          )
          .build();
      await resolveUser(session1);

      // Create second user (viewer)
      final session2 = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'user-2',
              {},
            ),
          )
          .build();
      final user2 = await resolveUser(session2);
      expect(user2.role, equals('viewer'));
    });

    test('returns existing user on repeated calls', () async {
      final session = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'user-1',
              {},
            ),
          )
          .build();

      final user1 = await resolveUser(session);
      final user2 = await resolveUser(session);
      expect(user1.id, equals(user2.id));
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
