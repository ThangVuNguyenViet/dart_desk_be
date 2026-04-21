import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import 'image_storage_provider.dart';

/// Default storage provider using Serverpod's built-in cloud storage.
/// No image transforms — returns null for transformUrl.
class LocalImageStorageProvider implements ImageStorageProvider {
  final Session session;

  LocalImageStorageProvider(this.session);

  @override
  // NOTE: Serverpod's built-in storage does NOT accept a Content-Type parameter.
  // This is a known limitation for local/dev mode; production uses S3 (AwsImageStorageProvider).
  Future<String> store(String assetId, String fileName, Uint8List data, String contentType) async {
    final storagePath = 'media/$assetId/$fileName';
    await session.storage.storeFile(
      storageId: 'public',
      path: storagePath,
      byteData: ByteData.sublistView(data),
    );
    final publicUrl = await session.storage.getPublicUrl(
      storageId: 'public',
      path: storagePath,
    );
    return publicUrl.toString();
  }

  @override
  Future<void> delete(String storagePath) async {
    await session.storage.deleteFile(
      storageId: 'public',
      path: storagePath,
    );
  }

  @override
  String? transformUrl(String publicUrl, ImageTransformParams params) {
    // Local provider does not support transforms.
    return null;
  }
}
