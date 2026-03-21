# Unit & Stress Testing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add unit tests, a CRDT stress test, and a two-tier CI pipeline to dart_desk_be and dart_desk_cloud.

**Architecture:** Pure unit tests (no Docker) for isolated logic via `reconstructFromOperations` and `transformUrl`. Integration tests with `withServerpod()` for DB-dependent code (MetadataExtractor, CRDT stress). Two-tier CI: unit tests on every push, integration tests on PRs to main/master.

**Tech Stack:** Dart `test` package, `mocktail`, `serverpod_test`, GitHub Actions

**Spec:** `docs/superpowers/specs/2026-03-21-unit-and-stress-testing-design.md`

---

## File Structure

### New Files
- `dart_desk_be_server/test/unit/services/document_crdt_service_test.dart` — Pure unit tests for CRDT reconstruction logic
- `dart_desk_be_server/test/integration/services/metadata_extractor_test.dart` — Integration tests for metadata extraction (uses withServerpod)
- `dart_desk_be_server/test/integration/crdt_stress_test.dart` — Stress test: 200 fields, 2000 ops, compaction
- `dart_desk_cloud/test/unit/services/aws_image_storage_provider_test.dart` — Unit tests for Thumbor URL generation
- `.github/workflows/ci.yml` — Two-tier CI pipeline

### Modified Files
- `dart_desk_be_server/pubspec.yaml` — Bump serverpod to 3.4.4, add mocktail
- `dart_desk_be_server/dart_test.yaml` — Add `stress` tag
- `dart_desk_cloud/pubspec.yaml` — Bump serverpod to 3.4.4, add test + mocktail
- `run_integration_tests.sh` — Exclude stress tag from default run

---

## Task 1: Bump Serverpod Dependencies

**Files:**
- Modify: `dart_desk_be_server/pubspec.yaml`
- Modify: `dart_desk_cloud/pubspec.yaml`

- [ ] **Step 1: Update dart_desk_be_server/pubspec.yaml**

Change these version pins:
```yaml
# dependencies:
serverpod: 3.4.4                    # was 3.4.3
serverpod_auth_idp_server: 3.4.4    # was 3.4.3

# dev_dependencies:
serverpod_test: 3.4.4               # was 3.4.3
mocktail: ^1.0.4                    # NEW
```

- [ ] **Step 2: Update dart_desk_cloud/pubspec.yaml**

Change these version pins and add dev_dependencies:
```yaml
# dependencies:
serverpod: 3.4.4                           # was ^2.3.1
serverpod_cloud_storage_s3: 3.4.4          # was ^2.3.1

# NEW section:
dev_dependencies:
  test: ^1.31.0
  mocktail: ^1.0.4
```

- [ ] **Step 3: Run pub get in both packages**

```bash
cd dart_desk_be_server && dart pub get
cd ../dart_desk_cloud && dart pub get  # Note: dart_desk_cloud is at ../dart_desk_cloud relative to workspace root
```

Verify no resolution errors. If there are errors related to the `dependency_overrides` for `serverpod_serialization` in dart_desk_be_server, the override may need to be updated or removed if the fix was merged into 3.4.4.

- [ ] **Step 4: Run existing tests to verify no regressions**

```bash
cd dart_desk_be_server && dart test test/unit/
```

Expected: existing `subdomain_extraction_test.dart` passes.

- [ ] **Step 5: Commit**

```bash
git add dart_desk_be_server/pubspec.yaml dart_desk_be_server/pubspec.lock dart_desk_cloud/pubspec.yaml dart_desk_cloud/pubspec.lock
git commit -m "chore: bump serverpod to 3.4.4 and add test dependencies"
```

---

## Task 2: CRDT Unit Tests (document_crdt_service_test.dart)

**Files:**
- Create: `dart_desk_be_server/test/unit/services/document_crdt_service_test.dart`

**Context:** `DocumentCrdtService.reconstructFromOperations` (line 271 of `lib/src/services/document_crdt_service.dart`) is a pure method. It takes a `List<DocumentCrdtOperation>` and an `initialState` map, applies operations in order (put sets a value, delete removes it), and returns a nested map. Internally it flattens the initial state to dot-notation (e.g., `{"user": {"name": "John"}}` → `{"user.name": "John"}`), applies operations, then unflattens back. Test data must use dot-notation field paths.

- [ ] **Step 1: Create test file with helper and first test**

