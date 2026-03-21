# External Auth Strategy & DartDeskApp Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Allow external auth providers (Firebase, Clerk, Auth0) alongside Serverpod's built-in IDP, and refactor the client-side API into a clean `DartDeskApp` widget.

**Architecture:** Add `ExternalAuthStrategy` interface and `DartDeskAuth` registry on the server. Endpoints call `DartDeskAuth.authenticateRequest()` which checks Serverpod IDP first, then tries external strategies. Auto-creates `User` records on first external auth. On the client, replace `FlutterCmsAuth` + `CmsStudioApp` with a unified `DartDeskApp` widget offering both built-in and external auth constructors.

**Tech Stack:** Dart, Serverpod 3.4.3, Flutter (shadcn_ui, signals, zenrouter), serverpod_test

**Spec:** `docs/superpowers/specs/2026-03-21-external-auth-strategy-design.md`

---

## Scope

This plan has two independent subsystems:

- **Server-side** (Tasks 1–6): External auth types, DartDeskAuth, User model update, endpoint migration, tests, migration — all in `dart_desk_be_server/`
- **Client-side** (Tasks 7–12): DartDeskConfig, DartDesk InheritedWidget, DartDeskApp widget, renames — all in `dart_desk/packages/dart_desk/` and `dart_desk_be_client/`

Server-side tasks can be implemented and verified independently. Client-side tasks depend on the regenerated client package from server Task 5.

---

## File Structure

### New files
- `dart_desk_be_server/lib/src/auth/external_auth_strategy.dart` — `ExternalAuthStrategy` abstract class + `ExternalAuthUser` type
- `dart_desk_be_server/lib/src/auth/dart_desk_auth.dart` — `DartDeskAuth` registry + `authenticateRequest()` + `_findOrCreateUser()`
- `dart_desk_be_server/test/integration/external_auth_test.dart` — integration tests for external auth flow
- `dart_desk/packages/dart_desk/lib/src/studio/dart_desk_app.dart` — `DartDeskApp` widget (replaces `CmsStudioApp` + `FlutterCmsAuth`)
- `dart_desk/packages/dart_desk/lib/src/studio/dart_desk_config.dart` — `DartDeskConfig` class
- `dart_desk/packages/dart_desk/lib/src/studio/dart_desk.dart` — `DartDesk` InheritedWidget

### Modified files
- `dart_desk_be_server/lib/src/models/cms_user.spy.yaml` — add `externalId: String?` and `externalProvider: String?` fields + new index
- `dart_desk_be_server/lib/src/endpoints/document_endpoint.dart` — replace `_getUser` with `DartDeskAuth.authenticateRequest()`
- `dart_desk_be_server/lib/src/endpoints/user_endpoint.dart` — remove `ensureUser` (implicit now), update `getCurrentUser`/`getUserCount`
- `dart_desk_be_server/lib/src/endpoints/cms_api_token_endpoint.dart` — use `DartDeskAuth.authenticateRequest()`
- `dart_desk_be_server/lib/src/endpoints/media_endpoint.dart` — use `DartDeskAuth.authenticateRequest()`
- `dart_desk_be_server/lib/src/endpoints/document_collaboration_endpoint.dart` — use `DartDeskAuth.authenticateRequest()`
- `dart_desk_be_server/lib/server.dart` — add `DartDeskAuth` initialization/disposal hooks
- `dart_desk_be_server/test/integration/helpers/test_data_factory.dart` — adapt for removed `ensureUser`
- `dart_desk_be_client/lib/src/dart_desk_auth.dart` — rewrite as `DartDeskApp` (or delete and move to frontend package)
- `dart_desk/packages/dart_desk/lib/studio.dart` — update exports
- `dart_desk/packages/dart_desk/lib/src/studio/cms_studio_app.dart` — **deleted** (replaced by `dart_desk_app.dart`)
- `dart_desk/packages/dart_desk/lib/src/data/cms_data_source.dart` — rename class `CmsDataSource` → `DataSource`
- `dart_desk/packages/dart_desk_annotation/lib/src/config.dart` — rename `CmsDocumentType` → `DocumentType`
- `dart_desk/packages/dart_desk/lib/src/studio/components/common/cms_document_type_decoration.dart` — rename `CmsDocumentTypeDecoration` → `DocumentTypeDecoration`

