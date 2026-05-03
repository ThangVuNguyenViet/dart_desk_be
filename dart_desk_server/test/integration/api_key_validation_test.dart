import 'package:dart_desk_server/src/auth/api_key_validator.dart';
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('ApiKey validation', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser(role: ClientRole.admin);
    });

    test('created key validates successfully', () async {
      final authed = factory.authenticatedSession();
      final result = await endpoints.apiKey.createKey(
        authed,
        'Valid Key',
        'write',
        null,
        projectId: TestDataFactory.testProjectId,
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        result.plaintextKey,
      );

      expect(context, isNotNull);
      expect(context!.role, equals('write'));
    });

    test('deactivated key fails validation', () async {
      final authed = factory.authenticatedSession();
      final result = await endpoints.apiKey.createKey(
        authed,
        'Deactivated',
        'read',
        null,
        projectId: TestDataFactory.testProjectId,
      );

      await endpoints.apiKey.updateKey(
        authed,
        result.apiKey.id,
        null,
        false,
        null,
        projectId: TestDataFactory.testProjectId,
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        result.plaintextKey,
      );

      expect(context, isNull);
    });

    test('regenerated key invalidates old, validates new', () async {
      final authed = factory.authenticatedSession();
      final original = await endpoints.apiKey.createKey(
        authed,
        'Regen',
        'write',
        null,
        projectId: TestDataFactory.testProjectId,
      );
      final oldKey = original.plaintextKey;

      final regenerated = await endpoints.apiKey.regenerateKey(
        authed,
        original.apiKey.id,
        projectId: TestDataFactory.testProjectId,
      );

      final session = sessionBuilder.build();

      // Old key fails
      expect(
        await ApiKeyValidator.validate(session, oldKey),
        isNull,
      );

      // New key works
      final context = await ApiKeyValidator.validate(
        session,
        regenerated.plaintextKey,
      );
      expect(context, isNotNull);
      expect(context!.role, equals('write'));
    });

    test('deleted key fails validation', () async {
      final authed = factory.authenticatedSession();
      final result = await endpoints.apiKey.createKey(
        authed,
        'Deleted',
        'read',
        null,
        projectId: TestDataFactory.testProjectId,
      );
      final key = result.plaintextKey;

      await endpoints.apiKey.deleteKey(
        authed,
        result.apiKey.id,
        projectId: TestDataFactory.testProjectId,
      );

      final session = sessionBuilder.build();
      expect(
        await ApiKeyValidator.validate(session, key),
        isNull,
      );
    });

    test('garbage key fails validation', () async {
      final session = sessionBuilder.build();
      expect(await ApiKeyValidator.validate(session, 'not-a-token'), isNull);
      expect(await ApiKeyValidator.validate(session, ''), isNull);
      expect(await ApiKeyValidator.validate(session, 'cms_r_fake'), isNull);
    });
  });
}
