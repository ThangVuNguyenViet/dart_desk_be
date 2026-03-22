# Require x-api-key on All API Requests

## Goal

Make `x-api-key` mandatory on every API request. The API key resolves the client (project). Remove `DartDeskTenancy` — the API key system is the sole client resolver. Expose `ApiKeyContext` to endpoints so they can enforce read/write authorization.

## Architecture

**Two-pass auth (updated):**

1. **x-api-key** (required) → resolves client + role via `ApiKeyValidator.validate`
2. **Authorization: Bearer** (optional) → resolves user identity via Serverpod IDP or external strategies

If `x-api-key` is missing or invalid, the request fails with 401 immediately. No fallback.

**Exception:** Auth-related endpoints that don't need client context (e.g., `emailIdp.login`, `googleIdp`, `refreshJwtTokens`) are exempt — they run before the user has a project context.

## Backend Changes

### 1. Update `authenticateRequest` return type

Change from `Future<User?>` to `Future<AuthResult>`, using the existing typedef:

```dart
typedef AuthResult = ({ApiKeyContext apiKey, User? user});
```

`authenticateRequest` becomes:
- Extract `x-api-key` header → validate → get `ApiKeyContext`
- If missing/invalid: throw `ServerpodException(401)` (not return null)
- Resolve user via Serverpod IDP or external strategies (using `apiKey.clientId`)
- Return `AuthResult(apiKey: apiKeyCtx, user: user)`

### 2. Remove `DartDeskTenancy`

- Delete `lib/src/tenancy.dart`
- Remove `DartDeskTenancy.configure(...)` call from `server.dart`
- Remove tenant resolver from `DartDeskRegistry` (currently named `_tenantResolver`, `setTenantResolver`, `resolveTenantId`)
- Remove `DartDeskSession.resolveTenantId` (if it exists as a convenience wrapper)

### 3. Update all endpoint callers

Every endpoint that calls `DartDeskAuth.authenticateRequest` must update to handle the new `AuthResult` return type:

All endpoints that call `DartDeskAuth.authenticateRequest` must update to use `AuthResult`. The key change: **client ID now comes from `authResult.apiKey.clientId`** (the API key), not from `user.clientId`.

| File | Notes |
|---|---|
| `cms_api_token_endpoint.dart` | `_requireUser` returns `(User, int?)` — change to extract clientId from `authResult.apiKey.clientId` |
| `document_endpoint.dart` | `_authenticateRequest` helper — update to return `AuthResult` |
| `document_collaboration_endpoint.dart` | Uses auth for identity + client |
| `media_endpoint.dart` | Uses auth for identity + client |
| `user_endpoint.dart` | Uses auth for identity + client |
| `deployment_endpoint.dart` | Has its own `_requireAdminUser` — update to use `AuthResult` |
| `project_endpoint.dart` | Uses `session.authenticated` directly — update for consistency |

### 4. Exempt endpoints

These endpoints don't require `x-api-key` because they run before the user has project context:
- `emailIdp` — Serverpod auth module
- `googleIdp` — Serverpod auth module
- `refreshJwtTokens` — Serverpod auth module
- `studioConfig` — returns client-side config (no project-specific data)

These are Serverpod module endpoints and don't go through `DartDeskAuth.authenticateRequest`, so they're naturally exempt.

### 5. Rename `tenantId` → `clientId` across all models and code

Rename the field in all Serverpod models and all code references:

| Model | Field rename |
|---|---|
| `api_token.spy.yaml` | `tenantId` → `clientId` (field + all index references) |
| `user.spy.yaml` | `tenantId` → `clientId` (field + all index references) |
| `document.spy.yaml` | `tenantId` → `clientId` (field + all index references) |
| `media_asset.spy.yaml` | `tenantId` → `clientId` (field + all index references) |

Also rename:
- `ApiKeyContext.tenantId` → `ApiKeyContext.clientId`
- `DartDeskTenancy` class name (being deleted anyway)
- All code references to `.tenantId` in endpoints, auth, services, tests

This requires `serverpod generate` and a database migration to rename the DB columns.

## Frontend Changes

### 5. `DartDeskApp` — accept `apiKey` parameter

Add `String? apiKey` to both constructors. Pass through to `DartDeskAuth` widget (built-in auth path) and make it available for `DartDeskApp.withDataSource` (external auth path).

### 6. `DartDeskAuth` widget — inject `x-api-key` header

Serverpod's `Client` doesn't expose a hook for custom HTTP headers. The `ServerpodClientRequestDelegate` creates its own `http.Client` internally, and the generated `Client` class doesn't accept a custom delegate.

