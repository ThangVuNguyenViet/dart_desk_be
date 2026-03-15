# Auth Flow & New User Onboarding — flutter_cms_manage

## Problem

The flutter_cms_manage web app assumes users are already authenticated and navigating to a known `/{clientSlug}` URL. Visiting `/` shows "Page not found." New users have no way to sign in or create their first project.

## Solution

Add authentication gating, a Google sign-in screen, a new-user setup wizard, and smart redirects — all driven by the `ManageCoordinator`.

## Auth Flow

```
User visits any URL
  → AuthGate widget checks: is user authenticated? (via serverpodClient.auth session stream)
    ✗ Not authenticated → shows LoginScreen (Google sign-in)
    ✓ Authenticated → calls getUserClients()
      ✗ No clients → shows SetupWizardScreen (create first project)
      ✓ Has clients → renders the destination route resolved by coordinator:
        - /{slug}/overview → OverviewRoute
        - /{slug}/api/tokens → TokensRoute
        - / (1 client) → coordinator redirects to /{slug}/overview
        - / (N clients) → ClientPickerRoute
```

## Routing Design

### Reserved Paths vs. Client Slugs

The coordinator must distinguish reserved paths from client slugs. Reserved first-segment values: `login`, `setup`.

```dart
// In parseRouteFromUri:
final segments = uri.pathSegments;

// 1. Root URL
if (segments.isEmpty) return ClientPickerRoute();

// 2. Reserved paths (NOT client slugs)
if (segments.first == 'login') return LoginRoute();
if (segments.first == 'setup') return SetupWizardRoute();

// 3. Everything else: treat first segment as clientSlug
clientSlug = segments.first;
// ... existing slug-based routing
```

### Slug Validation

Slugs must NOT collide with reserved paths. Validation rules:
- Minimum 3 characters, maximum 63 characters
- Lowercase alphanumeric and hyphens only (`[a-z0-9-]+`)
- Cannot start or end with a hyphen
- Cannot be a reserved word: `login`, `setup`, `admin`, `api`, `app`
- Enforced both in the wizard UI and the `createClientWithOwner` endpoint

### Route Definitions

All routes extend `ManageRoute`. Auth screens use no layout (fullscreen centered). App screens use `ManageLayout`/`ApiLayout` as before.

```
ManageRoute (base, abstract)
├── LoginRoute           — layout: null, toUri: /login
├── SetupWizardRoute     — layout: null, toUri: /setup
├── ClientPickerRoute    — layout: null, toUri: /
├── OverviewRoute(slug)  — layout: ManageLayout, toUri: /{slug}/overview
├── TokensRoute(slug)    — layout: ApiLayout, toUri: /{slug}/api/tokens
├── SettingsRoute(slug)  — layout: ManageLayout, toUri: /{slug}/settings
└── NotFoundRoute        — layout: null, toUri: /404
```

Routes with `layout: null` render fullscreen without the sidebar/nav shell. This is achieved by not overriding the `layout` getter (or returning `null` if ZenRouter supports it), so no `RouteLayout` shell wraps them.

### AuthGate — Widget, Not Route

The `AuthGate` is a **widget that wraps the router delegate output**, not a route. It sits in `ManageApp.build()` and intercepts rendering based on auth state:

```dart
// In ManageApp.build():
ShadApp.router(
  routeInformationParser: coordinator.routeInformationParser,
  routerDelegate: coordinator.routerDelegate,
  builder: (context, child) => AuthGate(child: child!),
)
```

