# Flutter CMS Manage — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a separate Flutter web app ("Manage") for project management of the Flutter CMS platform, starting with API token management.

**Architecture:** Serverpod backend with new `CmsApiToken` model and `CmsApiTokenEndpoint`. Separate Flutter web app (`flutter_cms_manage/`) using shadcn_ui (dark/Slate), zenrouter (Coordinator pattern), and Signals for state. The Manage app authenticates via Serverpod auth (Google/Email IDP), not API tokens.

**Tech Stack:** Serverpod 3.4.3, Flutter web, shadcn_ui, zenrouter, Signals, DBCrypt, serverpod_auth_idp_flutter

**Spec:** `docs/superpowers/specs/2026-03-13-flutter-cms-manage-design.md`

---

## File Structure

### Backend (new/modified files)

| File | Action | Responsibility |
|------|--------|----------------|
| `flutter_cms_be_server/lib/src/models/cms_api_token.spy.yaml` | Create | CmsApiToken database model |
| `flutter_cms_be_server/lib/src/models/cms_api_token_with_value.spy.yaml` | Create | Serialization-only model (token + plaintext) |
| `flutter_cms_be_server/lib/src/endpoints/cms_api_token_endpoint.dart` | Create | CRUD for API tokens |
| `flutter_cms_be_server/lib/src/endpoints/user_endpoint.dart` | Modify | Add getUserClients, getCurrentUserBySlug, getClientUserCount; update ensureUser for multi-token validation |
| `flutter_cms_be_server/lib/server.dart` | Modify | Register CmsApiToken in admin module |

### Frontend (new files)

| File | Action | Responsibility |
|------|--------|----------------|
| `flutter_cms_manage/pubspec.yaml` | Create | App dependencies |
| `flutter_cms_manage/web/index.html` | Create | Web entry point |
| `flutter_cms_manage/lib/main.dart` | Create | ShadApp entry, auth bootstrap, URL strategy |
| `flutter_cms_manage/lib/src/routes/manage_route.dart` | Create | Base route class |
| `flutter_cms_manage/lib/src/routes/manage_coordinator.dart` | Create | Coordinator with parseRouteFromUri |
| `flutter_cms_manage/lib/src/routes/manage_layout.dart` | Create | Shell layout (top bar, project header, tabs) |
| `flutter_cms_manage/lib/src/routes/api_layout.dart` | Create | API tab layout (sidebar + content) |
| `flutter_cms_manage/lib/src/routes/overview_route.dart` | Create | Overview leaf route |
| `flutter_cms_manage/lib/src/routes/tokens_route.dart` | Create | Tokens leaf route |
| `flutter_cms_manage/lib/src/routes/settings_route.dart` | Create | Settings leaf route |
| `flutter_cms_manage/lib/src/routes/not_found_route.dart` | Create | 404 leaf route |
| `flutter_cms_manage/lib/src/screens/overview_screen.dart` | Create | Overview UI |
| `flutter_cms_manage/lib/src/screens/tokens_screen.dart` | Create | Token list table UI |
| `flutter_cms_manage/lib/src/screens/create_token_dialog.dart` | Create | Create token dialog |
| `flutter_cms_manage/lib/src/screens/token_reveal_dialog.dart` | Create | One-time token reveal dialog |
| `flutter_cms_manage/lib/src/screens/settings_screen.dart` | Create | Client settings form |
| `flutter_cms_manage/lib/src/services/token_service.dart` | Create | Token CRUD via Serverpod client |
| `flutter_cms_manage/lib/src/providers/manage_providers.dart` | Create | Signals-based reactive state |

---

## Chunk 1: Backend — Model + Migration

### Task 1: Create CmsApiToken model

**Files:**
- Create: `flutter_cms_be_server/lib/src/models/cms_api_token.spy.yaml`

- [ ] **Step 1: Create the CmsApiToken model file**

```yaml
class: CmsApiToken
table: cms_api_tokens
fields:
  clientId: int, relation(parent=cms_clients, onDelete=Restrict)
  name: String
  tokenHash: String
  tokenPrefix: String
  tokenSuffix: String
  role: String
  createdByUserId: int?, relation(parent=cms_users, onDelete=SetNull)
  lastUsedAt: DateTime?
  expiresAt: DateTime?
  isActive: bool, default=true
  createdAt: DateTime?, default=now
indexes:
  cms_api_token_client_idx:
    fields: clientId
  cms_api_token_lookup_idx:
    fields: clientId, tokenPrefix, tokenSuffix
    unique: true
```

- [ ] **Step 2: Verify model syntax**

Run: `cd flutter_cms_be_server && cat lib/src/models/cms_api_token.spy.yaml`
Expected: File contents match the above YAML

### Task 2: Create CmsApiTokenWithValue serialization model

**Files:**
- Create: `flutter_cms_be_server/lib/src/models/cms_api_token_with_value.spy.yaml`

- [ ] **Step 1: Create the CmsApiTokenWithValue model file**

```yaml
class: CmsApiTokenWithValue
fields:
  token: CmsApiToken
  plaintextToken: String
```

Note: No `table` — this is serialization-only, never stored in the database.

### Task 3: Run Serverpod generate

- [ ] **Step 1: Generate protocol code**

Run: `cd flutter_cms_be_server && serverpod generate`
Expected: No errors. New files appear in `lib/src/generated/` for CmsApiToken and CmsApiTokenWithValue.

- [ ] **Step 2: Verify generated code compiles**

Run: `cd flutter_cms_be_server && dart analyze lib/src/generated/`
Expected: No errors

### Task 4: Create database migration

- [ ] **Step 1: Create migration**

Run: `cd flutter_cms_be_server && serverpod create-migration`
Expected: New migration folder in `migrations/` with SQL creating `cms_api_tokens` table, indexes, and foreign keys.

- [ ] **Step 2: Review migration SQL**

Read the latest migration SQL file and verify it contains:
- `CREATE TABLE "cms_api_tokens"` with all expected columns
- `CREATE INDEX "cms_api_token_client_idx"` on `clientId`
- `CREATE UNIQUE INDEX "cms_api_token_lookup_idx"` on `(clientId, tokenPrefix, tokenSuffix)`
- Foreign key constraints to `cms_clients` and `cms_users`

- [ ] **Step 3: Register CmsApiToken in admin module**

Modify: `flutter_cms_be_server/lib/server.dart`

Add inside `_registerAdminModule()`, after the existing `registry.register<DocumentCrdtSnapshot>();` line:

```dart
    registry.register<CmsApiToken>();
```

- [ ] **Step 4: Commit**

```bash
git add flutter_cms_be_server/lib/src/models/cms_api_token.spy.yaml \
       flutter_cms_be_server/lib/src/models/cms_api_token_with_value.spy.yaml \
       flutter_cms_be_server/lib/src/generated/ \
       flutter_cms_be_server/migrations/ \
       flutter_cms_be_server/lib/server.dart
git commit -m "feat: add CmsApiToken model and migration for multi-token support"
```

---

## Chunk 2: Backend — CmsApiTokenEndpoint

### Task 5: Create CmsApiTokenEndpoint

**Files:**
- Create: `flutter_cms_be_server/lib/src/endpoints/cms_api_token_endpoint.dart`

- [ ] **Step 1: Write the endpoint file**

