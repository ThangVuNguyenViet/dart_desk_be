import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('Multi-tenancy isolation', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    group('document isolation', () {
      test(
        'client A documents not visible to client B',
        () async {
          // Create two clients
          final clientA = await factory.createTestClient(
            name: 'Client A',
            slug: 'client-a',
          );
          final clientB = await factory.createTestClient(
            name: 'Client B',
            slug: 'client-b',
          );

          // Create users for each client
          final authedA = factory.authenticatedSession(
            userIdentifier: 'user-a',
          );
          final authedB = factory.authenticatedSession(
            userIdentifier: 'user-b',
          );
          await endpoints.user.ensureUser(authedA, 'client-a', clientA.apiToken);
          await endpoints.user.ensureUser(authedB, 'client-b', clientB.apiToken);

          // Client A creates a document
          final docA = await endpoints.document.createDocument(
            authedA,
            'blog',
            'Client A Secret',
            {'content': 'private'},
            isDefault: false,
          );

          // Client B should not see Client A's documents
          final listB = await endpoints.document.getDocuments(
            authedB,
            'blog',
            limit: 100,
            offset: 0,
          );

          expect(
            listB.documents.any((d) => d.id == docA.id),
            isFalse,
            reason: 'Client B should not see Client A documents',
          );
        },
      );

      test(
        'client A cannot update client B documents',
        () async {
          final clientA = await factory.createTestClient(slug: 'iso-update-a');
          final clientB = await factory.createTestClient(slug: 'iso-update-b');

          final authedA = factory.authenticatedSession(userIdentifier: 'u-upd-a');
          final authedB = factory.authenticatedSession(userIdentifier: 'u-upd-b');
          await endpoints.user.ensureUser(authedA, 'iso-update-a', clientA.apiToken);
          await endpoints.user.ensureUser(authedB, 'iso-update-b', clientB.apiToken);

          // Client A creates a document
          final docA = await endpoints.document.createDocument(
            authedA, 'blog', 'A Private Doc', {},
            isDefault: false,
          );

          // Client B tries to update Client A's document
          expect(
            () => endpoints.document.updateDocument(
              authedB, docA.id!, title: 'Hacked',
            ),
            throwsA(isA<Exception>()),
          );
        },
      );

      test(
        'client A cannot delete client B documents',
        () async {
          final clientA = await factory.createTestClient(slug: 'iso-del-a');
          final clientB = await factory.createTestClient(slug: 'iso-del-b');

          final authedA = factory.authenticatedSession(userIdentifier: 'u-del-a');
          final authedB = factory.authenticatedSession(userIdentifier: 'u-del-b');
          await endpoints.user.ensureUser(authedA, 'iso-del-a', clientA.apiToken);
          await endpoints.user.ensureUser(authedB, 'iso-del-b', clientB.apiToken);

          final docA = await endpoints.document.createDocument(
            authedA, 'blog', 'A Secret Doc', {},
            isDefault: false,
          );

          // Client B tries to delete Client A's document
          expect(
            () => endpoints.document.deleteDocument(authedB, docA.id!),
            throwsA(isA<Exception>()),
          );
        },
      );

      test(
        'same slug allowed for different clients',
        () async {
          final clientA = await factory.createTestClient(slug: 'slug-a');
          final clientB = await factory.createTestClient(slug: 'slug-b');

          final authedA = factory.authenticatedSession(userIdentifier: 'ua');
          final authedB = factory.authenticatedSession(userIdentifier: 'ub');
          await endpoints.user.ensureUser(authedA, 'slug-a', clientA.apiToken);
          await endpoints.user.ensureUser(authedB, 'slug-b', clientB.apiToken);

          // Both clients create a document with the same slug
          final docA = await endpoints.document.createDocument(
            authedA, 'page', 'Page A', {},
            slug: 'hello', isDefault: false,
          );
          final docB = await endpoints.document.createDocument(
            authedB, 'page', 'Page B', {},
            slug: 'hello', isDefault: false,
          );

          expect(docA.slug, equals('hello'));
          expect(docB.slug, equals('hello'));
        },
      );
    });
  });
}
