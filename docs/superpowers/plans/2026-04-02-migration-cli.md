# Migration CLI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a declarative migration system so users can rename, delete, and set fields on existing CMS documents via CLI commands backed by Serverpod endpoints.

**Architecture:** CLI reads migration Dart files from the user's project, serializes operations as JSON, and POSTs to a new `MigrationEndpoint` on the backend. The backend applies operations as CRDT ops (or previews them in dry-run mode) and tracks applied migrations in a `migration_history` table. A `MigrationService` encapsulates the operation logic.

**Tech Stack:** Serverpod 3.4.5, `args` package CLI, `package:http`, CRDT operations via `DocumentCrdtService`

---

## File Map

### Backend (`dart_desk_server/`)

| File | Action | Responsibility |
|------|--------|---------------|
| `lib/src/models/migration_history.spy.yaml` | Create | Model for tracking applied migrations |
| `lib/src/services/migration_service.dart` | Create | Operation execution logic (rename, delete, set) |
| `lib/src/endpoints/migration_endpoint.dart` | Create | `runMigration` and `listMigrations` RPC endpoints |
| `test/integration/migration_endpoint_test.dart` | Create | Integration tests for migration endpoints |

### CLI (`dart_desk_cli/`)

| File | Action | Responsibility |
|------|--------|---------------|
| `lib/src/migration.dart` | Create | `defineMigration`, `renameField`, `deleteField`, `setField` — the user-facing migration DSL |
| `lib/src/commands/migration_command.dart` | Create | Parent command + `create`, `list`, `run` subcommands |
| `bin/dart_desk_cli.dart` | Modify | Register `MigrationCommand` |
| `test/migration_test.dart` | Create | Unit tests for migration DSL serialization |

---

## Task 1: MigrationHistory Model

**Files:**
- Create: `dart_desk_server/lib/src/models/migration_history.spy.yaml`

- [ ] **Step 1: Create the model file**

```yaml
class: MigrationHistory
table: migration_history
fields:
  projectId: int, relation(parent=projects, onDelete=Cascade)
  name: String
  documentType: String
  appliedAt: DateTime, default=now
  operationsJson: String  # JSON of the operations applied (for audit)
  report: String  # JSON of the execution report
indexes:
  migration_history_project_name_idx:
    fields: projectId, name
    unique: true
```

- [ ] **Step 2: Generate code and create migration**

Run from `dart_desk_be/`:
```bash
cd dart_desk_server && serverpod generate && serverpod create-migration --force
```
Expected: Generated protocol files in `lib/src/generated/` and a new migration in `migrations/`.

- [ ] **Step 3: Verify the generated model compiles**

```bash
cd dart_desk_server && dart analyze lib/src/generated/migration_history.dart
```
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add dart_desk_server/lib/src/models/migration_history.spy.yaml dart_desk_server/lib/src/generated/ dart_desk_server/migrations/
git commit -m "feat(migration): add MigrationHistory model and DB migration"
```

---

## Task 2: MigrationService — Unit-Testable Operation Logic

**Files:**
- Create: `dart_desk_server/lib/src/services/migration_service.dart`

- [ ] **Step 1: Create MigrationService with operation application logic**

This service takes a document's `data` (as a `Map<String, dynamic>`) and a list of operations, applies them in-memory, and returns the modified data plus a list of change descriptions. It does NOT touch the database — that's the endpoint's job.

```dart
import 'dart:convert';

/// Represents a single migration operation.
class MigrationOperation {
  final String type; // 'renameField', 'deleteField', 'setField'
  final String? from;
  final String? to;
  final String? path;
  final dynamic value;

  MigrationOperation({
    required this.type,
    this.from,
    this.to,
    this.path,
    this.value,
  });

  factory MigrationOperation.fromJson(Map<String, dynamic> json) {
    return MigrationOperation(
      type: json['type'] as String,
      from: json['from'] as String?,
      to: json['to'] as String?,
      path: json['path'] as String?,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
      if (path != null) 'path': path,
      if (value != null) 'value': value,
    };
  }
}

/// Result of applying operations to a single document.
class DocumentMigrationResult {
  final int documentId;
  final String title;
  final String status; // 'modified' or 'skipped'
  final List<String> changes;
  final String? reason; // reason for skip
  final Map<String, dynamic>? newData; // null if skipped

  DocumentMigrationResult({
    required this.documentId,
    required this.title,
    required this.status,
    this.changes = const [],
    this.reason,
    this.newData,
  });

  Map<String, dynamic> toJson() => {
        'documentId': documentId,
        'title': title,
        'status': status,
        'changes': changes,
        if (reason != null) 'reason': reason,
      };
}