```dart
import 'dart:convert';
import 'dart:math';

import 'package:dbcrypt/dbcrypt.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Endpoint for managing CMS API tokens.
/// All methods require Serverpod auth (session.authenticated).
/// Authorization: caller must be a CmsUser belonging to the target client.
class CmsApiTokenEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const _maxRetries = 5;
  static const _rolePrefixes = {
    'viewer': 'cms_vi_',
    'editor': 'cms_ed_',
    'admin': 'cms_ad_',
  };

  /// List all tokens for a client (metadata only, never the hash).
  Future<List<CmsApiToken>> getTokens(
    Session session,
    int clientId,
  ) async {
    final user = await _requireUser(session, clientId);

    return await CmsApiToken.db.find(
      session,
      where: (t) => t.clientId.equals(clientId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }

  /// Create a new named token. Returns plaintext token (shown once).
  Future<CmsApiTokenWithValue> createToken(
    Session session,
    int clientId,
    String name,
    String role,
    DateTime? expiresAt,
  ) async {
    final user = await _requireUser(session, clientId);

    if (!_rolePrefixes.containsKey(role)) {
      throw Exception('Invalid role: $role. Must be viewer, editor, or admin.');
    }

    final prefix = _rolePrefixes[role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawToken = _generateToken(prefix);
      final suffix = rawToken.substring(rawToken.length - 4);
      final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());

      // Check for collision on (clientId, tokenPrefix, tokenSuffix)
      final existing = await CmsApiToken.db.findFirstRow(
        session,
        where: (t) =>
            t.clientId.equals(clientId) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix),
      );
      if (existing != null) continue;

      final token = CmsApiToken(
        clientId: clientId,
        name: name,
        tokenHash: hash,
        tokenPrefix: prefix,
        tokenSuffix: suffix,
        role: role,
        createdByUserId: user.id,
        isActive: true,
        createdAt: DateTime.now(),
      );

      if (expiresAt != null) {
        token.expiresAt = expiresAt;
      }

      final inserted = await CmsApiToken.db.insertRow(session, token);
      return CmsApiTokenWithValue(token: inserted, plaintextToken: rawToken);
    }

    throw Exception(
        'Failed to generate unique token after $_maxRetries attempts');
  }

  /// Update token metadata (name, isActive, expiresAt).
  Future<CmsApiToken> updateToken(
    Session session,
    int tokenId,
    String? name,
    bool? isActive,
    DateTime? expiresAt,
  ) async {
    final token = await CmsApiToken.db.findById(session, tokenId);
    if (token == null) throw Exception('Token not found: $tokenId');

    await _requireUser(session, token.clientId);

    final updated = token.copyWith(
      name: name ?? token.name,
      isActive: isActive ?? token.isActive,
      expiresAt: expiresAt ?? token.expiresAt,
    );

    return await CmsApiToken.db.updateRow(session, updated);
  }

  /// Regenerate token value. Returns new plaintext token (shown once).
  Future<CmsApiTokenWithValue> regenerateToken(
    Session session,
    int tokenId,
  ) async {
    final token = await CmsApiToken.db.findById(session, tokenId);
    if (token == null) throw Exception('Token not found: $tokenId');

    await _requireUser(session, token.clientId);

    final prefix = _rolePrefixes[token.role]!;

    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      final rawToken = _generateToken(prefix);
      final suffix = rawToken.substring(rawToken.length - 4);
      final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());

      // Check collision (skip self)
      final existing = await CmsApiToken.db.findFirstRow(
        session,
        where: (t) =>
            t.clientId.equals(token.clientId) &
            t.tokenPrefix.equals(prefix) &
            t.tokenSuffix.equals(suffix) &
            t.id.notEquals(tokenId),
      );
      if (existing != null) continue;

      final updated = token.copyWith(
        tokenHash: hash,
        tokenSuffix: suffix,
      );

      final result = await CmsApiToken.db.updateRow(session, updated);
      return CmsApiTokenWithValue(token: result, plaintextToken: rawToken);
    }

    throw Exception(
        'Failed to generate unique token after $_maxRetries attempts');
  }

  /// Delete a token permanently.
  Future<bool> deleteToken(
    Session session,
    int tokenId,
  ) async {
    final token = await CmsApiToken.db.findById(session, tokenId);
    if (token == null) return false;

    await _requireUser(session, token.clientId);

    await CmsApiToken.db.deleteRow(session, token);
    return true;
  }

  /// Verify the caller is an authenticated CmsUser of the given client.
  Future<CmsUser> _requireUser(Session session, int clientId) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final user = await CmsUser.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.clientId.equals(clientId) &
          t.isActive.equals(true),
    );
    if (user == null) {
      throw Exception('User does not belong to client $clientId');
    }
    return user;
  }

  /// Generate a crypto-random API token with the given prefix.
  static String _generateToken(String prefix) {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final randomPart = base64Url.encode(bytes).replaceAll('=', '');
    return '$prefix$randomPart';
  }
}
```

- [ ] **Step 2: Run serverpod generate to register the endpoint**

Run: `cd flutter_cms_be_server && serverpod generate`
Expected: No errors. Endpoint registered in generated code.

- [ ] **Step 3: Verify compilation**

Run: `cd flutter_cms_be_server && dart analyze`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add flutter_cms_be_server/lib/src/endpoints/cms_api_token_endpoint.dart \
       flutter_cms_be_server/lib/src/generated/
git commit -m "feat: add CmsApiTokenEndpoint with CRUD and collision-safe token generation"
```

---

## Chunk 3: Backend — Update UserEndpoint for Manage App

### Task 6: Add getUserClients, getCurrentUserBySlug, getClientUserCount

**Files:**
- Modify: `flutter_cms_be_server/lib/src/endpoints/user_endpoint.dart`

- [ ] **Step 1: Add three new methods to UserEndpoint**

Append the following methods before the closing `}` of the `UserEndpoint` class (after `getCurrentUser` method around line 134):

```dart

  /// Get all clients the authenticated user belongs to.
  /// Used by Manage app for client switcher.
  Future<List<CmsClient>> getUserClients(Session session) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    // Find all CmsUser records for this serverpod user
    final users = await CmsUser.db.find(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.isActive.equals(true),
    );

    if (users.isEmpty) return [];

    // Fetch the corresponding clients
    final clientIds = users.map((u) => u.clientId).toSet().toList();
    final clients = await CmsClient.db.find(
      session,
      where: (t) => t.id.inSet(clientIds) & t.isActive.equals(true),
    );

    return clients;
  }

  /// Get the current CMS user by client slug (for Manage app — no API token needed).
  /// Authenticates via Serverpod auth session only.
  Future<CmsUser?> getCurrentUserBySlug(
    Session session,
    String clientSlug,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    final client = await CmsClient.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(clientSlug) & t.isActive.equals(true),
    );
    if (client == null) return null;

    return await CmsUser.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.clientId.equals(client.id!),
    );
  }

  /// Get count of CmsUsers for a client (for Overview stats).
  Future<int> getClientUserCount(
    Session session,
    int clientId,
  ) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    // Verify caller belongs to this client
    final callerUser = await CmsUser.db.findFirstRow(
      session,
      where: (t) =>
          t.serverpodUserId.equals(authInfo.userIdentifier) &
          t.clientId.equals(clientId) &
          t.isActive.equals(true),
    );
    if (callerUser == null) {
      throw Exception('User does not belong to client $clientId');
    }

    return await CmsUser.db.count(
      session,
      where: (t) => t.clientId.equals(clientId) & t.isActive.equals(true),
    );
  }
