import 'dart:convert';

import 'package:crdt/crdt.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Service for managing CRDT-based document operations
/// Provides conflict-free collaborative editing using Hybrid Logical Clocks
class DocumentCrdtService {
  final String nodeId;

  DocumentCrdtService(this.nodeId);

  /// Initialize CRDT operations for a new document from initial data
  Future<void> initializeCrdt(
    Session session,
    int documentId,
    Map<String, dynamic> initialData, {
    int? cmsUserId,
  }) async {
    final userId = cmsUserId;

    // Generate initial HLC timestamp
    final hlc = Hlc.now(nodeId);
    final hlcString = hlc.toString();

    // Flatten JSON to dot-notation and create operations
    final flatData = _flattenMap(initialData);

    for (var entry in flatData.entries) {
      final operation = DocumentCrdtOperation(
        documentId: documentId,
        hlc: hlcString,
        nodeId: nodeId,
        operationType: CrdtOperationType.put,
        fieldPath: entry.key,
        fieldValue: jsonEncode(entry.value),
        createdAt: DateTime.now(),
        createdByUserId: userId,
      );

      await DocumentCrdtOperation.db.insertRow(session, operation);
    }

    // Update document with CRDT metadata
    final document = await Document.db.findById(session, documentId);
    if (document != null) {
      final updated = document.copyWith(
        crdtNodeId: nodeId,
        crdtHlc: hlcString,
      );
      await Document.db.updateRow(session, updated);
    }
  }

  /// Apply partial updates (only changed fields) and merge with existing state
  Future<Document> applyOperations(
    Session session,
    int documentId,
    Map<String, dynamic> updates,
    String sessionId, {
    int? cmsUserId,
  }) async {
    final userId = cmsUserId;

    // Get current document
    final doc = await Document.db.findById(session, documentId);
    if (doc == null) {
      throw Exception('Document not found: $documentId');
    }

    // Generate new HLC timestamp (incremented from current)
    final currentHlc = doc.crdtHlc != null ? Hlc.parse(doc.crdtHlc!) : null;
    final newHlc =
        currentHlc != null ? currentHlc.increment() : Hlc.now(nodeId);
    final hlcString = newHlc.toString();

    // Create peer ID for attribution
    final peerId = '$nodeId:$sessionId';

    // Flatten updates to dot-notation
    final flatUpdates = _flattenMap(updates);

    // Create CRDT operations for each changed field
    for (var entry in flatUpdates.entries) {
      final operation = DocumentCrdtOperation(
        documentId: documentId,
        hlc: hlcString,
        nodeId: peerId,
        operationType: CrdtOperationType.put,
        fieldPath: entry.key,
        fieldValue: jsonEncode(entry.value),
        createdAt: DateTime.now(),
        createdByUserId: userId,
      );

      await DocumentCrdtOperation.db.insertRow(session, operation);
    }

    // Rebuild current state from all operations
    final currentState = await getCurrentState(session, documentId);

    // Update document's data field with merged state
    final updated = doc.copyWith(
      data: jsonEncode(currentState),
      crdtHlc: hlcString,
      updatedAt: DateTime.now(),
      updatedByUserId: userId,
    );

    await Document.db.updateRow(session, updated);

    // Check if compaction is needed
    final opCount = await getOperationCount(session, documentId);
    if (opCount > 1000) {
      // Schedule compaction asynchronously (could be moved to background job)
      session.log(
          'Document $documentId has $opCount operations, needs compaction');
    }

    return updated;
  }

  /// Get current merged state from all CRDT operations
  Future<Map<String, dynamic>> getCurrentState(
    Session session,
    int documentId,
  ) async {
    // Check for recent snapshot to optimize reconstruction
    final snapshots = await DocumentCrdtSnapshot.db.find(
      session,
      where: (t) => t.documentId.equals(documentId),
      orderBy: (t) => t.snapshotHlc,
      orderDescending: true,
      limit: 1,
    );

    Map<String, dynamic> flatState = {};
    String sinceHlc = '0';

    if (snapshots.isNotEmpty) {
      // Start from snapshot (fast path)
      final snapshotData =
          jsonDecode(snapshots.first.snapshotData) as Map<String, dynamic>;
      flatState = _flattenMap(snapshotData);
      sinceHlc = snapshots.first.snapshotHlc;
    }

    // Get operations since snapshot (or all if no snapshot)
    // Use raw SQL for string comparison since hlc is lexicographically sortable
    final operations = await session.db.unsafeQuery(
      r'SELECT * FROM document_crdt_operations WHERE "documentId" = $1 AND hlc > $2 ORDER BY hlc ASC',
      parameters: QueryParameters.positional([documentId, sinceHlc]),
    );

    final operationsList = <DocumentCrdtOperation>[];
    for (var row in operations) {
      operationsList.add(DocumentCrdtOperation.fromJson(row.toColumnMap()));
    }

    // Apply operations to state (last-write-wins based on HLC)
    for (var op in operationsList) {
      if (op.operationType == CrdtOperationType.put && op.fieldValue != null) {
        _applyPutToFlatState(
            flatState, op.fieldPath, jsonDecode(op.fieldValue!));
      } else if (op.operationType == CrdtOperationType.delete) {
        flatState.remove(op.fieldPath);
        flatState.removeWhere((k, _) => k.startsWith('${op.fieldPath}.'));
      }
    }

    // Unflatten to nested structure
    return _unflattenMap(flatState);
  }

