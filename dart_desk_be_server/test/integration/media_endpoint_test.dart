import 'dart:convert';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('Media endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      final client = await factory.createTestClient(slug: 'test-client-media');
      final authed = factory.authenticatedSession();
      await endpoints.user.ensureUser(authed, 'test-client-media', client.apiToken);
    });

    group('uploadImage', () {
      test('uploads PNG and returns URL', () async {
        final result = await factory.uploadTestImage(
          fileName: 'hero.png',
        );

        expect(result.url, isNotEmpty);
        expect(result.id, isNotEmpty);
      });

      test('rejects non-image file type', () async {
        final authed = factory.authenticatedSession();
        final bytes = utf8.encode('not an image');
        final byteData = ByteData.sublistView(Uint8List.fromList(bytes));

        expect(
          () => endpoints.media.uploadImage(authed, 'bad.xyz', byteData),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('uploadFile', () {
      test('uploads text file and returns URL', () async {
        final result = await factory.uploadTestFile(
          fileName: 'document.txt',
          content: 'Hello, world!',
        );

        expect(result.url, isNotEmpty);
        expect(result.id, isNotEmpty);
      });
    });

    group('getMedia', () {
      test('returns media metadata by ID', () async {
        final uploaded = await factory.uploadTestImage();
        final authed = factory.authenticatedSession();
        final mediaId = int.parse(uploaded.id);

        final media = await endpoints.media.getMedia(authed, mediaId);

        expect(media, isNotNull);
        expect(media!.fileName, contains('test_image'));
      });
    });

    group('listMedia', () {
      test('lists uploaded media with pagination', () async {
        await factory.uploadTestImage(fileName: 'img1.png');
        await factory.uploadTestImage(fileName: 'img2.png');
        await factory.uploadTestFile(fileName: 'doc1.txt');

        final authed = factory.authenticatedSession();
        final list = await endpoints.media.listMedia(
          authed,
          limit: 10,
          offset: 0,
        );

        expect(list.length, greaterThanOrEqualTo(3));
      });
    });

    group('deleteMedia', () {
      test('deletes media file', () async {
        final uploaded = await factory.uploadTestImage();
        final authed = factory.authenticatedSession();
        // UploadResponse.id is a String — may be numeric or UUID.
        // Adjust parsing if int.parse throws FormatException.
        final mediaId = int.parse(uploaded.id);

        final deleted = await endpoints.media.deleteMedia(authed, mediaId);
        expect(deleted, isTrue);

        final fetched = await endpoints.media.getMedia(authed, mediaId);
        expect(fetched, isNull);
      });
    });

    group('file size limits', () {
      test('rejects file exceeding 10MB', () async {
        final authed = factory.authenticatedSession();
        // Create a ByteData slightly over 10MB
        final oversized = ByteData(10 * 1024 * 1024 + 1);
        expect(
          () => endpoints.media.uploadImage(authed, 'huge.png', oversized),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
