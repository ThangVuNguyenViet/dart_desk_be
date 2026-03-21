import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:dart_desk_be_server/src/generated/protocol.dart';
import 'package:dart_desk_be_server/src/services/metadata_extractor.dart';
import '../test_tools/serverpod_test_tools.dart';
import '../helpers/test_data_factory.dart';

void main() {
  withServerpod('MetadataExtractor', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    group('extractAndUpdate', () {
      test('valid image: populates LQIP, palette, and sets status complete',
          () async {
        // Upload a real 1x1 PNG via the media endpoint
        final asset = await factory.uploadTestImage();
        final session = sessionBuilder.build();

        // Run extraction
        await MetadataExtractor.extractAndUpdate(session, asset);

        // Re-fetch the asset to see updated fields
        final updated = await MediaAsset.db.findById(session, asset.id!);

        expect(updated, isNotNull);
        expect(updated!.metadataStatus, equals(MediaAssetMetadataStatus.complete));
        expect(updated.lqip, startsWith('data:image/jpeg;base64,'));
        expect(updated.paletteJson, isNotNull);
      });

      test('no EXIF: GPS fields null, status still complete', () async {
        // The 1x1 test PNG has no EXIF data
        final asset = await factory.uploadTestImage();
        final session = sessionBuilder.build();

        await MetadataExtractor.extractAndUpdate(session, asset);

        final updated = await MediaAsset.db.findById(session, asset.id!);

        expect(updated, isNotNull);
        expect(updated!.metadataStatus, equals(MediaAssetMetadataStatus.complete));
        expect(updated.exifJson, isNull);
        expect(updated.locationLat, isNull);
        expect(updated.locationLng, isNull);
      });

      test('missing file: sets status to failed', () async {
        final session = sessionBuilder.build();

        // Create a MediaAsset with a non-existent storage path
        final asset = await MediaAsset.db.insertRow(
          session,
          MediaAsset(
            tenantId: null,
            fileName: 'ghost.png',
            assetId: 'nonexistent-id',
            storagePath: 'media/nonexistent/ghost.png',
            publicUrl: 'http://localhost/media/nonexistent/ghost.png',
            mimeType: 'image/png',
            fileSize: 0,
            metadataStatus: MediaAssetMetadataStatus.pending,
          ),
        );

        await MetadataExtractor.extractAndUpdate(session, asset);

        final updated = await MediaAsset.db.findById(session, asset.id!);
        expect(updated!.metadataStatus, equals(MediaAssetMetadataStatus.failed));
      });

      test('corrupt image: sets status to failed', () async {
        final session = sessionBuilder.build();

        // Store garbage bytes as an "image"
        final garbageBytes = ByteData.sublistView(
          Uint8List.fromList([0x00, 0x01, 0x02, 0x03, 0xFF, 0xFE]),
        );
        await session.storage.storeFile(
          storageId: 'public',
          path: 'media/corrupt-id/corrupt.png',
          byteData: garbageBytes,
        );

        final asset = await MediaAsset.db.insertRow(
          session,
          MediaAsset(
            tenantId: null,
            fileName: 'corrupt.png',
            assetId: 'corrupt-id',
            storagePath: 'media/corrupt-id/corrupt.png',
            publicUrl: 'http://localhost/media/corrupt-id/corrupt.png',
            mimeType: 'image/png',
            fileSize: 6,
            metadataStatus: MediaAssetMetadataStatus.pending,
          ),
        );

        await MetadataExtractor.extractAndUpdate(session, asset);

        final updated = await MediaAsset.db.findById(session, asset.id!);
        expect(updated!.metadataStatus, equals(MediaAssetMetadataStatus.failed));
      });
    });
  });
}