Create `dart_desk_be_server/test/unit/services/document_crdt_service_test.dart`:

```dart
import 'dart:convert';
import 'package:test/test.dart';
import 'package:dart_desk_be_server/src/generated/protocol.dart';
import 'package:dart_desk_be_server/src/services/document_crdt_service.dart';

/// Helper to build a DocumentCrdtOperation for testing.
DocumentCrdtOperation putOp(String fieldPath, dynamic value, {String hlc = '2026-01-01T00:00:00.000Z-0000-test'}) {
  return DocumentCrdtOperation(
    documentId: 1,
    hlc: hlc,
    nodeId: 'test-node',
    operationType: CrdtOperationType.put,
    fieldPath: fieldPath,
    fieldValue: jsonEncode(value),
  );
}

DocumentCrdtOperation deleteOp(String fieldPath, {String hlc = '2026-01-01T00:00:00.000Z-0000-test'}) {
  return DocumentCrdtOperation(
    documentId: 1,
    hlc: hlc,
    nodeId: 'test-node',
    operationType: CrdtOperationType.delete,
    fieldPath: fieldPath,
  );
}

void main() {
  late DocumentCrdtService service;

  setUp(() {
    service = DocumentCrdtService('test-node');
  });

  group('reconstructFromOperations', () {
    test('empty state with no operations returns empty map', () {
      final result = service.reconstructFromOperations(
        [],
        initialState: {},
      );
      expect(result, equals({}));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it passes**

```bash
cd dart_desk_be_server && dart test test/unit/services/document_crdt_service_test.dart -v
```

Expected: PASS (1 test)

- [ ] **Step 3: Add flatten/unflatten round-trip test**

Add inside the `reconstructFromOperations` group:

```dart
    test('round-trip: operations reconstruct nested map', () {
      final ops = [
        putOp('user.name', 'John'),
        putOp('user.email', 'john@example.com'),
        putOp('title', 'Hello'),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: {},
      );

      expect(result, equals({
        'user': {'name': 'John', 'email': 'john@example.com'},
        'title': 'Hello',
      }));
    });
```

- [ ] **Step 4: Run tests**

```bash
cd dart_desk_be_server && dart test test/unit/services/document_crdt_service_test.dart -v
```

Expected: PASS (2 tests)

- [ ] **Step 5: Add deeply nested structures test**

```dart
    test('deeply nested structures (3-4 levels) reconstruct correctly', () {
      final ops = [
        putOp('page.sections.hero.title', 'Welcome'),
        putOp('page.sections.hero.subtitle', 'Start here'),
        putOp('page.sections.content.blocks.text', 'Hello world'),
        putOp('page.metadata.seo.description', 'A test page'),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: {},
      );

      expect(result['page']['sections']['hero']['title'], equals('Welcome'));
      expect(result['page']['sections']['content']['blocks']['text'], equals('Hello world'));
      expect(result['page']['metadata']['seo']['description'], equals('A test page'));
    });
```

- [ ] **Step 6: Add mixed types test**

```dart
    test('mixed types preserved through JSON encode/decode', () {
      final ops = [
        putOp('str', 'hello'),
        putOp('num_int', 42),
        putOp('num_double', 3.14),
        putOp('flag', true),
        putOp('items', ['a', 'b', 'c']),
        putOp('nullable', null),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: {},
      );

      expect(result['str'], equals('hello'));
      expect(result['num_int'], equals(42));
      expect(result['num_double'], equals(3.14));
      expect(result['flag'], isTrue);
      expect(result['items'], equals(['a', 'b', 'c']));
      expect(result['nullable'], isNull);
    });
```

- [ ] **Step 7: Add overwrite (last-write-wins) test**

```dart
    test('multiple puts to same field path: last value wins', () {
      final ops = [
        putOp('name', 'Alice', hlc: '2026-01-01T00:00:01.000Z-0000-test'),
        putOp('name', 'Bob', hlc: '2026-01-01T00:00:02.000Z-0000-test'),
        putOp('name', 'Charlie', hlc: '2026-01-01T00:00:03.000Z-0000-test'),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: {},
      );

      expect(result['name'], equals('Charlie'));
    });
