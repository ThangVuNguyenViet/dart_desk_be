# Migration CLI — Experimental

**Date:** 2026-04-02
**Status:** Approved
**Scope:** dart_desk_cli + dart_desk_be

## Problem

dart_desk uses schemaless JSON storage with CRDT operations. When a user renames or changes a field in their Dart model class, existing document data becomes orphaned — `fromMap()` silently drops old field values. There is no mechanism to migrate existing data to match the new schema.

## Solution

A CLI-driven migration system (modeled after Sanity's approach) where users write declarative migration files, preview changes with dry-run, and execute against the backend via API.

## Migration File Format

Migration files live in the user's CMS project at `migrations/<timestamp>_<name>.dart`:

```dart
import 'package:dart_desk_cli/migration.dart';

final migration = defineMigration(
  title: 'Rename primaryColor to mainColor',
  documentType: 'AppBranding',
  operations: [
    renameField('primaryColor', 'mainColor'),
  ],
);
```

## V1 Operations

| Operation | Description | Example |
|-----------|-------------|---------|
| `renameField(from, to)` | Rename a field path (supports dot-notation for nested fields) | `renameField('primaryColor', 'mainColor')` |
| `deleteField(path)` | Remove a field from all documents | `deleteField('legacyFlag')` |
| `setField(path, value)` | Set a field to a static value | `setField('version', 2)` |

## CLI Commands

```
dartdesk migration create "Rename primaryColor"   # scaffold migration file
dartdesk migration list                            # show pending/applied status
dartdesk migration run <file> --dry-run            # preview changes against real data
dartdesk migration run <file>                      # execute migration
```

### `migration create <title>`

Generates a timestamped migration file in `migrations/` with boilerplate.

### `migration list`

Queries the backend for applied migrations and cross-references with local migration files. Shows status: pending or applied (with timestamp).

### `migration run <file> [--dry-run]`

1. Reads and parses the migration file locally.
2. Serializes the migration as JSON: `{title, documentType, operations, dryRun}`.
3. POSTs to the backend migration endpoint.
4. Displays the report (documents scanned, modified, skipped).
5. If not dry-run, the backend persists changes and records the migration in history.

## Backend: New Endpoints

### `POST migration/run`

**Request:**
```json
{
  "title": "Rename primaryColor to mainColor",
  "documentType": "AppBranding",
  "operations": [
    {"type": "renameField", "from": "primaryColor", "to": "mainColor"}
  ],
  "dryRun": true
}
```

**Behavior:**
1. Fetch all documents where `documentType` matches.
2. For each document, apply operations to the `data` JSON:
   - `renameField`: copy value from old path to new path, remove old path.
   - `deleteField`: remove the path.
   - `setField`: set the path to the given value.
3. If `dryRun: false`:
   - Insert corresponding CRDT operations (`put` for new values, `delete` for removed paths).
   - Rebuild `Document.data` from CRDT state.
   - Insert a record into `migration_history`.
4. Return a report.

**Response:**
```json
{
  "documentType": "AppBranding",
  "totalDocuments": 3,
  "modified": 2,
  "skipped": 1,
  "dryRun": true,
  "details": [
    {"documentId": 1, "title": "Main Brand Config", "status": "modified", "changes": ["renameField: primaryColor -> mainColor"]},
    {"documentId": 2, "title": "Dark Theme Brand", "status": "modified", "changes": ["renameField: primaryColor -> mainColor"]},
    {"documentId": 3, "title": "Holiday Theme", "status": "skipped", "reason": "field primaryColor not found"}
  ]
}
```

### `GET migration/list`

Returns all applied migrations from the `migration_history` table.

## Backend: New Model

### `migration_history.spy.yaml`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String` | Migration title |
| `documentType` | `String` | Target document type |
| `appliedAt` | `DateTime` | When the migration was executed |
| `operationsJson` | `String` | JSON of the operations applied (for audit) |
| `report` | `String` | JSON of the execution report |

## Migration Execution Details

Operations are applied to the flattened dot-notation representation used by the CRDT system:

- **`renameField('primaryColor', 'mainColor')`**: For each document, find all CRDT operation paths starting with `primaryColor`, insert new `put` operations with the path rewritten to `mainColor`, insert `delete` operations for the old paths, rebuild `Document.data`.
- **`deleteField('legacyFlag')`**: Insert `delete` CRDT operations for all paths starting with `legacyFlag`, rebuild `Document.data`.
- **`setField('version', 2)`**: Insert a `put` CRDT operation for the path `version` with value `2`, rebuild `Document.data`.

This ensures the CRDT history remains consistent and the migration is reflected in the operation log.

## Authentication

Migration endpoints require cloud admin key authentication (same as existing admin endpoints).

## Tests

### Unit Tests
- Each operation (rename, delete, set) applied to sample document maps.
- Nested path handling (e.g., `renameField('metadata.author', 'metadata.writer')`).
- Edge cases: field not found, field already exists at target path, empty documents.

### Integration Tests
- Dry-run returns correct report without modifying data.
- Real run modifies documents and records migration history.
- Double-run prevention (same migration cannot be applied twice).
- Migration list endpoint returns correct pending/applied status.

### CLI Tests
- `create` generates correct file with timestamp.
- `run` serializes and sends migration correctly.
- `list` displays status correctly.

## What's NOT Included

- No revert/rollback — write a new migration to undo changes.
- No local fixture testing — use `--dry-run` or write Dart unit tests.
- No complex transforms (split, merge, type coercion) — future work.
- No automatic schema change detection — migrations are manual.

## Package Changes

### dart_desk_cli
- New `migration` parent command with `create`, `list`, `run` subcommands.
- New `package:dart_desk_cli/migration.dart` library exporting `defineMigration`, `renameField`, `deleteField`, `setField`.

### dart_desk_be
- New `MigrationEndpoint` with `run` and `list` methods.
- New `MigrationService` containing the operation execution logic.
- New `MigrationHistory` model and database table.
