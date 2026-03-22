# API Key Authentication Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add API key validation that checks `x-api-key` headers against the `ApiToken` table, consolidate on read/write roles, and remove the project-level token system.

**Architecture:** Two-pass auth — endpoints call `DartDeskAuth.authenticateRequest` which first validates the `x-api-key` header (resolves tenant + scope), then optionally resolves user identity via `Authorization: Bearer`. Serverpod has no middleware system, so validation is done via static methods called at the start of endpoint methods (same pattern as existing auth). The `ApiKeyContext` is returned alongside the optional `User` in an `AuthResult` record.

**Tech Stack:** Dart, Serverpod, `crypto` package (SHA-256, already in pubspec.yaml), existing `ApiToken` model

**Spec:** `docs/superpowers/specs/2026-03-23-api-key-authentication-design.md`

**Out of scope (TODO for follow-up):**
- Rate limiting for failed API key validations (spec mentions this but defers implementation details)
- cms_app integration (sending `x-api-key` header via `--dart-define`) — depends on frontend repo changes

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `lib/src/auth/api_key_context.dart` | Create | Data class holding validated token info (tenantId, role, tokenId) |
| `lib/src/auth/api_key_validator.dart` | Create | Parses `x-api-key` header, queries DB, checks SHA-256 hash |
| `lib/src/auth/dart_desk_auth.dart` | Modify | Integrate API key validation into `authenticateRequest`, return `AuthResult` |
| `lib/src/endpoints/cms_api_token_endpoint.dart` | Modify | Update roles to read/write, switch bcrypt→SHA-256 |
| `lib/src/endpoints/project_endpoint.dart` | Modify | Remove token generation, remove `regenerateApiToken` |
| `lib/src/models/api_token.spy.yaml` | Modify | Add prefix+suffix lookup index |
| `lib/src/models/project.spy.yaml` | Modify | Remove apiTokenHash, apiTokenPrefix, lastUsedAt fields |
| `lib/src/models/project_with_token.spy.yaml` | Delete | No longer needed |
| `test/unit/api_key_validator_test.dart` | Create | Unit tests for parsing and hashing |
| `test/integration/api_key_auth_test.dart` | Create | Integration tests for full validation flow |
| `test/integration/cms_api_token_endpoint_test.dart` | Modify | Update tests for new roles |
| `bin/seed_e2e.dart` | Modify | Update to use new token format |

All paths are relative to `dart_desk_be_server/`.

---

### Task 1: Create `ApiKeyContext` data class

**Files:**
- Create: `dart_desk_be_server/lib/src/auth/api_key_context.dart`

- [ ] **Step 1: Create the file**

```dart
/// Holds validated API key information for the current request.
class ApiKeyContext {
  final int? tenantId;
  final String role; // 'read' or 'write'
  final int tokenId;

  const ApiKeyContext({
    required this.tenantId,
    required this.role,
    required this.tokenId,
  });

  bool get canWrite => role == 'write';
  bool get canRead => true; // both roles can read
}
```

- [ ] **Step 2: Verify no compile errors**

Run: `cd dart_desk_be_server && dart analyze lib/src/auth/api_key_context.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add dart_desk_be_server/lib/src/auth/api_key_context.dart
git commit -m "feat: add ApiKeyContext data class for validated API key info"
```

---

### Task 2: Create API key validator

**Files:**
- Create: `dart_desk_be_server/lib/src/auth/api_key_validator.dart`
- Create: `dart_desk_be_server/test/unit/api_key_validator_test.dart`

- [ ] **Step 1: Write the failing test**

Create `dart_desk_be_server/test/unit/api_key_validator_test.dart`:

```dart
import 'package:dart_desk_be_server/src/auth/api_key_validator.dart';
import 'package:test/test.dart';

void main() {
  group('ApiKeyValidator', () {
    group('parseApiKey', () {
      test('parses valid read token', () {
        final result = ApiKeyValidator.parseApiKey(
          'cms_r_abcdefghijklmnopqrstuvwxyz1234567890abcdefg',
        );
        expect(result, isNotNull);
        expect(result!.prefix, equals('cms_r_'));
        expect(result.suffix, hasLength(4));
      });

      test('parses valid write token', () {
        final result = ApiKeyValidator.parseApiKey(
          'cms_w_abcdefghijklmnopqrstuvwxyz1234567890abcdefg',
        );
        expect(result, isNotNull);
        expect(result!.prefix, equals('cms_w_'));
      });

      test('returns null for invalid prefix', () {
        final result = ApiKeyValidator.parseApiKey(
          'cms_x_abcdefghijklmnopqrstuvwxyz1234567890abcdefg',
        );
        expect(result, isNull);
      });

      test('returns null for too-short token', () {
        final result = ApiKeyValidator.parseApiKey('cms_r_abc');
        expect(result, isNull);
      });

      test('returns null for empty string', () {
        final result = ApiKeyValidator.parseApiKey('');
        expect(result, isNull);
      });
    });

    group('hashToken', () {
      test('produces consistent SHA-256 hash', () {
        const token = 'cms_r_testtoken1234';
        final hash1 = ApiKeyValidator.hashToken(token);
        final hash2 = ApiKeyValidator.hashToken(token);
        expect(hash1, equals(hash2));
      });

      test('produces different hashes for different tokens', () {
        final hash1 = ApiKeyValidator.hashToken('cms_r_token_a');
        final hash2 = ApiKeyValidator.hashToken('cms_r_token_b');
        expect(hash1, isNot(equals(hash2)));
      });

      test('hash is 64 character hex string', () {
        final hash = ApiKeyValidator.hashToken('cms_r_test');
        expect(hash, hasLength(64));
        expect(hash, matches(RegExp(r'^[0-9a-f]{64}$')));
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd dart_desk_be_server && dart test test/unit/api_key_validator_test.dart`
Expected: FAIL — `ApiKeyValidator` not found

- [ ] **Step 3: Write the validator**

Create `dart_desk_be_server/lib/src/auth/api_key_validator.dart`:

```dart
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'api_key_context.dart';

/// Result of parsing an API key string.
class ParsedApiKey {
  final String prefix;
  final String suffix;
  final String rawToken;

  const ParsedApiKey({
    required this.prefix,
    required this.suffix,
    required this.rawToken,
  });
}

/// Validates x-api-key header values against the ApiToken table.
///
/// This is a stateless utility. Call [validate] from endpoint methods
/// or from [DartDeskAuth.authenticateRequest].
class ApiKeyValidator {
  static const _validPrefixes = {'cms_r_', 'cms_w_'};
  static const _prefixLength = 6;
  static const _minTokenLength = 10; // prefix + at least 4 chars
  static const _lastUsedDebounce = Duration(hours: 1);

  static const _prefixToRole = {
    'cms_r_': 'read',
    'cms_w_': 'write',
  };

  /// Parse an API key string into its components.
  /// Returns null if the format is invalid.
  static ParsedApiKey? parseApiKey(String apiKey) {
    if (apiKey.length < _minTokenLength) return null;

    final prefix = apiKey.substring(0, _prefixLength);
    if (!_validPrefixes.contains(prefix)) return null;

    final suffix = apiKey.substring(apiKey.length - 4);

    return ParsedApiKey(
      prefix: prefix,
      suffix: suffix,
      rawToken: apiKey,
    );
  }

  /// Compute SHA-256 hash of a token string (hex-encoded).
  static String hashToken(String token) {
    final bytes = utf8.encode(token);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Validate an API key against the database.
  /// Returns ApiKeyContext on success, null on failure.
  static Future<ApiKeyContext?> validate(
    Session session,
    String apiKey,
  ) async {
    final parsed = parseApiKey(apiKey);
    if (parsed == null) return null;

    final hash = hashToken(parsed.rawToken);

    // Query by prefix + suffix without tenantId filter.
    // The token lookup IS the tenant resolution.
    final candidates = await ApiToken.db.find(
      session,
      where: (t) =>
          t.tokenPrefix.equals(parsed.prefix) &
          t.tokenSuffix.equals(parsed.suffix) &
          t.isActive.equals(true),
    );

    for (final candidate in candidates) {
      if (candidate.tokenHash != hash) continue;

      // Check expiry
      if (candidate.expiresAt != null &&
          candidate.expiresAt!.isBefore(DateTime.now())) {
        return null;
      }

      // Debounce lastUsedAt update — only write if >1 hour stale
      final now = DateTime.now();
      if (candidate.lastUsedAt == null ||
          now.difference(candidate.lastUsedAt!) > _lastUsedDebounce) {
        try {
          await ApiToken.db.updateRow(
            session,
            candidate.copyWith(lastUsedAt: now),
          );
        } catch (_) {
          // Non-critical — don't fail the request
        }
      }

      final role = _prefixToRole[parsed.prefix] ?? 'read';

      return ApiKeyContext(
        tenantId: candidate.tenantId,
        role: role,
        tokenId: candidate.id!,
      );
    }

    return null;
  }
}
```

