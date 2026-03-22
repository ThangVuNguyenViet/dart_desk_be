# API Key Authentication Design

## Problem

Dart Desk has no mechanism to authenticate programmatic API calls. Two orphaned token systems exist (project-level `dd_live_*` and tenant-scoped `ApiToken` CRUD) but neither validates incoming requests. Every API call to a Dart Desk instance — whether cloud-hosted or self-hosted — needs authentication.

## Decision

Consolidate on the `ApiToken` system with two roles. Drop the project-level token from the `Project` model.

## Authentication Model

Two orthogonal headers authenticate requests:

| Header | Purpose | Identifies |
|---|---|---|
| `x-api-key: cms_r_xxx` or `cms_w_xxx` | Project-level access gate | Which project, what scope |
| `Authorization: Bearer <jwt>` | User identity (optional) | Who is making the request |

### Request Patterns by Consumer

| Consumer | `x-api-key` | `Authorization: Bearer` | Permissions from |
|---|---|---|---|
| Public frontend (read content) | `cms_r_xxx` | — | Token (read-only) |
| cms_app (edit content) | `cms_w_xxx` | JWT | User role |
| CLI (deploy) | `cms_w_xxx` | JWT | User role |

### Why Two Layers

- `x-api-key` proves the request comes from an authorized app/project.
- `Authorization: Bearer` proves which user is making the request.
- Public frontends use `x-api-key` alone — no user session. A leaked read token cannot modify content (defense-in-depth).
- cms_app and CLI use both — the token gates project access, the user's role (on the `User` model) controls fine-grained permissions (admin, editor, viewer).

## Token Design

### Roles and Prefixes

| Role | Prefix | Permissions |
|---|---|---|
| Read | `cms_r_` | Read published content |
| Write | `cms_w_` | Read + write content + deploy |

### Token Format

```
cms_r_<43 chars base64url>   (total 49 chars)
cms_w_<43 chars base64url>   (total 49 chars)
```

### Storage

- **`tokenHash`**: SHA-256 hash of the full token (for verification)
- **`tokenPrefix`**: `cms_r_` or `cms_w_` (for quick filtering)
- **`tokenSuffix`**: last 4 characters (for display: `cms_r_...ab3Q`)
- **Unique constraint**: `(tenantId, tokenPrefix, tokenSuffix)`

Plaintext is returned once at creation and never stored.

**Why SHA-256 instead of bcrypt:** Tokens are 32 bytes of cryptographic randomness — dictionary attacks are infeasible. bcrypt's ~100ms per check is too slow for every API request. SHA-256 is effectively instant and equally secure for high-entropy secrets.

### Model Changes

**`ApiToken` table — update roles:**
- Remove: `viewer`, `editor`, `admin` roles
- Add: `read`, `write` roles
- Update `_rolePrefixes` map: `{'read': 'cms_r_', 'write': 'cms_w_'}`
- Change `tokenHash` from bcrypt to SHA-256

**`Project` table — drop token fields:**
- Remove: `apiTokenHash`, `apiTokenPrefix` columns
- Remove: token generation from `createProject`, `createProjectWithOwner`, `regenerateApiToken`
- Remove: `ProjectWithToken` model

## Implementation: API Key Middleware

API key validation is a **separate middleware layer**, not an `ExternalAuthStrategy`. The `ExternalAuthStrategy` interface is designed for user-identity providers (Firebase, Clerk) that return a person with an email and auto-create `User` rows. API keys are machine credentials — forcing them through that path would create ghost users.

### Two-Pass Authentication

```
Request arrives
  │
  ├─ Pass 1: API Key Middleware
  │   Read x-api-key header → validate token → set tenant context + token scope
  │   (runs before DartDeskAuth)
  │
  └─ Pass 2: DartDeskAuth.authenticateRequest
      Read Authorization: Bearer header → resolve user identity + role
      (existing flow, unchanged)
```

The API key middleware attaches an `ApiKeyContext` to the session containing:
- `tenantId` — resolved from the matched token
- `role` — `read` or `write`
- `tokenId` — for audit/logging

### Validation Flow

1. Read `x-api-key` header — if absent, reject (no unauthenticated access)
2. Parse prefix (`cms_r_` or `cms_w_`) — reject if unrecognized
3. Extract suffix (last 4 chars)
4. Query `ApiToken` by `(tokenPrefix, tokenSuffix)` where `isActive = true` — **without tenantId filter** (the token lookup IS the tenant resolution)
5. `SHA-256(rawToken) == token.tokenHash` — reject if mismatch
6. Check `expiresAt` — reject if expired
7. Set tenant context from the matched token's `tenantId`
8. Debounce `lastUsedAt` update — only write if last recorded time is >1 hour stale
9. Attach `ApiKeyContext` to session

### Endpoint Authorization

Endpoints check the token's role to enforce scope:

- **Read endpoints** (e.g., `getDocuments`): accept both `read` and `write` tokens
- **Write endpoints** (e.g., `createDocument`, `deploy`): require `write` token
- If a user session is also present (Pass 2), the user's role on the `User` model provides further permission checks

### Rate Limiting

Failed API key validations should be rate-limited at the middleware level to prevent brute-force attempts and bcrypt-less DoS. Implementation details deferred to the implementation plan, but the middleware should track failed attempts by IP and apply exponential backoff.

## Token Lifecycle

1. User signs up and creates a project in the **manage app**
2. User creates an API token (read or write) in the manage app's Tokens screen
3. Plaintext is shown once in a reveal dialog — user copies it
4. User pastes into:
   - **cms_app**: `--dart-define=CMS_API_TOKEN=cms_w_xxx`
   - **Frontend**: environment variable, passed to Dart Desk client
   - **CLI**: config file or environment variable
5. Token can be deactivated, regenerated, or deleted from the manage app

## cms_app Integration

The cms_app requires a write token to launch, passed as a compile-time environment variable:

```dart
const apiToken = String.fromEnvironment('CMS_API_TOKEN');
```

The app sends this token as `x-api-key` header on every API call to the Dart Desk backend.

## Migration Plan

1. Add API key middleware to the backend (separate from `ExternalAuthStrategy`)
2. Switch `tokenHash` from bcrypt to SHA-256
3. Update `ApiToken` roles from `viewer/editor/admin` to `read/write`
4. Update prefixes from `cms_vi_/cms_ed_/cms_ad_` to `cms_r_/cms_w_`
5. Invalidate all existing tokens (breaking change — users must regenerate; existing tokens cannot be migrated because plaintext is not stored)
6. Remove `apiTokenHash`, `apiTokenPrefix` from `Project` model
7. Remove `ProjectWithToken` model
8. Remove `regenerateApiToken` from `ProjectEndpoint`
9. Update `createProject` and `createProjectWithOwner` to not generate tokens
10. Update manage app token creation UI to offer read/write roles
11. Update cms_app to send `x-api-key` header
12. Add database migration for schema changes