/// Applies migration operations to document data maps.
/// Pure logic — no database access.
class MigrationService {
  /// Apply a list of operations to a document's data.
  /// Returns the result with the new data (or skip reason).
  DocumentMigrationResult applyOperations({
    required int documentId,
    required String title,
    required Map<String, dynamic> data,
    required List<MigrationOperation> operations,
  }) {
    final flatData = _flattenMap(data);
    final changes = <String>[];
    var modified = false;

    for (final op in operations) {
      switch (op.type) {
        case 'renameField':
          final result = _applyRename(flatData, op.from!, op.to!);
          if (result != null) {
            changes.add(result);
            modified = true;
          }
        case 'deleteField':
          final result = _applyDelete(flatData, op.path!);
          if (result != null) {
            changes.add(result);
            modified = true;
          }
        case 'setField':
          final result = _applySet(flatData, op.path!, op.value);
          changes.add(result);
          modified = true;
      }
    }

    if (!modified) {
      return DocumentMigrationResult(
        documentId: documentId,
        title: title,
        status: 'skipped',
        reason: 'no matching fields found',
      );
    }

    return DocumentMigrationResult(
      documentId: documentId,
      title: title,
      status: 'modified',
      changes: changes,
      newData: _unflattenMap(flatData),
    );
  }

  /// Rename: find all keys starting with [from], rewrite prefix to [to].
  String? _applyRename(
      Map<String, dynamic> flat, String from, String to) {
    final keysToRename = flat.keys
        .where((k) => k == from || k.startsWith('$from.'))
        .toList();

    if (keysToRename.isEmpty) return null;

    for (final key in keysToRename) {
      final newKey = to + key.substring(from.length);
      flat[newKey] = flat[key];
      flat.remove(key);
    }
    return 'renameField: $from -> $to';
  }

  /// Delete: remove key and all sub-keys.
  String? _applyDelete(Map<String, dynamic> flat, String path) {
    final keysToDelete = flat.keys
        .where((k) => k == path || k.startsWith('$path.'))
        .toList();

    if (keysToDelete.isEmpty) return null;

    for (final key in keysToDelete) {
      flat.remove(key);
    }
    return 'deleteField: $path';
  }

  /// Set: set a key to a value.
  String _applySet(Map<String, dynamic> flat, String path, dynamic value) {
    flat[path] = value;
    return 'setField: $path = $value';
  }

  Map<String, dynamic> _flattenMap(Map<String, dynamic> map,
      [String prefix = '']) {
    final result = <String, dynamic>{};
    for (var entry in map.entries) {
      final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      if (entry.value is Map<String, dynamic>) {
        result.addAll(_flattenMap(entry.value as Map<String, dynamic>, key));
      } else {
        result[key] = entry.value;
      }
    }
    return result;
  }

  Map<String, dynamic> _unflattenMap(Map<String, dynamic> flat) {
    final result = <String, dynamic>{};
    for (var entry in flat.entries) {
      final keys = entry.key.split('.');
      dynamic current = result;
      for (var i = 0; i < keys.length - 1; i++) {
        if (current is! Map<String, dynamic>) break;
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
```

- [ ] **Step 2: Commit**

```bash
git add dart_desk_server/lib/src/services/migration_service.dart
git commit -m "feat(migration): add MigrationService with rename, delete, set operations"
```

---

## Task 3: MigrationService Unit Tests

**Files:**
- Create: `dart_desk_server/test/unit/migration_service_test.dart`

- [ ] **Step 1: Write unit tests for all three operations and edge cases**

```dart
import 'package:dart_desk_server/src/services/migration_service.dart';
import 'package:test/test.dart';

void main() {
  late MigrationService service;

  setUp(() {
    service = MigrationService();
  });

  group('renameField', () {
    test('renames a top-level field', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {'primaryColor': '#FF0000', 'other': 'value'},
        operations: [
          MigrationOperation(type: 'renameField', from: 'primaryColor', to: 'mainColor'),
        ],
      );

      expect(result.status, 'modified');
      expect(result.newData, {'mainColor': '#FF0000', 'other': 'value'});
      expect(result.changes, ['renameField: primaryColor -> mainColor']);
    });

    test('renames a nested field', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {
          'metadata': {'author': 'Jane', 'version': 3}
        },
        operations: [
          MigrationOperation(type: 'renameField', from: 'metadata.author', to: 'metadata.writer'),
        ],
      );

      expect(result.status, 'modified');
      expect(result.newData, {
        'metadata': {'writer': 'Jane', 'version': 3}
      });
    });

    test('renames a nested object with all sub-keys', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {
          'old': {'a': 1, 'b': 2}
        },
        operations: [
          MigrationOperation(type: 'renameField', from: 'old', to: 'new'),
        ],
      );

      expect(result.status, 'modified');
      expect(result.newData, {
        'new': {'a': 1, 'b': 2}
      });
    });

