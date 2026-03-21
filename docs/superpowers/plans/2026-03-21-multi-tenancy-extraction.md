# Multi-Tenancy Extraction Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extract multi-tenancy from core into an optional cloud plugin, making the backend single-tenant by default.

**Architecture:** Rename all `Cms`-prefixed models to plain names, change `clientId: int` to `tenantId: int?` (nullable), add `DartDeskTenancy` callback for tenant resolution, and move `CmsClient`/`CmsDeployment` to a new `dart_desk_cloud` package. All existing tests are updated to work without multi-tenant setup boilerplate.

**Tech Stack:** Dart, Serverpod 3.4.3, PostgreSQL, serverpod_test

**Spec:** `docs/superpowers/specs/2026-03-21-multi-tenancy-extraction-design.md`

---

## File Structure

### New files
- `dart_desk_be_server/lib/src/tenancy.dart` — `DartDeskTenancy` class + `TenantResolver` typedef
- `dart_desk_cloud/` — entire new package (Task 8, out of scope for initial core work)

### Renamed model files (in `dart_desk_be_server/lib/src/models/`)
- `cms_document.spy.yaml` → content updated (class `Document`, table `documents`, `clientId` → `tenantId: int?`)
- `cms_user.spy.yaml` → content updated (class `User`, table `users`, `clientId` → `tenantId: int?`)
- `cms_api_token.spy.yaml` → content updated (class `ApiToken`, table `api_tokens`, `clientId` → `tenantId: int?`)
- `media_asset.spy.yaml` → content updated (`clientId` → `tenantId: int?`)
- `cms_document_data.spy.yaml` → content updated (class `DocumentData`, table `documents_data`)
- `document_version.spy.yaml` → content updated (`createdByUserId: int` → `int?`)
- `document_crdt_operation.spy.yaml` → FK target updated (`cms_documents` → `documents`)
- `document_crdt_snapshot.spy.yaml` → FK target updated
- `cms_api_token_with_value.spy.yaml` → content updated (class `ApiTokenWithValue`)
- `document_list.spy.yaml` → protocol ref updated (`CmsDocument` → `Document`)
- `cms_client.spy.yaml` → **deleted** (moves to cloud plugin)
- `cms_deployment.spy.yaml` → **deleted** (moves to cloud plugin)
- `cms_client_list.spy.yaml` → **deleted** (moves to cloud plugin)
- `client_with_token.spy.yaml` → **deleted** (moves to cloud plugin)

### Modified endpoint files (in `dart_desk_be_server/lib/src/endpoints/`)
- `document_endpoint.dart` — `CmsDocument` → `Document`, `CmsUser` → `User`, `clientId` → `tenantId`, add tenancy resolution
- `user_endpoint.dart` — Complete rewrite: remove `clientSlug`/`apiToken` params, simplify to single-tenant `ensureUser`
- `cms_api_token_endpoint.dart` → rename to `api_token_endpoint.dart`, `CmsApiToken` → `ApiToken`, `CmsUser` → `User`, `clientId` → `tenantId`
- `media_endpoint.dart` — `CmsUser` → `User`, `clientId` → `tenantId`
- `document_collaboration_endpoint.dart` — `CmsUser` → `User`, `clientId` → `tenantId`
- `studio_config_endpoint.dart` — minimal changes (no model refs)
- `cms_client_endpoint.dart` → **deleted** (moves to cloud plugin)
- `deployment_endpoint.dart` → **deleted** (moves to cloud plugin)

### Deleted web route files (in `dart_desk_be_server/lib/src/web/routes/`)
- `deployment_upload.dart` → **deleted** (cloud concern)
- `deployment_utils.dart` → **deleted** (cloud concern)
- `preview_route.dart` → **deleted** (cloud concern)
- `subdomain_router.dart` → **deleted** (cloud concern)
- `root.dart` — stays (no model refs)

### Deleted service files
- `dart_desk_be_server/lib/src/services/deployment_storage.dart` → **deleted** (cloud concern)

### Out of scope packages (cloud-only, will break until cloud plugin exists)
- `dart_desk_manage/` — entire manage app is cloud-only (client picker, deployments, tokens). Will not compile after this refactor. Moves to cloud plugin scope.
- `dart_desk_admin/` — admin dashboard sidebar config references old table names. Low priority fix.

