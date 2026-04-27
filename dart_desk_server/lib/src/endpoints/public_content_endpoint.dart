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
      throw ApiException(message: 'No default published document found for type "$documentType".', code: 404);
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
      throw ApiException(message: 'No published document found for type "$documentType" with slug "$slug".', code: 404);
    }

    return _toPublicDocument(session, document);
  }

  /// Returns published documents of [documentType] whose JSON `data` contains
  /// the [dataContainsJson] fragment. The fragment must parse to a JSON object;
  /// scalars and arrays are rejected. Matching uses Postgres `jsonb` containment
  /// (`@>`) against the `data_jsonb` generated column. Project scope is enforced
  /// from the API key. Capped at 100 results.
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

    // Step 1: raw SQL filter using data_jsonb @> ... — only fetches matching IDs.
    // Uses the data_jsonb generated column (not data) because Postgres can only
    // GIN-index jsonb, and the typed ORM doesn't know about data_jsonb.
    // Column names are quoted camelCase to match the documents table DDL.
    final idRows = await session.db.unsafeQuery(
      r'''
      SELECT id FROM documents
      WHERE "projectId" = @projectId
        AND "documentType" = @docType
        AND "publishedAt" IS NOT NULL
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

    final ids = idRows.map((r) => UuidValue.fromString(r[0].toString())).toSet();
    if (ids.isEmpty) return [];

    // Step 2: typed materialization via the normal ORM.
    //
    // Design decision: we use a two-step pattern (raw SQL filter, then typed
    // load by ID) instead of a single SELECT * + hand-written row-to-Document
    // mapper. The trade-offs:
    //
    //   Two-step (chosen):
    //     - Document.db.find returns fully-typed Document objects automatically.
    //     - No hand-rolled deserializer to maintain.
    //     - Adding a new field to Document later: this endpoint adapts for free.
    //     - Survives column reorders and schema evolution.
    //     - Cost: one extra DB round-trip (negligible at LIMIT 100 on indexed
    //       queries — sub-ms locally, single-digit ms across a managed DB).
    //
    //   One-step (rejected):
    //     - SELECT * + DatabaseResultRow.toColumnMap() + hand-rolled mapper.
    //     - One round-trip, but ~15 lines of brittle name-keyed deserialization.
    //     - Silent-bug failure mode: adding a new field to Document leaves it
    //       unset on every result from this endpoint until someone notices.
    //     - Tight coupling between this endpoint and Document's column list.
    //
    // The typed `data_jsonb` column would also re-introduce the type-cast issue
    // we hit during D5 (driver decodes jsonb to Map; can't cast to String?).
    // Loading via Document.db.find sidesteps that — it reads the `data` text
    // column normally, which is why this two-step pattern works at all.
    final docs = await Document.db.find(
      session,
      where: (t) => t.id.inSet(ids),
    );

    return Future.wait(docs.map((d) => _toPublicDocument(session, d)));
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

  Future<PublicDocument> _toPublicDocument(Session session, Document doc) async {
    final data = await _resolveImageReferences(session, doc.data ?? '{}');
    return PublicDocument(
      id: doc.id,
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
