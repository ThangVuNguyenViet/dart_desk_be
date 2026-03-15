# Auth Flow & New User Onboarding Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Google sign-in, new-user setup wizard, and smart client redirects to flutter_cms_manage so unauthenticated and first-time users have a complete onboarding flow.

**Architecture:** AuthGate widget wraps the router output in `ShadApp.router`'s `builder` parameter, intercepting rendering based on auth state (unauthenticated → LoginScreen, no clients → SetupWizardScreen, ready → router child). The coordinator handles reserved paths (`/login`, `/setup`) separately from client slugs. A new backend endpoint `createClientWithOwner` atomically creates a CmsClient + admin CmsUser in a transaction.

**Tech Stack:** Serverpod 3.4.3, serverpod_auth_idp_flutter, ZenRouter, shadcn_ui, signals

**Spec:** `docs/superpowers/specs/2026-03-13-auth-flow-and-onboarding-design.md`

**Key API notes (serverpod_auth_idp_flutter 3.4.3):**
- Sign in: `GoogleAuthController(client: serverpodClient, onAuthenticated: ..., onError: ...).signIn()`
- Check auth: `serverpodClient.auth.isAuthenticated` (bool property)
- Listen for changes: `serverpodClient.auth.authInfoListenable` (ValueListenable)
- Sign out: `serverpodClient.auth.signOutDevice()`
- Signals flutter: import `package:signals/signals_flutter.dart` (not `signals_flutter` package)

---

## File Structure

### New Files
| File | Responsibility |
|------|---------------|
| `flutter_cms_manage/lib/src/screens/login_screen.dart` | Google sign-in UI |
| `flutter_cms_manage/lib/src/screens/setup_wizard_screen.dart` | Project name form + slug preview |
| `flutter_cms_manage/lib/src/screens/client_picker_screen.dart` | Multi-client selection grid |
| `flutter_cms_manage/lib/src/routes/login_route.dart` | LoginRoute — no layout, `toUri: /login` |
| `flutter_cms_manage/lib/src/routes/setup_wizard_route.dart` | SetupWizardRoute — no layout, `toUri: /setup` |
| `flutter_cms_manage/lib/src/routes/client_picker_route.dart` | ClientPickerRoute — no layout, `toUri: /` |
| `flutter_cms_manage/lib/src/widgets/auth_gate.dart` | Auth state machine, wraps router output |

### Modified Files
| File | Changes |
|------|---------|
| `flutter_cms_be_server/lib/src/endpoints/cms_client_endpoint.dart` | Add `createClientWithOwner` endpoint |
| `flutter_cms_manage/lib/src/providers/manage_providers.dart` | Add `AuthState` enum, `authState` signal, `logout()` helper |
| `flutter_cms_manage/lib/src/routes/manage_coordinator.dart` | Reserved path routing (`login`, `setup`), root URL handling |
| `flutter_cms_manage/lib/main.dart` | Add `builder` with `AuthGate` to `ShadApp.router` |
| `flutter_cms_manage/lib/src/routes/manage_layout.dart` | Add logout button to `_TopBar` |

---

## Chunk 1: Backend — createClientWithOwner Endpoint

### Task 1: Add createClientWithOwner to CmsClientEndpoint

**Files:**
- Modify: `flutter_cms_be_server/lib/src/endpoints/cms_client_endpoint.dart:193` (append before closing brace)

- [ ] **Step 1: Add the endpoint method**

Add after `deleteClient` method (line 192), before the closing `}` of the class:

```dart
  /// Reserved slugs that cannot be used as client slugs.
  static const _reservedSlugs = {'login', 'setup', 'admin', 'api', 'app'};

  /// Slug validation regex: 3-63 chars, lowercase alphanumeric + hyphens,
  /// no leading/trailing hyphens.
  static final _slugRegex = RegExp(r'^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$');

  /// Create a new client and an admin CmsUser for the caller in one transaction.
  /// Used by the manage app's setup wizard for first-time users.
  Future<CmsClient> createClientWithOwner(
    Session session, {
    required String name,
    required String slug,
  }) async {
    final authInfo = session.authenticated;
    if (authInfo == null) {
      throw Exception('User must be authenticated');
    }

    // Validate slug format
    if (!_slugRegex.hasMatch(slug)) {
      throw Exception(
        'Invalid slug: must be 3-63 characters, lowercase alphanumeric and hyphens, '
        'cannot start or end with a hyphen',
      );
    }
    if (_reservedSlugs.contains(slug)) {
      throw Exception('Slug "$slug" is reserved and cannot be used');
    }

    // Check slug uniqueness
    final existing = await CmsClient.db.findFirstRow(
      session,
      where: (t) => t.slug.equals(slug),
    );
    if (existing != null) {
      throw Exception('Slug "$slug" is already taken');
    }

    // Generate internal API token (same pattern as createClient)
    final rawToken = _generateToken();
    final prefix = rawToken.substring(0, 16);
    final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());

    // Get user profile for email (same pattern as UserEndpoint.ensureUser lines 57-68)
    String? email;
    String? userName;
    try {
      final profileRows = await session.db.unsafeQuery(
        'SELECT "email", "fullName" FROM "serverpod_auth_core_profile" '
        'WHERE "authUserId" = \'${authInfo.userIdentifier}\' LIMIT 1',
      );
      if (profileRows.isNotEmpty) {
        email = profileRows.first[0] as String?;
        userName = profileRows.first[1] as String?;
      }
    } catch (e) {
      // Profile lookup failed; use identifier as fallback
    }

    return session.db.transaction((transaction) async {
      final client = await CmsClient.db.insertRow(
        session,
        CmsClient(
          name: name,
          slug: slug,
          apiTokenHash: hash,
          apiTokenPrefix: prefix,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await CmsUser.db.insertRow(
        session,
        CmsUser(
          clientId: client.id!,
          email: email ?? authInfo.userIdentifier,
          name: userName,
          role: 'admin',
          isActive: true,
          serverpodUserId: authInfo.userIdentifier,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      return client;
    });
  }
```

> **Note:** The `session.db.unsafeQuery` pattern for profile lookup matches the existing pattern in `UserEndpoint.ensureUser` (lines 58-68). The `session.db.transaction` usage follows Serverpod 3.x conventions where operations inside the callback are scoped to the transaction via the session.

- [ ] **Step 2: Run serverpod generate**

Run from `flutter_cms_be_server/`:
```bash
cd flutter_cms_be_server && serverpod generate
```
Expected: Code generation succeeds, `flutter_cms_be_client` gets updated `cmsClient.createClientWithOwner` method.

- [ ] **Step 3: Verify the server compiles**

```bash
cd flutter_cms_be_server && dart analyze
```
Expected: No errors.

- [ ] **Step 4: Commit**

```bash
git add flutter_cms_be_server/lib/src/endpoints/cms_client_endpoint.dart
git add flutter_cms_be_client/lib/src/protocol/
git commit -m "feat: add createClientWithOwner endpoint for onboarding wizard"
```

---

## Chunk 2: Frontend — State and Providers

### Task 2: Add AuthState enum and logout helper to providers

**Files:**
- Modify: `flutter_cms_manage/lib/src/providers/manage_providers.dart`

- [ ] **Step 1: Add AuthState enum and authState signal**

Add after the imports (line 4), before the `serverpodClient` declaration:

```dart
/// Auth state for the AuthGate widget
enum AuthState { loading, unauthenticated, authenticatedLoading, ready, noClients }

/// Current auth state — written by AuthGate widget
final authState = signal<AuthState>(AuthState.loading);
```

- [ ] **Step 2: Add logout helper**

Add at the end of the file (after `initClientContext`):

```dart
/// Sign out and clear all state
Future<void> logout() async {
  await serverpodClient.auth.signOutDevice();
  currentUser.value = null;
  currentClient.value = null;
  userClients.value = [];
  authState.value = AuthState.unauthenticated;
  resetTokenService();
}
```