### Modified test files (in `dart_desk_be_server/test/`)
- `integration/helpers/test_data_factory.dart` — remove `createTestClient`/`ensureUser` boilerplate, simplify to single-tenant
- `integration/document_endpoint_test.dart` — remove client setup, use simplified factory
- `integration/user_endpoint_test.dart` — rewrite for new single-tenant `ensureUser`
- `integration/cms_api_token_endpoint_test.dart` — adapt to `ApiToken`, remove client setup
- `integration/media_endpoint_test.dart` — adapt, remove client setup
- `integration/multi_tenancy_test.dart` → **deleted** (moves to cloud plugin tests)
- `integration/cms_client_endpoint_test.dart` → **deleted** (moves to cloud plugin tests)
- All other test files: adapt to renamed types

### Modified server files
- `server.dart` — remove `CmsClient`/`CmsDeployment` from admin module, update `_seedAdminUser` to create `User` record, remove deployment storage init (cloud concern)

---

## Tasks

### Task 1: Add DartDeskTenancy infrastructure

**Files:**
- Create: `dart_desk_be_server/lib/src/tenancy.dart`

- [ ] **Step 1: Create tenancy.dart with TenantResolver and DartDeskTenancy**

```dart
// dart_desk_be_server/lib/src/tenancy.dart
import 'package:serverpod/serverpod.dart';

/// Resolves tenant ID from the current request.
/// Returns null for single-tenant deployments.
typedef TenantResolver = Future<int?> Function(Session session);

/// Global tenant resolution configuration.
///
/// Single-tenant (default): always returns null.
/// Multi-tenant (cloud plugin): configured via [configure] to extract
/// tenant from request headers, JWT claims, etc.
class DartDeskTenancy {
  static TenantResolver _resolver = (_) async => null;

  /// Configure a custom tenant resolver (called by cloud plugin).
  static void configure({required TenantResolver resolver}) {
    _resolver = resolver;
  }

  /// Resolve the current tenant ID. Returns null in single-tenant mode.
  static Future<int?> resolveTenantId(Session session) => _resolver(session);

  /// Reset to default single-tenant resolver (useful for testing).
  static void reset() {
    _resolver = (_) async => null;
  }
}
```

- [ ] **Step 2: Verify file compiles**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && dart analyze lib/src/tenancy.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add dart_desk_be_server/lib/src/tenancy.dart
git commit -m "feat: add DartDeskTenancy infrastructure for tenant resolution"
```

---

### Task 2: Rename and update YAML models (core models)

This is the largest single task — all model YAML files are updated. Run `serverpod generate` once at the end.

**Files:**
- Modify: `dart_desk_be_server/lib/src/models/cms_document.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/cms_user.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/cms_api_token.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/media_asset.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/cms_document_data.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/document_version.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/document_crdt_operation.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/document_crdt_snapshot.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/cms_api_token_with_value.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/document_list.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/document_version_list.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/document_version_with_operations.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/models/document_version_list_with_operations.spy.yaml`
- Delete: `dart_desk_be_server/lib/src/models/cms_client.spy.yaml`
- Delete: `dart_desk_be_server/lib/src/models/cms_deployment.spy.yaml`
- Delete: `dart_desk_be_server/lib/src/models/cms_client_list.spy.yaml`
- Delete: `dart_desk_be_server/lib/src/models/client_with_token.spy.yaml`

- [ ] **Step 1: Update cms_document.spy.yaml**

Replace entire contents with:
```yaml
class: Document
table: documents
fields:
  tenantId: int?
  documentType: String
  title: String
  slug: String
  isDefault: bool, default=false
  data: String?
  crdtNodeId: String?
  crdtHlc: String?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now
  createdByUserId: int?, relation(parent=users, onDelete=SetNull)
  updatedByUserId: int?, relation(parent=users, onDelete=SetNull)
indexes:
  documents_tenant_type_idx:
    fields: tenantId, documentType
  documents_tenant_type_slug_idx:
    fields: tenantId, documentType, slug
    unique: true
  documents_type_default_idx:
    fields: documentType, isDefault
  documents_created_at_idx:
    fields: createdAt
```

- [ ] **Step 2: Update cms_user.spy.yaml**

Replace entire contents with:
```yaml
class: User
table: users
fields:
  tenantId: int?
  email: String
  name: String?
  role: String, default='viewer'
  isActive: bool, default=true
  serverpodUserId: String?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now
indexes:
  users_tenant_email_idx:
    fields: tenantId, email
    unique: true
  users_tenant_id_idx:
    fields: tenantId
  users_serverpod_user_id_idx:
    fields: serverpodUserId
  users_is_active_idx:
    fields: isActive