### Deleted files
- `dart_desk_be_server/lib/src/endpoints/user_endpoint.dart` — `ensureUser` removed; `getCurrentUser`/`getUserCount` move into `DartDeskAuth` or a simplified endpoint
- `dart_desk_be_server/test/integration/user_endpoint_test.dart` — rewritten for new auth flow

---

## Tasks

### Task 1: Add ExternalAuthStrategy and ExternalAuthUser types

**Files:**
- Create: `dart_desk_be_server/lib/src/auth/external_auth_strategy.dart`

- [ ] **Step 1: Create auth directory and types file**

```dart
// dart_desk_be_server/lib/src/auth/external_auth_strategy.dart
import 'package:serverpod/serverpod.dart';

/// User data returned by external auth strategies.
class ExternalAuthUser {
  final String externalId;
  final String email;
  final String? name;
  final Map<String, dynamic>? metadata;

  const ExternalAuthUser({
    required this.externalId,
    required this.email,
    this.name,
    this.metadata,
  });
}

/// Interface for external auth providers (Firebase, Clerk, Auth0, etc.).
///
/// Strategies are tried in registration order. First non-null result wins.
/// Return null for unrecognized tokens (wrong format for this strategy).
/// Only throw for unexpected errors (network failure, SDK crash) —
/// thrown exceptions fail the request immediately, skipping remaining strategies.
abstract class ExternalAuthStrategy {
  /// Unique name for this strategy (e.g., 'firebase', 'clerk').
  String get name;

  /// Called once on server startup for setup (fetch JWKS keys, init SDK, etc.).
  Future<void> initialize() async {}

  /// Called on server shutdown for cleanup (close connections, etc.).
  Future<void> dispose() async {}

  /// Verify the request and return a user, or null to pass to next strategy.
  Future<ExternalAuthUser?> authenticate(
    Map<String, String> headers,
    Session session,
  );
}
```

- [ ] **Step 2: Verify file compiles**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && dart analyze lib/src/auth/external_auth_strategy.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add dart_desk_be_server/lib/src/auth/external_auth_strategy.dart
git commit -m "feat: add ExternalAuthStrategy interface and ExternalAuthUser type"
```

---

### Task 2: Add DartDeskAuth registry

**Files:**
- Create: `dart_desk_be_server/lib/src/auth/dart_desk_auth.dart`

- [ ] **Step 1: Create DartDeskAuth class**

```dart
// dart_desk_be_server/lib/src/auth/dart_desk_auth.dart
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../tenancy.dart';
import 'external_auth_strategy.dart';

