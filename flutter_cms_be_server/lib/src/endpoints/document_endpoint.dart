import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Endpoint for managing CMS documents
/// All write operations require authentication
class DocumentEndpoint extends Endpoint {
  /// Helper method to sync activeVersionData with the published version
  Future<void> _syncActiveVersionData(
    Session session,
    int documentId,
  ) async {
    // Find the published version (or latest draft if no published version)
    final publishedVersions = await DocumentVersion.db.find(
      session,
      where: (t) => t.documentId.equals(documentId) & t.status.equals('published'),
      orderBy: (t) => t.versionNumber,
      orderDescending: true,
      limit: 1,
    );

    String? activeData;
    if (publishedVersions.isNotEmpty) {
      activeData = publishedVersions.first.data;
    } else {
      // If no published version, use the latest version
      final latestVersions = await DocumentVersion.db.find(
        session,
        where: (t) => t.documentId.equals(documentId),
        orderBy: (t) => t.versionNumber,
        orderDescending: true,
        limit: 1,
      );
      activeData = latestVersions.isNotEmpty ? latestVersions.first.data : null;
    }

    // Update the document's activeVersionData
    final document = await CmsDocument.db.findById(session, documentId);
    if (document != null) {
      final updatedDoc = document.copyWith(
        activeVersionData: activeData,
        updatedAt: DateTime.now(),
      );
      await CmsDocument.db.updateRow(session, updatedDoc);
    }
  }

  /// Get all documents for a specific document type with pagination
  Future<DocumentList> getDocuments(
    Session session,
    String documentType, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    // Get total count
    final total = await CmsDocument.db.count(
      session,
      where: (t) => t.documentType.equals(documentType),
    );

    // Get paginated documents
    final documents = await CmsDocument.db.find(
      session,
      where: (t) {
        var expr = t.documentType.equals(documentType);
        if (search != null && search.isNotEmpty) {
          // Search in title and activeVersionData (cached from published version)
          expr = expr &
              (t.title.like('%$search%') |
                  t.activeVersionData.like('%$search%'));
        }
        return expr;
      },
      orderBy: (t) => t.updatedAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );

    return DocumentList(
      documents: documents,
      total: total,
      page: (offset ~/ limit) + 1,
      pageSize: limit,
    );
  }

  /// Get a single document by ID
  Future<CmsDocument?> getDocument(
    Session session,
    int documentId,
  ) async {
    return await CmsDocument.db.findById(session, documentId);
  }

  /// Get a document by slug
  Future<CmsDocument?> getDocumentBySlug(
    Session session,
    String slug,
  ) async {
    final documents = await CmsDocument.db.find(
      session,
      where: (t) => t.slug.equals(slug),
      limit: 1,
    );
    return documents.isNotEmpty ? documents.first : null;
  }

  /// Get the default document for a document type
  Future<CmsDocument?> getDefaultDocument(
    Session session,
    String documentType,
  ) async {
    final documents = await CmsDocument.db.find(
      session,
      where: (t) => t.documentType.equals(documentType) & t.isDefault.equals(true),
      limit: 1,
    );
    return documents.isNotEmpty ? documents.first : null;
  }


  /// Create a new document with an initial version
  /// This creates both the CmsDocument and its first DocumentVersion
  Future<CmsDocument> createDocument(
    Session session,
    String documentType,
    String title,
    Map<String, dynamic> data, {
    String? slug,
    bool isDefault = false,
  }) async {
    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to create documents');
    }

    final userId = authInfo.userId;

    // Create the document
    final encodedData = jsonEncode(data);
    final document = CmsDocument(
      clientId: 1, // TODO: Get from session or parameter
      documentType: documentType,
      title: title,
      slug: slug,
      isDefault: isDefault,
      activeVersionData: encodedData, // Cache the initial data
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdByUserId: userId,
      updatedByUserId: userId,
    );

    final created = await CmsDocument.db.insertRow(session, document);

    // Create the initial version
    if (created.id != null) {
      final version = DocumentVersion(
        documentId: created.id!,
        versionNumber: 1,
        status: 'draft',
        data: encodedData,
        changeLog: 'Initial version',
        createdAt: DateTime.now(),
        createdByUserId: userId,
      );
      await DocumentVersion.db.insertRow(session, version);
    }