- [ ] **Step 4: Run unit tests**

Run: `cd dart_desk_be_server && dart test test/unit/api_key_validator_test.dart`
Expected: All PASS

- [ ] **Step 5: Commit**

```bash
git add dart_desk_be_server/lib/src/auth/api_key_validator.dart dart_desk_be_server/test/unit/api_key_validator_test.dart
git commit -m "feat: add API key validator with SHA-256 token hashing"
```

---

### Task 3: Update `ApiToken` model — add lookup index

**Files:**
- Modify: `dart_desk_be_server/lib/src/models/api_token.spy.yaml`

Do this before updating the endpoint (Task 4) so `serverpod generate` runs before any code changes depend on it.

- [ ] **Step 1: Add lookup index**

Update `dart_desk_be_server/lib/src/models/api_token.spy.yaml`:

```yaml
class: ApiToken
table: api_tokens
fields:
  tenantId: int?
  name: String
  tokenHash: String
  tokenPrefix: String
  tokenSuffix: String
  role: String
  createdByUserId: int?, relation(parent=users, onDelete=SetNull)
  lastUsedAt: DateTime?
  expiresAt: DateTime?
  isActive: bool, default=true
  createdAt: DateTime?, default=now
indexes:
  api_token_tenant_idx:
    fields: tenantId
  api_token_lookup_idx:
    fields: tenantId, tokenPrefix, tokenSuffix
    unique: true
  api_token_prefix_suffix_idx:
    fields: tokenPrefix, tokenSuffix
```

- [ ] **Step 2: Generate Serverpod code**

Run: `cd dart_desk_be_server && serverpod generate`
Expected: Code generation completes successfully

- [ ] **Step 3: Create migration**

Run: `cd dart_desk_be_server && serverpod create-migration`
Expected: Migration created that adds the new index

- [ ] **Step 4: Commit**

```bash
git add dart_desk_be_server/lib/src/models/api_token.spy.yaml dart_desk_be_server/lib/src/generated/ dart_desk_be_server/migrations/
git commit -m "feat: add prefix+suffix lookup index for API key validation"
```

---

### Task 4: Update `ApiTokenEndpoint` — switch to read/write roles and SHA-256

**Files:**
- Modify: `dart_desk_be_server/lib/src/endpoints/cms_api_token_endpoint.dart`
- Modify: `dart_desk_be_server/test/integration/cms_api_token_endpoint_test.dart`

- [ ] **Step 1: Update the tests first**

In `test/integration/cms_api_token_endpoint_test.dart`, replace all role references:
- `'viewer'` → `'read'`, `'cms_vi_'` → `'cms_r_'`
- `'editor'` → `'write'`, `'cms_ed_'` → `'cms_w_'`
- Remove the admin token test (only two roles now)
- Add a test that rejects invalid role `'admin'`
- Update the regenerateToken test to use `'write'` and `'cms_w_'`

Full updated test file:

```dart
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('ApiToken endpoint', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    group('createToken', () {
      test('creates read token with correct prefix', () async {
        final authed = factory.authenticatedSession();

        final tokenResult = await endpoints.apiToken.createToken(
          authed, 'Read Token', 'read', null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_r_'));
        expect(tokenResult.token.name, equals('Read Token'));
        expect(tokenResult.token.role, equals('read'));
      });

      test('creates write token with correct prefix', () async {
        final authed = factory.authenticatedSession();

        final tokenResult = await endpoints.apiToken.createToken(
          authed, 'Write Token', 'write', null,
        );

        expect(tokenResult.plaintextToken, startsWith('cms_w_'));
        expect(tokenResult.token.role, equals('write'));
      });

      test('rejects invalid role', () async {
        final authed = factory.authenticatedSession();

        expect(
          () => endpoints.apiToken.createToken(
            authed, 'Bad Token', 'admin', null,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getTokens', () {
      test('lists tokens', () async {
        final authed = factory.authenticatedSession();

        await endpoints.apiToken.createToken(authed, 'Token A', 'read', null);
        await endpoints.apiToken.createToken(authed, 'Token B', 'write', null);

        final tokens = await endpoints.apiToken.getTokens(authed);
        expect(tokens.length, equals(2));
      });
    });

    group('updateToken', () {
      test('updates token name', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiToken.createToken(
          authed, 'Original Name', 'read', null,
        );

        final updated = await endpoints.apiToken.updateToken(
          authed, created.token.id!, 'Updated Name', null, null,
        );

        expect(updated.name, equals('Updated Name'));
      });

      test('deactivates token', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiToken.createToken(
          authed, 'Active Token', 'write', null,
        );

        final updated = await endpoints.apiToken.updateToken(
          authed, created.token.id!, null, false, null,
        );

        expect(updated.isActive, isFalse);
      });
    });

    group('regenerateToken', () {
      test('returns new token value with same role prefix', () async {
        final authed = factory.authenticatedSession();
        final created = await endpoints.apiToken.createToken(
          authed, 'Regen Token', 'write', null,
        );
        final originalToken = created.plaintextToken;

        final regenerated = await endpoints.apiToken.regenerateToken(
          authed, created.token.id!,
        );

        expect(regenerated.plaintextToken, startsWith('cms_w_'));
        expect(regenerated.plaintextToken, isNot(equals(originalToken)));
        expect(regenerated.token.id, equals(created.token.id));
      });
    });

    group('deleteToken', () {
      test('deletes a token', () async {
        final authed = factory.authenticatedSession();

        final tokenResult = await endpoints.apiToken.createToken(
          authed, 'Temp Token', 'read', null,
        );

        final deleted = await endpoints.apiToken.deleteToken(
          authed, tokenResult.token.id!,
        );
        expect(deleted, isTrue);
      });
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `cd dart_desk_be_server && dart test test/integration/cms_api_token_endpoint_test.dart`
Expected: FAIL — roles don't match

- [ ] **Step 3: Update the endpoint**

In `dart_desk_be_server/lib/src/endpoints/cms_api_token_endpoint.dart`:

1. Remove `import 'package:dbcrypt/dbcrypt.dart';`
2. Add `import '../auth/api_key_validator.dart';`
3. Keep `dart:convert` and `dart:math` imports (still needed by `_generateToken`)
4. Replace `_rolePrefixes`:
   ```dart
   static const _rolePrefixes = {
     'read': 'cms_r_',
     'write': 'cms_w_',
   };
   ```
5. In `createToken`, replace bcrypt with SHA-256:
   - Remove: `final hash = DBCrypt().hashpw(rawToken, DBCrypt().gensalt());`
   - Add: `final hash = ApiKeyValidator.hashToken(rawToken);`
6. In `regenerateToken`, same bcrypt→SHA-256 replacement
7. Update error message: `'Invalid role: $role. Must be read or write.'`

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd dart_desk_be_server && dart test test/integration/cms_api_token_endpoint_test.dart`
Expected: All PASS

- [ ] **Step 5: Commit**

```bash
git add dart_desk_be_server/lib/src/endpoints/cms_api_token_endpoint.dart dart_desk_be_server/test/integration/cms_api_token_endpoint_test.dart
git commit -m "feat: update ApiTokenEndpoint to read/write roles with SHA-256 hashing"
```

---

### Task 5: Remove project-level token system

**Files:**
- Modify: `dart_desk_be_server/lib/src/models/project.spy.yaml`
- Delete: `dart_desk_be_server/lib/src/models/project_with_token.spy.yaml`
- Modify: `dart_desk_be_server/lib/src/endpoints/project_endpoint.dart`

