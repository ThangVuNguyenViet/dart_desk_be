# Serverpod Database Reference

## Overview

Serverpod provides a built-in Object-Relational Mapping (ORM) system with PostgreSQL support, allowing you to write Dart code instead of SQL queries. The system includes automatic migrations to keep schema changes versioned and synchronized.

## Making Models Persistent

To make a model persistent in the database, add the `table` keyword to your model definition:

```yaml
class: Recipe
table: recipes
fields:
  author: String
  text: String
  date: DateTime
  ingredients: String
```

## Database Migrations

Database migrations manage schema evolution safely and provide a history of changes.

### Creating Migrations

**Two-step process:**

1. **Generate Code**:
```bash
serverpod generate
```

2. **Create Migration**:
```bash
serverpod create-migration
```

Each migration creates SQL queries that update your database schema. These step-by-step migrations provide a history of your database changes and allow you to roll back changes if needed.

### Applying Migrations

Start your database (if not running):
```bash
docker compose up -d
```

Apply migrations:
```bash
dart bin/main.dart --apply-migrations
```

## Writing Data (Create)

Once a model includes a `table` keyword, it becomes a `TableRow` type with database access.

### Insert Single Row

```dart
final recipe = Recipe(
  author: 'Gemini',
  text: responseText,
  date: DateTime.now(),
  ingredients: ingredients,
);

final recipeWithId = await Recipe.db.insertRow(session, recipe);
```

### Insert Multiple Rows

```dart
final recipes = [recipe1, recipe2, recipe3];
await Recipe.db.insert(session, recipes);
```

## Reading Data (Query)

Query data using the `find` method with various options.

### Basic Query

```dart
// Get all recipes
final recipes = await Recipe.db.find(session);
```

### Ordered Query

```dart
// Get all recipes sorted by date (descending)
final recipes = await Recipe.db.find(
  session,
  orderBy: (t) => t.date,
  orderDescending: true,
);
```

### Filtered Query

```dart
// Find recipes by specific author
final recipes = await Recipe.db.find(
  session,
  where: (t) => t.author.equals('John'),
);
```

### Limited Query

```dart
// Get first 10 recipes
final recipes = await Recipe.db.find(
  session,
  limit: 10,
);
```

### Find by ID

```dart
// Get specific recipe by ID
final recipe = await Recipe.db.findById(session, recipeId);
```

## Updating Data

```dart
// Fetch existing recipe
final recipe = await Recipe.db.findById(session, recipeId);

if (recipe != null) {
  // Update fields
  recipe.text = 'Updated recipe text';
  recipe.date = DateTime.now();

  // Save changes
  await Recipe.db.updateRow(session, recipe);
}
```

### Update Multiple Rows

```dart
await Recipe.db.update(session, [recipe1, recipe2, recipe3]);
```

## Deleting Data

### Delete Single Row

```dart
await Recipe.db.deleteRow(session, recipe);
```

### Delete by ID

```dart
await Recipe.db.deleteById(session, recipeId);
```

### Delete Multiple Rows

```dart
await Recipe.db.delete(session, [recipe1, recipe2, recipe3]);
```

### Delete with Where Clause

```dart
await Recipe.db.deleteWhere(
  session,
  where: (t) => t.date.isBefore(DateTime(2024, 1, 1)),
);
```

## TableRow Type

When a model includes the `table` keyword, it becomes a `TableRow` with these properties:

- **id**: Auto-generated unique identifier (int)
- **db**: Static field for database operations
- Database methods: `insertRow`, `updateRow`, `deleteRow`, etc.

## Query Operators

### Comparison Operators

```dart
where: (t) => t.age.equals(25)
where: (t) => t.age.notEquals(25)
where: (t) => t.age.greaterThan(18)
where: (t) => t.age.greaterOrEqualTo(18)
where: (t) => t.age.lessThan(65)
where: (t) => t.age.lessOrEqualTo(65)
where: (t) => t.age.between(18, 65)
```

### String Operators

```dart
where: (t) => t.name.like('%John%')
where: (t) => t.email.startsWith('user@')
where: (t) => t.email.endsWith('.com')
```

### Logical Operators

```dart
// AND
where: (t) => t.age.greaterThan(18) & t.status.equals('active')

// OR
where: (t) => t.role.equals('admin') | t.role.equals('moderator')

// NOT
where: (t) => !t.isDeleted
```

