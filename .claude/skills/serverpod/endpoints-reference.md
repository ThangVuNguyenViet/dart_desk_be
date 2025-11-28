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

## Best Practices

1. Keep endpoint methods stateless
2. Use the Session object for database access
3. Return typed Futures for type safety
4. Keep operations fast (sub-second)
5. Run `serverpod generate` after changes
