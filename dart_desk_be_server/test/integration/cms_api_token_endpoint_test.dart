import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('CmsApiToken endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
    });

    group('createToken', () {
      test('creates viewer token with correct prefix', () async {
        final client = await factory.createTestClient(slug: 'token-test');
        final authed = factory.authenticatedSession();

        // ensureUser first so the authed user belongs to this client
        await endpoints.user.ensureUser(
          authed,
          'token-test',
          client.apiToken,
        );

        final tokenResult = await endpoints.cmsApiToken.createToken(
          authed,
          client.client.id!,
          'Viewer Token',
          'viewer',
          null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_vi_'));
        expect(tokenResult.token.name, equals('Viewer Token'));
        expect(tokenResult.token.role, equals('viewer'));
      });

      test('creates editor token with correct prefix', () async {
        final client = await factory.createTestClient(slug: 'editor-token');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'editor-token', client.apiToken);

        final tokenResult = await endpoints.cmsApiToken.createToken(
          authed,
          client.client.id!,
          'Editor Token',
          'editor',
          null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_ed_'));
      });

      test('creates admin token with correct prefix', () async {
        final client = await factory.createTestClient(slug: 'admin-token');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'admin-token', client.apiToken);

        final tokenResult = await endpoints.cmsApiToken.createToken(
          authed,
          client.client.id!,
          'Admin Token',
          'admin',
          null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_ad_'));
      });
    });

    group('getTokens', () {
      test('lists tokens for a client', () async {
        final client = await factory.createTestClient(slug: 'list-tokens');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'list-tokens', client.apiToken);

        await endpoints.cmsApiToken.createToken(
          authed, client.client.id!, 'Token A', 'viewer', null,
        );
        await endpoints.cmsApiToken.createToken(
          authed, client.client.id!, 'Token B', 'editor', null,
        );

        final tokens = await endpoints.cmsApiToken.getTokens(
          authed,
          client.client.id!,
        );

        expect(tokens.length, equals(2));
      });
    });

    group('deleteToken', () {
      test('deletes a token', () async {
        final client = await factory.createTestClient(slug: 'del-token');
        final authed = factory.authenticatedSession();
        await endpoints.user.ensureUser(authed, 'del-token', client.apiToken);

        final tokenResult = await endpoints.cmsApiToken.createToken(
          authed, client.client.id!, 'Temp Token', 'viewer', null,
        );

        final deleted = await endpoints.cmsApiToken.deleteToken(
          authed,
          tokenResult.token.id!,
        );
        expect(deleted, isTrue);
      });
    });

    group('token validation', () {
      test('invalid API token is rejected by ensureUser', () async {
        await factory.createTestClient(slug: 'bad-token');
        final authed = factory.authenticatedSession();

        expect(
          () => endpoints.user.ensureUser(authed, 'bad-token', 'invalid_token_xyz'),
          throwsA(isA<Exception>()),
        );
      });

      test(
        'token for Client A cannot access Client B',
        () async {
          final clientA = await factory.createTestClient(slug: 'token-scope-a');
          final clientB = await factory.createTestClient(slug: 'token-scope-b');
          final authed = factory.authenticatedSession();

          // User belongs to Client A
          await endpoints.user.ensureUser(authed, 'token-scope-a', clientA.apiToken);

          // Attempt to create token for Client B should fail
          // (user does not belong to Client B)
          expect(
            () => endpoints.cmsApiToken.createToken(
              authed, clientB.client.id!, 'Cross Token', 'viewer', null,
            ),
            throwsA(isA<Exception>()),
          );
        },
      );
    });
  });
}