```

- [ ] **Step 2: Run serverpod generate**

Run: `cd flutter_cms_be_server && serverpod generate`
Expected: No errors

- [ ] **Step 3: Verify compilation**

Run: `cd flutter_cms_be_server && dart analyze`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add flutter_cms_be_server/lib/src/endpoints/user_endpoint.dart \
       flutter_cms_be_server/lib/src/generated/
git commit -m "feat: add getUserClients, getCurrentUserBySlug, getClientUserCount to UserEndpoint"
```

### Task 7: Update ensureUser for multi-token validation

**Files:**
- Modify: `flutter_cms_be_server/lib/src/endpoints/user_endpoint.dart`

- [ ] **Step 1: Add a private `_validateApiToken` helper method**

Add the following method to the `UserEndpoint` class (before the closing `}`):

```dart
  /// Validate an API token against cms_api_tokens table, falling back to
  /// CmsClient.apiTokenHash for legacy tokens. Returns the matched role
  /// or throws if invalid.
  Future<String> _validateApiToken(
    Session session,
    int clientId,
    String apiToken,
    String clientApiTokenHash,
  ) async {
    // Try new multi-token system first
    final prefixMatch = RegExp(r'^(cms_(?:vi|ed|ad)_)').firstMatch(apiToken);
    if (prefixMatch != null) {
      final tokenPrefix = prefixMatch.group(1)!;
      final tokenSuffix = apiToken.substring(apiToken.length - 4);

      final candidate = await CmsApiToken.db.findFirstRow(
        session,
        where: (t) =>
            t.clientId.equals(clientId) &
            t.tokenPrefix.equals(tokenPrefix) &
            t.tokenSuffix.equals(tokenSuffix) &
            t.isActive.equals(true),
      );

      if (candidate != null) {
        if (candidate.expiresAt != null &&
            candidate.expiresAt!.isBefore(DateTime.now())) {
          throw Exception('API token has expired');
        }
        if (DBCrypt().checkpw(apiToken, candidate.tokenHash)) {
          await CmsApiToken.db.updateRow(
            session,
            candidate.copyWith(lastUsedAt: DateTime.now()),
          );
          return candidate.role;
        }
      }
    }

    // Fallback: legacy CmsClient.apiTokenHash (for cms_live_ tokens)
    if (DBCrypt().checkpw(apiToken, clientApiTokenHash)) {
      return 'admin'; // Legacy tokens have implicit admin role
    }

    throw Exception('Invalid API token');
  }
```

- [ ] **Step 2: Update ensureUser to use the helper**

Replace the existing token validation block in `ensureUser` (lines 32-35):

```dart
    // Validate API token against stored bcrypt hash
    if (!DBCrypt().checkpw(apiToken, client.apiTokenHash)) {
      throw Exception('Invalid API token');
    }
```

With:

```dart
    // Validate API token (multi-token + legacy fallback)
    final matchedRole = await _validateApiToken(
      session, client.id!, apiToken, client.apiTokenHash);
```

- [ ] **Step 3: Update getCurrentUser to use the helper**

Replace the token validation block in `getCurrentUser` (lines 119-122):

```dart
    // Validate API token against stored bcrypt hash
    if (!DBCrypt().checkpw(apiToken, client.apiTokenHash)) {
      throw Exception('Invalid API token');
    }
```

With:

```dart
    // Validate API token (multi-token + legacy fallback)
    await _validateApiToken(
      session, client.id!, apiToken, client.apiTokenHash);
```

- [ ] **Step 4: Run serverpod generate and verify**

Run: `cd flutter_cms_be_server && serverpod generate && dart analyze`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add flutter_cms_be_server/lib/src/endpoints/user_endpoint.dart \
       flutter_cms_be_server/lib/src/generated/
git commit -m "feat: update ensureUser and getCurrentUser with multi-token validation"
```

---

## Chunk 4: Frontend — App Scaffold

### Task 8: Create flutter_cms_manage project

**Files:**
- Create: `flutter_cms_manage/pubspec.yaml`
- Create: `flutter_cms_manage/web/index.html`
- Create: `flutter_cms_manage/web/manifest.json`
- Create: `flutter_cms_manage/lib/main.dart`

- [ ] **Step 1: Create pubspec.yaml**

```yaml
name: flutter_cms_manage
description: Flutter CMS Manage — Project management dashboard
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.5.0 <4.0.0'
  flutter: '>=3.24.0'

dependencies:
  flutter:
    sdk: flutter
  shadcn_ui: ^0.52.0
  zenrouter: ^0.1.0
  signals: ^6.0.2
  flutter_cms_be_client:
    path: ../flutter_cms_be_client
  serverpod_flutter: 3.4.3
  serverpod_auth_idp_flutter: 3.4.3
  lucide_icons_flutter: ^1.5.8
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: '>=3.0.0 <7.0.0'

flutter:
  uses-material-design: true
```

Note: Check the exact `signals` version used in the existing Studio app. If there's a `../flutter_cms` project, match its version. Otherwise use the latest stable.

- [ ] **Step 2: Create web/index.html**

```html
<!DOCTYPE html>
<html>
<head>
  <base href="/">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Flutter CMS Manage">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="CMS Manage">
  <link rel="manifest" href="manifest.json">
  <title>Flutter CMS Manage</title>
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

- [ ] **Step 3: Create web/manifest.json**

```json
{
  "name": "Flutter CMS Manage",
  "short_name": "CMS Manage",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0a0a0a",
  "theme_color": "#0a0a0a"
}
```

- [ ] **Step 4: Create lib/main.dart (minimal bootstrap)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'src/routes/manage_coordinator.dart';

void main() {
  usePathUrlStrategy();
  runApp(const ManageApp());
}

class ManageApp extends StatefulWidget {
  const ManageApp({super.key});

  @override
  State<ManageApp> createState() => _ManageAppState();
}

class _ManageAppState extends State<ManageApp> {
  late final ManageCoordinator coordinator;

  @override
  void initState() {
    super.initState();
    coordinator = ManageCoordinator();
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'Flutter CMS Manage',
      theme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      routerConfig: coordinator,
    );
  }
}
```

- [ ] **Step 5: Run flutter create to generate platform files**

Run: `cd flutter_cms_manage && flutter create . --platforms web --project-name flutter_cms_manage`

This generates the remaining platform scaffolding. Then verify:

Run: `cd flutter_cms_manage && flutter pub get`
Expected: Dependencies resolve successfully

- [ ] **Step 6: Commit**

```bash
git add flutter_cms_manage/pubspec.yaml \
       flutter_cms_manage/web/ \
       flutter_cms_manage/lib/main.dart \
       flutter_cms_manage/analysis_options.yaml \
       flutter_cms_manage/.gitignore
git commit -m "feat: scaffold flutter_cms_manage app with shadcn_ui dark theme"
```

### Task 9: Create route classes and coordinator

**Files:**
- Create: `flutter_cms_manage/lib/src/routes/manage_route.dart`
- Create: `flutter_cms_manage/lib/src/routes/manage_coordinator.dart`
- Create: `flutter_cms_manage/lib/src/routes/overview_route.dart`
- Create: `flutter_cms_manage/lib/src/routes/tokens_route.dart`
- Create: `flutter_cms_manage/lib/src/routes/settings_route.dart`
- Create: `flutter_cms_manage/lib/src/routes/not_found_route.dart`

- [ ] **Step 1: Create manage_route.dart (base route class)**

```dart
import 'package:zenrouter/zenrouter.dart';