    test('skips when field not found', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {'other': 'value'},
        operations: [
          MigrationOperation(type: 'renameField', from: 'missing', to: 'new'),
        ],
      );

      expect(result.status, 'skipped');
      expect(result.reason, 'no matching fields found');
    });
  });

  group('deleteField', () {
    test('deletes a top-level field', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {'keep': 'yes', 'remove': 'me'},
        operations: [
          MigrationOperation(type: 'deleteField', path: 'remove'),
        ],
      );

      expect(result.status, 'modified');
      expect(result.newData, {'keep': 'yes'});
    });

    test('deletes a nested field and its sub-keys', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {
          'metadata': {'author': 'Jane', 'version': 3},
          'title': 'Hello',
        },
        operations: [
          MigrationOperation(type: 'deleteField', path: 'metadata'),
        ],
      );

      expect(result.status, 'modified');
      expect(result.newData, {'title': 'Hello'});
    });

    test('skips when field not found', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {'keep': 'yes'},
        operations: [
          MigrationOperation(type: 'deleteField', path: 'missing'),
        ],
      );

      expect(result.status, 'skipped');
    });
  });

  group('setField', () {
    test('sets a new field', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {'existing': 'value'},
        operations: [
          MigrationOperation(type: 'setField', path: 'version', value: 2),
        ],
      );

      expect(result.status, 'modified');
      expect(result.newData, {'existing': 'value', 'version': 2});
    });

    test('overwrites an existing field', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {'version': 1},
        operations: [
          MigrationOperation(type: 'setField', path: 'version', value: 2),
        ],
      );

      expect(result.status, 'modified');
      expect(result.newData, {'version': 2});
    });
  });

  group('multiple operations', () {
    test('applies multiple operations in order', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {'oldName': 'hello', 'legacy': true},
        operations: [
          MigrationOperation(type: 'renameField', from: 'oldName', to: 'newName'),
          MigrationOperation(type: 'deleteField', path: 'legacy'),
          MigrationOperation(type: 'setField', path: 'version', value: 2),
        ],
      );

      expect(result.status, 'modified');
      expect(result.newData, {'newName': 'hello', 'version': 2});
      expect(result.changes, hasLength(3));
    });
  });

  group('empty document', () {
    test('setField works on empty document', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {},
        operations: [
          MigrationOperation(type: 'setField', path: 'version', value: 1),
        ],
      );

      expect(result.status, 'modified');
      expect(result.newData, {'version': 1});
    });

    test('rename on empty document is skipped', () {
      final result = service.applyOperations(
        documentId: 1,
        title: 'Test Doc',
        data: {},
        operations: [
          MigrationOperation(type: 'renameField', from: 'a', to: 'b'),
        ],
      );

      expect(result.status, 'skipped');
    });
  });
}
```

- [ ] **Step 2: Run the tests**

```bash
cd dart_desk_server && dart test test/unit/migration_service_test.dart -v
```
Expected: All tests pass.

- [ ] **Step 3: Commit**

```bash
git add dart_desk_server/test/unit/migration_service_test.dart
git commit -m "test(migration): add unit tests for MigrationService operations"
```

---

## Task 4: MigrationEndpoint

**Files:**
- Create: `dart_desk_server/lib/src/endpoints/migration_endpoint.dart`

- [ ] **Step 1: Create the endpoint**

The endpoint uses the same auth pattern as `DocumentEndpoint` (`_requireAuth` with scope-based auth). It fetches documents by type, applies operations via `MigrationService`, and either previews (dry-run) or persists changes via CRDT operations.

```dart
import 'dart:convert';

import 'package:crdt/crdt.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../plugin/dart_desk_session.dart';
import '../services/migration_service.dart';

class MigrationEndpoint extends Endpoint {
  final MigrationService _migrationService = MigrationService();