### Date/Time Operators

```dart
where: (t) => t.date.isBefore(DateTime.now())
where: (t) => t.date.isAfter(DateTime(2024, 1, 1))
```

## Relationships & Eager Loading

Serverpod supports database relationships between models. See [Models Reference](./models-reference.md) for relation syntax details.

### Querying with Relations (Include)

Use the `include` parameter to eager load related objects:

```dart
// Fetch employee with their company
final employee = await Employee.db.findById(
  session,
  employeeId,
  include: Employee.include(
    company: Company.include(),
  ),
);

// Access related data
print(employee?.company?.name);
```

### Nested Includes

Load multiple levels of relations:

```dart
final employee = await Employee.db.findById(
  session,
  employeeId,
  include: Employee.include(
    company: Company.include(
      ceo: User.include(),
    ),
  ),
);
```

### Include with Find (Multiple Records)

```dart
final employees = await Employee.db.find(
  session,
  where: (t) => t.companyId.equals(companyId),
  include: Employee.include(
    company: Company.include(),
  ),
);
```

## Transactions

Use transactions for atomic operations:

```dart
await session.db.transaction((transaction) async {
  // All operations in this block are atomic
  final company = await Company.db.insertRow(
    session,
    Company(name: 'Acme Inc'),
    transaction: transaction,
  );

  await Employee.db.insertRow(
    session,
    Employee(name: 'John', companyId: company.id!),
    transaction: transaction,
  );
});
```

If any operation fails, all changes are rolled back.

## Pagination

Combine `limit` and `offset` for pagination:

```dart
Future<List<Document>> getDocuments({
  required int page,
  int pageSize = 20,
}) async {
  return await Document.db.find(
    session,
    limit: pageSize,
    offset: page * pageSize,
    orderBy: (t) => t.createdAt,
    orderDescending: true,
  );
}
```

## Counting Records

```dart
final count = await Document.db.count(
  session,
  where: (t) => t.clientId.equals(clientId),
);
```

## Raw SQL Queries

For complex queries not supported by the ORM, Serverpod provides multiple methods for raw SQL access.

### Query Methods

**1. `unsafeQuery` - Execute SELECT queries with results**

Uses extended query protocol with parameter binding (secure):

```dart
// Named parameters (@ prefix)
final results = await session.db.unsafeQuery(
  r'SELECT * FROM documents WHERE client_id = @clientId AND status = @status',
  parameters: QueryParameters.named({'clientId': clientId, 'status': status}),
);

// Positional parameters ($1, $2) - Recommended for most cases
final results = await session.db.unsafeQuery(
  r'SELECT * FROM documents WHERE client_id = $1 AND status = $2',
  parameters: QueryParameters.positional([clientId, status]),
);

// No parameters
final results = await session.db.unsafeQuery(
  'SELECT DISTINCT document_type FROM documents ORDER BY document_type',
);
```

**2. `unsafeExecute` - Execute INSERT/UPDATE/DELETE**

Returns the number of affected rows:

```dart
final rowsAffected = await session.db.unsafeExecute(
  r'DELETE FROM old_records WHERE created_at < $1',
  parameters: QueryParameters.positional([cutoffDate]),
);

session.log('Deleted $rowsAffected rows');
```

**3. `unsafeSimpleQuery` - Simple protocol (multi-statement)**

Uses simple query protocol without parameter binding. Use only when needed for:
- Multiple statements in one query
- Proxy environments like PGBouncer
- Compatibility requirements

```dart
final results = await session.db.unsafeSimpleQuery(
  'SELECT * FROM table1; SELECT * FROM table2;'
);
```

**⚠️ Warning**: Cannot use parameter binding - manually sanitize input!

**4. `unsafeSimpleExecute` - Simple protocol execute**

Similar to `unsafeSimpleQuery` but for non-SELECT statements:

```dart
await session.db.unsafeSimpleExecute(
  'CREATE INDEX idx_name ON table(column)'
);
```

### Parameter Binding

**Named Parameters** (Use @ prefix):

```dart
final results = await session.db.unsafeQuery(
  r'SELECT * FROM users WHERE age > @minAge AND city = @city',
  parameters: QueryParameters.named({
    'minAge': 18,
    'city': 'Stockholm',
  }),
);
```

**Positional Parameters** (Use $1, $2 - Recommended):

