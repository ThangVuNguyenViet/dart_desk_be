# Serverpod Caching Reference

## Overview

Serverpod includes high-performance, distributed caching capabilities out-of-the-box. The caching system supports both in-memory storage and Redis distribution for scaled deployments.

## Cache Types

### In-Memory Caching
- **Best for**: Single-server deployments, development
- **Storage**: Server RAM
- **Persistence**: Lost on restart
- **Speed**: Fastest (no network overhead)
- **Scaling**: Limited to single instance

### Redis Caching
- **Best for**: Multi-server deployments, production
- **Storage**: Redis server
- **Persistence**: Configurable (optional)
- **Speed**: Very fast (network overhead minimal)
- **Scaling**: Distributed across instances

## Basic Caching Operations

### Store Data in Cache

```dart
Future<void> cacheData(Session session) async {
  final data = {'key': 'value', 'count': 42};

  await session.caches.local.put(
    'my_cache_key',
    data,
  );
}
```

### Retrieve Data from Cache

```dart
Future<Map<String, dynamic>?> getCachedData(Session session) async {
  final data = await session.caches.local.get('my_cache_key');
  return data as Map<String, dynamic>?;
}
```

### Remove Data from Cache

```dart
Future<void> removeCachedData(Session session) async {
  await session.caches.local.invalidateKey('my_cache_key');
}
```

### Check if Key Exists

```dart
Future<bool> isCached(Session session) async {
  final data = await session.caches.local.get('my_cache_key');
  return data != null;
}
```

## Cache with TTL (Time To Live)

Set expiration time for cached data:

```dart
Future<void> cacheWithExpiration(Session session) async {
  await session.caches.local.put(
    'temporary_data',
    {'value': 'expires soon'},
    lifetime: Duration(minutes: 15),
  );
}
```

## Cache Patterns

### Cache-Aside (Lazy Loading)

Most common pattern - check cache first, load from database if miss:

```dart
Future<Recipe?> getRecipe(Session session, int id) async {
  final cacheKey = 'recipe_$id';

  // Try cache first
  final cached = await session.caches.local.get(cacheKey);
  if (cached != null) {
    return Recipe.fromJson(cached as Map<String, dynamic>);
  }

  // Cache miss - load from database
  final recipe = await Recipe.db.findById(session, id);
  if (recipe != null) {
    // Store in cache for future requests
    await session.caches.local.put(
      cacheKey,
      recipe.toJson(),
      lifetime: Duration(hours: 1),
    );
  }

  return recipe;
}
```

### Write-Through

Update cache when writing to database:

```dart
Future<Recipe> updateRecipe(Session session, Recipe recipe) async {
  // Update database
  await Recipe.db.updateRow(session, recipe);

  // Update cache immediately
  final cacheKey = 'recipe_${recipe.id}';
  await session.caches.local.put(
    cacheKey,
    recipe.toJson(),
    lifetime: Duration(hours: 1),
  );

  return recipe;
}
```

### Write-Behind (Write-Back)

Write to cache immediately, sync to database asynchronously:

```dart
Future<void> quickUpdate(Session session, int recipeId, String newText) async {
  final cacheKey = 'recipe_$recipeId';

  // Update cache immediately for fast response
  final cached = await session.caches.local.get(cacheKey);
  if (cached != null) {
    final data = cached as Map<String, dynamic>;
    data['text'] = newText;
    await session.caches.local.put(cacheKey, data);
  }

  // Schedule database update (background job)
  await session.messages.postMessage(
    'update_recipe',
    {'id': recipeId, 'text': newText},
  );
}
```

### Read-Through

Cache automatically loads from database on miss:

```dart
Future<Recipe?> getRecipeReadThrough(Session session, int id) async {
  final cacheKey = 'recipe_$id';

  return await session.caches.local.get(
    cacheKey,
    () async {
      // This function is called on cache miss
      final recipe = await Recipe.db.findById(session, id);
      return recipe?.toJson();
    },
    lifetime: Duration(hours: 1),
  );
}
```

## Cache Invalidation

### Invalidate Single Key

```dart
Future<void> invalidateRecipe(Session session, int id) async {
  await session.caches.local.invalidateKey('recipe_$id');
}
```

### Invalidate Multiple Keys by Pattern

```dart
Future<void> invalidateAllRecipes(Session session) async {
  // Invalidate all recipe cache entries
  await session.caches.local.invalidateGroup('recipes');
}
```

### Time-Based Expiration

```dart
Future<void> cacheWithShortLife(Session session) async {
  await session.caches.local.put(
    'real_time_data',
    {'timestamp': DateTime.now()},
    lifetime: Duration(seconds: 30),
  );
}
```

## Cache Groups

Organize related cache entries for batch operations:

```dart
Future<void> cacheUserData(Session session, int userId) async {
  final group = 'user_$userId';

  // Cache multiple related items in same group
  await session.caches.local.put(
    'profile_$userId',
    {'name': 'John'},
    group: group,
    lifetime: Duration(hours: 1),
  );

  await session.caches.local.put(
    'settings_$userId',
    {'theme': 'dark'},
    group: group,
    lifetime: Duration(hours: 1),
  );
}

Future<void> invalidateUserCache(Session session, int userId) async {
  // Invalidate all cache entries in the group
  await session.caches.local.invalidateGroup('user_$userId');
}
```

## Redis Configuration

### Setup Redis

Update `config/production.yaml`:

```yaml
redis:
  enabled: true
  host: redis.example.com
  port: 6379
```