  /// Run a migration against all documents of a given type.
  ///
  /// [operationsJson] - JSON array of operations, e.g.
  ///   [{"type":"renameField","from":"old","to":"new"}]
  /// [dryRun] - If true, preview changes without persisting.
  Future<String> runMigration(
    Session session,
    String title,
    String documentType,
    String operationsJson,
    bool dryRun,
  ) async {
    final auth = await _requireAuth(session);
    final projectId = auth.projectId;

    // Parse operations
    final operationsList =
        (jsonDecode(operationsJson) as List).cast<Map<String, dynamic>>();
    final operations =
        operationsList.map((o) => MigrationOperation.fromJson(o)).toList();

    // Check for duplicate migration (only if not dry-run)
    if (!dryRun && projectId != null) {
      final existing = await MigrationHistory.db.findFirstRow(
        session,
        where: (t) =>
            t.projectId.equals(projectId) & t.name.equals(title),
      );
      if (existing != null) {
        throw Exception(
            'Migration "$title" has already been applied to this project');
      }
    }

    // Fetch all documents of this type
    final whereClause = projectId != null
        ? (DocumentTable t) =>
            t.documentType.equals(documentType) &
            t.projectId.equals(projectId)
        : (DocumentTable t) => t.documentType.equals(documentType);

    final documents = await Document.db.find(session, where: whereClause);

    final details = <Map<String, dynamic>>[];
    var modifiedCount = 0;
    var skippedCount = 0;

    for (final doc in documents) {
      final data = doc.data != null
          ? jsonDecode(doc.data!) as Map<String, dynamic>
          : <String, dynamic>{};

      final result = _migrationService.applyOperations(
        documentId: doc.id!,
        title: doc.title,
        data: data,
        operations: operations,
      );

      details.add(result.toJson());

      if (result.status == 'modified') {
        modifiedCount++;

        if (!dryRun && result.newData != null) {
          // Persist via CRDT operations
          await session.crdtService.applyOperations(
            session,
            doc.id!,
            result.newData!,
            'migration',
          );
        }
      } else {
        skippedCount++;
      }
    }

    // Record migration history (only if not dry-run and changes were made)
    if (!dryRun && projectId != null) {
      final report = jsonEncode({
        'documentType': documentType,
        'totalDocuments': documents.length,
        'modified': modifiedCount,
        'skipped': skippedCount,
      });

      await MigrationHistory.db.insertRow(
        session,
        MigrationHistory(
          projectId: projectId,
          name: title,
          documentType: documentType,
          appliedAt: DateTime.now(),
          operationsJson: operationsJson,
          report: report,
        ),
      );
    }

    return jsonEncode({
      'documentType': documentType,
      'totalDocuments': documents.length,
      'modified': modifiedCount,
      'skipped': skippedCount,
      'dryRun': dryRun,
      'details': details,
    });
  }

  /// List all applied migrations for the current project.
  Future<List<MigrationHistory>> listMigrations(Session session) async {
    final auth = await _requireAuth(session);
    final projectId = auth.projectId;

    if (projectId == null) {
      return await MigrationHistory.db.find(
        session,
        orderBy: (t) => t.appliedAt,
        orderDescending: true,
      );
    }

    return await MigrationHistory.db.find(
      session,
      where: (t) => t.projectId.equals(projectId),
      orderBy: (t) => t.appliedAt,
      orderDescending: true,
    );
  }

  Future<({int? clientId, int? projectId})> _requireAuth(
      Session session) async {
    if (!session.canRead) {
      throw Exception('Missing read permission');
    }
    if (!session.canWrite) {
      throw Exception('Missing write permission');
    }
    return (
      clientId: session.clientId,
      projectId: session.projectId,
    );
  }
}
```

- [ ] **Step 2: Run `serverpod generate` to register the endpoint**

```bash
cd dart_desk_server && serverpod generate
```
Expected: `MigrationEndpoint` appears in generated protocol.

- [ ] **Step 3: Verify it compiles**

```bash
cd dart_desk_server && dart analyze lib/src/endpoints/migration_endpoint.dart
```
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add dart_desk_server/lib/src/endpoints/migration_endpoint.dart dart_desk_server/lib/src/generated/
git commit -m "feat(migration): add MigrationEndpoint with runMigration and listMigrations"
```

---

## Task 5: MigrationEndpoint Integration Tests

**Files:**
- Create: `dart_desk_server/test/integration/migration_endpoint_test.dart`

- [ ] **Step 1: Write integration tests**

