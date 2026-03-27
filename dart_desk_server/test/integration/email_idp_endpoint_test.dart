import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('EmailIdpEndpoint', (sessionBuilder, endpoints) {
    Future<void> seedGoogleAccount(String email) async {
      final session = sessionBuilder.build();

      // Insert a minimal AuthUser to satisfy GoogleAccount FK
      final authUser = await AuthUser.db.insertRow(
        session,
        AuthUser(scopeNames: {}),
      );

      await GoogleAccount.db.insertRow(
        session,
        GoogleAccount(
          authUserId: authUser.id!,
          userIdentifier: 'google-uid-${email.hashCode}',
          email: email.toLowerCase(),
        ),
      );
    }

    group('startRegistration guard', () {
      test('throws when GoogleAccount exists with same email', () async {
        await seedGoogleAccount('existing@example.com');
        await expectLater(
          () => endpoints.emailIdp.startRegistration(
            sessionBuilder,
            email: 'existing@example.com',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('exception message mentions Google', () async {
        await seedGoogleAccount('google-user@example.com');
        await expectLater(
          () => endpoints.emailIdp.startRegistration(
            sessionBuilder,
            email: 'google-user@example.com',
          ),
          throwsA(
            predicate<dynamic>((e) => e.toString().contains('Google')),
          ),
        );
      });

      test('email comparison is case-insensitive', () async {
        await seedGoogleAccount('camel@example.com');
        await expectLater(
          () => endpoints.emailIdp.startRegistration(
            sessionBuilder,
            email: 'CAMEL@EXAMPLE.COM',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
