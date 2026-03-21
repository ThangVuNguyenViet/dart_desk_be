# External Auth Strategy & DartDeskApp Refactor

**Date:** 2026-03-21
**Status:** Draft
**Depends on:** Multi-Tenancy Extraction (Spec 1)

## Goal

Allow developers using Dart Desk to integrate their own authentication solution (Firebase Auth, Clerk, Auth0, etc.) instead of being locked into Serverpod's built-in IDP. Simultaneously refactor the client-side API for a cleaner developer experience.

## Design

### Server-Side: External Auth Strategy System

#### New Types

```dart
/// Returned by external auth strategies
class ExternalAuthUser {
  final String externalId;  // unique ID in the external system
  final String email;
  final String? name;
  final Map<String, dynamic>? metadata;
}

/// Interface for external auth strategies (Payload CMS-style, class-based)
abstract class ExternalAuthStrategy {
  String get name;

  /// Called once on server startup for setup (fetch JWKS keys, init SDK, etc.)
  /// Does not take Session — use config/env for initialization.
  Future<void> initialize() async {}

  /// Called on server shutdown for cleanup (close connections, etc.)
  Future<void> dispose() async {}

  /// Verify the request and return a user, or null to pass to next strategy.
  /// Return null for unrecognized tokens (e.g., wrong format for this strategy).
  /// Only throw for unexpected errors (network failure, SDK crash, etc.)
  /// — thrown exceptions fail the request immediately, skipping remaining strategies.
  Future<ExternalAuthUser?> authenticate(
    Map<String, String> headers,
    Session session,
  );
}
```

#### Registration

Strategies are registered via `DartDeskAuth`, separate from Serverpod's `initializeAuthServices`:

```dart
// Configure external auth strategies
DartDeskAuth.configure(
  externalStrategies: [
    FirebaseAuthStrategy(projectId: '...'),
    ClerkAuthStrategy(secretKey: '...'),
  ],
);

// Serverpod's built-in IDP still works alongside
pod.initializeAuthServices(
  tokenManagerBuilders: [JwtConfigFromPasswords()],
  identityProviderBuilders: [
    EmailIdpConfigFromPasswords(...),
  ],
);
```

Multiple strategies are supported and tried in order (first non-null result wins).

#### Request Authentication Flow

1. Check Serverpod's built-in IDP auth first (`session.authenticated` — populated by `initializeAuthServices`)
2. If `session.authenticated` is null, try external strategies in registration order
3. First strategy to return an `ExternalAuthUser` wins
4. Look up or auto-create a `User` record (keyed on `externalId` + `externalProvider`)
5. If a strategy throws → fail the request immediately (unexpected error)
6. If all strategies return null → request is unauthenticated

#### Integration Point

Serverpod's `initializeAuthServices` sets its own `AuthenticationHandler` — we cannot replace it. Instead, the external auth check happens **inside endpoint methods**, not at the framework level.

```dart
/// Helper that checks Serverpod IDP first, then falls back to external strategies
class DartDeskAuth {
  static List<ExternalAuthStrategy> _strategies = [];

  static void configure({List<ExternalAuthStrategy> externalStrategies = const []}) {
    _strategies = externalStrategies;
  }

  /// Get authenticated user. Checks Serverpod IDP first, then external strategies.
  static Future<User?> authenticateRequest(Session session) async {
    // 1. Check Serverpod built-in auth
    final authInfo = session.authenticated;
    if (authInfo != null) {
      return User.db.findFirstRow(session,
        where: (t) => t.serverpodUserId.equals(authInfo.userIdentifier));
    }

    // 2. Try external strategies
    final headers = session.httpRequest.headers;
    for (final strategy in _strategies) {
      final extUser = await strategy.authenticate(headers, session);
      if (extUser != null) {
        return _findOrCreateUser(session, extUser, strategy.name);
      }
    }

    return null; // unauthenticated
  }

  static Future<User> _findOrCreateUser(
    Session session, ExternalAuthUser extUser, String providerName,
  ) async {
    final tenantId = await DartDeskTenancy.resolveTenantId(session);

    // Try to find existing user
    var user = await User.db.findFirstRow(session,
      where: (t) =>
        t.externalId.equals(extUser.externalId) &
        t.externalProvider.equals(providerName) &
        (tenantId != null ? t.tenantId.equals(tenantId) : t.tenantId.isNull()),
    );

    if (user != null) return user;

    // Auto-create with default role
    user = User(
      tenantId: tenantId,
      email: extUser.email,
      name: extUser.name,
      role: 'viewer',
      isActive: true,
      externalId: extUser.externalId,
      externalProvider: providerName,
    );

    return User.db.insertRow(session, user);
  }
}
```

**Endpoints use it like:**

```dart
class DocumentEndpoint extends Endpoint {
  Future<List<Document>> getDocuments(Session session, ...) async {
    final user = await DartDeskAuth.authenticateRequest(session);
    if (user == null) throw AuthenticationException();
    // ... query documents
  }
}
```

This avoids the `AuthenticationHandler` composition problem entirely — the check is explicit in endpoint code.

#### Admin Bootstrap for External-Auth-Only Deployments

When using external auth without Serverpod IDP, there's no `_seedAdminUser()`. Instead:

**Option 1 (config-based):** Declare an admin email in server config. First user matching that email gets `admin` role automatically:

```dart
DartDeskAuth.configure(
  externalStrategies: [FirebaseAuthStrategy(...)],
  adminEmails: ['admin@example.com'],  // first login with this email → admin
);
```

**Option 2 (CLI-based):** `serverpod` CLI command to promote a user:
```bash
dart run bin/promote_admin.dart --email admin@example.com
```