```

- [ ] **Step 3: Update cms_api_token.spy.yaml**

Replace entire contents with:
```yaml
class: ApiToken
table: api_tokens
fields:
  tenantId: int?
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
  api_token_tenant_idx:
    fields: tenantId
  api_token_lookup_idx:
    fields: tenantId, tokenPrefix, tokenSuffix
    unique: true
```

- [ ] **Step 4: Update media_asset.spy.yaml**

Change `clientId: int, relation(parent=cms_clients, onDelete=Restrict)` to `tenantId: int?` and update index names from `media_asset_client_id_idx` to `media_asset_tenant_id_idx`. Keep all other fields the same.

- [ ] **Step 5: Update cms_document_data.spy.yaml**

Change class name to `DocumentData`, table to `documents_data`. Update index names from `cms_documents_data_*` to `documents_data_*`.

- [ ] **Step 6: Update document_version.spy.yaml**

Change `createdByUserId: int, relation(parent=cms_users, onDelete=SetNull)` to `createdByUserId: int?, relation(parent=users, onDelete=SetNull)`. Update FK target from `cms_documents` to `documents` in `documentId` field.

- [ ] **Step 7: Update document_crdt_operation.spy.yaml**

Update FK targets: `cms_documents` → `documents`, `cms_users` → `users`. Update index names.

- [ ] **Step 8: Update document_crdt_snapshot.spy.yaml**

Update FK target: `cms_documents` → `documents`. Update index names.

- [ ] **Step 9: Update DTO models**

Update `cms_api_token_with_value.spy.yaml`:
```yaml
class: ApiTokenWithValue
fields:
  token: ApiToken
  plaintextToken: String
```

Update `document_list.spy.yaml`:
```yaml
class: DocumentList
fields:
  documents: List<protocol:Document>
  total: int
  page: int
  pageSize: int
```

`document_version_list.spy.yaml`, `document_version_with_operations.spy.yaml`, `document_version_list_with_operations.spy.yaml` — no changes needed (they reference `DocumentVersion` and `DocumentCrdtOperation` which keep their names).

- [ ] **Step 10: Delete cloud-only model files**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server
rm lib/src/models/cms_client.spy.yaml
rm lib/src/models/cms_deployment.spy.yaml
rm lib/src/models/cms_client_list.spy.yaml
rm lib/src/models/client_with_token.spy.yaml
```

- [ ] **Step 11: Delete cloud-only endpoints, web routes, and services BEFORE generate**

**CRITICAL:** These files reference types (`CmsClient`, `CmsDeployment`) from deleted YAML models. Serverpod's code generator parses endpoint Dart files, so these MUST be deleted before `serverpod generate` or generation will fail.

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server
# Cloud endpoints
rm lib/src/endpoints/cms_client_endpoint.dart
rm lib/src/endpoints/deployment_endpoint.dart
# Cloud web routes
rm lib/src/web/routes/deployment_upload.dart
rm lib/src/web/routes/deployment_utils.dart
rm lib/src/web/routes/preview_route.dart
rm lib/src/web/routes/subdomain_router.dart
# Cloud services
rm lib/src/services/deployment_storage.dart
```

- [ ] **Step 12: Run serverpod generate**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && serverpod generate`
Expected: Generation succeeds with no errors. Generated code in `lib/src/generated/` is updated with new class names.

- [ ] **Step 13: Commit**

```bash
git add -A
git commit -m "refactor: rename models, drop Cms prefix, clientId → tenantId"
```

---

### Task 3: Update server.dart

**Files:**
- Modify: `dart_desk_be_server/lib/server.dart`

- [ ] **Step 1: Update imports and admin module registration**

Remove cloud-related imports and code:
- Remove `import 'src/web/routes/deployment_upload.dart'`
- Remove `import 'src/web/routes/preview_route.dart'`
- Remove `import 'src/web/routes/subdomain_router.dart'`
- Remove `import 'src/services/deployment_storage.dart'`
- Remove `late DeploymentStorage deploymentStorage;` global
- Remove `deploymentStorage = LocalDeploymentStorage();` initialization
- Remove deployment upload route registration (`DeploymentUploadRoute`)
- Remove preview route registration (`PreviewRoute`)
- Remove subdomain middleware registration (`subdomainMiddleware`)
- Remove `CmsClient`, `CmsDeployment`, `ClientWithToken` from admin registry
- Update remaining model names (`CmsDocument` → `Document`, `CmsUser` → `User`, etc.)

