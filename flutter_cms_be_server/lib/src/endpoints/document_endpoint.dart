import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../../../server.dart' as server;
import '../generated/protocol.dart';

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
          expr = expr & (t.title.like('%$search%') | t.data.like('%$search%'));
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
      where: (t) =>
          t.documentType.equals(documentType) & t.isDefault.equals(true),
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
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to create documents');
    }

    final cmsUser = await _getCmsUser(session, authInfo.userIdentifier);
    final userId = cmsUser.id!;

    // Create the document
    final encodedData = jsonEncode(data);
    final effectiveSlug = slug ?? title.toLowerCase().replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(RegExp(r'\s+'), '-').replaceAll(RegExp(r'-+'), '-').trim();
    final document = CmsDocument(
      clientId: 1, // TODO: Get from session or parameter
      documentType: documentType,
      title: title,
      slug: effectiveSlug,
      isDefault: isDefault,
      data: encodedData, // Cache the initial data
      crdtNodeId: null, // Will be set when CRDT is initialized
      crdtHlc: null, // Will be set when CRDT is initialized
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdByUserId: userId,
      updatedByUserId: userId,
    );

    // Check if a document with the same slug already exists for this type
    final existing = await CmsDocument.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(document.clientId) &
          t.documentType.equals(documentType) &
          t.slug.equals(effectiveSlug),
    );
    if (existing != null) {
      throw Exception(
        'A document with slug "$effectiveSlug" already exists for type "$documentType".',
      );
    }

    final created = await CmsDocument.db.insertRow(session, document);

    // Initialize CRDT for this document
    if (created.id != null) {
      await server.documentCrdtService.initializeCrdt(
        session,
        created.id!,
        data,
        cmsUserId: userId,
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
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to update documents');
    }

    final cmsUser = await _getCmsUser(session, authInfo.userIdentifier);

    // Use user identifier as session ID if not provided
    final editSessionId = sessionId ?? 'user-${authInfo.userIdentifier}';

    // Apply CRDT operations
    return await server.documentCrdtService.applyOperations(
      session,
      documentId,
      updates,
      editSessionId,
      cmsUserId: cmsUser.id,
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
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to update documents');
    }

    final cmsUser = await _getCmsUser(session, authInfo.userIdentifier);
    final userId = cmsUser.id!;

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

  /// Suggest a unique slug for a document based on its title.
  ///
  /// Generates a URL-friendly slug from the title and checks the database
  /// for duplicates. If a duplicate exists, appends a numeric suffix (e.g. -2, -3).
  Future<String> suggestSlug(
    Session session,
    String title,
    String documentType,
  ) async {
    // Generate base slug from title
    var baseSlug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();

    if (baseSlug.isEmpty) {
      baseSlug = 'untitled';
    }

    // Remove trailing hyphens
    baseSlug = baseSlug.replaceAll(RegExp(r'-$'), '');

    // Check if this slug already exists
    final existing = await CmsDocument.db.findFirstRow(
      session,
      where: (t) =>
          t.slug.equals(baseSlug) & t.documentType.equals(documentType),
    );

    if (existing == null) {
      return baseSlug;
    }

    // Find the next available suffix
    // Query all slugs that match the pattern "baseSlug" or "baseSlug-N"
    final similarDocs = await CmsDocument.db.find(
      session,
      where: (t) =>
          t.slug.like('$baseSlug%') & t.documentType.equals(documentType),
    );

    final existingSlugs = similarDocs.map((d) => d.slug).toSet();

    var suffix = 2;
    while (existingSlugs.contains('$baseSlug-$suffix')) {
      suffix++;
    }

    return '$baseSlug-$suffix';
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
  /// Optionally includes CRDT operations between adjacent versions
  Future<DocumentVersionListWithOperations> getDocumentVersions(
    Session session,
    int documentId, {
    int limit = 20,
    int offset = 0,
    bool includeOperations = false,
  }) async {
    // Get total count
    final total = await DocumentVersion.db.count(
      session,
      where: (t) => t.documentId.equals(documentId),
    );

    // Get paginated versions, ordered by version number ascending
    // (to properly pair adjacent versions for operations)
    final versions = await DocumentVersion.db.find(
      session,
      where: (t) => t.documentId.equals(documentId),
      orderBy: (t) => t.versionNumber,
      orderDescending: false,
      limit: limit,
      offset: offset,
    );

    // Handle pagination edge case: need previous version's HLC for first item
    String? prevHlcForFirstItem;
    if (includeOperations && offset > 0 && versions.isNotEmpty) {
      final prevVersions = await DocumentVersion.db.find(
        session,
        where: (t) => t.documentId.equals(documentId),
        orderBy: (t) => t.versionNumber,
        orderDescending: false,
        limit: 1,
        offset: offset - 1,
      );
      prevHlcForFirstItem = prevVersions.firstOrNull?.snapshotHlc;
    }

    // Get base state for the first version in this page (for reconstruction)
    String? baseData;
    if (includeOperations && versions.isNotEmpty) {
      // Use the HLC BEFORE the first version as the base state
      final baseHlc = prevHlcForFirstItem;

      if (baseHlc != null) {
        // Reconstruct state at that point using getStateAtHlc
        final baseState = await server.documentCrdtService.getStateAtHlc(
          session,
          documentId,
          baseHlc,
        );
        baseData = jsonEncode(baseState);
      }
      // If baseHlc is null, we're at version 1, so baseState is empty {}
    }

    // Build versions with operations
    final versionsWithOps = <DocumentVersionWithOperations>[];

    for (var i = 0; i < versions.length; i++) {
      final version = versions[i];
      List<DocumentCrdtOperation> ops = [];

      if (includeOperations && version.snapshotHlc != null) {
        // Get previous version's HLC
        String? prevHlc;
        if (i == 0) {
          // First item in page: use fetched prev HLC (null for first version)
          prevHlc = prevHlcForFirstItem;
        } else {
          prevHlc = versions[i - 1].snapshotHlc;
        }

        ops = await server.documentCrdtService.getOperationsBetweenHlc(
          session,
          documentId,
          prevHlc,
          version.snapshotHlc!,
        );
      }

      versionsWithOps.add(DocumentVersionWithOperations(
        version: version,
        operationsSincePrevious: ops,
      ));
    }

    return DocumentVersionListWithOperations(
      versions: versionsWithOps,
      baseData: baseData,
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
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to create versions');
    }

    final cmsUser = await _getCmsUser(session, authInfo.userIdentifier);
    final userId = cmsUser.id!;

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
    final authInfo = session.authenticated;
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
    final authInfo = session.authenticated;
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
    final authInfo = session.authenticated;
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

  /// Look up the CMS user from the auth user identifier.
  Future<CmsUser> _getCmsUser(
      Session session, String userIdentifier) async {
    final cmsUser = await CmsUser.db.findFirstRow(
      session,
      where: (t) => t.serverpodUserId.equals(userIdentifier),
    );
    if (cmsUser == null) {
      throw Exception('CMS user not found for authenticated user');
    }
    return cmsUser;
  }
}
