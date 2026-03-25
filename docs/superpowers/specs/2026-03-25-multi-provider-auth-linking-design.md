# Multi-Provider Auth Linking & Auth Simplification

**Date:** 2026-03-25
**Status:** Draft

## Problem

Serverpod creates separate `AuthUser` records per identity provider with no cross-provider email matching. A user who registers with email/password and later signs in with Google (or vice versa) gets two separate accounts. Additionally, the current `DartDeskAuth` class mixes concerns (API key validation, user resolution, external auth strategies) that can be handled more cleanly with Serverpod-native patterns.

## Goals

1. Auto-link Google login to existing email/password accounts (same email)
2. Block email registration when the email already has a Google account
3. Auto-create `User` records on first login (first user becomes admin)
4. Replace `DartDeskAuth` with Relic middleware + standalone functions
5. Remove the external auth strategy system

## Non-Goals

- Supporting untrusted OAuth providers (GitHub, Discord) — only Google for now
- Manual account linking UI / endpoint
- Multi-tenant support changes

## Design

### 1. Google Login with Auto-Link

Override `GoogleIdpEndpoint.login()` to intercept before Serverpod creates a new `AuthUser`.

**Flow:**

1. Verify Google ID token via `GoogleIdpUtils.fetchAccountDetails()` → get email, userIdentifier
2. Check if a `GoogleAccount` already exists for this Google user ID
   - **Yes** → delegate to normal `googleIdp.login()` (existing user)
3. Check if an `EmailAccount` exists with the same email (case-insensitive)
   - **Match found** → call `GoogleIdpUtils.linkGoogleAuthentication()` with the existing `EmailAccount.authUserId`. Issue tokens for the existing `AuthUser`. Send notification (server-side log + optional email callback).
   - **No match** → delegate to normal `googleIdp.login()` (new user, new `AuthUser`)

**Rationale:** Google is a trusted provider (verifies email ownership). Auto-linking is industry standard for trusted providers (Auth0, Firebase, Supabase all do this).

**Token issuance for the link case:** When auto-linking, we cannot delegate to `googleIdp.login()` (it would create a new `AuthUser`). Instead, after calling `linkGoogleAuthentication()`, we manually issue tokens via the `TokenIssuer` accessible through `AuthServices.instance`:

```dart
final tokenIssuer = AuthServices.instance.tokenManager;
return tokenIssuer.issueToken(
  session,
  authUserId: existingAuthUserId,
  method: 'google',
  scopes: existingAuthUser.scopes,
  transaction: transaction,
);
```

**Race condition:** Between checking for existing `GoogleAccount` and calling `linkGoogleAuthentication()`, a concurrent request could create a duplicate. This is mitigated by running the entire check-and-link sequence inside a database transaction. If `linkGoogleAuthentication()` fails due to a unique constraint violation, we retry by looking up the now-existing `GoogleAccount` and proceeding with the normal login flow.

**Email case normalization:** Serverpod's `EmailAccount` stores emails lowercase (verified in the registration flow). `GoogleAccount` also stores emails lowercase (see `linkGoogleAuthentication()` which calls `email.toLowerCase()`). All email comparisons use the stored lowercase values with standard `equals()`.

**Key Serverpod APIs used:**
- `GoogleIdpUtils.fetchAccountDetails(session, idToken:, accessToken:)` — verify token, get email
- `GoogleAccount.db.findFirstRow(session, where: (t) => t.userIdentifier.equals(...))` — check existing Google account
- `EmailAccount.db.findFirstRow(session, where: (t) => t.email.equals(...))` — check existing email account
- `GoogleIdpUtils.linkGoogleAuthentication(session, authUserId:, accountDetails:)` — attach Google to existing AuthUser
- `AuthServices.instance.tokenManager.issueToken(session, authUserId:)` — issue JWT for the linked user

### 2. Email Registration Guard

Override `EmailIdpEndpoint.startRegistration()` to block registration when the email is already associated with a Google account.

**Flow:**