```

- [ ] **Step 8: Add delete operations test**

```dart
    test('delete operations remove fields without affecting siblings', () {
      final ops = [
        putOp('user.name', 'John'),
        putOp('user.email', 'john@test.com'),
        putOp('title', 'Hello'),
        deleteOp('user.email'),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: {},
      );

      expect(result['user'], equals({'name': 'John'}));
      expect(result['title'], equals('Hello'));
    });
```

- [ ] **Step 9: Add initial state test**

```dart
    test('operations merge with initial state', () {
      final initialState = {
        'existing': 'value',
        'nested': {'keep': 'this'},
      };

      final ops = [
        putOp('new_field', 'added'),
        putOp('nested.extra', 'appended'),
      ];

      final result = service.reconstructFromOperations(
        ops,
        initialState: initialState,
      );

      expect(result['existing'], equals('value'));
      expect(result['new_field'], equals('added'));
      expect(result['nested']['keep'], equals('this'));
      expect(result['nested']['extra'], equals('appended'));
    });
```

- [ ] **Step 10: Run all tests**

```bash
cd dart_desk_be_server && dart test test/unit/services/document_crdt_service_test.dart -v
```

Expected: PASS (7 tests)

- [ ] **Step 11: Commit**

```bash
git add dart_desk_be_server/test/unit/services/document_crdt_service_test.dart
git commit -m "test: add unit tests for DocumentCrdtService.reconstructFromOperations"
```

---

## Task 3: MetadataExtractor Integration Tests

**Files:**
- Create: `dart_desk_be_server/test/integration/services/metadata_extractor_test.dart`

**Context:** `MetadataExtractor.extractAndUpdate` is a static method that: (1) retrieves file bytes from `session.storage`, (2) decodes the image, (3) generates LQIP thumbnail, (4) extracts palette + EXIF data, (5) updates the `MediaAsset` DB row. It calls `MediaAsset.db.updateRow()` directly, so it needs a real Serverpod session via `withServerpod()`. Placed under `test/integration/services/` so it only runs in Tier 2 CI (with Docker).

The test uses the existing `TestDataFactory.uploadTestImage()` to create a MediaAsset with a real PNG stored in test storage, then calls `extractAndUpdate` and verifies the fields were populated.

- [ ] **Step 1: Create directory and test file**

```bash
mkdir -p dart_desk_be_server/test/integration/services
```

Create `dart_desk_be_server/test/integration/services/metadata_extractor_test.dart`:

```dart
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:dart_desk_be_server/src/generated/protocol.dart';
import 'package:dart_desk_be_server/src/services/metadata_extractor.dart';
import '../test_tools/serverpod_test_tools.dart';
import '../helpers/test_data_factory.dart';

