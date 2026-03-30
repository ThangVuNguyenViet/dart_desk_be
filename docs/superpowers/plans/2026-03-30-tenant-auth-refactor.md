# Tenant Auth Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the backend to explicit `Client -> Project` tenancy, move runtime auth to project-scoped API keys through `authenticationHandler`, remove custom Serverpod overrides and `ApiKeyContext`, and preserve the manage app as JWT-authenticated but API-key-exempt.

**Architecture:** Treat `Client` as the tenant boundary and `Project` as the runtime boundary. Schema, protocol, and endpoint contracts move runtime entities from `clientId` to `projectId`, while auth derives `project:{id}`, `project.read`, and `project.write` scopes directly from `ApiToken` and its owning `Project`. Manage endpoints continue to use user JWT auth, and dynamic map payloads cross the RPC boundary as JSON strings only.

**Tech Stack:** Dart, Serverpod 3.4.0, Serverpod auth, generated protocol/models, PostgreSQL migrations, Dart test, Flutter manage app integration assumptions.

---

## File Structure

### Server auth and boot

- Modify: `dart_desk_server/lib/server.dart`
- Modify: `dart_desk_server/lib/src/auth/api_key_validator.dart`
- Delete: `dart_desk_server/lib/src/auth/api_key_context.dart`
- Modify: `dart_desk_server/lib/src/auth/dart_desk_session.dart`
- Modify: `dart_desk_server/lib/src/auth/resolve_user.dart`

Responsibilities:

- configure upstream-compatible `authenticationHandler`
- resolve `ApiToken` directly instead of custom API-key context
- expose scoped session helpers for `clientId`, `projectId`, `canRead`, and `canWrite`

### Schema and generated protocol

- Modify: `dart_desk_server/lib/src/models/project.spy.yaml`
- Modify: `dart_desk_server/lib/src/models/api_token.spy.yaml`
- Modify: `dart_desk_server/lib/src/models/document.spy.yaml`
- Modify: `dart_desk_server/lib/src/models/media_asset.spy.yaml`
- Modify: `dart_desk_server/lib/src/models/user.spy.yaml` if the implementation confirms tenant-membership semantics
- Regenerate: `dart_desk_server/lib/src/generated/*`
- Regenerate: `dart_desk_client/lib/src/protocol/*`
- Regenerate: `dart_desk_server/migrations/*`

Responsibilities:

- make `Project.clientId` explicit
- move runtime ownership to `projectId`
- update generated bindings to match the new contract

### Endpoints

- Modify: `dart_desk_server/lib/src/endpoints/cms_api_token_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/document_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/document_collaboration_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/media_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/public_content_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/project_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/user_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/deployment_endpoint.dart`
- Regenerate: `dart_desk_server/lib/src/generated/endpoints.dart`
- Regenerate: `dart_desk_client/lib/src/protocol/client.dart`

Responsibilities:

- split manage endpoints from runtime endpoints cleanly
- change project-scoped parameters from `clientId` to `projectId`
- enforce `project.read` and `project.write`
- keep JSON-string transport for dynamic map payloads

### Tests

- Modify: `dart_desk_server/test/integration/helpers/test_data_factory.dart`
- Modify: `dart_desk_server/test/integration/api_key_auth_test.dart`
- Modify: `dart_desk_server/test/integration/api_token_validation_test.dart`
- Modify: `dart_desk_server/test/integration/cms_api_token_endpoint_test.dart`
- Modify: `dart_desk_server/test/integration/document_endpoint_test.dart`
- Modify: `dart_desk_server/test/integration/document_collaboration_endpoint_test.dart`
- Modify: `dart_desk_server/test/integration/media_endpoint_test.dart`
- Modify: `dart_desk_server/test/integration/public_content_endpoint_test.dart`
- Modify: `dart_desk_server/test/integration/project_endpoint_test.dart`
- Modify: `dart_desk_server/test/integration/user_endpoint_test.dart`
- Modify: `dart_desk_server/test/unit/dart_desk_session_ext_test.dart`
- Modify: `dart_desk_server/test/unit/api_key_validator_test.dart`

