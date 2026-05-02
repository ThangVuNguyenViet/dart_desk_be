import 'dart:convert';

import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/test_data_factory.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('restoreDocumentVersion', (sessionBuilder, endpoints) {
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
      'restoring an old version brings draft back to that state, leaving old version row unchanged',
      () async {
        final authed = factory.authenticatedSession();
        final doc = await factory.createTestDocument(
          title: 'Restore Test Doc',
          data: {},
        );

        await endpoints.document.updateDocumentData(
          authed,
          doc.id,
          '{"v":"1"}',
        );
        final v1 = await endpoints.document.publishCurrentVersion(
          authed,
          doc.id,
        );

        await endpoints.document.updateDocumentData(
          authed,
          doc.id,
          '{"v":"2"}',
        );
        final v2 = await endpoints.document.publishCurrentVersion(
          authed,
          doc.id,
        );

        // Restore v1.
        final updated = await endpoints.document.restoreDocumentVersion(
          authed,
          doc.id,
          v1.id!,
        );

        // Draft now matches v1.
        expect(jsonDecode(updated.data!), {'v': '1'});

        // v1 row untouched.
        final session = sessionBuilder.build();
        final v1After = await DocumentVersion.db.findById(session, v1.id!);
        expect(v1After!.status, DocumentVersionStatus.published);
        expect(v1After.versionNumber, v1.versionNumber);

        // No new published_documents row written until Publish is called.
        final live = await PublishedDocument.db.findFirstRow(
          session,
          where: (t) => t.documentId.equals(doc.id),
        );
        expect(live!.publishedVersionId, v2.id); // still v2
      },
    );
  });
}
