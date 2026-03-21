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
      await factory.ensureTestUser();
    });

    group('uploadImage', () {
      test('uploads PNG and returns asset', () async {
        final result = await factory.uploadTestImage(fileName: 'hero.png');

        expect(result.publicUrl, isNotEmpty);
        expect(result.assetId, isNotEmpty);
      });

      test('rejects non-image file type', () async {
        final authed = factory.authenticatedSession();
        final bytes = utf8.encode('not an image');
        final byteData = ByteData.sublistView(Uint8List.fromList(bytes));

        expect(
          () => endpoints.media.uploadImage(
            authed, 'bad.xyz', byteData, 1, 1, false, '', 'hash',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('uploadFile', () {
      test('uploads text file and returns asset', () async {
        final result = await factory.uploadTestFile(
          fileName: 'document.txt',
          content: 'Hello, world!',
        );

        expect(result.publicUrl, isNotEmpty);
        expect(result.assetId, isNotEmpty);
      });
    });

    group('getMedia', () {
      test('returns media metadata by assetId', () async {
        final uploaded = await factory.uploadTestImage();
        final authed = factory.authenticatedSession();

        final media = await endpoints.media.getMedia(authed, uploaded.assetId);

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
          authed, sortBy: 'createdAt', limit: 10, offset: 0,
        );

        expect(list.length, greaterThanOrEqualTo(3));
      });
    });

    group('deleteMedia', () {
      test('deletes media file', () async {
        final uploaded = await factory.uploadTestImage();
        final authed = factory.authenticatedSession();

        final deleted = await endpoints.media.deleteMedia(authed, uploaded.assetId);
        expect(deleted, isTrue);

        final fetched = await endpoints.media.getMedia(authed, uploaded.assetId);
        expect(fetched, isNull);
      });
    });

    group('file size limits', () {
      test('rejects file exceeding 10MB', () async {
        final authed = factory.authenticatedSession();
        final oversized = ByteData(10 * 1024 * 1024 + 1);
        expect(
          () => endpoints.media.uploadImage(
            authed, 'huge.png', oversized, 1, 1, false, '', 'hash',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