```dart
void _registerAdminModule() {
  admin.configureAdminModule((registry) {
    registry.register<Document>();
    registry.register<DocumentData>();
    registry.register<User>();
    registry.register<DocumentVersion>();
    registry.register<MediaAsset>();
    registry.register<DocumentCrdtOperation>();
    registry.register<DocumentCrdtSnapshot>();
    registry.register<ApiToken>();

    developer.log(
        '[Admin] Module registered with ${registry.registeredResourceMetadata.length} resources');
  });
}
```

- [ ] **Step 2: Update _seedAdminUser to create User record**

After creating the Serverpod auth user, also create a `User` record with `tenantId: null`, `role: 'admin'`:

```dart
Future<void> _seedAdminUser() async {
  final session = await Serverpod.instance.createSession();

  try {
    final emailAdmin = AuthServices.instance.emailIdp.admin;
    final email = Serverpod.instance.getPassword('adminEmail');
    final password = Serverpod.instance.getPassword('adminPassword');

    if (email == null || password == null) {
      developer.log(
          '[Admin] ADMIN_EMAIL and ADMIN_PASSWORD env vars not set, skipping admin seed');
      return;
    }

    // Check if the email account already exists
    final existingAccount = await emailAdmin.findAccount(
      session,
      email: email,
    );

    UuidValue authUserId;

    if (existingAccount == null) {
      // Create a new auth user and email authentication
      final authUser = await AuthServices.instance.authUsers.create(session);
      authUserId = authUser.id;

      await emailAdmin.createEmailAuthentication(
        session,
        authUserId: authUserId,
        email: email,
        password: password,
      );
      developer.log('[Admin] Created admin user: $email');
    } else {
      authUserId = existingAccount.authUserId;
      developer.log('[Admin] Admin user already exists: $email');
    }

    // Ensure admin scope is set
    await AuthServices.instance.authUsers.update(
      session,
      authUserId: authUserId,
      scopes: {Scope.admin},
    );

    // Ensure User record exists (single-tenant: tenantId = null)
    final existingUser = await User.db.findFirstRow(
      session,
      where: (t) => t.serverpodUserId.equals(authUserId.toString()),
    );
    if (existingUser == null) {
      await User.db.insertRow(session, User(
        tenantId: null,
        email: email,
        name: 'Admin',
        role: 'admin',
        isActive: true,
        serverpodUserId: authUserId.toString(),
      ));
      developer.log('[Admin] Created User record for admin');
    }
  } catch (e) {
    developer.log('[Admin] Error seeding admin user: $e');
  } finally {
    await session.close();
  }
}
```

- [ ] **Step 3: Verify compilation**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && dart analyze lib/server.dart`
Expected: No issues

- [ ] **Step 4: Commit**

```bash
git add dart_desk_be_server/lib/server.dart
git commit -m "refactor: update server.dart for single-tenant core"
```

---

### Task 4: Update DocumentEndpoint

**Files:**
- Modify: `dart_desk_be_server/lib/src/endpoints/document_endpoint.dart`

- [ ] **Step 1: Update all model references and add tenancy**

Key changes throughout the file:
- `CmsDocument` → `Document`
- `CmsUser` → `User`
- `.clientId.equals(cmsUser.clientId)` → tenancy-aware filter using `DartDeskTenancy.resolveTenantId`
- `_getCmsUser` → `_getUser` with tenancy-aware lookup
- SQL query in `getDocumentTypes`: `cms_documents` → `documents`

Replace `_getCmsUser` helper:

```dart
Future<User> _getUser(Session session, String userIdentifier) async {
  final tenantId = await DartDeskTenancy.resolveTenantId(session);
  final user = await User.db.findFirstRow(
    session,
    where: (t) {
      var expr = t.serverpodUserId.equals(userIdentifier);
      if (tenantId != null) {
        expr = expr & t.tenantId.equals(tenantId);
      }
      return expr;
    },
  );
  if (user == null) {
    throw Exception('User not found for authenticated user');
  }
  return user;
}
```

Update all `clientId` references in queries to use `tenantId`:
- In `getDocuments`: `t.clientId.equals(cmsUser.clientId)` → `(tenantId != null ? t.tenantId.equals(tenantId) : t.tenantId.isNull())`
- In `createDocument`: `clientId: cmsUser.clientId` → `tenantId: tenantId` (get from `DartDeskTenancy.resolveTenantId`)
- In `updateDocument`/`deleteDocument`: access check `existing.clientId != cmsUser.clientId` → compare `tenantId`
- In `getDocumentCount`: same pattern

Add import at top:
```dart
import '../tenancy.dart';
```

- [ ] **Step 2: Verify compilation**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && dart analyze lib/src/endpoints/document_endpoint.dart`

