# Unit & Stress Testing Design for dart_desk_be and dart_desk_cloud

**Date:** 2026-03-21
**Status:** Approved

## Summary

Add unit tests to dart_desk_be_server and dart_desk_cloud, a CRDT stress test to dart_desk_be_server, and a two-tier CI pipeline. The goal is fast feedback for pure logic (unit tests, no Docker) plus realistic validation for data-heavy operations (integration stress test with DB).

## Approach

**Approach 2 (selected):** Unit tests with mocktail for isolated logic + integration stress test against real Postgres for CRDT performance. Two-tier CI: unit tests on every push, integration tests on PRs to main/master.

## Prerequisites

**dart_desk_cloud Serverpod version alignment:** dart_desk_cloud uses `serverpod: ^2.3.1` while dart_desk_be_server uses `serverpod: 3.4.3`. Since dart_desk_cloud depends on dart_desk_be_server via path, the Serverpod version in dart_desk_cloud must be updated to `3.4.3` (along with `serverpod_cloud_storage_s3`) before adding test infrastructure.

## Test Structure

### dart_desk_be_server

```
test/
  unit/
    subdomain_extraction_test.dart        (existing)
    services/
      document_crdt_service_test.dart     (new)
      metadata_extractor_test.dart        (new — integration, uses withServerpod)
  integration/
    ...existing 8 test files...
    crdt_stress_test.dart                 (new, @Tag('stress'))
    helpers/
      test_data_factory.dart              (existing)
    test_tools/
      serverpod_test_tools.dart           (existing)
```

**Note on metadata_extractor_test.dart location:** Although placed under `unit/services/` for organizational clarity, this test uses `withServerpod()` because `MetadataExtractor.extractAndUpdate` calls `MediaAsset.db.updateRow()` directly — a static Serverpod DB accessor that cannot be mocked via `mocktail`. It requires a real Serverpod session with DB rollback. An alternative is refactoring `MetadataExtractor` to accept a persistence callback, but that's out of scope for this spec.

### dart_desk_cloud

```
test/
  unit/
    services/
      aws_image_storage_provider_test.dart  (new)
```

### New Dependencies

**dart_desk_be_server:**
- `mocktail` (dev_dependency)

**dart_desk_cloud:**
- `test: ^1.24.2` (dev_dependency — currently has no dev_dependencies at all)
- `mocktail` (dev_dependency)

**Note:** `serverpod_test` is NOT needed in dart_desk_cloud since its tests are pure unit tests with mocks only.

## Test Specifications

### 1. `document_crdt_service_test.dart` (Pure Unit Tests)

Tests `reconstructFromOperations` — the public method that takes a list of operations + initial state and returns reconstructed document data. No DB or mocks needed.

**Note:** Test data must construct `DocumentCrdtOperation` objects with dot-notation field paths (e.g., `user.name` for `{"user": {"name": ...}}`), matching the private `_flattenMap` convention. The flatten/unflatten helpers are private and not directly callable from tests.

**Test cases:**
- Flatten/unflatten round-trip: nested map -> operations -> reconstructed map matches original
- Nested structures: deeply nested maps (3-4 levels) reconstruct correctly
- Mixed types: strings, ints, doubles, bools, lists, nulls preserved through JSON encode/decode
- Operation ordering: put operations applied in HLC order, last-write-wins
- Delete operations: fields removed correctly, surrounding fields unaffected
- Empty state: empty initial state + no operations -> empty map
- Overwrite: multiple puts to same field path -> last value wins

### 2. `metadata_extractor_test.dart` (Integration Test via withServerpod)

Uses `withServerpod()` for a real Serverpod session because `extractAndUpdate` calls `MediaAsset.db.updateRow()` and `session.storage.retrieveFile()` — static Serverpod accessors that cannot be mocked with `mocktail`.

**Test cases:**
- Valid image: store a small PNG in test storage -> call extractAndUpdate -> verify LQIP generated, palette extracted, metadata status = complete
- No EXIF: image without EXIF data -> GPS fields null, status still complete
- Missing file: call with non-existent storage path -> metadata status = failed
- Corrupt image: store undecodable bytes -> metadata status = failed

**Note on GPS testing:** Testing GPS extraction requires a real image with EXIF GPS data baked in. If creating such a fixture is impractical, this test case can be deferred.

### 3. `crdt_stress_test.dart` (Integration, @Tag('stress'))

Runs with Docker/Postgres. Simulates a complex CMS page heavily edited over time.

**Scenario:**
- Setup: create a document with ~200 fields (nested 3-4 levels — sections, blocks, rich text, metadata)
- Apply ~2,000 CRDT operations in batches: updates to random fields, new fields added, some deleted
- Assertions:
  - `getCurrentState` returns correct merged state (spot-check known field values)
  - `getStateAtHlc` reconstructs historical state at intermediate timestamps correctly
  - `reconstructFromOperations` output matches `getCurrentState` output
  - All operations complete without error
- Performance guard: `getCurrentState` after 2,000 ops completes under 15 seconds. This is a generous threshold to avoid flaky failures across different hardware. Intended as a local regression tripwire, not enforced in CI.
- Compaction: trigger `compactOperations`, verify state still correct and operation count reduced

### 4. `aws_image_storage_provider_test.dart` (Unit Tests)

**`transformUrl` tests (pure logic, no mocks — instantiate with a dummy session):**
- Resize with clip/max fit: `width=800, height=600, fit=clip` -> `fit-in/800x600` in URL
- Resize with crop/fill/scale fit: `width=800, height=600, fit=crop` -> `800x600` (no fit-in)
- Smart cropping: focal point params -> `smart` segment in URL
- Format filter: `format=webp` -> `filters:format(webp)`
- Quality filter: `quality=80` -> `filters:quality(80)`
- Combined filters: format + quality -> `filters:format(webp):quality(80)`
- No transforms: no params -> returns null
- Path extraction: public URL with leading slash handled correctly

**`store` and `delete` tests:** These call `session.storage.*` methods which are Serverpod internal APIs. Mocking `Session` with `mocktail` is possible (`class MockSession extends Mock implements Session {}`) but may be fragile across Serverpod upgrades. If mocking proves brittle, these tests should be deferred or the provider refactored to accept a storage interface. The `transformUrl` tests are the primary value here.

## CI Pipeline

### Location

`.github/workflows/ci.yml` — standard GitHub Actions location. The existing deployment workflows at `dart_desk_cloud/deploy/workflows/` are custom deployment scripts, not GitHub Actions workflows (they'd need to be copied to `.github/workflows/` to actually run).

### Tier 1 — Unit Tests (every push & PR)

- **Trigger:** push to any branch, all PRs
- **Steps:** checkout -> setup Dart SDK -> `dart pub get` in both packages -> `dart test test/unit/` in dart_desk_be_server and dart_desk_cloud
- **Duration:** ~30s, no Docker

### Tier 2 — Integration Tests (PRs to main/master)

- **Trigger:** PR to main/master
- **Steps:** checkout -> setup Dart SDK -> start Postgres + Redis via Docker Compose -> wait for DB ready -> `dart test test/integration/` in dart_desk_be_server (excludes stress tag)
- **Duration:** ~2-3 min with Docker startup

### Stress Tests

Run manually via `dart test -t stress` or workflow_dispatch. Not on every PR.

### Deployment Gate

Add unit test step to existing deployment workflows — fail-fast before pushing to staging/production.