void main() {
  withServerpod('MetadataExtractor', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    group('extractAndUpdate', () {
      test('valid image: populates LQIP, palette, and sets status complete',
          () async {
        // Upload a real 1x1 PNG via the media endpoint
        final asset = await factory.uploadTestImage();
        final session = sessionBuilder.build();

        // Run extraction
        await MetadataExtractor.extractAndUpdate(session, asset);

        // Re-fetch the asset to see updated fields
        final updated = await MediaAsset.db.findById(session, asset.id!);

        expect(updated, isNotNull);
        expect(updated!.metadataStatus, equals(MediaAssetMetadataStatus.complete));
        expect(updated.lqip, startsWith('data:image/jpeg;base64,'));
        expect(updated.paletteJson, isNotNull);
      });

      test('no EXIF: GPS fields null, status still complete', () async {
        // The 1x1 test PNG has no EXIF data
        final asset = await factory.uploadTestImage();
        final session = sessionBuilder.build();

        await MetadataExtractor.extractAndUpdate(session, asset);

        final updated = await MediaAsset.db.findById(session, asset.id!);

        expect(updated, isNotNull);
        expect(updated!.metadataStatus, equals(MediaAssetMetadataStatus.complete));
        expect(updated.exifJson, isNull);
        expect(updated.locationLat, isNull);
        expect(updated.locationLng, isNull);
      });

      test('missing file: sets status to failed', () async {
        final session = sessionBuilder.build();

        // Create a MediaAsset with a non-existent storage path
        final asset = await MediaAsset.db.insertRow(
          session,
          MediaAsset(
            tenantId: null,
            fileName: 'ghost.png',
            assetId: 'nonexistent-id',
            storagePath: 'media/nonexistent/ghost.png',
            publicUrl: 'http://localhost/media/nonexistent/ghost.png',
            mimeType: 'image/png',
            fileSize: 0,
            metadataStatus: MediaAssetMetadataStatus.pending,
          ),
        );

        await MetadataExtractor.extractAndUpdate(session, asset);

        final updated = await MediaAsset.db.findById(session, asset.id!);
        expect(updated!.metadataStatus, equals(MediaAssetMetadataStatus.failed));
      });

      test('corrupt image: sets status to failed', () async {
        final session = sessionBuilder.build();

        // Store garbage bytes as an "image"
        final garbageBytes = ByteData.sublistView(
          Uint8List.fromList([0x00, 0x01, 0x02, 0x03, 0xFF, 0xFE]),
        );
        await session.storage.storeFile(
          storageId: 'public',
          path: 'media/corrupt-id/corrupt.png',
          byteData: garbageBytes,
        );

        final asset = await MediaAsset.db.insertRow(
          session,
          MediaAsset(
            tenantId: null,
            fileName: 'corrupt.png',
            assetId: 'corrupt-id',
            storagePath: 'media/corrupt-id/corrupt.png',
            publicUrl: 'http://localhost/media/corrupt-id/corrupt.png',
            mimeType: 'image/png',
            fileSize: 6,
            metadataStatus: MediaAssetMetadataStatus.pending,
          ),
        );

        await MetadataExtractor.extractAndUpdate(session, asset);

        final updated = await MediaAsset.db.findById(session, asset.id!);
        expect(updated!.metadataStatus, equals(MediaAssetMetadataStatus.failed));
      });
    });
  });
}
```

- [ ] **Step 2: Run tests (requires Docker)**

Start Docker services first if not running:
```bash
cd dart_desk_be_server && docker compose up -d postgres_test redis_test
```

Wait for Postgres, then run:
```bash
dart test test/integration/services/metadata_extractor_test.dart -v
```

Expected: PASS (4 tests). If the 1x1 PNG from `uploadTestImage` fails to decode via the `image` package, the "valid image" test may need a larger test fixture (e.g., a 10x10 PNG).

- [ ] **Step 3: Commit**

```bash
git add dart_desk_be_server/test/integration/services/metadata_extractor_test.dart
git commit -m "test: add integration tests for MetadataExtractor.extractAndUpdate"
```

---

## Task 4: CRDT Stress Test

**Files:**
- Create: `dart_desk_be_server/test/integration/crdt_stress_test.dart`
- Modify: `dart_desk_be_server/dart_test.yaml`
- Modify: `run_integration_tests.sh`

**Context:** This test creates a document with ~200 fields, applies ~2,000 CRDT operations, verifies state reconstruction, checks `getStateAtHlc` for historical replay, and verifies compaction works. Tagged `@Tag('stress')` so it can be excluded from normal CI runs.

- [ ] **Step 1: Add stress tag to dart_test.yaml**

Update `dart_desk_be_server/dart_test.yaml` to:

```yaml
tags:
  integration: {}
  stress: {}
```

- [ ] **Step 2: Update run_integration_tests.sh to exclude stress tag**

In `run_integration_tests.sh`, change the dart test command from:
```bash
dart test test/integration/ || TEST_EXIT=$?
```
to:
```bash
dart test test/integration/ --exclude-tags=stress || TEST_EXIT=$?
```

- [ ] **Step 3: Create the stress test file**

Create `dart_desk_be_server/test/integration/crdt_stress_test.dart`:

```dart
import 'dart:convert';
import 'dart:math';
import 'package:test/test.dart';
import 'package:dart_desk_be_server/src/generated/protocol.dart';
import 'package:dart_desk_be_server/src/services/document_crdt_service.dart';
import 'package:dart_desk_be_server/server.dart' as server;
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