Both options work. Option 1 is simpler for initial setup.

#### User Model Changes

Add two new fields to `User` for external auth identity mapping (additive migration on top of Spec 1):

```yaml
# user.spy.yaml
class: User
table: users
fields:
  tenantId: int?
  email: String
  name: String?
  role: String, default='viewer'
  isActive: bool, default=true
  serverpodUserId: String?      # for built-in Serverpod IDP auth
  externalId: String?            # NEW: unique ID from external auth provider
  externalProvider: String?      # NEW: which strategy name authenticated them
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

**Note on `users_external_id_idx`:** PostgreSQL allows multiple rows with `NULL` in unique indexes (`NULL != NULL`). This is correct behavior — Serverpod IDP users have `externalId = NULL` and won't conflict with each other. The unique constraint only enforces uniqueness for non-null combinations.

User matching logic:
- Built-in auth: match on `serverpodUserId` (existing behavior)
- External auth: match on `externalId` + `externalProvider` (+ `tenantId` if multi-tenant)

#### Token Expiry and Caching

- External strategies receive headers on **every request** — stateless by design. Short-lived tokens (Firebase ID tokens, 1hr) work naturally since the client refreshes them.
- `DartDeskAuth.authenticateRequest()` does a DB lookup per request. For high-traffic deployments, an optional in-memory cache (keyed on `externalId`, TTL ~60s) can be added later. Not in scope for initial implementation.
- If an external token is expired, the strategy should return `null` (not throw). The client receives a 401 and triggers re-authentication.
- WebSocket/streaming connections: re-authentication happens on reconnect, not mid-connection.

### Client-Side: DartDeskApp Refactor

#### Remove `FlutterCmsAuth` as Public API

The current `FlutterCmsAuth` widget mixes cloud-specific concerns (`clientId`, `apiToken`) with auth UI and state management. It is replaced by `DartDeskApp`.

#### Rename `CmsStudioApp` → `DartDeskApp`

#### Configuration Class

```dart
class DartDeskConfig {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final ShadThemeData? theme;
  final List<DocumentType> documentTypes;
  final List<DocumentTypeDecoration> documentTypeDecorations;

  const DartDeskConfig({
    required this.documentTypes,
    required this.documentTypeDecorations,
    this.title = 'Dart Desk',
    this.subtitle,
    this.icon,
    this.theme,
  });
}
```

#### Two Constructors

**`DartDeskApp()` — built-in auth:**

```dart
DartDeskApp(
  serverUrl: 'https://my-server.com/',
  config: DartDeskConfig(
    documentTypes: [...],
    documentTypeDecorations: [...],
    title: 'My CMS',
    icon: Icons.dashboard,
  ),
)
```

Internally handles:
- Client creation and Serverpod auth initialization (Google + email)
- Built-in sign-in screen when unauthenticated
- User creation on login (server-side via `DartDeskAuth.authenticateRequest`, no more client-side `ensureUser` with `clientSlug`/`apiToken`)
- Sign-out (no `onSignOut` callback needed)
- Creates `CloudDataSource(client)` for the studio

**`DartDeskApp.withDataSource()` — external auth:**

```dart
DartDeskApp.withDataSource(
  dataSource: CloudDataSource(myAuthenticatedClient),
  onSignOut: () => myAuth.signOut(),
  config: DartDeskConfig(
    documentTypes: [...],
    documentTypeDecorations: [...],
  ),
)
```

- Developer owns auth entirely (sign-in, token management, client setup)
- `onSignOut` is required since Dart Desk doesn't own auth
- No cloud-specific params (`clientId`, `apiToken`)
- Token refresh is the developer's responsibility — when the Dart Desk client receives a 401, the developer's auth layer should refresh and retry

#### Widget Tree Access

Single `InheritedWidget` with static accessor:

```dart
final dartDesk = DartDesk.of(context);
dartDesk.dataSource   // DataSource
dartDesk.signOut()    // VoidCallback
dartDesk.config       // DartDeskConfig
```

No context extensions.

#### What Replaces `ensureUser`

The current flow: client calls `ensureUser(clientSlug, apiToken)` after login to create `CmsUser`.

After refactor:
- **Built-in auth:** `DartDeskAuth.authenticateRequest()` on the server finds or creates the `User` on first API call. No explicit client-side `ensureUser` needed.
- **External auth:** Same — `DartDeskAuth.authenticateRequest()` auto-creates `User` from `ExternalAuthUser` on first request.
- The `ensureUser` endpoint is **removed**. User creation is an implicit server-side concern.

### Migration Path

- `FlutterCmsAuth` → removed, logic absorbed into `DartDeskApp()`
- `CmsStudioApp` → removed, renamed to `DartDeskApp`
- `FlutterCmsAuthContext` extension → removed, replaced by `DartDesk.of(context)`
- `_FlutterCmsAuthProvider` → replaced by `DartDesk` InheritedWidget
- `CmsDocumentType` → `DocumentType`
- `CmsDocumentTypeDecoration` → `DocumentTypeDecoration`
- `CmsDataSource` → `DataSource`
- `ensureUser` endpoint → removed (user creation is server-side implicit)

### Migration Ordering

Spec 1 creates the `users` table with the base fields. Spec 2 adds `externalId` and `externalProvider` columns via a **separate, additive migration** — not a modification of Spec 1's migration.

## Out of Scope

- Admin dashboard for managing external auth providers (config-only for now)
- Built-in implementations of specific external providers (Firebase, Clerk, etc.) — those are community packages
- Changes to the manage app (`dart_desk_manage`) auth flow
- Multi-tenancy (handled by Spec 1 and `dart_desk_cloud` plugin)
- Per-request caching of external auth results (optimization for later)
