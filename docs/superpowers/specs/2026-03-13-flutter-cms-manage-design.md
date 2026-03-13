# Flutter CMS Manage — Design Spec

## Overview

A separate Flutter web app ("Manage") for project management of the Flutter CMS platform, inspired by Sanity Manage. Provides project overview, API token management, and client settings. Linked to the existing CMS Studio via header navigation.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| App location | Separate app: `flutter_cms_manage/` | Independent from Studio, clean separation of concerns |
| Relationship to Studio | Separate Flutter web deployment, linked via header | Like Sanity Manage — different app from the content editor |
| UI framework | shadcn_ui (dark theme, Slate color scheme) | Consistent with existing Studio |
| Router | zenrouter (Coordinator pattern) | Web app needs URL sync, deep linking, browser back button |
| State management | Signals | Same as existing Studio |
| Backend integration | Direct Serverpod client (`flutter_cms_be_client`) | Consistent with existing architecture, type-safe auto-generated client |
| Dashboard sections | Overview, API, Settings | Core set — expandable later |
| API token model | Multiple named tokens per client (`CmsApiToken`) | Industry standard (Stripe, Sanity, Supabase) |
| Token permissions | 3 levels: `viewer`, `editor`, `admin` | Simplified Sanity-style, sufficient for CMS use case |
| Token access | Any authenticated CmsUser of the client | No role restriction on token management |

## Data Model

### CmsApiToken (new Serverpod model)

```yaml
# cms_api_token.spy.yaml
class: CmsApiToken
table: cms_api_tokens
fields:
  clientId: int
  name: String
  tokenHash: String
  tokenPrefix: String              # "cms_vi_", "cms_ed_", "cms_ad_" (role-encoded)
  tokenSuffix: String              # last 4 chars for display ("...x7Kq")
  role: String                     # viewer | editor | admin
  createdByUserId: int?
  lastUsedAt: DateTime?
  expiresAt: DateTime?
  isActive: bool
  createdAt: DateTime
indexes:
  cms_api_token_client_idx:
    fields: clientId
  cms_api_token_prefix_idx:
    fields: tokenPrefix
```

### CmsApiTokenWithValue (serialization only, not stored)

```yaml
class: CmsApiTokenWithValue
fields:
  token: CmsApiToken
  plaintextToken: String
```

### Token format

- Pattern: `cms_{role_prefix}_{base64(32 random bytes)}`
- Role prefixes: `vi` (viewer), `ed` (editor), `ad` (admin)
- Example: `cms_ed_a6YkZWe82WpTevvPem3ynitEBWky2J0FZpj9ycAk6S4WM4u`
- Storage: bcrypt hash in `tokenHash`, first 8 chars in `tokenPrefix`, last 4 in `tokenSuffix`
- Display: `cms_ed_...x7Kq` (prefix + suffix)
- Shown once: full plaintext token returned only at creation/regeneration

## API Endpoint

### CmsApiTokenEndpoint

```dart
class CmsApiTokenEndpoint extends Endpoint {
  /// List all tokens for a client (metadata only, never the hash)
  Future<List<CmsApiToken>> getTokens(Session session, int clientId)

  /// Create a new named token — returns plaintext token (shown once)
  Future<CmsApiTokenWithValue> createToken(
    Session session,
    int clientId,
    String name,
    String role,          // viewer | editor | admin
    DateTime? expiresAt,
  )

  /// Update token metadata (name, isActive, expiresAt)
  Future<CmsApiToken> updateToken(Session session, int tokenId, ...)

  /// Regenerate token value — returns new plaintext token (shown once)
  Future<CmsApiTokenWithValue> regenerateToken(Session session, int tokenId)

  /// Delete a token permanently
  Future<bool> deleteToken(Session session, int tokenId)
}
```

**Auth:** All methods require `session.authenticated`. Verify caller is a CmsUser belonging to the given `clientId`.

**Token validation changes:** Update `UserEndpoint.ensureUser()` to also check `cms_api_tokens` table, matching by bcrypt and respecting `isActive`, `expiresAt`, and `role`.

## App Structure

```
flutter_cms_manage/
├── lib/
│   ├── main.dart                    # ShadApp entry, auth, URL strategy
│   ├── src/
│   │   ├── routes/
│   │   │   ├── manage_route.dart    # abstract ManageRoute extends RouteTarget with RouteUnique
│   │   │   ├── manage_coordinator.dart
│   │   │   ├── manage_layout.dart   # RouteLayout — shared shell (top bar, project header, tabs)
│   │   │   ├── api_layout.dart      # RouteLayout — API tab (left sidebar + content)
│   │   │   ├── overview_route.dart
│   │   │   ├── tokens_route.dart
│   │   │   ├── settings_route.dart
│   │   │   └── not_found_route.dart
│   │   ├── screens/
│   │   │   ├── overview_screen.dart
│   │   │   ├── tokens_screen.dart
│   │   │   ├── create_token_dialog.dart
│   │   │   ├── token_reveal_dialog.dart
│   │   │   └── settings_screen.dart
│   │   ├── services/
│   │   │   └── token_service.dart
│   │   └── providers/
│   │       └── manage_providers.dart
├── pubspec.yaml
```

