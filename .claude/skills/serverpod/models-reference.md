# Serverpod Models Reference

## Overview

Serverpod models are YAML-based definitions that generate serializable Dart classes for both server and client.

## File Formats

- `.yaml` - Standard YAML format
- `.spy.yaml` - Enables syntax highlighting with Serverpod VS Code extension

## Basic Structure

```yaml
class: Company
fields:
  name: String
  foundedDate: DateTime?
  employees: List<Employee>
```

## Database Models

Add the `table` keyword to persist models in the database:

```yaml
class: Company
table: companies
fields:
  name: String
  foundedDate: DateTime?
```

When a model has a `table`, Serverpod automatically adds an `id` field of type `int?`.

## Relations

### Foreign Key Syntax

Use `relation(parent=table_name)` to create foreign key relationships:

```yaml
class: Employee
table: employees
fields:
  name: String
  companyId: int, relation(parent=companies)
```

**IMPORTANT**: The `parent` value must be the **table name** (e.g., `companies`), NOT the class name (e.g., `Company`).

### One-to-One Relations

For one-to-one, add optional: true to ensure uniqueness:

```yaml
class: User
table: users
fields:
  name: String

class: Profile
table: profiles
fields:
  bio: String
  userId: int?, relation(parent=users, optional=true)
```

### One-to-Many Relations

The "many" side holds the foreign key:

```yaml
class: Company
table: companies
fields:
  name: String

class: Employee
table: employees
fields:
  name: String
  companyId: int, relation(parent=companies)
```

### Many-to-Many Relations

Use a junction/join table:

```yaml
class: Student
table: students
fields:
  name: String

class: Course
table: courses
fields:
  title: String

class: Enrollment
table: enrollments
fields:
  studentId: int, relation(parent=students)
  courseId: int, relation(parent=courses)
indexes:
  enrollment_unique_idx:
    fields: studentId, courseId
    unique: true
```

### Referential Actions

Control what happens when referenced rows are deleted or updated:

```yaml
fields:
  companyId: int, relation(parent=companies, onDelete=Cascade)
  managerId: int?, relation(parent=users, onDelete=SetNull)
```

**Available Actions:**

| Action | Description |
|--------|-------------|
| `NoAction` | Default. No action; may cause foreign key violation errors |
| `Restrict` | Prevents deletion of referenced row |
| `Cascade` | Deletes/updates dependent rows automatically |
| `SetNull` | Sets foreign key to NULL (field must be nullable) |
| `SetDefault` | Sets foreign key to default value |

**Common Patterns:**
- `onDelete=Cascade` - Child records deleted with parent (e.g., comments when post deleted)
- `onDelete=Restrict` - Prevent deletion if children exist (e.g., can't delete client with documents)
- `onDelete=SetNull` - Keep record but clear reference (e.g., keep document but clear deleted user)

### Object Relations (Eager Loading)

Add an object field to enable eager loading of related data:

```yaml
class: Employee
table: employees
fields:
  name: String
  companyId: int, relation(parent=companies)
  company: Company?, relation(name=company)
```

The `name` in the object relation must match a relation field name.

## Indexes

Add indexes to improve query performance:

```yaml
class: User
table: users
fields:
  email: String
  name: String
  createdAt: DateTime?, default=now
indexes:
  user_email_idx:
    fields: email
    unique: true
  user_name_idx:
    fields: name
  user_created_idx:
    fields: createdAt
```

### Index Options

```yaml
indexes:
  my_index:
    fields: field1, field2    # Comma-separated field list
    unique: true              # Enforce uniqueness (default: false)
    type: btree               # Index type: btree (default), hash, gin, gist, spgist, brin
```

### Composite Indexes

For queries filtering on multiple columns:

```yaml
indexes:
  client_type_idx:
    fields: clientId, documentType
```

## Key Elements

- **class**: Defines the serializable class name
- **fields**: Lists properties with their types
- **table**: Optional database table mapping
- **serverOnly**: Boolean flag restricting generation to server-side only

## Supported Types

### Core Dart Types
- `bool`, `int`, `double`, `String`
- `DateTime`, `Duration`, `ByteData`

### Specialized Types
- `UuidValue`, `Uri`, `BigInt`

### Collections
- `List<T>`, `Map<K,V>`, `Set<T>`

### Vector Types (for embeddings)
- `Vector(dimension)`
- `HalfVector(dimension)`
- `SparseVector(dimension)`
- `Bit(dimension)`

## Generated Code

Running `serverpod generate` automatically creates:

- **copyWith**: Efficient object copying with selective field updates
- **toJson/fromJson**: Automatic serialization
- **Custom methods**: Can be added using Dart extensions

## Field Visibility

### Default Behavior
Generated code appears on both client and server.

### Restrict to Server
```yaml
# Individual field
fields:
  secretKey: String
    scope: serverOnly

# Entire class
class: InternalData
serverOnly: true
fields:
  data: String
```

## Default Values

Three keywords control defaults:

- **default**: Applied to both model and database
- **defaultModel**: Code-side only
- **defaultPersist**: Database-side only

### Supported Defaults

```yaml
fields:
  isActive: bool?, default: true
  createdAt: DateTime?, default: now
  count: int?, default: 0
  status: String?, default: 'pending'
  id: UuidValue?, default: random  # or random_v7
  duration: Duration?, default: 1h30m
```

## Code Generation Command

```bash
cd server_directory
serverpod generate
```

This compiles YAML into Dart code for both server and client.

## Best Practices

1. Use `.spy.yaml` extension for better IDE support
2. Mark sensitive fields as `serverOnly`
3. Use nullable types with `?` for optional fields
4. Leverage default values for common patterns
5. Run `serverpod generate` after any model changes
6. Use vector types for AI/ML embeddings
