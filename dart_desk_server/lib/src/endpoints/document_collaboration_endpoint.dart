import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:uuid/uuid.dart';

import '../auth/dart_desk_session.dart';
import '../auth/resolve_user.dart';
import '../plugin/dart_desk_session.dart';
import '../generated/protocol.dart';

/// Endpoint for real-time document collaboration features
/// Provides operation polling, edit submission, and presence tracking
class DocumentCollaborationEndpoint extends Endpoint {
  /// Get CRDT operations since a specific HLC timestamp
  /// Used for polling updates from other users
  Future<List<DocumentCrdtOperation>> getOperationsSince(
    Session session,
    UuidValue documentId,
    String sinceHlc, {
    int limit = 100,
  }) async {
    // Use raw SQL for efficient HLC string comparison
    final operations = await session.db.unsafeQuery(
      r'SELECT * FROM document_crdt_operations WHERE "documentId" = $1 AND hlc > $2 ORDER BY hlc ASC LIMIT $3',
      parameters: QueryParameters.positional([documentId, sinceHlc, limit]),
    );

    final result = <DocumentCrdtOperation>[];
    for (var row in operations) {
      result.add(DocumentCrdtOperation.fromJson(row.toColumnMap()));
    }

    return result;
  }

  /// Submit an edit (partial field updates) for collaborative editing
  Future<Document> submitEdit(
    Session session,
    UuidValue documentId,
    String sessionId,
    String fieldUpdatesJson,
  ) async {
    if (!session.canWrite) throw ApiException(message: 'Missing write permission', code: 403);
    final user = await resolveUser(session, clientId: session.clientId);
    final fieldUpdates = jsonDecode(fieldUpdatesJson) as Map<String, dynamic>;

    // Apply CRDT operations
    return await session.crdtService.applyOperations(
      session,
      documentId,
      fieldUpdates,
      sessionId,
      cmsUserId: user.id,
    );
  }

  /// Get list of users currently editing this document
  /// Based on recent operation activity (last 5 minutes)
  Future<List<String>> getActiveEditors(
    Session session,
    UuidValue documentId,
  ) async {
    final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));

    // Get recent operations for this document
    final recentOps = await DocumentCrdtOperation.db.find(
      session,
      where: (t) => t.documentId.equals(documentId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
      limit: 500, // Get recent batch
    );

    // Filter by time and group by user
    final userEdits = <UuidValue, DateTime>{};
    for (var op in recentOps) {
      if (op.createdAt != null &&
          op.createdAt!.isAfter(fiveMinutesAgo) &&
          op.createdByUserId != null) {
        final userId = op.createdByUserId!;
        final lastEdit = userEdits[userId];
        if (lastEdit == null || op.createdAt!.isAfter(lastEdit)) {
          userEdits[userId] = op.createdAt!;
        }
      }
    }

    // Build result with user IDs (frontend can fetch user details)
    final editors = <String>[];
    userEdits.forEach((userId, lastEdit) {
      editors.add(jsonEncode({
        'userId': userId.toString(),
        'lastEdit': lastEdit.toIso8601String(),
      }));
    });

    // Sort by most recent activity
    editors.sort((a, b) {
      final aMap = jsonDecode(a) as Map<String, dynamic>;
      final bMap = jsonDecode(b) as Map<String, dynamic>;
      return (bMap['lastEdit'] as String).compareTo(aMap['lastEdit'] as String);
    });

    return editors;
  }

  /// Get the current HLC for a document
  /// Useful for clients to know where they are in the operation log
  Future<String?> getCurrentHlc(
    Session session,
    UuidValue documentId,
  ) async {
    return await session.crdtService.getCurrentHlc(session, documentId);
  }

  /// Get operation count for a document
  /// Useful for monitoring and deciding when to compact
  Future<int> getOperationCount(
    Session session,
    UuidValue documentId,
  ) async {
    return await session.crdtService.getOperationCount(
      session,
      documentId,
    );
  }

  /// Manually trigger operation compaction
  /// Creates a snapshot and cleans up old operations
  Future<void> compactOperations(
    Session session,
    UuidValue documentId,
  ) async {
    if (!session.canWrite) throw ApiException(message: 'Missing write permission', code: 403);
    await resolveUser(session, clientId: session.clientId);

    await session.crdtService.compactOperations(session, documentId);
  }
}
