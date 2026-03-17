import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('User endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    group('ensureUser', () {
      test('creates user if not exists', () async {
        final client = await factory.createTestClient(slug: 'user-test');
        final authed = factory.authenticatedSession();

        final user = await endpoints.user.ensureUser(
          authed,
          'user-test',
          client.apiToken,
        );

        expect(user.id, isNotNull);
        expect(user.clientId, equals(client.client.id));
      });

      test('returns existing user on second call', () async {
        final client = await factory.createTestClient(slug: 'user-idempotent');
        final authed = factory.authenticatedSession();

        final user1 = await endpoints.user.ensureUser(
          authed, 'user-idempotent', client.apiToken,
        );
        final user2 = await endpoints.user.ensureUser(
          authed, 'user-idempotent', client.apiToken,
        );

        expect(user1.id, equals(user2.id));
      });
    });

    group('getCurrentUser', () {
      test('returns user after ensureUser', () async {
        final client = await factory.createTestClient(slug: 'current-user');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'current-user', client.apiToken);

        final user = await endpoints.user.getCurrentUser(
          authed,
          'current-user',
          client.apiToken,
        );

        expect(user, isNotNull);
      });
    });

    group('getUserClients', () {
      test('returns clients the user belongs to', () async {
        final client = await factory.createTestClient(slug: 'user-clients');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'user-clients', client.apiToken);

        final clients = await endpoints.user.getUserClients(authed);

        expect(clients, isNotEmpty);
        expect(
          clients.any((c) => c.slug == 'user-clients'),
          isTrue,
        );
      });
    });

    group('user association with documents', () {
      test('document tracks createdByUserId', () async {
        final client = await factory.createTestClient(slug: 'user-doc-assoc');
        final authed = factory.authenticatedSession();
        final user = await endpoints.user.ensureUser(
          authed, 'user-doc-assoc', client.apiToken,
        );

        final doc = await endpoints.document.createDocument(
          authed, 'assoc_test', 'User Assoc Doc', {},
          isDefault: false,
        );

        expect(doc.createdByUserId, equals(user.id));
      });
    });
  });
}