- [ ] **Step 3: Commit**

```bash
git add dart_desk_be_server/lib/src/endpoints/document_endpoint.dart
git commit -m "refactor: update DocumentEndpoint for single-tenant core"
```

---

### Task 5: Rewrite UserEndpoint

**Files:**
- Modify: `dart_desk_be_server/lib/src/endpoints/user_endpoint.dart`

- [ ] **Step 1: Rewrite for single-tenant**

The endpoint simplifies dramatically. Remove all `clientSlug`/`apiToken` params and `_validateApiToken` logic. The new `ensureUser` takes no client params — it just finds or creates a `User` by `serverpodUserId`.

```dart
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../tenancy.dart';

/// Endpoint for managing users
class UserEndpoint extends Endpoint {
  /// Ensure a user exists for the authenticated Serverpod user.
  /// Creates one automatically on first login.
  Future<User> ensureUser(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final userIdentifier = authInfo.userIdentifier;
    final tenantId = await DartDeskTenancy.resolveTenantId(session);

    // Check if User already exists
    final existing = await User.db.findFirstRow(
      session,
      where: (t) {
        var expr = t.serverpodUserId.equals(userIdentifier);
        if (tenantId != null) {
          expr = expr & t.tenantId.equals(tenantId);
        } else {
          expr = expr & t.tenantId.isNull();
        }
        return expr;
      },
    );
    if (existing != null) return existing;

    // Get user profile from serverpod_auth_core profile table
    String? email;
    String? name;
    try {
      final profileRows = await session.db.unsafeQuery(
        'SELECT "email", "fullName" FROM "serverpod_auth_core_profile" '
        'WHERE "authUserId" = \'$userIdentifier\' LIMIT 1',
      );
      if (profileRows.isNotEmpty) {
        email = profileRows.first[0] as String?;
        name = profileRows.first[1] as String?;
      }
    } catch (_) {}

    // Create the User
    final newUser = User(
      tenantId: tenantId,
      email: email ?? userIdentifier,
      name: name,
      role: 'viewer',
      isActive: true,
      serverpodUserId: userIdentifier,
    );

    try {
      return await User.db.insertRow(session, newUser);
    } catch (e) {
      // Handle duplicate key race condition
      final retried = await User.db.findFirstRow(
        session,
        where: (t) =>
            t.serverpodUserId.equals(userIdentifier) &
            (tenantId != null ? t.tenantId.equals(tenantId) : t.tenantId.isNull()),
      );
      if (retried != null) return retried;
      rethrow;
    }
  }

  /// Get the current user for the authenticated session.
  Future<User?> getCurrentUser(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final tenantId = await DartDeskTenancy.resolveTenantId(session);

    return await User.db.findFirstRow(
      session,
      where: (t) {
        var expr = t.serverpodUserId.equals(authInfo.userIdentifier);
        if (tenantId != null) {
          expr = expr & t.tenantId.equals(tenantId);
        }
        return expr;
      },
    );
  }

  /// Get count of users (for overview stats).
  Future<int> getUserCount(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final tenantId = await DartDeskTenancy.resolveTenantId(session);

    return await User.db.count(
      session,
      where: (t) {
        var expr = t.isActive.equals(true);
        if (tenantId != null) {
          expr = expr & t.tenantId.equals(tenantId);
        }
        return expr;
      },
    );
  }
}
```

**Note:** `getUserClients`, `getCurrentUserBySlug`, `getClientUserCount` — these are multi-tenant/cloud concerns. They move to the cloud plugin (Task 8). `_validateApiToken` also moves to cloud plugin (it validates `CmsClient` API tokens).

