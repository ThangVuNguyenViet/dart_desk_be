import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../auth/dart_desk_session.dart';
import '../generated/protocol.dart';
import '../plugin/dart_desk_session.dart';
import '../services/migration_service.dart';

typedef _AuthResult = ({int? clientId, int? projectId});

/// Endpoint for running and listing data migrations.
/// Both methods require read AND write scopes.
class MigrationEndpoint extends Endpoint {
  final MigrationService _migrationService = MigrationService();

  /// Run a migration against all documents of [documentType].
  ///
  /// [title] is a human-readable description of the migration.
  /// [operationsJson] is a JSON-encoded list of [MigrationOperation] maps.
  /// [dryRun] — when true, applies operations in memory only and returns the
  /// report without persisting anything.
  ///
  /// Returns a JSON-encoded migration report.
  Future<String> runMigration(
    Session session,
    String title,
    String documentType,
    String operationsJson,
    bool dryRun,
  ) async {
    final auth = await _requireAuth(session);
    final projectId = auth.projectId;
    if (projectId == null) {
      throw ApiException(message: 'No project associated with this session', code: 400);
    }

    // Parse operations
    final rawOps = jsonDecode(operationsJson) as List<dynamic>;
    final operations = rawOps
        .map((o) => MigrationOperation.fromJson(o as Map<String, dynamic>))
        .toList();

    // Duplicate check for non-dry-run
    if (!dryRun) {
      final existing = await MigrationHistory.db.findFirstRow(
        session,
        where: (t) => t.name.equals(title) & t.projectId.equals(projectId),
      );
      if (existing != null) {
        throw ApiException(message: 'Migration "$title" has already been applied to project $projectId', code: 409);
      }
    }

    // Fetch all documents for the given type + project
    final documents = await Document.db.find(
      session,
      where: (t) =>
          t.documentType.equals(documentType) &
          t.projectId.equals(projectId) &
          t.deletedAt.equals(null),
    );

    // Apply migration operations to each document
    final results = <DocumentMigrationResult>[];
    for (final doc in documents) {
      Map<String, dynamic> data;
      if (doc.data == null) {
        data = <String, dynamic>{};
      } else {
        data = jsonDecode(doc.data!) as Map<String, dynamic>;
      }
      final result = _migrationService.applyOperations(
        documentId: doc.id!,
        title: doc.title,
        data: data,
        operations: operations,
      );
      results.add(result);

      // Persist if not a dry run and the document was modified
      if (!dryRun && result.status == 'modified' && result.newData != null) {
        await session.crdtService.applyMigrationResult(
          session,
          doc.id!,
          data,
          result.newData!,
          'migration',
        );
      }
    }

    final report = {
      'title': title,
      'documentType': documentType,
      'dryRun': dryRun,
      'totalDocuments': documents.length,
      'modified': results.where((r) => r.status == 'modified').length,
      'skipped': results.where((r) => r.status == 'skipped').length,
      'results': results.map((r) => r.toJson()).toList(),
    };
    final reportJson = jsonEncode(report);

    // Persist history record for non-dry-run
    if (!dryRun) {
      await MigrationHistory.db.insertRow(
        session,
        MigrationHistory(
          projectId: projectId,
          name: title,
          documentType: documentType,
          operationsJson: operationsJson,
          report: reportJson,
        ),
      );
    }

    return reportJson;
  }

  /// Return all [MigrationHistory] records for the current project.
  Future<List<MigrationHistory>> listMigrations(Session session) async {
    final auth = await _requireAuth(session);
    final projectId = auth.projectId;
    if (projectId == null) {
      throw ApiException(message: 'No project associated with this session', code: 400);
    }

    return MigrationHistory.db.find(
      session,
      where: (t) => t.projectId.equals(projectId),
      orderBy: (t) => t.appliedAt,
      orderDescending: true,
    );
  }

  /// Requires both read and write scopes.
  Future<_AuthResult> _requireAuth(Session session) async {
    if (!session.canRead) {
      throw ApiException(message: 'Missing read permission', code: 403);
    }
    if (!session.canWrite) {
      throw ApiException(message: 'Missing write permission', code: 403);
    }
    return (clientId: session.clientId, projectId: session.projectId);
  }
}
