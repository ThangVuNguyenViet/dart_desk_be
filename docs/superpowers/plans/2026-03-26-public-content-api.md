# Public Content API Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a read-only public content API that serves published documents, with a denormalized `publishedAt` field on the Document model for high-read performance.

**Architecture:** Add `publishedAt` to the Document model, create a `PublicDocument` protocol-only DTO, build a new `PublicContentEndpoint` with five query methods, and update the existing publish/archive flows to sync the denormalized field.

**Tech Stack:** Serverpod, PostgreSQL, Dart

---

### Task 1: Add `publishedAt` to Document model

**Files:**
- Modify: `dart_desk_server/lib/src/models/document.spy.yaml`

- [ ] **Step 1: Add publishedAt field and index to Document model**

Edit `dart_desk_server/lib/src/models/document.spy.yaml` to add the `publishedAt` field and a partial index:

```yaml
class: Document
table: documents
fields:
  clientId: int?
  documentType: String
  title: String
  slug: String
  isDefault: bool, default=false
  data: String?
  crdtNodeId: String?
  crdtHlc: String?
  publishedAt: DateTime?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now
  createdByUserId: int?, relation(parent=users, onDelete=SetNull)
  updatedByUserId: int?, relation(parent=users, onDelete=SetNull)
indexes:
  documents_client_type_idx:
    fields: clientId, documentType
  documents_client_type_slug_idx:
    fields: clientId, documentType, slug
    unique: true
  documents_type_default_idx:
    fields: documentType, isDefault
  documents_created_at_idx:
    fields: createdAt
  documents_client_published_idx:
    fields: clientId, publishedAt
```

Note: Serverpod doesn't support partial indexes in YAML. The `documents_client_published_idx` on `(clientId, publishedAt)` serves the public API queries. Most queries filter by `clientId` + `publishedAt IS NOT NULL`, so a composite index is optimal.

- [ ] **Step 2: Generate Serverpod code**

Run:
```bash
cd dart_desk_server && serverpod generate
```

Expected: Generated code updates in `lib/src/generated/` reflecting the new `publishedAt` field on `Document`.

- [ ] **Step 3: Create migration**

Run:
```bash
cd dart_desk_server && serverpod create-migration
```

Expected: New migration directory under `migrations/` with SQL adding `published_at` column and the new index.

- [ ] **Step 4: Commit**

```bash
git add dart_desk_server/lib/src/models/document.spy.yaml dart_desk_server/lib/src/generated/ dart_desk_server/migrations/
git commit -m "feat: add publishedAt field to Document model"
```

---

### Task 2: Create PublicDocument DTO

**Files:**
- Create: `dart_desk_server/lib/src/models/public_document.spy.yaml`

- [ ] **Step 1: Create the PublicDocument protocol model**

Create `dart_desk_server/lib/src/models/public_document.spy.yaml`:

```yaml
class: PublicDocument
fields:
  id: int
  documentType: String
  title: String
  slug: String
  isDefault: bool
  data: String
  publishedAt: DateTime
  updatedAt: DateTime
```

Note: No `table` field — this is a protocol-only DTO for serialization. `data` is `String` (JSON-encoded) matching the existing `Document.data` field type.

- [ ] **Step 2: Generate Serverpod code**

Run:
```bash
cd dart_desk_server && serverpod generate
```

Expected: `PublicDocument` class generated in `lib/src/generated/`.

- [ ] **Step 3: Commit**

```bash
git add dart_desk_server/lib/src/models/public_document.spy.yaml dart_desk_server/lib/src/generated/
git commit -m "feat: add PublicDocument DTO model"
```

---

### Task 3: Sync `publishedAt` on publish/archive

**Files:**
- Modify: `dart_desk_server/lib/src/endpoints/document_endpoint.dart`
- Test: `dart_desk_server/test/integration/document_versioning_test.dart`

- [ ] **Step 1: Write failing tests for publishedAt sync**

Add tests to `dart_desk_server/test/integration/document_versioning_test.dart` (or create a new group in it). Read the file first to understand its structure, then add:

```dart
group('publishedAt sync', () {
  test('publishDocumentVersion sets document.publishedAt', () async {
    final doc = await factory.createTestDocument(title: 'Publish Test');
    final version = await factory.createTestVersion(doc.id!);

    await endpoints.document.publishDocumentVersion(
      factory.authenticatedSession(),
      version.id!,
    );

    final updated = await endpoints.document.getDocument(
      sessionBuilder,
      doc.id!,
    );
    expect(updated!.publishedAt, isNotNull);
  });

  test('archiveDocumentVersion nulls publishedAt when no published versions remain', () async {
    final doc = await factory.createTestDocument(title: 'Archive Test');
    final version = await factory.createTestVersion(doc.id!);

    // Publish then archive
    await endpoints.document.publishDocumentVersion(
      factory.authenticatedSession(),
      version.id!,
    );
    await endpoints.document.archiveDocumentVersion(
      factory.authenticatedSession(),
      version.id!,
    );

    final updated = await endpoints.document.getDocument(
      sessionBuilder,
      doc.id!,
    );
    expect(updated!.publishedAt, isNull);
  });

  test('archiveDocumentVersion keeps publishedAt when other published versions exist', () async {
    final doc = await factory.createTestDocument(title: 'Multi Version');
    final v1 = await factory.createTestVersion(doc.id!);
    final v2 = await factory.createTestVersion(doc.id!);

    // Publish both
    await endpoints.document.publishDocumentVersion(
      factory.authenticatedSession(),
      v1.id!,
    );
    await endpoints.document.publishDocumentVersion(
      factory.authenticatedSession(),
      v2.id!,
    );

    // Archive only v1
    await endpoints.document.archiveDocumentVersion(
      factory.authenticatedSession(),
      v1.id!,
    );

    final updated = await endpoints.document.getDocument(
      sessionBuilder,
      doc.id!,
    );
    expect(updated!.publishedAt, isNotNull);
  });
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run:
```bash
cd dart_desk_server && dart test test/integration/document_versioning_test.dart
```

Expected: FAIL — `publishedAt` is null because the sync logic doesn't exist yet.

- [ ] **Step 3: Implement sync in publishDocumentVersion**

In `dart_desk_server/lib/src/endpoints/document_endpoint.dart`, update `publishDocumentVersion` (around line 515-535):

```dart
/// Publish a version (set status to 'published' and set publishedAt timestamp)
Future<DocumentVersion?> publishDocumentVersion(
  Session session,
  int versionId,
) async {
  await _requireAuth(session);

  final existing = await DocumentVersion.db.findById(session, versionId);

  if (existing == null) {
    return null;
  }

  final now = DateTime.now();
  final updated = existing.copyWith(
    status: DocumentVersionStatus.published,
    publishedAt: now,
  );

  await DocumentVersion.db.updateRow(session, updated);

  // Sync publishedAt to the parent document for fast public reads
  final document = await Document.db.findById(session, existing.documentId);
  if (document != null) {
    await Document.db.updateRow(
      session,
      document.copyWith(publishedAt: now),
    );
  }

  return updated;
}
```

- [ ] **Step 4: Implement sync in archiveDocumentVersion**

Update `archiveDocumentVersion` (around line 537-558):

```dart
/// Archive a version (set status to 'archived' and set archivedAt timestamp)
Future<DocumentVersion?> archiveDocumentVersion(
  Session session,
  int versionId,
) async {
  await _requireAuth(session);

  final existing = await DocumentVersion.db.findById(session, versionId);

  if (existing == null) {
    return null;
  }

  final updated = existing.copyWith(
    status: DocumentVersionStatus.archived,
    archivedAt: DateTime.now(),
  );

  await DocumentVersion.db.updateRow(session, updated);

  // Check if any published versions remain for this document
  final publishedCount = await DocumentVersion.db.count(
    session,
    where: (t) =>
        t.documentId.equals(existing.documentId) &
        t.status.equals(DocumentVersionStatus.published),
  );

  if (publishedCount == 0) {
    final document =
        await Document.db.findById(session, existing.documentId);
    if (document != null) {
      await Document.db.updateRow(
        session,
        document.copyWith(publishedAt: null),
      );
    }
  }

  return updated;
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run:
```bash
cd dart_desk_server && dart test test/integration/document_versioning_test.dart
```

Expected: All new tests PASS.

- [ ] **Step 6: Commit**

```bash
git add dart_desk_server/lib/src/endpoints/document_endpoint.dart dart_desk_server/test/integration/document_versioning_test.dart
git commit -m "feat: sync publishedAt to Document on publish/archive"
```

---

### Task 4: Create PublicContentEndpoint

**Files:**
- Create: `dart_desk_server/lib/src/endpoints/public_content_endpoint.dart`
- Test: `dart_desk_server/test/integration/public_content_endpoint_test.dart`

- [ ] **Step 1: Write failing tests**

Create `dart_desk_server/test/integration/public_content_endpoint_test.dart`:

```dart
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('PublicContent endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    /// Helper: create a document, create a version, publish it.
    Future<Document> createPublishedDocument({
      required String documentType,
      required String title,
      String? slug,
      bool isDefault = false,
      Map<String, dynamic> data = const {'body': 'content'},
    }) async {
      final doc = await factory.createTestDocument(
        documentType: documentType,
        title: title,
        slug: slug,
        isDefault: isDefault,
        data: data,
      );
      final version = await factory.createTestVersion(doc.id!);
      await endpoints.document.publishDocumentVersion(
        factory.authenticatedSession(),
        version.id!,
      );
      // Re-fetch to get updated publishedAt
      return (await endpoints.document.getDocument(sessionBuilder, doc.id!))!;
    }

    group('getAllContents', () {
      test('returns published documents grouped by type', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Blog 1',
          slug: 'blog-1',
        );
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Blog 2',
          slug: 'blog-2',
        );
        await createPublishedDocument(
          documentType: 'page',
          title: 'Page 1',
          slug: 'page-1',
        );

        final result = await endpoints.publicContent.getAllContents(
          sessionBuilder,
        );

        expect(result, containsPair('blog', hasLength(2)));
        expect(result, containsPair('page', hasLength(1)));
      });

      test('excludes unpublished documents', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Published',
          slug: 'published',
        );
        // Create unpublished doc (no version published)
        await factory.createTestDocument(
          documentType: 'blog',
          title: 'Draft',
          slug: 'draft',
        );

        final result = await endpoints.publicContent.getAllContents(
          sessionBuilder,
        );

        expect(result['blog'], hasLength(1));
        expect(result['blog']!.first.title, equals('Published'));
      });
    });

    group('getDefaultContents', () {
      test('returns default document per type', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Default Blog',
          slug: 'default-blog',
          isDefault: true,
        );
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Other Blog',
          slug: 'other-blog',
        );
        await createPublishedDocument(
          documentType: 'page',
          title: 'Default Page',
          slug: 'default-page',
          isDefault: true,
        );

        final result = await endpoints.publicContent.getDefaultContents(
          sessionBuilder,
        );

        expect(result, hasLength(2));
        expect(result['blog']!.title, equals('Default Blog'));
        expect(result['page']!.title, equals('Default Page'));
      });
    });

    group('getContentsByType', () {
      test('returns all published documents of a type', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Blog A',
          slug: 'blog-a',
        );
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Blog B',
          slug: 'blog-b',
        );
        await createPublishedDocument(
          documentType: 'page',
          title: 'Page A',
          slug: 'page-a',
        );

        final result = await endpoints.publicContent.getContentsByType(
          sessionBuilder,
          'blog',
        );

        expect(result, hasLength(2));
        expect(result.map((d) => d.title), containsAll(['Blog A', 'Blog B']));
      });
    });

    group('getDefaultContent', () {
      test('returns default document for a type', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Default',
          slug: 'default',
          isDefault: true,
        );

        final result = await endpoints.publicContent.getDefaultContent(
          sessionBuilder,
          'blog',
        );

        expect(result.title, equals('Default'));
        expect(result.isDefault, isTrue);
      });

      test('throws when no default exists', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Not Default',
          slug: 'not-default',
        );

        expect(
          () => endpoints.publicContent.getDefaultContent(
            sessionBuilder,
            'blog',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getContentBySlug', () {
      test('returns document by type and slug', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'My Post',
          slug: 'my-post',
        );

        final result = await endpoints.publicContent.getContentBySlug(
          sessionBuilder,
          'blog',
          'my-post',
        );

        expect(result.title, equals('My Post'));
        expect(result.slug, equals('my-post'));
      });

      test('throws when no match', () async {
        expect(
          () => endpoints.publicContent.getContentBySlug(
            sessionBuilder,
            'blog',
            'nonexistent',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run:
```bash
cd dart_desk_server && dart test test/integration/public_content_endpoint_test.dart
```

Expected: Compilation error — `endpoints.publicContent` doesn't exist yet.

- [ ] **Step 3: Implement PublicContentEndpoint**

Create `dart_desk_server/lib/src/endpoints/public_content_endpoint.dart`:

```dart
import 'package:serverpod/serverpod.dart';

import '../auth/dart_desk_session.dart';
import '../generated/protocol.dart';

/// Read-only public content API for external consumers.
/// Requires x-api-key with read permission.
/// ClientId is derived from the API key.
class PublicContentEndpoint extends Endpoint {
  /// Returns all published documents grouped by document type.
  Future<Map<String, List<PublicDocument>>> getAllContents(
    Session session,
  ) async {
    final clientId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) & t.publishedAt.notEquals(null),
    );

    final grouped = <String, List<PublicDocument>>{};
    for (final doc in documents) {
      grouped.putIfAbsent(doc.documentType, () => []);
      grouped[doc.documentType]!.add(_toPublicDocument(doc));
    }
    return grouped;
  }

  /// Returns the default published document for each document type.
  Future<Map<String, PublicDocument>> getDefaultContents(
    Session session,
  ) async {
    final clientId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.isDefault.equals(true),
    );

    return {
      for (final doc in documents)
        doc.documentType: _toPublicDocument(doc),
    };
  }

  /// Returns all published documents of a specific type.
  Future<List<PublicDocument>> getContentsByType(
    Session session,
    String documentType,
  ) async {
    final clientId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType),
    );

    return documents.map(_toPublicDocument).toList();
  }

  /// Returns the default published document for a specific type.
  Future<PublicDocument> getDefaultContent(
    Session session,
    String documentType,
  ) async {
    final clientId = _requireReadAccess(session);

    final document = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType) &
          t.isDefault.equals(true),
    );

    if (document == null) {
      throw Exception(
        'No default published document found for type "$documentType".',
      );
    }

    return _toPublicDocument(document);
  }

  /// Returns a single published document by type and slug.
  Future<PublicDocument> getContentBySlug(
    Session session,
    String documentType,
    String slug,
  ) async {
    final clientId = _requireReadAccess(session);

    final document = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType) &
          t.slug.equals(slug),
    );

    if (document == null) {
      throw Exception(
        'No published document found for type "$documentType" with slug "$slug".',
      );
    }

    return _toPublicDocument(document);
  }

  /// Validates the API key has read access and returns the clientId.
  int? _requireReadAccess(Session session) {
    final apiKey = session.apiKey;
    if (!apiKey.canRead) {
      throw Exception('API key does not have read permission.');
    }
    return apiKey.clientId;
  }

  PublicDocument _toPublicDocument(Document doc) {
    return PublicDocument(
      id: doc.id!,
      documentType: doc.documentType,
      title: doc.title,
      slug: doc.slug,
      isDefault: doc.isDefault,
      data: doc.data ?? '{}',
      publishedAt: doc.publishedAt!,
      updatedAt: doc.updatedAt ?? DateTime.now(),
    );
  }
}
```

- [ ] **Step 4: Regenerate Serverpod code**

Run:
```bash
cd dart_desk_server && serverpod generate
```

Expected: `endpoints.publicContent` is now available in generated code.

- [ ] **Step 5: Run tests to verify they pass**

Run:
```bash
cd dart_desk_server && dart test test/integration/public_content_endpoint_test.dart
```

Expected: All tests PASS.

- [ ] **Step 6: Run full test suite**

Run:
```bash
cd dart_desk_server && dart test
```

Expected: All existing tests still pass. No regressions.

- [ ] **Step 7: Commit**

```bash
git add dart_desk_server/lib/src/endpoints/public_content_endpoint.dart dart_desk_server/test/integration/public_content_endpoint_test.dart dart_desk_server/lib/src/generated/
git commit -m "feat: add PublicContentEndpoint with read-only public content API"
```
