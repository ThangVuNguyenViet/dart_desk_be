# Nullable ApiKeyContext Design

## Overview

Make `DartDeskSessionExt.apiKey` return `ApiKeyContext?` instead of `ApiKeyContext` with a permissive default. This forces compile-time safety — callers must explicitly handle the case where no API key is present, rather than silently using a fake context.

## Changes

### 1. `DartDeskSessionExt.apiKey` getter returns `ApiKeyContext?`

In `dart_desk_server/lib/src/auth/dart_desk_session.dart`:
- Change return type from `ApiKeyContext` to `ApiKeyContext?`
- Remove the permissive default fallback (`ApiKeyContext(clientId: null, role: 'write', tokenId: 0)`)
- Return `null` when no context is set

### 2. Update all callers to null-check

Every endpoint that accesses `session.apiKey` must null-check and throw if null:

- `DocumentEndpoint._requireAuth()` — null-check, throw `'Missing API key'`
- `PublicContentEndpoint._requireReadAccess()` — null-check, throw
- `DocumentCollaborationEndpoint` (2 call sites) — null-check, throw
- `MediaEndpoint` (1 call site) — null-check, throw
- `CmsApiTokenEndpoint` (1 call site) — null-check, throw

The `server.dart` pre-handler (setter side) is unchanged.

### 3. Fix tests for explicit `clientId` endpoints

Update tests calling endpoints that now take `clientId` explicitly:

- `document_endpoint_test.dart` — pass `clientId` to `getDocumentCount`
- `user_endpoint_test.dart` — pass `clientId` to `getCurrentUser` and `getUserCount`

### 4. Update `TestDataFactory`

- Add `static const testClientId = 1`
- Update `ensureTestUser` to default to `clientId: testClientId`
- Tests use `TestDataFactory.testClientId` when passing `clientId` to endpoints
