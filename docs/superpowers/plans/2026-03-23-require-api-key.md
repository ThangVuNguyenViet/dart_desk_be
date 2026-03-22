# Require x-api-key on All API Requests

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `x-api-key` mandatory on all API requests, rename `tenantId` → `clientId` across all models, remove `DartDeskTenancy`, and update the CMS app to send the API key header.

**Architecture:** Two-pass auth — `x-api-key` header is required and resolves the client (project) + role; `Authorization: Bearer` optionally resolves user identity. `DartDeskAuth.authenticateRequest` returns `AuthResult` (apiKey + optional user) instead of `User?`. All endpoints updated to use the new return type.

**Tech Stack:** Dart, Serverpod, existing `ApiKeyValidator`/`ApiKeyContext` (from prior implementation), Flutter (`dart_desk` frontend package)

**Spec:** `docs/superpowers/specs/2026-03-23-require-api-key-design.md`

**Scope note:** This plan covers both backend (`dart_desk_be`) and frontend (`dart_desk`) repos. Backend tasks (1–7) run in the backend repo. Frontend tasks (8–10) run in the `dart_desk` repo. Task 7 (seed script) bridges both.

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `lib/src/auth/api_key_context.dart` | Modify | Rename `tenantId` → `clientId` |
| `lib/src/auth/api_key_validator.dart` | Modify | Update `tenantId` references → `clientId` |
| `lib/src/auth/dart_desk_auth.dart` | Modify | Return `AuthResult`, require x-api-key, remove `DartDeskTenancy` import |
| `lib/src/tenancy.dart` | Delete | No longer needed |
| `lib/server.dart` | Modify | Remove `DartDeskTenancy.configure` |
| `lib/src/plugin/dart_desk_registry.dart` | Modify | Remove tenant resolver |
| `lib/src/plugin/dart_desk_session.dart` | Modify | Remove `resolveTenantId` |
| `lib/src/models/api_token.spy.yaml` | Modify | Rename `tenantId` → `clientId` |
| `lib/src/models/user.spy.yaml` | Modify | Rename `tenantId` → `clientId` |
| `lib/src/models/document.spy.yaml` | Modify | Rename `tenantId` → `clientId` |
| `lib/src/models/media_asset.spy.yaml` | Modify | Rename `tenantId` → `clientId` |
| `lib/src/endpoints/cms_api_token_endpoint.dart` | Modify | Use `AuthResult`, `clientId` |
| `lib/src/endpoints/document_endpoint.dart` | Modify | Use `AuthResult`, `clientId` |
| `lib/src/endpoints/document_collaboration_endpoint.dart` | Modify | Use `AuthResult` |
| `lib/src/endpoints/media_endpoint.dart` | Modify | Use `AuthResult`, `clientId`, fix inconsistent auth |
| `lib/src/endpoints/user_endpoint.dart` | Modify | Use `AuthResult`, `clientId` |
| `lib/src/endpoints/deployment_endpoint.dart` | Modify | Update `tenantId` → `clientId` |
| `lib/src/endpoints/project_endpoint.dart` | Modify | Update `tenantId` → `clientId` |
| `bin/seed_e2e.dart` | Modify | Rename `tenantId` column reference |
| `test/integration/helpers/test_data_factory.dart` | Modify | Update `tenantId` → `clientId` |
| `test/integration/cms_api_token_endpoint_test.dart` | Modify | Tests for required API key |
| `test/integration/api_key_auth_test.dart` | Modify | Tests for required API key |

All paths relative to `dart_desk_be_server/`.

---

### Task 1: Rename `tenantId` → `clientId` in models and generate

**Files:**
- Modify: `lib/src/models/api_token.spy.yaml`
- Modify: `lib/src/models/user.spy.yaml`
- Modify: `lib/src/models/document.spy.yaml`
- Modify: `lib/src/models/media_asset.spy.yaml`

This task must come first because `serverpod generate` regenerates all model classes, and subsequent tasks need the new field names.

- [ ] **Step 1: Update api_token.spy.yaml**

Replace all occurrences of `tenantId` with `clientId`:

```yaml
class: ApiToken
table: api_tokens
fields:
  clientId: int?
  name: String
  tokenHash: String
  tokenPrefix: String
  tokenSuffix: String
  role: String
  createdByUserId: int?, relation(parent=users, onDelete=SetNull)
  lastUsedAt: DateTime?
  expiresAt: DateTime?
  isActive: bool, default=true
  createdAt: DateTime?, default=now
indexes:
  api_token_client_idx:
    fields: clientId
  api_token_lookup_idx:
    fields: clientId, tokenPrefix, tokenSuffix
    unique: true
  api_token_prefix_suffix_idx:
    fields: tokenPrefix, tokenSuffix
```

Note: Index names also change (`api_token_tenant_idx` → `api_token_client_idx`).

- [ ] **Step 2: Update user.spy.yaml**

Replace all `tenantId` with `clientId` in fields and indexes. Update index names similarly (e.g., `user_tenant_idx` → `user_client_idx` or whatever the current names are). Read the file first to get exact index names.

- [ ] **Step 3: Update document.spy.yaml**

Same pattern — replace `tenantId` → `clientId` in fields and indexes.

- [ ] **Step 4: Update media_asset.spy.yaml**

Same pattern.

- [ ] **Step 5: Run `serverpod generate`**

Run: `cd dart_desk_be_server && serverpod generate`
Expected: Code generation completes successfully. All generated model classes now use `clientId`.

- [ ] **Step 6: Run `serverpod create-migration`**

Run: `cd dart_desk_be_server && serverpod create-migration`
Expected: Migration created that renames `tenantId` columns to `clientId` across all tables and updates index names.

**Important:** Check the generated migration SQL. Serverpod may generate DROP+ADD instead of RENAME for columns. If it drops and recreates, you'll lose data. In that case, manually edit the migration SQL to use `ALTER TABLE ... RENAME COLUMN "tenantId" TO "clientId"` instead.

- [ ] **Step 7: Commit**

```bash
git add lib/src/models/ lib/src/generated/ dart_desk_be_client/ migrations/
git commit -m "refactor: rename tenantId to clientId across all models"
```

---

### Task 2: Update `ApiKeyContext` and `ApiKeyValidator`

**Files:**
- Modify: `lib/src/auth/api_key_context.dart`
- Modify: `lib/src/auth/api_key_validator.dart`
- Modify: `test/unit/api_key_validator_test.dart`

- [ ] **Step 1: Update ApiKeyContext**

In `lib/src/auth/api_key_context.dart`, rename `tenantId` → `clientId`:

```dart
/// Holds validated API key information for the current request.
class ApiKeyContext {
  final int? clientId;
  final String role; // 'read' or 'write'
  final int tokenId;

  const ApiKeyContext({
    required this.clientId,
    required this.role,
    required this.tokenId,
  });

  bool get canWrite => role == 'write';
  bool get canRead => true; // both roles can read
}
```

- [ ] **Step 2: Update ApiKeyValidator**

