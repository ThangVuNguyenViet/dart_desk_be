# Nullable ApiKeyContext Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `session.apiKey` return `ApiKeyContext?` so callers get compile-time enforcement instead of a silent permissive default.

**Architecture:** Change the getter return type, then update every caller to null-check and throw. Update test data factory so test users have a concrete clientId.

**Tech Stack:** Dart, Serverpod

---

### Task 1: Make `session.apiKey` nullable and update all callers

This is a single atomic change — the getter and all callers must change together for compilation.

**Files:**
- Modify: `dart_desk_server/lib/src/auth/dart_desk_session.dart`
- Modify: `dart_desk_server/lib/src/endpoints/document_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/public_content_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/document_collaboration_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/media_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/cms_api_token_endpoint.dart`

- [ ] **Step 1: Update the getter to return `ApiKeyContext?`**

In `dart_desk_server/lib/src/auth/dart_desk_session.dart`, replace the entire extension:

```dart
extension DartDeskSessionExt on Session {
  /// The validated API key context for this request.
  /// Returns null when no API key has been set (e.g. test contexts without
  /// the pre-endpoint handler).
  ApiKeyContext? get apiKey {
    final ctx = requestContext?[_apiKeyContextKey];
    if (ctx is ApiKeyContext) return ctx;
    return null;
  }

  /// Sets the API key context. Called by the pre-endpoint handler.
  set apiKey(ApiKeyContext ctx) {
    requestContext ??= {};
    requestContext![_apiKeyContextKey] = ctx;
  }
}
```

- [ ] **Step 2: Update `DocumentEndpoint._requireAuth` and `_requireUser`**

In `dart_desk_server/lib/src/endpoints/document_endpoint.dart`, replace lines 616-625:

```dart
  /// Authenticate the current request via session.apiKey.
  Future<AuthResult> _requireAuth(Session session) async {
    final apiKey = session.apiKey;
    if (apiKey == null) {
      throw Exception('Missing API key');
    }
    return (apiKey: apiKey, user: null);
  }

  /// Authenticate and require a user identity (for write operations).
  Future<AuthResult> _requireUser(Session session) async {
    final apiKey = session.apiKey;
    if (apiKey == null) {
      throw Exception('Missing API key');
    }
    final user = await resolveUser(session, clientId: apiKey.clientId);
    return (apiKey: apiKey, user: user);
  }
```

- [ ] **Step 3: Update `PublicContentEndpoint._requireReadAccess`**

In `dart_desk_server/lib/src/endpoints/public_content_endpoint.dart`, replace lines 119-126:

```dart
  /// Validates the API key has read access and returns the clientId.
  int? _requireReadAccess(Session session) {
    final apiKey = session.apiKey;
    if (apiKey == null) {
      throw Exception('Missing API key');
    }
    if (!apiKey.canRead) {
      throw Exception('API key does not have read permission.');
    }
    return apiKey.clientId;
  }
```

- [ ] **Step 4: Update `DocumentCollaborationEndpoint` (2 call sites)**

In `dart_desk_server/lib/src/endpoints/document_collaboration_endpoint.dart`:

Replace line 40 (`final user = await resolveUser(session, clientId: session.apiKey.clientId);`):

```dart
    final apiKey = session.apiKey;
    if (apiKey == null) throw Exception('Missing API key');
    final user = await resolveUser(session, clientId: apiKey.clientId);
```

Replace line 127 (`await resolveUser(session, clientId: session.apiKey.clientId);`):

```dart
    final apiKey = session.apiKey;
    if (apiKey == null) throw Exception('Missing API key');
    await resolveUser(session, clientId: apiKey.clientId);
```

- [ ] **Step 5: Update `MediaEndpoint._authenticateAndResolve`**

In `dart_desk_server/lib/src/endpoints/media_endpoint.dart`, replace lines 302-307:

```dart
  Future<(({ApiKeyContext apiKey, User? user}), int?)> _authenticateAndResolve(Session session) async {
    final apiKey = session.apiKey;
    if (apiKey == null) throw Exception('Missing API key');
    final user = await resolveUser(session, clientId: apiKey.clientId);
    final authResult = (apiKey: apiKey, user: user as User?);
    return (authResult, apiKey.clientId);
  }
```

- [ ] **Step 6: Update `CmsApiTokenEndpoint._requireAuth`**

In `dart_desk_server/lib/src/endpoints/cms_api_token_endpoint.dart`, replace lines 166-171:

```dart
  Future<(({ApiKeyContext apiKey, User? user}), int?)> _requireAuth(Session session) async {
    final apiKey = session.apiKey;
    if (apiKey == null) throw Exception('Missing API key');
    final user = await resolveUser(session, clientId: apiKey.clientId);
    final authResult = (apiKey: apiKey, user: user as User?);
    return (authResult, apiKey.clientId);
  }
```

- [ ] **Step 7: Verify compilation**

Run:
```bash
cd dart_desk_server && dart analyze
```

Expected: No errors.

- [ ] **Step 8: Run tests**

Run:
```bash
cd dart_desk_server && dart test test/integration/document_versioning_test.dart && dart test test/integration/public_content_endpoint_test.dart && dart test test/integration/user_endpoint_test.dart
```

Expected: All tests pass. (Note: kill any running Dart server on port 8080 first if tests fail with port conflict.)

- [ ] **Step 9: Commit**

```bash
git add dart_desk_server/lib/src/auth/dart_desk_session.dart dart_desk_server/lib/src/endpoints/
git commit -m "refactor: make session.apiKey nullable, remove permissive default"
```