1. Before delegating to `emailIdp.startRegistration()`, query `GoogleAccount.db` for the email (case-insensitive)
2. **Match found** → throw a custom exception indicating "this email is already registered via Google, please sign in with Google instead"
3. **No match** → proceed with normal Serverpod email registration flow (3-step verified: start → verify code → finish)

**Note:** This intentionally breaks Serverpod's anti-email-enumeration pattern (which silently returns a dummy ID). We prioritize clear UX over anti-enumeration for this case, since the user needs actionable feedback.

### 3. Auto-Create User on First Login

Replace `_seedAdminUser()` with automatic `User` record creation on first successful login via any Serverpod IDP.

**`serverpodUserId` storage:** The `User.serverpodUserId` field stores `authUserId.toString()` (the UUID string form of Serverpod's `AuthUser.id`). This matches `session.authenticated.userIdentifier` which is the same UUID as a string. The current `_seedAdminUser` code already uses this convention.

**Precondition:** `resolveUser()` requires `session.authenticated` to be non-null. It should only be called when the endpoint expects a logged-in user. API-key-only requests (no JWT) should not call `resolveUser()`.

**Implementation:** A standalone `resolveUser()` function:

```dart
Future<User> resolveUser(Session session, {int? clientId}) async {
  final auth = session.authenticated!;
  final serverpodUserId = auth.userIdentifier;

  // Try to find existing User
  var user = await User.db.findFirstRow(session, where: (t) {
    var expr = t.serverpodUserId.equals(serverpodUserId);
    if (clientId != null) expr = expr & t.clientId.equals(clientId);
    return expr;
  });
  if (user != null) return user;

  // Get email/name from Serverpod UserProfile
  final profile = await UserProfile.db.findFirstRow(session,
    where: (t) => t.authUserId.equals(auth.authUserId));

  // First user in tenant becomes admin
  final userCount = await User.db.count(session,
    where: (t) => clientId != null
      ? t.clientId.equals(clientId)
      : t.clientId.equals(null));
  final role = userCount == 0 ? 'admin' : 'viewer';

  return await User.db.insertRow(session, User(
    clientId: clientId,
    email: profile?.email ?? '',
    name: profile?.fullName,
    role: role,
    isActive: true,
    serverpodUserId: serverpodUserId,
  ));
}
```

### 4. API Key Middleware (Replace DartDeskAuth)

Replace `DartDeskAuth` with a two-layer approach:

1. **Relic middleware** — extracts and format-validates the raw API key from headers, rejects if missing. Stores the raw key on the `Request` via `ContextProperty`.
2. **`requireApiKey()` function** — called in endpoints with a `Session`. Does the DB lookup via `ApiKeyValidator.validate()`, returns `ApiKeyContext`.

This split is necessary because RPC server middleware runs before `Session` creation, so DB operations aren't available in middleware.

**Middleware (header extraction + format validation):**

```dart
final _rawApiKeyProperty = ContextProperty<String>('rawApiKey');

extension RawApiKeyRequest on Request {
  String get rawApiKey => _rawApiKeyProperty.get(this);
  String? get rawApiKeyOrNull => _rawApiKeyProperty[this];
}

Middleware apiKeyMiddleware() {
  return (Handler next) {
    return (Request request) async {
      // Extract API key from x-api-key header or DartDesk scheme
      final rawApiKey = request.headers['x-api-key']?.firstOrNull
          ?? _extractApiKeyFromDartDeskScheme(
               request.headers['authorization']?.firstOrNull);
      if (rawApiKey == null) {
        return Response(statusCode: 401,
          body: Body.fromString('Missing API key'));
      }
      // Format validation only (prefix check)
      if (!rawApiKey.startsWith('cms_r_') && !rawApiKey.startsWith('cms_w_')) {
        return Response(statusCode: 401,
          body: Body.fromString('Invalid API key format'));
      }
      _rawApiKeyProperty[request] = rawApiKey;
      return await next(request);
    };
  };
}
```

**DB validation function (called in endpoints with Session):**

```dart
Future<ApiKeyContext> requireApiKey(Session session) async {
  final rawKey = session.request!.rawApiKey;
  final ctx = await ApiKeyValidator.validate(session, rawKey);
  if (ctx == null) throw Exception('Invalid API key');
  return ctx;
}
```

**Registration in server.dart:**

```dart
pod.server.addMiddleware(apiKeyMiddleware());
```

**DartDesk Authorization scheme parsing** stays in `server.dart`'s `authenticationHandler` override for JWT extraction. The middleware independently extracts the API key portion from the same `Authorization` header — both parse the compound `DartDesk apiKey=xxx;Basic <jwt>` scheme, each taking their respective part.

**Endpoint usage:**

```dart
class DocumentEndpoint extends Endpoint {
  Future<Document> getDocument(Session session, int id) async {
    final apiKey = await requireApiKey(session);
    final user = await resolveUser(session, clientId: apiKey.clientId);
    // ...
  }
}
```

### 5. IDP Endpoint API Key Gating

The middleware applies to all RPC server requests, including `/emailIdp` and `/googleIdp`. This means IDP endpoints are automatically gated by API key — only client apps with valid API keys can call auth endpoints. This prevents brute-force attacks and spam registrations from unknown sources.

## Removals

| Item | Reason |
|------|--------|
| `DartDeskAuth` class | Replaced by middleware + `resolveUser()` |
| `ExternalAuthStrategy` interface | Future custom providers use Serverpod's `IdpBaseEndpoint` + OAuth2 PKCE utility |
| `User.externalId` field | No longer needed |
| `User.externalProvider` field | No longer needed |
| `users_external_id_idx` index | No longer needed |
| `_seedAdminUser()` in server.dart | Replaced by auto-create in `resolveUser()` |
| Admin email/password in passwords.yaml | No longer needed |

## User Model Changes

```yaml
# Before
fields:
  clientId: int?
  email: String
  name: String?
  role: String, default='viewer'
  isActive: bool, default=true
  serverpodUserId: String?
  externalId: String?
  externalProvider: String?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now

# After
fields:
  clientId: int?
  email: String
  name: String?
  role: String, default='viewer'
  isActive: bool, default=true
  serverpodUserId: String?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now
```

Removed fields: `externalId`, `externalProvider`
Removed index: `users_external_id_idx`

## Auth Flow Summary

```
Request arrives at RPC server
│
├─ apiKeyMiddleware (Relic middleware)
│  ├─ Extract API key from x-api-key or DartDesk scheme
│  ├─ Validate via ApiKeyValidator
│  ├─ Store ApiKeyContext on request via ContextProperty
│  └─ Reject if missing/invalid (401/403)
│
├─ authenticationHandler (Serverpod)
│  ├─ Extract JWT from Authorization header or DartDesk scheme
│  ├─ Validate JWT → populate session.authenticated
│  └─ (null if no JWT — e.g., API-key-only requests)
│
└─ Endpoint method
   ├─ session.request!.apiKeyContext → tenant context
   ├─ session.authenticated → user identity (if present)
   └─ resolveUser() → find or create User record
```

## Notification on Auto-Link

When Google auto-links to an existing email/password account:
- Server logs the event
- Optional email notification callback (same pattern as `sendRegistrationVerificationCode`)
- The auth response is standard `AuthSuccess` (no modification needed)

## Testing Strategy

- Unit tests for `resolveUser()` (first user = admin, subsequent = viewer)
- Integration tests for Google auto-link flow (mock Google token verification)
- Integration tests for email registration guard (reject when Google account exists)
- Integration tests for API key middleware (reject missing/invalid, pass valid)
- Migration test for User model changes (externalId/externalProvider removal)

## Migration

- Database migration to drop `externalId`, `externalProvider` columns and `users_external_id_idx` index
- Update all endpoints to use `session.request!.apiKeyContext` instead of `DartDeskAuth.authenticateRequest()`
- Update all `_requireAuth` helpers to use new pattern
- Remove `DartDeskAuth` and `ExternalAuthStrategy` files
- Remove `_seedAdminUser()` and related passwords.yaml entries