- [ ] **Step 1: Update Project model — remove token fields**

Update `dart_desk_be_server/lib/src/models/project.spy.yaml`:

```yaml
class: Project
table: projects
fields:
  name: String
  slug: String
  description: String?
  isActive: bool, default=true
  settings: String?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now
indexes:
  projects_slug_idx:
    fields: slug
    unique: true
  projects_is_active_idx:
    fields: isActive
```

Removed: `apiTokenHash`, `apiTokenPrefix`, `lastUsedAt`

- [ ] **Step 2: Delete ProjectWithToken model**

Delete file: `dart_desk_be_server/lib/src/models/project_with_token.spy.yaml`

- [ ] **Step 3: Update ProjectEndpoint**

In `dart_desk_be_server/lib/src/endpoints/project_endpoint.dart`:

1. Remove imports: `dart:convert`, `dart:math`, `package:dbcrypt/dbcrypt.dart`
2. Remove `_generateToken()` method entirely
3. Change `createProject` return type from `Future<ProjectWithToken>` to `Future<Project>`:
   - Remove token generation lines (rawToken, prefix, hash)
   - Remove `apiTokenHash` and `apiTokenPrefix` from `Project()` constructor
   - Return `inserted` directly instead of wrapping in `ProjectWithToken`
4. Remove `regenerateApiToken` method entirely
5. Update `createProjectWithOwner`:
   - Remove token generation lines (rawToken, prefix, hash)
   - Remove `apiTokenHash` and `apiTokenPrefix` from `Project()` constructor inside the transaction

- [ ] **Step 4: Generate Serverpod code**

Run: `cd dart_desk_be_server && serverpod generate`
Expected: Code generation completes — `ProjectWithToken` generated files are removed, `Project` updated

- [ ] **Step 5: Fix any compile errors**

Run: `cd dart_desk_be_server && dart analyze lib/`
Expected: No issues. If there are references to `ProjectWithToken` or removed fields elsewhere, fix them. Check `dart_desk_be_client/` as well since protocol files are generated there too.

- [ ] **Step 6: Create migration**

Run: `cd dart_desk_be_server && serverpod create-migration`
Expected: Migration drops `apiTokenHash`, `apiTokenPrefix`, `lastUsedAt` columns from `projects` table. Note: `apiTokenHash` is currently non-nullable — PostgreSQL handles dropping non-nullable columns fine, but verify the migration SQL looks correct.

- [ ] **Step 7: Commit**

```bash
git add -A dart_desk_be_server/lib/src/models/ dart_desk_be_server/lib/src/generated/ dart_desk_be_server/lib/src/endpoints/project_endpoint.dart dart_desk_be_server/migrations/ dart_desk_be_client/
git commit -m "feat: remove project-level token system, consolidate on ApiToken"
```

---

### Task 6: Integrate API key validation into `DartDeskAuth`

**Files:**
- Modify: `dart_desk_be_server/lib/src/auth/dart_desk_auth.dart`
- Create: `dart_desk_be_server/test/integration/api_key_auth_test.dart`

Serverpod has no middleware system. The pattern is to call validation at the start of endpoint methods. `DartDeskAuth.authenticateRequest` already serves this role. We extend it to also validate the `x-api-key` header and return both the API key context and optional user in a single result.

- [ ] **Step 1: Write integration test**

Create `dart_desk_be_server/test/integration/api_key_auth_test.dart`:

```dart
import 'package:dart_desk_be_server/src/auth/api_key_context.dart';
import 'package:dart_desk_be_server/src/auth/api_key_validator.dart';
import 'package:test/test.dart';
import 'test_tools/serverpod_test_tools.dart';
import 'helpers/test_data_factory.dart';

void main() {
  withServerpod('API key validation', (sessionBuilder, endpoints) {
    late TestDataFactory factory;

    setUp(() async {
      factory = TestDataFactory(
        sessionBuilder: sessionBuilder,
        endpoints: endpoints,
      );
      await factory.ensureTestUser();
    });

    test('validates a created write token', () async {
      final authed = factory.authenticatedSession();

      final tokenResult = await endpoints.apiToken.createToken(
        authed, 'Test Write Token', 'write', null,
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        tokenResult.plaintextToken,
      );

      expect(context, isNotNull);
      expect(context!.role, equals('write'));
      expect(context.canWrite, isTrue);
    });

    test('validates a created read token', () async {
      final authed = factory.authenticatedSession();

      final tokenResult = await endpoints.apiToken.createToken(
        authed, 'Test Read Token', 'read', null,
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        tokenResult.plaintextToken,
      );

      expect(context, isNotNull);
      expect(context!.role, equals('read'));
      expect(context.canWrite, isFalse);
      expect(context.canRead, isTrue);
    });

    test('rejects invalid token', () async {
      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        'cms_w_this_is_not_a_valid_token_at_all_xxxxx',
      );

      expect(context, isNull);
    });

    test('rejects deactivated token', () async {
      final authed = factory.authenticatedSession();

      final tokenResult = await endpoints.apiToken.createToken(
        authed, 'Deactivated Token', 'read', null,
      );

      await endpoints.apiToken.updateToken(
        authed, tokenResult.token.id!, null, false, null,
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        tokenResult.plaintextToken,
      );

      expect(context, isNull);
    });

    test('rejects expired token', () async {
      final authed = factory.authenticatedSession();

      // Create token with expiry in the past
      final tokenResult = await endpoints.apiToken.createToken(
        authed,
        'Expired Token',
        'write',
        DateTime.now().subtract(Duration(hours: 1)),
      );

      final session = sessionBuilder.build();
      final context = await ApiKeyValidator.validate(
        session,
        tokenResult.plaintextToken,
      );

      expect(context, isNull);
    });
  });
}
```

- [ ] **Step 2: Run tests**

Run: `cd dart_desk_be_server && dart test test/integration/api_key_auth_test.dart`
Expected: All PASS (validator is already implemented)

- [ ] **Step 3: Update DartDeskAuth**

In `dart_desk_be_server/lib/src/auth/dart_desk_auth.dart`:

1. Add imports:
   ```dart
   import 'api_key_context.dart';
   import 'api_key_validator.dart';
   ```

2. Define a result type at the top of the file (outside the class):
   ```dart
   /// Result of authenticating a request.
   /// [apiKey] is always present for valid requests (x-api-key is required).
   /// [user] is present when the request also has a valid Bearer JWT.
   typedef AuthResult = ({ApiKeyContext apiKey, User? user});
   ```

3. Add a new method `authenticateApiKey` that extracts and validates the x-api-key header:
   ```dart
   /// Validate the x-api-key header. Returns null if missing or invalid.
   static Future<ApiKeyContext?> authenticateApiKey(Session session) async {
     final request = session.request;
     if (request == null) return null;

     final apiKeyHeader = request.headers['x-api-key']?.first;
     if (apiKeyHeader == null) return null;

     return ApiKeyValidator.validate(session, apiKeyHeader);
   }
   ```

4. Update `authenticateRequest` to use `ApiKeyContext` for tenant resolution when present. In the Serverpod built-in auth branch, change:
   ```dart
   final tenantId = await DartDeskTenancy.resolveTenantId(session);
   ```
   to:
   ```dart
   final apiKeyCtx = await authenticateApiKey(session);
   final tenantId = apiKeyCtx?.tenantId ?? await DartDeskTenancy.resolveTenantId(session);
   ```

   Same change in `_findOrCreateUser` — accept tenantId as a parameter instead of resolving it again:
   ```dart
   static Future<User> _findOrCreateUser(
     Session session,
     ExternalAuthUser extUser,
     String providerName,
     int? tenantId,
   ) async {
     // Remove the line: final tenantId = await DartDeskTenancy.resolveTenantId(session);
     // Use the tenantId parameter instead
   ```

   Update the call site in `authenticateRequest` to pass tenantId:
   ```dart
   return _findOrCreateUser(session, extUser, strategy.name, tenantId);
   ```
   where `tenantId` is the one already resolved (from apiKeyCtx or DartDeskTenancy).

- [ ] **Step 4: Run all integration tests**

