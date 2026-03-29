import 'dart:convert';

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

      // Clean up leftover data from rollback-disabled groups.
      final session = sessionBuilder.build();
      await DocumentCrdtOperation.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
      await DocumentCrdtSnapshot.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
      await DocumentVersion.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
      await DocumentData.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
      await Document.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
      await MediaAsset.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
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

  withServerpod(
    'PublicContent image reference resolution',
    (sessionBuilder, endpoints) {
      late TestDataFactory factory;

      setUp(() async {
        TestDataFactory.initializeCrdtService();
        factory = TestDataFactory(
          sessionBuilder: sessionBuilder,
          endpoints: endpoints,
        );
        await factory.ensureTestUser();

        // Clean up leftover data from previous runs (rollback disabled).
        final session = sessionBuilder.build();
        await DocumentCrdtOperation.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
        await DocumentCrdtSnapshot.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
        await DocumentVersion.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
        await DocumentData.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
        await Document.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
        await MediaAsset.db.deleteWhere(session, where: (t) => t.id.notEquals(null));
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
        return (await endpoints.document.getDocument(
          sessionBuilder,
          doc.id!,
        ))!;
      }

      test('inlines asset fields into imageReference nodes', () async {
        final asset = await factory.uploadTestImage();

        await createPublishedDocument(
          documentType: 'blog',
          title: 'Image Post',
          slug: 'image-post',
          data: {
            'title': 'Hello',
            'heroImage': {
              '_type': 'imageReference',
              'assetId': asset.assetId,
            },
          },
        );

        final result = await endpoints.publicContent.getContentBySlug(
          sessionBuilder,
          'blog',
          'image-post',
        );

        final data = jsonDecode(result.data) as Map<String, dynamic>;
        final heroImage = data['heroImage'] as Map<String, dynamic>;

        expect(heroImage['_type'], equals('imageReference'));
        expect(heroImage['assetId'], equals(asset.assetId));
        expect(heroImage['publicUrl'], equals(asset.publicUrl));
        expect(heroImage['width'], equals(1));
        expect(heroImage['height'], equals(1));
        expect(heroImage['blurHash'], isNotEmpty);
      });

      test('resolves nested imageReference inside a list', () async {
        final asset = await factory.uploadTestImage();

        await createPublishedDocument(
          documentType: 'blog',
          title: 'Gallery Post',
          slug: 'gallery-post',
          data: {
            'gallery': [
              {
                '_type': 'imageReference',
                'assetId': asset.assetId,
              },
            ],
          },
        );

        final result = await endpoints.publicContent.getContentBySlug(
          sessionBuilder,
          'blog',
          'gallery-post',
        );

        final data = jsonDecode(result.data) as Map<String, dynamic>;
        final gallery = data['gallery'] as List<dynamic>;
        final firstImage = gallery.first as Map<String, dynamic>;

        expect(firstImage['publicUrl'], equals(asset.publicUrl));
      });

      test('document with no imageReference nodes is unchanged', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Text Post',
          slug: 'text-post',
          data: {'body': 'hello world'},
        );

        final result = await endpoints.publicContent.getContentBySlug(
          sessionBuilder,
          'blog',
          'text-post',
        );

        final data = jsonDecode(result.data) as Map<String, dynamic>;
        expect(data['body'], equals('hello world'));
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
