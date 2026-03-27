import 'package:dart_desk_server/src/auth/api_key_validator.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('ApiToken validation', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    test('created token validates successfully', () async {
      final authed = factory.authenticatedSession();
      final result = await endpoints.apiToken.createToken(
        authed, 'Valid Token', 'write', null,
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        result.plaintextToken,
      );

      expect(context, isNotNull);
      expect(context!.role, equals('write'));
    });

    test('deactivated token fails validation', () async {
      final authed = factory.authenticatedSession();
      final result = await endpoints.apiToken.createToken(
        authed, 'Deactivated', 'read', null,
      );

      await endpoints.apiToken.updateToken(
        authed, result.token.id!, null, false, null,
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        result.plaintextToken,
      );

      expect(context, isNull);
    });

    test('regenerated token invalidates old, validates new', () async {
      final authed = factory.authenticatedSession();
      final original = await endpoints.apiToken.createToken(
        authed, 'Regen', 'write', null,
      );
      final oldToken = original.plaintextToken;

      final regenerated = await endpoints.apiToken.regenerateToken(
        authed, original.token.id!,
      );

      final session = sessionBuilder.build();

      // Old token fails
      expect(
        await ApiKeyValidator.validate(session, oldToken),
        isNull,
      );

      // New token works
      final context = await ApiKeyValidator.validate(
        session,
        regenerated.plaintextToken,
      );
      expect(context, isNotNull);
      expect(context!.role, equals('write'));
    });

    test('deleted token fails validation', () async {
      final authed = factory.authenticatedSession();
      final result = await endpoints.apiToken.createToken(
        authed, 'Deleted', 'read', null,
      );
      final token = result.plaintextToken;

      await endpoints.apiToken.deleteToken(authed, result.token.id!);

      final session = sessionBuilder.build();
      expect(
        await ApiKeyValidator.validate(session, token),
        isNull,
      );
    });

    test('garbage token fails validation', () async {
      final session = sessionBuilder.build();
      expect(await ApiKeyValidator.validate(session, 'not-a-token'), isNull);
      expect(await ApiKeyValidator.validate(session, ''), isNull);
      expect(await ApiKeyValidator.validate(session, 'cms_r_fake'), isNull);
    });
  });
}
