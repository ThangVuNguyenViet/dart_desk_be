import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('CmsClient endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    group('createClient', () {
      test('creates client and returns token', () async {
        final result = await factory.createTestClient(
          name: 'Acme Corp',
          slug: 'acme-corp',
        );

        expect(result.client.id, isNotNull);
        expect(result.client.name, equals('Acme Corp'));
        expect(result.client.slug, equals('acme-corp'));
        expect(result.apiToken, startsWith('cms_live_'));
      });

      test('rejects reserved slugs', () async {
        final authed = factory.authenticatedSession();
        expect(
          () => endpoints.cmsClient.createClient(authed, 'Login', 'login'),
          throwsA(isA<Exception>()),
        );
      });

      test('rejects invalid slug format', () async {
        final authed = factory.authenticatedSession();
        expect(
          () => endpoints.cmsClient.createClient(authed, 'Bad', 'AB'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getClient', () {
      test('returns client by ID', () async {
        final created = await factory.createTestClient(slug: 'get-test');
        final fetched = await endpoints.cmsClient.getClient(
          sessionBuilder,
          created.client.id!,
        );
        expect(fetched, isNotNull);
        expect(fetched!.slug, equals('get-test'));
      });
    });

    group('getClientBySlug', () {
      test('returns client by slug', () async {
        await factory.createTestClient(slug: 'slug-lookup');
        final fetched = await endpoints.cmsClient.getClientBySlug(
          sessionBuilder,
          'slug-lookup',
        );
        expect(fetched, isNotNull);
        expect(fetched!.slug, equals('slug-lookup'));
      });
    });

    group('updateClient', () {
      test('updates client name', () async {
        final created = await factory.createTestClient(
          name: 'Old Name',
          slug: 'update-test',
        );
        final authed = factory.authenticatedSession();
        final updated = await endpoints.cmsClient.updateClient(
          authed,
          created.client.id!,
          name: 'New Name',
        );
        expect(updated!.name, equals('New Name'));
      });

      test('deactivates client', () async {
        final created = await factory.createTestClient(slug: 'deactivate-test');
        final authed = factory.authenticatedSession();
        final updated = await endpoints.cmsClient.updateClient(
          authed,
          created.client.id!,
          isActive: false,
        );
        expect(updated!.isActive, isFalse);
      });
    });

    group('deleteClient', () {
      test('deletes client', () async {
        final created = await factory.createTestClient(slug: 'delete-test');
        final authed = factory.authenticatedSession();
        final result = await endpoints.cmsClient.deleteClient(
          authed,
          created.client.id!,
        );
        expect(result, isTrue);
      });
    });
  });
}