/// Central authentication registry for Dart Desk.
///
/// Checks Serverpod's built-in IDP auth first, then tries external strategies
/// in registration order. Auto-creates User records on first external auth.
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

  /// Authenticate the current request.
  ///
  /// 1. Checks Serverpod built-in IDP auth (session.authenticated)
  /// 2. If null, tries external strategies in order
  /// 3. First non-null ExternalAuthUser wins → find or create User
  /// 4. Returns null if all strategies return null (unauthenticated)
  static Future<User?> authenticateRequest(Session session) async {
    // 1. Check Serverpod built-in auth
    final authInfo = session.authenticated;
    if (authInfo != null) {
      final tenantId = await DartDeskTenancy.resolveTenantId(session);
      return User.db.findFirstRow(
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

    // 2. Try external strategies
    if (_strategies.isEmpty) return null;

    final headers = <String, String>{};
    session.httpRequest.headers.forEach((name, values) {
      if (values.isNotEmpty) {
        headers[name] = values.first;
      }
    });

    for (final strategy in _strategies) {
      final extUser = await strategy.authenticate(headers, session);
      if (extUser != null) {
        return _findOrCreateUser(session, extUser, strategy.name);
      }
    }

    return null; // unauthenticated
  }

  /// Find existing User by external ID or auto-create one.
  static Future<User> _findOrCreateUser(
    Session session,
    ExternalAuthUser extUser,
    String providerName,
  ) async {
    final tenantId = await DartDeskTenancy.resolveTenantId(session);

    // Try to find existing user by external identity
    var user = await User.db.findFirstRow(
      session,
      where: (t) =>
          t.externalId.equals(extUser.externalId) &
          t.externalProvider.equals(providerName) &
          (tenantId != null
              ? t.tenantId.equals(tenantId)
              : t.tenantId.equals(null)),
    );

    if (user != null) return user;

    // Determine role: admin if email is in adminEmails list, otherwise viewer
    final role = _adminEmails.contains(extUser.email) ? 'admin' : 'viewer';

    // Auto-create user
    user = User(
      tenantId: tenantId,
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
            (tenantId != null
                ? t.tenantId.equals(tenantId)
                : t.tenantId.equals(null)),
      );
      if (retried != null) return retried;
      rethrow;
    }
  }
}
```

- [ ] **Step 2: Verify file compiles**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && dart analyze lib/src/auth/dart_desk_auth.dart`

Note: This will fail until Task 3 adds `externalId`/`externalProvider` fields to the User model. That's expected. Verify the Dart syntax is valid and imports resolve (except the missing model fields).

- [ ] **Step 3: Commit (may need to wait for Task 3)**

```bash
git add dart_desk_be_server/lib/src/auth/
git commit -m "feat: add DartDeskAuth registry with external strategy support"
```

---

### Task 3: Update User model with external auth fields + migration

**Files:**
- Modify: `dart_desk_be_server/lib/src/models/cms_user.spy.yaml`

- [ ] **Step 1: Add externalId and externalProvider fields**

Replace entire contents of `cms_user.spy.yaml` with:
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
  externalId: String?
  externalProvider: String?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now
indexes:
  users_tenant_email_idx:
    fields: tenantId, email
    unique: true
  users_external_id_idx:
    fields: externalId, externalProvider, tenantId
    unique: true
  users_tenant_id_idx:
    fields: tenantId
  users_serverpod_user_id_idx:
    fields: serverpodUserId
  users_is_active_idx:
    fields: isActive
```

- [ ] **Step 2: Run serverpod generate**

Run: `cd /Users/vietthangvunguyen/Workspace/dart_desk_workspace/dart_desk_be/dart_desk_be_server && serverpod generate`
Expected: Generation succeeds

- [ ] **Step 3: Create migration**

Run: `serverpod create-migration --force`

- [ ] **Step 4: Review migration SQL**

Verify it contains:
- `ALTER TABLE "users" ADD COLUMN "externalId" text;`
- `ALTER TABLE "users" ADD COLUMN "externalProvider" text;`
- `CREATE UNIQUE INDEX "users_external_id_idx" ON "users" ("externalId", "externalProvider", "tenantId");`

- [ ] **Step 5: Verify DartDeskAuth now compiles**

Run: `dart analyze lib/src/auth/`
Expected: No issues

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: add externalId and externalProvider fields to User model"
```

---

### Task 4: Update all endpoints to use DartDeskAuth.authenticateRequest()

**Files:**
- Modify: `dart_desk_be_server/lib/src/endpoints/document_endpoint.dart`
- Modify: `dart_desk_be_server/lib/src/endpoints/user_endpoint.dart`
- Modify: `dart_desk_be_server/lib/src/endpoints/cms_api_token_endpoint.dart`
- Modify: `dart_desk_be_server/lib/src/endpoints/media_endpoint.dart`
- Modify: `dart_desk_be_server/lib/src/endpoints/document_collaboration_endpoint.dart`
- Modify: `dart_desk_be_server/lib/server.dart`