```dart
import 'dart:convert';

import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'helpers/test_data_factory.dart';
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('MigrationEndpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestProject();
      await factory.ensureTestUser(role: 'admin');
    });

    group('runMigration', () {
      test('dry-run returns report without modifying data', () async {
        final doc = await factory.createTestDocument(
          documentType: 'AppBranding',
          title: 'Brand Config',
          data: {'primaryColor': '#FF0000', 'other': 'value'},
        );

        final authed = factory.authenticatedSession();
        final report = await endpoints.migration.runMigration(
          authed,
          'Rename primaryColor',
          'AppBranding',
          jsonEncode([
            {'type': 'renameField', 'from': 'primaryColor', 'to': 'mainColor'}
          ]),
          true, // dryRun
        );

        final parsed = jsonDecode(report) as Map<String, dynamic>;
        expect(parsed['dryRun'], true);
        expect(parsed['modified'], 1);

        // Verify data was NOT changed
        final unchanged = await endpoints.document.getDocument(
          authed,
          doc.id!,
        );
        final data = jsonDecode(unchanged.data!) as Map<String, dynamic>;
        expect(data['primaryColor'], '#FF0000');
        expect(data.containsKey('mainColor'), false);
      });

      test('real run modifies documents and records history', () async {
        await factory.createTestDocument(
          documentType: 'AppBranding',
          title: 'Brand Config',
          data: {'primaryColor': '#FF0000', 'other': 'value'},
        );

        final authed = factory.authenticatedSession();
        final report = await endpoints.migration.runMigration(
          authed,
          'Rename primaryColor',
          'AppBranding',
          jsonEncode([
            {'type': 'renameField', 'from': 'primaryColor', 'to': 'mainColor'}
          ]),
          false, // not dryRun
        );

        final parsed = jsonDecode(report) as Map<String, dynamic>;
        expect(parsed['dryRun'], false);
        expect(parsed['modified'], 1);

        // Verify migration was recorded
        final history = await endpoints.migration.listMigrations(authed);
        expect(history, hasLength(1));
        expect(history.first.name, 'Rename primaryColor');
      });

      test('prevents duplicate migration', () async {
        await factory.createTestDocument(
          documentType: 'AppBranding',
          title: 'Brand Config',
          data: {'primaryColor': '#FF0000'},
        );

        final authed = factory.authenticatedSession();
        final ops = jsonEncode([
          {'type': 'renameField', 'from': 'primaryColor', 'to': 'mainColor'}
        ]);

        // First run succeeds
        await endpoints.migration.runMigration(
          authed, 'Rename primaryColor', 'AppBranding', ops, false,
        );

        // Second run throws
        expect(
          () => endpoints.migration.runMigration(
            authed, 'Rename primaryColor', 'AppBranding', ops, false,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('skips documents without matching fields', () async {
        await factory.createTestDocument(
          documentType: 'AppBranding',
          title: 'Has Field',
          data: {'primaryColor': '#FF0000'},
        );
        await factory.createTestDocument(
          documentType: 'AppBranding',
          title: 'No Field',
          data: {'other': 'value'},
          slug: 'no-field',
        );

        final authed = factory.authenticatedSession();
        final report = await endpoints.migration.runMigration(
          authed,
          'Rename primaryColor',
          'AppBranding',
          jsonEncode([
            {'type': 'renameField', 'from': 'primaryColor', 'to': 'mainColor'}
          ]),
          true,
        );

        final parsed = jsonDecode(report) as Map<String, dynamic>;
        expect(parsed['modified'], 1);
        expect(parsed['skipped'], 1);
      });

      test('deleteField removes field from documents', () async {
        await factory.createTestDocument(
          documentType: 'AppBranding',
          title: 'Brand Config',
          data: {'primaryColor': '#FF0000', 'legacy': true},
        );

        final authed = factory.authenticatedSession();
        final report = await endpoints.migration.runMigration(
          authed,
          'Remove legacy flag',
          'AppBranding',
          jsonEncode([
            {'type': 'deleteField', 'path': 'legacy'}
          ]),
          false,
        );

        final parsed = jsonDecode(report) as Map<String, dynamic>;
        expect(parsed['modified'], 1);
      });

      test('setField adds a new field to documents', () async {
        await factory.createTestDocument(
          documentType: 'AppBranding',
          title: 'Brand Config',
          data: {'primaryColor': '#FF0000'},
        );

        final authed = factory.authenticatedSession();
        final report = await endpoints.migration.runMigration(
          authed,
          'Add version field',
          'AppBranding',
          jsonEncode([
            {'type': 'setField', 'path': 'version', 'value': 2}
          ]),
          false,
        );

        final parsed = jsonDecode(report) as Map<String, dynamic>;
        expect(parsed['modified'], 1);
      });
    });

    group('listMigrations', () {
      test('returns empty list when no migrations applied', () async {
        final authed = factory.authenticatedSession();
        final result = await endpoints.migration.listMigrations(authed);
        expect(result, isEmpty);
      });

      test('returns applied migrations', () async {
        await factory.createTestDocument(
          documentType: 'AppBranding',
          title: 'Brand Config',
          data: {'old': 'value'},
        );

        final authed = factory.authenticatedSession();
        await endpoints.migration.runMigration(
          authed,
          'Test migration',
          'AppBranding',
          jsonEncode([
            {'type': 'setField', 'path': 'new', 'value': 'value'}
          ]),
          false,
        );

        final result = await endpoints.migration.listMigrations(authed);
        expect(result, hasLength(1));
        expect(result.first.name, 'Test migration');
        expect(result.first.documentType, 'AppBranding');
      });
    });
  });
}
```

- [ ] **Step 2: Run the integration tests**

```bash
cd dart_desk_server && dart test test/integration/migration_endpoint_test.dart -v
```
Expected: All tests pass.

