import 'dart:convert';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('Document CRDT operations', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      final client = await factory.createTestClient(slug: 'test-client-crdt');
      final authed = factory.authenticatedSession();
      await endpoints.user.ensureUser(authed, 'test-client-crdt', client.apiToken);
    });

    group('updateDocumentData', () {
      test('sequential updates produce correct merged state', () async {
        final doc = await factory.createTestDocument(
          title: 'CRDT Doc',
          data: {'field1': 'initial'},
        );
        final authed = factory.authenticatedSession();

        // First update
        final updated1 = await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'field1': 'updated', 'field2': 'new_value'},
        );

        // Parse the data field (stored as JSON string)
        final data1 = jsonDecode(updated1.data!) as Map<String, dynamic>;
        expect(data1['field1'], equals('updated'));
        expect(data1['field2'], equals('new_value'));

        // Second update
        final updated2 = await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'field3': 'another_value'},
        );

        final data2 = jsonDecode(updated2.data!) as Map<String, dynamic>;
        expect(data2['field1'], equals('updated'));
        expect(data2['field2'], equals('new_value'));
        expect(data2['field3'], equals('another_value'));
      });

      test('updates to different fields merge cleanly', () async {
        final doc = await factory.createTestDocument(
          title: 'Merge Doc',
          data: {'a': '1', 'b': '2'},
        );
        final authed = factory.authenticatedSession();

        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'a': 'updated_a'},
        );
        final result = await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'b': 'updated_b'},
        );

        final data = jsonDecode(result.data!) as Map<String, dynamic>;
        expect(data['a'], equals('updated_a'));
        expect(data['b'], equals('updated_b'));
      });
    });

    group('CRDT operations tracking', () {
      test('operations are recorded and countable', () async {
        final doc = await factory.createTestDocument(
          title: 'Ops Doc',
          data: {'x': '1'},
        );
        final authed = factory.authenticatedSession();

        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'x': '2'},
        );
        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'y': '3'},
        );

        final count = await endpoints.documentCollaboration.getOperationCount(
          sessionBuilder,
          doc.id!,
        );

        // At least 2 operations from our updates (may be more from create)
        expect(count, greaterThanOrEqualTo(2));
      });

      test('getCurrentHlc returns a valid HLC', () async {
        final doc = await factory.createTestDocument(
          title: 'HLC Doc',
          data: {'z': '1'},
        );
        final authed = factory.authenticatedSession();

        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'z': '2'},
        );

        final hlc = await endpoints.documentCollaboration.getCurrentHlc(
          sessionBuilder,
          doc.id!,
        );

        expect(hlc, isNotNull);
        expect(hlc!.isNotEmpty, isTrue);
      });
    });
  });
}
