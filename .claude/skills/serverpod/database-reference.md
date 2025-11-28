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

## Relationships

Serverpod supports database relationships between models.

### One-to-Many

```yaml
class: User
table: users
fields:
  name: String
  posts: List<Post>?, relation(parent=user)
```

```yaml
class: Post
table: posts
fields:
  title: String
  userId: int, relation(parent=user)
```

### Many-to-Many

Use a join table for many-to-many relationships.

## Best Practices

1. **Always use migrations** - Never manually modify the database schema
2. **Use transactions** for multiple related operations
3. **Index frequently queried fields** for better performance
4. **Validate data** before inserting into database
5. **Use typed queries** to maintain type safety
6. **Handle null values** appropriately
7. **Close database connections** properly (Serverpod handles this automatically)
8. **Use batch operations** for multiple inserts/updates
9. **Optimize queries** with proper where clauses and limits
10. **Test migrations** in development before applying to production

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
