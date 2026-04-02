import 'dart:convert';

import 'package:test/test.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('MigrationEndpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    group('listMigrations', () {
      test('returns empty list when no migrations applied', () async {
        final authed = factory.authenticatedSession();
        final migrations = await endpoints.migration.listMigrations(authed);
        expect(migrations, isEmpty);
      });

      test('returns applied migrations after a real run', () async {
        await factory.createTestDocument(
          documentType: 'article',
          title: 'Doc A',
          data: {'oldField': 'hello'},
          slug: 'list-mig-doc-a',
        );

        final authed = factory.authenticatedSession();
        final ops = jsonEncode([
          {'type': 'renameField', 'from': 'oldField', 'to': 'newField'},
        ]);

        await endpoints.migration.runMigration(
          authed,
          'List Test Migration',
          'article',
          ops,
          false,
        );

        final migrations = await endpoints.migration.listMigrations(authed);
        expect(migrations, hasLength(1));
        expect(migrations.first.name, equals('List Test Migration'));
        expect(migrations.first.documentType, equals('article'));
      });
    });

    group('runMigration dry-run', () {
      test('returns report without modifying data', () async {
        final doc = await factory.createTestDocument(
          documentType: 'blog_post',
          title: 'Dry Run Doc',
          data: {'oldField': 'original'},
          slug: 'dry-run-doc',
        );

        final authed = factory.authenticatedSession();
        final ops = jsonEncode([
          {'type': 'renameField', 'from': 'oldField', 'to': 'newField'},
        ]);

        final reportJson = await endpoints.migration.runMigration(
          authed,
          'Dry Run Migration',
          'blog_post',
          ops,
          true,
        );

        final report = jsonDecode(reportJson) as Map<String, dynamic>;
        expect(report['dryRun'], isTrue);
        expect(report['modified'], equals(1));
        expect(report['skipped'], equals(0));

        // Verify original data is unchanged
        final unchanged = await endpoints.document.getDocument(
          authed,
          doc.id!,
        );
        expect(unchanged, isNotNull);
        final data = jsonDecode(unchanged!.data!) as Map<String, dynamic>;
        expect(data.containsKey('oldField'), isTrue);
        expect(data.containsKey('newField'), isFalse);
      });

      test('does not record migration history on dry run', () async {
        await factory.createTestDocument(
          documentType: 'blog_post',
          title: 'History Check Doc',
          data: {'field': 'value'},
          slug: 'history-check-doc',
        );

        final authed = factory.authenticatedSession();
        final ops = jsonEncode([
          {'type': 'setField', 'path': 'added', 'value': 'new'},
        ]);

        await endpoints.migration.runMigration(
          authed,
          'No History Migration',
          'blog_post',
          ops,
          true,
        );

        final migrations = await endpoints.migration.listMigrations(authed);
        expect(
          migrations.where((m) => m.name == 'No History Migration'),
          isEmpty,
        );
      });
    });

    group('runMigration real run', () {
      test('modifies documents and records history', () async {
        await factory.createTestDocument(
          documentType: 'page',
          title: 'Real Run Doc',
          data: {'oldName': 'foo'},
          slug: 'real-run-doc',
        );

        final authed = factory.authenticatedSession();
        final ops = jsonEncode([
          {'type': 'renameField', 'from': 'oldName', 'to': 'newName'},
        ]);

        final reportJson = await endpoints.migration.runMigration(
          authed,
          'Real Run Migration',
          'page',
          ops,
          false,
        );

        final report = jsonDecode(reportJson) as Map<String, dynamic>;
        expect(report['dryRun'], isFalse);
        expect(report['modified'], equals(1));

        final migrations = await endpoints.migration.listMigrations(authed);
        expect(migrations.any((m) => m.name == 'Real Run Migration'), isTrue);
      });

      test('prevents duplicate migration', () async {
        await factory.createTestDocument(
          documentType: 'page',
          title: 'Dup Doc',
          data: {'field': 'val'},
          slug: 'dup-doc',
        );

        final authed = factory.authenticatedSession();
        final ops = jsonEncode([
          {'type': 'setField', 'path': 'extra', 'value': 1},
        ]);

        await endpoints.migration.runMigration(
          authed,
          'Duplicate Migration',
          'page',
          ops,
          false,
        );

        expect(
          () => endpoints.migration.runMigration(
            authed,
            'Duplicate Migration',
            'page',
            ops,
            false,
          ),
          throwsA(anything),
        );
      });
    });

    group('runMigration field operations', () {
      test('skips documents without matching fields', () async {
        await factory.createTestDocument(
          documentType: 'post',
          title: 'Has Old Field',
          data: {'targetField': 'value'},
          slug: 'has-old-field',
        );

        await factory.createTestDocument(
          documentType: 'post',
          title: 'No Old Field',
          data: {'otherField': 'value'},
          slug: 'no-old-field',
        );

        final authed = factory.authenticatedSession();
        final ops = jsonEncode([
          {'type': 'deleteField', 'path': 'targetField'},
        ]);

        final reportJson = await endpoints.migration.runMigration(
          authed,
          'Skip Test Migration',
          'post',
          ops,
          true,
        );

        final report = jsonDecode(reportJson) as Map<String, dynamic>;
        expect(report['modified'], equals(1));
        expect(report['skipped'], equals(1));
      });

      test('deleteField removes field from document', () async {
        final doc = await factory.createTestDocument(
          documentType: 'widget',
          title: 'Delete Field Doc',
          data: {'keepField': 'keep', 'dropField': 'drop'},
          slug: 'delete-field-doc',
        );

        final authed = factory.authenticatedSession();
        final ops = jsonEncode([
          {'type': 'deleteField', 'path': 'dropField'},
        ]);

        await endpoints.migration.runMigration(
          authed,
          'Delete Field Migration',
          'widget',
          ops,
          false,
        );

        final updated = await endpoints.document.getDocument(authed, doc.id!);
        expect(updated, isNotNull);
        final data = jsonDecode(updated!.data!) as Map<String, dynamic>;
        expect(data.containsKey('dropField'), isFalse);
        expect(data.containsKey('keepField'), isTrue);
      });

      test('setField adds a new field to document', () async {
        final doc = await factory.createTestDocument(
          documentType: 'widget',
          title: 'Set Field Doc',
          data: {'existingField': 'existing'},
          slug: 'set-field-doc',
        );

        final authed = factory.authenticatedSession();
        final ops = jsonEncode([
          {'type': 'setField', 'path': 'newField', 'value': 'added'},
        ]);

        await endpoints.migration.runMigration(
          authed,
          'Set Field Migration',
          'widget',
          ops,
          false,
        );

        final updated = await endpoints.document.getDocument(authed, doc.id!);
        expect(updated, isNotNull);
        final data = jsonDecode(updated!.data!) as Map<String, dynamic>;
        expect(data['newField'], equals('added'));
        expect(data['existingField'], equals('existing'));
      });
    });
  });
}
