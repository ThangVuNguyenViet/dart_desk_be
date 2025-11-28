# Advanced Endpoints Reference

## Endpoint Inheritance

Serverpod supports sophisticated inheritance patterns for code reuse and behavior configuration.

## Standard Inheritance

Parent methods are preserved while adding child-specific methods.

```dart
class BaseEndpoint extends Endpoint {
  Future<String> commonMethod(Session session) async {
    return 'Common functionality';
  }
}

class SpecializedEndpoint extends BaseEndpoint {
  Future<String> specialMethod(Session session) async {
    return 'Specialized functionality';
  }

  // Both commonMethod and specialMethod are available
}
```

## Abstract Endpoints

Abstract endpoints aren't exposed as API endpoints but their methods appear through subclasses.

```dart
abstract class BaseEndpoint extends Endpoint {
  Future<String> sharedLogic(Session session) async {
    return 'Shared implementation';
  }
}

class ConcreteEndpoint extends BaseEndpoint {
  // Inherits sharedLogic but BaseEndpoint isn't accessible to clients
}
```

## Method Overriding

Override inherited behavior using `@override`.

```dart
class ParentEndpoint extends Endpoint {
  Future<String> greet(Session session, String name) async {
    return 'Hello $name';
  }
}

class ChildEndpoint extends ParentEndpoint {
  @override
  Future<String> greet(Session session, String name) async {
    return 'Hi there, $name!';
  }
}
```

## Method Hiding

Use `@doNotGenerate` to exclude specific inherited methods.

```dart
class ParentEndpoint extends Endpoint {
  Future<String> publicMethod(Session session) async {
    return 'Public';
  }

  Future<String> internalMethod(Session session) async {
    return 'Internal';
  }
}

class ChildEndpoint extends ParentEndpoint {
  @doNotGenerate
  @override
  Future<String> internalMethod(Session session) async {
    // This method won't be generated for clients
    return super.internalMethod(session);
  }
}
```

## Method Unhiding

Override `@doNotGenerate` annotations from parent classes.

```dart
abstract class BaseEndpoint extends Endpoint {
  @doNotGenerate
  Future<String> hiddenMethod(Session session) async {
    return 'Hidden';
  }
}

class PublicEndpoint extends BaseEndpoint {
  @override
  Future<String> hiddenMethod(Session session) async {
    // Now exposed to clients despite parent annotation
    return 'Now public';
  }
}
```

## Base Endpoint for Common Behavior

Create pre-configured base classes for common requirements.

```dart
abstract class LoggedInEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;
}

abstract class AdminEndpoint extends LoggedInEndpoint {
  @override
  Future<bool> handleCall(Session session) async {
    final user = await User.db.findById(session, session.userId!);
    if (user?.role != 'admin') {
      throw Exception('Admin access required');
    }
    return super.handleCall(session);
  }
}

// All admin endpoints automatically require login and admin role
class AdminDashboardEndpoint extends AdminEndpoint {
  Future<DashboardData> getData(Session session) async {
    // User is guaranteed to be admin here
    return await DashboardData.fetch(session);
  }
}
```

## Excluding Endpoints from Generation

The `@doNotGenerate` annotation prevents code generation for entire classes.

```dart
@doNotGenerate
class InternalEndpoint extends Endpoint {
  Future<String> internalOnly(Session session) async {
    return 'Not exposed to clients';
  }
}

// Can still be called from other endpoints
class PublicEndpoint extends Endpoint {
  Future<String> useInternal(Session session) async {
    final internal = InternalEndpoint();
    return await internal.internalOnly(session);
  }
}
```

## Data Type Support

### Primitive Types

Supported return types and parameters:
- `bool`
- `int`
- `double`
- `String`
- `UuidValue`
- `Duration`
- `DateTime`
- `ByteData`
- `Uri`
- `BigInt`

### Collections

Must be strictly typed:
- `List<T>`
- `Map<K, V>`
- `Set<T>`
- `Record` types

### Custom Objects

Any serializable model defined in protocol files.

```dart
Future<Recipe> getRecipe(Session session, int id) async {
  return await Recipe.db.findById(session, id);
}

Future<List<Recipe>> getAllRecipes(Session session) async {
  return await Recipe.db.find(session);
}

Future<Map<String, Recipe>> getRecipeMap(Session session) async {
  final recipes = await Recipe.db.find(session);
  return {for (var r in recipes) r.id.toString(): r};
}
```

## Size Limitations

**Important:** The size of a call is by default limited to 512 kB.

This includes:
- Request parameters
- Response data
- Serialized objects

For large data transfers:
- Use file uploads (separate mechanism)
- Paginate large result sets
- Stream data instead of bulk transfers
- Compress data when appropriate

```dart
// Good: Paginated response
Future<List<Recipe>> getRecipes(
  Session session,
  {int page = 0, int pageSize = 20}
) async {
  return await Recipe.db.find(
    session,
    offset: page * pageSize,
    limit: pageSize,
  );
}

// Bad: Could exceed 512 kB limit
Future<List<Recipe>> getAllRecipes(Session session) async {
  return await Recipe.db.find(session); // Potentially thousands of recipes
}
```

