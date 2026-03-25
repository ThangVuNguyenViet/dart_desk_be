# Multi-Provider Auth Linking Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Auto-link Google login to email/password accounts, guard email registration against Google-registered emails, replace DartDeskAuth with Relic middleware + standalone functions, and auto-create User records on first login.

**Architecture:** API key validation is already handled via `preEndpointHandlers` in the Serverpod fork — endpoints access it via `session.apiKey`. `resolveUser()` handles User record auto-creation. IDP endpoints override Serverpod base classes to intercept cross-provider conflicts.

**Tech Stack:** Serverpod 3.4.4, Relic 1.2.0 (ContextProperty, Middleware), serverpod_auth_idp_server (GoogleIdpUtils, EmailAccount, GoogleAccount)

**Spec:** `docs/superpowers/specs/2026-03-25-multi-provider-auth-linking-design.md`

---

## File Structure

### New files
- `dart_desk_server/lib/src/auth/resolve_user.dart` — `resolveUser()` standalone function
- `dart_desk_server/test/unit/resolve_user_test.dart` — unit tests for user resolution logic
- `dart_desk_server/test/integration/google_auto_link_test.dart` — integration tests for Google auto-link
- `dart_desk_server/test/integration/email_registration_guard_test.dart` — integration tests for email guard

### Modified files
- `dart_desk_server/lib/src/endpoints/google_idp_endpoint.dart` — override `login()` with auto-link logic
- `dart_desk_server/lib/src/endpoints/email_idp_endpoint.dart` — override `startRegistration()` with guard
- `dart_desk_server/lib/server.dart` — register middleware, remove `_seedAdminUser()`, clean up imports
- `dart_desk_server/lib/src/endpoints/document_endpoint.dart` — replace `DartDeskAuth` calls with `requireApiKey()` + `resolveUser()`
- `dart_desk_server/lib/src/endpoints/cms_api_token_endpoint.dart` — same
- `dart_desk_server/lib/src/endpoints/user_endpoint.dart` — same
- `dart_desk_server/lib/src/endpoints/media_endpoint.dart` — same
- `dart_desk_server/lib/src/endpoints/document_collaboration_endpoint.dart` — same
- `dart_desk_server/lib/src/models/user.spy.yaml` — remove `externalId`, `externalProvider`, `users_external_id_idx`
- `dart_desk_server/test/integration/helpers/test_data_factory.dart` — update to match new auth pattern

### Additionally modified (minor)
- `dart_desk_server/lib/src/auth/api_key_validator.dart` — update doc comment referencing `DartDeskAuth`
- `dart_desk_server/lib/src/plugin/dart_desk_registry.dart` — remove `authStrategies` and `ExternalAuthStrategy` import

### Unchanged endpoints (no DartDeskAuth usage)
- `studio_config_endpoint.dart` — no DartDeskAuth usage. Note: `preEndpointHandlers` gates ALL endpoints with API key. If this endpoint needs to be public, it will need exemption in the handler.
- `project_endpoint.dart` — uses `session.authenticated` directly, no DartDeskAuth. Unchanged.
- `deployment_endpoint.dart` — uses `session.authenticated` directly, no DartDeskAuth. Unchanged.
- `refresh_jwt_tokens_endpoint.dart` — IDP endpoint, no DartDeskAuth. Unchanged.

### Deleted files
- `dart_desk_server/lib/src/auth/dart_desk_auth.dart`
- `dart_desk_server/lib/src/auth/external_auth_strategy.dart`
- `dart_desk_server/test/integration/external_auth_test.dart`
- `dart_desk_server/test/unit/dart_desk_auth_scheme_test.dart`

---

## Task 1: resolveUser() Function

**Files:**
- Create: `dart_desk_server/lib/src/auth/resolve_user.dart`
- Create: `dart_desk_server/test/unit/resolve_user_test.dart`

- [ ] **Step 1: Write resolveUser()**

Create `dart_desk_server/lib/src/auth/resolve_user.dart`:

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

