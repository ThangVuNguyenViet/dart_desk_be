# Require x-api-key on All API Requests

## Goal

Make `x-api-key` mandatory on every API request. The API key resolves the tenant (project). Remove `DartDeskTenancy` — the API key system is the sole tenant resolver. Expose `ApiKeyContext` to endpoints so they can enforce read/write authorization.

## Architecture

**Two-pass auth (updated):**

1. **x-api-key** (required) → resolves tenant + role via `ApiKeyValidator.validate`
2. **Authorization: Bearer** (optional) → resolves user identity via Serverpod IDP or external strategies

If `x-api-key` is missing or invalid, the request fails with 401 immediately. No fallback.

**Exception:** Auth-related endpoints that don't need tenant context (e.g., `emailIdp.login`, `googleIdp`, `refreshJwtTokens`) are exempt — they run before the user has a project context.

## Backend Changes

### 1. Update `authenticateRequest` return type

Change from `Future<User?>` to `Future<AuthResult>`, using the existing typedef:

```dart
typedef AuthResult = ({ApiKeyContext apiKey, User? user});
```

`authenticateRequest` becomes:
- Extract `x-api-key` header → validate → get `ApiKeyContext`
- If missing/invalid: throw `ServerpodException(401)` (not return null)
- Resolve user via Serverpod IDP or external strategies (using `apiKey.tenantId`)
- Return `AuthResult(apiKey: apiKeyCtx, user: user)`

### 2. Remove `DartDeskTenancy`

- Delete `lib/src/tenancy.dart`
- Remove `DartDeskTenancy.configure(...)` call from `server.dart`
- Remove tenant resolver from `DartDeskRegistry` (`_tenantResolver`, `setTenantResolver`, `resolveTenantId`)
- Remove `DartDeskSession.resolveTenantId` (if it exists as a convenience wrapper)

### 3. Update all endpoint callers

Every endpoint that calls `DartDeskAuth.authenticateRequest` must update to handle the new `AuthResult` return type:

| File | Current pattern | New pattern |
|---|---|---|
| `cms_api_token_endpoint.dart` | `_requireUser` returns `(User, int?)` | Returns `(AuthResult, int?)` where tenantId comes from `authResult.apiKey.tenantId` |
| `document_endpoint.dart` | `_authenticateRequest` returns `User` | Returns `AuthResult`, use `authResult.apiKey.tenantId` and `authResult.user` |
| `document_collaboration_endpoint.dart` | Gets `User` from auth | Gets `AuthResult`, uses `.user` for identity, `.apiKey.tenantId` for tenant |
| `media_endpoint.dart` | Gets `User` from auth | Same pattern |
| `user_endpoint.dart` | Gets `User` from auth | Same pattern |
| `project_endpoint.dart` | Uses `session.authenticated` directly | Should use `AuthResult` for consistency (or keep as-is since project management may be admin-only) |

### 4. Exempt endpoints

These endpoints don't require `x-api-key` because they run before the user has project context:
- `emailIdp` — Serverpod auth module
- `googleIdp` — Serverpod auth module
- `refreshJwtTokens` — Serverpod auth module
- `studioConfig` — returns client-side config (no tenant data)

These are Serverpod module endpoints and don't go through `DartDeskAuth.authenticateRequest`, so they're naturally exempt.

## Frontend Changes

### 5. `DartDeskApp` — accept `apiKey` parameter

Add `String? apiKey` to both constructors. Pass through to `DartDeskAuth` widget (built-in auth path) and make it available for `DartDeskApp.withDataSource` (external auth path).

### 6. `DartDeskAuth` widget — inject `x-api-key` header

Serverpod's `Client` uses `ServerpodClientRequestDelegate` for HTTP calls. The delegate's `serverRequest` method only accepts `body` and `authenticationValue` — there's no hook for custom headers.

**Approach:** Create a wrapper delegate that adds `x-api-key` to every request.

For the browser implementation (`serverpod_client_browser.dart`), the `http.Client.post` call accepts a `headers` map. We wrap the delegate to inject our header:

```dart
class ApiKeyRequestDelegate extends ServerpodClientRequestDelegate {
  final ServerpodClientRequestDelegate _inner;
  final String _apiKey;

  ApiKeyRequestDelegate(this._inner, this._apiKey);

  @override
  Future<String> serverRequest<T>(Uri url, {required String body, String? authenticationValue}) {
    // We need to override the actual HTTP call to inject x-api-key header
    // Since _inner.serverRequest doesn't expose headers, we need to
    // reimplement the HTTP call with the extra header.
  }

  @override
  void close() => _inner.close();
}
```

**Problem:** The `serverRequest` interface doesn't expose headers — we can't wrap it. We need to reimplement the HTTP call. Since the CMS app runs on web (Chrome), we only need the browser implementation.

**Solution:** Create `ApiKeyHttpClient` that wraps `http.Client` and adds the header, then use Serverpod's existing browser delegate with the wrapped client. However, the delegate creates its own `http.Client` internally.

**Simplest approach:** Fork the browser delegate pattern in the dart_desk package — a small class (~30 lines) that does the same POST with an extra header. Pass it to `Client` via... but `Client` doesn't accept a custom delegate either.

**Actual simplest approach:** Serverpod's `Client` (generated code) extends `ServerpodClientShared` which has a `_requestDelegate` field. Looking at the constructor chain, the delegate is created internally based on platform. There's no public API to override it.

**Pragmatic approach:** Use `http_interceptor` or monkey-patch. But the cleanest solution for Serverpod is:

Override `callServerEndpoint` on the generated `Client` class. But we can't — it's generated.

**Final approach:** Create a custom HTTP client wrapper at the `http` package level. Serverpod's browser delegate uses `http.Client()`. We can provide our own `http.Client` that adds headers by using `http.Client` with an interceptor via `BaseClient`:

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

But we still can't inject this into Serverpod's delegate since it creates `http.Client()` internally.

**Actually simplest approach:** The `dart_desk` package already wraps all API calls through `CloudDataSource`. Instead of modifying the Serverpod client internals, we can add `x-api-key` at the CloudDataSource level by subclassing the Serverpod client or using a different HTTP approach.

**Recommended approach:** Since Serverpod doesn't support custom headers on the client, use `HttpOverrides` (dart:io) or a custom `http.Client` via zone injection to intercept all HTTP requests from the Serverpod client and add the header. On web, use `http.Client` override.

Actually, the simplest and most maintainable approach: **Patch the Serverpod-generated Client.** Since `client.dart` is generated, we should not modify it. But we can create a subclass or extension.

Wait — re-reading the code: `ServerpodClientShared` constructor creates the delegate internally, but the delegate is stored as `_requestDelegate`. We can't access it.

**RECOMMENDED APPROACH:** Create a thin HTTP interceptor in the `dart_desk` package that wraps the platform's HTTP client. On web (where the CMS app runs), Serverpod uses `package:http`'s `Client`. We can use Dart's `HttpOverrides` (IO) or zone-based `Client` injection to add the header globally for the Serverpod client instance.

For Flutter web specifically: use `package:http`'s `runWithClient` (added in http 1.2.0) to provide a custom `Client` that adds headers:

```dart
import 'package:http/http.dart' as http;

runWithClient(
  () => runApp(MyApp()),
  () => ApiKeyClient(http.Client(), apiKey),
);
```

This is clean, doesn't modify Serverpod internals, and works on web. For IO (mobile/desktop), `HttpOverrides` achieves the same thing.

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
| `dart_desk_be_server/lib/src/plugin/dart_desk_registry.dart` | Modify — remove tenant resolver | backend |
| `dart_desk_be_server/lib/src/plugin/dart_desk_session.dart` | Modify — remove `resolveTenantId` | backend |
| `dart_desk_be_server/lib/src/endpoints/cms_api_token_endpoint.dart` | Modify — use `AuthResult` | backend |
| `dart_desk_be_server/lib/src/endpoints/document_endpoint.dart` | Modify — use `AuthResult` | backend |
| `dart_desk_be_server/lib/src/endpoints/document_collaboration_endpoint.dart` | Modify — use `AuthResult` | backend |
| `dart_desk_be_server/lib/src/endpoints/media_endpoint.dart` | Modify — use `AuthResult` | backend |
| `dart_desk_be_server/lib/src/endpoints/user_endpoint.dart` | Modify — use `AuthResult` | backend |
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