Responsibilities:

- remove assumptions about `clientId == project.id`
- remove injected `ApiKeyContext`
- prove project isolation and read/write scope behavior

### Client auth header plumbing

- Modify: `dart_desk_client/lib/src/auth/dart_desk_auth_key_provider.dart`
- Modify: `flutter_cms_be_client/pubspec.yaml`
- Modify: `dart_desk_client/pubspec.yaml`
- Modify: `dart_desk_server/pubspec.yaml`

Responsibilities:

- send `Bearer {authToken}:{apiKey}`
- remove fork overrides and pin upstream Serverpod version

### Manage app follow-up surface

- Follow-up repo: `../dart_desk_cloud/dart_desk_manage`

Responsibilities:

- rename project-scoped params from `clientId` to `projectId`
- keep JWT-authenticated requests API-key-exempt

### Task 1: Lock upstream Serverpod and auth header contract

**Files:**
- Modify: `dart_desk_server/pubspec.yaml`
- Modify: `dart_desk_client/pubspec.yaml`
- Modify: `flutter_cms_be_client/pubspec.yaml`
- Modify: `dart_desk_client/lib/src/auth/dart_desk_auth_key_provider.dart`
- Test: `dart_desk_server/test/integration/api_key_auth_test.dart`

- [ ] **Step 1: Write the failing auth-header test**

```dart
test('auth header provider formats bearer payload as authToken:apiKey', () async {
  final inner = _FakeAuthProvider('jwt-token');
  final provider = DartDeskAuthKeyProvider(
    apiKey: 'project-key',
    inner: inner,
  );

  expect(await provider.authHeaderValue, 'jwt-token:project-key');
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test dart_desk_server/test/integration/api_key_auth_test.dart`
Expected: FAIL because the current auth header contract or test fixtures still assume `x-api-key` or fork-specific behavior.

- [ ] **Step 3: Write minimal implementation**

