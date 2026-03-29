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
      await factory.ensureTestUser();
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

    group('complex data types', () {
      test('create with rich data, retrieve and verify types preserved',
          () async {
        final complexData = TestDataFactory.complexTestData;
        final doc = await factory.createTestDocument(
          title: 'Complex Doc',
          data: complexData,
        );
        final authed = factory.authenticatedSession();

        final fetched = await endpoints.document.getDocument(authed, doc.id!);
        expect(fetched, isNotNull);

        final data = jsonDecode(fetched!.data!) as Map<String, dynamic>;
        expect(data['title'], equals('Test Page'));
        expect(data['title'], isA<String>());
        expect(data['isActive'], isA<bool>());
        expect(data['isActive'], isTrue);
        expect(data['count'], isA<int>());
        expect(data['count'], equals(42));
        expect(data['rating'], isA<double>());
        expect(data['rating'], equals(4.5));
        expect(data['tags'], isA<List>());
        expect(data['tags'], equals(['alpha', 'beta', 'gamma']));
        expect(data['metadata'], isA<Map>());
        expect(data['metadata']['author'], equals('Jane'));
        expect(data['metadata']['version'], isA<int>());
        expect(data['metadata']['version'], equals(3));
        expect(data['metadata']['published'], isA<bool>());
        expect(data['metadata']['published'], isTrue);
        expect(data['items'], isA<List>());
        expect((data['items'] as List).length, equals(2));
        expect(data['items'][0]['name'], equals('Item 1'));
        expect(data['items'][0]['price'], isA<double>());
        expect(data['items'][0]['price'], equals(9.99));
        expect(data['emptyList'], isA<List>());
        expect((data['emptyList'] as List), isEmpty);
        expect(data['emptyMap'], isA<Map>());
        expect((data['emptyMap'] as Map), isEmpty);
        expect(data['nullableField'], isNull);
      });

      test('update with complex types, verify merge preserves types',
          () async {
        final doc = await factory.createTestDocument(
          title: 'Update Complex Doc',
          data: {'simple': 'start'},
        );
        final authed = factory.authenticatedSession();

        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {
            'nested': {
              'deep': {'value': true}
            },
            'scores': [100, 200],
          },
        );

        final fetched = await endpoints.document.getDocument(authed, doc.id!);
        final data = jsonDecode(fetched!.data!) as Map<String, dynamic>;

        expect(data['nested'], isA<Map>());
        expect(data['nested']['deep'], isA<Map>());
        expect(data['nested']['deep']['value'], isA<bool>());
        expect(data['nested']['deep']['value'], isTrue);
        expect(data['scores'], isA<List>());
        expect(data['scores'], equals([100, 200]));
        expect(data['scores'][0], isA<int>());
      });

      test('deeply nested List->Map->List->Map round-trips correctly', () async {
        final doc = await factory.createTestDocument(
          title: 'Deep Nesting Doc',
          data: {
            'root': [
              {
                'sections': [
                  {'label': 'A', 'score': 1},
                  {'label': 'B', 'score': 2},
                ],
                'active': true,
              },
              {
                'sections': [
                  {'label': 'C', 'score': 3},
                ],
                'active': false,
              },
            ],
          },
        );
        final authed = factory.authenticatedSession();

        final fetched = await endpoints.document.getDocument(authed, doc.id!);
        final data = jsonDecode(fetched!.data!) as Map<String, dynamic>;

        // List
        expect(data['root'], isA<List>());
        final root = data['root'] as List;
        // Map
        expect(root[0], isA<Map>());
        // List
        expect(root[0]['sections'], isA<List>());
        // Map
        expect(root[0]['sections'][0], isA<Map>());
        expect(root[0]['sections'][0]['label'], equals('A'));
        expect(root[0]['sections'][0]['score'], isA<int>());
        expect(root[0]['sections'][0]['score'], equals(1));
        expect(root[0]['sections'][1]['score'], equals(2));
        expect(root[0]['active'], isA<bool>());
        expect(root[0]['active'], isTrue);
        expect(root[1]['active'], isFalse);
        expect(root[1]['sections'][0]['label'], equals('C'));
      });

      test('version snapshot preserves complex types', () async {
        final complexData = TestDataFactory.complexTestData;
        final doc = await factory.createTestDocument(
          title: 'Version Complex Doc',
          data: complexData,
        );

        final version = await factory.createTestVersion(doc.id!);

        final versionData = await endpoints.document.getDocumentVersionData(
          sessionBuilder,
          version.id!,
        );

        expect(versionData, isNotNull);
        expect(versionData!['isActive'], isA<bool>());
        expect(versionData['isActive'], isTrue);
        expect(versionData['count'], isA<int>());
        expect(versionData['count'], equals(42));
        expect(versionData['rating'], isA<double>());
        expect(versionData['tags'], isA<List>());
        expect(versionData['tags'], equals(['alpha', 'beta', 'gamma']));
        expect(versionData['metadata'], isA<Map>());
        expect(versionData['metadata']['version'], isA<int>());
        expect(versionData['items'], isA<List>());
        expect(versionData['items'][0]['price'], isA<double>());
      });
    });

    group('image field lifecycle', () {
      test('clearing image field removes sub-keys from state', () async {
        final doc = await factory.createTestDocument(
          title: 'Image Clear Doc',
          data: {
            'image': {'url': 'https://example.com/photo.jpg', 'alt': 'A photo'},
          },
        );
        final authed = factory.authenticatedSession();

        // Clear the image field
        final result = await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'image': null},
        );

        final data = jsonDecode(result.data!) as Map<String, dynamic>;
        expect(data['image'], isNull,
            reason: 'image should be null after clearing');
        // Must not have survived as a nested map with the old sub-keys
        expect(data['image'], isNot(isA<Map>()));
      });

      test('restoring image after null produces correct nested map', () async {
        final doc = await factory.createTestDocument(
          title: 'Image Restore Doc',
          data: {'image': null},
        );
        final authed = factory.authenticatedSession();

        final result = await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {
            'image': {'url': 'https://example.com/new.jpg', 'alt': 'New photo'},
          },
        );

        final data = jsonDecode(result.data!) as Map<String, dynamic>;
        expect(data['image'], isA<Map>());
        expect(data['image']['url'], equals('https://example.com/new.jpg'));
        expect(data['image']['alt'], equals('New photo'));
      });

      test('full image lifecycle: set → clear → restore', () async {
        final doc = await factory.createTestDocument(
          title: 'Image Lifecycle Doc',
          data: {
            'title': 'My Article',
            'image': {'url': 'https://example.com/v1.jpg', 'alt': 'V1'},
          },
        );
        final authed = factory.authenticatedSession();

        // Clear image
        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'image': null},
        );

        // Verify cleared
        final afterClear =
            await endpoints.document.getDocument(authed, doc.id!);
        final clearedData =
            jsonDecode(afterClear!.data!) as Map<String, dynamic>;
        expect(clearedData['image'], isNull);
        expect(clearedData['title'], equals('My Article'));

        // Restore with new image
        final result = await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {
            'image': {'url': 'https://example.com/v2.jpg', 'alt': 'V2'},
          },
        );

        final finalData = jsonDecode(result.data!) as Map<String, dynamic>;
        expect(finalData['image'], isA<Map>());
        expect(finalData['image']['url'], equals('https://example.com/v2.jpg'));
        expect(finalData['image']['alt'], equals('V2'));
        expect(finalData['title'], equals('My Article'));
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