abstract class ManageRoute extends RouteTarget with RouteUnique {}
```

- [ ] **Step 2: Create not_found_route.dart**

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'manage_coordinator.dart';
import 'manage_route.dart';
import 'overview_route.dart';

class NotFoundRoute extends ManageRoute {
  @override
  Uri toUri() => Uri.parse('/404');

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Page not found', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 16),
          ShadButton(
            child: const Text('Go Home'),
            onPressed: () => coordinator.push(
              OverviewRoute(coordinator.clientSlug),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create overview_route.dart**

```dart
import 'package:flutter/material.dart';

import 'manage_coordinator.dart';
import 'manage_layout.dart';
import 'manage_route.dart';
import '../screens/overview_screen.dart';

class OverviewRoute extends ManageRoute {
  @override
  Type get layout => ManageLayout;

  @override
  Uri toUri() => Uri.parse('/${coordinator.clientSlug}/overview');

  ManageCoordinator get coordinator =>
      Coordinator.of<ManageCoordinator>(this);

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      OverviewScreen(coordinator: coordinator);
}
```

Note: The `Coordinator.of<ManageCoordinator>(this)` pattern may not exist in zenrouter. If `toUri()` doesn't have access to the coordinator, store `clientSlug` as a field on the route itself — populated during `parseRouteFromUri`. Adjust accordingly at implementation time. The coordinator is passed to `build()` so that's fine for the screen.

**Revised approach — store clientSlug on each route:**

```dart
import 'package:flutter/material.dart';

import 'manage_layout.dart';
import 'manage_route.dart';
import 'manage_coordinator.dart';
import '../screens/overview_screen.dart';

class OverviewRoute extends ManageRoute {
  final String clientSlug;
  OverviewRoute(this.clientSlug);

  @override
  Type get layout => ManageLayout;

  @override
  Uri toUri() => Uri.parse('/$clientSlug/overview');

  @override
  List<Object?> get props => [clientSlug];

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      OverviewScreen(coordinator: coordinator);
}
```

- [ ] **Step 4: Create tokens_route.dart**

```dart
import 'package:flutter/material.dart';

import 'api_layout.dart';
import 'manage_route.dart';
import 'manage_coordinator.dart';
import '../screens/tokens_screen.dart';

class TokensRoute extends ManageRoute {
  final String clientSlug;
  TokensRoute(this.clientSlug);

  @override
  Type get layout => ApiLayout;

  @override
  Uri toUri() => Uri.parse('/$clientSlug/api/tokens');

  @override
  List<Object?> get props => [clientSlug];

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      TokensScreen(coordinator: coordinator);
}
```

- [ ] **Step 5: Create settings_route.dart**

```dart
import 'package:flutter/material.dart';

import 'manage_layout.dart';
import 'manage_route.dart';
import 'manage_coordinator.dart';
import '../screens/settings_screen.dart';

class SettingsRoute extends ManageRoute {
  final String clientSlug;
  SettingsRoute(this.clientSlug);

  @override
  Type get layout => ManageLayout;

  @override
  Uri toUri() => Uri.parse('/$clientSlug/settings');

  @override
  List<Object?> get props => [clientSlug];

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      SettingsScreen(coordinator: coordinator);
}
```

- [ ] **Step 6: Create manage_coordinator.dart**

```dart
import 'package:zenrouter/zenrouter.dart';

import 'manage_route.dart';
import 'manage_layout.dart';
import 'api_layout.dart';
import 'overview_route.dart';
import 'tokens_route.dart';
import 'settings_route.dart';
import 'not_found_route.dart';

class ManageCoordinator extends Coordinator<ManageRoute> {
  String clientSlug = '';

  late final manageStack = NavigationPath.createWith(
    label: 'manage',
    coordinator: this,
  )..bindLayout(ManageLayout.new);

  late final apiStack = NavigationPath.createWith(
    label: 'api',
    coordinator: this,
  )..bindLayout(ApiLayout.new);

  @override
  List<StackPath> get paths => [...super.paths, manageStack, apiStack];

  @override
  ManageRoute parseRouteFromUri(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return NotFoundRoute();

    clientSlug = segments.first;
    final rest = segments.skip(1).toList();

    return switch (rest) {
      [] => OverviewRoute(clientSlug),
      ['overview'] => OverviewRoute(clientSlug),
      ['api', 'tokens'] => TokensRoute(clientSlug),
      ['settings'] => SettingsRoute(clientSlug),
      _ => NotFoundRoute(),
    };
  }
}
```

- [ ] **Step 7: Verify compilation**

Run: `cd flutter_cms_manage && flutter analyze`
Expected: May have errors due to missing ManageLayout, ApiLayout, and screen files — that's expected, we create those next.

- [ ] **Step 8: Commit route files**

```bash
git add flutter_cms_manage/lib/src/routes/
git commit -m "feat: add zenrouter Coordinator with manage, api, overview, tokens, settings routes"
```

### Task 10: Create layout routes and shell widgets

**Files:**
- Create: `flutter_cms_manage/lib/src/routes/manage_layout.dart`
- Create: `flutter_cms_manage/lib/src/routes/api_layout.dart`

- [ ] **Step 1: Create manage_layout.dart (ManageLayout + ManageShell)**

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zenrouter/zenrouter.dart';

import 'manage_route.dart';
import 'manage_coordinator.dart';
import 'overview_route.dart';
import 'tokens_route.dart';
import 'settings_route.dart';

class ManageLayout extends ManageRoute with RouteLayout<ManageRoute> {
  @override
  NavigationPath<ManageRoute> resolvePath(ManageCoordinator coordinator) =>
      coordinator.manageStack;

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) {
    return ManageShell(
      coordinator: coordinator,
      child: buildPath(coordinator),
    );
  }
}

class ManageShell extends StatelessWidget {
  final ManageCoordinator coordinator;
  final Widget child;

  const ManageShell({
    super.key,
    required this.coordinator,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          // Top bar
          _TopBar(coordinator: coordinator),
          // Project header
          _ProjectHeader(coordinator: coordinator),
          // Tab navigation
          _TabNavigation(coordinator: coordinator),
          const Divider(height: 1),
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final ManageCoordinator coordinator;
  const _TopBar({required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Flutter CMS',
            style: theme.textTheme.large.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ShadButton.ghost(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Open Studio'),
                const SizedBox(width: 4),
                Icon(LucideIcons.externalLink, size: 14),
              ],
            ),
            onPressed: () {
              // TODO: Link to Studio URL
            },
          ),
          const SizedBox(width: 8),
          ShadAvatar(
            size: const Size(28, 28),
            child: const Text('U'),
          ),
        ],
      ),
    );
  }
}

class _ProjectHeader extends StatelessWidget {
  final ManageCoordinator coordinator;
  const _ProjectHeader({required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          ShadAvatar(
            size: const Size(48, 48),
            child: Text(
              coordinator.clientSlug.isNotEmpty
                  ? coordinator.clientSlug[0].toUpperCase()
                  : '?',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coordinator.clientSlug,
                style: theme.textTheme.h3,
              ),
              Text(
                'Project ID: ${coordinator.clientSlug}',
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabNavigation extends StatelessWidget {
  final ManageCoordinator coordinator;
  const _TabNavigation({required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final slug = coordinator.clientSlug;

    return ListenableBuilder(
      listenable: Listenable.merge([coordinator.manageStack, coordinator.apiStack]),
      builder: (context, _) {
        final activeRoute = coordinator.root.activeRoute;
        final isOverview = activeRoute is OverviewRoute;
        final isApi = activeRoute is TokensRoute;
        final isSettings = activeRoute is SettingsRoute;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _TabButton(
                label: 'Overview',
                isActive: isOverview,
                onPressed: () => coordinator.push(OverviewRoute(slug)),
              ),
              _TabButton(
                label: 'API',
                isActive: isApi,
                onPressed: () => coordinator.push(TokensRoute(slug)),
              ),
              _TabButton(
                label: 'Settings',
                isActive: isSettings,
                onPressed: () => coordinator.push(SettingsRoute(slug)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: ShadButton.ghost(
        size: ShadButtonSize.sm,
        decoration: isActive
            ? ShadDecoration(
                border: ShadBorder(
                  bottom: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? theme.colorScheme.foreground
                : theme.colorScheme.mutedForeground,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
```

