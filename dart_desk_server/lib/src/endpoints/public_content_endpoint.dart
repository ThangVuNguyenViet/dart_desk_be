import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../auth/dart_desk_session.dart';
import '../generated/protocol.dart';

/// Read-only public content API for external consumers.
/// Requires a project API key with read permission.
/// Project scope is derived from the API key.
class PublicContentEndpoint extends Endpoint {
  /// Returns all published documents grouped by document type.
  Future<Map<String, List<PublicDocument>>> getAllContents(
    Session session,
  ) async {
    final projectId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.publishedAt.notEquals(null) &
          t.deletedAt.equals(null),
    );

    final grouped = <String, List<PublicDocument>>{};
    for (final doc in documents) {
      grouped.putIfAbsent(doc.documentType, () => []);
      grouped[doc.documentType]!.add(await _toPublicDocument(session, doc));
    }
    return grouped;
  }

  /// Returns the default published document for each document type.
  Future<Map<String, PublicDocument>> getDefaultContents(
    Session session,
  ) async {
    final projectId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.publishedAt.notEquals(null) &
          t.isDefault.equals(true) &
          t.deletedAt.equals(null),
    );

    final result = <String, PublicDocument>{};
    for (final doc in documents) {
      result[doc.documentType] = await _toPublicDocument(session, doc);
    }
    return result;
  }

  /// Returns all published documents of a specific type.
  Future<List<PublicDocument>> getContentsByType(
    Session session,
    String documentType,
  ) async {
    final projectId = _requireReadAccess(session);

    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType) &
          t.deletedAt.equals(null),
    );

    return Future.wait(documents.map((d) => _toPublicDocument(session, d)));
  }

  /// Returns the default published document for a specific type.
  Future<PublicDocument> getDefaultContent(
    Session session,
    String documentType,
  ) async {
    final projectId = _requireReadAccess(session);

    final document = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType) &
          t.isDefault.equals(true) &
          t.deletedAt.equals(null),
    );

    if (document == null) {
      throw ApiException(message: 'No default published document found for type "$documentType".', code: 400);
    }

    return _toPublicDocument(session, document);
  }

  /// Returns a single published document by type and slug.
  Future<PublicDocument> getContentBySlug(
    Session session,
    String documentType,
    String slug,
  ) async {
    final projectId = _requireReadAccess(session);

    final document = await Document.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.publishedAt.notEquals(null) &
          t.documentType.equals(documentType) &
          t.slug.equals(slug) &
          t.deletedAt.equals(null),
    );

    if (document == null) {
      throw ApiException(message: 'No published document found for type "$documentType" with slug "$slug".', code: 400);
    }

    return _toPublicDocument(session, document);
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  /// Validates the API key has read access and returns the projectId.
  int _requireReadAccess(Session session) {
    if (!session.canRead) {
      throw ApiException(message: 'Missing read permission', code: 403);
    }
    final projectId = session.projectId;
    if (projectId == null) {
      throw ApiException(message: 'Missing project scope', code: 400);
    }
    return projectId;
  }

  Future<PublicDocument> _toPublicDocument(Session session, Document doc) async {
    final data = await _resolveImageReferences(session, doc.data ?? '{}');
    return PublicDocument(
      id: doc.id!,
      documentType: doc.documentType,
      title: doc.title,
      slug: doc.slug,
      isDefault: doc.isDefault,
      data: data,
      publishedAt: doc.publishedAt!,
      updatedAt: doc.updatedAt ?? DateTime.now(),
    );
  }

  /// Scans [dataJson] for imageReference nodes, batch-fetches their MediaAsset
  /// records, and inlines publicUrl/width/height/blurHash/lqip into each node.
  Future<String> _resolveImageReferences(
    Session session,
    String dataJson,
  ) async {
    final map = jsonDecode(dataJson) as Map<String, dynamic>;

    final assetIds = <String>{};
    _collectAssetIds(map, assetIds);
    if (assetIds.isEmpty) return dataJson;

    final assets = await MediaAsset.db.find(
      session,
      where: (t) => t.assetId.inSet(assetIds),
    );
    final assetMap = {for (final a in assets) a.assetId: a};

    _inlineAssets(map, assetMap);
    return jsonEncode(map);
  }

  /// Recursively collects assetId values from all imageReference nodes.
  void _collectAssetIds(dynamic node, Set<String> ids) {
    if (node is Map<String, dynamic>) {
      if (node['_type'] == 'imageReference') {
        final id = node['assetId'] as String?;
        if (id != null) ids.add(id);
      }
      for (final v in node.values) {
        _collectAssetIds(v, ids);
      }
    } else if (node is List) {
      for (final v in node) {
        _collectAssetIds(v, ids);
      }
    }
  }

  /// Recursively replaces imageReference nodes with inlined asset fields.
  void _inlineAssets(dynamic node, Map<String, MediaAsset> assetMap) {
    if (node is Map<String, dynamic>) {
      if (node['_type'] == 'imageReference') {
        final id = node['assetId'] as String?;
        final asset = id != null ? assetMap[id] : null;
        if (asset != null) {
          node['publicUrl'] = asset.publicUrl;
          node['width'] = asset.width;
          node['height'] = asset.height;
          node['blurHash'] = asset.blurHash;
          if (asset.lqip != null) node['lqip'] = asset.lqip;
        }
      }
      for (final v in node.values.toList()) {
        _inlineAssets(v, assetMap);
      }
    } else if (node is List) {
      for (final v in node) {
        _inlineAssets(v, assetMap);
      }
    }
  }
}