  /// Reconstruct document state at a specific HLC timestamp (for version history)
  Future<Map<String, dynamic>> getStateAtHlc(
    Session session,
    int documentId,
    String targetHlc,
  ) async {
    // Optimization: if targetHlc matches current document HLC, return cached data
    final doc = await Document.db.findById(session, documentId);
    if (doc != null && doc.crdtHlc == targetHlc && doc.data != null) {
      return jsonDecode(doc.data!) as Map<String, dynamic>;
    }

    // Find nearest snapshot BEFORE target HLC using raw SQL
    final snapshotResults = await session.db.unsafeQuery(
      r'SELECT * FROM document_crdt_snapshots WHERE "documentId" = $1 AND "snapshotHlc" <= $2 ORDER BY "snapshotHlc" DESC LIMIT 1',
      parameters: QueryParameters.positional([documentId, targetHlc]),
    );

    Map<String, dynamic> flatState = {};
    String sinceHlc = '0';

    if (snapshotResults.isNotEmpty) {
      final snapshot =
          DocumentCrdtSnapshot.fromJson(snapshotResults.first.toColumnMap());
      final snapshotData =
          jsonDecode(snapshot.snapshotData) as Map<String, dynamic>;
      flatState = _flattenMap(snapshotData);
      sinceHlc = snapshot.snapshotHlc;
    }

    // Replay operations from snapshot to target HLC
    final operations = await session.db.unsafeQuery(
      r'SELECT * FROM document_crdt_operations WHERE "documentId" = $1 AND hlc > $2 AND hlc <= $3 ORDER BY hlc ASC',
      parameters: QueryParameters.positional([documentId, sinceHlc, targetHlc]),
    );

    for (var row in operations) {
      final op = DocumentCrdtOperation.fromJson(row.toColumnMap());
      if (op.operationType == CrdtOperationType.put && op.fieldValue != null) {
        _applyPutToFlatState(
            flatState, op.fieldPath, jsonDecode(op.fieldValue!));
      } else if (op.operationType == CrdtOperationType.delete) {
        flatState.remove(op.fieldPath);
        flatState.removeWhere((k, _) => k.startsWith('${op.fieldPath}.'));
      }
    }

    return _unflattenMap(flatState);
  }

  /// Compact operations into a snapshot when log grows too large
  Future<void> compactOperations(
    Session session,
    int documentId, {
    int threshold = 1000,
  }) async {
    final opCount = await getOperationCount(session, documentId);

    if (opCount > threshold) {
      // Get current state and HLC
      final currentState = await getCurrentState(session, documentId);
      final doc = await Document.db.findById(session, documentId);

      if (doc?.crdtHlc == null) {
        session.log('Cannot compact: document has no CRDT HLC');
        return;
      }

      final currentHlc = doc!.crdtHlc!;

      // Create snapshot
      final snapshot = DocumentCrdtSnapshot(
        documentId: documentId,
        snapshotHlc: currentHlc,
        snapshotData: jsonEncode(currentState),
        operationCountAtSnapshot: opCount,
        createdAt: DateTime.now(),
      );

      await DocumentCrdtSnapshot.db.insertRow(session, snapshot);

      // Delete operations older than this snapshot
      // Keep operations at and after this HLC for safety
      await session.db.unsafeExecute(
        r'DELETE FROM document_crdt_operations WHERE "documentId" = $1 AND hlc < $2',
        parameters: QueryParameters.positional([documentId, currentHlc]),
      );

      session.log('Compacted $opCount operations for document $documentId');
    }
  }

