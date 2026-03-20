# Dart Desk Manage — Design Spec

## Overview

A separate Flutter web app ("Manage") for project management of the Dart Desk platform, inspired by Sanity Manage. Provides project overview, API token management, and client settings. Linked to the existing CMS Studio via header navigation.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| App location | Separate app: `dart_desk_manage/` | Independent from Studio, clean separation of concerns |
| Relationship to Studio | Separate Flutter web deployment, linked via header | Like Sanity Manage — different app from the content editor |
| UI framework | shadcn_ui (dark theme, Slate color scheme) | Consistent with existing Studio |
| Router | zenrouter (Coordinator pattern) | Web app needs URL sync, deep linking, browser back button |
| State management | Signals | Same as existing Studio |
| Backend integration | Direct Serverpod client (`dart_desk_be_client`) | Consistent with existing architecture, type-safe auto-generated client |
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
  createdByUserId: int?            # nullable for tokens created via admin seeding/migration
  lastUsedAt: DateTime?
  expiresAt: DateTime?
  isActive: bool
  createdAt: DateTime
indexes:
  cms_api_token_client_idx:
    fields: clientId
  cms_api_token_lookup_idx:
    fields: clientId, tokenPrefix, tokenSuffix
    unique: true
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
- Storage: bcrypt hash in `tokenHash`, role prefix in `tokenPrefix` (e.g., `cms_ed_`), last 4 chars of the full token string in `tokenSuffix`
- Collision handling: if `(clientId, tokenPrefix, tokenSuffix)` already exists, regenerate the random portion until unique (retry up to 5 times)
- Display: `cms_ed_...x7Kq` (prefix + suffix)
- Shown once: full plaintext token returned only at creation/regeneration

### Migration from existing CmsClient.apiTokenHash

The existing `apiTokenHash` and `apiTokenPrefix` fields on `CmsClient` remain for backward compatibility. They serve as the **bootstrap token** — the first token created when a client is set up via the admin endpoint (`CmsClientEndpoint.createClient()`). This token has implicit `admin` role.

Going forward:
- New tokens are created via `CmsApiTokenEndpoint` and stored in `cms_api_tokens`
- The Manage app authenticates users via Serverpod auth (Google/email IDP), not via API tokens
- API tokens are for external app/script access to the CMS data API
- The existing `CmsClient.apiTokenHash` continues to work as a fallback during token validation

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

  /// Update token metadata. Looks up token by ID, verifies its clientId matches caller's client.
  Future<CmsApiToken> updateToken(
    Session session,
    int tokenId,
    String? name,
    bool? isActive,
    DateTime? expiresAt,
  )

  /// Regenerate token value. Verifies token belongs to caller's client. Returns new plaintext token (shown once).
  Future<CmsApiTokenWithValue> regenerateToken(Session session, int tokenId)

  /// Delete a token permanently. Verifies token belongs to caller's client.
  Future<bool> deleteToken(Session session, int tokenId)
}
```

**Auth:** All methods require `session.authenticated` (Serverpod auth via Google/email IDP). The Manage app user is authenticated as a Serverpod user, and their CmsUser record (via `UserEndpoint.getCurrentUser()`) determines which `clientId` they belong to. The endpoint verifies the caller's `clientId` matches the requested `clientId`.

**Token validation changes:** Update `UserEndpoint.ensureUser()` to check tokens in this order:
1. Extract the role prefix from the incoming token (e.g., `cms_ed_`) and the suffix (last 4 chars)
2. Query `cms_api_tokens` by `clientId` + `tokenPrefix` + `tokenSuffix` + `isActive = true` — this narrows to at most 1 candidate
3. bcrypt-verify the incoming token against the single candidate's `tokenHash`
4. If no match in `cms_api_tokens`, fall back to `CmsClient.apiTokenHash` (backward compatibility for `cms_live_` tokens)
5. The matched token's `role` determines API permissions for that request
6. Reject if `expiresAt` is set and has passed

Add composite index `(clientId, tokenPrefix, tokenSuffix)` for efficient lookup.

## Manage App Authentication & Client Context

The Manage app authenticates users via **Serverpod auth (Google/email IDP)**, not via API tokens. API tokens are for external app/script access to the CMS data API.

**Client context resolution:**
- A Serverpod user can belong to multiple clients (multiple `CmsUser` rows with different `clientId`)
- The Manage app URL includes the client slug: `/manage/:clientSlug/overview`, `/manage/:clientSlug/api/tokens`, etc.
- On app load, the Manage app fetches all `CmsUser` records for the authenticated `serverpodUserId` to get the list of clients the user has access to
- The `clientSlug` from the URL determines which client is active

**New endpoint needed:** `UserEndpoint.getUserClients(Session session)` — returns all `CmsClient` records the authenticated user belongs to. This enables the client switcher if a user has access to multiple clients.

**New endpoints needed:**
- `UserEndpoint.getUserClients(Session session)` — returns all `CmsClient` records the authenticated user belongs to
- `UserEndpoint.getCurrentUserBySlug(Session session, String clientSlug)` — resolves the CmsUser from `session.authenticated` + `clientSlug` without requiring an API token (for Manage app use)
- `UserEndpoint.getClientUserCount(Session session, int clientId)` — returns count of CmsUsers for a client (for Overview stats)

The existing `getCurrentUser()` method (requiring `clientSlug` + `apiToken`) remains unchanged for Studio/API use.

## App Structure

```
dart_desk_manage/
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
/:clientSlug/                → redirects to /:clientSlug/overview
ManageLayout (top bar + project header + tabs)
├── OverviewRoute    → /:clientSlug/overview
├── ApiLayout (left sidebar for API sub-sections)
│   └── TokensRoute  → /:clientSlug/api/tokens
└── SettingsRoute    → /:clientSlug/settings
```

### Coordinator

```dart
class ManageCoordinator extends Coordinator<ManageRoute> {
  String clientSlug; // set from URL, drives client context

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
    final segments = uri.pathSegments;
    if (segments.isEmpty) return NotFoundRoute();

