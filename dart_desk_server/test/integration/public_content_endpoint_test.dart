import 'package:dart_desk_server/src/generated/protocol.dart';
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

        await expectLater(
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
        await expectLater(
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