- [ ] **Step 2: Create api_layout.dart (ApiLayout + ApiShell)**

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:zenrouter/zenrouter.dart';

import 'manage_route.dart';
import 'manage_layout.dart';
import 'manage_coordinator.dart';

class ApiLayout extends ManageRoute with RouteLayout<ManageRoute> {
  @override
  Type get layout => ManageLayout;

  @override
  NavigationPath<ManageRoute> resolvePath(ManageCoordinator coordinator) =>
      coordinator.apiStack;

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) {
    return ApiShell(
      coordinator: coordinator,
      child: buildPath(coordinator),
    );
  }
}

class ApiShell extends StatelessWidget {
  final ManageCoordinator coordinator;
  final Widget child;

  const ApiShell({
    super.key,
    required this.coordinator,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      children: [
        // Left sidebar
        Container(
          width: 180,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: theme.colorScheme.border),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SidebarItem(
                  icon: LucideIcons.key,
                  label: 'Tokens',
                  isActive: true,
                ),
                // Future: CORS Origins, Webhooks, etc.
              ],
            ),
          ),
        ),
        // Content area
        Expanded(child: child),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? theme.colorScheme.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive
                ? theme.colorScheme.foreground
                : theme.colorScheme.mutedForeground,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? theme.colorScheme.foreground
                  : theme.colorScheme.mutedForeground,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create placeholder screens so the app compiles**

Create `flutter_cms_manage/lib/src/screens/overview_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../routes/manage_coordinator.dart';

class OverviewScreen extends StatelessWidget {
  final ManageCoordinator coordinator;
  const OverviewScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Overview — coming soon'));
  }
}
```

Create `flutter_cms_manage/lib/src/screens/tokens_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../routes/manage_coordinator.dart';

class TokensScreen extends StatelessWidget {
  final ManageCoordinator coordinator;
  const TokensScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tokens — coming soon'));
  }
}
```

Create `flutter_cms_manage/lib/src/screens/settings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../routes/manage_coordinator.dart';

class SettingsScreen extends StatelessWidget {
  final ManageCoordinator coordinator;
  const SettingsScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings — coming soon'));
  }
}
```

- [ ] **Step 4: Verify the app compiles**

Run: `cd flutter_cms_manage && flutter analyze`
Expected: No errors

- [ ] **Step 5: Verify the app builds for web**

Run: `cd flutter_cms_manage && flutter build web --no-tree-shake-icons`
Expected: Build succeeds

- [ ] **Step 6: Commit**

```bash
git add flutter_cms_manage/lib/src/routes/ \
       flutter_cms_manage/lib/src/screens/
git commit -m "feat: add ManageLayout, ApiLayout shells with zenrouter, placeholder screens"
```

---

## Chunk 5: Frontend — Tokens Feature

### Task 11: Create token service

**Files:**
- Create: `flutter_cms_manage/lib/src/services/token_service.dart`

- [ ] **Step 1: Write the token service**

```dart
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:signals/signals.dart';

class TokenService {
  final Client client;
  final int clientId;

  TokenService({required this.client, required this.clientId});

  final tokens = listSignal<CmsApiToken>([]);
  final isLoading = signal(false);
  final error = signal<String?>(null);

  Future<void> loadTokens() async {
    isLoading.value = true;
    error.value = null;
    try {
      final result = await client.cmsApiToken.getTokens(clientId);
      tokens.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<CmsApiTokenWithValue?> createToken({
    required String name,
    required String role,
    DateTime? expiresAt,
  }) async {
    try {
      final result = await client.cmsApiToken.createToken(
        clientId,
        name,
        role,
        expiresAt,
      );
      await loadTokens();
      return result;
    } catch (e) {
      error.value = e.toString();
      return null;
    }
  }

  Future<bool> updateToken({
    required int tokenId,
    String? name,
    bool? isActive,
    DateTime? expiresAt,
  }) async {
    try {
      await client.cmsApiToken.updateToken(
        tokenId,
        name,
        isActive,
        expiresAt,
      );
      await loadTokens();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }

  Future<CmsApiTokenWithValue?> regenerateToken(int tokenId) async {
    try {
      final result = await client.cmsApiToken.regenerateToken(tokenId);
      await loadTokens();
      return result;
    } catch (e) {
      error.value = e.toString();
      return null;
    }
  }

  Future<bool> deleteToken(int tokenId) async {
    try {
      await client.cmsApiToken.deleteToken(tokenId);
      await loadTokens();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    }
  }
}
```

Note: The `Client` type and method signatures depend on the auto-generated Serverpod client. The exact parameter order may differ from what's shown — adjust at implementation time based on the generated `CmsApiTokenEndpoint` client stub.

- [ ] **Step 2: Commit**

```bash
git add flutter_cms_manage/lib/src/services/token_service.dart
git commit -m "feat: add TokenService with Signals for reactive token management"
```

### Task 12: Implement TokensScreen with data table

**Files:**
- Modify: `flutter_cms_manage/lib/src/screens/tokens_screen.dart`

- [ ] **Step 1: Replace placeholder with full implementation**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../routes/manage_coordinator.dart';
import '../services/token_service.dart';
import 'create_token_dialog.dart';
import 'token_reveal_dialog.dart';

class TokensScreen extends StatefulWidget {
  final ManageCoordinator coordinator;
  const TokensScreen({super.key, required this.coordinator});

  @override
  State<TokensScreen> createState() => _TokensScreenState();
}

class _TokensScreenState extends State<TokensScreen> {
  late final TokenService _tokenService;