    clientSlug = segments.first;
    final rest = segments.skip(1).toList();

    return switch (rest) {
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
  Uri toUri() => Uri.parse('/${coordinator.clientSlug}/overview');
  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      OverviewScreen(coordinator: coordinator);
}

class TokensRoute extends ManageRoute {
  @override
  Type get layout => ApiLayout;
  @override
  Uri toUri() => Uri.parse('/${coordinator.clientSlug}/api/tokens');
  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      TokensScreen(coordinator: coordinator);
}

class SettingsRoute extends ManageRoute {
  @override
  Type get layout => ManageLayout;
  @override
  Uri toUri() => Uri.parse('/${coordinator.clientSlug}/settings');
  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      SettingsScreen(coordinator: coordinator);
}
```

## UI Layout

### ManageShell (ManageLayout's widget)

Dark theme layout with:
- **Top bar**: Logo ("Dart Desk"), project name, "Open Studio →" link, user avatar
- **Project header**: Client avatar, client name, client ID, status badge
- **Tab navigation**: Overview | API | Settings (active tab highlighted with accent border)

### ApiShell (ApiLayout's widget)

- **Left sidebar** (180px): Sub-section links — Tokens (active), CORS Origins (future), more
- **Content area**: Renders child route (TokensScreen)

### OverviewScreen

Displays client project information:
- **Client details**: name, slug, description, `isActive` status
- **Client ID**: copyable display
- **Quick stats**: number of API tokens (from `CmsApiTokenEndpoint.getTokens()`), number of documents (from `DocumentEndpoint.getDocuments()` with `limit: 1` to get total count from response), number of CMS users (new: `UserEndpoint.getClientUserCount()`)
- **Quick links**: "Open Studio" button, "Manage API Tokens" button

### SettingsScreen

Client configuration form using ShadForm:
- **Client name**: ShadInputFormField (editable)
- **Description**: ShadTextareaFormField (editable)
- **Slug**: ShadInputFormField (read-only display)
- **Status**: Toggle `isActive` with confirmation dialog
- **Save button**: Calls `CmsClientEndpoint.updateClient()`
- **Danger zone**: Delete client with confirmation dialog. If FK constraint error occurs (users/documents exist), display error toast explaining the client cannot be deleted until all associated data is removed first

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
  dart_desk_be_client:
    path: ../dart_desk_be_client
  serverpod_auth_shared_flutter: ^2.9.2
  lucide_icons_flutter: # included with shadcn_ui
  flutter_animate: # included with shadcn_ui
  intl: # for date formatting
```

## Implementation Order

1. **Backend: model + migration**: `CmsApiToken` model, `CmsApiTokenWithValue`, `serverpod generate`, `serverpod create-migration`
2. **Backend: endpoint + token validation**: `CmsApiTokenEndpoint`, update `UserEndpoint.ensureUser()` to check `cms_api_tokens` with prefix-based lookup
3. **App scaffold**: `dart_desk_manage/` with ShadApp, zenrouter coordinator, ManageLayout, ApiLayout, shell widgets
4. **Tokens feature**: TokensScreen, CreateTokenDialog, TokenRevealDialog, token service
5. **Overview screen**: Client details, quick stats, quick links
6. **Settings screen**: Client config form with ShadForm, save/delete actions

## Future Expansion

The navigation structure supports adding more sections:
- **Members** tab (user management) — add to ManageLayout tabs
- **API > CORS Origins** — add as sibling to TokensRoute under ApiLayout
- **Usage** tab (analytics/stats) — add to ManageLayout tabs
- **Billing/Plan** tab — add to ManageLayout tabs
