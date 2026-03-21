# External Auth Strategy & DartDeskApp Refactor

**Date:** 2026-03-21
**Status:** Draft

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

/// Interface for external auth strategies (Payload-style, class-based)
abstract class ExternalAuthStrategy {
  String get name;

  /// Called once on server startup for setup (fetch JWKS keys, init SDK, etc.)
  Future<void> initialize(Session session) async {}

  /// Verify the request and return a user, or null to pass to next strategy.
  Future<ExternalAuthUser?> authenticate(
    Map<String, String> headers,
    Session session,
  );
}
```

#### Registration

Strategies are registered in `server.dart` alongside existing IDP config:

```dart
pod.initializeAuthServices(
  tokenManagerBuilders: [JwtConfigFromPasswords()],
  identityProviderBuilders: [
    GoogleIdpConfig(...),
    EmailIdpConfigFromPasswords(...),
  ],
  externalAuthStrategies: [
    FirebaseAuthStrategy(projectId: '...'),
    ClerkAuthStrategy(secretKey: '...'),
  ],
);
```

Multiple strategies are supported and tried in order (first non-null result wins).

#### Request Authentication Flow

1. Check Serverpod's built-in IDP auth first (existing behavior, unchanged)
2. If no Serverpod session, try external strategies in registration order
3. First strategy to return an `ExternalAuthUser` wins
4. Auto-create or match a `CmsUser` from the `ExternalAuthUser` (keyed on `externalId` + `externalProvider`)
5. If all strategies return null → request is unauthenticated

#### CmsUser Model Changes

Add two new fields to support external auth identity mapping:

```yaml
fields:
  clientId: int
  email: String
  name: String?
  role: String
  isActive: bool
  serverpodUserId: String?    # existing: for built-in auth
  externalId: String?          # NEW: unique ID from external auth provider
  externalProvider: String?    # NEW: which strategy name authenticated them
  createdAt: DateTime
  updatedAt: DateTime
```

User matching logic:
- Built-in auth: match on `serverpodUserId` (existing behavior)
- External auth: match on `externalId` + `externalProvider` + `clientId`

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
  final List<CmsDocumentType> documentTypes;
  final List<CmsDocumentTypeDecoration> documentTypeDecorations;

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

**`DartDeskApp()` — built-in auth (cloud/hosted):**

```dart
DartDeskApp(
  serverUrl: 'https://my-server.com/',
  clientId: 'my-client',
  apiToken: 'cms_ad_...',
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
- `ensureUser` on login
- Sign-out (no `onSignOut` callback needed)
- Creates `CloudDataSource(client)` for the studio

**`DartDeskApp.withDataSource()` — external auth / self-hosted:**

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
- No `clientId`/`apiToken` — those are cloud concerns

#### Widget Tree Access

Single `InheritedWidget` with static accessor, no context extensions:

```dart
final dartDesk = DartDesk.of(context);
dartDesk.dataSource   // CmsDataSource
dartDesk.signOut()    // VoidCallback
dartDesk.config       // DartDeskConfig
```

### Migration Path

- `FlutterCmsAuth` → deprecated, logic absorbed into `DartDeskApp()`
- `CmsStudioApp` → deprecated, renamed to `DartDeskApp`
- `FlutterCmsAuthContext` extension → removed, replaced by `DartDesk.of(context)`
- `_FlutterCmsAuthProvider` → replaced by `DartDesk` InheritedWidget

## Out of Scope

- Admin dashboard for managing external auth providers (config-only for now)
- Built-in implementations of specific external providers (Firebase, Clerk, etc.) — those are community packages
- Changes to the API token system (`CmsApiToken`)
- Changes to the manage app (`dart_desk_manage`) auth flow
