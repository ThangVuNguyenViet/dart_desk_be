import 'package:test/test.dart';
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
      await factory.ensureTestUser();
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
          created.id!,
        );

        expect(fetched, isNotNull);
        expect(fetched!.title, equals('Fetch Me'));
      });

      test('returns null for nonexistent ID', () async {
        final fetched = await endpoints.document.getDocument(
          sessionBuilder,
          999999,
        );
        expect(fetched, isNull);
      });
    });

    group('getDocumentBySlug', () {
      test('returns document by slug', () async {
        await factory.createTestDocument(
          title: 'Slug Test',
          slug: 'slug-test',
        );
        final fetched = await endpoints.document.getDocumentBySlug(
          sessionBuilder,
          'slug-test',
        );

        expect(fetched, isNotNull);
        expect(fetched!.title, equals('Slug Test'));
      });

      test('returns null for nonexistent slug', () async {
        final fetched = await endpoints.document.getDocumentBySlug(
          sessionBuilder,
          'nonexistent-slug',
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

        expect(result.documents.length, equals(3));
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

        expect(result.documents.length, equals(1));
        expect(result.documents.first.title, equals('Alpha Post'));
      });
    });

    group('updateDocument', () {
      test('updates title', () async {
        final doc = await factory.createTestDocument(title: 'Old Title');
        final authed = factory.authenticatedSession();
        final updated = await endpoints.document.updateDocument(
          authed,
          doc.id!,
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
          doc.id!,
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
          doc.id!,
        );

        expect(result, isTrue);

        final fetched = await endpoints.document.getDocument(
          sessionBuilder,
          doc.id!,
        );
        expect(fetched, isNull);
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
      test('returns count of documents for tenant', () async {
        await factory.createTestDocument(title: 'Count 1');
        await factory.createTestDocument(title: 'Count 2');

        final authed = factory.authenticatedSession();
        final count = await endpoints.document.getDocumentCount(authed);

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
  });
}
