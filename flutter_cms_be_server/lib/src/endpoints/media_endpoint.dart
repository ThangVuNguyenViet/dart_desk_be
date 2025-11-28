import 'dart:typed_data';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Endpoint for managing media files and uploads
/// All operations require authentication
class MediaEndpoint extends Endpoint {
  /// Upload an image file
  /// Returns the public URL and file ID
  Future<UploadResponse> uploadImage(
    Session session,
    String fileName,
    ByteData fileData,
  ) async {
    return _uploadFile(
      session,
      fileName,
      fileData,
      allowedTypes: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      fileCategory: 'image',
    );
  }

  /// Upload a general file (PDF, documents, etc.)
  /// Returns the public URL, file ID, and filename
  Future<UploadResponse> uploadFile(
    Session session,
    String fileName,
    ByteData fileData,
  ) async {
    return _uploadFile(
      session,
      fileName,
      fileData,
      allowedTypes: ['pdf', 'doc', 'docx', 'txt', 'csv', 'xlsx'],
      fileCategory: 'file',
    );
  }

  /// Internal method to handle file uploads
  Future<UploadResponse> _uploadFile(
    Session session,
    String fileName,
    ByteData fileData, {
    required List<String> allowedTypes,
    required String fileCategory,
  }) async {
    // Validate file extension
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedTypes.contains(extension)) {
      throw Exception(
        'Invalid file type. Allowed types: ${allowedTypes.join(", ")}',
      );
    }

    // Validate file size (10MB max)
    const maxFileSize = 10 * 1024 * 1024; // 10MB
    if (fileData.lengthInBytes > maxFileSize) {
      throw Exception('File size exceeds maximum allowed size of 10MB');
    }

    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to upload files');
    }

    final userId = authInfo.userId;

    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uniqueFileName = '${timestamp}_$fileName';
    final storagePath = '$fileCategory/$uniqueFileName';

    try {
      // Store file using Serverpod's storage
      await session.storage.storeFile(
        storageId: 'public',
        path: storagePath,
        byteData: fileData,
      );

      // Get public URL
      final publicUri = await session.storage.getPublicUrl(
        storageId: 'public',
        path: storagePath,
      );

      if (publicUri == null) {
        throw Exception('Failed to get public URL for uploaded file');
      }

      final publicUrl = publicUri.toString();

      // Get the CMS user to find their clientId
      final cmsUser = await CmsUser.db.findFirstRow(
        session,
        where: (t) => t.serverpodUserId.equals(userId),
      );

      if (cmsUser == null) {
        throw Exception('CMS user not found for authenticated user');
      }

      // Save file metadata to database
      final mediaFile = MediaFile(
        clientId: cmsUser.clientId,
        fileName: fileName,
        fileType: extension,
        fileSize: fileData.lengthInBytes,
        storagePath: storagePath,
        publicUrl: publicUrl,
        uploadedByUserId: cmsUser.id!,
        createdAt: DateTime.now(),
      );

      final savedFile = await MediaFile.db.insertRow(session, mediaFile);

      return UploadResponse(
        url: publicUrl,
        id: savedFile.id!.toString(),
        fileName: fileName,
      );
    } catch (e) {
      session.log('Error uploading file: $e', level: LogLevel.error);
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Delete a media file by ID
  Future<bool> deleteMedia(
    Session session,
    int fileId,
  ) async {
    try {
      final mediaFile = await MediaFile.db.findById(session, fileId);

      if (mediaFile == null) {
        return false;
      }

      // Delete file from storage
      await session.storage.deleteFile(
        storageId: 'public',
        path: mediaFile.storagePath,
      );

      // Delete record from database
      await MediaFile.db.deleteRow(session, mediaFile);

      return true;
    } catch (e) {
      session.log('Error deleting media file: $e', level: LogLevel.warning);
      return false;
    }
  }

  /// Get media file metadata by ID
  Future<MediaFile?> getMedia(
    Session session,
    int fileId,
  ) async {
    return await MediaFile.db.findById(session, fileId);
  }

  /// List all media files with pagination
  Future<List<MediaFile>> listMedia(
    Session session, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await MediaFile.db.find(
      session,
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );
  }
}