    return created;
  }

  /// Update document metadata (title, slug, isDefault)
  /// To update document data, use createDocumentVersion instead
  Future<CmsDocument?> updateDocument(
    Session session,
    int documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) async {
    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to update documents');
    }

    final userId = authInfo.userId;

    final existing = await CmsDocument.db.findById(session, documentId);

    if (existing == null) {
      return null;
    }

    final updated = existing.copyWith(
      title: title ?? existing.title,
      slug: slug ?? existing.slug,
      isDefault: isDefault ?? existing.isDefault,
      updatedAt: DateTime.now(),
      updatedByUserId: userId,
    );

    await CmsDocument.db.updateRow(session, updated);
    return updated;
  }

  /// Delete a document
  Future<bool> deleteDocument(
    Session session,
    int documentId,
  ) async {
    final existing = await CmsDocument.db.findById(session, documentId);

    if (existing == null) {
      return false;
    }

    await CmsDocument.db.deleteRow(session, existing);
    return true;
  }


  /// Get all document types (unique document type names)
  Future<List<String>> getDocumentTypes(Session session) async {
    final result = await session.db.unsafeQuery(
      'SELECT DISTINCT document_type FROM cms_documents ORDER BY document_type',
    );

    return result.map((row) => row.first as String).toList();
  }

  // ============================================================
  // Document Version Operations
  // ============================================================

  /// Get all versions for a document with pagination
  Future<DocumentVersionList> getDocumentVersions(
    Session session,
    int documentId, {
    int limit = 20,
    int offset = 0,
  }) async {
    // Get total count
    final total = await DocumentVersion.db.count(
      session,
      where: (t) => t.documentId.equals(documentId),
    );

    // Get paginated versions, ordered by version number descending
    final versions = await DocumentVersion.db.find(
      session,
      where: (t) => t.documentId.equals(documentId),
      orderBy: (t) => t.versionNumber,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );

    return DocumentVersionList(
      versions: versions,
      total: total,
      page: (offset ~/ limit) + 1,
      pageSize: limit,
    );
  }

  /// Get a single version by ID
  Future<DocumentVersion?> getDocumentVersion(
    Session session,
    int versionId,
  ) async {
    return await DocumentVersion.db.findById(session, versionId);
  }

  /// Create a new version for a document
  /// If status is 'published', updates the document's activeVersionData
  Future<DocumentVersion> createDocumentVersion(
    Session session,
    int documentId,
    Map<String, dynamic> data, {
    String status = 'draft',
    String? changeLog,
  }) async {
    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to create versions');
    }

    final userId = authInfo.userId;

    // Get the next version number for this document
    final existingVersions = await DocumentVersion.db.find(
      session,
      where: (t) => t.documentId.equals(documentId),
      orderBy: (t) => t.versionNumber,
      orderDescending: true,
      limit: 1,
    );

    final nextVersionNumber =
        existingVersions.isEmpty ? 1 : existingVersions.first.versionNumber + 1;

    final version = DocumentVersion(
      documentId: documentId,
      versionNumber: nextVersionNumber,
      status: status,
      data: jsonEncode(data),
      changeLog: changeLog,
      createdAt: DateTime.now(),
      createdByUserId: userId,
    );

    final created = await DocumentVersion.db.insertRow(session, version);

    // Sync activeVersionData if this is a published version
    if (status == 'published') {
      await _syncActiveVersionData(session, documentId);
    }

    return created;
  }

  /// Update an existing version
  /// If the version is published, updates the document's activeVersionData
  Future<DocumentVersion?> updateDocumentVersion(
    Session session,
    int versionId,
    Map<String, dynamic> data, {
    String? changeLog,
  }) async {
    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to update versions');
    }

    final existing = await DocumentVersion.db.findById(session, versionId);

    if (existing == null) {
      return null;
    }

    final updated = existing.copyWith(
      data: jsonEncode(data),
      changeLog: changeLog ?? existing.changeLog,
    );

    await DocumentVersion.db.updateRow(session, updated);

    // Sync activeVersionData if this is a published version
    if (updated.status == 'published') {
      await _syncActiveVersionData(session, updated.documentId);
    }

    return updated;
  }

  /// Publish a version (set status to 'published' and set publishedAt timestamp)
  /// Also updates the document's activeVersionData cache
  Future<DocumentVersion?> publishDocumentVersion(
    Session session,
    int versionId,
  ) async {
    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to publish versions');
    }

    final existing = await DocumentVersion.db.findById(session, versionId);

    if (existing == null) {
      return null;
    }

    final updated = existing.copyWith(
      status: 'published',
      publishedAt: DateTime.now(),
    );

    await DocumentVersion.db.updateRow(session, updated);

    // Sync activeVersionData
    await _syncActiveVersionData(session, existing.documentId);

    return updated;
  }

  /// Archive a version (set status to 'archived' and set archivedAt timestamp)
  /// If archiving the published version, updates activeVersionData to next published version or null
  Future<DocumentVersion?> archiveDocumentVersion(
    Session session,
    int versionId,
  ) async {
    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to archive versions');
    }

    final existing = await DocumentVersion.db.findById(session, versionId);

    if (existing == null) {
      return null;
    }

    final wasPublished = existing.status == 'published';

    final updated = existing.copyWith(
      status: 'archived',
      archivedAt: DateTime.now(),
    );

    await DocumentVersion.db.updateRow(session, updated);

    // Sync activeVersionData if we archived a published version
    if (wasPublished) {
      await _syncActiveVersionData(session, existing.documentId);
    }

    return updated;
  }

  /// Delete a version
  /// If deleting the published version, updates activeVersionData to next published version or null
  Future<bool> deleteDocumentVersion(
    Session session,
    int versionId,
  ) async {
    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to delete versions');
    }

    final existing = await DocumentVersion.db.findById(session, versionId);

    if (existing == null) {
      return false;
    }

    final wasPublished = existing.status == 'published';
    final documentId = existing.documentId;

    await DocumentVersion.db.deleteRow(session, existing);

    // Sync activeVersionData if we deleted a published version
    if (wasPublished) {
      await _syncActiveVersionData(session, documentId);
    }

    return true;
  }
}
