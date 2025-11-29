import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../../../server.dart' as server;

/// Endpoint for managing CMS documents
/// All write operations require authentication
class DocumentEndpoint extends Endpoint {

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
          // Search in title and data (cached latest version)
          expr = expr &
              (t.title.like('%$search%') |
                  t.data.like('%$search%'));
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
      data: encodedData, // Cache the initial data
      crdtNodeId: null, // Will be set when CRDT is initialized
      crdtHlc: null, // Will be set when CRDT is initialized
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdByUserId: userId,
      updatedByUserId: userId,
    );

    final created = await CmsDocument.db.insertRow(session, document);

    // Initialize CRDT for this document
    if (created.id != null) {
      await server.documentCrdtService.initializeCrdt(
        session,
        created.id!,
        data,
      );

      // Get the HLC that was set during initialization
      final updatedDoc = await CmsDocument.db.findById(session, created.id!);
      final currentHlc = updatedDoc?.crdtHlc;

      // Create initial version pointing to initial HLC
      final opCount = await server.documentCrdtService.getOperationCount(
        session,
        created.id!,
      );

      final version = DocumentVersion(
        documentId: created.id!,
        versionNumber: 1,
        status: DocumentVersionStatus.draft,
        snapshotHlc: currentHlc,
        operationCount: opCount,
        changeLog: 'Initial version',
        createdAt: DateTime.now(),
        createdByUserId: userId,
      );
      await DocumentVersion.db.insertRow(session, version);

      return updatedDoc ?? created;
    }

    return created;
  }

  /// Update document data using CRDT operations (partial updates)
  /// Only changed fields need to be provided - they will be merged automatically
  Future<CmsDocument> updateDocumentData(
    Session session,
    int documentId,
    Map<String, dynamic> updates, {
    String? sessionId,
  }) async {
    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to update documents');
    }

    // Use user ID as session ID if not provided
    final editSessionId = sessionId ?? 'user-${authInfo.userId}';

    // Apply CRDT operations
    return await server.documentCrdtService.applyOperations(
      session,
      documentId,
      updates,
      editSessionId,
    );
  }

  /// Update document metadata (title, slug, isDefault)
  /// To update document data, use updateDocumentData instead
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

  /// Get the document data for a specific version
  /// Reconstructs the data from CRDT operations at the version's HLC snapshot
  Future<Map<String, dynamic>?> getDocumentVersionData(
    Session session,
    int versionId,
  ) async {
    final version = await DocumentVersion.db.findById(session, versionId);
    if (version == null) return null;

    // If version has no HLC snapshot, return empty data
    if (version.snapshotHlc == null) {
      return {};
    }

    // Reconstruct document state at this version's HLC
    return await server.documentCrdtService.getStateAtHlc(
      session,
      version.documentId,
      version.snapshotHlc!,
    );
  }

  /// Create a new version for a document
  /// Captures the current CRDT state as a version snapshot
  Future<DocumentVersion> createDocumentVersion(
    Session session,
    int documentId, {
    DocumentVersionStatus status = DocumentVersionStatus.draft,
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

    // Get current CRDT HLC and operation count for version snapshot
    final currentHlc = await server.documentCrdtService.getCurrentHlc(
      session,
      documentId,
    );
    final opCount = await server.documentCrdtService.getOperationCount(
      session,
      documentId,
    );

    final version = DocumentVersion(
      documentId: documentId,
      versionNumber: nextVersionNumber,
      status: status,
      snapshotHlc: currentHlc,
      operationCount: opCount,
      changeLog: changeLog,
      createdAt: DateTime.now(),
      createdByUserId: userId,
    );

    final created = await DocumentVersion.db.insertRow(session, version);

    return created;
  }

  /// Publish a version (set status to 'published' and set publishedAt timestamp)
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
      status: DocumentVersionStatus.published,
      publishedAt: DateTime.now(),
    );

    await DocumentVersion.db.updateRow(session, updated);

    return updated;
  }

  /// Archive a version (set status to 'archived' and set archivedAt timestamp)
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

    final updated = existing.copyWith(
      status: DocumentVersionStatus.archived,
      archivedAt: DateTime.now(),
    );

    await DocumentVersion.db.updateRow(session, updated);

    return updated;
  }

  /// Delete a version
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

    await DocumentVersion.db.deleteRow(session, existing);

    return true;
  }
}
