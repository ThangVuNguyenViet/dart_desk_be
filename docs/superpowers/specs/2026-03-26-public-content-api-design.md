# Public Content API Design

## Overview

A read-only public API for external consumers to fetch published document content. Authenticated via `x-api-key` with read permission. Client isolation enforced by deriving `clientId` from the API key.

## Schema Changes

### Document model — add `publishedAt`

Add a nullable `DateTime` field `publishedAt` to the `Document` model (`document.spy.yaml`). This is a denormalized copy of the publish timestamp from `DocumentVersion`, optimized for high-read public queries.

- **Set** to `DateTime.now()` when `publishDocumentVersion()` is called on any version of the document.
- **Nulled** when `archiveDocumentVersion()` is called and no other published versions remain for the document.
- **Partial index** on `documents(published_at) WHERE published_at IS NOT NULL` for fast filtered reads.

### Sync logic

Modify two existing methods in `DocumentEndpoint`:

- `publishDocumentVersion()` — after setting version status to `published`, also set `document.publishedAt = DateTime.now()`.
- `archiveDocumentVersion()` — after setting version status to `archived`, check if any published versions remain for the document. If none, set `document.publishedAt = null`.

## PublicDocument DTO

A protocol-only Serverpod model (no database table) for serializing public content responses.

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | `int` | Document ID |
| `documentType` | `String` | Document type identifier |
| `title` | `String` | Document title |
| `slug` | `String` | URL-friendly identifier |
| `isDefault` | `bool` | Whether this is the default document for its type |
| `data` | `Map<String, dynamic>` | Document content (JSON) |
| `publishedAt` | `DateTime` | When the document was published |
| `updatedAt` | `DateTime` | Last update timestamp |

Defined as a `.spy.yaml` without a `table` field.

## PublicContentEndpoint

A new endpoint class, separate from `DocumentEndpoint`. All methods require `x-api-key` with read permission. `clientId` is derived from the API key — not passed as a parameter.

All queries filter by `published_at IS NOT NULL`.

### Methods

#### `getAllContents()` -> `Map<String, List<PublicDocument>>`

Returns all published documents for the client, grouped by document type.

#### `getDefaultContents()` -> `Map<String, PublicDocument>`

Returns the default published document for each document type. Each key maps to a single `PublicDocument`.

#### `getContentsByType(String documentType)` -> `List<PublicDocument>`

Returns all published documents of a specific type.

#### `getDefaultContent(String documentType)` -> `PublicDocument`

Returns the default published document for a specific type. Throws if no default found.

#### `getContentBySlug(String documentType, String slug)` -> `PublicDocument`

Returns a single published document by type and slug. Throws if no match found.

### Authentication

This endpoint is **not** added to `_apiKeyExemptEndpoints`, so the existing pre-endpoint handler in `server.dart` enforces `x-api-key` validation automatically. The handler attaches `ApiKeyContext` to the session, from which the endpoint derives `clientId` and verifies read permission.

### Error Handling

- Missing/invalid API key: 401 (handled by pre-endpoint handler)
- Write-only API key: 403
- Document not found: 404