- [ ] **Step 2: Verify compilation**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && dart analyze lib/src/endpoints/user_endpoint.dart`

- [ ] **Step 3: Commit**

```bash
git add dart_desk_be_server/lib/src/endpoints/user_endpoint.dart
git commit -m "refactor: rewrite UserEndpoint for single-tenant core"
```

---

### Task 6: Update remaining endpoints

**Files:**
- Modify: `dart_desk_be_server/lib/src/endpoints/cms_api_token_endpoint.dart`
- Modify: `dart_desk_be_server/lib/src/endpoints/media_endpoint.dart`
- Modify: `dart_desk_be_server/lib/src/endpoints/document_collaboration_endpoint.dart`
- Delete: `dart_desk_be_server/lib/src/endpoints/cms_client_endpoint.dart`
- Delete: `dart_desk_be_server/lib/src/endpoints/deployment_endpoint.dart`

- [ ] **Step 1: Update CmsApiTokenEndpoint**

Rename class to `ApiTokenEndpoint`. Replace all:
- `CmsApiToken` → `ApiToken`
- `CmsApiTokenWithValue` → `ApiTokenWithValue`
- `CmsUser` → `User`
- `.clientId.equals(clientId)` → tenantId-aware filter
- `_requireUser(session, clientId)` → `_requireUser(session)` (resolve tenantId internally)

Add `import '../tenancy.dart';`

Update `_requireUser`:
```dart
Future<User> _requireUser(Session session) async {
  final authInfo = session.authenticated;
  if (authInfo == null) {
    throw Exception('User must be authenticated');
  }

  final tenantId = await DartDeskTenancy.resolveTenantId(session);

  final user = await User.db.findFirstRow(
    session,
    where: (t) {
      var expr = t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.isActive.equals(true);
      if (tenantId != null) {
        expr = expr & t.tenantId.equals(tenantId);
      }
      return expr;
    },
  );
  if (user == null) {
    throw Exception('User not found');
  }
  return user;
}
```

Update method signatures — remove `clientId` parameter from `getTokens`, `createToken`. Instead, resolve tenantId from session:
```dart
Future<List<ApiToken>> getTokens(Session session) async {
  await _requireUser(session);
  final tenantId = await DartDeskTenancy.resolveTenantId(session);
  return await ApiToken.db.find(
    session,
    where: (t) => tenantId != null ? t.tenantId.equals(tenantId) : t.tenantId.isNull(),
    orderBy: (t) => t.createdAt,
    orderDescending: true,
  );
}
```

Same pattern for `createToken` — remove `clientId` param, get `tenantId` from session.

- [ ] **Step 2: Update MediaEndpoint**

Replace:
- `CmsUser` → `User`
- `cmsUser.clientId` → tenantId from `DartDeskTenancy.resolveTenantId`
- `clientId: cmsUser.clientId` → `tenantId: tenantId`

Add `import '../tenancy.dart';`

Extract shared auth+user lookup:
```dart
Future<(User, int?)> _authenticateAndResolve(Session session) async {
  final authInfo = session.authenticated;
  if (authInfo == null) {
    throw Exception('User must be authenticated');
  }
  final user = await User.db.findFirstRow(
    session,
    where: (t) => t.serverpodUserId.equals(authInfo.userIdentifier),
  );
  if (user == null) {
    throw Exception('User not found for authenticated user');
  }
  final tenantId = await DartDeskTenancy.resolveTenantId(session);
  return (user, tenantId);
}
```

- [ ] **Step 3: Update DocumentCollaborationEndpoint**

Same pattern: `CmsUser` → `User`, `CmsDocument` → `Document`, `clientId` → `tenantId`. Add tenancy import.

- [ ] **Step 4: Run serverpod generate and verify compilation**

Note: Cloud endpoint files (`cms_client_endpoint.dart`, `deployment_endpoint.dart`) were already deleted in Task 2 Step 11.

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && serverpod generate && dart analyze`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor: update all endpoints for single-tenant core"
```

---

### Task 7: Update tests

**Files:**
- Modify: `dart_desk_be_server/test/integration/helpers/test_data_factory.dart`
- Modify: `dart_desk_be_server/test/integration/document_endpoint_test.dart`
- Modify: `dart_desk_be_server/test/integration/user_endpoint_test.dart`
- Modify: `dart_desk_be_server/test/integration/cms_api_token_endpoint_test.dart`
- Modify: `dart_desk_be_server/test/integration/media_endpoint_test.dart`
- Modify: `dart_desk_be_server/test/integration/document_crdt_test.dart`
- Modify: `dart_desk_be_server/test/integration/document_versioning_test.dart`
- Modify: `dart_desk_be_server/test/integration/studio_config_endpoint_test.dart`
- Delete: `dart_desk_be_server/test/integration/multi_tenancy_test.dart`
- Delete: `dart_desk_be_server/test/integration/cms_client_endpoint_test.dart`

- [ ] **Step 1: Update TestDataFactory**

Remove `createTestClient` and client-dependent helpers. Simplify `authenticatedSession`. Add `ensureTestUser` that calls the new simplified `ensureUser`:

```dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_desk_be_server/server.dart' as server;
import 'package:dart_desk_be_server/src/generated/protocol.dart';
import 'package:dart_desk_be_server/src/services/document_crdt_service.dart';