**AuthGate behavior:**
1. Listens to `serverpodClient.auth` session stream (via `serverpod_auth_idp_flutter`)
2. If unauthenticated → renders `LoginScreen` (ignoring `child`)
3. If authenticated but clients not yet loaded → shows loading spinner
4. If authenticated and no clients → renders `SetupWizardScreen`
5. If authenticated and has clients → renders `child` (the router's output)

This means LoginRoute and SetupWizardRoute exist as route objects (for URL representation) but the AuthGate widget overrides what's actually shown based on auth state. The URL stays correct for bookmarking/sharing.

### Navigation After Login/Setup

- **After Google sign-in completes:** Auth session stream emits authenticated state → AuthGate rebuilds → fetches clients → decides next screen
- **After wizard creates project:** Add new client to `userClients` signal immediately (don't re-fetch). Then call `coordinator.setNewRoutePath(OverviewRoute(newSlug))` to navigate.
- **After picking a client:** Call `coordinator.setNewRoutePath(OverviewRoute(slug))` to navigate.

## Backend Changes

### New Endpoint: createClientWithOwner

**Location:** `cms_client_endpoint.dart`

```dart
Future<CmsClient> createClientWithOwner(Session session, {
  required String name,
  required String slug,
}) async
```

**Implementation:**
- Requires Serverpod auth (`session.authenticated`)
- Validates slug: format rules (see above), uniqueness, not reserved
- Wraps in a database transaction:
  1. Creates `CmsClient` with:
     - `name`, `slug` from params
     - `apiTokenHash`: generate a random token, bcrypt-hash it (same pattern as existing `createClient`)
     - `apiTokenPrefix`: store prefix for lookup
     - `isActive: true`
     - `createdAt/updatedAt: DateTime.now()`
  2. Creates `CmsUser` with:
     - `clientId`: the new client's ID
     - `email`: from auth profile (`serverpod_auth_core_profile` lookup via `session.authenticated.userIdentifier`)
     - `role: 'admin'`
     - `serverpodUserId`: from `session.authenticated.userIdentifier`
     - `isActive: true`
  3. Returns the created `CmsClient` (token is internal, not exposed to the manage UI — users create API tokens explicitly via the Tokens screen)

### getUserClients — No Changes Needed

Existing `UserEndpoint.getUserClients()` queries by `serverpodUserId` matching the authenticated session. Works as-is.

## Frontend Components

### LoginScreen

- Stateless widget, fullscreen centered layout (dark background matching app theme)
- "Flutter CMS" title, "Sign in to manage your projects" subtitle
- Single "Sign in with Google" `ShadButton`
- Triggers Google OAuth via `serverpod_auth_idp_flutter` package
- Shows loading indicator during auth handshake
- Shows error toast on failure
- **Google OAuth web setup:** Requires Google Client ID configured in `web/index.html` meta tag and in Serverpod's `GoogleIdpConfig`. This should already be configured since `server.dart` has `GoogleIdpConfig`.

### SetupWizardScreen

- Stateful widget with `ShadForm`, fullscreen centered layout
- "Welcome! Create your project" heading
- Single `ShadInputFormField` for project name (min 3 chars)
- Live slug preview below input: `generateSlug(name)` → lowercase, replace `[^a-z0-9]+` with hyphens, trim hyphens
- "Create Project" `ShadButton`
- Loading state during creation
- Error handling: slug conflict → show error "This slug is taken", suggest `{slug}-2`
- On success: updates `userClients` signal locally, navigates via coordinator

### ClientPickerScreen

- Stateless widget, fullscreen centered layout
- "Select a project" heading
- Lists `userClients` signal data as clickable `ShadCard` items
- Each card shows: name, slug, description (if any)
- Click navigates to `/{slug}/overview` via coordinator

### AuthGate Widget

- Wraps router output in `ShadApp.builder`
- Listens to auth session stream from `serverpod_auth_idp_flutter`
- State machine to avoid redundant API calls:
  ```
  States: loading → unauthenticated → authenticatedLoading → ready | noClients
  ```
- On `ready`: caches client list in `userClients` signal; only re-fetches on explicit actions (wizard completion, logout)
- Shows centered `ShadProgress` spinner during loading/authenticatedLoading states

## State Management

### New/Updated Signals

```dart
/// Auth state enum
enum AuthState { loading, unauthenticated, authenticatedLoading, ready, noClients }

/// Current auth state — written by AuthGate widget
final authState = signal<AuthState>(AuthState.loading);
```

### initClientContext Update

`initClientContext(String clientSlug)` remains unchanged — called by `ManageLayout` when a slug-based route is rendered, after AuthGate has confirmed authentication and client membership. AuthGate itself calls `getUserClients()` directly (not via `initClientContext`) since it doesn't have a slug yet.

### Logout

- Logout button in `ManageLayout` top bar (already has user avatar area)
- Calls `serverpodClient.auth.signOut()`
- Clears signals: `currentUser.value = null`, `currentClient.value = null`, `userClients.value = []`, `authState.value = AuthState.unauthenticated`
- Auth stream fires → AuthGate shows LoginScreen

## File Changes Summary

### New Files (flutter_cms_manage)
- `lib/src/routes/login_route.dart`
- `lib/src/routes/setup_wizard_route.dart`
- `lib/src/routes/client_picker_route.dart`
- `lib/src/screens/login_screen.dart`
- `lib/src/screens/setup_wizard_screen.dart`
- `lib/src/screens/client_picker_screen.dart`
- `lib/src/widgets/auth_gate.dart`

### Modified Files (flutter_cms_manage)
- `lib/main.dart` — Add `builder` with `AuthGate` to `ShadApp.router`
- `lib/src/routes/manage_coordinator.dart` — Reserved path handling, root URL logic
- `lib/src/routes/manage_route.dart` — No changes needed (base class is fine)
- `lib/src/providers/manage_providers.dart` — Add `authState` signal, `AuthState` enum, logout helper

### Backend Files
- `flutter_cms_be_server/lib/src/endpoints/cms_client_endpoint.dart` — Add `createClientWithOwner`
- Run `serverpod generate` after endpoint changes

## Edge Cases

- **Auth session expires mid-use:** AuthGate listens to auth stream; session drop → shows LoginScreen
- **Slug conflict during wizard:** Show inline error with suggestion
- **User removed from all clients:** Next AuthGate evaluation detects empty client list → shows wizard
- **Direct URL to `/login` when authenticated:** AuthGate overrides and shows appropriate screen (picker/dashboard)
- **Direct URL to `/setup` when user has clients:** AuthGate overrides and renders the normal app
- **Browser refresh:** Auth session persists via `FlutterAuthSessionManager`; AuthGate re-evaluates seamlessly
- **User removed from specific client (but has others):** `initClientContext` finds no matching client → redirect to ClientPickerRoute or show "no access" message
- **Reserved slugs:** Prevented at creation time (both UI and backend validation)
- **After wizard, before server sync:** New client added to `userClients` signal immediately to avoid race condition where re-fetch might not include it yet
