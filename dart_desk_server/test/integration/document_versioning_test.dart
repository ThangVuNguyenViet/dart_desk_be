import 'dart:convert';

import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Document versioning', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser(role: ClientRole.admin);
    });

    group('createDocumentVersion', () {
      test('creates draft version', () async {
        final doc = await factory.createTestDocument(title: 'Versioned Doc');
        final version = await factory.createTestVersion(doc.id);

        expect(version.id, isNotNull);
        expect(version.documentId, equals(doc.id));
        expect(version.status, equals(DocumentVersionStatus.draft));
        expect(version.versionNumber, equals(2));
      });

      test('increments version number', () async {
        final doc = await factory.createTestDocument(title: 'Multi Version');
        final v1 = await factory.createTestVersion(doc.id);
        final v2 = await factory.createTestVersion(doc.id);

        expect(v1.versionNumber, equals(2));
        expect(v2.versionNumber, equals(3));
      });

      test('stores changeLog', () async {
        final doc = await factory.createTestDocument(title: 'Changelog Doc');
        final version = await factory.createTestVersion(
          doc.id,
          changeLog: 'Initial draft with hero section',
        );

        expect(version.changeLog, equals('Initial draft with hero section'));
      });
    });

    group('archiveDocumentVersion', () {
      test('changes status to archived and sets archivedAt', () async {
        final doc = await factory.createTestDocument(title: 'Archive Test');
        final draft = await factory.createTestVersion(doc.id);
        final authed = factory.authenticatedSession();

        final archived = await endpoints.document.archiveDocumentVersion(
          authed,
          draft.id,
        );

        expect(archived, isNotNull);
        expect(archived!.status, equals(DocumentVersionStatus.archived));
        expect(archived.archivedAt, isNotNull);
      });
    });

    group('getDocumentVersions', () {
      test('returns versions ordered by versionNumber ascending', () async {
        final doc = await factory.createTestDocument(title: 'History Doc');
        await factory.createTestVersion(doc.id);
        await factory.createTestVersion(doc.id);
        await factory.createTestVersion(doc.id);

        final result = await endpoints.document.getDocumentVersions(
          sessionBuilder,
          doc.id,
          limit: 100,
          offset: 0,
        );

        expect(result.versions.length, equals(4));
        // Ascending order: v1, v2, v3, v4
        expect(
          result.versions.first.versionNumber,
          lessThan(result.versions.last.versionNumber),
        );
      });

      test('paginates version list', () async {
        final doc = await factory.createTestDocument(title: 'Paginated Doc');
        for (var i = 0; i < 5; i++) {
          await factory.createTestVersion(doc.id);
        }

        final page1 = await endpoints.document.getDocumentVersions(
          sessionBuilder,
          doc.id,
          limit: 2,
          offset: 0,
        );

        expect(page1.versions.length, equals(2));
        expect(page1.total, equals(6));
      });
    });

    group('version snapshot data', () {
      test('version snapshot contains correct data at point-in-time', () async {
        final doc = await factory.createTestDocument(
          title: 'Snapshot Doc',
          data: {'content': 'v1'},
        );
        final authed = factory.authenticatedSession();

        // Publish v1 — creates an immutable published row at the current HLC.
        // Published rows are never extended by _upsertAutosaveVersion, so
        // v1's snapshotHlc is guaranteed to remain at the 'v1' HLC.
        final publishedV1 =
            await endpoints.document.publishCurrentVersion(authed, doc.id);

        // Update data to v2 — autosave creates a new draft row.
        await endpoints.document.updateDocumentData(
          authed,
          doc.id,
          jsonEncode({'content': 'v2'}),
        );

        // Retrieve the published v1 snapshot data — should still be 'v1'.
        final v1Data = await endpoints.document.getDocumentVersionData(
          sessionBuilder,
          publishedV1.id,
        );
        final v1Json = jsonDecode(v1Data!) as Map<String, dynamic>;

        expect(v1Data, isNotNull);
        expect(v1Json['content'], equals('v1'));
      });
    });

    group('deleteDocumentVersion', () {
      test('deletes a draft version', () async {
        final doc = await factory.createTestDocument(title: 'Delete Ver');
        final version = await factory.createTestVersion(doc.id);
        final authed = factory.authenticatedSession();

        final result = await endpoints.document.deleteDocumentVersion(
          authed,
          version.id,
        );
        expect(result, isTrue);

        // Soft delete: getDocumentVersion throws 410 for deleted versions
        await expectLater(
          () => endpoints.document.getDocumentVersion(sessionBuilder, version.id),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}
