import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('ApiToken endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    group('createToken', () {
      test('creates viewer token with correct prefix', () async {
        final authed = factory.authenticatedSession();

        final tokenResult = await endpoints.apiToken.createToken(
          authed, 'Viewer Token', 'viewer', null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_vi_'));
        expect(tokenResult.token.name, equals('Viewer Token'));
        expect(tokenResult.token.role, equals('viewer'));
      });

      test('creates editor token with correct prefix', () async {
        final authed = factory.authenticatedSession();

        final tokenResult = await endpoints.apiToken.createToken(
          authed, 'Editor Token', 'editor', null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_ed_'));
      });

      test('creates admin token with correct prefix', () async {
        final authed = factory.authenticatedSession();

        final tokenResult = await endpoints.apiToken.createToken(
          authed, 'Admin Token', 'admin', null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_ad_'));
      });
    });

    group('getTokens', () {
      test('lists tokens', () async {
        final authed = factory.authenticatedSession();

        await endpoints.apiToken.createToken(
          authed, 'Token A', 'viewer', null,
        );
        await endpoints.apiToken.createToken(
          authed, 'Token B', 'editor', null,
        );

        final tokens = await endpoints.apiToken.getTokens(authed);

        expect(tokens.length, equals(2));
      });
    });

    group('updateToken', () {
      test('updates token name', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiToken.createToken(
          authed, 'Original Name', 'viewer', null,
        );

        final updated = await endpoints.apiToken.updateToken(
          authed,
          created.token.id!,
          'Updated Name',
          null,
          null,
        );

        expect(updated.name, equals('Updated Name'));
      });

      test('deactivates token', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiToken.createToken(
          authed, 'Active Token', 'editor', null,
        );

        final updated = await endpoints.apiToken.updateToken(
          authed,
          created.token.id!,
          null,
          false,
          null,
        );

        expect(updated.isActive, isFalse);
      });
    });

    group('regenerateToken', () {
      test('returns new token value with same role prefix', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiToken.createToken(
          authed, 'Regen Token', 'admin', null,
        );
        final originalToken = created.plaintextToken;

        final regenerated = await endpoints.apiToken.regenerateToken(
          authed,
          created.token.id!,
        );

        expect(regenerated.plaintextToken, startsWith('cms_ad_'));
        expect(regenerated.plaintextToken, isNot(equals(originalToken)));
        expect(regenerated.token.id, equals(created.token.id));
      });
    });

    group('deleteToken', () {
      test('deletes a token', () async {
        final authed = factory.authenticatedSession();

        final tokenResult = await endpoints.apiToken.createToken(
          authed, 'Temp Token', 'viewer', null,
        );

        final deleted = await endpoints.apiToken.deleteToken(
          authed,
          tokenResult.token.id!,
        );
        expect(deleted, isTrue);
      });
    });
  });
}
