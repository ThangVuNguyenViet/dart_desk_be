import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_desk_server/src/generated/api_exception.dart';
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod(
    'Media endpoint',
    (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
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
          () => endpoints.media.uploadImage(authed, 'bad.xyz', byteData),
          throwsA(isA<ApiException>()),
        );
      });

      test('returns fully-populated MediaAsset synchronously', () async {
        // Use a distinct green PNG so bytes differ from the red fixture used
        // elsewhere — avoids dedup returning an earlier row.
        final authed = factory.authenticatedSession();
        final greenImage = img.fill(
          img.Image(width: 4, height: 4),
          color: img.ColorRgb8(0, 255, 0),
        );
        final pngBytes = img.encodePng(greenImage);
        final byteData = ByteData.sublistView(Uint8List.fromList(pngBytes));
        final result = await endpoints.media.uploadImage(
          authed,
          'Hero Photo.png',
          byteData,
        );
        expect(result.width, greaterThan(0));
        expect(result.height, greaterThan(0));
        expect(result.blurHash, isNotEmpty);
        expect(result.lqip, startsWith('data:image/jpeg;base64,'));
        expect(result.paletteJson, contains('dominant'));
        expect(result.metadataStatus, MediaAssetMetadataStatus.complete);
        // fileName preserved; storagePath uses slugged form
        expect(result.fileName, 'Hero Photo.png');
        expect(result.storagePath, contains('hero-photo.png'));
      });

      test('rejects malformed bytes with 400', () async {
        final authed = factory.authenticatedSession();
        final bad = Uint8List.fromList([1, 2, 3, 4]);
        expect(
          () => endpoints.media.uploadImage(
            authed,
            'bad.png',
            ByteData.sublistView(bad),
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('dedup: same bytes return same assetId', () async {
        final a = await factory.uploadTestImage(fileName: 'first.png');
        final b = await factory.uploadTestImage(fileName: 'second.png');
        expect(a.assetId, b.assetId);
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
        expect(media!.assetId, equals(uploaded.assetId));
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

    group('listMediaCount', () {
      test('counts uploaded media', () async {
        await factory.uploadTestImage(fileName: 'count1.png');
        await factory.uploadTestImage(fileName: 'count2.png');

        final authed = factory.authenticatedSession();
        final count = await endpoints.media.listMediaCount(authed);

        expect(count, greaterThanOrEqualTo(2));
      });

      test('filters count by mimeTypePrefix', () async {
        await factory.uploadTestImage(fileName: 'filter1.png');
        await factory.uploadTestFile(fileName: 'filter1.txt');

        final authed = factory.authenticatedSession();
        final imageCount = await endpoints.media.listMediaCount(
          authed,
          mimeTypePrefix: 'image/',
        );
        final textCount = await endpoints.media.listMediaCount(
          authed,
          mimeTypePrefix: 'text/',
        );

        expect(imageCount, greaterThanOrEqualTo(1));
        expect(textCount, greaterThanOrEqualTo(1));
      });
    });

    group('getMediaUsageCount', () {
      test('returns zero for unused asset', () async {
        final uploaded = await factory.uploadTestImage(fileName: 'unused.png');
        final authed = factory.authenticatedSession();

        final count = await endpoints.media.getMediaUsageCount(
          authed,
          uploaded.assetId,
        );

        expect(count, equals(0));
      });
    });

    group('updateMediaAsset', () {
      test('renames media file', () async {
        final uploaded = await factory.uploadTestImage(fileName: 'original.png');
        final authed = factory.authenticatedSession();

        final updated = await endpoints.media.updateMediaAsset(
          authed,
          uploaded.assetId,
          fileName: 'renamed.png',
        );

        expect(updated.fileName, equals('renamed.png'));
      });

      test('throws for nonexistent asset', () async {
        final authed = factory.authenticatedSession();

        expect(
          () => endpoints.media.updateMediaAsset(
            authed,
            'nonexistent-asset-id',
            fileName: 'nope.png',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('file size limits', () {
      test('rejects file exceeding 10MB', () async {
        final authed = factory.authenticatedSession();
        final oversized = ByteData(10 * 1024 * 1024 + 1);
        expect(
          () => endpoints.media.uploadImage(authed, 'huge.png', oversized),
          throwsA(isA<ApiException>()),
        );
      });
    });
  },
    rollbackDatabase: RollbackDatabase.disabled,
  );
}