  /// Reconstruct document data from a list of CRDT operations (no database lookup)
  ///
  /// [operations] - List of operations to replay, should be ordered by HLC ascending
  /// [initialState] - Optional starting state (e.g., from a snapshot)
  ///
  /// Returns the reconstructed document as a nested Map
  Map<String, dynamic> reconstructFromOperations(
    List<DocumentCrdtOperation> operations, {
    required Map<String, dynamic> initialState,
  }) {
    // Start from initial state or empty
    Map<String, dynamic> flatState = _flattenMap(initialState);

    // Apply each operation in order (assumes operations are sorted by HLC)
    for (var op in operations) {
      if (op.operationType == CrdtOperationType.put && op.fieldValue != null) {
        _applyPutToFlatState(
            flatState, op.fieldPath, jsonDecode(op.fieldValue!));
      } else if (op.operationType == CrdtOperationType.delete) {
        flatState.remove(op.fieldPath);
        flatState.removeWhere((k, _) => k.startsWith('${op.fieldPath}.'));
      }
    }

    return _unflattenMap(flatState);
  }

  /// Get current HLC timestamp for document
  Future<String?> getCurrentHlc(Session session, int documentId) async {
    final doc = await Document.db.findById(session, documentId);
    return doc?.crdtHlc;
  }

  /// Get total operation count for document
  Future<int> getOperationCount(Session session, int documentId) async {
    final result = await DocumentCrdtOperation.db.count(
      session,
      where: (t) => t.documentId.equals(documentId),
    );
    return result;
  }

  /// Get operations between two HLC timestamps (exclusive fromHlc, inclusive toHlc)
  ///
  /// [fromHlc] - Start HLC (exclusive), null returns empty list (for first version)
  /// [toHlc] - End HLC (inclusive)
  ///
  /// Returns operations where: fromHlc < hlc <= toHlc
  Future<List<DocumentCrdtOperation>> getOperationsBetweenHlc(
    Session session,
    int documentId,
    String? fromHlc,
    String toHlc,
  ) async {
    // First version has no previous operations
    if (fromHlc == null) {
      return [];
    }

    final results = await session.db.unsafeQuery(
      r'SELECT * FROM document_crdt_operations WHERE "documentId" = $1 AND hlc > $2 AND hlc <= $3 ORDER BY hlc ASC',
      parameters: QueryParameters.positional([documentId, fromHlc, toHlc]),
    );

    return results
        .map((row) => DocumentCrdtOperation.fromJson(row.toColumnMap()))
        .toList();
  }

  /// Apply a put operation to flat state with parent/child conflict resolution.
  ///
  /// Invariants:
  /// - Setting K = null removes all K.* sub-keys (null overrides a prior sub-map).
  /// - Setting K.X = val removes any K = null ancestor (sub-key overrides a prior null).
  void _applyPutToFlatState(
    Map<String, dynamic> flatState,
    String fieldPath,
    dynamic value,
  ) {
    if (value == null) {
      // Nulling a field: remove all dot-notation sub-keys for this path.
      flatState.removeWhere((k, _) => k.startsWith('$fieldPath.'));
    } else {
      // Setting a sub-key: remove any ancestor plain-null that would conflict.
      var path = fieldPath;
      while (path.contains('.')) {
        path = path.substring(0, path.lastIndexOf('.'));
        if (flatState.containsKey(path) && flatState[path] == null) {
          flatState.remove(path);
        }
      }
    }
    flatState[fieldPath] = value;
  }

  /// Flatten nested map to dot-notation
  /// Example: {"user": {"name": "John"}} -> {"user.name": "John"}
  Map<String, dynamic> _flattenMap(
    Map<String, dynamic> map, [
    String prefix = '',
  ]) {
    final result = <String, dynamic>{};

    for (var entry in map.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';

      if (entry.value is Map<String, dynamic>) {
        // Recursively flatten nested maps
        result.addAll(_flattenMap(entry.value as Map<String, dynamic>, key));
      } else {
        // Store primitive values and arrays as-is
        result[key] = entry.value;
      }
    }

    return result;
  }

  /// Unflatten dot-notation to nested map
  /// Example: {"user.name": "John"} -> {"user": {"name": "John"}}
  Map<String, dynamic> _unflattenMap(Map<String, dynamic> flat) {
    final result = <String, dynamic>{};

    for (var entry in flat.entries) {
      final keys = entry.key.split('.');
      dynamic current = result;

      for (var i = 0; i < keys.length - 1; i++) {
        if (current is! Map<String, dynamic>) {
          break;
        }
        current[keys[i]] ??= <String, dynamic>{};
        current = current[keys[i]];
      }

      if (current is Map<String, dynamic>) {
        current[keys.last] = entry.value;
      }
    }

    return result;
  }
}