## Routing (zenrouter Coordinator)

### Route hierarchy

```
ManageLayout (top bar + project header + tabs)
├── OverviewRoute    → /overview
├── ApiLayout (left sidebar for API sub-sections)
│   └── TokensRoute  → /api/tokens
└── SettingsRoute    → /settings
/                    → redirects to /overview
```

### Coordinator

```dart
class ManageCoordinator extends Coordinator<ManageRoute> {
  late final manageStack = NavigationPath.createWith(
    label: 'manage', coordinator: this,
  )..bindLayout(ManageLayout.new);

  late final apiStack = NavigationPath.createWith(
    label: 'api', coordinator: this,
  )..bindLayout(ApiLayout.new);

  @override
  List<StackPath> get paths => [...super.paths, manageStack, apiStack];

  @override
  ManageRoute parseRouteFromUri(Uri uri) {
    return switch (uri.pathSegments) {
      [] => OverviewRoute(),
      ['overview'] => OverviewRoute(),
      ['api', 'tokens'] => TokensRoute(),
      ['settings'] => SettingsRoute(),
      _ => NotFoundRoute(),
    };
  }
}
```

### Layout routes

```dart
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
```

### Leaf routes

```dart
class OverviewRoute extends ManageRoute {
  @override
  Type get layout => ManageLayout;
  @override
  Uri toUri() => Uri.parse('/overview');
  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      OverviewScreen(coordinator: coordinator);
}

class TokensRoute extends ManageRoute {
  @override
  Type get layout => ApiLayout;
  @override
  Uri toUri() => Uri.parse('/api/tokens');
  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      TokensScreen(coordinator: coordinator);
}

class SettingsRoute extends ManageRoute {
  @override
  Type get layout => ManageLayout;
  @override
  Uri toUri() => Uri.parse('/settings');
  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      SettingsScreen(coordinator: coordinator);
}
```

## UI Layout

### ManageShell (ManageLayout's widget)

Dark theme layout with:
- **Top bar**: Logo ("Flutter CMS"), project name, "Open Studio →" link, user avatar
- **Project header**: Client avatar, client name, client ID, status badge
- **Tab navigation**: Overview | API | Settings (active tab highlighted with accent border)

### ApiShell (ApiLayout's widget)

- **Left sidebar** (180px): Sub-section links — Tokens (active), CORS Origins (future), more
- **Content area**: Renders child route (TokensScreen)

### TokensScreen

- **Header**: "Tokens" title, description text, "+ Add API token" button
- **Table**: Columns — Name, Role (color-coded badge), Prefix (`cms_ed_...x7Kq`), Created (relative time), Actions menu (⋯)
- **Empty state**: Illustration + "There are no API tokens yet" message
- **Role badge colors**: viewer (purple), editor (green), admin (amber)

### CreateTokenDialog (ShadDialog)

- **Token name**: ShadInputFormField
- **Permission level**: 3-way selector (Viewer / Editor / Admin) with descriptions
- **Expiration**: Optional date picker, default "Never expires"
- **Actions**: Cancel, Create Token

### TokenRevealDialog

- **Warning banner**: "Copy the token below — this is your only chance to do so!"
- **Token display**: Monospace code block with full plaintext token + copy button
- **Action**: Done button (closes dialog)

### Token actions (context menu per row)

- Regenerate token → confirms, then shows TokenRevealDialog with new token
- Disable/Enable token → toggles `isActive`
- Delete token → confirms, then removes

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  shadcn_ui: ^0.52.0
  zenrouter: ^0.1.0
  signals: # same version as Studio
  flutter_cms_be_client:
    path: ../flutter_cms_be_client
  serverpod_auth_shared_flutter: ^2.9.2
  lucide_icons_flutter: # included with shadcn_ui
  flutter_animate: # included with shadcn_ui
  intl: # for date formatting
```

## Implementation Order

1. **Backend first**: `CmsApiToken` model + migration + `CmsApiTokenEndpoint`
2. **App scaffold**: `flutter_cms_manage/` with ShadApp, zenrouter coordinator, ManageLayout
3. **Tokens feature**: TokensScreen, CreateTokenDialog, TokenRevealDialog, token service
4. **Overview screen**: Basic project info display (client details, stats)
5. **Settings screen**: Client configuration (name, description, etc.)
6. **Token validation**: Update `UserEndpoint.ensureUser()` to check `cms_api_tokens` table

## Future Expansion

The navigation structure supports adding more sections:
- **Members** tab (user management) — add to ManageLayout tabs
- **API > CORS Origins** — add as sibling to TokensRoute under ApiLayout
- **Usage** tab (analytics/stats) — add to ManageLayout tabs
- **Billing/Plan** tab — add to ManageLayout tabs
