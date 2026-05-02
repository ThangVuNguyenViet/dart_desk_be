import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../auth/dart_desk_session.dart';
import '../generated/protocol.dart';

/// Read-only public content API for external consumers.
/// Requires a project API key with read permission.
/// Project scope is derived from the API key.
/// All reads come from [PublishedDocument] (the published snapshot table),
/// so post-publish draft edits never leak to public consumers.
class PublicContentEndpoint extends Endpoint {
  /// Returns all published documents grouped by document type.
  Future<Map<String, List<PublicDocument>>> getAllContents(
    Session session,
  ) async {
    final projectId = _requireReadAccess(session);

    final docs = await PublishedDocument.db.find(
      session,
      where: (t) =>
          t.projectId.equals(projectId) & t.deletedAt.equals(null),
    );

    final grouped = <String, List<PublicDocument>>{};
    for (final doc in docs) {
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

    final docs = await PublishedDocument.db.find(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.isDefault.equals(true) &
          t.deletedAt.equals(null),
    );

    final result = <String, PublicDocument>{};
    for (final doc in docs) {
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

    final docs = await PublishedDocument.db.find(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.documentType.equals(documentType) &
          t.deletedAt.equals(null),
    );

    return Future.wait(docs.map((d) => _toPublicDocument(session, d)));
  }

  /// Returns the default published document for a specific type.
  Future<PublicDocument> getDefaultContent(
    Session session,
    String documentType,
  ) async {
    final projectId = _requireReadAccess(session);

    final doc = await PublishedDocument.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.documentType.equals(documentType) &
          t.isDefault.equals(true) &
          t.deletedAt.equals(null),
    );

    if (doc == null) {
      throw ApiException(
          message:
              'No default published document found for type "$documentType".',
          code: 404);
    }

    return _toPublicDocument(session, doc);
  }

  /// Returns a single published document by type and slug.
  Future<PublicDocument> getContentBySlug(
    Session session,
    String documentType,
    String slug,
  ) async {
    final projectId = _requireReadAccess(session);

    final doc = await PublishedDocument.db.findFirstRow(
      session,
      where: (t) =>
          t.projectId.equals(projectId) &
          t.documentType.equals(documentType) &
          t.slug.equals(slug) &
          t.deletedAt.equals(null),
    );

    if (doc == null) {
      throw ApiException(
          message:
              'No published document found for type "$documentType" with slug "$slug".',
          code: 404);
    }

    return _toPublicDocument(session, doc);
  }

  /// Returns published documents of [documentType] whose JSON `data` contains
  /// the [dataContainsJson] fragment. The fragment must parse to a JSON object;
  /// scalars and arrays are rejected. Matching uses Postgres `jsonb` containment
  /// (`@>`) against the `data` jsonb column on `published_documents`. Project
  /// scope is enforced from the API key. Capped at 100 results.
  Future<List<PublicDocument>> getContentsByDataContains(
    Session session,
    String documentType,
    String dataContainsJson,
  ) async {
    final projectId = _requireReadAccess(session);

    final dynamic parsed;
    try {
      parsed = jsonDecode(dataContainsJson);
    } catch (_) {
      throw ApiException(
        message: 'dataContainsJson must be valid JSON',
        code: 400,
      );
    }
    if (parsed is! Map<String, dynamic>) {
      throw ApiException(
        message: 'dataContainsJson must be a JSON object',
        code: 400,
      );
    }

    // Step 1: raw SQL filter using data_jsonb @> ... on published_documents.
    // published_documents.data is text; data_jsonb is a generated jsonb column
    // with a GIN index (published_docs_data_gin), so containment queries are
    // index-backed. Same pattern as documents.data_jsonb (see CLAUDE.md).
    final idRows = await session.db.unsafeQuery(
      r'''
      SELECT id FROM published_documents
      WHERE "projectId" = @projectId
        AND "documentType" = @docType
        AND "deletedAt" IS NULL
        AND data_jsonb @> @fragment::jsonb
      LIMIT 100
      ''',
      parameters: QueryParameters.named({
        'projectId': projectId.toString(),
        'docType': documentType,
        'fragment': dataContainsJson,
      }),
    );

    final ids =
        idRows.map((r) => UuidValue.fromString(r[0].toString())).toSet();
    if (ids.isEmpty) return [];

    // Step 2: typed materialization via the normal ORM.
    final docs = await PublishedDocument.db.find(
      session,
      where: (t) => t.id.inSet(ids),
    );

    return Future.wait(docs.map((d) => _toPublicDocument(session, d)));
  }

  /// Cross-type variant of [getContentsByDataContains]: returns all published
  /// documents in the project whose JSON `data` contains [dataContainsJson],
  /// grouped by `documentType`. Same JSONB containment (`@>`) semantics and
  /// 100-row cap as the typed variant.
  Future<Map<String, List<PublicDocument>>> getAllContentsByDataContains(
    Session session,
    String dataContainsJson,
  ) async {
    final projectId = _requireReadAccess(session);

    final dynamic parsed;
    try {
      parsed = jsonDecode(dataContainsJson);
    } catch (_) {
      throw ApiException(
        message: 'dataContainsJson must be valid JSON',
        code: 400,
      );
    }
    if (parsed is! Map<String, dynamic>) {
      throw ApiException(
        message: 'dataContainsJson must be a JSON object',
        code: 400,
      );
    }

    final idRows = await session.db.unsafeQuery(
      r'''
      SELECT id FROM published_documents
      WHERE "projectId" = @projectId
        AND "deletedAt" IS NULL
        AND data_jsonb @> @fragment::jsonb
      LIMIT 100
      ''',
      parameters: QueryParameters.named({
        'projectId': projectId.toString(),
        'fragment': dataContainsJson,
      }),
    );

    final ids =
        idRows.map((r) => UuidValue.fromString(r[0].toString())).toSet();
    if (ids.isEmpty) return {};

    final docs = await PublishedDocument.db.find(
      session,
      where: (t) => t.id.inSet(ids),
    );

    final grouped = <String, List<PublicDocument>>{};
    for (final doc in docs) {
      grouped.putIfAbsent(doc.documentType, () => []);
      grouped[doc.documentType]!.add(await _toPublicDocument(session, doc));
    }
    return grouped;
  }

  // ------------------------------------------------------------------
  // Private helpers
  // ------------------------------------------------------------------

  /// Validates the API key has read access and returns the projectId.
  UuidValue _requireReadAccess(Session session) {
    if (!session.canRead) {
      throw ApiException(message: 'Missing read permission', code: 403);
    }
    final projectId = session.projectId;
    if (projectId == null) {
      throw ApiException(message: 'Missing project scope', code: 400);
    }
    return projectId;
  }

  Future<PublicDocument> _toPublicDocument(
    Session session,
    PublishedDocument live,
  ) async {
    final resolved = await _resolveImageReferences(session, live.data ?? '{}');
    return PublicDocument(
      id: live.documentId,
      documentType: live.documentType,
      title: live.title,
      slug: live.slug,
      isDefault: live.isDefault,
      data: resolved,
      publishedAt: live.publishedAt,
      updatedAt: live.updatedAt ?? DateTime.now(),
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
