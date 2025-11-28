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
