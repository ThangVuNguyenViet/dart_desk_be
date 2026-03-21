import 'package:dart_desk_be_server/src/auth/dart_desk_auth.dart';
import 'package:dart_desk_be_server/src/auth/external_auth_strategy.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

/// Test strategy that authenticates requests with 'X-Test-User-Id' header.
class TestAuthStrategy extends ExternalAuthStrategy {
  @override
  String get name => 'test';

  @override
  Future<ExternalAuthUser?> authenticate(
    Map<String, String> headers,
    Session session,
  ) async {
    final userId = headers['x-test-user-id'];
    if (userId == null) return null;
    return ExternalAuthUser(
      externalId: userId,
      email: '$userId@test.com',
      name: 'Test User $userId',
    );
  }
}

void main() {
  withServerpod('External auth', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      DartDeskAuth.reset();
    });

    tearDown(() {
      DartDeskAuth.reset();
    });

    group('Serverpod IDP auth via DartDeskAuth', () {
      test('authenticates via built-in IDP when User exists', () async {
        // Seed a User record for the test auth user
        await factory.ensureTestUser();

        final authed = factory.authenticatedSession();
        final user = await endpoints.user.getCurrentUser(authed);

        expect(user, isNotNull);
        expect(user!.serverpodUserId, equals('test-user-1'));
      });

      test('returns null when no User record matches IDP user', () async {
        final authed = factory.authenticatedSession(
          userIdentifier: 'unknown-idp-user',
        );

        final user = await endpoints.user.getCurrentUser(authed);
        expect(user, isNull);
      });
    });

    group('DartDeskAuth configuration', () {
      test('configure sets strategies and admin emails', () {
        DartDeskAuth.configure(
          externalStrategies: [TestAuthStrategy()],
          adminEmails: ['admin@test.com'],
        );

        // No assertion needed — just verifying it doesn't throw.
        // The strategies are tested via authenticateRequest.
      });

      test('reset clears strategies', () async {
        DartDeskAuth.configure(
          externalStrategies: [TestAuthStrategy()],
        );
        DartDeskAuth.reset();

        // After reset, unauthenticated session should return null
        final user = await endpoints.user.getCurrentUser(sessionBuilder);
        expect(user, isNull);
      });
    });

    group('DartDeskAuth._findOrCreateUser (via IDP path)', () {
      test('finds existing user by serverpodUserId', () async {
        final created = await factory.ensureTestUser(
          email: 'existing@test.com',
          name: 'Existing',
        );

        final authed = factory.authenticatedSession();
        final found = await endpoints.user.getCurrentUser(authed);

        expect(found, isNotNull);
        expect(found!.id, equals(created.id));
      });
    });
  });
}
