import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:test/test.dart';
import 'package:dart_desk_be_server/src/generated/protocol.dart';
import 'package:dart_desk_be_server/src/services/metadata_extractor.dart';
import '../test_tools/serverpod_test_tools.dart';

/// Generate a valid PNG using the image library (guaranteed decodable).
Uint8List _createValidPng() {
  final source = img.Image(width: 10, height: 10);
  for (var y = 0; y < 10; y++) {
    for (var x = 0; x < 10; x++) {
      source.setPixelRgb(x, y, 255, 0, 0);
    }
  }
  return Uint8List.fromList(img.encodePng(source));
}

final _validPngBytes = _createValidPng();

int _counter = 0;
String _uniqueId(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_counter++}';

MediaAsset _buildPendingAsset({
  required String assetId,
  required String fileName,
  String mimeType = 'image/png',
  int fileSize = 0,
}) {
  return MediaAsset(
    tenantId: null,
    fileName: fileName,
    assetId: assetId,
    storagePath: 'media/$assetId/$fileName',
    publicUrl: 'http://localhost/media/$assetId/$fileName',
    mimeType: mimeType,
    fileSize: fileSize,
    width: 0,
    height: 0,
    hasAlpha: false,
    blurHash: 'L00000fQfQfQfQfQfQfQfQfQ',
    metadataStatus: MediaAssetMetadataStatus.pending,
  );
}

void main() {
  withServerpod(
    'MetadataExtractor',
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      group('extractAndUpdate', () {
        test('valid image: populates LQIP, palette, and sets status complete',
            () async {
          final session = sessionBuilder.build();
          final id = _uniqueId('valid');

          // Store a real PNG in test storage
          await session.storage.storeFile(
            storageId: 'public',
            path: 'media/$id/test.png',
            byteData: ByteData.sublistView(_validPngBytes),
          );

          // Insert a pending asset record
          final asset = await MediaAsset.db.insertRow(
            session,
            _buildPendingAsset(
              assetId: id,
              fileName: 'test.png',
              fileSize: _validPngBytes.length,
            ),
          );

          // Run extraction
          await MetadataExtractor.extractAndUpdate(session, asset);

          // Re-fetch the asset to see updated fields
          final updated = await MediaAsset.db.findById(session, asset.id!);

          expect(updated, isNotNull);
          expect(updated!.metadataStatus,
              equals(MediaAssetMetadataStatus.complete));
          expect(updated.lqip, startsWith('data:image/jpeg;base64,'));
          expect(updated.paletteJson, isNotNull);
        });

        test('no EXIF: GPS fields null, status still complete', () async {
          final session = sessionBuilder.build();
          final id = _uniqueId('noexif');

          await session.storage.storeFile(
            storageId: 'public',
            path: 'media/$id/test.png',
            byteData: ByteData.sublistView(_validPngBytes),
          );

          final asset = await MediaAsset.db.insertRow(
            session,
            _buildPendingAsset(
              assetId: id,
              fileName: 'test.png',
              fileSize: _validPngBytes.length,
            ),
          );

          await MetadataExtractor.extractAndUpdate(session, asset);

          final updated = await MediaAsset.db.findById(session, asset.id!);

          expect(updated, isNotNull);
          expect(updated!.metadataStatus,
              equals(MediaAssetMetadataStatus.complete));
          expect(updated.exifJson, isNull);
          expect(updated.locationLat, isNull);
          expect(updated.locationLng, isNull);
        });

        test('missing file: sets status to failed', () async {
          final session = sessionBuilder.build();
          final id = _uniqueId('missing');

          final asset = await MediaAsset.db.insertRow(
            session,
            _buildPendingAsset(
              assetId: id,
              fileName: 'ghost.png',
            ),
          );

          await MetadataExtractor.extractAndUpdate(session, asset);

          final updated = await MediaAsset.db.findById(session, asset.id!);
          expect(updated!.metadataStatus,
              equals(MediaAssetMetadataStatus.failed));
        });

        test('corrupt image: sets status to failed', () async {
          final session = sessionBuilder.build();
          final id = _uniqueId('corrupt');

          final garbageBytes = ByteData.sublistView(
            Uint8List.fromList([0x00, 0x01, 0x02, 0x03, 0xFF, 0xFE]),
          );
          await session.storage.storeFile(
            storageId: 'public',
            path: 'media/$id/corrupt.png',
            byteData: garbageBytes,
          );

          final asset = await MediaAsset.db.insertRow(
            session,
            _buildPendingAsset(
              assetId: id,
              fileName: 'corrupt.png',
              fileSize: 6,
            ),
          );

          await MetadataExtractor.extractAndUpdate(session, asset);

          final updated = await MediaAsset.db.findById(session, asset.id!);
          expect(updated!.metadataStatus,
              equals(MediaAssetMetadataStatus.failed));
        });
      });
    },
  );
}
