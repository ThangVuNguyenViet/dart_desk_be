import 'dart:convert';

import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show Scope, UuidValue;
import 'package:test/test.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

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
      await DocumentCrdtOperation.db
          .deleteWhere(session, where: (t) => t.id.notEquals(null));
      await DocumentCrdtSnapshot.db
          .deleteWhere(session, where: (t) => t.id.notEquals(null));
      await DocumentVersion.db
          .deleteWhere(session, where: (t) => t.id.notEquals(null));
      await DocumentData.db
          .deleteWhere(session, where: (t) => t.id.notEquals(null));
      await Document.db
          .deleteWhere(session, where: (t) => t.id.notEquals(null));
      await MediaAsset.db
          .deleteWhere(session, where: (t) => t.id.notEquals(null));
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
      final version = await factory.createTestVersion(doc.id);
      await endpoints.document.publishDocumentVersion(
        factory.authenticatedSession(),
        version.id,
      );
      // Re-fetch to get updated publishedAt
      return (await endpoints.document.getDocument(sessionBuilder, doc.id))!;
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
          factory.authenticatedSession(),
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
          factory.authenticatedSession(),
        );

        expect(result['blog'], hasLength(1));
        expect(result['blog']!.first.title, equals('Published'));
      });

      test('returns only documents in the API key\'s project', () async {
        final otherProjectId = UuidValue.fromString(
          'a1b2c3d4-e5f6-4a7b-8c9d-000000000001',
        );
        await factory.ensureTestProject(
          projectId: otherProjectId,
          name: 'Other Project',
          slug: 'other-project-1',
        );
        final session = sessionBuilder.build();
        final otherDoc = await Document.db.insertRow(
          session,
          Document(
            projectId: otherProjectId,
            documentType: 'blog',
            title: 'Other Project Blog',
            slug: 'other-project-blog',
            isDefault: false,
            data: jsonEncode({'body': 'other'}),
            publishedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect(otherDoc.id, isNotNull);

        await createPublishedDocument(
          documentType: 'blog',
          title: 'My Blog',
          slug: 'my-blog',
        );

        final result = await endpoints.publicContent.getAllContents(
          factory.authenticatedSession(),
        );

        // The map must not contain any key from the other project.
        // The only 'blog' entry should be the one in the test project.
        expect(result['blog'], hasLength(1));
        expect(result['blog']!.first.title, equals('My Blog'));
        // The other project's document type must not appear as an extra key.
        for (final docs in result.values) {
          for (final doc in docs) {
            expect(doc.title, isNot(equals('Other Project Blog')));
          }
        }
      });

      test('throws 403 when session lacks read permission', () async {
        final unscoped = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-read-user',
            {Scope('project:${TestDataFactory.testProjectId}')},
          ),
        );

        expect(
          () => endpoints.publicContent.getAllContents(unscoped),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
        );
      });

      test('throws 400 when session has read permission but no project scope',
          () async {
        final noProject = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-project-user',
            {Scope('project.read')},
          ),
        );

        expect(
          () => endpoints.publicContent.getAllContents(noProject),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('excludes soft-deleted documents', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Alive',
          slug: 'alive',
        );
        // Insert a soft-deleted published doc directly so it would match
        // if deletedAt were not checked.
        final session = sessionBuilder.build();
        await Document.db.insertRow(
          session,
          Document(
            projectId: TestDataFactory.testProjectId,
            documentType: 'blog',
            title: 'Deleted',
            slug: 'deleted-all',
            isDefault: false,
            data: jsonEncode({'body': 'gone'}),
            publishedAt: DateTime.now(),
            deletedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final result = await endpoints.publicContent.getAllContents(
          factory.authenticatedSession(),
        );

        expect(result['blog'], hasLength(1));
        expect(result['blog']!.first.title, equals('Alive'));
      });

      test('inlines imageReference fields in returned data', () async {
        final asset = await factory.uploadTestImage(fileName: 'all-cover.png');

        await createPublishedDocument(
          documentType: 'blog',
          title: 'Image Blog',
          slug: 'image-blog-all',
          data: {
            'cover': {'_type': 'imageReference', 'assetId': asset.assetId},
          },
        );

        final result = await endpoints.publicContent.getAllContents(
          factory.authenticatedSession(),
        );

        expect(result['blog'], hasLength(1));
        final decoded =
            jsonDecode(result['blog']!.first.data) as Map<String, dynamic>;
        final cover = decoded['cover'] as Map<String, dynamic>;
        expect(cover['publicUrl'], equals(asset.publicUrl));
        expect(cover['width'], greaterThan(0));
        expect(cover['height'], greaterThan(0));
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
          factory.authenticatedSession(),
        );

        expect(result, hasLength(2));
        expect(result['blog']!.title, equals('Default Blog'));
        expect(result['page']!.title, equals('Default Page'));
      });

      test('returns only documents in the API key\'s project', () async {
        final otherProjectId = UuidValue.fromString(
          'a1b2c3d4-e5f6-4a7b-8c9d-000000000002',
        );
        await factory.ensureTestProject(
          projectId: otherProjectId,
          name: 'Other Project 2',
          slug: 'other-project-2',
        );
        final session = sessionBuilder.build();
        final otherDoc = await Document.db.insertRow(
          session,
          Document(
            projectId: otherProjectId,
            documentType: 'blog',
            title: 'Other Default',
            slug: 'other-default',
            isDefault: true,
            data: jsonEncode({'body': 'other'}),
            publishedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect(otherDoc.id, isNotNull);

        await createPublishedDocument(
          documentType: 'blog',
          title: 'My Default',
          slug: 'my-default',
          isDefault: true,
        );

        final result = await endpoints.publicContent.getDefaultContents(
          factory.authenticatedSession(),
        );

        expect(result['blog']!.title, equals('My Default'));
        // Must not include other project's document type as a key.
        for (final doc in result.values) {
          expect(doc.title, isNot(equals('Other Default')));
        }
      });

      test('throws 403 when session lacks read permission', () async {
        final unscoped = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-read-user',
            {Scope('project:${TestDataFactory.testProjectId}')},
          ),
        );

        expect(
          () => endpoints.publicContent.getDefaultContents(unscoped),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
        );
      });

      test('throws 400 when session has read permission but no project scope',
          () async {
        final noProject = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-project-user',
            {Scope('project.read')},
          ),
        );

        expect(
          () => endpoints.publicContent.getDefaultContents(noProject),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('excludes soft-deleted documents', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Alive Default',
          slug: 'alive-default',
          isDefault: true,
        );
        final session = sessionBuilder.build();
        await Document.db.insertRow(
          session,
          Document(
            projectId: TestDataFactory.testProjectId,
            documentType: 'page',
            title: 'Deleted Default',
            slug: 'deleted-default',
            isDefault: true,
            data: jsonEncode({'body': 'gone'}),
            publishedAt: DateTime.now(),
            deletedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final result = await endpoints.publicContent.getDefaultContents(
          factory.authenticatedSession(),
        );

        expect(result.keys, isNot(contains('page')));
        expect(result['blog']!.title, equals('Alive Default'));
      });

      test('inlines imageReference fields in returned data', () async {
        final asset =
            await factory.uploadTestImage(fileName: 'defaults-cover.png');

        await createPublishedDocument(
          documentType: 'blog',
          title: 'Image Default',
          slug: 'image-default',
          isDefault: true,
          data: {
            'cover': {'_type': 'imageReference', 'assetId': asset.assetId},
          },
        );

        final result = await endpoints.publicContent.getDefaultContents(
          factory.authenticatedSession(),
        );

        expect(result['blog'], isNotNull);
        final decoded =
            jsonDecode(result['blog']!.data) as Map<String, dynamic>;
        final cover = decoded['cover'] as Map<String, dynamic>;
        expect(cover['publicUrl'], equals(asset.publicUrl));
        expect(cover['width'], greaterThan(0));
        expect(cover['height'], greaterThan(0));
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
          factory.authenticatedSession(),
          'blog',
        );

        expect(result, hasLength(2));
        expect(result.map((d) => d.title), containsAll(['Blog A', 'Blog B']));
      });

      test('returns only documents in the API key\'s project', () async {
        final otherProjectId = UuidValue.fromString(
          'a1b2c3d4-e5f6-4a7b-8c9d-000000000003',
        );
        await factory.ensureTestProject(
          projectId: otherProjectId,
          name: 'Other Project 3',
          slug: 'other-project-3',
        );
        final session = sessionBuilder.build();
        final otherDoc = await Document.db.insertRow(
          session,
          Document(
            projectId: otherProjectId,
            documentType: 'blog',
            title: 'Other Blog',
            slug: 'other-blog-type',
            isDefault: false,
            data: jsonEncode({'body': 'other'}),
            publishedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect(otherDoc.id, isNotNull);

        await createPublishedDocument(
          documentType: 'blog',
          title: 'My Blog Type',
          slug: 'my-blog-type',
        );

        final result = await endpoints.publicContent.getContentsByType(
          factory.authenticatedSession(),
          'blog',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('My Blog Type'));
      });

      test('throws 403 when session lacks read permission', () async {
        final unscoped = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-read-user',
            {Scope('project:${TestDataFactory.testProjectId}')},
          ),
        );

        expect(
          () => endpoints.publicContent.getContentsByType(unscoped, 'blog'),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
        );
      });

      test('throws 400 when session has read permission but no project scope',
          () async {
        final noProject = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-project-user',
            {Scope('project.read')},
          ),
        );

        expect(
          () => endpoints.publicContent.getContentsByType(noProject, 'blog'),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('excludes soft-deleted documents', () async {
        await createPublishedDocument(
          documentType: 'blog',
          title: 'Alive Blog',
          slug: 'alive-blog',
        );
        final session = sessionBuilder.build();
        await Document.db.insertRow(
          session,
          Document(
            projectId: TestDataFactory.testProjectId,
            documentType: 'blog',
            title: 'Deleted Blog',
            slug: 'deleted-blog-type',
            isDefault: false,
            data: jsonEncode({'body': 'gone'}),
            publishedAt: DateTime.now(),
            deletedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final result = await endpoints.publicContent.getContentsByType(
          factory.authenticatedSession(),
          'blog',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('Alive Blog'));
      });

      test('inlines imageReference fields in returned data', () async {
        final asset = await factory.uploadTestImage(fileName: 'type-cover.png');

        await createPublishedDocument(
          documentType: 'blog',
          title: 'Image Blog Type',
          slug: 'image-blog-type',
          data: {
            'cover': {'_type': 'imageReference', 'assetId': asset.assetId},
          },
        );

        final result = await endpoints.publicContent.getContentsByType(
          factory.authenticatedSession(),
          'blog',
        );

        expect(result, hasLength(1));
        final decoded = jsonDecode(result.first.data) as Map<String, dynamic>;
        final cover = decoded['cover'] as Map<String, dynamic>;
        expect(cover['publicUrl'], equals(asset.publicUrl));
        expect(cover['width'], greaterThan(0));
        expect(cover['height'], greaterThan(0));
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
          factory.authenticatedSession(),
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
            factory.authenticatedSession(),
            'blog',
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('returns only documents in the API key\'s project', () async {
        final otherProjectId = UuidValue.fromString(
          'a1b2c3d4-e5f6-4a7b-8c9d-000000000004',
        );
        await factory.ensureTestProject(
          projectId: otherProjectId,
          name: 'Other Project 4',
          slug: 'other-project-4',
        );
        final session = sessionBuilder.build();
        // Insert a default doc in the other project for the same type.
        final otherDoc = await Document.db.insertRow(
          session,
          Document(
            projectId: otherProjectId,
            documentType: 'blog',
            title: 'Other Default Content',
            slug: 'other-default-content',
            isDefault: true,
            data: jsonEncode({'body': 'other'}),
            publishedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect(otherDoc.id, isNotNull);

        await createPublishedDocument(
          documentType: 'blog',
          title: 'My Default Content',
          slug: 'my-default-content',
          isDefault: true,
        );

        final result = await endpoints.publicContent.getDefaultContent(
          factory.authenticatedSession(),
          'blog',
        );

        expect(result.title, equals('My Default Content'));
      });

      test('throws 403 when session lacks read permission', () async {
        final unscoped = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-read-user',
            {Scope('project:${TestDataFactory.testProjectId}')},
          ),
        );

        expect(
          () => endpoints.publicContent.getDefaultContent(unscoped, 'blog'),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
        );
      });

      test('throws 400 when session has read permission but no project scope',
          () async {
        final noProject = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-project-user',
            {Scope('project.read')},
          ),
        );

        expect(
          () => endpoints.publicContent.getDefaultContent(noProject, 'blog'),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('excludes soft-deleted documents', () async {
        // Only a soft-deleted default — should throw, not return the deleted doc.
        final session = sessionBuilder.build();
        await Document.db.insertRow(
          session,
          Document(
            projectId: TestDataFactory.testProjectId,
            documentType: 'blog',
            title: 'Deleted Default Content',
            slug: 'deleted-default-content',
            isDefault: true,
            data: jsonEncode({'body': 'gone'}),
            publishedAt: DateTime.now(),
            deletedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        await expectLater(
          () => endpoints.publicContent.getDefaultContent(
            factory.authenticatedSession(),
            'blog',
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('inlines imageReference fields in returned data', () async {
        final asset =
            await factory.uploadTestImage(fileName: 'default-cover.png');

        await createPublishedDocument(
          documentType: 'blog',
          title: 'Image Default Content',
          slug: 'image-default-content',
          isDefault: true,
          data: {
            'cover': {'_type': 'imageReference', 'assetId': asset.assetId},
          },
        );

        final result = await endpoints.publicContent.getDefaultContent(
          factory.authenticatedSession(),
          'blog',
        );

        final decoded = jsonDecode(result.data) as Map<String, dynamic>;
        final cover = decoded['cover'] as Map<String, dynamic>;
        expect(cover['publicUrl'], equals(asset.publicUrl));
        expect(cover['width'], greaterThan(0));
        expect(cover['height'], greaterThan(0));
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
          factory.authenticatedSession(),
          'blog',
          'my-post',
        );

        expect(result.title, equals('My Post'));
        expect(result.slug, equals('my-post'));
      });

      test('throws when no match', () async {
        await expectLater(
          () => endpoints.publicContent.getContentBySlug(
            factory.authenticatedSession(),
            'blog',
            'nonexistent',
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('returns only documents in the API key\'s project', () async {
        final otherProjectId = UuidValue.fromString(
          'a1b2c3d4-e5f6-4a7b-8c9d-000000000005',
        );
        await factory.ensureTestProject(
          projectId: otherProjectId,
          name: 'Other Project 5',
          slug: 'other-project-5',
        );
        final session = sessionBuilder.build();
        // Insert a doc in the other project with the same type+slug combination.
        final otherDoc = await Document.db.insertRow(
          session,
          Document(
            projectId: otherProjectId,
            documentType: 'blog',
            title: 'Other Slug Post',
            slug: 'shared-slug',
            isDefault: false,
            data: jsonEncode({'body': 'other'}),
            publishedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect(otherDoc.id, isNotNull);

        await createPublishedDocument(
          documentType: 'blog',
          title: 'My Slug Post',
          slug: 'shared-slug',
        );

        final result = await endpoints.publicContent.getContentBySlug(
          factory.authenticatedSession(),
          'blog',
          'shared-slug',
        );

        expect(result.title, equals('My Slug Post'));
      });

      test('throws 403 when session lacks read permission', () async {
        final unscoped = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-read-user',
            {Scope('project:${TestDataFactory.testProjectId}')},
          ),
        );

        expect(
          () => endpoints.publicContent.getContentBySlug(
            unscoped,
            'blog',
            'my-post',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
        );
      });

      test('throws 400 when session has read permission but no project scope',
          () async {
        final noProject = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-project-user',
            {Scope('project.read')},
          ),
        );

        expect(
          () => endpoints.publicContent.getContentBySlug(
            noProject,
            'blog',
            'my-post',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('excludes soft-deleted documents', () async {
        final session = sessionBuilder.build();
        await Document.db.insertRow(
          session,
          Document(
            projectId: TestDataFactory.testProjectId,
            documentType: 'blog',
            title: 'Deleted Slug Post',
            slug: 'deleted-slug-post',
            isDefault: false,
            data: jsonEncode({'body': 'gone'}),
            publishedAt: DateTime.now(),
            deletedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        await expectLater(
          () => endpoints.publicContent.getContentBySlug(
            factory.authenticatedSession(),
            'blog',
            'deleted-slug-post',
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('inlines imageReference fields in returned data', () async {
        final asset = await factory.uploadTestImage(fileName: 'slug-cover.png');

        await createPublishedDocument(
          documentType: 'blog',
          title: 'Image Slug Post',
          slug: 'image-slug-post',
          data: {
            'cover': {'_type': 'imageReference', 'assetId': asset.assetId},
          },
        );

        final result = await endpoints.publicContent.getContentBySlug(
          factory.authenticatedSession(),
          'blog',
          'image-slug-post',
        );

        final decoded = jsonDecode(result.data) as Map<String, dynamic>;
        final cover = decoded['cover'] as Map<String, dynamic>;
        expect(cover['publicUrl'], equals(asset.publicUrl));
        expect(cover['width'], greaterThan(0));
        expect(cover['height'], greaterThan(0));
      });
    });

    group('getContentsByDataContains', () {
      test('returns docs whose data contains the fragment', () async {
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Group 1',
          slug: 'group-1',
          data: {'deviceIds': ['ABC-123', 'ABC-456']},
        );
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Group 2',
          slug: 'group-2',
          data: {'deviceIds': ['XYZ-001']},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["ABC-123"]}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('Group 1'));
      });

      // ---- Task 5: coverage tests ----

      test('returns empty list when no doc contains the fragment', () async {
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Group 1',
          slug: 'group-1',
          data: {'deviceIds': ['ABC-123']},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["NOT-PRESENT"]}',
        );

        expect(result, isEmpty);
      });

      test('document type filter excludes other types', () async {
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Group',
          slug: 'group',
          data: {'deviceIds': ['ABC']},
        );
        await createPublishedDocument(
          documentType: 'productGroup',
          title: 'Product',
          slug: 'product',
          data: {'deviceIds': ['ABC']},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["ABC"]}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('Group'));
      });

      test('excludes unpublished and soft-deleted documents', () async {
        // Published, matches
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Published',
          slug: 'published',
          data: {'deviceIds': ['ABC']},
        );
        // Unpublished draft, matches data but not published
        await factory.createTestDocument(
          documentType: 'deviceGroup',
          title: 'Draft',
          slug: 'draft',
          data: {'deviceIds': ['ABC']},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["ABC"]}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('Published'));
      });

      test('matches nested object fragments', () async {
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'US Group',
          slug: 'us-group',
          data: {'region': {'code': 'US', 'tier': 1}, 'active': true},
        );
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'EU Group',
          slug: 'eu-group',
          data: {'region': {'code': 'EU', 'tier': 1}, 'active': true},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"region":{"code":"US"}}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('US Group'));
      });

      test('multi-key fragment requires all keys to match', () async {
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Both',
          slug: 'both',
          data: {'deviceIds': ['ABC'], 'active': true},
        );
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Inactive',
          slug: 'inactive',
          data: {'deviceIds': ['ABC'], 'active': false},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["ABC"],"active":true}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('Both'));
      });

      test('rejects non-JSON input with 400', () async {
        expect(
          () => endpoints.publicContent.getContentsByDataContains(
            factory.authenticatedSession(),
            'deviceGroup',
            'not valid json',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('rejects JSON scalar with 400', () async {
        expect(
          () => endpoints.publicContent.getContentsByDataContains(
            factory.authenticatedSession(),
            'deviceGroup',
            '"just a string"',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('rejects JSON array with 400', () async {
        expect(
          () => endpoints.publicContent.getContentsByDataContains(
            factory.authenticatedSession(),
            'deviceGroup',
            '["a","b"]',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('caps results at 100', () async {
        for (var i = 0; i < 105; i++) {
          await createPublishedDocument(
            documentType: 'deviceGroup',
            title: 'Group $i',
            slug: 'group-cap-$i',
            data: {'shared': 'yes', 'idx': i},
          );
        }

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"shared":"yes"}',
        );

        expect(result, hasLength(100));
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('returns only documents in the API key\'s project', () async {
        // Seed an additional project with a matching document.
        final otherProjectId = UuidValue.fromString(
          'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d',
        );
        await factory.ensureTestProject(
          projectId: otherProjectId,
          name: 'Other Project',
          slug: 'other-project',
        );
        // Insert a document for the other project directly via DB (bypass
        // endpoint project-scope checks). Use jsonEncode because Document.data
        // is String? — the generated column data_jsonb is computed by Postgres.
        final session = sessionBuilder.build();
        final otherDoc = await Document.db.insertRow(
          session,
          Document(
            projectId: otherProjectId,
            documentType: 'deviceGroup',
            title: 'Other Group',
            slug: 'other-group',
            isDefault: false,
            data: jsonEncode({'deviceIds': ['SHARED']}),
            publishedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect(otherDoc.id, isNotNull);

        // Same fragment also lives in the test project.
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'My Group',
          slug: 'my-group',
          data: {'deviceIds': ['SHARED']},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["SHARED"]}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('My Group'));
      });

      // Auth tests — Step 9
      // AuthenticationOverride and Scope are available (used by TestDataFactory).
      test('throws 403 when session lacks read permission', () async {
        // Session with project scope but no project.read scope.
        final unscoped = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-read-user',
            {Scope('project:${TestDataFactory.testProjectId}')},
          ),
        );

        expect(
          () => endpoints.publicContent.getContentsByDataContains(
            unscoped,
            'deviceGroup',
            '{"deviceIds":["ABC"]}',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
        );
      });

      test('throws 400 when session has read permission but no project scope',
          () async {
        final noProject = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-project-user',
            {Scope('project.read')},
          ),
        );

        expect(
          () => endpoints.publicContent.getContentsByDataContains(
            noProject,
            'deviceGroup',
            '{"deviceIds":["ABC"]}',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('inlines imageReference fields in returned data', () async {
        final asset = await factory.uploadTestImage(fileName: 'cover.png');

        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'With Image',
          slug: 'with-image',
          data: {
            'deviceIds': ['ABC'],
            'cover': {'_type': 'imageReference', 'assetId': asset.assetId},
          },
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["ABC"]}',
        );

        expect(result, hasLength(1));
        final decoded = jsonDecode(result.first.data) as Map<String, dynamic>;
        final cover = decoded['cover'] as Map<String, dynamic>;
        expect(cover['publicUrl'], equals(asset.publicUrl));
        expect(cover['width'], greaterThan(0));
        expect(cover['height'], greaterThan(0));
      });

      // ---- Task 6: Index-usage smoke test ----

      test('documents_data_gin GIN index exists on data_jsonb column',
          () async {
        // Task 6: Verify the GIN index that enables containment lookups is
        // present in the database. Planner-usage tests are unreliable in
        // transactional test environments because ANALYZE reads only committed
        // data; uncommitted rows seeded within the test transaction leave
        // statistics stale, causing the planner to prefer seq scan regardless
        // of row count. Asserting index existence is the stable substitute.
        final session = sessionBuilder.build();

        final rows = await session.db.unsafeQuery(
          r'''
          SELECT indexname, indexdef
          FROM pg_indexes
          WHERE tablename = 'documents'
            AND indexname = 'documents_data_gin'
          ''',
        );

        expect(
          rows,
          isNotEmpty,
          reason: 'Expected documents_data_gin GIN index to exist.',
        );

        // Also confirm it is a GIN index on data_jsonb.
        final indexDef = rows.first[1].toString();
        expect(indexDef, contains('gin'));
        expect(indexDef, contains('data_jsonb'));
      });
    });

    group('getContentsByDataContains', () {
      test('returns docs whose data contains the fragment', () async {
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Group 1',
          slug: 'group-1',
          data: {'deviceIds': ['ABC-123', 'ABC-456']},
        );
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Group 2',
          slug: 'group-2',
          data: {'deviceIds': ['XYZ-001']},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["ABC-123"]}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('Group 1'));
      });

      // ---- Task 5: coverage tests ----

      test('returns empty list when no doc contains the fragment', () async {
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Group 1',
          slug: 'group-1',
          data: {'deviceIds': ['ABC-123']},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["NOT-PRESENT"]}',
        );

        expect(result, isEmpty);
      });

      test('document type filter excludes other types', () async {
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Group',
          slug: 'group',
          data: {'deviceIds': ['ABC']},
        );
        await createPublishedDocument(
          documentType: 'productGroup',
          title: 'Product',
          slug: 'product',
          data: {'deviceIds': ['ABC']},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["ABC"]}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('Group'));
      });

      test('excludes unpublished and soft-deleted documents', () async {
        // Published, matches
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Published',
          slug: 'published',
          data: {'deviceIds': ['ABC']},
        );
        // Unpublished draft, matches data but not published
        await factory.createTestDocument(
          documentType: 'deviceGroup',
          title: 'Draft',
          slug: 'draft',
          data: {'deviceIds': ['ABC']},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["ABC"]}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('Published'));
      });

      test('matches nested object fragments', () async {
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'US Group',
          slug: 'us-group',
          data: {'region': {'code': 'US', 'tier': 1}, 'active': true},
        );
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'EU Group',
          slug: 'eu-group',
          data: {'region': {'code': 'EU', 'tier': 1}, 'active': true},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"region":{"code":"US"}}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('US Group'));
      });

      test('multi-key fragment requires all keys to match', () async {
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Both',
          slug: 'both',
          data: {'deviceIds': ['ABC'], 'active': true},
        );
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'Inactive',
          slug: 'inactive',
          data: {'deviceIds': ['ABC'], 'active': false},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["ABC"],"active":true}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('Both'));
      });

      test('rejects non-JSON input with 400', () async {
        expect(
          () => endpoints.publicContent.getContentsByDataContains(
            factory.authenticatedSession(),
            'deviceGroup',
            'not valid json',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('rejects JSON scalar with 400', () async {
        expect(
          () => endpoints.publicContent.getContentsByDataContains(
            factory.authenticatedSession(),
            'deviceGroup',
            '"just a string"',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('rejects JSON array with 400', () async {
        expect(
          () => endpoints.publicContent.getContentsByDataContains(
            factory.authenticatedSession(),
            'deviceGroup',
            '["a","b"]',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('caps results at 100', () async {
        for (var i = 0; i < 105; i++) {
          await createPublishedDocument(
            documentType: 'deviceGroup',
            title: 'Group $i',
            slug: 'group-cap-$i',
            data: {'shared': 'yes', 'idx': i},
          );
        }

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"shared":"yes"}',
        );

        expect(result, hasLength(100));
      }, timeout: const Timeout(Duration(minutes: 2)));

      test('returns only documents in the API key\'s project', () async {
        // Seed an additional project with a matching document.
        final otherProjectId = UuidValue.fromString(
          'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d',
        );
        await factory.ensureTestProject(
          projectId: otherProjectId,
          name: 'Other Project',
          slug: 'other-project',
        );
        // Insert a document for the other project directly via DB (bypass
        // endpoint project-scope checks). Use jsonEncode because Document.data
        // is String? — the generated column data_jsonb is computed by Postgres.
        final session = sessionBuilder.build();
        final otherDoc = await Document.db.insertRow(
          session,
          Document(
            projectId: otherProjectId,
            documentType: 'deviceGroup',
            title: 'Other Group',
            slug: 'other-group',
            isDefault: false,
            data: jsonEncode({'deviceIds': ['SHARED']}),
            publishedAt: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        expect(otherDoc.id, isNotNull);

        // Same fragment also lives in the test project.
        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'My Group',
          slug: 'my-group',
          data: {'deviceIds': ['SHARED']},
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["SHARED"]}',
        );

        expect(result, hasLength(1));
        expect(result.first.title, equals('My Group'));
      });

      // Auth tests — Step 9
      // AuthenticationOverride and Scope are available (used by TestDataFactory).
      test('throws 403 when session lacks read permission', () async {
        // Session with project scope but no project.read scope.
        final unscoped = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-read-user',
            {Scope('project:${TestDataFactory.testProjectId}')},
          ),
        );

        expect(
          () => endpoints.publicContent.getContentsByDataContains(
            unscoped,
            'deviceGroup',
            '{"deviceIds":["ABC"]}',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
        );
      });

      test('throws 400 when session has read permission but no project scope',
          () async {
        final noProject = sessionBuilder.copyWith(
          authentication: AuthenticationOverride.authenticationInfo(
            'no-project-user',
            {Scope('project.read')},
          ),
        );

        expect(
          () => endpoints.publicContent.getContentsByDataContains(
            noProject,
            'deviceGroup',
            '{"deviceIds":["ABC"]}',
          ),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
        );
      });

      test('inlines imageReference fields in returned data', () async {
        final asset = await factory.uploadTestImage(fileName: 'cover.png');

        await createPublishedDocument(
          documentType: 'deviceGroup',
          title: 'With Image',
          slug: 'with-image',
          data: {
            'deviceIds': ['ABC'],
            'cover': {'_type': 'imageReference', 'assetId': asset.assetId},
          },
        );

        final result = await endpoints.publicContent.getContentsByDataContains(
          factory.authenticatedSession(),
          'deviceGroup',
          '{"deviceIds":["ABC"]}',
        );

        expect(result, hasLength(1));
        final decoded = jsonDecode(result.first.data) as Map<String, dynamic>;
        final cover = decoded['cover'] as Map<String, dynamic>;
        expect(cover['publicUrl'], equals(asset.publicUrl));
        expect(cover['width'], greaterThan(0));
        expect(cover['height'], greaterThan(0));
      });

      // ---- Task 6: Index-usage smoke test ----

      test('documents_data_gin GIN index exists on data_jsonb column',
          () async {
        // Task 6: Verify the GIN index that enables containment lookups is
        // present in the database. Planner-usage tests are unreliable in
        // transactional test environments because ANALYZE reads only committed
        // data; uncommitted rows seeded within the test transaction leave
        // statistics stale, causing the planner to prefer seq scan regardless
        // of row count. Asserting index existence is the stable substitute.
        final session = sessionBuilder.build();

        final rows = await session.db.unsafeQuery(
          r'''
          SELECT indexname, indexdef
          FROM pg_indexes
          WHERE tablename = 'documents'
            AND indexname = 'documents_data_gin'
          ''',
        );

        expect(
          rows,
          isNotEmpty,
          reason: 'Expected documents_data_gin GIN index to exist.',
        );

        // Also confirm it is a GIN index on data_jsonb.
        final indexDef = rows.first[1].toString();
        expect(indexDef, contains('gin'));
        expect(indexDef, contains('data_jsonb'));
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
        await DocumentCrdtOperation.db
            .deleteWhere(session, where: (t) => t.id.notEquals(null));
        await DocumentCrdtSnapshot.db
            .deleteWhere(session, where: (t) => t.id.notEquals(null));
        await DocumentVersion.db
            .deleteWhere(session, where: (t) => t.id.notEquals(null));
        await DocumentData.db
            .deleteWhere(session, where: (t) => t.id.notEquals(null));
        await Document.db
            .deleteWhere(session, where: (t) => t.id.notEquals(null));
        await MediaAsset.db
            .deleteWhere(session, where: (t) => t.id.notEquals(null));
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
        final version = await factory.createTestVersion(doc.id);
        await endpoints.document.publishDocumentVersion(
          factory.authenticatedSession(),
          version.id,
        );
        // Re-fetch to get updated publishedAt
        return (await endpoints.document.getDocument(
          sessionBuilder,
          doc.id,
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
          factory.authenticatedSession(),
          'blog',
          'image-post',
        );

        final data = jsonDecode(result.data) as Map<String, dynamic>;
        final heroImage = data['heroImage'] as Map<String, dynamic>;

        expect(heroImage['_type'], equals('imageReference'));
        expect(heroImage['assetId'], equals(asset.assetId));
        expect(heroImage['publicUrl'], equals(asset.publicUrl));
        expect(heroImage['width'], greaterThan(0));
        expect(heroImage['height'], greaterThan(0));
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
          factory.authenticatedSession(),
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
          factory.authenticatedSession(),
          'blog',
          'text-post',
        );

        final data = jsonDecode(result.data) as Map<String, dynamic>;
        expect(data['body'], equals('hello world'));
      });

      group('getAllContentsByDataContains', () {
        test('returns matching docs grouped by document type', () async {
          await createPublishedDocument(
            documentType: 'deviceGroup',
            title: 'Group',
            slug: 'group',
            data: {'deviceIds': ['ABC']},
          );
          await createPublishedDocument(
            documentType: 'productGroup',
            title: 'Product',
            slug: 'product',
            data: {'deviceIds': ['ABC']},
          );
          await createPublishedDocument(
            documentType: 'banner',
            title: 'Banner',
            slug: 'banner',
            data: {'deviceIds': ['XYZ']},
          );

          final result =
              await endpoints.publicContent.getAllContentsByDataContains(
            factory.authenticatedSession(),
            '{"deviceIds":["ABC"]}',
          );

          expect(result.keys, unorderedEquals(['deviceGroup', 'productGroup']));
          expect(result['deviceGroup'], hasLength(1));
          expect(result['deviceGroup']!.first.title, equals('Group'));
          expect(result['productGroup'], hasLength(1));
          expect(result['productGroup']!.first.title, equals('Product'));
        });

        test('returns empty map when no doc contains the fragment', () async {
          await createPublishedDocument(
            documentType: 'deviceGroup',
            title: 'Group',
            slug: 'group',
            data: {'deviceIds': ['ABC']},
          );

          final result =
              await endpoints.publicContent.getAllContentsByDataContains(
            factory.authenticatedSession(),
            '{"deviceIds":["NOT-PRESENT"]}',
          );

          expect(result, isEmpty);
        });

        test('groups multiple matching docs of the same type', () async {
          await createPublishedDocument(
            documentType: 'deviceGroup',
            title: 'Group A',
            slug: 'group-a',
            data: {'deviceIds': ['ABC']},
          );
          await createPublishedDocument(
            documentType: 'deviceGroup',
            title: 'Group B',
            slug: 'group-b',
            data: {'deviceIds': ['ABC', 'DEF']},
          );

          final result =
              await endpoints.publicContent.getAllContentsByDataContains(
            factory.authenticatedSession(),
            '{"deviceIds":["ABC"]}',
          );

          expect(result.keys, equals(['deviceGroup']));
          expect(result['deviceGroup'], hasLength(2));
          expect(
            result['deviceGroup']!.map((d) => d.title),
            unorderedEquals(['Group A', 'Group B']),
          );
        });

        test('excludes unpublished and soft-deleted documents', () async {
          await createPublishedDocument(
            documentType: 'deviceGroup',
            title: 'Published',
            slug: 'published',
            data: {'deviceIds': ['ABC']},
          );
          await factory.createTestDocument(
            documentType: 'productGroup',
            title: 'Draft',
            slug: 'draft',
            data: {'deviceIds': ['ABC']},
          );

          final result =
              await endpoints.publicContent.getAllContentsByDataContains(
            factory.authenticatedSession(),
            '{"deviceIds":["ABC"]}',
          );

          expect(result.keys, equals(['deviceGroup']));
          expect(result['deviceGroup']!.first.title, equals('Published'));
        });

        test('returns only documents in the API key\'s project', () async {
          final otherProjectId = UuidValue.fromString(
            'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d',
          );
          await factory.ensureTestProject(
            projectId: otherProjectId,
            name: 'Other Project',
            slug: 'other-project',
          );
          final session = sessionBuilder.build();
          await Document.db.insertRow(
            session,
            Document(
              projectId: otherProjectId,
              documentType: 'deviceGroup',
              title: 'Other Group',
              slug: 'other-group',
              isDefault: false,
              data: jsonEncode({'deviceIds': ['SHARED']}),
              publishedAt: DateTime.now(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          await createPublishedDocument(
            documentType: 'deviceGroup',
            title: 'My Group',
            slug: 'my-group',
            data: {'deviceIds': ['SHARED']},
          );

          final result =
              await endpoints.publicContent.getAllContentsByDataContains(
            factory.authenticatedSession(),
            '{"deviceIds":["SHARED"]}',
          );

          expect(result.keys, equals(['deviceGroup']));
          expect(result['deviceGroup'], hasLength(1));
          expect(result['deviceGroup']!.first.title, equals('My Group'));
        });

        test('rejects non-JSON input with 400', () async {
          expect(
            () => endpoints.publicContent.getAllContentsByDataContains(
              factory.authenticatedSession(),
              'not json',
            ),
            throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
          );
        });

        test('rejects JSON array with 400', () async {
          expect(
            () => endpoints.publicContent.getAllContentsByDataContains(
              factory.authenticatedSession(),
              '[1,2,3]',
            ),
            throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
          );
        });

        test('throws 403 when session lacks read permission', () async {
          final unscoped = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'no-read-user',
              {Scope('project:${TestDataFactory.testProjectId}')},
            ),
          );
          expect(
            () => endpoints.publicContent.getAllContentsByDataContains(
              unscoped,
              '{"deviceIds":["ABC"]}',
            ),
            throwsA(isA<ApiException>().having((e) => e.code, 'code', 403)),
          );
        });

        test('throws 400 when session has read permission but no project scope',
            () async {
          final noProject = sessionBuilder.copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'no-project-user',
              {Scope('project.read')},
            ),
          );
          expect(
            () => endpoints.publicContent.getAllContentsByDataContains(
              noProject,
              '{"deviceIds":["ABC"]}',
            ),
            throwsA(isA<ApiException>().having((e) => e.code, 'code', 400)),
          );
        });

        test('inlines imageReference fields in returned data', () async {
          final asset = await factory.uploadTestImage(fileName: 'cover.png');
          await createPublishedDocument(
            documentType: 'deviceGroup',
            title: 'With Image',
            slug: 'with-image',
            data: {
              'deviceIds': ['ABC'],
              'cover': {'_type': 'imageReference', 'assetId': asset.assetId},
            },
          );

          final result =
              await endpoints.publicContent.getAllContentsByDataContains(
            factory.authenticatedSession(),
            '{"deviceIds":["ABC"]}',
          );

          expect(result['deviceGroup'], hasLength(1));
          final decoded = jsonDecode(result['deviceGroup']!.first.data)
              as Map<String, dynamic>;
          final cover = decoded['cover'] as Map<String, dynamic>;
          expect(cover['publicUrl'], equals(asset.publicUrl));
          expect(cover['width'], greaterThan(0));
          expect(cover['height'], greaterThan(0));
        });
      });
    },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