import '../test_tools/serverpod_test_tools.dart';

class TestDataFactory {
  final TestSessionBuilder sessionBuilder;
  final TestEndpoints endpoints;

  TestDataFactory({
    required this.sessionBuilder,
    required this.endpoints,
  });

  static void initializeCrdtService() {
    server.documentCrdtService = DocumentCrdtService('test-node');
  }

  TestSessionBuilder authenticatedSession({
    String userIdentifier = 'test-user-1',
  }) {
    return sessionBuilder.copyWith(
      authentication: AuthenticationOverride.authenticationInfo(
        userIdentifier,
        {},
      ),
    );
  }

  /// Ensures a User record exists for the authenticated test user.
  Future<User> ensureTestUser() async {
    final authed = authenticatedSession();
    return await endpoints.user.ensureUser(authed);
  }

  Future<Document> createTestDocument({
    String documentType = 'test_type',
    String title = 'Test Document',
    Map<String, dynamic> data = const {'field1': 'value1'},
    String? slug,
    bool isDefault = false,
  }) async {
    final authed = authenticatedSession();
    return await endpoints.document.createDocument(
      authed,
      documentType,
      title,
      data,
      slug: slug,
      isDefault: isDefault,
    );
  }

  Future<DocumentVersion> createTestVersion(
    int documentId, {
    DocumentVersionStatus status = DocumentVersionStatus.draft,
    String? changeLog,
  }) async {
    final authed = authenticatedSession();
    return await endpoints.document.createDocumentVersion(
      authed,
      documentId,
      status: status,
      changeLog: changeLog,
    );
  }

  static Map<String, dynamic> get complexTestData => {
        'title': 'Test Page',
        'isActive': true,
        'count': 42,
        'rating': 4.5,
        'tags': ['alpha', 'beta', 'gamma'],
        'metadata': {
          'author': 'Jane',
          'version': 3,
          'published': true,
        },
        'items': [
          {'name': 'Item 1', 'price': 9.99},
          {'name': 'Item 2', 'price': 19.99},
        ],
        'emptyList': <dynamic>[],
        'emptyMap': <String, dynamic>{},
        'nullableField': null,
      };