- [ ] **Step 1: Update DocumentEndpoint**

Replace `_getUser` helper with `DartDeskAuth.authenticateRequest()`:

```dart
import '../auth/dart_desk_auth.dart';

// Replace _getUser calls with:
Future<User> _requireAuth(Session session) async {
  final user = await DartDeskAuth.authenticateRequest(session);
  if (user == null) {
    throw Exception('User must be authenticated');
  }
  return user;
}
```

Replace all `_getUser(session, authInfo.userIdentifier)` calls with `_requireAuth(session)`. Remove the inline `session.authenticated` checks since `DartDeskAuth.authenticateRequest()` handles both IDP and external auth.

- [ ] **Step 2: Simplify UserEndpoint**

Remove `ensureUser` — user creation is now implicit via `DartDeskAuth.authenticateRequest()` → `_findOrCreateUser()`. Keep `getCurrentUser` and `getUserCount`, updated to use `DartDeskAuth`:

```dart
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../auth/dart_desk_auth.dart';

class UserEndpoint extends Endpoint {
  /// Get the current authenticated user.
  /// For Serverpod IDP: returns existing User (must exist via seed or prior ensureUser).
  /// For external auth: auto-creates User on first call.
  Future<User?> getCurrentUser(Session session) async {
    return await DartDeskAuth.authenticateRequest(session);
  }

  /// Get count of active users in the current tenant.
  Future<int> getUserCount(Session session) async {
    final user = await DartDeskAuth.authenticateRequest(session);
    if (user == null) {
      throw Exception('User must be authenticated');
    }
    return await User.db.count(
      session,
      where: (t) {
        var expr = t.isActive.equals(true);
        if (user.tenantId != null) {
          expr = expr & t.tenantId.equals(user.tenantId);
        }
        return expr;
      },
    );
  }
}
```

- [ ] **Step 3: Update ApiTokenEndpoint, MediaEndpoint, DocumentCollaborationEndpoint**

Same pattern: replace inline auth checks + `_requireUser` with `DartDeskAuth.authenticateRequest()`.

- [ ] **Step 4: Add DartDeskAuth lifecycle to server.dart**

After `pod.start()`, add:
```dart
await DartDeskAuth.initialize();
```

In the shutdown hook (if one exists), add `await DartDeskAuth.dispose();`.

- [ ] **Step 5: Run serverpod generate (endpoint signatures changed)**

Run: `serverpod generate && dart analyze lib/`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor: migrate all endpoints to DartDeskAuth.authenticateRequest()"
```

---

### Task 5: Write integration tests for external auth flow

**Files:**
- Create: `dart_desk_be_server/test/integration/external_auth_test.dart`
- Modify: `dart_desk_be_server/test/integration/helpers/test_data_factory.dart`

- [ ] **Step 1: Create a test ExternalAuthStrategy**

In the test file, define a mock strategy:

```dart
import 'package:dart_desk_be_server/src/auth/external_auth_strategy.dart';
import 'package:dart_desk_be_server/src/auth/dart_desk_auth.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

/// Test strategy that authenticates requests with 'X-Test-User-Id' header.
class TestAuthStrategy extends ExternalAuthStrategy {
  @override
  String get name => 'test';