- [ ] **Step 3: Commit**

```bash
git add dart_desk_server/test/integration/migration_endpoint_test.dart
git commit -m "test(migration): add integration tests for MigrationEndpoint"
```

---

## Task 6: CLI Migration DSL (`dart_desk_cli/lib/src/migration.dart`)

**Files:**
- Create: `../dart_desk_cli/lib/src/migration.dart`

- [ ] **Step 1: Create the migration DSL library**

This file defines the user-facing API for writing migration files. It's a simple data structure — no execution logic.

```dart
import 'dart:convert';

/// Defines a migration with a title, target document type, and operations.
class Migration {
  final String title;
  final String documentType;
  final List<MigrationOp> operations;

  Migration({
    required this.title,
    required this.documentType,
    required this.operations,
  });

  /// Serialize operations to JSON string for sending to the backend.
  String operationsToJson() {
    return jsonEncode(operations.map((op) => op.toJson()).toList());
  }
}

/// A single migration operation.
sealed class MigrationOp {
  Map<String, dynamic> toJson();
}

class _RenameField extends MigrationOp {
  final String from;
  final String to;
  _RenameField(this.from, this.to);

  @override
  Map<String, dynamic> toJson() => {'type': 'renameField', 'from': from, 'to': to};
}

class _DeleteField extends MigrationOp {
  final String path;
  _DeleteField(this.path);

  @override
  Map<String, dynamic> toJson() => {'type': 'deleteField', 'path': path};
}

class _SetField extends MigrationOp {
  final String path;
  final dynamic value;
  _SetField(this.path, this.value);

  @override
  Map<String, dynamic> toJson() => {'type': 'setField', 'path': path, 'value': value};
}

/// Create a migration definition.
Migration defineMigration({
  required String title,
  required String documentType,
  required List<MigrationOp> operations,
}) {
  return Migration(
    title: title,
    documentType: documentType,
    operations: operations,
  );
}

/// Rename a field (supports dot-notation for nested paths).
MigrationOp renameField(String from, String to) => _RenameField(from, to);

/// Delete a field and all its sub-keys.
MigrationOp deleteField(String path) => _DeleteField(path);

/// Set a field to a static value.
MigrationOp setField(String path, dynamic value) => _SetField(path, value);
```

- [ ] **Step 2: Export from package**

Add to `../dart_desk_cli/lib/dart_desk_cli.dart`:

```dart
export 'src/migration.dart';
```

- [ ] **Step 3: Commit**

```bash
cd ../dart_desk_cli && git add lib/src/migration.dart lib/dart_desk_cli.dart
git commit -m "feat(migration): add migration DSL library (defineMigration, renameField, deleteField, setField)"
```

---

## Task 7: CLI Migration DSL Unit Tests

**Files:**
- Create: `../dart_desk_cli/test/migration_test.dart`

- [ ] **Step 1: Write unit tests for serialization**

```dart
import 'dart:convert';

import 'package:dart_desk_cli/src/migration.dart';
import 'package:test/test.dart';

void main() {
  group('Migration DSL', () {
    test('renameField serializes correctly', () {
      final op = renameField('primaryColor', 'mainColor');
      expect(op.toJson(), {
        'type': 'renameField',
        'from': 'primaryColor',
        'to': 'mainColor',
      });
    });

    test('deleteField serializes correctly', () {
      final op = deleteField('legacyFlag');
      expect(op.toJson(), {
        'type': 'deleteField',
        'path': 'legacyFlag',
      });
    });

    test('setField serializes correctly', () {
      final op = setField('version', 2);
      expect(op.toJson(), {
        'type': 'setField',
        'path': 'version',
        'value': 2,
      });
    });

    test('defineMigration creates Migration with correct fields', () {
      final migration = defineMigration(
        title: 'Test migration',
        documentType: 'AppBranding',
        operations: [
          renameField('old', 'new'),
          deleteField('remove'),
          setField('added', true),
        ],
      );

      expect(migration.title, 'Test migration');
      expect(migration.documentType, 'AppBranding');
      expect(migration.operations, hasLength(3));
    });

    test('operationsToJson produces valid JSON array', () {
      final migration = defineMigration(
        title: 'Test',
        documentType: 'Test',
        operations: [
          renameField('a', 'b'),
          setField('c', 42),
        ],
      );

      final json = jsonDecode(migration.operationsToJson()) as List;
      expect(json, hasLength(2));
      expect(json[0]['type'], 'renameField');
      expect(json[1]['type'], 'setField');
    });
  });
}
```

- [ ] **Step 2: Run the tests**

```bash
cd ../dart_desk_cli && dart test test/migration_test.dart -v
```
Expected: All tests pass.

