import 'package:dart_desk_server/src/auth/auth_user_resolver.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('findAuthUserIdByEmail', (sessionBuilder, endpoints) {
    test('returns null when no AuthUser exists for the email', () async {
      final session = sessionBuilder.build();
      final result = await findAuthUserIdByEmail(session, 'nobody@example.com');
      expect(result, isNull);
    });

    test('returns the AuthUser id for an email-IDP account', () async {
      final session = sessionBuilder.build();

      // Seed an AuthUser + EmailAccount directly.
      final authUser = await AuthUser.db.insertRow(
        session,
        AuthUser(scopeNames: {}),
      );

      await EmailAccount.db.insertRow(
        session,
        EmailAccount(
          authUserId: authUser.id!,
          email: 'email-user@example.com',
          passwordHash: r'$argon2id$v=19$m=65536,t=3,p=4$placeholder$hash',
        ),
      );

      final result =
          await findAuthUserIdByEmail(session, 'email-user@example.com');
      expect(result, equals(authUser.id));
    });

    test('returns the AuthUser id for a Google-only account', () async {
      final session = sessionBuilder.build();

      // Seed an AuthUser + GoogleAccount directly (no real OAuth needed).
      final authUser = await AuthUser.db.insertRow(
        session,
        AuthUser(scopeNames: {}),
      );

      await GoogleAccount.db.insertRow(
        session,
        GoogleAccount(
          authUserId: authUser.id!,
          email: 'google-user@example.com',
          userIdentifier: 'google-sub-12345',
        ),
      );

      final result =
          await findAuthUserIdByEmail(session, 'google-user@example.com');
      expect(result, equals(authUser.id));
    });

    test('email matching is case-insensitive', () async {
      final session = sessionBuilder.build();

      // Register with mixed-case; look up with lower-case.
      final authUser = await AuthUser.db.insertRow(
        session,
        AuthUser(scopeNames: {}),
      );

      await EmailAccount.db.insertRow(
        session,
        EmailAccount(
          authUserId: authUser.id!,
          // Both IDPs normalise to lower-case before storing.
          email: 'foo@bar.co',
          passwordHash: r'$argon2id$v=19$m=65536,t=3,p=4$placeholder$hash',
        ),
      );

      // Look up with the mixed-case original — helper should normalise.
      final result = await findAuthUserIdByEmail(session, 'Foo@Bar.co');
      expect(result, equals(authUser.id));
    });
  });
}
