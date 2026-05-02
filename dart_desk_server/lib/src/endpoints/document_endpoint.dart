import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../auth/dart_desk_session.dart';
import '../auth/require_role.dart';
import '../auth/resolve_user.dart';
import '../generated/protocol.dart';
import '../plugin/dart_desk_session.dart';

typedef AuthResult = ({UuidValue? clientId, UuidValue? projectId, User? user});

/// Endpoint for managing CMS documents
/// All write operations require authentication
class DocumentEndpoint extends Endpoint {
  /// Get all documents for a specific document type with pagination
  Future<PaginatedDocuments> getDocuments(
    Session session,
    String documentType, {
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    final auth = await _requireAuth(session);

    // Get total count filtered by projectId
    final total = await Document.db.count(
      session,
      where: (t) =>
          t.documentType.equals(documentType) &
          t.projectId.equals(auth.projectId) &
          t.deletedAt.equals(null),
    );

    // Get paginated documents filtered by projectId
    final documents = await Document.db.find(
      session,
      where: (t) {
        var expr = t.documentType.equals(documentType) &
            t.projectId.equals(auth.projectId) &
            t.deletedAt.equals(null);
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

    return PaginatedDocuments(
      items: documents,
      total: total,
      limit: limit,
      offset: offset,
      hasMore: offset + documents.length < total,
    );
  }

  /// Get a single document by ID
  Future<Document?> getDocument(
    Session session,
    UuidValue documentId,
  ) async {
    final doc = await Document.db.findById(session, documentId);
    if (doc == null) return null;
    if (doc.deletedAt != null) {
      throw ApiException(
          message: 'Document has been deleted',
          code: 410,
          errorCode: 'RESOURCE_DELETED');
    }
    return doc;
  }

  /// Get the default document for a document type
  Future<Document?> getDefaultDocument(
    Session session,
    String documentType,
  ) async {
    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.documentType.equals(documentType) &
          t.isDefault.equals(true) &
          t.deletedAt.equals(null),
      limit: 1,
    );
    return documents.isNotEmpty ? documents.first : null;
  }

  /// Create a new document with an initial version
  /// This creates both the Document and its first DocumentVersion
  Future<Document> createDocument(
    Session session,
    String documentType,
    String title,
    String dataJson, {
    String? slug,
    bool isDefault = false,
  }) async {
    final auth = await _requireUser(session);
    final userId = auth.user!.id;
    final data = jsonDecode(dataJson) as Map<String, dynamic>;

    // Create the document — encode data as JSON for storage
    final effectiveSlug = slug ??
        title
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s-]'), '')
            .replaceAll(RegExp(r'\s+'), '-')
            .replaceAll(RegExp(r'-+'), '-')
            .trim();
    final document = Document(
      projectId: auth.projectId!,
      documentType: documentType,
      title: title,
      slug: effectiveSlug,
      isDefault: isDefault,
      data: dataJson, // Cache the initial data
      crdtNodeId: null, // Will be set when CRDT is initialized
      crdtHlc: null, // Will be set when CRDT is initialized
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdByUserId: userId,
      updatedByUserId: userId,
    );

    // Check if a document with the same slug already exists for this type.
    // Ignore soft-deleted rows so a slug can be reused after deletion.
    final existing = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(document.projectId) &
          t.documentType.equals(documentType) &
          t.slug.equals(effectiveSlug) &
          t.deletedAt.equals(null),
    );
    if (existing != null) {
      throw ApiException(
          message:
              'A document with slug "$effectiveSlug" already exists for type "$documentType".',
          code: 409);
    }

    final created = await Document.db.insertRow(session, document);
    session.log('Created Document id=${created.id} type=$documentType',
        level: LogLevel.info);

    // Initialize CRDT for this document
    await session.crdtService.initializeCrdt(
      session,
      created.id,
      data,
      cmsUserId: userId,
    );

    // Get the HLC that was set during initialization
    final updatedDoc = await Document.db.findById(session, created.id);
    final currentHlc = updatedDoc?.crdtHlc;

    // Create initial version pointing to initial HLC
    final opCount = await session.crdtService.getOperationCount(
      session,
      created.id,
    );

    final version = DocumentVersion(
      documentId: created.id,
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

  /// Update document data using CRDT operations (partial updates)
  /// Only changed fields need to be provided - they will be merged automatically
  Future<Document> updateDocumentData(
    Session session,
    UuidValue documentId,
    String updatesJson, {
    String? sessionId,
  }) async {
    final auth = await _requireAuth(session);
    final updates = jsonDecode(updatesJson) as Map<String, dynamic>;

    // Use user ID as session ID if not provided
    final editSessionId = sessionId ?? 'user-${auth.user?.id}';

    // Apply CRDT operations
    final doc = await session.crdtService.applyOperations(
      session,
      documentId,
      updates,
      editSessionId,
      cmsUserId: auth.user?.id,
    );
    session.log('Updated DocumentData id=$documentId', level: LogLevel.info);
    return doc;
  }

  /// Update document metadata (title, slug, isDefault)
  /// To update document data, use updateDocumentData instead
  Future<Document?> updateDocument(
    Session session,
    UuidValue documentId, {
    String? title,
    String? slug,
    bool? isDefault,
  }) async {
    final auth = await _requireUser(session);
    final userId = auth.user!.id;

    final existing = await Document.db.findById(session, documentId);

    if (existing == null) {
      return null;
    }

    // Verify the document belongs to the user's client
    if (existing.projectId != auth.projectId) {
      throw ApiException(
          message: 'Access denied: document belongs to a different project',
          code: 403);
    }

    final updated = existing.copyWith(
      title: title ?? existing.title,
      slug: slug ?? existing.slug,
      isDefault: isDefault ?? existing.isDefault,
      updatedAt: DateTime.now(),
      updatedByUserId: userId,
    );

    await Document.db.updateRow(session, updated);
    session.log('Updated Document id=$documentId', level: LogLevel.info);
    return updated;
  }

  /// Atomically unsets the current default for [documentTypeSlug] in this
  /// project and sets [documentId] as the new default. Returns the updated
  /// document.
  Future<Document> setDefaultDocument(
    Session session,
    String documentTypeSlug,
    UuidValue documentId,
  ) async {
    final auth = await _requireUser(session);

    final doc = await Document.db.findById(session, documentId);
    if (doc == null) {
      throw ApiException(message: 'Document not found: $documentId', code: 404);
    }
    if (doc.projectId != auth.projectId) {
      throw ApiException(
          message: 'Access denied: document belongs to a different project',
          code: 403);
    }

    // Find the current default for this type (may be null or already this doc)
    final currentDefault = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.documentType.equals(documentTypeSlug) &
          t.projectId.equals(doc.projectId) &
          t.isDefault.equals(true) &
          t.deletedAt.equals(null),
    );

    final result = await session.db.transaction<Document>((transaction) async {
      // Unset old default (skip if it's already the target document)
      if (currentDefault != null && currentDefault.id != documentId) {
        await Document.db.updateRow(
          session,
          currentDefault.copyWith(isDefault: false),
          transaction: transaction,
        );
      }

      // Set new default
      final updated = doc.copyWith(isDefault: true);
      await Document.db.updateRow(session, updated, transaction: transaction);
      return updated;
    });
    session.log('Set default Document id=$documentId type=$documentTypeSlug',
        level: LogLevel.info);
    return result;
  }

  /// Delete a document (soft delete)
  Future<bool> deleteDocument(
    Session session,
    UuidValue documentId,
  ) async {
    final auth = await _requireUser(session);
    await RoleGuard.requireRole(
      session,
      allowed: RoleGuard.destructiveRoles,
      clientId: auth.clientId,
    );

    final existing = await Document.db.findById(session, documentId);
    if (existing == null) return false;
    if (existing.projectId != auth.projectId) {
      throw ApiException(
          message: 'Access denied: document belongs to a different project',
          code: 403);
    }
    if (existing.deletedAt != null) return false;

    final now = DateTime.now();
    existing.deletedAt = now;
    await Document.db.updateRow(session, existing);

    // Soft-delete all versions
    final versions = await DocumentVersion.db.find(
      session,
      where: (t) => t.documentId.equals(documentId) & t.deletedAt.equals(null),
    );
    for (final v in versions) {
      v.deletedAt = now;
      await DocumentVersion.db.updateRow(session, v);
    }
    session.log('Soft-deleted Document id=$documentId', level: LogLevel.info);
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
    final existing = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.slug.equals(baseSlug) &
          t.documentType.equals(documentType) &
          t.deletedAt.equals(null),
    );

    if (existing == null) {
      return baseSlug;
    }

    // Find the next available suffix
    // Query all slugs that match the pattern "baseSlug" or "baseSlug-N"
    final similarDocs = await Document.db.find(
      session,
      where: (t) =>
          t.slug.like('$baseSlug%') &
          t.documentType.equals(documentType) &
          t.deletedAt.equals(null),
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
    final auth = await _requireAuth(session);
    final projectId = auth.projectId;

    final result = projectId != null
        ? await session.db.unsafeQuery(
            'SELECT DISTINCT "documentType" FROM documents '
            'WHERE "projectId" = \$1 '
            'ORDER BY "documentType"',
            parameters: QueryParameters.positional([projectId.toString()]),
          )
        : await session.db.unsafeQuery(
            'SELECT DISTINCT "documentType" FROM documents '
            'WHERE "projectId" IS NULL '
            'ORDER BY "documentType"',
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
    UuidValue documentId, {
    int limit = 20,
    int offset = 0,
    bool includeOperations = false,
  }) async {
    // Get total count
    final total = await DocumentVersion.db.count(
      session,
      where: (t) => t.documentId.equals(documentId) & t.deletedAt.equals(null),
    );

    // Get paginated versions, ordered by version number ascending
    // (to properly pair adjacent versions for operations)
    final versions = await DocumentVersion.db.find(
      session,
      where: (t) => t.documentId.equals(documentId) & t.deletedAt.equals(null),
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
        where: (t) =>
            t.documentId.equals(documentId) & t.deletedAt.equals(null),
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
        final baseState = await session.crdtService.getStateAtHlc(
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

        ops = await session.crdtService.getOperationsBetweenHlc(
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
    UuidValue versionId,
  ) async {
    final version = await DocumentVersion.db.findById(session, versionId);
    if (version == null) return null;
    if (version.deletedAt != null) {
      throw ApiException(
          message: 'Document version has been deleted',
          code: 410,
          errorCode: 'RESOURCE_DELETED');
    }
    return version;
  }

  /// Get the document data for a specific version.
  /// Reconstructs the data from CRDT operations at the version's HLC snapshot.
  Future<String?> getDocumentVersionData(
    Session session,
    UuidValue versionId,
  ) async {
    final version = await DocumentVersion.db.findById(session, versionId);
    if (version == null) return null;

    // If version has no HLC snapshot, return empty data
    if (version.snapshotHlc == null) {
      return '{}';
    }

    // Reconstruct document state at this version's HLC
    final data = await session.crdtService.getStateAtHlc(
      session,
      version.documentId,
      version.snapshotHlc!,
    );
    return jsonEncode(data);
  }

  /// Create a new version for a document
  /// Captures the current CRDT state as a version snapshot
  Future<DocumentVersion> createDocumentVersion(
    Session session,
    UuidValue documentId, {
    DocumentVersionStatus status = DocumentVersionStatus.draft,
    String? changeLog,
  }) async {
    final auth = await _requireUser(session);
    final userId = auth.user!.id;

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
    final currentHlc = await session.crdtService.getCurrentHlc(
      session,
      documentId,
    );
    final opCount = await session.crdtService.getOperationCount(
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

  /// Publish the document's current draft as a new version.
  ///
  /// Atomic flow:
  /// 1. Read the document's current crdtHlc as snapshotHlc.
  /// 2. Determine next version number.
  /// 3. Insert a new document_versions row with status=published.
  /// 4. Reconstruct the full data Map at snapshotHlc.
  /// 5. Upsert the published_documents row.
  /// Steps 3-5 are wrapped in a single transaction.
  Future<DocumentVersion> publishCurrentVersion(
    Session session,
    UuidValue documentId,
  ) async {
    final auth = await _requireUser(session);
    final userId = auth.user!.id;

    final document = await Document.db.findById(session, documentId);
    if (document == null) {
      throw ApiException(message: 'Document not found: $documentId', code: 404);
    }
    if (document.projectId != auth.projectId) {
      throw ApiException(
          message: 'Access denied: document belongs to a different project',
          code: 403);
    }

    final snapshotHlc = document.crdtHlc;
    if (snapshotHlc == null) {
      throw ApiException(
          message: 'Document has no CRDT state; cannot publish',
          code: 400);
    }

    // Reconstruct CRDT state at the captured HLC. These reads happen outside
    // the transaction by design: the op log is append-only and HLC-keyed, so
    // reconstruction at a fixed snapshotHlc is deterministic regardless of
    // concurrent writes (a later write produces a newer HLC, not a different
    // value at our captured HLC). Inlining these into the transaction would
    // also break under `serverpod_test`'s RollbackDatabase, which forbids
    // bare-session reads while a transaction is active.
    final opCount = await session.crdtService.getOperationCount(
      session,
      documentId,
    );
    final reconstructedData = await session.crdtService.getStateAtHlc(
      session,
      documentId,
      snapshotHlc,
    );

    return await session.db.transaction<DocumentVersion>((tx) async {
      // Determine next version number
      final existing = await DocumentVersion.db.find(
        session,
        where: (t) => t.documentId.equals(documentId),
        orderBy: (t) => t.versionNumber,
        orderDescending: true,
        limit: 1,
        transaction: tx,
      );
      final nextVersionNumber =
          existing.isEmpty ? 1 : existing.first.versionNumber + 1;

      final now = DateTime.now();
      final newVersion = DocumentVersion(
        documentId: documentId,
        versionNumber: nextVersionNumber,
        status: DocumentVersionStatus.published,
        snapshotHlc: snapshotHlc,
        operationCount: opCount,
        publishedAt: now,
        createdAt: now,
        createdByUserId: userId,
      );
      final inserted = await DocumentVersion.db.insertRow(
        session,
        newVersion,
        transaction: tx,
      );
      final insertedId = inserted.id ??
          (throw StateError(
              'insertRow returned null id for DocumentVersion'));

      // Upsert published_documents row.
      // PublishedDocument.data is String? (same as documents.data) — store as
      // JSON-encoded text. Postgres maintains data_jsonb as a generated column.
      final dataJson = jsonEncode(reconstructedData);
      final existingLive = await PublishedDocument.db.findFirstRow(
        session,
        where: (t) => t.documentId.equals(documentId),
        transaction: tx,
      );

      if (existingLive == null) {
        await PublishedDocument.db.insertRow(
          session,
          PublishedDocument(
            documentId: documentId,
            projectId: document.projectId,
            documentType: document.documentType,
            title: document.title,
            slug: document.slug,
            isDefault: document.isDefault,
            data: dataJson,
            publishedAt: now,
            publishedVersionId: insertedId,
            updatedAt: now,
          ),
          transaction: tx,
        );
      } else {
        await PublishedDocument.db.updateRow(
          session,
          existingLive.copyWith(
            documentType: document.documentType,
            title: document.title,
            slug: document.slug,
            isDefault: document.isDefault,
            data: dataJson,
            publishedAt: now,
            publishedVersionId: insertedId,
            updatedAt: now,
            deletedAt: null,
          ),
          transaction: tx,
        );
      }

      session.log(
          'Published DocumentVersion id=$insertedId documentId=$documentId versionNumber=$nextVersionNumber',
          level: LogLevel.info);

      return inserted;
    });
  }

  /// Archive a version (set status to 'archived' and set archivedAt timestamp)
  Future<DocumentVersion?> archiveDocumentVersion(
    Session session,
    UuidValue versionId,
  ) async {
    await _requireAuth(session);

    final existing = await DocumentVersion.db.findById(session, versionId);

    if (existing == null) {
      return null;
    }

    final updated = existing.copyWith(
      status: DocumentVersionStatus.archived,
      archivedAt: DateTime.now(),
    );

    await DocumentVersion.db.updateRow(session, updated);
    session.log(
        'Archived DocumentVersion id=$versionId documentId=${existing.documentId}',
        level: LogLevel.info);

    // Check if any published versions remain for this document
    final publishedCount = await DocumentVersion.db.count(
      session,
      where: (t) =>
          t.documentId.equals(existing.documentId) &
          t.status.equals(DocumentVersionStatus.published),
    );

    return updated;
  }

  /// Delete a version (soft delete)
  Future<bool> deleteDocumentVersion(
    Session session,
    UuidValue versionId,
  ) async {
    final auth = await _requireUser(session);
    await RoleGuard.requireRole(session,
        allowed: RoleGuard.destructiveRoles, clientId: auth.clientId);
    final existing = await DocumentVersion.db.findById(session, versionId);
    if (existing == null || existing.deletedAt != null) return false;
    existing.deletedAt = DateTime.now();
    await DocumentVersion.db.updateRow(session, existing);
    session.log('Soft-deleted DocumentVersion id=$versionId',
        level: LogLevel.info);
    return true;
  }

  /// Get total document count for the specified project.
  Future<int> getDocumentCount(Session session,
      {required UuidValue projectId}) async {
    final project = await Project.db.findById(session, projectId);
    if (project == null) {
      throw ApiException(message: 'Project not found', code: 404);
    }
    await resolveUser(session, clientId: project.clientId);
    return await Document.db.count(
      session,
      where: (t) => t.projectId.equals(projectId),
    );
  }

  /// Authenticate the current request via scopes.
  Future<AuthResult> _requireAuth(Session session) async {
    if (!session.canRead) {
      throw ApiException(message: 'Missing read permission', code: 403);
    }
    return (
      clientId: session.clientId,
      projectId: session.projectId,
      user: null,
    );
  }

  /// Authenticate and require a user identity (for write operations).
  Future<AuthResult> _requireUser(Session session) async {
    if (!session.canWrite) {
      throw ApiException(message: 'Missing write permission', code: 403);
    }
    final user = await resolveUser(session, clientId: session.clientId);
    return (
      clientId: session.clientId,
      projectId: session.projectId,
      user: user,
    );
  }
}