  @override
  Future<ExternalAuthUser?> authenticate(
    Map<String, String> headers,
    Session session,
  ) async {
    final userId = headers['x-test-user-id'];
    if (userId == null) return null;
    return ExternalAuthUser(
      externalId: userId,
      email: '$userId@test.com',
      name: 'Test User $userId',
    );
  }
}
```

- [ ] **Step 2: Write tests for DartDeskAuth**

```dart
void main() {
  withServerpod('External auth', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() {
      TestDataFactory.initializeCrdtService();
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      DartDeskAuth.reset();
    });

    tearDown(() {
      DartDeskAuth.reset();
    });

    group('Serverpod IDP auth', () {
      test('authenticates via built-in IDP when User exists', () async {
        // Create user via Serverpod auth (simulate seed)
        final authed = factory.authenticatedSession();
        // getCurrentUser uses DartDeskAuth.authenticateRequest internally
        // First need to insert a User record for this test user
        // ... (insert User with serverpodUserId matching test-user-1)

        final user = await endpoints.user.getCurrentUser(authed);
        expect(user, isNotNull);
      });
    });

    group('external auth', () {
      test('auto-creates User on first external auth', () async {
        DartDeskAuth.configure(
          externalStrategies: [TestAuthStrategy()],
        );

        // TODO: This test requires httpRequest.headers access which
        // serverpod_test may not support directly. May need to test
        // DartDeskAuth._findOrCreateUser more directly or use
        // a session with custom headers.
      });

      test('adminEmails config grants admin role', () async {
        DartDeskAuth.configure(
          externalStrategies: [TestAuthStrategy()],
          adminEmails: ['admin@test.com'],
        );

        // Same caveat about headers in test sessions
      });
    });
  });
}
```

**Note:** Serverpod's test framework (`withServerpod`) creates test sessions without HTTP request context. External auth tests that rely on `session.httpRequest.headers` may need a different approach — either:
1. Test `DartDeskAuth._findOrCreateUser` directly via a public test helper
2. Use the Serverpod IDP path (which works via `session.authenticated`)
3. Write a small integration test that hits the actual HTTP server

For now, focus on testing the IDP path and the `_findOrCreateUser` logic. External strategy integration testing can use the E2E suite.

- [ ] **Step 3: Update TestDataFactory**

Since `ensureUser` is removed, update `ensureTestUser` to insert a User record directly:

```dart
/// Ensures a User record exists for the authenticated test user.
/// Uses DartDeskAuth for Serverpod IDP path.
Future<User> ensureTestUser() async {
  final authed = authenticatedSession();
  final user = await endpoints.user.getCurrentUser(authed);
  if (user != null) return user;

  // If getCurrentUser returns null (no User record yet),
  // insert one directly for testing
  return await User.db.insertRow(
    await _createSession(),
    User(
      tenantId: null,
      email: 'test@example.com',
      name: 'Test User',
      role: 'viewer',
      isActive: true,
      serverpodUserId: 'test-user-1',
    ),
  );
}
```

- [ ] **Step 4: Run tests**

Run: `dart test test/integration/external_auth_test.dart`
Expected: All tests pass

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "test: add integration tests for external auth flow"
```

---

### Task 6: Update existing tests for removed ensureUser

**Files:**
- Modify: `dart_desk_be_server/test/integration/document_endpoint_test.dart`
- Modify: `dart_desk_be_server/test/integration/cms_api_token_endpoint_test.dart`
- Modify: `dart_desk_be_server/test/integration/media_endpoint_test.dart`
- Modify: `dart_desk_be_server/test/integration/document_crdt_test.dart`
- Modify: `dart_desk_be_server/test/integration/document_versioning_test.dart`
- Modify: `dart_desk_be_server/test/integration/user_endpoint_test.dart`

- [ ] **Step 1: Update all setUp blocks**

Replace `await factory.ensureTestUser()` (which called `endpoints.user.ensureUser()`) with the new direct-insert approach. Since `ensureUser` is removed, tests need to seed a User record directly.

- [ ] **Step 2: Update user_endpoint_test.dart**

Rewrite for the new API: `getCurrentUser` returns the authenticated user (creates on external auth, finds on IDP), `getUserCount` returns active user count.

- [ ] **Step 3: Run all tests**

