# Unit & Stress Testing Design for dart_desk_be and dart_desk_cloud

**Date:** 2026-03-21
**Status:** Approved

## Summary

Add unit tests to dart_desk_be_server and dart_desk_cloud, a CRDT stress test to dart_desk_be_server, and a two-tier CI pipeline. The goal is fast feedback for pure logic (unit tests, no Docker) plus realistic validation for data-heavy operations (integration stress test with DB).

## Approach

**Approach 2 (selected):** Unit tests with mocktail for isolated logic + integration stress test against real Postgres for CRDT performance. Two-tier CI: unit tests on every push, integration tests on PRs to main/master.

## Test Structure

### dart_desk_be_server

```
test/
  unit/
    subdomain_extraction_test.dart        (existing)
    services/
      document_crdt_service_test.dart     (new)
      metadata_extractor_test.dart        (new)
  integration/
    ...existing 8 test files...
    crdt_stress_test.dart                 (new, @Tag('stress'))
    helpers/
      test_data_factory.dart              (existing)
    test_tools/
      serverpod_test_tools.dart           (existing)
```

### dart_desk_cloud

```
test/
  unit/
    services/
      aws_image_storage_provider_test.dart  (new)
```

### New Dependencies

- `mocktail` in both projects (dev_dependency)
- `serverpod_test` in dart_desk_cloud (currently missing)

## Test Specifications

### 1. `document_crdt_service_test.dart` (Pure Unit Tests)

Tests `reconstructFromOperations` — the public method that takes a list of operations + initial state and returns reconstructed document data. No DB or mocks needed.

**Test cases:**
- Flatten/unflatten round-trip: nested map -> operations -> reconstructed map matches original
- Nested structures: deeply nested maps (3-4 levels) reconstruct correctly
- Mixed types: strings, ints, doubles, bools, lists, nulls preserved through JSON encode/decode
- Operation ordering: put operations applied in HLC order, last-write-wins
- Delete operations: fields removed correctly, surrounding fields unaffected
- Empty state: empty initial state + no operations -> empty map
- Overwrite: multiple puts to same field path -> last value wins

### 2. `metadata_extractor_test.dart` (Unit Tests with Mocked Session)

Uses `mocktail` to mock `Session.storage`. Tests the full `extractAndUpdate` flow.

**Test cases:**
- Valid image: mock storage returns a small PNG -> verify LQIP generated, palette extracted, metadata status = complete
- GPS extraction: image with EXIF GPS data -> correct lat/lng with N/S/E/W hemisphere handling
- No EXIF: image without EXIF data -> GPS fields null, status still complete
- Missing file: storage returns null -> metadata status = failed
- Corrupt image: undecodable bytes -> metadata status = failed

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
- Performance guard: `getCurrentState` after 2,000 ops completes under 5 seconds (regression tripwire, not a benchmark)
- Compaction: trigger `compactOperations`, verify state still correct and operation count reduced

### 4. `aws_image_storage_provider_test.dart` (Unit Tests with Mocked Session)

Uses `mocktail` to mock `Session` and `Session.storage`.

**`transformUrl` tests (pure logic, no mocks):**
- Resize with clip/max fit: `width=800, height=600, fit=clip` -> `fit-in/800x600` in URL
- Resize with crop/fill/scale fit: `width=800, height=600, fit=crop` -> `800x600` (no fit-in)
- Smart cropping: focal point params -> `smart` segment in URL
- Format filter: `format=webp` -> `filters:format(webp)`
- Quality filter: `quality=80` -> `filters:quality(80)`
- Combined filters: format + quality -> `filters:format(webp):quality(80)`
- No transforms: no params -> returns null
- Path extraction: public URL with leading slash handled correctly

**`store` tests (mocked):**
- Calls `storeFile` with correct path `media/{assetId}/{fileName}`
- Calls `getPublicUrl` and returns the result

**`delete` tests (mocked):**
- Calls `deleteFile` with correct path

## CI Pipeline

### Location

`dart_desk_cloud/deploy/workflows/ci.yml` (alongside existing deployment workflows)

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
