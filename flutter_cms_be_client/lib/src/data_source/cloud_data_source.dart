import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_cms/flutter_cms.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart' as serverpod;

/// Cloud data source implementation using the Serverpod flutter_cms_be_client.
///
/// This class wraps the Serverpod-generated client and converts between
/// Serverpod models and platform-agnostic CMS data models.
///
/// ## Usage
///
/// ```dart
/// import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
/// import 'package:flutter_cms_cloud/flutter_cms_cloud.dart';
///
/// final client = Client('http://localhost:8080/');
/// final dataSource = CloudDataSource(client);
///
/// // Use the data source
/// final documents = await dataSource.getDocuments('article');
/// ```
class CloudDataSource implements CmsDataSource {
  /// The Serverpod client used for API calls
  final serverpod.Client _client;

  /// Creates a new CloudDataSource with the given client.
  ///
  /// [client] - The Serverpod client instance configured with the server URL
  CloudDataSource(this._client);

  // ============================================================
  // Document Operations
  // ============================================================

  @override
  Future<DocumentList> getDocuments(
    String documentType, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client.document.getDocuments(
        documentType,
        search: search,
        limit: limit,
        offset: offset,
      );

      return DocumentList(
        documents: response.documents.map(_toCmsDocument).toList(),
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
      );
    } catch (e) {
      throw CmsDataSourceException('Failed to get documents', e);
    }
  }

  @override
  Future<CmsDocument?> getDocument(int documentId) async {
    try {
      final response = await _client.document.getDocument(documentId);
      if (response == null) return null;
      return _toCmsDocument(response);
    } catch (e) {
      throw CmsDataSourceException('Failed to get document', e);
    }
  }

  @override
  Future<CmsDocument> createDocument(
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  }) async {
    try {
      final response = await _client.document.createDocument(
        documentType,
        title,
        data,
        slug: slug,
        isDefault: isDefault,
      );
      return _toCmsDocument(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to create document', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to create document', e);
    }
  }

  @override
  Future<CmsDocument?> updateDocument(
    int documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) async {
    try {
      final response = await _client.document.updateDocument(
        documentId,
        title: title,
        slug: slug,
        isDefault: isDefault,
      );
      if (response == null) return null;
      return _toCmsDocument(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to update document', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to update document', e);
    }
  }

  @override
  Future<bool> deleteDocument(int documentId) async {
    try {
      return await _client.document.deleteDocument(documentId);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to delete document', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to delete document', e);
    }
  }

  @override
  Future<List<String>> getDocumentTypes() async {
    try {
      return await _client.document.getDocumentTypes();
    } catch (e) {
      throw CmsDataSourceException('Failed to get document types', e);
    }
  }

  // ============================================================
  // Document Version Operations
  // ============================================================

  @override
  Future<DocumentVersionList> getDocumentVersions(
    int documentId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _client.document.getDocumentVersions(
        documentId,
        limit: limit,
        offset: offset,
      );

      return DocumentVersionList(
        versions: response.versions.map(_toDocumentVersion).toList(),
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
      );
    } catch (e) {
      throw CmsDataSourceException('Failed to get document versions', e);
    }
  }

  @override
  Future<DocumentVersion?> getDocumentVersion(int versionId) async {
    try {
      final response = await _client.document.getDocumentVersion(versionId);
      if (response == null) return null;
      return _toDocumentVersion(response);
    } catch (e) {
      throw CmsDataSourceException('Failed to get document version', e);
    }
  }

  @override
  Future<DocumentVersion> createDocumentVersion(
    int documentId,
    Map<String, dynamic> data, {
    String status = 'draft',
    String? changeLog,
  }) async {
    try {
      final response = await _client.document.createDocumentVersion(
        documentId,
        data,
        status: status,
        changeLog: changeLog,
      );
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to create document version', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to create document version', e);
    }
  }

  @override
  Future<DocumentVersion?> updateDocumentVersion(
    int versionId,
    Map<String, dynamic> data, {
    String? changeLog,
  }) async {
    try {
      final response = await _client.document.updateDocumentVersion(
        versionId,
        data,
        changeLog: changeLog,
      );
      if (response == null) return null;
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to update document version', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to update document version', e);
    }
  }

  @override
  Future<DocumentVersion?> publishDocumentVersion(int versionId) async {
    try {
      final response = await _client.document.publishDocumentVersion(versionId);
      if (response == null) return null;
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to publish document version', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to publish document version', e);
    }
  }

  @override
  Future<DocumentVersion?> archiveDocumentVersion(int versionId) async {
    try {
      final response = await _client.document.archiveDocumentVersion(versionId);
      if (response == null) return null;
      return _toDocumentVersion(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to archive document version', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to archive document version', e);
    }
  }

  @override
  Future<bool> deleteDocumentVersion(int versionId) async {
    try {
      return await _client.document.deleteDocumentVersion(versionId);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to delete document version', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to delete document version', e);
    }
  }

  // ============================================================
  // Media Operations
  // ============================================================

  @override
  Future<MediaUploadResult> uploadImage(
    String fileName,
    Uint8List fileData,
  ) async {
    try {
      final byteData = ByteData.view(fileData.buffer);
      final response = await _client.media.uploadImage(fileName, byteData);
      return _toUploadResult(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to upload image', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to upload image', e);
    }
  }

  @override
  Future<MediaUploadResult> uploadFile(
    String fileName,
    Uint8List fileData,
  ) async {
    try {
      final byteData = ByteData.view(fileData.buffer);
      final response = await _client.media.uploadFile(fileName, byteData);
      return _toUploadResult(response);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to upload file', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to upload file', e);
    }
  }

  @override
  Future<bool> deleteMedia(int fileId) async {
    try {
      return await _client.media.deleteMedia(fileId);
    } on serverpod.ServerpodClientException catch (e) {
      if (e.statusCode == 401) {
        throw const CmsAuthenticationException();
      }
      throw CmsDataSourceException('Failed to delete media', e);
    } catch (e) {
      throw CmsDataSourceException('Failed to delete media', e);
    }
  }

  @override
  Future<MediaFile?> getMedia(int fileId) async {
    try {
      final response = await _client.media.getMedia(fileId);
      if (response == null) return null;
      return _toMediaFile(response);
    } catch (e) {
      throw CmsDataSourceException('Failed to get media', e);
    }
  }

  @override
  Future<List<MediaFile>> listMedia({int limit = 50, int offset = 0}) async {
    try {
      final response = await _client.media.listMedia(
        limit: limit,
        offset: offset,
      );
      return response.map(_toMediaFile).toList();
    } catch (e) {
      throw CmsDataSourceException('Failed to list media', e);
    }
  }

  // ============================================================
  // Conversion Helpers
  // ============================================================

  /// Converts a Serverpod CmsDocument to a platform-agnostic CmsDocument.
  CmsDocument _toCmsDocument(serverpod.CmsDocument doc) {
    // Parse the activeVersionData JSON string into a map if present
    Map<String, dynamic>? parsedData;
    if (doc.activeVersionData != null && doc.activeVersionData!.isNotEmpty) {
      try {
        parsedData = jsonDecode(doc.activeVersionData!) as Map<String, dynamic>;
      } catch (_) {
        parsedData = null;
      }
    }

    return CmsDocument(
      id: doc.id,
      clientId: doc.clientId,
      documentType: doc.documentType,
      title: doc.title,
      slug: doc.slug,
      isDefault: doc.isDefault,
      activeVersionData: parsedData,
      createdAt: doc.createdAt,
      updatedAt: doc.updatedAt,
      createdByUserId: doc.createdByUserId,
      updatedByUserId: doc.updatedByUserId,
    );
  }

  /// Converts a Serverpod MediaFile to a platform-agnostic MediaFile.
  MediaFile _toMediaFile(serverpod.MediaFile file) {
    return MediaFile(
      id: file.id,
      fileName: file.fileName,
      fileType: file.fileType,
      fileSize: file.fileSize,
      publicUrl: file.publicUrl,
      altText: file.altText,
      metadata: file.metadata,
      createdAt: file.createdAt,
      uploadedByUserId: file.uploadedByUserId,
    );
  }

  /// Converts a Serverpod UploadResponse to a platform-agnostic MediaUploadResult.
  MediaUploadResult _toUploadResult(serverpod.UploadResponse response) {
    return MediaUploadResult(
      id: response.id,
      url: response.url,
      fileName: response.fileName,
    );
  }

  /// Converts a Serverpod DocumentVersion to a platform-agnostic DocumentVersion.
  DocumentVersion _toDocumentVersion(serverpod.DocumentVersion version) {
    // Parse the JSON data string into a map
    Map<String, dynamic> parsedData;
    try {
      parsedData = jsonDecode(version.data) as Map<String, dynamic>;
    } catch (_) {
      parsedData = {};
    }

    return DocumentVersion(
      id: version.id,
      documentId: version.documentId,
      versionNumber: version.versionNumber,
      status: version.status,
      data: parsedData,
      changeLog: version.changeLog,
      publishedAt: version.publishedAt,
      scheduledAt: version.scheduledAt,
      archivedAt: version.archivedAt,
      createdAt: version.createdAt,
      createdByUserId: version.createdByUserId,
    );
  }
}
