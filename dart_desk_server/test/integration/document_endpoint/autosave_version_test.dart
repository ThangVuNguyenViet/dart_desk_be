import 'dart:convert';

import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../helpers/test_data_factory.dart';
import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('updateDocumentData autosave version',
      (sessionBuilder, endpoints) {
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
      'first edit by same user within window extends the initial draft '
      '(no new row, snapshotHlc updated)',
      () async {
        final session = factory.authenticatedSession();
        final doc = await endpoints.document.createDocument(
          session,
          'test_type',
          'doc',
          jsonEncode({'title': 'a'}),
          isDefault: false,
        );

        // Initial creation already inserted v1 draft.
        var result = await endpoints.document.getDocumentVersions(
          session,
          doc.id,
          limit: 100,
          offset: 0,
          includeOperations: false,
        );
        expect(result.versions, hasLength(1));
        expect(
          result.versions.first.version.status,
          DocumentVersionStatus.draft,
        );
        final v1Hlc = result.versions.first.version.snapshotHlc;

        // Edit -> should extend v1 bucket, not insert a new row.
        await endpoints.document.updateDocumentData(
          session,
          doc.id,
          jsonEncode({'title': 'b'}),
        );

        result = await endpoints.document.getDocumentVersions(
          session,
          doc.id,
          limit: 100,
          offset: 0,
          includeOperations: false,
        );
        expect(result.versions, hasLength(1),
            reason: 'edit within bucket should extend, not insert');
        expect(result.versions.first.version.versionNumber, 1);
        expect(
          result.versions.first.version.status,
          DocumentVersionStatus.draft,
        );
        expect(
          result.versions.first.version.snapshotHlc,
          isNot(equals(v1Hlc)),
          reason: 'snapshotHlc should advance',
        );
      },
    );

    test('publish then edit inserts a new draft after the published row',
        () async {
      final session = factory.authenticatedSession();
      final doc = await endpoints.document.createDocument(
        session,
        'test_type',
        'doc',
        jsonEncode({'title': 'a'}),
        isDefault: false,
      );

      await endpoints.document.publishCurrentVersion(session, doc.id);

      await endpoints.document.updateDocumentData(
        session,
        doc.id,
        jsonEncode({'title': 'b'}),
      );

      final result = await endpoints.document.getDocumentVersions(
        session,
        doc.id,
        limit: 100,
        offset: 0,
        includeOperations: false,
      );

      final statuses =
          result.versions.map((v) => v.version.status).toList();
      // Expect: v1 draft, v2 published, v3 draft.
      expect(statuses, [
        DocumentVersionStatus.draft,
        DocumentVersionStatus.published,
        DocumentVersionStatus.draft,
      ]);
      expect(result.versions.last.version.versionNumber, 3);
    });

    test('author switch inserts a new draft (Z rule)', () async {
      // Alice creates and edits.
      final aliceSession =
          factory.authenticatedSession(userIdentifier: 'test-user-1');
      final aliceUser = await factory.ensureTestUser(
        userIdentifier: 'test-user-1',
        name: 'Alice',
        role: ClientRole.admin,
      );

      final doc = await endpoints.document.createDocument(
        aliceSession,
        'test_type',
        'doc',
        jsonEncode({'title': 'a'}),
        isDefault: false,
      );

      await endpoints.document.updateDocumentData(
        aliceSession,
        doc.id,
        jsonEncode({'title': 'b'}),
      );

      // Bob edits — different user, should break the bucket.
      final bobUser = await factory.ensureTestUser(
        userIdentifier: 'test-user-2',
        email: 'test-user-2@example.com',
        name: 'Bob',
        role: ClientRole.admin,
      );
      final bobSession =
          factory.authenticatedSession(userIdentifier: 'test-user-2');

      await endpoints.document.updateDocumentData(
        bobSession,
        doc.id,
        jsonEncode({'title': 'c'}),
      );

      final result = await endpoints.document.getDocumentVersions(
        aliceSession,
        doc.id,
        limit: 100,
        offset: 0,
        includeOperations: false,
      );

      expect(result.versions, hasLength(2),
          reason: 'author switch breaks the bucket');
      expect(
        result.versions[0].version.createdByUserId,
        aliceUser.id,
      );
      expect(
        result.versions[1].version.createdByUserId,
        bobUser.id,
      );
      expect(
        result.versions[1].version.status,
        DocumentVersionStatus.draft,
      );
    });

    test('no-op update (same HLC) does not write a new row or extend',
        () async {
      final session = factory.authenticatedSession();
      final doc = await endpoints.document.createDocument(
        session,
        'test_type',
        'doc',
        jsonEncode({'title': 'a'}),
        isDefault: false,
      );

      final before = (await endpoints.document.getDocumentVersions(
        session,
        doc.id,
        limit: 100,
        offset: 0,
        includeOperations: false,
      ))
          .versions
          .first
          .version;

      // Empty update — no CRDT ops applied, HLC unchanged.
      await endpoints.document.updateDocumentData(
        session,
        doc.id,
        jsonEncode({}),
      );

      final after = await endpoints.document.getDocumentVersions(
        session,
        doc.id,
        limit: 100,
        offset: 0,
        includeOperations: false,
      );

      expect(after.versions, hasLength(1));
      expect(after.versions.first.version.snapshotHlc, before.snapshotHlc);
    });
  });
}
