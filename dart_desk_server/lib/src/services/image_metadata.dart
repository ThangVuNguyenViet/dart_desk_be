import 'dart:convert';
import 'dart:typed_data';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;

/// Fully-decoded image metadata derived in a single pass over the decoded image.
class ImageMetadata {
  final int width;
  final int height;
  final bool hasAlpha;
  final String blurHash;
  final String lqip;
  final String paletteJson;
  final String? exifJson;
  final double? locationLat;
  final double? locationLng;

  const ImageMetadata({
    required this.width,
    required this.height,
    required this.hasAlpha,
    required this.blurHash,
    required this.lqip,
    required this.paletteJson,
    this.exifJson,
    this.locationLat,
    this.locationLng,
  });
}

/// Slugify a filename for safe inclusion in URLs.
///
/// Lowercases, strips diacritics, collapses non-alphanumeric runs into `-`,
/// strips leading/trailing `-`, preserves the extension.
String slugifyFilename(String input) {
  final trimmed = input.trim();
  final dot = trimmed.lastIndexOf('.');
  final hasExt = dot > 0 && dot < trimmed.length - 1;
  final stem = hasExt ? trimmed.substring(0, dot) : trimmed;
  final ext = hasExt ? trimmed.substring(dot + 1) : '';

  String slug(String s) {
    final ascii = _stripDiacritics(s).toLowerCase();
    final replaced = ascii.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return replaced.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  final stemSlug = slug(stem);
  final extSlug = slug(ext);
  if (extSlug.isEmpty) return stemSlug;
  return '$stemSlug.$extSlug';
}

String _stripDiacritics(String s) {
  const map = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
    'ç': 'c',
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
    'ñ': 'n',
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
    'ý': 'y', 'ÿ': 'y',
  };
  final buf = StringBuffer();
  for (final c in s.split('')) {
    buf.write(map[c] ?? c);
  }
  return buf.toString();
}

/// Derive metadata from an already-decoded image. Callers are responsible for
/// the initial `img.decodeImage`. [rawBytes] are used only for EXIF reading.
Future<ImageMetadata> extractFromDecodedImage(
    img.Image image, Uint8List rawBytes) async {
  final width = image.width;
  final height = image.height;
  final hasAlpha = image.hasAlpha;

  final thumb = (width > 64 || height > 64)
      ? img.copyResize(image, width: 64, maintainAspect: true)
      : image;
  final blurHash = BlurHash.encode(thumb, numCompX: 4, numCompY: 3).hash;

  const lqipWidth = 20;
  final lqipHeight = (height * lqipWidth / width).round();
  final lqipThumb = img.copyResize(
    image,
    width: lqipWidth,
    height: lqipHeight,
    interpolation: img.Interpolation.average,
  );
  final lqipBytes = img.encodeJpg(lqipThumb, quality: 30);
  final lqip = 'data:image/jpeg;base64,${base64Encode(lqipBytes)}';

  final paletteJson = _extractPalette(image);

  String? exifJson;
  double? locationLat;
  double? locationLng;
  try {
    final exifData = await readExifFromBytes(rawBytes);
    if (exifData.isNotEmpty) {
      final exifMap = <String, String>{};
      for (final entry in exifData.entries) {
        exifMap[entry.key] = entry.value.toString();
      }
      exifJson = jsonEncode(exifMap);

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
        // GPS best-effort.
      }
    }
  } catch (_) {
    // EXIF best-effort.
  }

  return ImageMetadata(
    width: width,
    height: height,
    hasAlpha: hasAlpha,
    blurHash: blurHash,
    lqip: lqip,
    paletteJson: paletteJson,
    exifJson: exifJson,
    locationLat: locationLat,
    locationLng: locationLng,
  );
}

String _extractPalette(img.Image image) {
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
    final quantized = ((r >> 4) << 16) | ((g >> 4) << 8) | (b >> 4);
    colorCounts[quantized] = (colorCounts[quantized] ?? 0) + 1;
  }

  final sorted = colorCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top = sorted.take(4).toList();

  String toHex(int q) {
    final r = ((q >> 16) & 0xF) << 4;
    final g = ((q >> 8) & 0xF) << 4;
    final b = (q & 0xF) << 4;
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

double? _parseGpsDms(String raw) {
  try {
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