Run: `dart test`
Expected: All tests pass (unit + integration where possible)

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "test: update all tests for DartDeskAuth migration"
```

---

### Task 7: Create DartDeskConfig class (frontend)

**Files:**
- Create: `dart_desk/packages/dart_desk/lib/src/studio/dart_desk_config.dart`

- [ ] **Step 1: Create configuration class**

```dart
// dart_desk/packages/dart_desk/lib/src/studio/dart_desk_config.dart
import 'package:flutter/widgets.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import '../studio/components/common/cms_document_type_decoration.dart';

/// Configuration for the DartDeskApp widget.
class DartDeskConfig {
  final String title;
  final String? subtitle;
  final IconData? icon;
  // theme is handled by DartDeskApp directly, not config
  final List<CmsDocumentType> documentTypes;
  final List<CmsDocumentTypeDecoration> documentTypeDecorations;

  const DartDeskConfig({
    required this.documentTypes,
    required this.documentTypeDecorations,
    this.title = 'Dart Desk',
    this.subtitle,
    this.icon,
  });
}
```

Note: Uses existing `CmsDocumentType` and `CmsDocumentTypeDecoration` names. The rename to `DocumentType`/`DocumentTypeDecoration` happens in Task 12.

- [ ] **Step 2: Verify compiles**

Run: `cd dart_desk/packages/dart_desk && dart analyze lib/src/studio/dart_desk_config.dart`

- [ ] **Step 3: Commit**

```bash
git add dart_desk/packages/dart_desk/lib/src/studio/dart_desk_config.dart
git commit -m "feat: add DartDeskConfig class"
```

---

### Task 8: Create DartDesk InheritedWidget (frontend)

**Files:**
- Create: `dart_desk/packages/dart_desk/lib/src/studio/dart_desk.dart`

- [ ] **Step 1: Create InheritedWidget**

```dart
// dart_desk/packages/dart_desk/lib/src/studio/dart_desk.dart
import 'package:flutter/widgets.dart';
import '../data/cms_data_source.dart';
import 'dart_desk_config.dart';

/// InheritedWidget providing DartDesk context to descendant widgets.
///
/// Access via `DartDesk.of(context)`.
class DartDesk extends InheritedWidget {
  final CmsDataSource dataSource;
  final VoidCallback signOut;
  final DartDeskConfig config;

  const DartDesk({
    super.key,
    required this.dataSource,
    required this.signOut,
    required this.config,
    required super.child,
  });

  static DartDesk of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<DartDesk>();
    assert(result != null, 'No DartDesk found in context');
    return result!;
  }

  static DartDesk? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DartDesk>();
  }

  @override
  bool updateShouldNotify(DartDesk oldWidget) {
    return dataSource != oldWidget.dataSource ||
        config != oldWidget.config;
  }
}
```

- [ ] **Step 2: Verify compiles**

- [ ] **Step 3: Commit**

```bash
git add dart_desk/packages/dart_desk/lib/src/studio/dart_desk.dart
git commit -m "feat: add DartDesk InheritedWidget"
```

---

### Task 9: Create DartDeskApp widget (frontend)

**Files:**
- Create: `dart_desk/packages/dart_desk/lib/src/studio/dart_desk_app.dart`
- Modify: `dart_desk/packages/dart_desk/lib/studio.dart`

- [ ] **Step 1: Create DartDeskApp with default constructor (built-in auth)**

This widget absorbs `FlutterCmsAuth` (from `dart_desk_be_client`) and `CmsStudioApp` logic. The default constructor handles Serverpod client creation, auth initialization, sign-in screen, and wraps `CmsStudioApp` with `DartDesk` InheritedWidget.

Read the existing `CmsStudioApp` at `dart_desk/packages/dart_desk/lib/src/studio/cms_studio_app.dart` and `FlutterCmsAuth` at `dart_desk_be_client/lib/src/dart_desk_auth.dart` to understand the full widget tree.

```dart
// dart_desk/packages/dart_desk/lib/src/studio/dart_desk_app.dart
// ... (full implementation depends on reading existing CmsStudioApp)
```

The key pattern:
- `DartDeskApp(serverUrl, config)` — creates Client, initializes auth, shows sign-in, then wraps CmsStudioApp internals with DartDesk InheritedWidget
- `DartDeskApp.withDataSource(dataSource, onSignOut, config)` — skips auth, wraps directly

- [ ] **Step 2: Create DartDeskApp.withDataSource named constructor (external auth)**

```dart
DartDeskApp.withDataSource({
  required CmsDataSource dataSource,
  required VoidCallback onSignOut,
  required DartDeskConfig config,
}) : _mode = _DartDeskMode.external,
     _dataSource = dataSource,
     _onSignOut = onSignOut,
     _config = config,
     _serverUrl = null;