**Approach:** Use `package:http`'s `runWithClient` to provide a custom `http.BaseClient` that injects the `x-api-key` header on every request:

```dart
class ApiKeyClient extends http.BaseClient {
  final http.Client _inner;
  final String _apiKey;

  ApiKeyClient(this._inner, this._apiKey);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['x-api-key'] = _apiKey;
    return _inner.send(request);
  }
}
```

In the app's `main()`:

```dart
runWithClient(
  () => runApp(MyApp()),
  () => ApiKeyClient(http.Client(), apiKey),
);
```

This works on web (where Serverpod uses `package:http`). For IO (mobile/desktop), `HttpOverrides` achieves the same thing. The `DartDeskAuth` widget handles this setup when `apiKey` is provided.

### 7. `cms_app` — pass API key from `--dart-define`

```dart
class MyApp extends StatelessWidget {
  static const apiKey = String.fromEnvironment('API_KEY');

  @override
  Widget build(BuildContext context) {
    return DartDeskApp(
      serverUrl: serverUrl,
      apiKey: apiKey,
      config: DartDeskConfig(...),
    );
  }
}
```

Launch: `flutter run -d chrome --dart-define=API_KEY=cms_w_...`

Same for `main_e2e.dart`.

## File Map

| File | Action | Repo |
|---|---|---|
| `dart_desk_be_server/lib/src/auth/dart_desk_auth.dart` | Modify — return `AuthResult`, require x-api-key | backend |
| `dart_desk_be_server/lib/src/tenancy.dart` | Delete | backend |
| `dart_desk_be_server/lib/server.dart` | Modify — remove `DartDeskTenancy.configure` | backend |
| `dart_desk_be_server/lib/src/plugin/dart_desk_registry.dart` | Modify — remove client resolver | backend |
| `dart_desk_be_server/lib/src/plugin/dart_desk_session.dart` | Modify — remove `resolveTenantId` | backend |
| `dart_desk_be_server/lib/src/endpoints/cms_api_token_endpoint.dart` | Modify — use `AuthResult` | backend |
| `dart_desk_be_server/lib/src/endpoints/document_endpoint.dart` | Modify — use `AuthResult` | backend |
| `dart_desk_be_server/lib/src/endpoints/document_collaboration_endpoint.dart` | Modify — use `AuthResult` | backend |
| `dart_desk_be_server/lib/src/endpoints/media_endpoint.dart` | Modify — use `AuthResult` | backend |
| `dart_desk_be_server/lib/src/endpoints/user_endpoint.dart` | Modify — use `AuthResult` | backend |
| `dart_desk_be_server/lib/src/endpoints/deployment_endpoint.dart` | Modify — use `AuthResult` | backend |
| `dart_desk_be_server/lib/src/auth/api_key_context.dart` | Modify — rename `tenantId` → `clientId` | backend |
| `dart_desk_be_server/lib/src/auth/api_key_validator.dart` | Modify — update `tenantId` references | backend |
| `dart_desk_be_server/lib/src/models/api_token.spy.yaml` | Modify — rename `tenantId` → `clientId` | backend |
| `dart_desk_be_server/lib/src/models/user.spy.yaml` | Modify — rename `tenantId` → `clientId` | backend |
| `dart_desk_be_server/lib/src/models/document.spy.yaml` | Modify — rename `tenantId` → `clientId` | backend |
| `dart_desk_be_server/lib/src/models/media_asset.spy.yaml` | Modify — rename `tenantId` → `clientId` | backend |
| `dart_desk/packages/dart_desk/lib/src/studio/dart_desk_app.dart` | Modify — add `apiKey` param | frontend |
| `dart_desk/packages/dart_desk/lib/src/cloud/dart_desk_auth.dart` | Modify — inject x-api-key header | frontend |
| `dart_desk/packages/dart_desk/lib/src/cloud/api_key_http_client.dart` | Create — HTTP client wrapper | frontend |
| `dart_desk/examples/cms_app/lib/main.dart` | Modify — read API_KEY, pass to DartDeskApp | frontend |
| `dart_desk/examples/cms_app/lib/main_e2e.dart` | Modify — read API_KEY, pass to DartDeskApp | frontend |

## Migration Impact

- **Breaking change for all API consumers.** Every request must now include `x-api-key`.
- Existing CMS app deployments will break until they're updated with an API key.
- The cloud plugin must stop using `setTenantResolver` and instead ensure clients send `x-api-key`.

## Out of Scope

- Rate limiting for failed API key validations
- Per-endpoint read/write enforcement (the infrastructure is there via `authResult.apiKey.canWrite`, but adding checks to each endpoint is a separate task)
