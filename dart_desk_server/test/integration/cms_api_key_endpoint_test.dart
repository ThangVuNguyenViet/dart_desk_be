import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('ApiKey endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser(role: ClientRole.admin);
    });

    group('createKey', () {
      test('creates read key with correct prefix', () async {
        final authed = factory.authenticatedSession();

        final keyResult = await endpoints.apiKey.createKey(
          authed,
          'Read Key',
          'read',
          null,
          projectId: TestDataFactory.testProjectId,
        );

        expect(keyResult.plaintextKey, startsWith('cms_r_'));
        expect(keyResult.apiKey.name, equals('Read Key'));
        expect(keyResult.apiKey.role, equals('read'));
      });

      test('creates write key with correct prefix', () async {
        final authed = factory.authenticatedSession();

        final keyResult = await endpoints.apiKey.createKey(
          authed,
          'Write Key',
          'write',
          null,
          projectId: TestDataFactory.testProjectId,
        );

        expect(keyResult.plaintextKey, startsWith('cms_w_'));
        expect(keyResult.apiKey.role, equals('write'));
      });

      test('rejects invalid role', () async {
        final authed = factory.authenticatedSession();

        expect(
          () => endpoints.apiKey.createKey(
            authed,
            'Bad Key',
            'admin',
            null,
            projectId: TestDataFactory.testProjectId,
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getKeys', () {
      test('lists keys', () async {
        final authed = factory.authenticatedSession();

        await endpoints.apiKey.createKey(
          authed,
          'Key A',
          'read',
          null,
          projectId: TestDataFactory.testProjectId,
        );
        await endpoints.apiKey.createKey(
          authed,
          'Key B',
          'write',
          null,
          projectId: TestDataFactory.testProjectId,
        );

        final keys = await endpoints.apiKey.getKeys(
          authed,
          projectId: TestDataFactory.testProjectId,
        );
        expect(keys.length, equals(2));
      });
    });

    group('updateKey', () {
      test('updates key name', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiKey.createKey(
          authed,
          'Original Name',
          'read',
          null,
          projectId: TestDataFactory.testProjectId,
        );

        final updated = await endpoints.apiKey.updateKey(
          authed,
          created.apiKey.id,
          'Updated Name',
          null,
          null,
          projectId: TestDataFactory.testProjectId,
        );

        expect(updated.name, equals('Updated Name'));
      });

      test('deactivates key', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiKey.createKey(
          authed,
          'Active Key',
          'write',
          null,
          projectId: TestDataFactory.testProjectId,
        );

        final updated = await endpoints.apiKey.updateKey(
          authed,
          created.apiKey.id,
          null,
          false,
          null,
          projectId: TestDataFactory.testProjectId,
        );

        expect(updated.isActive, isFalse);
      });
    });

    group('regenerateKey', () {
      test('returns new key value with same role prefix', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiKey.createKey(
          authed,
          'Regen Key',
          'write',
          null,
          projectId: TestDataFactory.testProjectId,
        );
        final originalKey = created.plaintextKey;

        final regenerated = await endpoints.apiKey.regenerateKey(
          authed,
          created.apiKey.id,
          projectId: TestDataFactory.testProjectId,
        );

        expect(regenerated.plaintextKey, startsWith('cms_w_'));
        expect(regenerated.plaintextKey, isNot(equals(originalKey)));
        expect(regenerated.apiKey.id, equals(created.apiKey.id));
      });
    });

    group('deleteKey', () {
      test('deletes a key', () async {
        final authed = factory.authenticatedSession();

        final keyResult = await endpoints.apiKey.createKey(
          authed,
          'Temp Key',
          'read',
          null,
          projectId: TestDataFactory.testProjectId,
        );

        final deleted = await endpoints.apiKey.deleteKey(
          authed,
          keyResult.apiKey.id,
          projectId: TestDataFactory.testProjectId,
        );
        expect(deleted, isTrue);
      });
    });
  });
}