Run: `cd dart_desk_be_server && dart test test/integration/`
Expected: All PASS

- [ ] **Step 5: Commit**

```bash
git add dart_desk_be_server/lib/src/auth/dart_desk_auth.dart dart_desk_be_server/test/integration/api_key_auth_test.dart
git commit -m "feat: integrate API key validation into DartDeskAuth"
```

---

### Task 7: Update `seed_e2e.dart`

**Files:**
- Modify: `dart_desk_be_server/bin/seed_e2e.dart`

The current seed script inserts into `cms_clients` table (old name) with a `cms_ad_` prefixed bcrypt-hashed token stored on the project row. Update it to:
- Insert the project into `projects` table without token fields
- Insert a separate `api_tokens` row with SHA-256 hash and `cms_w_` prefix

- [ ] **Step 1: Update seed script**

Read the current `bin/seed_e2e.dart` file. Replace:
1. The token prefix from `cms_ad_` to `cms_w_`
2. The hashing from `DBCrypt().hashpw(...)` to SHA-256 (`ApiKeyValidator.hashToken(...)`)
3. The SQL INSERT: instead of storing the token on the project row, insert a row into `api_tokens` with:
   - `tenantId` = the project's ID
   - `name` = 'E2E Test Token'
   - `tokenHash` = SHA-256 hash
   - `tokenPrefix` = 'cms_w_'
   - `tokenSuffix` = last 4 chars of the raw token
   - `role` = 'write'
   - `isActive` = true
4. Remove `apiTokenHash` and `apiTokenPrefix` from the project INSERT
5. Update the table name from `cms_clients` to `projects` if it hasn't been updated already

The known test token value should be something like:
```dart
const testToken = 'cms_w_e2e_test_token_for_integration_testing_2026';
```

- [ ] **Step 2: Verify no compile errors**

Run: `cd dart_desk_be_server && dart analyze bin/seed_e2e.dart`
Expected: No issues

- [ ] **Step 3: Commit**

```bash
git add dart_desk_be_server/bin/seed_e2e.dart
git commit -m "feat: update e2e seed to use new API key system with SHA-256"
```

---

### Task 8: Database migration — consolidate and add data migration

**Files:**
- Generated migration files from Tasks 3 and 5

- [ ] **Step 1: Review generated migrations**

Check the migrations created in Tasks 3 and 5. Ensure they:
- Add the `api_token_prefix_suffix_idx` index on `api_tokens`
- Drop `apiTokenHash`, `apiTokenPrefix`, `lastUsedAt` from `projects` table
- Drop the `project_with_tokens` table (if Serverpod created one)
- Do NOT drop the `api_tokens` table

- [ ] **Step 2: Add data migration to invalidate existing tokens**

Existing tokens use bcrypt hashes and old prefixes (`cms_vi_`, `cms_ed_`, `cms_ad_`). They cannot be migrated because the plaintext is not stored. Add a SQL statement to the latest migration:

```sql
-- Breaking change: invalidate all existing API tokens.
-- Old tokens use bcrypt hashes and legacy prefixes (cms_vi_, cms_ed_, cms_ad_).
-- Users must create new tokens after this migration.
DELETE FROM api_tokens;
```

- [ ] **Step 3: Test migration locally**

Run:
```bash
cd dart_desk_be_server
docker compose up -d
dart run bin/main.dart --apply-migrations
```
Expected: Server starts with clean schema, no errors

- [ ] **Step 4: Commit**

```bash
git add dart_desk_be_server/migrations/
git commit -m "feat: database migration — drop project tokens, invalidate legacy API tokens"
```

---

### Task 9: Final verification

- [ ] **Step 1: Run all tests**

Run: `cd dart_desk_be_server && dart test`
Expected: All tests pass

- [ ] **Step 2: Run analyzer**

Run: `cd dart_desk_be_server && dart analyze`
Expected: No issues

- [ ] **Step 3: Verify server starts**

Run: `cd dart_desk_be_server && dart run bin/main.dart --apply-migrations`
Expected: Server starts without errors

- [ ] **Step 4: Commit any final fixes**

If any issues were found in steps 1-3, fix and commit.
