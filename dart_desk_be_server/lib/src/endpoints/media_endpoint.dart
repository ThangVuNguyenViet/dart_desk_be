import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:mime/mime.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../services/local_image_storage_provider.dart';

/// Allowed image MIME types for upload validation.
const _allowedImageMimeTypes = {
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
  'image/svg+xml',
  'image/avif',
  'image/heic',
  'image/heif',
  'image/tiff',
  'image/bmp',
};

/// Maximum file size: 10 MB.
const _maxFileSize = 10 * 1024 * 1024;

/// Endpoint for managing media assets (images and files).
/// All operations require authentication.
class MediaEndpoint extends Endpoint {
  /// Upload an image file with client-provided quick metadata.
  ///
  /// Performs deduplication based on content hash + dimensions + extension.
  /// If an identical asset already exists, returns the existing record.
  Future<MediaAsset> uploadImage(
    Session session,
    String fileName,
    ByteData fileData,
    int width,
    int height,
    bool hasAlpha,
    String blurHash,
    String contentHash,
  ) async {
    // Authenticate
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to upload files');
    }

    // Look up CMS user
    final cmsUser = await CmsUser.db.findFirstRow(
      session,
      where: (t) => t.serverpodUserId.equals(authInfo.userIdentifier),
    );
    if (cmsUser == null) {
      throw Exception('CMS user not found for authenticated user');
    }

    // Validate MIME type
    final mimeType = lookupMimeType(fileName);
    if (mimeType == null || !_allowedImageMimeTypes.contains(mimeType)) {
      throw Exception(
        'Invalid image type. Allowed types: ${_allowedImageMimeTypes.join(", ")}',
      );
    }

    // Validate file size
    if (fileData.lengthInBytes > _maxFileSize) {
      throw Exception('File size exceeds maximum allowed size of 10MB');
    }

    // Build asset ID for deduplication
    final ext = fileName.split('.').last.toLowerCase();
    final assetId = 'image-$contentHash-${width}x$height-$ext';

    // Check for existing asset (deduplication)
    final existing = await MediaAsset.db.findFirstRow(
      session,
      where: (t) => t.assetId.equals(assetId),
    );
    if (existing != null) {
      return existing;
    }

    // Store file
    final provider = LocalImageStorageProvider(session);
    final bytes = fileData.buffer.asUint8List();
    final publicUrl = await provider.store(assetId, fileName, bytes);
    final storagePath = 'media/$assetId/$fileName';

    // Create DB record
    final asset = MediaAsset(
      clientId: cmsUser.clientId,
      assetId: assetId,
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileData.lengthInBytes,
      storagePath: storagePath,
      publicUrl: publicUrl,
      width: width,
      height: height,
      hasAlpha: hasAlpha,
      blurHash: blurHash,
      uploadedByUserId: cmsUser.id!,
      metadataStatus: MediaAssetMetadataStatus.pending,
    );