  @override
  void initState() {
    super.initState();
    // TODO: Get client and clientId from coordinator/provider
    // _tokenService = TokenService(client: ..., clientId: ...);
    // _tokenService.loadTokens();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tokens', style: theme.textTheme.h3),
                  const SizedBox(height: 4),
                  Text(
                    'Manage API tokens for external access to your project.',
                    style: theme.textTheme.muted,
                  ),
                ],
              ),
              ShadButton(
                leading: Icon(LucideIcons.plus, size: 16),
                child: const Text('Add API token'),
                onPressed: () => _showCreateTokenDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Token table
          Expanded(
            child: _buildTokenTable(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenTable(BuildContext context) {
    final theme = ShadTheme.of(context);

    // TODO: Watch _tokenService.tokens signal
    // For now, show empty state
    return _buildEmptyState(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.key,
            size: 48,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(height: 16),
          Text(
            'There are no API tokens yet',
            style: theme.textTheme.large,
          ),
          const SizedBox(height: 8),
          Text(
            'Create a token to access this project\'s API.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 24),
          ShadButton(
            leading: Icon(LucideIcons.plus, size: 16),
            child: const Text('Add API token'),
            onPressed: () => _showCreateTokenDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenRow(BuildContext context, CmsApiToken token) {
    final theme = ShadTheme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border),
        ),
      ),
      child: Row(
        children: [
          // Name
          Expanded(
            flex: 3,
            child: Text(token.name, style: theme.textTheme.p),
          ),
          // Role badge
          Expanded(
            flex: 2,
            child: _RoleBadge(role: token.role),
          ),
          // Prefix display
          Expanded(
            flex: 2,
            child: Text(
              '${token.tokenPrefix}...${token.tokenSuffix}',
              style: theme.textTheme.muted.copyWith(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
          // Created date
          Expanded(
            flex: 2,
            child: Text(
              token.createdAt != null
                  ? dateFormat.format(token.createdAt!)
                  : '—',
              style: theme.textTheme.muted,
            ),
          ),
          // Status
          SizedBox(
            width: 60,
            child: token.isActive
                ? ShadBadge(
                    child: const Text('Active'),
                  )
                : ShadBadge.secondary(
                    child: const Text('Disabled'),
                  ),
          ),
          // Actions menu
          SizedBox(
            width: 40,
            child: _TokenActionsMenu(
              token: token,
              onRegenerate: () => _regenerateToken(token),
              onToggleActive: () => _toggleToken(token),
              onDelete: () => _deleteToken(token),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTokenDialog(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (ctx) => CreateTokenDialog(
        onCreateToken: (name, role, expiresAt) async {
          // TODO: Call _tokenService.createToken
          // final result = await _tokenService.createToken(
          //   name: name, role: role, expiresAt: expiresAt);
          // if (result != null) {
          //   Navigator.of(ctx).pop();
          //   _showTokenRevealDialog(ctx, result.plaintextToken);
          // }
        },
      ),
    );
  }

  void _showTokenRevealDialog(BuildContext context, String plaintextToken) {
    showShadDialog(
      context: context,
      builder: (ctx) => TokenRevealDialog(token: plaintextToken),
    );
  }

  Future<void> _regenerateToken(CmsApiToken token) async {
    // TODO: Confirmation dialog, then regenerate
  }

  Future<void> _toggleToken(CmsApiToken token) async {
    // TODO: Call _tokenService.updateToken
  }

  Future<void> _deleteToken(CmsApiToken token) async {
    // TODO: Confirmation dialog, then delete
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (role) {
      'viewer' => (Colors.purple, 'Viewer'),
      'editor' => (Colors.green, 'Editor'),
      'admin' => (Colors.amber, 'Admin'),
      _ => (Colors.grey, role),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}

class _TokenActionsMenu extends StatelessWidget {
  final CmsApiToken token;
  final VoidCallback onRegenerate;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _TokenActionsMenu({
    required this.token,
    required this.onRegenerate,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      size: ShadButtonSize.icon,
      icon: Icon(LucideIcons.ellipsis, size: 16),
      onPressed: () {
        // TODO: Use ShadPopover or ShadContextMenu for actions
      },
    );
  }
}
```

Note: This is the structural skeleton. The TODO comments mark where Serverpod client integration connects. The full wiring happens when the providers are set up with actual client instances.

- [ ] **Step 2: Commit**

```bash
git add flutter_cms_manage/lib/src/screens/tokens_screen.dart
git commit -m "feat: implement TokensScreen with table layout, empty state, role badges"
```

### Task 13: Implement CreateTokenDialog

**Files:**
- Create: `flutter_cms_manage/lib/src/screens/create_token_dialog.dart`

- [ ] **Step 1: Write the dialog**

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CreateTokenDialog extends StatefulWidget {
  final Future<void> Function(String name, String role, DateTime? expiresAt)
      onCreateToken;

  const CreateTokenDialog({super.key, required this.onCreateToken});

  @override
  State<CreateTokenDialog> createState() => _CreateTokenDialogState();
}

class _CreateTokenDialogState extends State<CreateTokenDialog> {
  final _formKey = GlobalKey<ShadFormState>();
  String _selectedRole = 'viewer';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadDialog(
      title: const Text('Create API Token'),
      description: const Text(
        'Create a new API token for external access to your project.',
      ),
      child: ShadForm(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ShadInputFormField(
              id: 'name',
              label: const Text('Token name'),
              placeholder: const Text('e.g., Production API'),
              validator: (v) =>
                  v.isEmpty ? 'Token name is required' : null,
            ),
            const SizedBox(height: 16),
            Text('Permission level', style: theme.textTheme.p),
            const SizedBox(height: 8),
            _RoleSelector(
              selectedRole: _selectedRole,
              onChanged: (role) => setState(() => _selectedRole = role),
            ),
            const SizedBox(height: 16),
            // TODO: Add optional expiration date picker
            Text(
              'Expiration: Never (default)',
              style: theme.textTheme.muted,
            ),
          ],
        ),
      ),
      actions: [
        ShadButton.outline(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ShadButton(
          enabled: !_isSubmitting,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Token'),
          onPressed: () async {
            if (_formKey.currentState!.saveAndValidate()) {
              setState(() => _isSubmitting = true);
              final values = _formKey.currentState!.value;
              await widget.onCreateToken(
                values['name'] as String,
                _selectedRole,
                null, // expiresAt — TODO: add date picker
              );
              setState(() => _isSubmitting = false);
            }
          },
        ),
      ],
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const _RoleSelector({
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      children: [
        _RoleOption(
          role: 'viewer',
          title: 'Viewer',
          description: 'Read-only access to published content',
          color: Colors.purple,
          isSelected: selectedRole == 'viewer',
          onTap: () => onChanged('viewer'),
        ),
        const SizedBox(height: 8),
        _RoleOption(
          role: 'editor',
          title: 'Editor',
          description: 'Read and write access to content',
          color: Colors.green,
          isSelected: selectedRole == 'editor',
          onTap: () => onChanged('editor'),
        ),
        const SizedBox(height: 8),
        _RoleOption(
          role: 'admin',
          title: 'Admin',
          description: 'Full access including settings and users',
          color: Colors.amber,
          isSelected: selectedRole == 'admin',
          onTap: () => onChanged('admin'),
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String role;
  final String title;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.role,
    required this.title,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? color.withOpacity(0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.p),
                Text(description, style: theme.textTheme.muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add flutter_cms_manage/lib/src/screens/create_token_dialog.dart
git commit -m "feat: add CreateTokenDialog with role selector and form validation"
```

### Task 14: Implement TokenRevealDialog

**Files:**
- Create: `flutter_cms_manage/lib/src/screens/token_reveal_dialog.dart`

- [ ] **Step 1: Write the dialog**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class TokenRevealDialog extends StatefulWidget {
  final String token;
  const TokenRevealDialog({super.key, required this.token});

  @override
  State<TokenRevealDialog> createState() => _TokenRevealDialogState();
}

class _TokenRevealDialogState extends State<TokenRevealDialog> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadDialog(
      title: const Text('API Token Created'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Warning banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.triangleAlert,
                    size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Copy the token below — this is your only chance to do so!',
                    style: TextStyle(
                      color: Colors.amber.shade200,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Token display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    widget.token,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ShadButton.ghost(
                  size: ShadButtonSize.icon,
                  icon: Icon(
                    _copied ? LucideIcons.check : LucideIcons.copy,
                    size: 16,
                    color: _copied ? Colors.green : null,
                  ),
                  onPressed: () async {
                    await Clipboard.setData(
                        ClipboardData(text: widget.token));
                    setState(() => _copied = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _copied = false);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ShadButton(
          child: const Text('Done'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add flutter_cms_manage/lib/src/screens/token_reveal_dialog.dart
git commit -m "feat: add TokenRevealDialog with copy-to-clipboard and warning banner"
```

### Task 15: Create manage providers

**Files:**
- Create: `flutter_cms_manage/lib/src/providers/manage_providers.dart`

- [ ] **Step 1: Write providers with Signals**

```dart
import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'package:signals/signals.dart';

import '../services/token_service.dart';

/// Global Serverpod client instance (initialized in main.dart)
late final Client serverpodClient;

/// Current authenticated CmsUser
final currentUser = signal<CmsUser?>(null);

/// Current CmsClient (resolved from URL slug)
final currentClient = signal<CmsClient?>(null);

/// All clients the user belongs to
final userClients = listSignal<CmsClient>([]);

/// Token service for the current client
TokenService? _tokenService;

TokenService get tokenService {
  final client = currentClient.value;
  if (client == null) throw StateError('No client selected');
  _tokenService ??= TokenService(
    client: serverpodClient,
    clientId: client.id!,
  );
  return _tokenService!;
}

/// Reset token service when client changes
void resetTokenService() {
  _tokenService = null;
}

/// Initialize client context from slug
Future<void> initClientContext(String clientSlug) async {
  final user = await serverpodClient.user.getCurrentUserBySlug(clientSlug);
  currentUser.value = user;

  final clients = await serverpodClient.user.getUserClients();
  userClients.value = clients;

  final client = clients.where((c) => c.slug == clientSlug).firstOrNull;
  currentClient.value = client;
  resetTokenService();
}
```

Note: The exact Serverpod client API names (`serverpodClient.user.getCurrentUserBySlug`, `serverpodClient.user.getUserClients`) depend on the generated client code. Adjust at implementation time.

- [ ] **Step 2: Commit**

```bash
git add flutter_cms_manage/lib/src/providers/manage_providers.dart
git commit -m "feat: add Signals-based manage providers for client context and token service"
```

- [ ] **Step 3: Verify full app compilation**

Run: `cd flutter_cms_manage && flutter analyze`
Expected: No errors (or only warnings about unused TODOs)

- [ ] **Step 4: Verify web build**

Run: `cd flutter_cms_manage && flutter build web --no-tree-shake-icons`
Expected: Build succeeds

---

## Chunk 6: Frontend — Overview Screen

### Task 16: Implement OverviewScreen

**Files:**
- Modify: `flutter_cms_manage/lib/src/screens/overview_screen.dart`

- [ ] **Step 1: Replace placeholder with full implementation**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../routes/manage_coordinator.dart';
import '../routes/tokens_route.dart';

class OverviewScreen extends StatelessWidget {
  final ManageCoordinator coordinator;
  const OverviewScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final slug = coordinator.clientSlug;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Project Overview', style: theme.textTheme.h3),
          const SizedBox(height: 24),
          // Quick stats row
          Row(
            children: [
              _StatCard(
                icon: LucideIcons.key,
                label: 'API Tokens',
                value: '—', // TODO: load from tokenService
              ),
              const SizedBox(width: 16),
              _StatCard(
                icon: LucideIcons.fileText,
                label: 'Documents',
                value: '—', // TODO: load from documentEndpoint
              ),
              const SizedBox(width: 16),
              _StatCard(
                icon: LucideIcons.users,
                label: 'Team Members',
                value: '—', // TODO: load from getClientUserCount
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Client details
          ShadCard(
            title: const Text('Project Details'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(label: 'Slug', value: slug),
                  _DetailRow(
                    label: 'Project ID',
                    value: slug,
                    copyable: true,
                  ),
                  _DetailRow(label: 'Status', value: 'Active'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quick links
          Row(
            children: [
              ShadButton.outline(
                leading: Icon(LucideIcons.externalLink, size: 16),
                child: const Text('Open Studio'),
                onPressed: () {
                  // TODO: Open Studio URL
                },
              ),
              const SizedBox(width: 12),
              ShadButton.outline(
                leading: Icon(LucideIcons.key, size: 16),
                child: const Text('Manage API Tokens'),
                onPressed: () =>
                    coordinator.push(TokensRoute(slug)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Expanded(
      child: ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.mutedForeground),
              const SizedBox(height: 8),
              Text(value, style: theme.textTheme.h2),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: theme.textTheme.muted),
          ),
          Text(value, style: theme.textTheme.p),
          if (copyable) ...[
            const SizedBox(width: 8),
            ShadButton.ghost(
              size: ShadButtonSize.icon,
              icon: Icon(LucideIcons.copy, size: 14),
              onPressed: () => Clipboard.setData(ClipboardData(text: value)),
            ),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add flutter_cms_manage/lib/src/screens/overview_screen.dart
git commit -m "feat: implement OverviewScreen with stat cards, project details, quick links"
```

---

## Chunk 7: Frontend — Settings Screen

### Task 17: Implement SettingsScreen

**Files:**
- Modify: `flutter_cms_manage/lib/src/screens/settings_screen.dart`

- [ ] **Step 1: Replace placeholder with full implementation**

```dart
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../routes/manage_coordinator.dart';

class SettingsScreen extends StatefulWidget {
  final ManageCoordinator coordinator;
  const SettingsScreen({super.key, required this.coordinator});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: theme.textTheme.h3),
          const SizedBox(height: 8),
          Text(
            'Manage your project settings.',
            style: theme.textTheme.muted,
          ),
          const SizedBox(height: 32),

          // Settings form
          ShadCard(
            title: const Text('General'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ShadForm(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShadInputFormField(
                      id: 'name',
                      label: const Text('Project name'),
                      // TODO: initialValue from currentClient
                    ),
                    const SizedBox(height: 16),
                    ShadTextareaFormField(
                      id: 'description',
                      label: const Text('Description'),
                      placeholder:
                          const Text('A brief description of your project'),
                      // TODO: initialValue from currentClient
                    ),
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      id: 'slug',
                      label: const Text('Slug'),
                      readOnly: true,
                      initialValue: widget.coordinator.clientSlug,
                    ),
                    const SizedBox(height: 16),
                    // Status toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Active', style: theme.textTheme.p),
                            Text(
                              'Deactivating will disable all API access',
                              style: theme.textTheme.muted,
                            ),
                          ],
                        ),
                        ShadSwitch(
                          value: true, // TODO: bind to currentClient.value?.isActive
                          onChanged: (value) {
                            if (!value) {
                              _showDeactivateConfirmation(context);
                            } else {
                              // TODO: call updateClient with isActive: true
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ShadButton(
                      enabled: !_isSaving,
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
                      onPressed: () async {
                        if (_formKey.currentState!.saveAndValidate()) {
                          setState(() => _isSaving = true);
                          // TODO: call updateClient endpoint
                          setState(() => _isSaving = false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Danger zone
          ShadCard(
            title: Row(
              children: [
                Icon(LucideIcons.triangleAlert,
                    size: 16, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Danger Zone'),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delete Project', style: theme.textTheme.p),
                      Text(
                        'Permanently delete this project and all its data.',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                  ShadButton.destructive(
                    child: const Text('Delete'),
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeactivateConfirmation(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Deactivate Project'),
        description: const Text(
          'Deactivating will disable all API access to this project. '
          'You can reactivate it later.',
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ShadButton.destructive(
            child: const Text('Deactivate'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              // TODO: Call updateClient with isActive: false
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Delete Project'),
        description: const Text(
          'Are you sure? This action cannot be undone. All associated data '
          'must be removed first.',
        ),
        actions: [
          ShadButton.outline(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ShadButton.destructive(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              // TODO: Call deleteClient endpoint
              // Handle FK constraint errors with toast
            },
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Verify full app compilation**

Run: `cd flutter_cms_manage && flutter analyze`
Expected: No errors

- [ ] **Step 3: Build web to verify everything works together**

Run: `cd flutter_cms_manage && flutter build web --no-tree-shake-icons`
Expected: Build succeeds

- [ ] **Step 4: Commit**

```bash
git add flutter_cms_manage/lib/src/screens/settings_screen.dart
git commit -m "feat: implement SettingsScreen with form, save, and danger zone"
```

- [ ] **Step 5: Final commit — all features complete**

```bash
git add -A
git commit -m "feat: Flutter CMS Manage app — complete initial implementation"
```

---

## Chunk 8: Frontend — Client Init + Wiring

### Task 18: Initialize Serverpod client and auth in main.dart

**Files:**
- Modify: `flutter_cms_manage/lib/main.dart`
- Modify: `flutter_cms_manage/lib/src/providers/manage_providers.dart`

- [ ] **Step 1: Add Serverpod client initialization to main.dart**

Update `main.dart` to initialize the Serverpod client before `runApp`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:flutter_cms_be_client/flutter_cms_be_client.dart';
import 'src/providers/manage_providers.dart';
import 'src/routes/manage_coordinator.dart';

void main() {
  usePathUrlStrategy();

  // Initialize Serverpod client
  serverpodClient = Client(
    'http://localhost:8080/',
    authenticationKeyManager: FlutterAuthenticationKeyManager(),
  )..connectivityMonitor = FlutterConnectivityMonitor();

  runApp(const ManageApp());
}
```

Note: The server URL should be configurable per environment. For now, hardcode localhost for development. The `FlutterAuthenticationKeyManager` and `FlutterConnectivityMonitor` come from `serverpod_flutter`.

- [ ] **Step 2: Commit**

```bash
git add flutter_cms_manage/lib/main.dart
git commit -m "feat: add Serverpod client initialization and auth to main.dart"
```

### Task 19: Wire TokensScreen to TokenService

**Files:**
- Modify: `flutter_cms_manage/lib/src/screens/tokens_screen.dart`

- [ ] **Step 1: Wire up TokenService in initState**

Replace the `initState` TODO block with actual service initialization:

```dart
  @override
  void initState() {
    super.initState();
    _tokenService = tokenService; // from manage_providers.dart
    _tokenService.loadTokens();
  }
```

Add the import at the top:
```dart
import '../providers/manage_providers.dart';
```

- [ ] **Step 2: Replace `_buildTokenTable` to watch signals**

```dart
  Widget _buildTokenTable(BuildContext context) {
    final theme = ShadTheme.of(context);
    final tokenList = _tokenService.tokens.watch(context);
    final loading = _tokenService.isLoading.watch(context);

    if (loading && tokenList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tokenList.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Name', style: theme.textTheme.muted)),
              Expanded(flex: 2, child: Text('Role', style: theme.textTheme.muted)),
              Expanded(flex: 2, child: Text('Token', style: theme.textTheme.muted)),
              Expanded(flex: 2, child: Text('Created', style: theme.textTheme.muted)),
              SizedBox(width: 60, child: Text('Status', style: theme.textTheme.muted)),
              const SizedBox(width: 40),
            ],
          ),
        ),
        // Token rows
        Expanded(
          child: ListView.builder(
            itemCount: tokenList.length,
            itemBuilder: (ctx, i) => _buildTokenRow(ctx, tokenList[i]),
          ),
        ),
      ],
    );
  }
```

- [ ] **Step 3: Wire up the create, regenerate, toggle, delete actions**

```dart
  void _showCreateTokenDialog(BuildContext context) {
    showShadDialog(
      context: context,
      builder: (ctx) => CreateTokenDialog(
        onCreateToken: (name, role, expiresAt) async {
          final result = await _tokenService.createToken(
            name: name, role: role, expiresAt: expiresAt);
          if (result != null && ctx.mounted) {
            Navigator.of(ctx).pop();
            _showTokenRevealDialog(context, result.plaintextToken);
          }
        },
      ),
    );
  }

  Future<void> _regenerateToken(CmsApiToken token) async {
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Regenerate Token'),
        description: const Text('This will invalidate the current token value. Continue?'),
        actions: [
          ShadButton.outline(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop(false)),
          ShadButton.destructive(child: const Text('Regenerate'), onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );
    if (confirmed == true) {
      final result = await _tokenService.regenerateToken(token.id!);
      if (result != null && mounted) {
        _showTokenRevealDialog(context, result.plaintextToken);
      }
    }
  }

  Future<void> _toggleToken(CmsApiToken token) async {
    await _tokenService.updateToken(
      tokenId: token.id!,
      isActive: !token.isActive,
    );
  }

  Future<void> _deleteToken(CmsApiToken token) async {
    final confirmed = await showShadDialog<bool>(
      context: context,
      builder: (ctx) => ShadDialog(
        title: const Text('Delete Token'),
        description: Text('Delete "${token.name}"? This cannot be undone.'),
        actions: [
          ShadButton.outline(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop(false)),
          ShadButton.destructive(child: const Text('Delete'), onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );
    if (confirmed == true) {
      await _tokenService.deleteToken(token.id!);
    }
  }
```

- [ ] **Step 4: Verify compilation**

Run: `cd flutter_cms_manage && flutter analyze`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add flutter_cms_manage/lib/src/screens/tokens_screen.dart
git commit -m "feat: wire TokensScreen to TokenService with full CRUD actions"
```

---

## Implementation Notes

### Adjustments expected at implementation time

1. **ShadApp.router** — verify `ShadApp` supports `routerConfig` parameter. If not, use `ShadApp.custom` with `MaterialApp.router(routerConfig: coordinator)`.

2. **Signals package version** — check if the existing Studio uses `signals` or `signals_flutter`. Match the same package and version.

3. **Generated client API names** — Serverpod generates client stubs like `client.cmsApiToken.getTokens(...)`. The exact names and parameter order depend on what `serverpod generate` produces. Verify after generation.

4. **Route `toUri()` coordinator access** — zenrouter's `RouteUnique.toUri()` may or may not have access to the coordinator. If not, pass `clientSlug` as a route field (the plan uses this approach).

5. **`ShadCard` constructor** — verify `title` parameter type. Some versions use `Widget? title` as a named parameter; others may differ. Check the shadcn_ui API reference.

6. **Token table** — the plan uses custom `Row`-based layout. Consider switching to `ShadTable` if available and fits the use case.

7. **Auth bootstrap in main.dart** — the plan omits Serverpod auth initialization for brevity. At implementation time, add `serverpod_auth_idp_flutter` setup similar to the existing Flutter app in `flutter_cms_be_flutter/`.