## Endpoint Naming

The endpoint name derives from the class name with the "Endpoint" suffix removed.

```dart
// Creates 'user' endpoint
class UserEndpoint extends Endpoint { }

// Creates 'userProfile' endpoint
class UserProfileEndpoint extends Endpoint { }

// Creates 'api' endpoint
class ApiEndpoint extends Endpoint { }
```

## Session Object

The `Session` parameter provides access to:
- **Database**: `session.db`
- **Authentication**: `session.auth`, `session.userId`, `session.isUserSignedIn`
- **Passwords**: `session.passwords['key']`
- **Logging**: `session.log`
- **Messages**: Send real-time messages

```dart
Future<void> exampleSession(Session session) async {
  // Database access
  final users = await User.db.find(session);

  // Authentication check
  if (session.isUserSignedIn) {
    final userId = session.userId!;
    final user = await User.db.findById(session, userId);
  }

  // Logging
  session.log('Processing request');

  // Access passwords
  final apiKey = session.passwords['external_api'];
}
```

## Error Handling

```dart
Future<Recipe> getRecipe(Session session, int id) async {
  final recipe = await Recipe.db.findById(session, id);

  if (recipe == null) {
    throw Exception('Recipe not found');
  }

  return recipe;
}

// With custom error types
class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

Future<Recipe> getRecipeWithCustomError(Session session, int id) async {
  final recipe = await Recipe.db.findById(session, id);

  if (recipe == null) {
    throw NotFoundException('Recipe with id $id not found');
  }

  return recipe;
}
```

## Async Patterns

### Sequential Operations

```dart
Future<ProcessedData> processSequentially(Session session, int id) async {
  final data = await fetchData(session, id);
  final validated = await validateData(session, data);
  final processed = await processData(session, validated);
  return processed;
}
```

### Parallel Operations

```dart
Future<CombinedData> processParallel(Session session) async {
  final results = await Future.wait([
    fetchUserData(session),
    fetchRecipes(session),
    fetchSettings(session),
  ]);

  return CombinedData(
    user: results[0],
    recipes: results[1],
    settings: results[2],
  );
}
```

## Best Practices

1. **Keep methods stateless** - Don't store state in endpoint instances
2. **Complete quickly** - Aim for sub-second response times
3. **Use proper types** - Leverage type safety for parameters and returns
4. **Handle errors gracefully** - Provide meaningful error messages
5. **Validate input** - Check parameters before processing
6. **Use inheritance wisely** - Create base classes for common patterns
7. **Document complex methods** - Add comments for non-obvious logic
8. **Respect size limits** - Paginate large data sets
9. **Log appropriately** - Use session.log for debugging
10. **Test thoroughly** - Write tests for all endpoint methods

## Performance Considerations

1. **Database queries** - Optimize with proper indexes and where clauses
2. **N+1 queries** - Use joins or batch loading
3. **Caching** - Cache frequently accessed data
4. **Async operations** - Use Future.wait for parallel operations
5. **Data serialization** - Keep response payloads reasonable
6. **Connection pooling** - Serverpod handles this automatically

## Common Patterns

### CRUD Endpoint

```dart
class RecipeEndpoint extends Endpoint {
  // Create
  Future<Recipe> create(Session session, Recipe recipe) async {
    return await Recipe.db.insertRow(session, recipe);
  }

  // Read
  Future<Recipe?> get(Session session, int id) async {
    return await Recipe.db.findById(session, id);
  }

  // Update
  Future<Recipe> update(Session session, Recipe recipe) async {
    await Recipe.db.updateRow(session, recipe);
    return recipe;
  }

  // Delete
  Future<void> delete(Session session, int id) async {
    await Recipe.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id),
    );
  }

  // List
  Future<List<Recipe>> list(Session session, {int page = 0}) async {
    return await Recipe.db.find(
      session,
      offset: page * 20,
      limit: 20,
      orderBy: (t) => t.date,
      orderDescending: true,
    );
  }
}
```

### Protected Resource Pattern

```dart
class ProtectedEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<UserData> getUserData(Session session) async {
    final userId = session.userId!;

    // Fetch only user's own data
    final data = await UserData.db.find(
      session,
      where: (t) => t.userId.equals(userId),
    );

    return data;
  }
}
```

### Service Integration Pattern

```dart
class ExternalApiEndpoint extends Endpoint {
  Future<ExternalData> fetchExternal(Session session, String query) async {
    final apiKey = session.passwords['external_api'];

    // Call external service
    final response = await http.get(
      Uri.parse('https://api.example.com/data?q=$query'),
      headers: {'Authorization': 'Bearer $apiKey'},
    );

    // Process and return
    return ExternalData.fromJson(jsonDecode(response.body));
  }
}
```
