import 'package:serverpod/serverpod.dart';

import '../auth/dart_desk_session.dart';
import '../generated/protocol.dart';

/// Read-only public content API for external consumers.
/// Requires x-api-key with read permission.
/// ClientId is derived from the API key.
class PublicContentEndpoint extends Endpoint {
  /// Returns all published documents grouped by document type.
  Future<Map<String, List<PublicDocument>>> getAllContents(
    Session session,
  ) async {
    final clientId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) & t.publishedAt.notEquals(null),
    );

    final grouped = <String, List<PublicDocument>>{};
    for (final doc in documents) {
      grouped.putIfAbsent(doc.documentType, () => []);
      grouped[doc.documentType]!.add(_toPublicDocument(doc));
    }
    return grouped;
  }

  /// Returns the default published document for each document type.
  Future<Map<String, PublicDocument>> getDefaultContents(
    Session session,
  ) async {
    final clientId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.isDefault.equals(true),
    );

    return {
      for (final doc in documents)
        doc.documentType: _toPublicDocument(doc),
    };
  }

  /// Returns all published documents of a specific type.
  Future<List<PublicDocument>> getContentsByType(
    Session session,
    String documentType,
  ) async {
    final clientId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType),
    );

    return documents.map(_toPublicDocument).toList();
  }

  /// Returns the default published document for a specific type.
  Future<PublicDocument> getDefaultContent(
    Session session,
    String documentType,
  ) async {
    final clientId = _requireReadAccess(session);

    final document = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType) &
          t.isDefault.equals(true),
    );

    if (document == null) {
      throw Exception(
        'No default published document found for type "$documentType".',
      );
    }

    return _toPublicDocument(document);
  }

  /// Returns a single published document by type and slug.
  Future<PublicDocument> getContentBySlug(
    Session session,
    String documentType,
    String slug,
  ) async {
    final clientId = _requireReadAccess(session);

    final document = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.clientId.equals(clientId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType) &
          t.slug.equals(slug),
    );

    if (document == null) {
      throw Exception(
        'No published document found for type "$documentType" with slug "$slug".',
      );
    }

    return _toPublicDocument(document);
  }

  /// Validates the API key has read access and returns the clientId.
  int? _requireReadAccess(Session session) {
    final apiKey = session.apiKey;
    if (apiKey == null) {
      throw Exception('Missing API key');
    }
    if (!apiKey.canRead) {
      throw Exception('API key does not have read permission.');
    }
    return apiKey.clientId;
  }

  PublicDocument _toPublicDocument(Document doc) {
    return PublicDocument(
      id: doc.id!,
      documentType: doc.documentType,
      title: doc.title,
      slug: doc.slug,
      isDefault: doc.isDefault,
      data: doc.data ?? '{}',
      publishedAt: doc.publishedAt!,
      updatedAt: doc.updatedAt ?? DateTime.now(),
    );
  }
}