- [ ] **Step 3: Verify compilation**

```bash
cd flutter_cms_manage && flutter analyze
```
Expected: No errors (warnings about unused are OK for now).

- [ ] **Step 4: Commit**

```bash
git add flutter_cms_manage/lib/src/providers/manage_providers.dart
git commit -m "feat: add AuthState enum, authState signal, and logout helper"
```

---

## Chunk 3: Frontend — Screens (created BEFORE routes that import them)

### Task 3: Create LoginScreen

**Files:**
- Create: `flutter_cms_manage/lib/src/screens/login_screen.dart`

- [ ] **Step 1: Create the login screen**

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../providers/manage_providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final controller = GoogleAuthController(
        client: serverpodClient,
        onAuthenticated: () {
          // Auth state change is handled by AuthGate's listener
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = 'Sign-in failed. Please try again.';
              _isLoading = false;
            });
          }
        },
      );
      await controller.signIn();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Sign-in failed. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: ShadCard(
          width: 400,
          title: const Text('Flutter CMS', style: TextStyle(fontSize: 24)),
          description: const Text('Sign in to manage your projects'),
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null) ...[
                  ShadAlert.destructive(
                    title: Text(_error!),
                  ),
                  const SizedBox(height: 16),
                ],
                ShadButton(
                  width: double.infinity,
                  enabled: !_isLoading,
                  onPressed: _signInWithGoogle,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.logIn, size: 16),
                            const SizedBox(width: 8),
                            const Text('Sign in with Google'),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add flutter_cms_manage/lib/src/screens/login_screen.dart
git commit -m "feat: add LoginScreen with Google sign-in"
```

### Task 4: Create SetupWizardScreen

**Files:**
- Create: `flutter_cms_manage/lib/src/screens/setup_wizard_screen.dart`

- [ ] **Step 1: Create the setup wizard screen**

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/manage_providers.dart';
import '../routes/manage_coordinator.dart';
import '../routes/overview_route.dart';

class SetupWizardScreen extends StatefulWidget {
  final ManageCoordinator coordinator;

  const SetupWizardScreen({super.key, required this.coordinator});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  String _generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  Future<void> _createProject() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final slug = _generateSlug(name);

    if (slug.length < 3) {
      setState(() => _error = 'Project name is too short to generate a valid slug.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = await serverpodClient.cmsClient.createClientWithOwner(
        name: name,
        slug: slug,
      );

      // Update local state immediately (avoid re-fetch race condition)
      userClients.value = [...userClients.value, client];
      authState.value = AuthState.ready;

      if (mounted) {
        widget.coordinator.setNewRoutePath(OverviewRoute(client.slug));
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString();
        if (message.contains('already taken')) {
          setState(() => _error = 'Slug "$slug" is already taken. Try a different name.');
        } else if (message.contains('reserved')) {
          setState(() => _error = 'This name uses a reserved word. Try a different name.');
        } else {
          setState(() => _error = 'Failed to create project. Please try again.');
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: ShadCard(
          width: 460,
          title: const Text('Welcome! Create your project',
              style: TextStyle(fontSize: 20)),
          description: const Text(
            'Give your CMS project a name. You can configure everything else later.',
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: ShadForm(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    ShadAlert.destructive(title: Text(_error!)),
                    const SizedBox(height: 16),
                  ],
                  ShadInputFormField(
                    id: 'name',
                    label: const Text('Project Name'),
                    controller: _nameController,
                    placeholder: const Text('My Awesome Project'),
                    validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_nameController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Slug: ${_generateSlug(_nameController.text)}',
                      style: theme.textTheme.muted,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ShadButton(
                    width: double.infinity,
                    enabled: !_isLoading,
                    onPressed: _createProject,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Project'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add flutter_cms_manage/lib/src/screens/setup_wizard_screen.dart
git commit -m "feat: add SetupWizardScreen with project name form and slug preview"
```

### Task 5: Create ClientPickerScreen

**Files:**
- Create: `flutter_cms_manage/lib/src/screens/client_picker_screen.dart`

