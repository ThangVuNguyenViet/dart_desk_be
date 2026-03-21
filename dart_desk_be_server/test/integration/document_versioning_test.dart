import 'package:test/test.dart';
import 'package:dart_desk_be_server/src/generated/protocol.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('Document versioning', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    group('createDocumentVersion', () {
      test('creates draft version', () async {
        final doc = await factory.createTestDocument(title: 'Versioned Doc');
        final version = await factory.createTestVersion(doc.id!);

        expect(version.id, isNotNull);
        expect(version.documentId, equals(doc.id));
        expect(version.status, equals(DocumentVersionStatus.draft));
        expect(version.versionNumber, equals(2));
      });

      test('increments version number', () async {
        final doc = await factory.createTestDocument(title: 'Multi Version');
        final v1 = await factory.createTestVersion(doc.id!);
        final v2 = await factory.createTestVersion(doc.id!);

        expect(v1.versionNumber, equals(2));
        expect(v2.versionNumber, equals(3));
      });

      test('stores changeLog', () async {
        final doc = await factory.createTestDocument(title: 'Changelog Doc');
        final version = await factory.createTestVersion(
          doc.id!,
          changeLog: 'Initial draft with hero section',
        );

        expect(version.changeLog, equals('Initial draft with hero section'));
      });
    });

    group('publishDocumentVersion', () {
      test('changes status to published and sets publishedAt', () async {
        final doc = await factory.createTestDocument(title: 'Publish Test');
        final draft = await factory.createTestVersion(doc.id!);
        final authed = factory.authenticatedSession();

        final published = await endpoints.document.publishDocumentVersion(
          authed,
          draft.id!,
        );

        expect(published, isNotNull);
        expect(published!.status, equals(DocumentVersionStatus.published));
        expect(published.publishedAt, isNotNull);
      });
    });

    group('archiveDocumentVersion', () {
      test('changes status to archived and sets archivedAt', () async {
        final doc = await factory.createTestDocument(title: 'Archive Test');
        final draft = await factory.createTestVersion(doc.id!);
        final authed = factory.authenticatedSession();

        // Publish first, then archive
        await endpoints.document.publishDocumentVersion(authed, draft.id!);
        final archived = await endpoints.document.archiveDocumentVersion(
          authed,
          draft.id!,
        );

        expect(archived, isNotNull);
        expect(archived!.status, equals(DocumentVersionStatus.archived));
        expect(archived.archivedAt, isNotNull);
      });
    });

    group('getDocumentVersions', () {
      test('returns versions ordered by versionNumber ascending', () async {
        final doc = await factory.createTestDocument(title: 'History Doc');
        await factory.createTestVersion(doc.id!);
        await factory.createTestVersion(doc.id!);
        await factory.createTestVersion(doc.id!);

        final result = await endpoints.document.getDocumentVersions(
          sessionBuilder,
          doc.id!,
          limit: 100,
          offset: 0,
          includeOperations: false,
        );

        expect(result.versions.length, equals(4));
        // Ascending order: v1, v2, v3, v4
        expect(
          result.versions.first.version.versionNumber,
          lessThan(result.versions.last.version.versionNumber),
        );
      });

      test('paginates version list', () async {
        final doc = await factory.createTestDocument(title: 'Paginated Doc');
        for (var i = 0; i < 5; i++) {
          await factory.createTestVersion(doc.id!);
        }

        final page1 = await endpoints.document.getDocumentVersions(
          sessionBuilder,
          doc.id!,
          limit: 2,
          offset: 0,
          includeOperations: false,
        );

        expect(page1.versions.length, equals(2));
        expect(page1.total, equals(6));
      });
    });

    group('publishDocumentVersion edge cases', () {
      test('publish already-published version succeeds idempotently', () async {
        final doc = await factory.createTestDocument(title: 'Double Publish');
        final draft = await factory.createTestVersion(doc.id!);
        final authed = factory.authenticatedSession();

        // Publish first time — should succeed
        final first = await endpoints.document.publishDocumentVersion(authed, draft.id!);
        expect(first, isNotNull);
        expect(first!.status, equals(DocumentVersionStatus.published));

        // Publish again — endpoint updates the same version (idempotent)
        final second = await endpoints.document.publishDocumentVersion(authed, draft.id!);
        expect(second, isNotNull);
        expect(second!.status, equals(DocumentVersionStatus.published));
        expect(second.id, equals(first.id));
      });
    });

    group('version snapshot data', () {
      test('version snapshot contains correct data at point-in-time', () async {
        final doc = await factory.createTestDocument(
          title: 'Snapshot Doc',
          data: {'content': 'v1'},
        );
        final authed = factory.authenticatedSession();

        // Create version at v1
        final v1 = await factory.createTestVersion(doc.id!);

        // Update data to v2
        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          {'content': 'v2'},
        );

        // Retrieve v1 snapshot data — should still be v1
        final v1Data = await endpoints.document.getDocumentVersionData(
          sessionBuilder,
          v1.id!,
        );

        expect(v1Data, isNotNull);
        expect(v1Data!['content'], equals('v1'));
      });
    });

    group('deleteDocumentVersion', () {
      test('deletes a draft version', () async {
        final doc = await factory.createTestDocument(title: 'Delete Ver');
        final version = await factory.createTestVersion(doc.id!);
        final authed = factory.authenticatedSession();

        final result = await endpoints.document.deleteDocumentVersion(
          authed,
          version.id!,
        );
        expect(result, isTrue);

        final fetched = await endpoints.document.getDocumentVersion(
          sessionBuilder,
          version.id!,
        );
        expect(fetched, isNull);
      });
    });
  });
}