/// Find or auto-create a [User] record for the currently authenticated session.
///
/// Requires [session.authenticated] to be non-null (caller must be logged in).
/// The first user in a tenant automatically gets the 'admin' role.
Future<User> resolveUser(Session session, {int? clientId}) async {
  final auth = session.authenticated;
  if (auth == null) {
    throw Exception('User must be authenticated');
  }
  final serverpodUserId = auth.userIdentifier;

  // Try to find existing User
  var user = await User.db.findFirstRow(
    session,
    where: (t) {
      var expr = t.serverpodUserId.equals(serverpodUserId);
      if (clientId != null) {
        expr = expr & t.clientId.equals(clientId);
      } else {
        expr = expr & t.clientId.equals(null);
      }
      return expr;
    },
  );
  if (user != null) return user;

  // Get email/name from Serverpod UserProfile
  final profile = await UserProfile.db.findFirstRow(
    session,
    where: (t) => t.authUserId.equals(auth.authUserId),
  );

  // First user in tenant becomes admin
  final userCount = await User.db.count(
    session,
    where: (t) => clientId != null
        ? t.clientId.equals(clientId)
        : t.clientId.equals(null),
  );
  final role = userCount == 0 ? 'admin' : 'viewer';

  user = User(
    clientId: clientId,
    email: profile?.email ?? '',
    name: profile?.fullName,
    role: role,
    isActive: true,
    serverpodUserId: serverpodUserId,
  );

  try {
    return await User.db.insertRow(session, user);
  } catch (e) {
    // Race condition: another request may have created the user
    final retried = await User.db.findFirstRow(
      session,
      where: (t) {
        var expr = t.serverpodUserId.equals(serverpodUserId);
        if (clientId != null) {
          expr = expr & t.clientId.equals(clientId);
        } else {
          expr = expr & t.clientId.equals(null);
        }
        return expr;
      },
    );
    if (retried != null) return retried;
    rethrow;
  }
}
```

- [ ] **Step 2: Write integration tests for resolveUser()**

Create `dart_desk_server/test/unit/resolve_user_test.dart`:

```dart
import 'package:dart_desk_server/src/auth/resolve_user.dart';
import 'package:dart_desk_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('resolveUser', (sessionBuilder, endpoints) {
    test('first user becomes admin', () async {
      final session = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'user-1',
              {},
            ),
          )
          .build();

      final user = await resolveUser(session);
      expect(user.role, equals('admin'));
      expect(user.serverpodUserId, equals('user-1'));
    });

    test('second user becomes viewer', () async {
      // Create first user (admin)
      final session1 = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'user-1',
              {},
            ),
          )
          .build();
      await resolveUser(session1);

      // Create second user (viewer)
      final session2 = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'user-2',
              {},
            ),
          )
          .build();
      final user2 = await resolveUser(session2);
      expect(user2.role, equals('viewer'));
    });

    test('returns existing user on repeated calls', () async {
      final session = sessionBuilder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'user-1',
              {},
            ),
          )
          .build();

      final user1 = await resolveUser(session);
      final user2 = await resolveUser(session);
      expect(user1.id, equals(user2.id));
    });

    test('throws when not authenticated', () async {
      final session = sessionBuilder.build();
      expect(
        () => resolveUser(session),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

- [ ] **Step 3: Run tests**

Run: `cd dart_desk_server && dart test test/unit/resolve_user_test.dart -v`
Expected: All PASS

- [ ] **Step 4: Commit**

```bash
git add dart_desk_server/lib/src/auth/resolve_user.dart dart_desk_server/test/unit/resolve_user_test.dart
git commit -m "feat: add resolveUser() with auto-create and first-user-admin logic"
```

---

## Task 2: User Model Migration

**Files:**
- Modify: `dart_desk_server/lib/src/models/user.spy.yaml`

- [ ] **Step 1: Remove externalId and externalProvider from model**

Edit `dart_desk_server/lib/src/models/user.spy.yaml` to remove `externalId`, `externalProvider` fields and `users_external_id_idx` index:

```yaml
class: User
table: users
fields:
  clientId: int?
  email: String
  name: String?
  role: String, default='viewer'
  isActive: bool, default=true
  serverpodUserId: String?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now
indexes:
  users_client_email_idx:
    fields: clientId, email
    unique: true
  users_client_id_idx:
    fields: clientId
  users_serverpod_user_id_idx:
    fields: serverpodUserId
  users_is_active_idx:
    fields: isActive
```

- [ ] **Step 2: Run serverpod generate**

Run: `cd dart_desk_server && serverpod generate`
Expected: Code generation succeeds

- [ ] **Step 3: Create migration**

Run: `cd dart_desk_server && serverpod create-migration`
Expected: Migration created that drops `externalId`, `externalProvider` columns and `users_external_id_idx` index

- [ ] **Step 4: Verify migration SQL**

Read the generated migration file and confirm it contains:
- `ALTER TABLE "users" DROP COLUMN "externalId"`
- `ALTER TABLE "users" DROP COLUMN "externalProvider"`
- `DROP INDEX "users_external_id_idx"`

- [ ] **Step 5: Commit**

```bash
git add dart_desk_server/lib/src/models/user.spy.yaml dart_desk_server/lib/src/generated/ dart_desk_server/migrations/
git commit -m "refactor: remove externalId/externalProvider from User model"
```

---

## Task 3: Remove _seedAdminUser + Remove DartDeskAuth

**Files:**
- Modify: `dart_desk_server/lib/server.dart`
- Delete: `dart_desk_server/lib/src/auth/dart_desk_auth.dart`
- Delete: `dart_desk_server/lib/src/auth/external_auth_strategy.dart`
- Delete: `dart_desk_server/test/integration/external_auth_test.dart`
- Delete: `dart_desk_server/test/unit/dart_desk_auth_scheme_test.dart`

- [ ] **Step 1: Update server.dart**

In `dart_desk_server/lib/server.dart`:

1. Remove import for `dart_desk_auth.dart`
2. Remove `DartDeskAuth.configure(...)` call
3. Remove `await DartDeskAuth.initialize()` call
4. Remove `_seedAdminUser()` function and its call
5. Keep the `preEndpointHandlers` (already handles API key validation)
6. Remove the `authenticationHandler` override if it only existed for DartDesk scheme parsing — check if it's still needed

- [ ] **Step 2: Delete removed files and clean up references**

```bash
rm dart_desk_server/lib/src/auth/dart_desk_auth.dart
rm dart_desk_server/lib/src/auth/external_auth_strategy.dart
rm dart_desk_server/test/integration/external_auth_test.dart
rm dart_desk_server/test/unit/dart_desk_auth_scheme_test.dart
```

Also:
- In `dart_desk_server/lib/src/auth/api_key_validator.dart`: update doc comment that references `DartDeskAuth` (line 25) to reference `requireApiKey()` instead.
- In `dart_desk_server/lib/src/plugin/dart_desk_registry.dart`: remove `authStrategies` field, `registerAuthStrategy()` method, and `ExternalAuthStrategy` import. These are dead code after removing the external auth strategy system.

- [ ] **Step 3: Verify compilation**

Run: `cd dart_desk_server && dart analyze`
Expected: May show errors in endpoints that still reference `DartDeskAuth` — these are fixed in Task 5.

- [ ] **Step 4: Commit**

```bash
git add -A
git commit -m "refactor: register API key middleware, remove DartDeskAuth and _seedAdminUser"
```

---

## Task 4: Migrate All Endpoints to New Auth Pattern

**Files:**
- Modify: `dart_desk_server/lib/src/endpoints/document_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/cms_api_token_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/user_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/media_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/document_collaboration_endpoint.dart`
- Modify: `dart_desk_server/test/integration/helpers/test_data_factory.dart`

Each endpoint currently calls `DartDeskAuth.authenticateRequest(session)` which returns `AuthResult = ({ApiKeyContext apiKey, User? user})`. Replace with:

```dart
// Before:
final auth = await DartDeskAuth.authenticateRequest(session);
final clientId = auth.apiKey.clientId;
final user = auth.user;

// After:
final clientId = session.apiKey.clientId;
final user = await resolveUser(session, clientId: clientId);
```

For read-only endpoints that don't need a user (API-key-only):
```dart
final clientId = session.apiKey.clientId;
```

- [ ] **Step 1: Migrate document_endpoint.dart**

Replace `import '../auth/dart_desk_auth.dart'` with:
```dart
import '../auth/dart_desk_session.dart';
import '../auth/resolve_user.dart';
```

Replace `_requireAuth()`:
```dart
Future<({ApiKeyContext apiKey, User? user})> _requireAuth(Session session) async {
  return (apiKey: session.apiKey, user: null);
}
```

Replace `_requireUser()`:
```dart
Future<({ApiKeyContext apiKey, User user})> _requireUser(Session session) async {
  final user = await resolveUser(session, clientId: session.apiKey.clientId);
  return (apiKey: session.apiKey, user: user);
}
```

Update imports to include `ApiKeyContext` from `api_key_context.dart`.

- [ ] **Step 2: Migrate cms_api_token_endpoint.dart**

Same pattern. Replace `_requireAuth()` to use `session.apiKey` + `resolveUser()`.

- [ ] **Step 3: Migrate user_endpoint.dart**

Replace `DartDeskAuth.authenticateRequest(session)` with `session.apiKey` + `resolveUser()`:

```dart
import '../auth/dart_desk_session.dart';
import '../auth/resolve_user.dart';

class UserEndpoint extends Endpoint {
  Future<User?> getCurrentUser(Session session) async {
    if (session.authenticated == null) return null;
    return await resolveUser(session, clientId: session.apiKey.clientId);
  }

  Future<int> getUserCount(Session session) async {
    final user = await resolveUser(session, clientId: session.apiKey.clientId);
    return await User.db.count(
      session,
      where: (t) {
        var expr = t.isActive.equals(true);
        if (session.apiKey.clientId != null) {
          expr = expr & t.clientId.equals(session.apiKey.clientId);
        }
        return expr;
      },
    );
  }
}
```

- [ ] **Step 4: Migrate media_endpoint.dart**

Same pattern.

- [ ] **Step 5: Migrate document_collaboration_endpoint.dart**

Same pattern.

- [ ] **Step 6: Update test_data_factory.dart**

Remove reference to `DartDeskAuth` from `ensureTestUser()`. The method inserts directly via `User.db.insertRow()` which doesn't depend on `DartDeskAuth`, so just remove the import if present.

- [ ] **Step 7: Verify compilation**

Run: `cd dart_desk_server && dart analyze`
Expected: No errors

- [ ] **Step 8: Run all tests**

Run: `cd dart_desk_server && dart test`
Expected: All tests pass (except tests that depend on middleware/session.request which need adjustment in test setup)

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "refactor: migrate all endpoints from DartDeskAuth to requireApiKey() + resolveUser()"
```

---

## Task 5: Google Auto-Link Endpoint

**Files:**
- Modify: `dart_desk_server/lib/src/endpoints/google_idp_endpoint.dart`
- Create: `dart_desk_server/test/integration/google_auto_link_test.dart`

- [ ] **Step 1: Override GoogleIdpEndpoint.login()**

Edit `dart_desk_server/lib/src/endpoints/google_idp_endpoint.dart`:

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {
  @override
  Future<AuthSuccess> login(
    Session session, {
    required String idToken,
    required String? accessToken,
  }) async {
    final utils = googleIdp.utils;

    // Verify Google token and get account details
    final accountDetails = await utils.fetchAccountDetails(
      session,
      idToken: idToken,
      accessToken: accessToken,
    );

    // Check if this Google user ID is already known
    final existingGoogle = await GoogleAccount.db.findFirstRow(
      session,
      where: (t) => t.userIdentifier.equals(accountDetails.userIdentifier),
    );

    if (existingGoogle != null) {
      // Existing Google account — normal login flow
      return super.login(session, idToken: idToken, accessToken: accessToken);
    }

    // New Google user — check if email matches an existing EmailAccount
    final existingEmail = await EmailAccount.db.findFirstRow(
      session,
      where: (t) => t.email.equals(accountDetails.email.toLowerCase()),
    );

    if (existingEmail != null) {
      // Auto-link: attach Google to existing EmailAccount's AuthUser
      return await session.db.transaction((transaction) async {
        try {
          await utils.linkGoogleAuthentication(
            session,
            authUserId: existingEmail.authUserId,
            accountDetails: accountDetails,
            transaction: transaction,
          );
        } catch (e) {
          // Race condition: Google account may have been created concurrently
          // Fall through to normal login
          session.log(
            'Google link failed (likely race condition), falling back to normal login: $e',
            level: LogLevel.warning,
          );
          return super.login(
              session, idToken: idToken, accessToken: accessToken);
        }

        session.log(
          '[Auth] Auto-linked Google account (${accountDetails.email}) to existing email account',
          level: LogLevel.info,
        );

        // Issue tokens for the existing AuthUser
        final authUser = await AuthServices.instance.authUsers.get(
          session,
          authUserId: existingEmail.authUserId,
          transaction: transaction,
        );

        return AuthServices.instance.tokenManager.issueToken(
          session,
          authUserId: existingEmail.authUserId,
          transaction: transaction,
          method: 'google',
          scopes: authUser.scopes,
        );
      });
    }

    // No existing account — normal flow (creates new AuthUser + GoogleAccount)
    return super.login(session, idToken: idToken, accessToken: accessToken);
  }
}
```

- [ ] **Step 2: Verify compilation**

Run: `cd dart_desk_server && dart analyze`
Expected: No errors. If `AuthServices.instance.tokenManager` or `authUsers.get()` have different API shapes, adjust accordingly by checking the Serverpod source.

- [ ] **Step 3: Commit**

```bash
git add dart_desk_server/lib/src/endpoints/google_idp_endpoint.dart
git commit -m "feat: auto-link Google login to existing email/password accounts"
```

---

## Task 6: Email Registration Guard

**Files:**
- Modify: `dart_desk_server/lib/src/endpoints/email_idp_endpoint.dart`

- [ ] **Step 1: Override EmailIdpEndpoint.startRegistration()**

Edit `dart_desk_server/lib/src/endpoints/email_idp_endpoint.dart`:

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

class EmailIdpEndpoint extends EmailIdpBaseEndpoint {
  @override
  Future<UuidValue> startRegistration(
    Session session, {
    required String email,
  }) async {
    // Check if this email is already registered via Google
    final existingGoogle = await GoogleAccount.db.findFirstRow(
      session,
      where: (t) => t.email.equals(email.toLowerCase()),
    );

    if (existingGoogle != null) {
      throw Exception(
        'This email is already registered via Google. Please sign in with Google instead.',
      );
    }

    return super.startRegistration(session, email: email);
  }
}
```

- [ ] **Step 2: Verify compilation**

Run: `cd dart_desk_server && dart analyze`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add dart_desk_server/lib/src/endpoints/email_idp_endpoint.dart
git commit -m "feat: block email registration when email already has Google account"
```

---

## Task 7: Fix Tests + Final Verification

**Files:**
- Modify: various test files as needed

- [ ] **Step 1: Run full test suite**

Run: `cd dart_desk_server && dart test`
Expected: Note which tests fail

- [ ] **Step 2: Fix failing tests**

Common issues:
- Tests that reference `DartDeskAuth` — update imports
- Tests that reference `User.externalId` / `User.externalProvider` — remove
- Tests using `session.request` which may be null in test context — mock or use `sessionBuilder` appropriately
- `ensureTestUser()` in `test_data_factory.dart` may need updating if `User` model changed

- [ ] **Step 3: Run full test suite again**

Run: `cd dart_desk_server && dart test`
Expected: All PASS

- [ ] **Step 4: Run dart analyze**

Run: `cd dart_desk_server && dart analyze`
Expected: No errors, no warnings

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "test: fix tests for new auth pattern"
```

---

## Task 8: Cleanup + Apply Migration

- [ ] **Step 1: Verify no remaining references to removed code**

Run these checks:
```bash
cd dart_desk_server
grep -r "DartDeskAuth" lib/ test/ --include="*.dart"
grep -r "ExternalAuthStrategy" lib/ test/ --include="*.dart"
grep -r "externalId" lib/ test/ --include="*.dart"
grep -r "externalProvider" lib/ test/ --include="*.dart"
grep -r "_seedAdminUser" lib/ test/ --include="*.dart"
```

Expected: No matches (or only in docs/specs/plans)

- [ ] **Step 2: Run serverpod generate one final time**

Run: `cd dart_desk_server && serverpod generate`
Expected: Clean generation

- [ ] **Step 3: Final full test run**

Run: `cd dart_desk_server && dart test`
Expected: All PASS

- [ ] **Step 4: Commit any remaining changes**

```bash
git add -A
git commit -m "chore: final cleanup after auth simplification"
```