- [ ] **Step 1: Create the client picker screen**

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../providers/manage_providers.dart';
import '../routes/manage_coordinator.dart';
import '../routes/overview_route.dart';

class ClientPickerScreen extends StatelessWidget {
  final ManageCoordinator coordinator;

  const ClientPickerScreen({super.key, required this.coordinator});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final clients = userClients.watch(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flutter CMS',
                    style: theme.textTheme.h2
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Select a project', style: theme.textTheme.muted),
                const SizedBox(height: 24),
                ...clients.map((client) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ShadCard(
                        onPressed: () => coordinator
                            .setNewRoutePath(OverviewRoute(client.slug)),
                        child: Row(
                          children: [
                            ShadAvatar(
                              '',
                              size: const Size(40, 40),
                              placeholder: Text(
                                client.name.isNotEmpty
                                    ? client.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(client.name,
                                      style: theme.textTheme.large),
                                  Text(client.slug,
                                      style: theme.textTheme.muted),
                                ],
                              ),
                            ),
                            Icon(LucideIcons.chevronRight,
                                color: theme.colorScheme.mutedForeground),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add flutter_cms_manage/lib/src/screens/client_picker_screen.dart
git commit -m "feat: add ClientPickerScreen for multi-client users"
```

---

## Chunk 4: Frontend — Routes and Coordinator

### Task 6: Create LoginRoute, SetupWizardRoute, ClientPickerRoute

**Files:**
- Create: `flutter_cms_manage/lib/src/routes/login_route.dart`
- Create: `flutter_cms_manage/lib/src/routes/setup_wizard_route.dart`
- Create: `flutter_cms_manage/lib/src/routes/client_picker_route.dart`

> **Note:** Screens were created in Chunk 3, so these imports will resolve.

- [ ] **Step 1: Create LoginRoute**

```dart
import 'package:flutter/material.dart';

import 'manage_coordinator.dart';
import 'manage_route.dart';
import '../screens/login_screen.dart';

class LoginRoute extends ManageRoute {
  @override
  Uri toUri() => Uri.parse('/login');

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      const LoginScreen();
}
```

- [ ] **Step 2: Create SetupWizardRoute**

```dart
import 'package:flutter/material.dart';

import 'manage_coordinator.dart';
import 'manage_route.dart';
import '../screens/setup_wizard_screen.dart';

class SetupWizardRoute extends ManageRoute {
  @override
  Uri toUri() => Uri.parse('/setup');

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      SetupWizardScreen(coordinator: coordinator);
}
```

- [ ] **Step 3: Create ClientPickerRoute**

```dart
import 'package:flutter/material.dart';

import 'manage_coordinator.dart';
import 'manage_route.dart';
import '../screens/client_picker_screen.dart';

class ClientPickerRoute extends ManageRoute {
  @override
  Uri toUri() => Uri.parse('/');

  @override
  Widget build(ManageCoordinator coordinator, BuildContext context) =>
      ClientPickerScreen(coordinator: coordinator);
}
```

- [ ] **Step 4: Commit**

```bash
git add flutter_cms_manage/lib/src/routes/login_route.dart
git add flutter_cms_manage/lib/src/routes/setup_wizard_route.dart
git add flutter_cms_manage/lib/src/routes/client_picker_route.dart
git commit -m "feat: add LoginRoute, SetupWizardRoute, ClientPickerRoute"
```

### Task 7: Update ManageCoordinator with reserved path routing

**Files:**
- Modify: `flutter_cms_manage/lib/src/routes/manage_coordinator.dart`

- [ ] **Step 1: Replace the entire file content**

```dart
import 'package:zenrouter/zenrouter.dart';

import 'manage_route.dart';
import 'manage_layout.dart';
import 'api_layout.dart';
import 'overview_route.dart';
import 'tokens_route.dart';
import 'settings_route.dart';
import 'not_found_route.dart';
import 'login_route.dart';
import 'setup_wizard_route.dart';
import 'client_picker_route.dart';

class ManageCoordinator extends Coordinator<ManageRoute> {
  String clientSlug = '';

  late final manageStack = NavigationPath<ManageRoute>('manage');

  late final apiStack = NavigationPath<ManageRoute>('api');

  @override
  List<StackPath> get paths => [...super.paths, manageStack, apiStack];

  @override
  void defineLayout() {
    RouteLayout.defineLayout(ManageLayout, ManageLayout.new);
    RouteLayout.defineLayout(ApiLayout, ApiLayout.new);
  }

  @override
  ManageRoute parseRouteFromUri(Uri uri) {
    final segments = uri.pathSegments;

    // 1. Root URL → client picker
    if (segments.isEmpty) return ClientPickerRoute();

    // 2. Reserved paths (not client slugs)
    if (segments.first == 'login') return LoginRoute();
    if (segments.first == 'setup') return SetupWizardRoute();

    // 3. Everything else: first segment is clientSlug
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

- [ ] **Step 2: Verify compilation**

```bash
cd flutter_cms_manage && flutter analyze
```
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add flutter_cms_manage/lib/src/routes/manage_coordinator.dart
git commit -m "feat: update coordinator with reserved path routing for auth flow"
```

---

## Chunk 5: Frontend — AuthGate, Wiring, and Logout

### Task 8: Create AuthGate widget

**Files:**
- Create: `flutter_cms_manage/lib/src/widgets/auth_gate.dart`

- [ ] **Step 1: Create the auth gate widget**

```dart
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/manage_providers.dart';
import '../screens/login_screen.dart';
import '../screens/setup_wizard_screen.dart';
import '../routes/manage_coordinator.dart';
import '../routes/overview_route.dart';

class AuthGate extends StatefulWidget {
  final Widget child;
  final ManageCoordinator coordinator;

  const AuthGate({
    super.key,
    required this.child,
    required this.coordinator,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    // Listen for auth changes via ValueListenable
    serverpodClient.auth.authInfoListenable.addListener(_checkAuth);
  }

  Future<void> _checkAuth() async {
    final isSignedIn = serverpodClient.auth.isAuthenticated;

    if (!isSignedIn) {
      authState.value = AuthState.unauthenticated;
      _initialized = true;
      if (mounted) setState(() {});
      return;
    }

    // User is authenticated — fetch their clients
    authState.value = AuthState.authenticatedLoading;
    if (mounted) setState(() {});

    try {
      final clients = await serverpodClient.user.getUserClients();
      userClients.value = clients;

      if (clients.isEmpty) {
        authState.value = AuthState.noClients;
      } else {
        authState.value = AuthState.ready;

        // If user has exactly one client and is on root/login/setup,
        // redirect to their client's overview
        if (clients.length == 1 && _isRootOrAuthRoute()) {
          widget.coordinator.setNewRoutePath(
            OverviewRoute(clients.first.slug),
          );
        }
      }
    } catch (e) {
      // If fetching clients fails, treat as unauthenticated
      authState.value = AuthState.unauthenticated;
    }

    _initialized = true;
    if (mounted) setState(() {});
  }

  bool _isRootOrAuthRoute() {
    final uri = widget.coordinator.currentConfiguration?.uri;
    if (uri == null) return true;
    final path = uri.path;
    return path == '/' || path == '/login' || path == '/setup';
  }

  @override
  void dispose() {
    serverpodClient.auth.authInfoListenable.removeListener(_checkAuth);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final state = authState.value;

    // Loading state
    if (!_initialized || state == AuthState.loading || state == AuthState.authenticatedLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Unauthenticated → show login
    if (state == AuthState.unauthenticated) {
      return const LoginScreen();
    }

    // Authenticated but no clients → show setup wizard
    if (state == AuthState.noClients) {
      return SetupWizardScreen(coordinator: widget.coordinator);
    }

    // Ready → show the router's output
    return widget.child;
  }
}
```

- [ ] **Step 2: Verify compilation**

```bash
cd flutter_cms_manage && flutter analyze
```

- [ ] **Step 3: Commit**

```bash
git add flutter_cms_manage/lib/src/widgets/auth_gate.dart
git commit -m "feat: add AuthGate widget with auth state machine"
```

### Task 9: Wire AuthGate into main.dart

**Files:**
- Modify: `flutter_cms_manage/lib/main.dart`

- [ ] **Step 1: Add import at top of file**

Add after the existing imports:
```dart
import 'src/widgets/auth_gate.dart';
```

- [ ] **Step 2: Add builder parameter to ShadApp.router**

Replace lines 40-49 (the `build` method in `_ManageAppState`):

Old:
```dart
  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'Flutter CMS Manage',
      theme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      routeInformationParser: coordinator.routeInformationParser,
      routerDelegate: coordinator.routerDelegate,
    );
  }
```

New:
```dart
  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'Flutter CMS Manage',
      theme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      routeInformationParser: coordinator.routeInformationParser,
      routerDelegate: coordinator.routerDelegate,
      builder: (context, child) => AuthGate(
        coordinator: coordinator,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
```

- [ ] **Step 3: Verify compilation**

```bash
cd flutter_cms_manage && flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add flutter_cms_manage/lib/main.dart
git commit -m "feat: wire AuthGate into ShadApp.router builder"
```

### Task 10: Add logout button to ManageLayout top bar

**Files:**
- Modify: `flutter_cms_manage/lib/src/routes/manage_layout.dart`

- [ ] **Step 1: Add import**

Add after existing imports (around line 9):
```dart
import '../providers/manage_providers.dart';
```

- [ ] **Step 2: Replace avatar with logout menu**

In `_TopBar.build()`, replace lines 88-92:

Old:
```dart
          ShadAvatar(
            'U',
            size: const Size(28, 28),
            placeholder: const Text('U'),
          ),
```

New:
```dart
          ShadButton.ghost(
            size: ShadButtonSize.icon,
            onPressed: () => logout(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShadAvatar(
                  'U',
                  size: const Size(28, 28),
                  placeholder: const Text('U'),
                ),
                const SizedBox(width: 8),
                Icon(LucideIcons.logOut, size: 14),
              ],
            ),
          ),
```

- [ ] **Step 3: Verify compilation**

```bash
cd flutter_cms_manage && flutter analyze
```

- [ ] **Step 4: Commit**

```bash
git add flutter_cms_manage/lib/src/routes/manage_layout.dart
git commit -m "feat: add sign-out button to top bar"
```

---

## Chunk 6: Integration Testing

### Task 11: Full integration test

- [ ] **Step 1: Ensure backend is running**

```bash
cd flutter_cms_be_server && docker-compose up -d && dart bin/main.dart
```

- [ ] **Step 2: Run serverpod generate to sync client**

```bash
cd flutter_cms_be_server && serverpod generate
```

No model changes were made (only endpoint additions), so migration should not be needed.

- [ ] **Step 3: Launch the manage app on Chrome**

Use Dart MCP `launch_app` tool or:
```bash
cd flutter_cms_manage && flutter run -d chrome
```

- [ ] **Step 4: Test the happy path**

Verify:
1. Visiting `/` shows the login screen (not "Page not found")
2. Google sign-in button initiates OAuth flow
3. After first login (no clients) → setup wizard appears
4. Entering a project name shows slug preview below input
5. Creating project navigates to `/{slug}/overview`
6. Refreshing the page stays on the overview (session persists)
7. Clicking sign-out button returns to login screen
8. Signing in again auto-redirects to the project (single client)

- [ ] **Step 5: Test edge cases**

1. Navigate to `/login` while authenticated → should show dashboard, not login
2. Navigate to `/setup` while having clients → should show dashboard
3. Navigate to `/nonexistent-slug/overview` → should show not found
4. Try creating a project with a reserved slug name → should show error
5. Try creating a project with slug that already exists → should show error

- [ ] **Step 6: Fix any issues and commit**

```bash
git add -u
git commit -m "fix: address issues found during integration testing"
```