- [ ] **Step 3: Commit**

```bash
git add test/migration_test.dart
git commit -m "test(migration): add unit tests for migration DSL serialization"
```

---

## Task 8: CLI Migration Commands

**Files:**
- Create: `../dart_desk_cli/lib/src/commands/migration_command.dart`
- Modify: `../dart_desk_cli/bin/dart_desk_cli.dart`

- [ ] **Step 1: Create the migration command with subcommands**

```dart
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import '../config.dart';
import '../credentials.dart';
import '../migration.dart';

class MigrationCommand extends Command {
  @override
  final name = 'migration';
  @override
  final description = 'Manage data migrations';

  MigrationCommand() {
    addSubcommand(_CreateSubcommand());
    addSubcommand(_ListSubcommand());
    addSubcommand(_RunSubcommand());
  }
}

class _CreateSubcommand extends Command {
  @override
  final name = 'create';
  @override
  final description = 'Create a new migration file';

  @override
  String get invocation => '${runner!.executableName} migration create <title>';

  @override
  Future<void> run() async {
    final args = argResults!.rest;
    if (args.isEmpty) {
      usageException('Please provide a migration title.');
    }

    final title = args.join(' ');
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');

    final timestamp =
        DateTime.now().toIso8601String().substring(0, 10).replaceAll('-', '');
    final fileName = '${timestamp}_$slug.dart';

    final migrationsDir = Directory('migrations');
    if (!migrationsDir.existsSync()) {
      migrationsDir.createSync();
    }

    final file = File(p.join('migrations', fileName));
    file.writeAsStringSync('''import 'package:dart_desk_cli/migration.dart';

final migration = defineMigration(
  title: '$title',
  documentType: 'TODO: set document type',
  operations: [
    // renameField('oldName', 'newName'),
    // deleteField('fieldToRemove'),
    // setField('fieldName', 'value'),
  ],
);
''');

    stdout.writeln('Created migration: migrations/$fileName');
  }
}

class _ListSubcommand extends Command {
  @override
  final name = 'list';
  @override
  final description = 'List migrations and their status';

  _ListSubcommand() {
    argParser.addOption('token', abbr: 't', help: 'Auth token');
  }

  @override
  Future<void> run() async {
    final config = CmsConfig.load();
    final token = _resolveToken(argResults!);

    // Get applied migrations from backend
    final response = await http.get(
      Uri.parse('${config.server}/migration/listMigrations'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final applied = <String>{};
    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      for (final item in list) {
        applied.add(item['name'] as String);
      }
    }

    // List local migration files
    final migrationsDir = Directory('migrations');
    if (!migrationsDir.existsSync()) {
      stdout.writeln('No migrations directory found.');
      return;
    }

    final files = migrationsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    if (files.isEmpty) {
      stdout.writeln('No migration files found.');
      return;
    }

    for (final file in files) {
      final name = p.basenameWithoutExtension(file.path);
      // Try to extract title from file content
      final content = file.readAsStringSync();
      final titleMatch = RegExp(r"title:\s*'([^']*)'").firstMatch(content);
      final title = titleMatch?.group(1) ?? name;
      final status = applied.contains(title) ? '✓ applied' : '○ pending';
      stdout.writeln('  $status  ${p.basename(file.path)}  ($title)');
    }
  }
}

class _RunSubcommand extends Command {
  @override
  final name = 'run';
  @override
  final description = 'Run a migration';

  @override
  String get invocation =>
      '${runner!.executableName} migration run <file> [--dry-run]';

  _RunSubcommand() {
    argParser.addFlag('dry-run',
        help: 'Preview changes without applying them', defaultsTo: false);
    argParser.addOption('token', abbr: 't', help: 'Auth token');
  }

  @override
  Future<void> run() async {
    final args = argResults!.rest;
    if (args.isEmpty) {
      usageException('Please provide a migration file path.');
    }

    final filePath = args.first;
    final dryRun = argResults!['dry-run'] as bool;
    final config = CmsConfig.load();
    final token = _resolveToken(argResults!);

    // Parse migration file by running it as a Dart script
    // For v1, we extract title, documentType, and operations via regex
    final file = File(filePath);
    if (!file.existsSync()) {
      stderr.writeln('Migration file not found: $filePath');
      exit(1);
    }

    final content = file.readAsStringSync();
    final migration = _parseMigrationFile(content);
    if (migration == null) {
      stderr.writeln('Failed to parse migration file: $filePath');
      exit(1);
    }

    stdout.writeln(dryRun ? 'Dry run — no changes will be saved.' : 'Running migration...');
    stdout.writeln('Title: ${migration.title}');
    stdout.writeln('Document type: ${migration.documentType}');
    stdout.writeln('');

    // Send to backend
    final response = await http.post(
      Uri.parse('${config.server}/migration/runMigration'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': migration.title,
        'documentType': migration.documentType,
        'operationsJson': migration.operationsToJson(),
        'dryRun': dryRun,
      }),
    );

    if (response.statusCode != 200) {
      stderr.writeln('Migration failed: ${response.body}');
      exit(1);
    }

    final report = jsonDecode(response.body) as Map<String, dynamic>;
    final details = report['details'] as List? ?? [];

    for (final detail in details) {
      final d = detail as Map<String, dynamic>;
      final icon = d['status'] == 'modified' ? '✓' : '—';
      final suffix = d['status'] == 'skipped'
          ? ' (${d['reason']})'
          : ' ${(d['changes'] as List).join(', ')}';
      stdout.writeln('  $icon #${d['documentId']} "${d['title']}"$suffix');
    }

    stdout.writeln('');
    stdout.writeln(
        '${report['totalDocuments']} documents scanned, '
        '${report['modified']} modified, '
        '${report['skipped']} skipped.');
  }

  /// Parse a migration Dart file using regex extraction.
  /// This avoids needing to run the Dart file as a script.
  Migration? _parseMigrationFile(String content) {
    final titleMatch = RegExp(r"title:\s*'([^']*)'").firstMatch(content);
    final docTypeMatch =
        RegExp(r"documentType:\s*'([^']*)'").firstMatch(content);

    if (titleMatch == null || docTypeMatch == null) return null;

    final title = titleMatch.group(1)!;
    final documentType = docTypeMatch.group(1)!;

    final operations = <MigrationOp>[];

    // Parse renameField('from', 'to')
    for (final match in RegExp(r"renameField\(\s*'([^']*)'\s*,\s*'([^']*)'\s*\)")
        .allMatches(content)) {
      operations.add(renameField(match.group(1)!, match.group(2)!));
    }

    // Parse deleteField('path')
    for (final match in RegExp(r"deleteField\(\s*'([^']*)'\s*\)")
        .allMatches(content)) {
      operations.add(deleteField(match.group(1)!));
    }

    // Parse setField('path', value)
    for (final match in RegExp(r"setField\(\s*'([^']*)'\s*,\s*(.+?)\s*\)")
        .allMatches(content)) {
      final path = match.group(1)!;
      final valueStr = match.group(2)!.trim();
      dynamic value;
      if (valueStr == 'true') {
        value = true;
      } else if (valueStr == 'false') {
        value = false;
      } else if (valueStr == 'null') {
        value = null;
      } else if (int.tryParse(valueStr) != null) {
        value = int.parse(valueStr);
      } else if (double.tryParse(valueStr) != null) {
        value = double.parse(valueStr);
      } else {
        // Strip quotes from string values
        value = valueStr.replaceAll(RegExp(r"^'|'$"), '');
      }
      operations.add(setField(path, value));
    }

    return defineMigration(
      title: title,
      documentType: documentType,
      operations: operations,
    );
  }
}

String _resolveToken(dynamic argResults) {
  final token = argResults['token'] as String?;
  if (token != null) return token;

  final creds = Credentials.load();
  if (creds == null || creds.isExpired) {
    stderr.writeln('Not logged in. Run `dartdesk login` first or pass --token.');
    exit(1);
  }
  return creds.token;
}
```