```dart
dependencies:
  serverpod: 3.4.0
  serverpod_auth_core_server: 3.4.0
  serverpod_auth_idp_server: 3.4.0

class DartDeskAuthKeyProvider implements ClientAuthKeyProvider {
  @override
  Future<String?> get authHeaderValue async {
    final innerValue = await inner?.authHeaderValue;
    final authToken = innerValue ?? 'null';
    return '$authToken:$apiKey';
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `dart test dart_desk_server/test/integration/api_key_auth_test.dart`
Expected: PASS for the header-format assertion.

- [ ] **Step 5: Commit**

```bash
git add dart_desk_server/pubspec.yaml dart_desk_client/pubspec.yaml flutter_cms_be_client/pubspec.yaml dart_desk_client/lib/src/auth/dart_desk_auth_key_provider.dart dart_desk_server/test/integration/api_key_auth_test.dart
git commit -m "chore: move auth clients to upstream serverpod"
```

### Task 2: Convert the schema to explicit client and project ownership

**Files:**
- Modify: `dart_desk_server/lib/src/models/project.spy.yaml`
- Modify: `dart_desk_server/lib/src/models/api_token.spy.yaml`
- Modify: `dart_desk_server/lib/src/models/document.spy.yaml`
- Modify: `dart_desk_server/lib/src/models/media_asset.spy.yaml`
- Modify: `dart_desk_server/lib/src/models/user.spy.yaml` if tenant-membership semantics are confirmed
- Regenerate: `dart_desk_server/lib/src/generated/protocol.dart`
- Regenerate: `dart_desk_server/lib/src/generated/project.dart`
- Regenerate: `dart_desk_server/lib/src/generated/api_token.dart`
- Regenerate: `dart_desk_server/lib/src/generated/document.dart`
- Regenerate: `dart_desk_server/lib/src/generated/media_asset.dart`
- Regenerate: `dart_desk_client/lib/src/protocol/project.dart`
- Regenerate: `dart_desk_client/lib/src/protocol/api_token.dart`
- Regenerate: `dart_desk_client/lib/src/protocol/document.dart`
- Regenerate: `dart_desk_client/lib/src/protocol/media_asset.dart`
- Regenerate: `dart_desk_server/migrations/*`
- Test: `dart_desk_server/test/unit/protocol_deserialization_test.dart`

- [ ] **Step 1: Write the failing schema contract tests**

```dart
test('api token serializes with projectId', () {
  final token = ApiToken(
    projectId: 3,
    name: 'preview',
    tokenHash: 'hash',
    tokenPrefix: 'abc',
    tokenSuffix: 'xyz',
    role: 'editor',
    createdAt: DateTime(2026),
  );

  expect(token.toJson()['projectId'], 3);
  expect(token.toJson().containsKey('clientId'), isFalse);
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test dart_desk_server/test/unit/protocol_deserialization_test.dart`
Expected: FAIL because generated models still expose `clientId` for runtime-owned records.

- [ ] **Step 3: Write minimal implementation**

```yaml
# project.spy.yaml
class: Project
table: projects
fields:
  clientId: int, relation(parent=clients, onDelete=Cascade)

# api_token.spy.yaml
fields:
  projectId: int, relation(parent=projects, onDelete=Cascade)

# document.spy.yaml
fields:
  projectId: int, relation(parent=projects, onDelete=Cascade)
```

- [ ] **Step 4: Regenerate protocol and migration artifacts**

Run: `dart pub get && serverpod generate`
Expected: generated models and migration files now expose `projectId` on runtime-owned types and `clientId` on `Project`.

- [ ] **Step 5: Run tests to verify the contract**

Run: `dart test dart_desk_server/test/unit/protocol_deserialization_test.dart`
Expected: PASS with `projectId`-based serialization.

- [ ] **Step 6: Commit**

```bash
git add dart_desk_server/lib/src/models dart_desk_server/lib/src/generated dart_desk_client/lib/src/protocol dart_desk_server/migrations dart_desk_server/test/unit/protocol_deserialization_test.dart
git commit -m "refactor: make project ownership explicit"
```

### Task 3: Replace ApiKeyContext with scoped authenticationHandler auth

**Files:**
- Modify: `dart_desk_server/lib/server.dart`
- Modify: `dart_desk_server/lib/src/auth/api_key_validator.dart`
- Delete: `dart_desk_server/lib/src/auth/api_key_context.dart`
- Modify: `dart_desk_server/lib/src/auth/dart_desk_session.dart`
- Modify: `dart_desk_server/test/unit/dart_desk_session_ext_test.dart`
- Modify: `dart_desk_server/test/unit/api_key_validator_test.dart`
- Test: `dart_desk_server/test/integration/api_key_auth_test.dart`

- [ ] **Step 1: Write the failing scope-auth test**

```dart
test('api token authentication yields project and write scopes', () async {
  final authInfo = await authenticateBearer('null:valid-project-token');

  expect(authInfo, isNotNull);
  expect(authInfo!.scopes, contains(Scope('project:1')));
  expect(authInfo.scopes, contains(Scope('project.read')));
  expect(authInfo.scopes, contains(Scope('project.write')));
});
```

- [ ] **Step 2: Run test to verify it fails**

Run: `dart test dart_desk_server/test/integration/api_key_auth_test.dart dart_desk_server/test/unit/dart_desk_session_ext_test.dart`
Expected: FAIL because auth still depends on `ApiKeyContext` and request context wiring.

- [ ] **Step 3: Write minimal implementation**

```dart
final pod = Serverpod(
  args,
  Protocol(),
  Endpoints(),
  authenticationHandler: (session, token) async {
    if (token == null) return null;
    final parts = token.split(':');
    final authToken = parts[0];
    final apiKey = parts.length > 1 ? parts[1] : null;

    final scopes = <Scope>{};
    int? userId;

    if (authToken.isNotEmpty && authToken != 'null') {
      final authInfo = await UserAuthentication.authenticateRequest(session, authToken);
      if (authInfo != null) {
        userId = authInfo.userId;
        scopes.addAll(authInfo.scopes);
      }
    }

    if (apiKey != null && apiKey.isNotEmpty && apiKey != 'null') {
      final tokenRow = await ApiKeyValidator.validate(session, apiKey);
      if (tokenRow != null) {
        scopes.add(Scope('project:${tokenRow.projectId}'));
        scopes.add(Scope('project.read'));
        if (tokenRow.role == 'editor' || tokenRow.role == 'admin') {
          scopes.add(Scope('project.write'));
        }
      }
    }

    return scopes.isEmpty ? null : AuthenticationInfo(userId ?? -1, scopes);
  },
);
```

- [ ] **Step 4: Run tests to verify it passes**

Run: `dart test dart_desk_server/test/integration/api_key_auth_test.dart dart_desk_server/test/unit/dart_desk_session_ext_test.dart dart_desk_server/test/unit/api_key_validator_test.dart`
Expected: PASS with no `ApiKeyContext` dependency.

- [ ] **Step 5: Commit**

```bash
git add dart_desk_server/lib/server.dart dart_desk_server/lib/src/auth/api_key_validator.dart dart_desk_server/lib/src/auth/dart_desk_session.dart dart_desk_server/test/integration/api_key_auth_test.dart dart_desk_server/test/unit/dart_desk_session_ext_test.dart dart_desk_server/test/unit/api_key_validator_test.dart
git rm dart_desk_server/lib/src/auth/api_key_context.dart
git commit -m "refactor: authenticate api tokens through scopes"
```

### Task 4: Rewire endpoint contracts to explicit project scoping

**Files:**
- Modify: `dart_desk_server/lib/src/endpoints/cms_api_token_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/document_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/document_collaboration_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/media_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/public_content_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/project_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/user_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/deployment_endpoint.dart`
- Regenerate: `dart_desk_server/lib/src/generated/endpoints.dart`
- Regenerate: `dart_desk_client/lib/src/protocol/client.dart`
- Test: `dart_desk_server/test/integration/cms_api_token_endpoint_test.dart`
- Test: `dart_desk_server/test/integration/document_endpoint_test.dart`
- Test: `dart_desk_server/test/integration/document_collaboration_endpoint_test.dart`
- Test: `dart_desk_server/test/integration/media_endpoint_test.dart`
- Test: `dart_desk_server/test/integration/public_content_endpoint_test.dart`
- Test: `dart_desk_server/test/integration/project_endpoint_test.dart`
- Test: `dart_desk_server/test/integration/user_endpoint_test.dart`

- [ ] **Step 1: Write failing endpoint authorization tests**

```dart
test('document list rejects token from a different project', () async {
  final response = () => endpoints.document.listDocuments(
    otherProjectSession,
    'page',
  );

  await expectLater(response, throwsA(isA<Exception>()));
});

test('api token management accepts jwt-authenticated manage requests without api key', () async {
  final tokens = await endpoints.apiToken.getTokens(
    manageSession,
    projectId: seededProject.id!,
  );

  expect(tokens, isA<List<ApiToken>>());
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test dart_desk_server/test/integration/cms_api_token_endpoint_test.dart dart_desk_server/test/integration/document_endpoint_test.dart dart_desk_server/test/integration/media_endpoint_test.dart`
Expected: FAIL because endpoints still mix `clientId` and `projectId` or require old auth state.

- [ ] **Step 3: Write minimal implementation**

```dart
Future<({int projectId, User? user})> _requireProjectRead(Session session) async {
  if (!session.canRead || session.projectId == null) {
    throw Exception('Missing read permission');
  }
  return (projectId: session.projectId!, user: null);
}

Future<List<ApiToken>> getTokens(Session session, {required int projectId}) async {
  await _requireManageProjectAccess(session, projectId);
  return ApiToken.db.find(session, where: (t) => t.projectId.equals(projectId));
}

Future<Document> createDocument(Session session, String type, String title, String dataJson) async {
  final auth = await _requireProjectWrite(session);
  final data = jsonDecode(dataJson) as Map<String, dynamic>;
  return Document.db.insertRow(session, Document(projectId: auth.projectId, ...));
}
```

- [ ] **Step 4: Regenerate endpoint bindings**

Run: `serverpod generate`
Expected: generated client and endpoint contracts expose `projectId` where the server methods changed and JSON string parameters for dynamic map fields remain intact.

- [ ] **Step 5: Run tests to verify endpoint behavior**

Run: `dart test dart_desk_server/test/integration/cms_api_token_endpoint_test.dart dart_desk_server/test/integration/document_endpoint_test.dart dart_desk_server/test/integration/document_collaboration_endpoint_test.dart dart_desk_server/test/integration/media_endpoint_test.dart dart_desk_server/test/integration/public_content_endpoint_test.dart dart_desk_server/test/integration/project_endpoint_test.dart dart_desk_server/test/integration/user_endpoint_test.dart`
Expected: PASS for manage JWT access, runtime project isolation, and project read/write enforcement.

- [ ] **Step 6: Commit**

```bash
git add dart_desk_server/lib/src/endpoints dart_desk_server/lib/src/generated/endpoints.dart dart_desk_client/lib/src/protocol/client.dart dart_desk_server/test/integration/cms_api_token_endpoint_test.dart dart_desk_server/test/integration/document_endpoint_test.dart dart_desk_server/test/integration/document_collaboration_endpoint_test.dart dart_desk_server/test/integration/media_endpoint_test.dart dart_desk_server/test/integration/public_content_endpoint_test.dart dart_desk_server/test/integration/project_endpoint_test.dart dart_desk_server/test/integration/user_endpoint_test.dart
git commit -m "refactor: scope runtime endpoints to projects"
```

### Task 5: Preserve JSON-string transport for dynamic content fields

**Files:**
- Modify: `dart_desk_server/lib/src/endpoints/document_endpoint.dart`
- Modify: `dart_desk_server/lib/src/endpoints/document_collaboration_endpoint.dart`
- Modify: `dart_desk_client/lib/src/protocol/client.dart`
- Test: `dart_desk_server/test/integration/document_endpoint_test.dart`
- Test: `dart_desk_server/test/integration/document_collaboration_endpoint_test.dart`

- [ ] **Step 1: Write failing round-trip tests**

```dart
test('document version data returns JSON string payload', () async {
  final data = await endpoints.document.getDocumentVersionData(session, versionId);

  expect(data, contains('"title":"Hello"'));
});

test('submit edit accepts JSON string field updates', () async {
  final updated = await endpoints.documentCollaboration.submitEdit(
    writeSession,
    documentId,
    'session-1',
    '{"title":"Updated"}',
  );

  expect(updated.data, contains('"Updated"'));
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test dart_desk_server/test/integration/document_endpoint_test.dart dart_desk_server/test/integration/document_collaboration_endpoint_test.dart`
Expected: FAIL if any endpoint or generated contract still expects `Map<String, dynamic>` directly.

- [ ] **Step 3: Write minimal implementation**

```dart
Future<Document> updateDocumentData(Session session, int documentId, String updatesJson) async {
  final updates = jsonDecode(updatesJson) as Map<String, dynamic>;
  ...
}

Future<String?> getDocumentVersionData(Session session, int versionId) async {
  final state = await session.crdtService.getStateAtHlc(session, version.documentId, version.snapshotHlc!);
  return jsonEncode(state);
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `dart test dart_desk_server/test/integration/document_endpoint_test.dart dart_desk_server/test/integration/document_collaboration_endpoint_test.dart`
Expected: PASS with string-based dynamic payload transport.

- [ ] **Step 5: Commit**

```bash
git add dart_desk_server/lib/src/endpoints/document_endpoint.dart dart_desk_server/lib/src/endpoints/document_collaboration_endpoint.dart dart_desk_client/lib/src/protocol/client.dart dart_desk_server/test/integration/document_endpoint_test.dart dart_desk_server/test/integration/document_collaboration_endpoint_test.dart
git commit -m "fix: use json strings for dynamic document payloads"
```

### Task 6: Repair factories and end-to-end verification for multi-project tenants

**Files:**
- Modify: `dart_desk_server/test/integration/helpers/test_data_factory.dart`
- Modify: `dart_desk_server/test/integration/test_tools/serverpod_test_tools.dart`
- Modify: `dart_desk_server/test/integration/api_token_validation_test.dart`
- Modify: `dart_desk_server/test/integration/deployment_endpoint_test.dart`
- Modify: `dart_desk_server/test/integration/public_content_endpoint_test.dart`
- Test: `dart_desk_server/test/integration/*`

- [ ] **Step 1: Write failing isolation tests**

```dart
test('two projects under one client cannot read each others documents', () async {
  final projectA = await factory.createProject(clientId: client.id!);
  final projectB = await factory.createProject(clientId: client.id!);
  await factory.createDocument(projectId: projectA.id!, title: 'A');

  await expectLater(
    () => endpoints.document.listDocuments(sessionForProject(projectB.id!), 'page'),
    throwsA(isA<Exception>()),
  );
});
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `dart test dart_desk_server/test/integration/api_token_validation_test.dart dart_desk_server/test/integration/public_content_endpoint_test.dart dart_desk_server/test/integration/deployment_endpoint_test.dart`
Expected: FAIL because fixtures and helpers still build auth state around the old implicit tenant model.

- [ ] **Step 3: Write minimal implementation**

```dart
static AuthenticationInfo projectAuth({
  required int clientId,
  required int projectId,
  bool canWrite = false,
}) {
  return AuthenticationInfo(
    1,
    {
      Scope('client:$clientId'),
      Scope('project:$projectId'),
      Scope('project.read'),
      if (canWrite) Scope('project.write'),
    },
  );
}
```

- [ ] **Step 4: Run the focused integration suite**

Run: `dart test dart_desk_server/test/integration/api_key_auth_test.dart dart_desk_server/test/integration/api_token_validation_test.dart dart_desk_server/test/integration/cms_api_token_endpoint_test.dart dart_desk_server/test/integration/document_endpoint_test.dart dart_desk_server/test/integration/document_collaboration_endpoint_test.dart dart_desk_server/test/integration/media_endpoint_test.dart dart_desk_server/test/integration/public_content_endpoint_test.dart dart_desk_server/test/integration/project_endpoint_test.dart dart_desk_server/test/integration/user_endpoint_test.dart`
Expected: PASS with project-scoped isolation and manage JWT exemptions.

- [ ] **Step 5: Run the broader server test suite**

Run: `dart test`
Expected: PASS across unit and integration coverage, or a short list of residual failures tied to explicit follow-up work.

- [ ] **Step 6: Commit**

```bash
git add dart_desk_server/test/integration/helpers/test_data_factory.dart dart_desk_server/test/integration/test_tools/serverpod_test_tools.dart dart_desk_server/test/integration/api_token_validation_test.dart dart_desk_server/test/integration/deployment_endpoint_test.dart dart_desk_server/test/integration/public_content_endpoint_test.dart
git commit -m "test: cover project scoped multi-tenant auth"
```

## Self-Review

Spec coverage:

- explicit `Client -> Project` tenancy: covered by Task 2
- upstream Serverpod migration: covered by Task 1
- `authenticationHandler` and scope-based auth: covered by Task 3
- endpoint access split between public, manage JWT, and runtime API key: covered by Task 4
- JSON-string dynamic payload workaround: covered by Task 5
- project isolation verification: covered by Task 6

Placeholder scan:

- no `TODO` or `TBD` markers remain
- each task has explicit files, commands, and expected outcomes

Type consistency:

- plan uses `Project.clientId` for tenant ownership
- plan uses `projectId` for `ApiToken`, `Document`, and `MediaAsset`
- plan uses scopes `project:{id}`, `project.read`, and `project.write` consistently