    try {
      return await MediaAsset.db.insertRow(session, asset);
    } catch (e) {
      // Race condition: another request may have inserted the same assetId.
      // Re-fetch and return.
      final reFetched = await MediaAsset.db.findFirstRow(
        session,
        where: (t) => t.assetId.equals(assetId),
      );
      if (reFetched != null) {
        return reFetched;
      }
      rethrow;
    }
  }

  /// Upload a non-image file.
  ///
  /// Content hash is computed server-side via SHA-256.
  Future<MediaAsset> uploadFile(
    Session session,
    String fileName,
    ByteData fileData,
  ) async {
    // Authenticate
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to upload files');
    }

    // Look up CMS user
    final cmsUser = await CmsUser.db.findFirstRow(
      session,
      where: (t) => t.serverpodUserId.equals(authInfo.userIdentifier),
    );
    if (cmsUser == null) {
      throw Exception('CMS user not found for authenticated user');
    }

    // Validate file size
    if (fileData.lengthInBytes > _maxFileSize) {
      throw Exception('File size exceeds maximum allowed size of 10MB');
    }

    // Determine MIME type (allow any for generic files)
    final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

    // Compute content hash server-side
    final bytes = fileData.buffer.asUint8List();
    final contentHash = sha256.convert(bytes).toString();

    // Build asset ID
    final ext = fileName.split('.').last.toLowerCase();
    final assetId = 'file-$contentHash-$ext';

    // Check for existing asset (deduplication)
    final existing = await MediaAsset.db.findFirstRow(
      session,
      where: (t) => t.assetId.equals(assetId),
    );
    if (existing != null) {
      return existing;
    }

    // Store file
    final provider = LocalImageStorageProvider(session);
    final publicUrl = await provider.store(assetId, fileName, bytes);
    final storagePath = 'media/$assetId/$fileName';

    // Create DB record
    final asset = MediaAsset(
      clientId: cmsUser.clientId,
      assetId: assetId,
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileData.lengthInBytes,
      storagePath: storagePath,
      publicUrl: publicUrl,
      width: 0,
      height: 0,
      hasAlpha: false,
      blurHash: '',
      uploadedByUserId: cmsUser.id!,
      metadataStatus: MediaAssetMetadataStatus.pending,
    );

    try {
      return await MediaAsset.db.insertRow(session, asset);
    } catch (e) {
      // Race condition: another request may have inserted the same assetId.
      final reFetched = await MediaAsset.db.findFirstRow(
        session,
        where: (t) => t.assetId.equals(assetId),
      );
      if (reFetched != null) {
        return reFetched;
      }
      rethrow;
    }
  }

  /// Delete a media asset by assetId.
  ///
  /// Refuses to delete if the asset is still referenced in any document.
  Future<bool> deleteMedia(Session session, String assetId) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to delete media');
    }

    // Safety check: refuse delete if asset is in use
    final usageCount = await getMediaUsageCount(session, assetId);
    if (usageCount > 0) {
      throw Exception(
        'Cannot delete asset "$assetId": it is referenced in $usageCount document(s)',
      );
    }

    // Find the asset
    final asset = await MediaAsset.db.findFirstRow(
      session,
      where: (t) => t.assetId.equals(assetId),
    );
    if (asset == null) {
      return false;
    }

    // Delete from storage
    final provider = LocalImageStorageProvider(session);
    await provider.delete(asset.storagePath);

    // Delete DB record
    await MediaAsset.db.deleteRow(session, asset);

    return true;
  }

  /// Get a single media asset by assetId.
  Future<MediaAsset?> getMedia(Session session, String assetId) async {
    return await MediaAsset.db.findFirstRow(
      session,
      where: (t) => t.assetId.equals(assetId),
    );
  }

  /// List media assets with search, filter, sort, and pagination.
  Future<List<MediaAsset>> listMedia(
    Session session, {
    String? search,
    String? mimeTypePrefix,
    String sortBy = 'dateDesc',
    int limit = 50,
    int offset = 0,
  }) async {
    return await MediaAsset.db.find(
      session,
      where: (t) => _buildWhereClause(t, search: search, mimeTypePrefix: mimeTypePrefix),
      orderBy: (t) => _buildOrderBy(t, sortBy),
      orderDescending: sortBy.endsWith('Desc'),
      limit: limit,
      offset: offset,
    );
  }

  /// Count total media assets matching the given filters.
  Future<int> listMediaCount(
    Session session, {
    String? search,
    String? mimeTypePrefix,
  }) async {
    return await MediaAsset.db.count(
      session,
      where: (t) => _buildWhereClause(t, search: search, mimeTypePrefix: mimeTypePrefix),
    );
  }

  /// Count how many distinct documents reference the given assetId.
  Future<int> getMediaUsageCount(Session session, String assetId) async {
    final result = await session.db.unsafeQuery(
      'SELECT COUNT(DISTINCT "documentId") FROM "document_crdt_snapshots" '
      "WHERE data::text LIKE \$1",
      parameters: QueryParameters.positional(['%$assetId%']),
    );
    if (result.isEmpty || result.first.isEmpty) {
      return 0;
    }
    return result.first.first as int;
  }

  /// Update a media asset's metadata (currently supports renaming).
  Future<MediaAsset> updateMediaAsset(
    Session session,
    String assetId, {
    String? fileName,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to update media');
    }

    final asset = await MediaAsset.db.findFirstRow(
      session,
      where: (t) => t.assetId.equals(assetId),
    );
    if (asset == null) {
      throw Exception('Media asset not found: $assetId');
    }

    if (fileName != null) {
      asset.fileName = fileName;
    }

    return await MediaAsset.db.updateRow(session, asset);
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  /// Build a WHERE expression from search and mimeTypePrefix filters.
  Expression _buildWhereClause(
    MediaAssetTable t, {
    String? search,
    String? mimeTypePrefix,
  }) {
    Expression where = Constant.bool(true);

    if (search != null && search.isNotEmpty) {
      where = where & t.fileName.like('%$search%');
    }

    if (mimeTypePrefix != null && mimeTypePrefix.isNotEmpty) {
      where = where & t.mimeType.like('$mimeTypePrefix%');
    }

    return where;
  }

  /// Build an ORDER BY column from a sort key string.
  Column _buildOrderBy(MediaAssetTable t, String sortBy) {
    switch (sortBy) {
      case 'dateAsc':
      case 'dateDesc':
        return t.createdAt;
      case 'nameAsc':
      case 'nameDesc':
        return t.fileName;
      case 'sizeAsc':
      case 'sizeDesc':
        return t.fileSize;
      default:
        return t.createdAt;
    }
  }
}
