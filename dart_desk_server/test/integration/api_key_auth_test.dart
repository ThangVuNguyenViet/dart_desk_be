import 'package:dart_desk_server/src/auth/api_key_validator.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('API key validation', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    test('validates a created write token', () async {
      final authed = factory.authenticatedSession();

      final tokenResult = await endpoints.apiToken.createToken(
        authed, 'Test Write Token', 'write', null,
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        tokenResult.plaintextToken,
      );

      expect(context, isNotNull);
      expect(context!.role, equals('write'));
      expect(context.canWrite, isTrue);
    });

    test('validates a created read token', () async {
      final authed = factory.authenticatedSession();

      final tokenResult = await endpoints.apiToken.createToken(
        authed, 'Test Read Token', 'read', null,
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        tokenResult.plaintextToken,
      );

      expect(context, isNotNull);
      expect(context!.role, equals('read'));
      expect(context.canWrite, isFalse);
      expect(context.canRead, isTrue);
    });

    test('rejects invalid token', () async {
      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        'cms_w_this_is_not_a_valid_token_at_all_xxxxx',
      );

      expect(context, isNull);
    });

    test('rejects deactivated token', () async {
      final authed = factory.authenticatedSession();

      final tokenResult = await endpoints.apiToken.createToken(
        authed, 'Deactivated Token', 'read', null,
      );

      await endpoints.apiToken.updateToken(
        authed, tokenResult.token.id!, null, false, null,
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        tokenResult.plaintextToken,
      );

      expect(context, isNull);
    });

    test('rejects expired token', () async {
      final authed = factory.authenticatedSession();

      // Create token with expiry in the past
      final tokenResult = await endpoints.apiToken.createToken(
        authed,
        'Expired Token',
        'write',
        DateTime.now().subtract(Duration(hours: 1)),
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        tokenResult.plaintextToken,
      );

      expect(context, isNull);
    });
  });
}
