---
name: serverpod
description: "Expert guidance for the Serverpod backend framework for Flutter/Dart. Use when (1) creating or modifying Serverpod endpoints, (2) defining database models in YAML with relations and indexes, (3) working with the Serverpod ORM for queries, transactions, and migrations, (4) implementing authentication with Google, Apple, email, or custom providers, (5) setting up caching with Redis or in-memory stores, (6) building real-time features with streams and WebSockets, (7) deploying Serverpod to cloud providers, (8) managing sessions, serialization, or code generation. Triggers include serverpod, endpoint, database model, ORM, session, migration, serverpod auth, serverpod deploy, serverpod generate."
---

# Serverpod

Open-source, scalable backend framework for Flutter enabling full-stack Dart development. Version 3.3.0.

- Docs: https://docs.serverpod.dev/
- pub.dev: https://pub.dev/packages/serverpod
- GitHub: https://github.com/serverpod/serverpod

## Project Structure

```
my_project/
├── my_project_server/    # Server (endpoints, models, business logic)
│   ├── lib/src/
│   │   ├── endpoints/    # API endpoints
│   │   └── models/       # YAML model definitions
│   ├── migrations/       # Database migrations
│   └── config/           # Server configuration
├── my_project_client/    # Auto-generated client library
└── my_project_flutter/   # Flutter app
```

## Quick Start

```bash
# Install CLI
dart pub global activate serverpod_cli

# Create project
serverpod create my_project

# Generate code after model/endpoint changes
cd my_project_server && serverpod generate

# Create migration after model changes
serverpod create-migration

# Start server (requires Docker for PostgreSQL + Redis)
docker compose up --build --detach && dart run bin/main.dart
```

For full setup details: see [references/getting-started.md](references/getting-started.md)

## Core Concepts

### Models (YAML)

Define in `lib/src/models/`:

```yaml
# company.yaml
class: Company
table: company
fields:
  name: String
  ceo: Employee?, relation(name=company_ceo)
indexes:
  company_name_idx:
    fields: name
    unique: true
```

After changes: `serverpod generate` then `serverpod create-migration`

**Key features:**
- Types: `int`, `double`, `bool`, `String`, `DateTime`, `Duration`, `UuidValue`, `ByteData`, `Uri`, enums, `List<T>`, `Map<String, T>`
- Field scopes: `database` (default), `api`, `all`, `none`
- Relations: `relation(name=...)`, `relation(parent=table_name)`, `relation(optional)`

Full model syntax: see [references/models.md](references/models.md)

### Endpoints

Define in `lib/src/endpoints/`:

```dart
class CompanyEndpoint extends Endpoint {
  Future<Company> create(Session session, {required String name}) async {
    return Company.db.insertRow(session, Company(name: name));
  }

  Future<List<Company>> list(Session session) async {
    return Company.db.find(session);
  }
}
```

Call from Flutter:
```dart
final company = await client.company.create(name: 'Acme');
```

- `Session` provides access to database, caching, auth, logging
- All params after `session` must be named
- Throw `SerializableException` subclasses for typed client errors

Advanced patterns: see [references/endpoints.md](references/endpoints.md)

### Database (ORM)

```dart
// Insert
final row = await Company.db.insertRow(session, company);

// Query with filtering
final companies = await Company.db.find(
  session,
  where: (t) => t.name.like('A%') & t.ceo.has(),
  orderBy: (t) => t.name,
  limit: 10,
);

// Find by ID / first match
final c = await Company.db.findById(session, id);
final c = await Company.db.findFirstRow(session, where: (t) => t.name.equals('Acme'));

// Update and delete
company.name = 'New Name';
await Company.db.updateRow(session, company);
await Company.db.deleteWhere(session, where: (t) => t.name.like('Old%'));

// Transactions
await session.db.transaction((tx) async {
  await Company.db.insertRow(session, c1, transaction: tx);
  await Company.db.insertRow(session, c2, transaction: tx);
});

// Eager loading relations
final c = await Company.db.findById(session, id,
  include: Company.include(ceo: Employee.include()));
```

Raw SQL, migrations, indexing: see [references/database.md](references/database.md)

### Authentication (IDP System - Serverpod 3.x)

**Server setup** (`server.dart`):
```dart
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

// No authenticationHandler needed - initializeAuthServices handles it
final pod = Serverpod(args, Protocol(), Endpoints());

pod.initializeAuthServices(
  tokenManagerBuilders: [JwtConfigFromPasswords()],
  identityProviderBuilders: [
    GoogleIdpConfig(clientSecret: GoogleClientSecret.fromJsonString(
      pod.getPassword('googleClientSecret')!,
    )),
  ],
);
```

**Required endpoints** (create these files):
```dart
// google_idp_endpoint.dart
class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {}

// refresh_jwt_tokens_endpoint.dart
class RefreshJwtTokensEndpoint extends core.RefreshJwtTokensEndpoint {}
```

**Check auth in methods**:
```dart
final authInfo = session.authenticated; // AuthenticationInfo?
final userIdentifier = authInfo?.userIdentifier; // String (UUID)
```

**Require auth on endpoint**:
```dart
class SecureEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  @override
  Set<Scope> get requiredScopes => {Scope('admin')};
}
```

**Flutter client setup**:
```dart
client = Client(apiUrl)
  ..connectivityMonitor = FlutterConnectivityMonitor()
  ..authSessionManager = FlutterAuthSessionManager();
await client.auth.initialize();
await client.auth.initializeGoogleSignIn();
```

**Google Sign-In widget** (new IDP):
```dart
GoogleSignInWidget(
  client: client,
  onAuthenticated: () { /* signed in */ },
  onError: (error) { /* handle error */ },
)
```

Setup and providers: see [references/authentication.md](references/authentication.md)

### Caching

```dart
// Local (in-memory) and global (Redis) caching
await session.caches.local.put('key', obj);
await session.caches.global.put('key', obj, lifetime: Duration(minutes: 5));
final obj = await session.caches.global.get<MyObject>('key');
await session.caches.localAndGlobal.invalidateKey('key');
```

Cache patterns and groups: see [references/caching.md](references/caching.md)

### Real-time

```dart
// Server: post to channel
session.messages.postMessage('chat_1', ChatMessage(text: 'Hello'));

// Client: listen
client.messages.listen<ChatMessage>('chat_1').listen((msg) => print(msg.text));
```

Streams, WebSockets, patterns: see [references/realtime.md](references/realtime.md)

## Reference Files

| File | Use when |
|------|----------|
| [references/getting-started.md](references/getting-started.md) | Setting up a new project, understanding structure |
| [references/models.md](references/models.md) | Defining YAML models, relations, indexes, enums |
| [references/endpoints.md](references/endpoints.md) | Creating endpoints, inheritance, error handling |
| [references/database.md](references/database.md) | ORM queries, migrations, raw SQL, transactions, indexing |
| [references/authentication.md](references/authentication.md) | Auth setup, sign-in providers, custom auth, scopes |
| [references/caching.md](references/caching.md) | In-memory/Redis caching, cache patterns, TTL |
| [references/realtime.md](references/realtime.md) | Streams, WebSockets, message channels |
| [references/deployment.md](references/deployment.md) | Server config, Docker, cloud deploy, nginx, scaling |