```dart
final results = await session.db.unsafeQuery(
  r'SELECT * FROM users WHERE age > $1 AND city = $2',
  parameters: QueryParameters.positional([18, 'Stockholm']),
);
```

### Working with Results

```dart
final results = await session.db.unsafeQuery(
  r'SELECT id, name, email FROM users WHERE active = $1',
  parameters: QueryParameters.positional([true]),
);

// Iterate over rows
for (var row in results) {
  final id = row[0] as int;
  final name = row[1] as String;
  final email = row[2] as String?;

  // Or use toColumnMap
  final map = row.toColumnMap();
  final userId = map['id'];
  final userName = map['name'];
}

// Map to custom objects
final users = results.map((row) {
  return User(
    id: row[0] as int,
    name: row[1] as String,
    email: row[2] as String?,
  );
}).toList();

// Convert to protocol objects
final entities = results.map((row) {
  return MyEntity.fromJson(row.toColumnMap());
}).toList();
```

### Security Best Practices

**✅ DO: Use Parameter Binding**

```dart
// Safe - parameters are properly escaped
await session.db.unsafeQuery(
  r'SELECT * FROM users WHERE username = $1',
  parameters: QueryParameters.positional([userInput]),
);
```

**❌ DON'T: Concatenate User Input**

```dart
// DANGEROUS - SQL injection vulnerability!
await session.db.unsafeQuery(
  'SELECT * FROM users WHERE username = \'$userInput\'',
);
```

**Always Sanitize**: Even with "safe" methods, validate and sanitize user input before database operations.

### When to Use Raw SQL

Use raw SQL queries when:
- Complex joins not well-supported by ORM
- Aggregations and window functions
- PostgreSQL-specific features (full-text search, JSON operations)
- Performance-critical queries needing optimization
- Database administration tasks

**Prefer ORM when possible** for:
- Simple CRUD operations
- Standard queries with where/orderBy
- Type safety and code maintainability
- Automatic serialization

### Example: Complex Query with CRDT

```dart
// Get CRDT operations since a timestamp with HLC comparison
final operations = await session.db.unsafeQuery(
  r'''
  SELECT o.*, u.username
  FROM document_crdt_operations o
  LEFT JOIN users u ON o.created_by_user_id = u.id
  WHERE o.document_id = $1
    AND o.hlc > $2
  ORDER BY o.hlc ASC
  LIMIT $3
  ''',
  parameters: QueryParameters.positional([documentId, sinceHlc, limit]),
);

// Convert to protocol objects
final ops = operations.map((row) {
  return DocumentCrdtOperation.fromJson(row.toColumnMap());
}).toList();
```

## Database Indexing

Indexes improve query performance by allowing faster data retrieval. Define indexes in your `.spy.yaml` model files.

### Basic Index Definition

```yaml
class: User
table: users
fields:
  email: String
  username: String
  age: int
indexes:
  users_email_idx:
    fields: email
  users_username_idx:
    fields: username
```

### Composite (Multi-field) Indexes

Combine multiple fields into a single index for queries that filter on multiple columns:

```yaml
indexes:
  users_age_city_idx:
    fields: age, city
```

**Index order matters**: Place the most selective field first for optimal performance.

### Unique Indexes

Enforce uniqueness constraints at the database level:

```yaml
indexes:
  users_email_unique_idx:
    fields: email
    unique: true
  users_username_unique_idx:
    fields: username
    unique: true
```

**Composite unique indexes** ensure the combination of fields is unique:

```yaml
indexes:
  documents_client_type_idx:
    fields: clientId, documentType
    unique: true  # Each client can only have one document of each type
```

### Index Types

PostgreSQL supports various index algorithms:

```yaml
indexes:
  # B-tree (default) - Best for general purpose, equality and range queries
  users_age_idx:
    fields: age
    type: btree

  # Hash - Only for equality comparisons
  users_status_idx:
    fields: status
    type: hash

  # BRIN - Block Range Index, for very large tables with natural ordering
  logs_timestamp_idx:
    fields: timestamp
    type: brin

  # GIN - Generalized Inverted Index, for full-text search and JSON
  documents_tags_idx:
    fields: tags
    type: gin

  # GiST - Generalized Search Tree, for geometric and full-text data
  locations_coords_idx:
    fields: coordinates
    type: gist
```

### Vector Indexes (pgvector)

