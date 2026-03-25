import 'dart:typed_data';

/// Fit modes for image transforms.
enum FitMode { clip, crop, fill, max, scale }

/// Crop rectangle with 0-1 fractional values.
class CropRect {
  final double top;
  final double bottom;
  final double left;
  final double right;

  const CropRect({
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });
}

/// Parameters for image URL transforms.
class ImageTransformParams {
  final int? width;
  final int? height;
  final FitMode? fit;
  final String? format;
  final int? quality;
  final double? fpX;
  final double? fpY;
  final CropRect? crop;

  const ImageTransformParams({
    this.width,
    this.height,
    this.fit,
    this.format,
    this.quality,
    this.fpX,
    this.fpY,
    this.crop,
  });
}

/// Abstract storage + transform provider.
/// Implementations: LocalImageStorageProvider (default), AwsImageStorageProvider (cloud).
abstract class ImageStorageProvider {
  /// Store file, return public URL.
  Future<String> store(String assetId, String fileName, Uint8List data);

  /// Delete file by its storage path.
  Future<void> delete(String storagePath);

  /// Generate a transform URL. Returns null if transforms not supported.
  String? transformUrl(String publicUrl, ImageTransformParams params);
}