- [ ] **Step 2: Register the command in the CLI entry point**

In `../dart_desk_cli/bin/dart_desk_cli.dart`, add:

```dart
import 'package:dart_desk_cli/src/commands/migration_command.dart';
```

And add `..addCommand(MigrationCommand())` to the `CommandRunner` chain.

- [ ] **Step 3: Verify it compiles**

```bash
cd ../dart_desk_cli && dart analyze lib/src/commands/migration_command.dart
```
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add lib/src/commands/migration_command.dart bin/dart_desk_cli.dart
git commit -m "feat(migration): add CLI migration commands (create, list, run)"
```

---

## Task 9: End-to-End Verification

- [ ] **Step 1: Run all backend tests**

```bash
cd dart_desk_server && dart test -v
```
Expected: All existing tests still pass, plus new migration tests.

- [ ] **Step 2: Run all CLI tests**

```bash
cd ../dart_desk_cli && dart test -v
```
Expected: All tests pass.

- [ ] **Step 3: Manual smoke test of `migration create`**

```bash
cd ../dart_desk_cli && dart run bin/dart_desk_cli.dart migration create "Rename primaryColor to mainColor"
```
Expected: Creates `migrations/20260402_rename_primarycolor_to_maincolor.dart` with boilerplate.

- [ ] **Step 4: Commit any remaining changes**

```bash
git add -A && git commit -m "chore(migration): end-to-end verification complete"
```
