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
      test('creates read token with correct prefix', () async {
        final authed = factory.authenticatedSession();

        final tokenResult = await endpoints.apiToken.createToken(
          authed, 'Read Token', 'read', null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_r_'));
        expect(tokenResult.token.name, equals('Read Token'));
        expect(tokenResult.token.role, equals('read'));
      });

      test('creates write token with correct prefix', () async {
        final authed = factory.authenticatedSession();

        final tokenResult = await endpoints.apiToken.createToken(
          authed, 'Write Token', 'write', null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_w_'));
        expect(tokenResult.token.role, equals('write'));
      });

      test('rejects invalid role', () async {
        final authed = factory.authenticatedSession();

        expect(
          () => endpoints.apiToken.createToken(
            authed, 'Bad Token', 'admin', null,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getTokens', () {
      test('lists tokens', () async {
        final authed = factory.authenticatedSession();

        await endpoints.apiToken.createToken(authed, 'Token A', 'read', null);
        await endpoints.apiToken.createToken(authed, 'Token B', 'write', null);

        final tokens = await endpoints.apiToken.getTokens(authed);
        expect(tokens.length, equals(2));
      });
    });

    group('updateToken', () {
      test('updates token name', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiToken.createToken(
          authed, 'Original Name', 'read', null,
        );

        final updated = await endpoints.apiToken.updateToken(
          authed, created.token.id!, 'Updated Name', null, null,
        );

        expect(updated.name, equals('Updated Name'));
      });

      test('deactivates token', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiToken.createToken(
          authed, 'Active Token', 'write', null,
        );

        final updated = await endpoints.apiToken.updateToken(
          authed, created.token.id!, null, false, null,
        );

        expect(updated.isActive, isFalse);
      });
    });

    group('regenerateToken', () {
      test('returns new token value with same role prefix', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiToken.createToken(
          authed, 'Regen Token', 'write', null,
        );
        final originalToken = created.plaintextToken;

        final regenerated = await endpoints.apiToken.regenerateToken(
          authed, created.token.id!,
        );

        expect(regenerated.plaintextToken, startsWith('cms_w_'));
        expect(regenerated.plaintextToken, isNot(equals(originalToken)));
        expect(regenerated.token.id, equals(created.token.id));
      });
    });

    group('deleteToken', () {
      test('deletes a token', () async {
        final authed = factory.authenticatedSession();

        final tokenResult = await endpoints.apiToken.createToken(
          authed, 'Temp Token', 'read', null,
        );

        final deleted = await endpoints.apiToken.deleteToken(
          authed, tokenResult.token.id!,
        );
        expect(deleted, isTrue);
      });
    });
  });
}
