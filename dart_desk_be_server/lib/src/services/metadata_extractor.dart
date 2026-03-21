import 'dart:convert';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Extracts rich metadata from an uploaded image and updates the
/// [MediaAsset] record asynchronously.
class MetadataExtractor {
  /// Downloads the file, decodes it, and populates LQIP, palette, EXIF, and
  /// GPS fields on [asset] before persisting the updated row.
  ///
  /// Call with [unawaited] so the upload response is not blocked.
  static Future<void> extractAndUpdate(Session session, MediaAsset asset) async {
    try {
      // 1. Retrieve file bytes from storage.
      final byteData = await session.storage.retrieveFile(
        storageId: 'public',
        path: asset.storagePath,
      );
      if (byteData == null) {
        throw Exception('File not found in storage: ${asset.storagePath}');
      }
      final bytes = byteData.buffer.asUint8List();

      // 2. Decode image.
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image: ${asset.storagePath}');
      }

      // 3. Generate LQIP (20px wide, JPEG quality 30, base64 data URI).
      final lqipWidth = 20;
      final lqipHeight = (image.height * lqipWidth / image.width).round();
      final thumbnail = img.copyResize(
        image,
        width: lqipWidth,
        height: lqipHeight,
        interpolation: img.Interpolation.average,
      );
      final jpegBytes = img.encodeJpg(thumbnail, quality: 30);
      final lqip =
          'data:image/jpeg;base64,${base64Encode(jpegBytes)}';

      // 4. Extract color palette by sampling ~1000 pixels.
      final paletteJson = _extractPalette(image);

      // 5. Read EXIF data.
      String? exifJson;
      double? locationLat;
      double? locationLng;

      try {
        final exifData = await readExifFromBytes(bytes);
        if (exifData.isNotEmpty) {
          final exifMap = <String, String>{};
          for (final entry in exifData.entries) {
            exifMap[entry.key] = entry.value.toString();
          }
          exifJson = jsonEncode(exifMap);

          // 6. Extract GPS coordinates.
          try {
            final latTag = exifData['GPS GPSLatitude'];
            final lngTag = exifData['GPS GPSLongitude'];
            final latRef = exifData['GPS GPSLatitudeRef'];
            final lngRef = exifData['GPS GPSLongitudeRef'];

            if (latTag != null && lngTag != null) {
              final lat = _parseGpsDms(latTag.toString());
              final lng = _parseGpsDms(lngTag.toString());
              if (lat != null && lng != null) {
                locationLat =
                    (latRef?.toString().toUpperCase() == 'S') ? -lat : lat;
                locationLng =
                    (lngRef?.toString().toUpperCase() == 'W') ? -lng : lng;
              }
            }
          } catch (_) {
            // GPS extraction is best-effort — ignore failures.
          }
        }
      } catch (_) {
        // EXIF extraction is best-effort — ignore failures.
      }

      // 7. Persist extracted metadata.
      asset.lqip = lqip;
      asset.paletteJson = paletteJson;
      asset.exifJson = exifJson;
      asset.locationLat = locationLat;
      asset.locationLng = locationLng;
      asset.metadataStatus = MediaAssetMetadataStatus.complete;

      await MediaAsset.db.updateRow(session, asset);
    } catch (e) {
      try {
        asset.metadataStatus = MediaAssetMetadataStatus.failed;
        await MediaAsset.db.updateRow(session, asset);
      } catch (_) {
        // Ignore secondary failure.
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Samples ~1000 pixels and returns a JSON string with up to 4 palette
  /// entries: dominant, vibrant, muted, darkMuted.
  static String _extractPalette(img.Image image) {
    final totalPixels = image.width * image.height;
    final step = (totalPixels / 1000).ceil().clamp(1, totalPixels);

    final colorCounts = <int, int>{};

    for (var i = 0; i < totalPixels; i += step) {
      final x = i % image.width;
      final y = i ~/ image.width;
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();

      // Quantize by shifting right 4 bits (16-level buckets per channel).
      final quantized =
          ((r >> 4) << 16) | ((g >> 4) << 8) | (b >> 4);
      colorCounts[quantized] = (colorCounts[quantized] ?? 0) + 1;
    }

    // Sort by frequency and take top 4.
    final sorted = colorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top = sorted.take(4).toList();

    String toHex(int quantized) {
      final r = ((quantized >> 16) & 0xF) << 4;
      final g = ((quantized >> 8) & 0xF) << 4;
      final b = (quantized & 0xF) << 4;
      return '#${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}';
    }

    final labels = ['dominant', 'vibrant', 'muted', 'darkMuted'];
    final palette = <String, String>{};
    for (var i = 0; i < top.length; i++) {
      palette[labels[i]] = toHex(top[i].key);
    }

    return jsonEncode(palette);
  }

  /// Parses a GPS DMS string of the form "[d, m, s]" or "d/1, m/1, s/100"
  /// and returns decimal degrees, or null on failure.
  static double? _parseGpsDms(String raw) {
    try {
      // IfdTag.toString() typically looks like "[34, 7, 4851/100]"
      final cleaned = raw.replaceAll(RegExp(r'[\[\]\s]'), '');
      final parts = cleaned.split(',');
      if (parts.length != 3) return null;

      double parseFraction(String s) {
        if (s.contains('/')) {
          final nums = s.split('/');
          return double.parse(nums[0]) / double.parse(nums[1]);
        }
        return double.parse(s);
      }

      final d = parseFraction(parts[0]);
      final m = parseFraction(parts[1]);
      final s = parseFraction(parts[2]);
      return d + m / 60.0 + s / 3600.0;
    } catch (_) {
      return null;
    }
  }
}
