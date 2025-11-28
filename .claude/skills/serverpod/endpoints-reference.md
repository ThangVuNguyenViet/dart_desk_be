# Serverpod Endpoints Reference

## Overview

Endpoints extend the `Endpoint` class and contain methods that handle server-side operations. You can choose any directory structure you want.

## Method Requirements

Endpoint methods must follow these conventions:

### Return Types
Must return a typed `Future` of:
- `void`
- `bool`, `int`, `double`, `String`
- `UuidValue`, `Duration`, `DateTime`, `ByteData`, `Uri`, `BigInt`
- Serializable models
- Typed `List`, `Map`, or `Set` collections

### Parameters
- **First parameter**: Must be a `Session` object
- **Additional parameters**: Can accept any serializable types

## Basic Example

```dart
class RecipeEndpoint extends Endpoint {
  Future<String> generateRecipe(Session session, String ingredients) async {
    // Implementation here
    return responseText;
  }
}
```

## Key Features

- Access passwords via `session.passwords` map
- The `Session` object provides database access and other Serverpod features (similar to `BuildContext` in Flutter)
- Methods should be **stateless** and complete quickly (typically sub-second)

## Code Generation

After defining endpoints, run:
```bash
serverpod generate
```

This creates:
- Client bindings for Flutter/Dart apps
- Registers endpoints in the generated protocol file
- Enables type-safe client-side calls

## Named Parameters

Use named parameters for optional values:

```dart
class DocumentEndpoint extends Endpoint {
  Future<List<Document>> list(
    Session session, {
    int limit = 50,
    int offset = 0,
    String? documentType,
  }) async {
    return await Document.db.find(
      session,
      where: documentType != null
          ? (t) => t.documentType.equals(documentType)
          : null,
      limit: limit,
      offset: offset,
    );
  }
}
```

## Exception Handling

### Throwing Serializable Exceptions

Create custom exception classes for client-friendly errors:

```dart
// In models/my_exception.spy.yaml
class: MyException
fields:
  message: String
  errorCode: int
```

```dart
// In endpoint
Future<Document> getDocument(Session session, int id) async {
  final doc = await Document.db.findById(session, id);
  if (doc == null) {
    throw MyException(
      message: 'Document not found',
      errorCode: 404,
    );
  }
  return doc;
}
```

### Catching Exceptions on Client

```dart
try {
  final doc = await client.document.getDocument(id);
} on MyException catch (e) {
  print('Error: ${e.message} (${e.errorCode})');
}
```

## Calling Endpoints from Client

After running `serverpod generate`, call endpoints:

```dart
// In Flutter app
final client = Client('http://localhost:8080/')
  ..connectivityMonitor = FlutterConnectivityMonitor();

// Call endpoint method
final documents = await client.document.list(
  limit: 20,
  offset: 0,
);
```

## Session Object

The `Session` object provides access to:

```dart
// Database access
await Model.db.find(session);

// Storage
await session.storage.storeFile(...);

// Logging
session.log('Message', level: LogLevel.info);

// Passwords from config
final apiKey = session.passwords['myApiKey'];

// Authentication (when using serverpod_auth)
final userId = await session.authenticated?.userId;
```

## Endpoint Registration

Endpoints are automatically registered when placed in `lib/src/endpoints/`. After `serverpod generate`:

```dart
// Generated in lib/src/generated/endpoints.dart
class Endpoints extends EndpointDispatch {
  @override
  void initializeEndpoints(Server server) {
    // Auto-registered endpoints
  }
}
```

## Best Practices

1. Keep endpoint methods stateless
2. Use the Session object for database access
3. Return typed Futures for type safety
4. Keep operations fast (sub-second)
5. Run `serverpod generate` after changes
6. Use named parameters for optional values
7. Create serializable exceptions for client-friendly errors
8. Always validate input parameters
9. Use transactions for multi-step operations
10. Log errors appropriately