For AI/ML vector similarity search:

```yaml
indexes:
  # HNSW - Fast approximate nearest neighbor search
  embeddings_vector_idx:
    fields: embedding
    type: hnsw
    distanceFunction: cosine
    m: 16  # Max connections per layer
    ef_construction: 64  # Size of candidate list

  # IVFFLAT - For large datasets
  embeddings_large_idx:
    fields: embedding
    type: ivfflat
    distanceFunction: l2
    lists: 100  # Number of clusters
```

**Distance functions**: `l2`, `innerProduct`, `cosine`, `l1`, `hamming`, `jaccard`

**Limitations**:
- Vector indexes require single field only
- SparseVector only supports HNSW
- HalfVector has L1 limitations with IVFFLAT
- Bit types only support hamming/jaccard

### Index Naming Conventions

**Recommended pattern**: `{table}_{fields}_{type}_idx`

```yaml
indexes:
  users_email_idx:          # Single field
  users_age_city_idx:       # Composite
  users_email_unique_idx:   # Unique constraint
  logs_timestamp_brin_idx:  # Specific type
```

### When to Add Indexes

**DO index**:
- Fields used in WHERE clauses frequently
- Foreign key columns
- Fields used in JOIN conditions
- Fields used in ORDER BY
- Composite keys for common multi-field queries
- Unique constraints for data integrity

**DON'T over-index**:
- Small tables (< 1000 rows)
- Rarely queried fields
- Fields with low cardinality (few distinct values)
- Every column "just in case"

**Trade-offs**:
- ✅ Faster SELECT queries
- ❌ Slower INSERT/UPDATE/DELETE operations
- ❌ Increased storage space

### Index Examples

**E-commerce product search**:
```yaml
class: Product
table: products
fields:
  category: String
  price: double
  inStock: bool
  createdAt: DateTime
indexes:
  products_category_idx:
    fields: category
  products_price_idx:
    fields: price
  products_category_price_idx:
    fields: category, price  # For category browsing sorted by price
  products_created_at_idx:
    fields: createdAt
  products_in_stock_idx:
    fields: inStock
```

**Multi-tenant application**:
```yaml
class: Document
table: documents
fields:
  clientId: int
  documentType: String
  title: String
  createdAt: DateTime
indexes:
  documents_client_idx:
    fields: clientId
  documents_client_type_idx:
    fields: clientId, documentType
    unique: true  # One document per type per client
  documents_client_created_idx:
    fields: clientId, createdAt  # Pagination within client
```

**Full-text search**:
```yaml
class: Article
table: articles
fields:
  title: String
  content: String
  tags: String  # JSON array
indexes:
  articles_content_idx:
    fields: content
    type: gin  # For full-text search
  articles_tags_idx:
    fields: tags
    type: gin  # For JSON array searches
```

### Monitoring Index Usage

Check which indexes are actually being used:

```sql
-- Find unused indexes
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan as index_scans
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexname NOT LIKE '%pkey%'
ORDER BY tablename;

-- Find most used indexes
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan as scans,
  idx_tup_read as tuples_read,
  idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
ORDER BY idx_scan DESC;
```

## Best Practices

1. **Always use migrations** - Never manually modify the database schema
2. **Use transactions** for multiple related operations
3. **Index frequently queried fields** for better performance
4. **Don't over-index** - Each index has overhead for writes
5. **Use composite indexes** for common multi-field queries
6. **Add unique constraints** via unique indexes for data integrity
7. **Monitor index usage** - Remove unused indexes
8. **Validate data** before inserting into database
9. **Use typed queries** to maintain type safety
10. **Handle null values** appropriately
11. **Close database connections** properly (Serverpod handles this automatically)
12. **Use batch operations** for multiple inserts/updates
13. **Optimize queries** with proper where clauses and limits
14. **Test migrations** in development before applying to production

## Configuration

Database connection is configured in:
- `config/development.yaml` - Local development
- `config/production.yaml` - Production deployment
- `config/passwords.yaml` - Database credentials (keep secure!)

## Health & Monitoring

Monitor database health through:
- Serverpod Insights (port 8081)
- Application logs
- PostgreSQL monitoring tools

## Advanced Features

For advanced database operations, refer to the official Serverpod ORM documentation covering:
- Transactions
- Joins
- Indexes
- Full-text search
- JSON fields
- Custom SQL queries