  Future<MediaAsset> uploadTestImage({
    String fileName = 'test_image.png',
  }) async {
    final authed = authenticatedSession();
    final pngBytes = <int>[
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
      0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41,
      0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
      0x00, 0x00, 0x02, 0x00, 0x01, 0xE2, 0x21, 0xBC,
      0x33, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
      0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
    final byteData = ByteData.sublistView(Uint8List.fromList(pngBytes));
    // Note: uploadImage signature may change — adapt to match updated endpoint
    return await endpoints.media.uploadImage(
      authed, fileName, byteData, 1, 1, false, 'L00000fQfQfQfQfQfQfQfQfQfQ', 'testhash',
    );
  }

  Future<MediaAsset> uploadTestFile({
    String fileName = 'test_file.txt',
    String content = 'test file content',
  }) async {
    final authed = authenticatedSession();
    final bytes = utf8.encode(content);
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return await endpoints.media.uploadFile(authed, fileName, byteData);
  }
}
```

- [ ] **Step 2: Update document_endpoint_test.dart**

In `setUp()`, replace:
```dart
testClient = await factory.createTestClient(slug: 'test-client-doc');
final authed = factory.authenticatedSession();
await endpoints.user.ensureUser(authed, 'test-client-doc', testClient.apiToken);
```
With:
```dart
await factory.ensureTestUser();
```

Remove the `late ClientWithToken testClient;` declaration. Update all type references: `CmsDocument` → `Document`.

- [ ] **Step 3: Update user_endpoint_test.dart**

Rewrite tests for the simplified `ensureUser(session)` (no clientSlug/apiToken). Remove `getUserClients`, `getCurrentUserBySlug`, `getClientUserCount` tests (those are cloud concerns). Update type references.

- [ ] **Step 4: Update api token test**

Adapt `cms_api_token_endpoint_test.dart` for the renamed `ApiTokenEndpoint`. Remove `clientId` params from method calls. Update setUp to use `ensureTestUser()` instead of creating a client.

- [ ] **Step 5: Update remaining test files**

- `media_endpoint_test.dart`: Remove client setup, use `ensureTestUser()`, update type refs
- `document_crdt_test.dart`: Same pattern
- `document_versioning_test.dart`: Same pattern
- `studio_config_endpoint_test.dart`: Minimal changes

- [ ] **Step 6: Delete cloud-only test files**

```bash
rm dart_desk_be_server/test/integration/multi_tenancy_test.dart
rm dart_desk_be_server/test/integration/cms_client_endpoint_test.dart
```

- [ ] **Step 7: Regenerate test tools and run tests**

```bash
cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server
serverpod generate
dart test
```

Expected: All remaining tests pass.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "test: update all tests for single-tenant core"
```

---

### Task 8: Create database migration

**Files:**
- New migration in: `dart_desk_be_server/migrations/`

- [ ] **Step 1: Create migration**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && serverpod create-migration`

- [ ] **Step 2: Review generated migration SQL**

Verify it includes:
- Table renames (`cms_documents` → `documents`, `cms_users` → `users`, etc.)
- Column rename `client_id` → `tenant_id`
- `tenant_id` is nullable
- `created_by_user_id` is nullable
- FK constraints to `cms_clients` are removed (cloud plugin will re-add)
- `cms_clients` and `cms_deployments` tables are dropped (or left — cloud plugin will own them)
- Index names updated

**Important:** If the auto-generated migration doesn't handle COALESCE indexes, manually edit the migration SQL to add:
```sql
CREATE UNIQUE INDEX documents_tenant_type_slug_idx
  ON documents (COALESCE(tenant_id, 0), document_type, slug);

CREATE UNIQUE INDEX users_tenant_email_idx
  ON users (COALESCE(tenant_id, 0), email);
```

- [ ] **Step 3: Run tests with migration**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && dart test`
Expected: All tests pass with the new migration applied.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "feat: add database migration for single-tenant core"
```

---

### Task 9: Update dart_desk_be_client

The generated client package needs to be regenerated and any manual code (like `dart_desk_auth.dart`) updated.

**Files:**
- Modify: `dart_desk_be_client/lib/src/dart_desk_auth.dart`
- Regenerated: `dart_desk_be_client/lib/src/protocol/` (auto-generated by `serverpod generate`)

- [ ] **Step 1: Regenerate client**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && serverpod generate`

This updates the client package with the new model names and endpoint signatures.

- [ ] **Step 2: Update dart_desk_auth.dart**

This file calls `_client.user.ensureUser(widget.clientId, widget.apiToken)`. Update to match the new simplified signature: `_client.user.ensureUser()`.

Also remove `clientId` and `apiToken` fields from the widget (those are cloud concerns). This is a temporary update — the full `DartDeskApp` refactor is in Spec 2.

For now, keep the widget functional by removing the cloud params and simplifying:

```dart
// In _ensureUser()
await _client.user.ensureUser();

// In _FlutterCmsAuthProvider — remove clientId and apiToken fields
// In FlutterCmsAuthContext — remove cmsClientId and cmsApiToken getters
```

- [ ] **Step 3: Verify client package compiles**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_client && dart analyze`

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: update client package for single-tenant core"
```

---

### Task 10: Placeholder for dart_desk_cloud package (future work)

This task documents what the cloud plugin will contain but does NOT implement it. Implementation is tracked separately.

**NOT IMPLEMENTED — reference only:**

The `dart_desk_cloud` package will contain:
- `Tenant` model (formerly `CmsClient`)
- `Deployment` model (formerly `CmsDeployment`)
- `TenantList`, `TenantWithToken` DTOs
- Tenant CRUD endpoints (from `cms_client_endpoint.dart`)
- Deployment endpoints (from `deployment_endpoint.dart`)
- `CloudTenantResolver` (resolves tenant from request headers)
- `DartDeskCloud.register(pod)` entry point
- Migration adding FK constraint from `tenantId` → `tenants.id`
- Multi-tenancy tests (from `multi_tenancy_test.dart`)
- Client endpoint tests (from `cms_client_endpoint_test.dart`)

- [ ] **Step 1: Document the cloud plugin TODO**

No code to write. This task is complete once the core extraction is done. The cloud plugin will be a separate implementation effort.

- [ ] **Step 2: Final commit**

```bash
git add -A
git commit -m "docs: multi-tenancy extraction complete, cloud plugin deferred"
```
