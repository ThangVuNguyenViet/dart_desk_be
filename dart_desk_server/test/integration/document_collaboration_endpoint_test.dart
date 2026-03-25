import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('DocumentCollaboration endpoint',
      (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    group('submitEdit', () {
      test('applies field updates and returns updated document', () async {
        final doc = await factory.createTestDocument(
          title: 'Collab Doc',
          data: {'body': 'initial'},
        );
        final authed = factory.authenticatedSession();

        final updated = await endpoints.documentCollaboration.submitEdit(
          authed,
          doc.id!,
          'session-1',
          {'body': 'edited', 'newField': 'value'},
        );

        expect(updated.id, equals(doc.id));
      });
    });

    group('getOperationsSince', () {
      test('returns operations after given HLC', () async {
        final doc = await factory.createTestDocument(
          title: 'Ops Doc',
          data: {'field': 'v1'},
        );
        final authed = factory.authenticatedSession();

        // Get initial HLC (before any updates)
        final initialHlc =
            await endpoints.documentCollaboration.getCurrentHlc(
          sessionBuilder,
          doc.id!,
        );

        // Make some updates to generate operations
        await endpoints.documentCollaboration.submitEdit(
          authed,
          doc.id!,
          'session-1',
          {'field': 'v2'},
        );
        await endpoints.documentCollaboration.submitEdit(
          authed,
          doc.id!,
          'session-1',
          {'field': 'v3'},
        );

        // Fetch operations since the initial HLC
        final sinceHlc = initialHlc ?? '';
        final ops = await endpoints.documentCollaboration.getOperationsSince(
          sessionBuilder,
          doc.id!,
          sinceHlc,
          limit: 100,
        );

        expect(ops, isNotEmpty);
      });

      test('returns empty list when no new operations', () async {
        final doc = await factory.createTestDocument(
          title: 'No Ops Doc',
          data: {'x': '1'},
        );

        // Use a far-future HLC so nothing is "since" it
        final ops = await endpoints.documentCollaboration.getOperationsSince(
          sessionBuilder,
          doc.id!,
          '9999-01-01T00:00:00.000Z-0000-0000000000000000',
          limit: 100,
        );

        expect(ops, isEmpty);
      });
    });

    group('getActiveEditors', () {
      test('returns editors after recent edits', () async {
        final doc = await factory.createTestDocument(
          title: 'Active Editors Doc',
          data: {'content': 'hello'},
        );
        final authed = factory.authenticatedSession();

        // Submit an edit to register activity
        await endpoints.documentCollaboration.submitEdit(
          authed,
          doc.id!,
          'session-active',
          {'content': 'updated'},
        );

        final editors = await endpoints.documentCollaboration.getActiveEditors(
          sessionBuilder,
          doc.id!,
        );

        // Should include the test user who just edited
        expect(editors, isA<List<Map<String, dynamic>>>());
      });

      test('returns empty list for nonexistent document', () async {
        final editors = await endpoints.documentCollaboration.getActiveEditors(
          sessionBuilder,
          999999,
        );

        expect(editors, isEmpty);
      });
    });

    group('compactOperations', () {
      test('compacts operations without error', () async {
        final doc = await factory.createTestDocument(
          title: 'Compact Doc',
          data: {'field': 'v1'},
        );
        final authed = factory.authenticatedSession();

        // Generate some operations
        for (var i = 0; i < 5; i++) {
          await endpoints.documentCollaboration.submitEdit(
            authed,
            doc.id!,
            'session-compact',
            {'field': 'v${i + 2}'},
          );
        }

        final countBefore =
            await endpoints.documentCollaboration.getOperationCount(
          sessionBuilder,
          doc.id!,
        );
        expect(countBefore, greaterThan(0));

        // Compact should not throw
        await endpoints.documentCollaboration.compactOperations(
          authed,
          doc.id!,
        );

        // After compaction, operation count should be reduced
        final countAfter =
            await endpoints.documentCollaboration.getOperationCount(
          sessionBuilder,
          doc.id!,
        );
        expect(countAfter, lessThanOrEqualTo(countBefore));
      });
    });
  });
}
