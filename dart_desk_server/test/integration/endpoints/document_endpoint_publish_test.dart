import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/test_data_factory.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('publishCurrentVersion', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser(role: ClientRole.admin);
    });

    test(
      'creates new document_versions row with status=published and upserts published_documents',
      () async {
        final authed = factory.authenticatedSession();
        // Create document with empty initial data so we control what CRDT state holds.
        final doc = await factory.createTestDocument(
          title: 'Publish Test Doc',
          data: {},
        );

        // Apply a CRDT op so the draft has content.
        await endpoints.document.updateDocumentData(
          authed,
          doc.id,
          '{"title":"Hello","body":"World"}',
        );

        // Act.
        final published = await endpoints.document.publishCurrentVersion(
          authed,
          doc.id,
        );

        // Version row exists, status=published, versionNumber bumped.
        expect(published.status, DocumentVersionStatus.published);
        expect(published.versionNumber, greaterThanOrEqualTo(1));
        expect(published.publishedAt, isNotNull);

        // published_documents row reflects current data.
        final session = sessionBuilder.build();
        final live = await PublishedDocument.db.findFirstRow(
          session,
          where: (t) => t.documentId.equals(doc.id),
        );
        expect(live, isNotNull);
        expect(live!.publishedVersionId, published.id);
        expect(live.data, {'title': 'Hello', 'body': 'World'});
      },
    );

    test('publishing twice produces two version rows but a single live row',
        () async {
      final authed = factory.authenticatedSession();
      final doc = await factory.createTestDocument(
        title: 'Multi Publish Doc',
        data: {},
      );

      await endpoints.document.updateDocumentData(
        authed,
        doc.id,
        '{"title":"v1"}',
      );
      final v1 = await endpoints.document.publishCurrentVersion(
        authed,
        doc.id,
      );

      await endpoints.document.updateDocumentData(
        authed,
        doc.id,
        '{"title":"v2"}',
      );
      final v2 = await endpoints.document.publishCurrentVersion(
        authed,
        doc.id,
      );

      expect(v2.versionNumber, greaterThan(v1.versionNumber));

      final session = sessionBuilder.build();
      final allVersions = await DocumentVersion.db.find(
        session,
        where: (t) => t.documentId.equals(doc.id),
      );
      expect(
        allVersions.where((v) => v.status == DocumentVersionStatus.published).length,
        2,
      );

      final liveRows = await PublishedDocument.db.find(
        session,
        where: (t) => t.documentId.equals(doc.id),
      );
      expect(liveRows.length, 1);
      expect(liveRows.single.publishedVersionId, v2.id);
      expect(liveRows.single.data, {'title': 'v2'});
    });
  });
}
