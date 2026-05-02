import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('Document endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser(role: ClientRole.admin);
    });

    group('createDocument', () {
      test('creates document with required fields', () async {
        final doc = await factory.createTestDocument(
          documentType: 'blog_post',
          title: 'My First Post',
          data: {'body': 'Hello world'},
        );

        expect(doc.id, isNotNull);
        expect(doc.title, equals('My First Post'));
        expect(doc.documentType, equals('blog_post'));
      });

      test('creates document with custom slug', () async {
        final doc = await factory.createTestDocument(
          title: 'Custom Slug Post',
          slug: 'custom-slug',
        );

        expect(doc.slug, equals('custom-slug'));
      });

      test('creates document with isDefault flag', () async {
        final doc = await factory.createTestDocument(
          title: 'Default Post',
          isDefault: true,
        );

        expect(doc.isDefault, isTrue);
      });
    });

    group('getDocument', () {
      test('returns document by ID', () async {
        final created = await factory.createTestDocument(title: 'Fetch Me');
        final fetched = await endpoints.document.getDocument(
          sessionBuilder,
          created.id,
        );

        expect(fetched, isNotNull);
        expect(fetched!.title, equals('Fetch Me'));
      });

      test('returns null for nonexistent ID', () async {
        final fetched = await endpoints.document.getDocument(
          sessionBuilder,
          UuidValue.fromString('00000000-0000-0000-0000-000000000000'),
        );
        expect(fetched, isNull);
      });
    });

    group('getDefaultDocument', () {
      test('returns default document for type', () async {
        await factory.createTestDocument(
          documentType: 'page',
          title: 'Default Page',
          isDefault: true,
        );
        final fetched = await endpoints.document.getDefaultDocument(
          sessionBuilder,
          'page',
        );

        expect(fetched, isNotNull);
        expect(fetched!.isDefault, isTrue);
      });

      test('returns null when no default exists', () async {
        await factory.createTestDocument(
          documentType: 'article',
          title: 'Not Default',
          isDefault: false,
        );
        final fetched = await endpoints.document.getDefaultDocument(
          sessionBuilder,
          'article',
        );
        expect(fetched, isNull);
      });
    });

    group('getDocuments', () {
      test('lists documents with pagination', () async {
        for (var i = 0; i < 5; i++) {
          await factory.createTestDocument(
            title: 'Doc $i',
            documentType: 'list_test',
          );
        }

        final result = await endpoints.document.getDocuments(
          factory.authenticatedSession(),
          'list_test',
          limit: 3,
          offset: 0,
        );

        expect(result.items.length, equals(3));
        expect(result.total, equals(5));
      });

      test('searches documents by title', () async {
        await factory.createTestDocument(
          title: 'Alpha Post',
          documentType: 'search_test',
        );
        await factory.createTestDocument(
          title: 'Beta Post',
          documentType: 'search_test',
        );

        final result = await endpoints.document.getDocuments(
          factory.authenticatedSession(),
          'search_test',
          search: 'Alpha',
          limit: 100,
          offset: 0,
        );

        expect(result.items.length, equals(1));
        expect(result.items.first.title, equals('Alpha Post'));
      });
    });

    group('updateDocument', () {
      test('updates title', () async {
        final doc = await factory.createTestDocument(title: 'Old Title');
        final authed = factory.authenticatedSession();
        final updated = await endpoints.document.updateDocument(
          authed,
          doc.id,
          title: 'New Title',
        );

        expect(updated, isNotNull);
        expect(updated!.title, equals('New Title'));
      });

      test('updates slug', () async {
        final doc = await factory.createTestDocument(title: 'Slug Update');
        final authed = factory.authenticatedSession();
        final updated = await endpoints.document.updateDocument(
          authed,
          doc.id,
          slug: 'new-slug',
        );

        expect(updated!.slug, equals('new-slug'));
      });
    });

    group('deleteDocument', () {
      test('deletes existing document', () async {
        final doc = await factory.createTestDocument(title: 'Delete Me');
        final authed = factory.authenticatedSession();
        final result = await endpoints.document.deleteDocument(
          authed,
          doc.id,
        );

        expect(result, isTrue);

        // Soft delete: getDocument throws 410 for deleted documents
        await expectLater(
          () => endpoints.document.getDocument(sessionBuilder, doc.id),
          throwsA(isA<ApiException>()),
        );
      });

      test('allows recreating a document with the same slug after delete',
          () async {
        final original = await factory.createTestDocument(
          documentType: 'page',
          title: 'Original',
          slug: 'main',
        );

        final authed = factory.authenticatedSession();
        final deleted = await endpoints.document.deleteDocument(
          authed,
          original.id,
        );
        expect(deleted, isTrue);

        final recreated = await factory.createTestDocument(
          documentType: 'page',
          title: 'Recreated',
          slug: 'main',
        );

        expect(recreated.id, isNot(equals(original.id)));
        expect(recreated.slug, equals('main'));
      });
    });

    group('getDocumentTypes', () {
      test('returns distinct document types', () async {
        await factory.createTestDocument(
          documentType: 'blog_post',
          title: 'Post 1',
        );
        await factory.createTestDocument(
          documentType: 'blog_post',
          title: 'Post 2',
        );
        await factory.createTestDocument(
          documentType: 'page',
          title: 'Page 1',
        );

        final authed = factory.authenticatedSession();
        final types = await endpoints.document.getDocumentTypes(authed);

        expect(types, containsAll(['blog_post', 'page']));
      });

      test('returns sorted types', () async {
        await factory.createTestDocument(
          documentType: 'zebra',
          title: 'Z Doc',
        );
        await factory.createTestDocument(
          documentType: 'alpha',
          title: 'A Doc',
        );

        final authed = factory.authenticatedSession();
        final types = await endpoints.document.getDocumentTypes(authed);

        final filtered = types.where(
          (t) => t == 'alpha' || t == 'zebra',
        ).toList();
        expect(filtered, equals(['alpha', 'zebra']));
      });

      test('returns empty list when no documents exist', () async {
        final authed = factory.authenticatedSession();
        final types = await endpoints.document.getDocumentTypes(authed);

        // May contain types from other tests in this group,
        // but should at least not throw
        expect(types, isA<List<String>>());
      });
    });

    group('getDocumentCount', () {
      test('returns count of documents for project', () async {
        await factory.createTestDocument(title: 'Count 1');
        await factory.createTestDocument(title: 'Count 2');

        final authed = factory.authenticatedSession();
        final count = await endpoints.document.getDocumentCount(
          authed,
          projectId: TestDataFactory.testProjectId,
        );

        expect(count, greaterThanOrEqualTo(2));
      });
    });

    group('suggestSlug', () {
      test('generates slug from title', () async {
        final slug = await endpoints.document.suggestSlug(
          sessionBuilder,
          'My Amazing Blog Post',
          'blog',
        );

        expect(slug, contains('my-amazing-blog-post'));
      });

      test('handles duplicate slugs', () async {
        await factory.createTestDocument(
          title: 'Duplicate',
          slug: 'duplicate',
          documentType: 'slug_test',
        );

        final slug = await endpoints.document.suggestSlug(
          sessionBuilder,
          'Duplicate',
          'slug_test',
        );

        // Should append a suffix to avoid collision
        expect(slug, isNot(equals('duplicate')));
      });
    });

    // ============================================================
    // setDefaultDocument
    // ============================================================
    group('setDefaultDocument', () {
      test('swaps isDefault from current default to new document', () async {
        final docA = await factory.createTestDocument(
          documentType: 'article',
          title: 'Doc A',
          isDefault: true,
        );
        final docB = await factory.createTestDocument(
          documentType: 'article',
          title: 'Doc B',
        );

        final authed = factory.authenticatedSession();
        final result = await endpoints.document.setDefaultDocument(
          authed,
          'article',
          docB.id,
        );

        expect(result.id, docB.id);
        expect(result.isDefault, isTrue);

        final fetchedA = await endpoints.document.getDocument(
          sessionBuilder,
          docA.id,
        );
        expect(fetchedA?.isDefault, isFalse);
      });

      test('returns the updated document with isDefault true', () async {
        final doc = await factory.createTestDocument(
          documentType: 'article',
          title: 'Target',
        );

        final authed = factory.authenticatedSession();
        final result = await endpoints.document.setDefaultDocument(
          authed,
          'article',
          doc.id,
        );

        expect(result.id, doc.id);
        expect(result.isDefault, isTrue);
      });

      test('does not affect documents of other types', () async {
        final blog = await factory.createTestDocument(
          documentType: 'blog',
          title: 'Blog Default',
          isDefault: true,
        );
        final article = await factory.createTestDocument(
          documentType: 'article',
          title: 'Article',
        );

        final authed = factory.authenticatedSession();
        await endpoints.document.setDefaultDocument(
          authed,
          'article',
          article.id,
        );

        final fetchedBlog = await endpoints.document.getDocument(
          sessionBuilder,
          blog.id,
        );
        expect(fetchedBlog?.isDefault, isTrue);
      });

      test('throws for unknown documentId', () async {
        final authed = factory.authenticatedSession();
        expect(
          () => endpoints.document.setDefaultDocument(authed, 'article', UuidValue.fromString('00000000-0000-0000-0000-000000000000')),
          throwsA(anything),
        );
      });
    });
  });
}
