# dart_desk_server

Serverpod backend for [Dart Desk](https://github.com/ThangVuNguyenViet/dart_desk_be) — a headless CMS with versioned documents, CRDT collaboration, media management, and a public read API for consumer apps.

> ⚠️ **Rapid development.** APIs may shift between minor versions.
> Bug reports and feature requests are very welcome — please open an issue at
> [github.com/ThangVuNguyenViet/dart_desk_be/issues](https://github.com/ThangVuNguyenViet/dart_desk_be/issues).

## Prerequisites

- Dart SDK >= 3.5.0
- Docker (for PostgreSQL and Redis)

## Getting started

```bash
# 1. Start Postgres + Redis
docker compose up --build --detach

# 2. Run the server
dart bin/main.dart

# 3. Stop services when finished
docker compose stop
```

## Configuration

Server config lives in `config/`:

- `development.yaml` — local development settings
- `production.yaml` — production settings
- `passwords.yaml` — secrets (not committed; create from `passwords.example.yaml` and fill in)

## Features

### Documents

- CRUD with version history (draft / published / scheduled / archived) and a publish workflow.
- **Soft delete** with partial unique indexes — slugs and emails can be reused after a row is soft-deleted.
- **UUID primary keys** across all entities.
- **CRDT-based collaborative editing** for partial document updates without conflicts.

### Public read API (`publicContent` endpoint)

The integration surface for consumer apps. No auth required for default content:

| Method | Returns | Use for |
|--------|---------|---------|
| `getDefaultContents()` | `Map<String, PublicDocument>` (one default per type) | Most consumer apps |
| `getDefaultContent(documentType)` | `PublicDocument?` | A single type |
| `getContentsByDataContains(dataContainsJson)` | `Map<String, PublicDocument>` | JSONB containment lookup, default-flagged matches |
| `getAllContentsByDataContains(dataContainsJson)` | `Map<String, List<PublicDocument>>` | All matches per type — used for device-group / segment routing |

JSONB containment lookups use a generated `data_jsonb` column with a GIN index. See [`CLAUDE.md`](../CLAUDE.md) for the schema-drift caveats around the hand-rolled column.

### Media

- Upload endpoint with **single-pass server-side metadata extraction**: dimensions, EXIF, [BlurHash](https://blurha.sh/), dominant-color palette, content hash.
- Pluggable `ImageStorageProvider` with content-type tagging (S3, GCS, local disk, …).

### Auth

- Serverpod IDP — Google + email/password.
- API tokens for programmatic access.
- Role guards (RBAC) on protected endpoints.

### Operational

- Paginated list responses across collection endpoints.
- Structured logging.
- Purge service for hard-deleting soft-deleted rows past retention.
- Rate limiting on public-facing endpoints.
- Health-check endpoint for liveness/readiness probes.

## License

Business Source License 1.1 — see [LICENSE](LICENSE).