Add Redis password to `config/passwords.yaml`:

```yaml
redis: your_redis_password
```

### Using Redis Cache

```dart
Future<void> useRedisCache(Session session) async {
  // Redis cache is automatically used when configured
  await session.caches.local.put(
    'distributed_key',
    {'data': 'shared across servers'},
    lifetime: Duration(hours: 1),
  );
}
```

## Cache Scopes

### Local Cache
Per-server cache (in-memory or Redis):

```dart
await session.caches.local.put('key', data);
```

### Global Cache
Shared across all servers (requires Redis):

```dart
await session.caches.global.put('key', data);
```

## Performance Optimization

### Cache Warming

Pre-load frequently accessed data:

```dart
Future<void> warmCache(Session session) async {
  // Load popular recipes into cache
  final popular = await Recipe.db.find(
    session,
    where: (t) => t.views.greaterThan(1000),
    limit: 100,
  );

  for (final recipe in popular) {
    await session.caches.local.put(
      'recipe_${recipe.id}',
      recipe.toJson(),
      lifetime: Duration(hours: 24),
    );
  }
}
```

### Cache Stampede Prevention

Prevent multiple simultaneous cache misses:

```dart
final _loadingKeys = <String, Future>{};

Future<Recipe?> getRecipeSafe(Session session, int id) async {
  final cacheKey = 'recipe_$id';

  // Check cache first
  final cached = await session.caches.local.get(cacheKey);
  if (cached != null) {
    return Recipe.fromJson(cached as Map<String, dynamic>);
  }

  // Check if already loading
  if (_loadingKeys.containsKey(cacheKey)) {
    return await _loadingKeys[cacheKey] as Recipe?;
  }

  // Start loading
  final future = _loadFromDatabase(session, id, cacheKey);
  _loadingKeys[cacheKey] = future;

  try {
    return await future;
  } finally {
    _loadingKeys.remove(cacheKey);
  }
}

Future<Recipe?> _loadFromDatabase(
  Session session,
  int id,
  String cacheKey,
) async {
  final recipe = await Recipe.db.findById(session, id);
  if (recipe != null) {
    await session.caches.local.put(
      cacheKey,
      recipe.toJson(),
      lifetime: Duration(hours: 1),
    );
  }
  return recipe;
}
```

## Best Practices

1. **Set appropriate TTL** - Balance freshness vs. performance
2. **Use cache groups** - Organize related data for easy invalidation
3. **Handle cache misses gracefully** - Always have fallback to database
4. **Invalidate on write** - Keep cache consistent with database
5. **Monitor cache hit rate** - Optimize based on actual usage
6. **Use Redis for production** - Distribute cache across servers
7. **Cache expensive operations** - Database queries, external API calls
8. **Avoid caching everything** - Cache only frequently accessed data
9. **Consider data size** - Large objects consume memory
10. **Plan cache keys carefully** - Use consistent naming conventions

## Common Patterns

### List Caching

```dart
Future<List<Recipe>> getRecentRecipes(Session session) async {
  const cacheKey = 'recent_recipes';

  final cached = await session.caches.local.get(cacheKey);
  if (cached != null) {
    return (cached as List)
        .map((json) => Recipe.fromJson(json))
        .toList();
  }

  final recipes = await Recipe.db.find(
    session,
    limit: 10,
    orderBy: (t) => t.date,
    orderDescending: true,
  );

  await session.caches.local.put(
    cacheKey,
    recipes.map((r) => r.toJson()).toList(),
    lifetime: Duration(minutes: 5),
  );

  return recipes;
}
```

### User-Specific Caching

```dart
Future<UserPreferences> getUserPreferences(Session session) async {
  final userId = session.userId!;
  final cacheKey = 'prefs_$userId';

  final cached = await session.caches.local.get(cacheKey);
  if (cached != null) {
    return UserPreferences.fromJson(cached as Map<String, dynamic>);
  }

  final prefs = await UserPreferences.db.findById(session, userId);
  if (prefs != null) {
    await session.caches.local.put(
      cacheKey,
      prefs.toJson(),
      lifetime: Duration(hours: 1),
    );
  }

  return prefs ?? UserPreferences.defaults();
}
```

### Computed Result Caching

```dart
Future<Statistics> getStatistics(Session session) async {
  const cacheKey = 'daily_statistics';

  final cached = await session.caches.local.get(cacheKey);
  if (cached != null) {
    return Statistics.fromJson(cached as Map<String, dynamic>);
  }

  // Expensive computation
  final stats = await _computeStatistics(session);

  await session.caches.local.put(
    cacheKey,
    stats.toJson(),
    lifetime: Duration(hours: 24),
  );

  return stats;
}
```

## Monitoring Cache Performance

```dart
Future<CacheStats> getCacheStats(Session session) async {
  // Track cache hits and misses
  final hits = await session.caches.local.get('cache_hits') ?? 0;
  final misses = await session.caches.local.get('cache_misses') ?? 0;

  return CacheStats(
    hits: hits as int,
    misses: misses as int,
    hitRate: hits / (hits + misses),
  );
}
```

## Cache Configuration

### In-Memory Cache Limits

Configure in `config/production.yaml`:

```yaml
cache:
  local:
    maxSize: 1000  # Maximum number of entries
    defaultLifetime: 3600  # Default TTL in seconds
```

### Redis Configuration Options

```yaml
redis:
  enabled: true
  host: redis.example.com
  port: 6379
  db: 0
  maxConnections: 10
  connectionTimeout: 5000  # milliseconds
```