```

- [ ] **Step 3: Update studio.dart barrel exports**

Add exports for new files, keep CmsStudioApp export for backward compatibility (deprecated).

- [ ] **Step 4: Verify compiles**

Run: `cd dart_desk/packages/dart_desk && dart analyze`

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: add DartDeskApp widget with built-in and external auth modes"
```

---

### Task 10: Update example app to use DartDeskApp (frontend)

**Files:**
- Modify: `dart_desk/examples/cms_app/lib/main.dart`
- Modify: `dart_desk/examples/example_app/` (if applicable)

- [ ] **Step 1: Update example to use DartDeskApp**

Replace `FlutterCmsAuth` + `CmsStudioApp` with single `DartDeskApp(serverUrl, config)`.

- [ ] **Step 2: Verify example compiles**

- [ ] **Step 3: Commit**

```bash
git add -A
git commit -m "refactor: update example apps to use DartDeskApp"
```

---

### Task 11: Rename CmsDocumentType → DocumentType, CmsDocumentTypeDecoration → DocumentTypeDecoration, CmsDataSource → DataSource (frontend)

**Files:**
- Modify: `dart_desk/packages/dart_desk_annotation/lib/src/config.dart`
- Modify: `dart_desk/packages/dart_desk/lib/src/studio/components/common/cms_document_type_decoration.dart`
- Modify: `dart_desk/packages/dart_desk/lib/src/data/cms_data_source.dart`
- Modify: All files that reference these types (imports, usages)

- [ ] **Step 1: Rename CmsDocumentType → DocumentType in annotation package**

Use find-and-replace across the `dart_desk_annotation` package. Keep old names as deprecated typedefs for one release cycle.

- [ ] **Step 2: Rename CmsDocumentTypeDecoration → DocumentTypeDecoration**

- [ ] **Step 3: Rename CmsDataSource → DataSource**

Also rename the file: `cms_data_source.dart` → `data_source.dart`.

- [ ] **Step 4: Update all imports and usages across dart_desk package**

- [ ] **Step 5: Run dart analyze on all packages**

Run:
```bash
cd dart_desk/packages/dart_desk_annotation && dart analyze
cd dart_desk/packages/dart_desk && dart analyze
```

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "refactor: rename CmsDocumentType → DocumentType, CmsDataSource → DataSource"
```

---

### Task 12: Final verification and cleanup

- [ ] **Step 1: Run dart analyze on server package**

Run: `cd dart_desk_be_server && dart analyze`

- [ ] **Step 2: Run dart test on server package**

Run: `cd dart_desk_be_server && dart test`

- [ ] **Step 3: Run dart analyze on client package**

Run: `cd dart_desk_be_client && dart analyze` (requires Flutter SDK)

- [ ] **Step 4: Run dart analyze on frontend packages**

Run: `cd dart_desk/packages/dart_desk && dart analyze`

- [ ] **Step 5: Commit any fixes**

```bash
git add -A
git commit -m "chore: final cleanup and verification"
```