@Tags(['stress'])
void main() {
  withServerpod('CRDT stress test', (sessionBuilder, endpoints) {
    late TestDataFactory factory;
    late DocumentCrdtService crdtService;

    setUp(() async {
      TestDataFactory.initializeCrdtService();
      crdtService = server.documentCrdtService!;
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    test('200 fields, 2000 operations, reconstruct and compact', () async {
      final authed = factory.authenticatedSession();
      final session = sessionBuilder.build();
      final random = Random(42); // Fixed seed for reproducibility

      // 1. Create initial document with ~200 fields (simulating a complex CMS page)
      final initialData = <String, dynamic>{};
      for (var s = 0; s < 10; s++) {
        final section = <String, dynamic>{};
        for (var b = 0; b < 5; b++) {
          section['block_$b'] = <String, dynamic>{
            'title': 'Section $s Block $b',
            'content': 'Lorem ipsum dolor sit amet, section $s block $b.',
            'visible': true,
            'order': b,
          };
        }
        initialData['section_$s'] = section;
      }

      final doc = await factory.createTestDocument(
        title: 'Stress Test Doc',
        data: initialData,
      );

      // Record intermediate HLC for history check later
      String? midpointHlc;

      // 2. Apply ~2000 CRDT operations in batches
      final fieldPaths = <String>[];
      for (var s = 0; s < 10; s++) {
        for (var b = 0; b < 5; b++) {
          fieldPaths.addAll([
            'section_$s.block_$b.title',
            'section_$s.block_$b.content',
            'section_$s.block_$b.visible',
            'section_$s.block_$b.order',
          ]);
        }
      }

      for (var batch = 0; batch < 100; batch++) {
        final updates = <String, dynamic>{};
        for (var i = 0; i < 20; i++) {
          final path = fieldPaths[random.nextInt(fieldPaths.length)];
          // Split dot-path to build nested map for updateDocumentData
          final keys = path.split('.');
          dynamic target = updates;
          for (var k = 0; k < keys.length - 1; k++) {
            (target as Map<String, dynamic>)[keys[k]] ??= <String, dynamic>{};
            target = target[keys[k]];
          }
          // Set a variety of value types
          final valueType = random.nextInt(3);
          dynamic value;
          if (valueType == 0) {
            value = 'updated_batch_${batch}_i_$i';
          } else if (valueType == 1) {
            value = random.nextInt(10000);
          } else {
            value = random.nextBool();
          }
          (target as Map<String, dynamic>)[keys.last] = value;
        }

        await endpoints.document.updateDocumentData(
          authed,
          doc.id!,
          updates,
        );

        // Capture HLC at midpoint
        if (batch == 50) {
          midpointHlc = await crdtService.getCurrentHlc(session, doc.id!);
        }
      }

      // 3. Verify getCurrentState returns valid data
      final stopwatch = Stopwatch()..start();
      final currentState = await crdtService.getCurrentState(session, doc.id!);
      stopwatch.stop();

      expect(currentState, isNotEmpty);
      expect(currentState.keys.where((k) => k.startsWith('section_')).length, equals(10));

      // Performance guard: should complete well under 15 seconds
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(15000),
        reason: 'getCurrentState took ${stopwatch.elapsedMilliseconds}ms, expected < 15000ms',
      );

      // 4. Verify getStateAtHlc for historical reconstruction
      if (midpointHlc != null) {
        final historicalState = await crdtService.getStateAtHlc(
          session,
          doc.id!,
          midpointHlc!,
        );
        expect(historicalState, isNotEmpty);
        // Historical state should have the same top-level structure
        expect(historicalState.keys.where((k) => k.startsWith('section_')).length, equals(10));
      }

      // 5. Verify reconstructFromOperations matches getCurrentState
      // Get all operations
      final allOpsResult = await session.db.unsafeQuery(
        r'SELECT * FROM document_crdt_operations WHERE "documentId" = $1 ORDER BY hlc ASC',
        parameters: QueryParameters.positional([doc.id!]),
      );
      final allOps = allOpsResult
          .map((row) => DocumentCrdtOperation.fromJson(row.toColumnMap()))
          .toList();

      final reconstructed = crdtService.reconstructFromOperations(
        allOps,
        initialState: {},
      );
      expect(jsonEncode(reconstructed), equals(jsonEncode(currentState)));

      // 6. Test compaction
      final opCountBefore = await crdtService.getOperationCount(session, doc.id!);
      expect(opCountBefore, greaterThan(1000));

      await crdtService.compactOperations(session, doc.id!, threshold: 100);

      final opCountAfter = await crdtService.getOperationCount(session, doc.id!);
      expect(opCountAfter, lessThan(opCountBefore));

      // State should still be correct after compaction
      final stateAfterCompaction = await crdtService.getCurrentState(session, doc.id!);
      expect(jsonEncode(stateAfterCompaction), equals(jsonEncode(currentState)));
    });
  });
}
```

- [ ] **Step 4: Run the stress test (requires Docker)**

```bash
cd dart_desk_be_server && dart test test/integration/crdt_stress_test.dart -v
```

Expected: PASS (1 test). May take 5-15 seconds depending on hardware.

- [ ] **Step 5: Verify normal integration tests still exclude stress**

```bash
cd dart_desk_be_server && dart test test/integration/ --exclude-tags=stress --dry-run
```

Verify the stress test is NOT in the list.

- [ ] **Step 6: Commit**

```bash
git add dart_desk_be_server/test/integration/crdt_stress_test.dart dart_desk_be_server/dart_test.yaml run_integration_tests.sh
git commit -m "test: add CRDT stress test with 200 fields and 2000 operations"
```

---

## Task 5: AwsImageStorageProvider Unit Tests (dart_desk_cloud)

**Files:**
- Create: `dart_desk_cloud/test/unit/services/aws_image_storage_provider_test.dart`

**Context:** `AwsImageStorageProvider.transformUrl` (line 47 of `dart_desk_cloud/lib/src/services/aws_image_storage_provider.dart`) is pure URL-building logic. It takes a `publicUrl` and `ImageTransformParams`, and returns a Thumbor-compatible URL like `https://{transformHost}/{fit}/{WxH}/filters:{...}/{path}`. The constructor requires a `Session` and `transformHost`, but `transformUrl` doesn't use the session.

For `transformUrl` tests, we mock `Session` minimally (just to construct the provider). The `store`/`delete` tests are deferred per spec if mocking proves brittle — focus on `transformUrl`.

`ImageTransformParams` and `FitMode` are defined in `dart_desk_be_server/lib/src/services/image_storage_provider.dart`.

- [ ] **Step 1: Create directory structure**

```bash
mkdir -p dart_desk_cloud/test/unit/services
```

- [ ] **Step 2: Create test file**

Create `dart_desk_cloud/test/unit/services/aws_image_storage_provider_test.dart`:

```dart
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:serverpod/serverpod.dart';
import 'package:dart_desk_be_server/src/services/image_storage_provider.dart';
import 'package:dart_desk_cloud/src/services/aws_image_storage_provider.dart';

class MockSession extends Mock implements Session {}

void main() {
  late AwsImageStorageProvider provider;
  late MockSession mockSession;

  setUp(() {
    mockSession = MockSession();
    provider = AwsImageStorageProvider(
      session: mockSession,
      transformHost: 'transforms.example.com',
    );
  });

  group('transformUrl', () {
    const publicUrl = 'https://bucket.s3.us-west-2.amazonaws.com/media/abc123/hero.jpg';

    test('clip fit: produces fit-in URL', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(width: 800, height: 600, fit: FitMode.clip),
      );

      expect(result, equals(
        'https://transforms.example.com/fit-in/800x600/media/abc123/hero.jpg',
      ));
    });

    test('max fit: produces fit-in URL', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(width: 400, height: 300, fit: FitMode.max),
      );

      expect(result, contains('fit-in/400x300'));
    });

    test('crop fit: produces direct dimensions (no fit-in)', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(width: 800, height: 600, fit: FitMode.crop),
      );

      expect(result, contains('800x600'));
      expect(result, isNot(contains('fit-in')));
    });

    test('fill fit: produces direct dimensions (no fit-in)', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(width: 800, height: 600, fit: FitMode.fill),
      );

      expect(result, contains('800x600'));
      expect(result, isNot(contains('fit-in')));
    });

    test('scale fit: produces direct dimensions (no fit-in)', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(width: 800, height: 600, fit: FitMode.scale),
      );

      expect(result, contains('800x600'));
      expect(result, isNot(contains('fit-in')));
    });

    test('focal point: adds smart segment', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(width: 800, height: 600, fit: FitMode.crop, fpX: 0.5, fpY: 0.3),
      );

      expect(result, contains('/smart/'));
    });

    test('format filter', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(width: 800, height: 600, fit: FitMode.clip, format: 'webp'),
      );

      expect(result, contains('filters:format(webp)'));
    });

    test('quality filter', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(width: 800, height: 600, fit: FitMode.clip, quality: 80),
      );

      expect(result, contains('filters:quality(80)'));
    });

    test('combined format and quality filters', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(
          width: 800,
          height: 600,
          fit: FitMode.clip,
          format: 'webp',
          quality: 80,
        ),
      );

      expect(result, contains('filters:format(webp):quality(80)'));
    });

    test('no transforms: returns null', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(),
      );

      expect(result, isNull);
    });

    test('public URL with leading slash: path extracted correctly', () {
      final result = provider.transformUrl(
        'https://bucket.s3.amazonaws.com/media/test/image.jpg',
        ImageTransformParams(width: 100, height: 100, fit: FitMode.clip),
      );

      expect(result, endsWith('/media/test/image.jpg'));
      expect(result, isNot(contains('//media'))); // No double slash
    });

    test('width only: defaults to clip fit with height 0', () {
      final result = provider.transformUrl(
        publicUrl,
        ImageTransformParams(width: 500),
      );

      // When fit is null, code does: final fit = params.fit ?? FitMode.clip
      // So it defaults to clip → fit-in/500x0
      expect(result, contains('fit-in/500x0'));
    });
  });
}
```

- [ ] **Step 3: Run tests**

```bash
cd dart_desk_cloud && dart test test/unit/services/aws_image_storage_provider_test.dart -v
```

Expected: PASS (12 tests). If `MockSession` fails to compile due to Serverpod `Session` constructor constraints, simplify by testing `transformUrl` logic in a standalone function extracted from the class, or use a more targeted mock.

- [ ] **Step 4: Commit**

```bash
git add dart_desk_cloud/test/unit/services/aws_image_storage_provider_test.dart
git commit -m "test: add unit tests for AwsImageStorageProvider.transformUrl"
```

---

## Task 6: CI Pipeline

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Create .github/workflows directory**

```bash
mkdir -p .github/workflows
```

- [ ] **Step 2: Create ci.yml**

Create `.github/workflows/ci.yml`:

**Note:** dart_desk_cloud is a separate repository. Its CI workflow should be created in that repo separately. This workflow covers dart_desk_be only.

**Deferred:** The spec's "Deployment Gate" (adding unit tests to existing deployment workflows) is deferred to a follow-up task since the deployment workflows live in dart_desk_cloud's repo.

```yaml
name: CI

on:
  push:
    branches: ['**']
  pull_request:
    branches: [main, master]

jobs:
  unit-tests:
    name: Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: dart-lang/setup-dart@v1
        with:
          sdk: '3.5.0'

      - name: Get dependencies
        working-directory: dart_desk_be_server
        run: dart pub get

      - name: Run unit tests
        working-directory: dart_desk_be_server
        run: dart test test/unit/ -v

  integration-tests:
    name: Integration Tests
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    services:
      postgres:
        image: pgvector/pgvector:pg16
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: dart_desk_be_test
        ports:
          - 9090:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 5s
          --health-timeout 5s
          --health-retries 10

      redis:
        image: redis:6.2.6
        ports:
          - 9091:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 5s
          --health-timeout 5s
          --health-retries 10

    steps:
      - uses: actions/checkout@v4

      - uses: dart-lang/setup-dart@v1
        with:
          sdk: '3.5.0'

      - name: Get dependencies
        working-directory: dart_desk_be_server
        run: dart pub get

      - name: Run integration tests (excludes stress)
        working-directory: dart_desk_be_server
        run: dart test test/integration/ --exclude-tags=stress -v
```

- [ ] **Step 3: Verify workflow syntax**

```bash
cat .github/workflows/ci.yml | head -5
```

Confirm file exists and YAML is valid.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: add two-tier CI pipeline with unit and integration tests"
```

---

## Task 7: Final Verification

- [ ] **Step 1: Run all unit tests across both projects**

```bash
cd dart_desk_be_server && dart test test/unit/ -v
```

Expected: all unit tests pass (CRDT service + subdomain extraction). MetadataExtractor tests are under integration/services/ and run separately.

```bash
cd ../dart_desk_cloud && dart test test/unit/ -v
```

Expected: all transformUrl tests pass.

- [ ] **Step 2: Run integration tests (requires Docker)**

```bash
cd dart_desk_be_server && docker compose up -d postgres_test redis_test
# Wait for ready
dart test test/integration/ --exclude-tags=stress -v
```

Expected: all existing + new integration tests pass.

- [ ] **Step 3: Run stress test separately**

```bash
cd dart_desk_be_server && dart test -t stress -v
```

Expected: stress test passes within 15 seconds.

- [ ] **Step 4: Commit any fixes from verification**

If any tests needed adjustment during verification, commit those fixes.