In `lib/src/auth/api_key_validator.dart`, update the `validate` method. The model field is now `candidate.clientId` (from Task 1's generate). Update the return:

```dart
return ApiKeyContext(
  clientId: candidate.clientId,
  role: candidate.role,
  tokenId: candidate.id!,
);
```

- [ ] **Step 3: Verify**

Run: `cd dart_desk_be_server && dart analyze lib/src/auth/`
Expected: No issues

Run: `cd dart_desk_be_server && dart test test/unit/api_key_validator_test.dart`
Expected: All pass (unit tests don't reference tenantId)

- [ ] **Step 4: Commit**

```bash
git add lib/src/auth/api_key_context.dart lib/src/auth/api_key_validator.dart
git commit -m "refactor: rename tenantId to clientId in ApiKeyContext and ApiKeyValidator"
```

---

### Task 3: Update `DartDeskAuth` — require x-api-key, return `AuthResult`

**Files:**
- Modify: `lib/src/auth/dart_desk_auth.dart`

This is the core change. `authenticateRequest` must:
1. Require `x-api-key` (throw 401 if missing/invalid)
2. Return `AuthResult` instead of `User?`
3. Stop using `DartDeskTenancy`

- [ ] **Step 1: Update authenticateRequest**

Replace the current `authenticateRequest` method. The full updated `dart_desk_auth.dart`:

```dart
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'api_key_context.dart';
import 'api_key_validator.dart';
import 'external_auth_strategy.dart';

/// Result of authenticating a request.
/// [apiKey] is always present for valid requests (x-api-key is required).
/// [user] is present when the request also has a valid Bearer JWT.
typedef AuthResult = ({ApiKeyContext apiKey, User? user});

/// Central authentication registry for Dart Desk.
///
/// Two-pass auth:
/// 1. x-api-key (required) → resolves client + role
/// 2. Authorization: Bearer (optional) → resolves user identity
class DartDeskAuth {
  static List<ExternalAuthStrategy> _strategies = [];
  static List<String> _adminEmails = [];

  /// Configure external auth strategies and admin bootstrap emails.
  static void configure({
    List<ExternalAuthStrategy> externalStrategies = const [],
    List<String> adminEmails = const [],
  }) {
    _strategies = externalStrategies;
    _adminEmails = adminEmails;
  }

  /// Initialize all registered strategies. Call during server startup.
  static Future<void> initialize() async {
    for (final strategy in _strategies) {
      await strategy.initialize();
    }
  }

  /// Dispose all registered strategies. Call during server shutdown.
  static Future<void> dispose() async {
    for (final strategy in _strategies) {
      await strategy.dispose();
    }
  }

  /// Reset to default state (useful for testing).
  static void reset() {
    _strategies = [];
    _adminEmails = [];
  }

  /// Validate the x-api-key header. Returns null if missing or invalid.
  static Future<ApiKeyContext?> authenticateApiKey(Session session) async {
    final request = session.request;
    if (request == null) return null;

    final apiKeyHeader = request.headers['x-api-key']?.first;
    if (apiKeyHeader == null) return null;

    return ApiKeyValidator.validate(session, apiKeyHeader);
  }

  /// Authenticate the current request.
  ///
  /// 1. Validates x-api-key header (required) → resolves client + role
  /// 2. Checks Serverpod built-in IDP auth or external strategies → resolves user
  /// 3. Returns AuthResult with apiKey context and optional user
  ///
  /// Throws 401 if x-api-key is missing or invalid.
  static Future<AuthResult> authenticateRequest(Session session) async {
    // 1. Require API key
    final apiKeyCtx = await authenticateApiKey(session);
    if (apiKeyCtx == null) {
      throw ServerpodException(
        message: 'Missing or invalid x-api-key header',
        errorType: ExceptionType.unauthorized,
      );
    }

    final clientId = apiKeyCtx.clientId;

    // 2. Check Serverpod built-in auth
    final authInfo = session.authenticated;
    if (authInfo != null) {
      final user = await User.db.findFirstRow(
        session,
        where: (t) {
          var expr = t.serverpodUserId.equals(authInfo.userIdentifier);
          if (clientId != null) {
            expr = expr & t.clientId.equals(clientId);
          }
          return expr;
        },
      );
      return (apiKey: apiKeyCtx, user: user);
    }

    // 3. Try external strategies
    if (_strategies.isEmpty) return (apiKey: apiKeyCtx, user: null);

    final request = session.request;
    if (request == null) return (apiKey: apiKeyCtx, user: null);

    final headers = <String, String>{};
    for (final entry in request.headers.entries) {
      final values = entry.value;
      if (values.isNotEmpty) {
        headers[entry.key] = values.first;
      }
    }

    for (final strategy in _strategies) {
      final extUser = await strategy.authenticate(headers, session);
      if (extUser != null) {
        final user = await _findOrCreateUser(
            session, extUser, strategy.name, clientId);
        return (apiKey: apiKeyCtx, user: user);
      }
    }

    return (apiKey: apiKeyCtx, user: null);
  }

  /// Find existing User by external ID or auto-create one.
  static Future<User> _findOrCreateUser(
    Session session,
    ExternalAuthUser extUser,
    String providerName,
    int? clientId,
  ) async {
    // Try to find existing user by external identity
    var user = await User.db.findFirstRow(
      session,
      where: (t) =>
          t.externalId.equals(extUser.externalId) &
          t.externalProvider.equals(providerName) &
          (clientId != null
              ? t.clientId.equals(clientId)
              : t.clientId.equals(null)),
    );

    if (user != null) return user;

    // Determine role: admin if email is in adminEmails list, otherwise viewer
    final role = _adminEmails.contains(extUser.email) ? 'admin' : 'viewer';

    // Auto-create user
    user = User(
      clientId: clientId,
      email: extUser.email,
      name: extUser.name,
      role: role,
      isActive: true,
      externalId: extUser.externalId,
      externalProvider: providerName,
    );

    try {
      return await User.db.insertRow(session, user);
    } catch (e) {
      // Handle duplicate key race condition
      final retried = await User.db.findFirstRow(
        session,
        where: (t) =>
            t.externalId.equals(extUser.externalId) &
            t.externalProvider.equals(providerName) &
            (clientId != null
                ? t.clientId.equals(clientId)
                : t.clientId.equals(null)),
      );
      if (retried != null) return retried;
      rethrow;
    }
  }
}
```

- [ ] **Step 2: Verify**

Run: `cd dart_desk_be_server && dart analyze lib/src/auth/dart_desk_auth.dart`
Expected: No issues (the tenancy import is gone, AuthResult is used)

- [ ] **Step 3: Commit**

```bash
git add lib/src/auth/dart_desk_auth.dart
git commit -m "feat: require x-api-key in authenticateRequest, return AuthResult"
```

---

### Task 4: Remove `DartDeskTenancy` and update server/plugin

**Files:**
- Delete: `lib/src/tenancy.dart`
- Modify: `lib/server.dart`
- Modify: `lib/src/plugin/dart_desk_registry.dart`
- Modify: `lib/src/plugin/dart_desk_session.dart`

- [ ] **Step 1: Delete tenancy.dart**

```bash
rm lib/src/tenancy.dart
```

- [ ] **Step 2: Update server.dart**

Remove the line:
```dart
DartDeskTenancy.configure(resolver: registry.resolveTenantId);
```

And remove the import of `tenancy.dart` if present.

Also update the seed admin user creation: change `tenantId: null` → `clientId: null` (the field was renamed in Task 1).

- [ ] **Step 3: Update dart_desk_registry.dart**

Remove the tenant resolver section entirely:
- Remove `_tenantResolver` field
- Remove `setTenantResolver` method
- Remove `resolveTenantId` method

- [ ] **Step 4: Update dart_desk_session.dart**

Remove the `resolveTenantId` method and the import of `DartDeskTenancy` (or `DartDeskRegistry.resolveTenantId`). Read the file first to find exact lines.

- [ ] **Step 5: Verify**

Run: `cd dart_desk_be_server && dart analyze lib/`
Expected: There may be errors in endpoint files that still reference `User.tenantId` or old auth patterns — those will be fixed in Tasks 5-6. Check that `tenancy.dart`, `server.dart`, `dart_desk_registry.dart`, and `dart_desk_session.dart` are clean.

- [ ] **Step 6: Commit**

```bash
git add -A lib/src/tenancy.dart lib/server.dart lib/src/plugin/
git commit -m "refactor: remove DartDeskTenancy, clean up registry and session"
```

---

### Task 5: Update all endpoints to use `AuthResult`

**Files:**
- Modify: `lib/src/endpoints/cms_api_token_endpoint.dart`
- Modify: `lib/src/endpoints/document_endpoint.dart`
- Modify: `lib/src/endpoints/document_collaboration_endpoint.dart`
- Modify: `lib/src/endpoints/media_endpoint.dart`
- Modify: `lib/src/endpoints/user_endpoint.dart`

Each endpoint needs to handle the new `AuthResult` return type and use `clientId` instead of `tenantId`.

- [ ] **Step 1: Update cms_api_token_endpoint.dart**

The `_requireUser` helper currently returns `(User, int?)`. Update it:

```dart
/// Verify the caller is authenticated and resolve client.
Future<(AuthResult, int?)> _requireAuth(Session session) async {
  final authResult = await DartDeskAuth.authenticateRequest(session);
  if (authResult.user == null) {
    throw Exception('User must be authenticated');
  }
  return (authResult, authResult.apiKey.clientId);
}
```

Update all callers from `final (user, tenantId) = await _requireUser(session)` to `final (auth, clientId) = await _requireAuth(session)`. Where `user` was used (e.g., `user.id`), use `auth.user!.id` instead. Where `tenantId` was used, use `clientId`.

- [ ] **Step 2: Update document_endpoint.dart**

Current helper `_requireAuth` returns `User`. Change to return `AuthResult`:

```dart
Future<AuthResult> _requireAuth(Session session) async {
  return await DartDeskAuth.authenticateRequest(session);
}
```

Update all callers:
- `final cmsUser = await _requireAuth(session)` → `final auth = await _requireAuth(session)`
- `cmsUser.tenantId` → `auth.apiKey.clientId`
- `cmsUser.id` → `auth.user?.id`
- `createdByUserId: cmsUser.id` → `createdByUserId: auth.user?.id`
- Document queries filtering by `t.tenantId.equals(cmsUser.tenantId)` → `t.clientId.equals(auth.apiKey.clientId)`
- `tenantId: cmsUser.tenantId` → `clientId: auth.apiKey.clientId`

The raw SQL in `getDocumentTypes` (around line 311) that uses `tenantId` needs updating too — change the column name in the SQL string.

- [ ] **Step 3: Update document_collaboration_endpoint.dart**

Direct calls to `DartDeskAuth.authenticateRequest(session)`. Change:
- `final cmsUser = await DartDeskAuth.authenticateRequest(session)` → `final auth = await DartDeskAuth.authenticateRequest(session)`
- Null check: `if (cmsUser == null)` → `if (auth.user == null)` (for methods that require a user)
- `cmsUser.id` → `auth.user!.id`

- [ ] **Step 4: Update media_endpoint.dart**

Current helper `_authenticateAndResolve` returns `(User, int?)`. Update:

```dart
Future<(AuthResult, int?)> _authenticateAndResolve(Session session) async {
  final authResult = await DartDeskAuth.authenticateRequest(session);
  return (authResult, authResult.apiKey.clientId);
}
```

Update callers:
- `final (cmsUser, tenantId) = await _authenticateAndResolve(session)` → `final (auth, clientId) = await _authenticateAndResolve(session)`
- `cmsUser.id` → `auth.user?.id`
- `tenantId: tenantId` → `clientId: clientId`

Also fix the inconsistent auth in `deleteMedia` and `updateMediaAsset` — they currently use raw `session.authenticated` instead of `DartDeskAuth`. Update them to use `_authenticateAndResolve` for consistency.

- [ ] **Step 5: Update user_endpoint.dart**

Direct calls. Change:
- `await DartDeskAuth.authenticateRequest(session)` returns `AuthResult` now
- `getCurrentUser`: return `auth.user`
- `getUserCount`: use `auth.apiKey.clientId` for filtering, `auth.user` for identity

- [ ] **Step 6: Verify**

Run: `cd dart_desk_be_server && dart analyze lib/src/endpoints/`
Expected: No issues (or only issues in deployment/project endpoints — Task 6)

- [ ] **Step 7: Commit**

```bash
git add lib/src/endpoints/cms_api_token_endpoint.dart lib/src/endpoints/document_endpoint.dart lib/src/endpoints/document_collaboration_endpoint.dart lib/src/endpoints/media_endpoint.dart lib/src/endpoints/user_endpoint.dart
git commit -m "feat: update endpoints to use AuthResult and clientId"
```

---

### Task 6: Update `DeploymentEndpoint` and `ProjectEndpoint`

**Files:**
- Modify: `lib/src/endpoints/deployment_endpoint.dart`
- Modify: `lib/src/endpoints/project_endpoint.dart`

These endpoints have their own auth patterns (not using `DartDeskAuth.authenticateRequest`). They use `session.authenticated` directly because they're admin-level operations tied to specific projects. **Scope decision:** keep their existing auth pattern — only rename `tenantId` → `clientId`. Threading `AuthResult` through these endpoints is deferred (they don't serve CMS content, so the x-api-key requirement doesn't apply to them yet).

- [ ] **Step 1: Update deployment_endpoint.dart**

The `_requireAdminUser` helper uses `t.tenantId.equals(project.id!)`. Update to `t.clientId.equals(project.id!)`. Keep the existing `session.authenticated` pattern.

- [ ] **Step 2: Update project_endpoint.dart**

The `createProjectWithOwner` method creates a User with `tenantId: project.id!`. Change to `clientId: project.id!`. Check for any other `tenantId` references.

- [ ] **Step 3: Verify full codebase**

Run: `cd dart_desk_be_server && dart analyze lib/`
Expected: No issues related to tenantId/clientId. Pre-existing warnings may remain.

Run: `grep -r "tenantId" lib/src/ --include="*.dart"`
Expected: No matches (all renamed). Generated files in `lib/src/generated/` should also be clean from Task 1's `serverpod generate`.

- [ ] **Step 4: Commit**

```bash
git add lib/src/endpoints/deployment_endpoint.dart lib/src/endpoints/project_endpoint.dart
git commit -m "refactor: update deployment and project endpoints to use clientId"
```

---

### Task 7: Update tests and seed script

**Files:**
- Modify: `test/integration/helpers/test_data_factory.dart`
- Modify: `test/integration/cms_api_token_endpoint_test.dart`
- Modify: `test/integration/api_key_auth_test.dart`
- Modify: `bin/seed_e2e.dart`

- [ ] **Step 1: Update test_data_factory.dart**

Change `tenantId: null` → `clientId: null` (or whatever the factory sets).

- [ ] **Step 2: Update seed_e2e.dart**

Change the SQL `"tenantId"` column reference to `"clientId"`:

```sql
INSERT INTO api_tokens ("clientId", name, "tokenHash", ...
```

- [ ] **Step 3: Update integration tests**

In `cms_api_token_endpoint_test.dart` and `api_key_auth_test.dart`, check for any `tenantId` references and update to `clientId`. The tests may not directly reference the field — read them first.

- [ ] **Step 4: Run all tests**

Run: `cd dart_desk_be_server && dart test test/unit/`
Expected: All pass

Run: `cd dart_desk_be_server && dart test test/integration/`
Expected: All pass (the integration test framework manages its own DB, so the migration will apply)

- [ ] **Step 5: Commit**

```bash
git add test/ bin/seed_e2e.dart
git commit -m "refactor: update tests and seed script for clientId rename"
```

---

### Task 8: Review and fix database migration

**Files:**
- Migration files from Task 1

- [ ] **Step 1: Review migration SQL**

Read the migration SQL generated in Task 1. Verify it uses `RENAME COLUMN` rather than `DROP` + `ADD`. If Serverpod generated destructive DDL, manually edit:

```sql
ALTER TABLE "api_tokens" RENAME COLUMN "tenantId" TO "clientId";
ALTER TABLE "users" RENAME COLUMN "tenantId" TO "clientId";
ALTER TABLE "documents" RENAME COLUMN "tenantId" TO "clientId";
ALTER TABLE "media_assets" RENAME COLUMN "tenantId" TO "clientId";
```

Also verify index renames look correct.

- [ ] **Step 2: Test migration locally**

Run:
```bash
cd dart_desk_be_server
docker compose up -d
dart run bin/main.dart --apply-migrations
```
Expected: Server starts with clean schema, no errors.

- [ ] **Step 3: Commit any migration fixes**

```bash
git add migrations/
git commit -m "fix: ensure column rename migration preserves data"
```

---

### Task 9: Frontend — add API key HTTP client wrapper

**Repo:** `dart_desk` (frontend)
**Files:**
- Create: `packages/dart_desk/lib/src/cloud/api_key_http_client.dart`

- [ ] **Step 1: Create ApiKeyHttpClient**

```dart
import 'package:http/http.dart' as http;

/// HTTP client wrapper that injects x-api-key header on every request.
///
/// Used with `runWithClient` to intercept all HTTP requests from
/// the Serverpod client without modifying generated code.
class ApiKeyHttpClient extends http.BaseClient {
  final http.Client _inner;
  final String _apiKey;

  ApiKeyHttpClient(this._inner, this._apiKey);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['x-api-key'] = _apiKey;
    return _inner.send(request);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add packages/dart_desk/lib/src/cloud/api_key_http_client.dart
git commit -m "feat: add ApiKeyHttpClient for x-api-key header injection"
```

---

### Task 10: Frontend — update `DartDeskApp` and `DartDeskAuth` widget

**Repo:** `dart_desk` (frontend)
**Files:**
- Modify: `packages/dart_desk/lib/src/studio/dart_desk_app.dart`
- Modify: `packages/dart_desk/lib/src/cloud/dart_desk_auth.dart`

- [ ] **Step 1: Add `apiKey` to DartDeskApp**

Add `String? apiKey` parameter to both constructors of `DartDeskApp`. Pass it to the `DartDeskAuth` widget in the `build` method.

- [ ] **Step 2: Update DartDeskAuth widget to use apiKey**

Add `String? apiKey` field to the widget. The header injection must happen at the app root level via `runWithClient`, NOT inside `_initializeClient` — because `runWithClient` is zone-scoped, and the zone must remain alive for the entire app lifetime.

**Important:** The `DartDeskAuth` widget should NOT call `runWithClient` internally. Instead, expose a static helper or document that the caller must wrap their `main()`:

```dart
// In cms_app/lib/main.dart:
void main() {
  final apiKey = const String.fromEnvironment('API_KEY');
  if (apiKey.isNotEmpty) {
    runWithClient(
      () => runApp(const MyApp()),
      () => ApiKeyHttpClient(http.Client(), apiKey),
    );
  } else {
    runApp(const MyApp());
  }
}
```

The `DartDeskAuth` widget receives the `apiKey` parameter for display/validation purposes only (e.g., showing an error if no API key is configured). The actual header injection is done at the `main()` level.

Verify `runWithClient` is available from `package:http/http.dart` (requires http >= 1.2.0).

- [ ] **Step 3: Update CloudDataSource tenantId reference**

In `packages/dart_desk/lib/src/cloud/cloud_data_source.dart`, line 467 already maps `doc.tenantId` → `clientId`. After the backend model rename, this will be `doc.clientId`. Update:

```dart
clientId: doc.clientId ?? 0,
```

- [ ] **Step 4: Verify**

Run: `cd packages/dart_desk && dart analyze lib/`
Expected: No issues

- [ ] **Step 5: Commit**

```bash
git add packages/dart_desk/lib/src/studio/dart_desk_app.dart packages/dart_desk/lib/src/cloud/dart_desk_auth.dart packages/dart_desk/lib/src/cloud/cloud_data_source.dart
git commit -m "feat: add apiKey parameter and inject x-api-key header"
```

---

### Task 11: Frontend — update `cms_app` entry points

**Repo:** `dart_desk` (frontend)
**Files:**
- Modify: `examples/cms_app/lib/main.dart`
- Modify: `examples/cms_app/lib/main_e2e.dart`

- [ ] **Step 1: Update main.dart**

Wrap `runApp` with `runWithClient` when an API key is provided:

```dart
import 'package:dart_desk/src/cloud/api_key_http_client.dart';
import 'package:http/http.dart' as http;

const String _defaultServerUrl = 'http://localhost:8080/';

void main() {
  const apiKey = String.fromEnvironment('API_KEY');
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized(CmsMarionetteConfig.configuration);
  }
  if (apiKey.isNotEmpty) {
    runWithClient(
      () => runApp(const MyApp()),
      () => ApiKeyHttpClient(http.Client(), apiKey),
    );
  } else {
    runApp(const MyApp());
  }
}
```

The `MyApp` widget stays the same but passes `apiKey` to `DartDeskApp`:

```dart
static const apiKey = String.fromEnvironment('API_KEY');

// In build():
return DartDeskApp(
  serverUrl: serverUrl,
  apiKey: apiKey.isNotEmpty ? apiKey : null,
  config: DartDeskConfig(...),
);
```

- [ ] **Step 2: Update main_e2e.dart**

Same pattern — wrap with `runWithClient` in `main()`, pass `apiKey` to `DartDeskApp`.

- [ ] **Step 3: Commit**

```bash
git add examples/cms_app/lib/main.dart examples/cms_app/lib/main_e2e.dart
git commit -m "feat: pass API_KEY from dart-define to DartDeskApp"
```

---

### Task 12: Final verification

- [ ] **Step 1: Run all backend tests**

Run: `cd dart_desk_be_server && dart test`
Expected: All tests pass

- [ ] **Step 2: Run backend analyzer**

Run: `cd dart_desk_be_server && dart analyze`
Expected: No new issues

- [ ] **Step 3: Verify no remaining tenantId references**

Run: `grep -r "tenantId" dart_desk_be_server/lib/src/ --include="*.dart"`
Expected: No matches

Run: `grep -r "tenantId" dart_desk_be_server/test/ --include="*.dart"`
Expected: No matches

Run: `grep -r "tenantId" dart_desk_be_server/bin/ --include="*.dart"`
Expected: No matches

- [ ] **Step 4: Verify server starts**

Run: `cd dart_desk_be_server && dart run bin/main.dart --apply-migrations`
Expected: Server starts without errors

- [ ] **Step 5: Commit any final fixes**

If any issues found, fix and commit.
