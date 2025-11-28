import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

/// Endpoint for managing CMS documents
/// All write operations require authentication
class DocumentEndpoint extends Endpoint {
  /// Get all documents for a specific document type with pagination
  Future<DocumentListResponse> getDocuments(
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
          expr = expr & t.data.like('%$search%');
        }
        return expr;
      },
      orderBy: (t) => t.updatedAt,
      orderDescending: true,
      limit: limit,
      offset: offset,
    );

    return DocumentListResponse(
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

  /// Get a document by document type and ID
  Future<CmsDocument?> getDocumentByType(
    Session session,
    String documentType,
    int documentId,
  ) async {
    final documents = await CmsDocument.db.find(
      session,
      where: (t) => t.id.equals(documentId) & t.documentType.equals(documentType),
      limit: 1,
    );
    return documents.isNotEmpty ? documents.first : null;
  }

  /// Create a new document
  Future<CmsDocument> createDocument(
    Session session,
    String documentType,
    Map<String, dynamic> data,
  ) async {
    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to create documents');
    }

    final userId = authInfo.userId;

    final document = CmsDocument(
      documentType: documentType,
      data: jsonEncode(data),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdByUserId: userId,
      updatedByUserId: userId,
    );

    final created = await CmsDocument.db.insertRow(session, document);
    return created;
  }

  /// Update an existing document
  Future<CmsDocument?> updateDocument(
    Session session,
    int documentId,
    Map<String, dynamic> data,
  ) async {
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
      data: jsonEncode(data),
      updatedAt: DateTime.now(),
      updatedByUserId: userId,
    );

    await CmsDocument.db.updateRow(session, updated);
    return updated;
  }

  /// Update a document by document type and ID
  Future<CmsDocument?> updateDocumentByType(
    Session session,
    String documentType,
    int documentId,
    Map<String, dynamic> data,
  ) async {
    // Require authentication
    final authInfo = await session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated to update documents');
    }

    final userId = authInfo.userId;

    final existing = await getDocumentByType(session, documentType, documentId);

    if (existing == null) {
      return null;
    }

    final updated = existing.copyWith(
      data: jsonEncode(data),
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

  /// Delete a document by document type and ID
  Future<bool> deleteDocumentByType(
    Session session,
    String documentType,
    int documentId,
  ) async {
    final existing = await getDocumentByType(session, documentType, documentId);

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
}
