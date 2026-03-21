import 'package:serverpod/serverpod.dart';

import '../../../server.dart' as server;
import '../auth/dart_desk_auth.dart';
import '../generated/protocol.dart';

/// Endpoint for real-time document collaboration features
/// Provides operation polling, edit submission, and presence tracking
class DocumentCollaborationEndpoint extends Endpoint {
  /// Get CRDT operations since a specific HLC timestamp
  /// Used for polling updates from other users
  Future<List<DocumentCrdtOperation>> getOperationsSince(
    Session session,
    int documentId,
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
    int documentId,
    String sessionId,
    Map<String, dynamic> fieldUpdates,
  ) async {
    final cmsUser = await DartDeskAuth.authenticateRequest(session);
    if (cmsUser == null) {
      throw Exception('User must be authenticated to submit edits');
    }

    // Apply CRDT operations
    return await server.documentCrdtService.applyOperations(
      session,
      documentId,
      fieldUpdates,
      sessionId,
      cmsUserId: cmsUser.id,
    );
  }

  /// Get list of users currently editing this document
  /// Based on recent operation activity (last 5 minutes)
  Future<List<Map<String, dynamic>>> getActiveEditors(
    Session session,
    int documentId,
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
    final userEdits = <int, DateTime>{};
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
    final editors = <Map<String, dynamic>>[];
    userEdits.forEach((userId, lastEdit) {
      editors.add({
        'userId': userId,
        'lastEdit': lastEdit.toIso8601String(),
      });
    });

    // Sort by most recent activity
    editors.sort(
        (a, b) => (b['lastEdit'] as String).compareTo(a['lastEdit'] as String));

    return editors;
  }

  /// Get the current HLC for a document
  /// Useful for clients to know where they are in the operation log
  Future<String?> getCurrentHlc(
    Session session,
    int documentId,
  ) async {
    return await server.documentCrdtService.getCurrentHlc(session, documentId);
  }

  /// Get operation count for a document
  /// Useful for monitoring and deciding when to compact
  Future<int> getOperationCount(
    Session session,
    int documentId,
  ) async {
    return await server.documentCrdtService.getOperationCount(
      session,
      documentId,
    );
  }

  /// Manually trigger operation compaction
  /// Creates a snapshot and cleans up old operations
  Future<void> compactOperations(
    Session session,
    int documentId,
  ) async {
    final user = await DartDeskAuth.authenticateRequest(session);
    if (user == null) {
      throw Exception('User must be authenticated to compact operations');
    }

    await server.documentCrdtService.compactOperations(session, documentId);
  }
}
