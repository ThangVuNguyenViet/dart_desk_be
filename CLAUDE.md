# Flutter CMS Backend - Serverpod Project

This is the backend server for the Flutter CMS project, built with **Serverpod 2.9.2**.

## Critical Instructions

**ALWAYS use the `serverpod` skill when working on this project.** This skill provides comprehensive Serverpod documentation and best practices for:
- Creating and modifying endpoints
- Working with database models (`.spy.yaml` files)
- Database queries and migrations
- Session management
- File storage and uploads
- Authentication (when implementing)
- Future calls and background tasks
- Serialization and protocol definitions

To activate the skill, use: `Skill: serverpod`

## Project Overview

This backend provides a flexible Content Management System (CMS) API that:
- Manages documents with dynamic JSON data structure
- Handles media file uploads (images and files)
- Provides pagination and search capabilities
- Stores data in PostgreSQL
- Serves uploaded files from storage

### Related Projects

- **UI Package**: `../flutter_cms` - The Flutter widget library that consumes this backend
- When UI-related questions arise, check the `../flutter_cms` package for context on how the frontend expects the API to behave

## Project Structure

```
flutter_cms_be/
├── flutter_cms_be_server/     # Main Serverpod server
│   ├── lib/
│   │   ├── src/
│   │   │   ├── endpoints/     # API endpoints
│   │   │   ├── models/        # .spy.yaml model definitions
│   │   │   ├── generated/     # Auto-generated code (DO NOT EDIT)
│   │   │   └── web/           # Web routes and static files
│   │   └── server.dart        # Server entry point
│   ├── migrations/            # Database migrations
│   ├── config/                # Environment configs
│   └── deploy/                # Deployment configs (AWS/GCP)
│
├── flutter_cms_be_client/     # Generated client library
└── flutter_cms_be_flutter/    # Flutter test app
```

## Key Components

### Endpoints

**DocumentEndpoint** (`lib/src/endpoints/document_endpoint.dart`)
- `getDocuments()` - List documents with pagination and search
- `getDocument()` - Get single document by ID
- `getDocumentByType()` - Get document by type and ID
- `createDocument()` - Create new document
- `updateDocument()` - Update existing document
- `deleteDocument()` - Delete document
- `getDocumentTypes()` - List all unique document types

**MediaEndpoint** (`lib/src/endpoints/media_endpoint.dart`)
- `uploadImage()` - Upload images (jpg, png, gif, webp)
- `uploadFile()` - Upload files (pdf, doc, txt, csv, xlsx)
- `deleteMedia()` - Delete media file
- `getMedia()` - Get media file metadata
- `listMedia()` - List media files with pagination

### Database Models

Models are defined in `lib/src/models/*.spy.yaml`:

- **CmsDocument** - Flexible document storage with JSON data field
- **CmsUser** - User management (for future authentication)
- **MediaFile** - Media file metadata and storage paths
- **DocumentListResponse** - Pagination response wrapper
- **UploadResponse** - File upload response

### Storage Configuration

- Files are stored using Serverpod's storage with `storageId: 'public'`
- Images stored in: `image/{timestamp}_{filename}`
- Files stored in: `file/{timestamp}_{filename}`
- Public files served via: `/files/*` route
- Max file size: 10MB

## Important Conventions

### When Modifying Models

1. Edit the `.spy.yaml` file in `lib/src/models/`
2. Run `serverpod generate` to regenerate code
3. Create migration: `serverpod create-migration`
4. Apply migration to database

### Authentication (TODO)

Current endpoints have commented-out authentication code:
```dart
// TODO: Add user authentication and get user ID from session
// final userId = await session.authenticated?.userId;
```

When implementing authentication:
- Uncomment user ID tracking in endpoints
- Set up authentication in `lib/server.dart`
- Configure authentication tables and models

### Future Calls

The server includes a birthday reminder future call example (`BirthdayReminder`):
- Demonstrates background task scheduling
- Can be used as template for scheduled tasks
- Registered in `lib/server.dart`

## Development Workflow

### Running the Server

```bash
cd flutter_cms_be_server
docker-compose up -d  # Start PostgreSQL
dart bin/main.dart    # Run server
```

### Regenerating Code

When you modify `.spy.yaml` files or add endpoints:
```bash
serverpod generate
```

### Database Migrations

Create and apply migrations after model changes:
```bash
serverpod create-migration
# Review migration files in migrations/
# Apply by restarting server or running migration commands
```

### Testing

- Integration tests in `test/integration/`
- Uses `serverpod_test` package
- Test tools available in `test/integration/test_tools/`

## Deployment

Configured for both AWS and GCP:
- **AWS**: CodeDeploy, EC2, RDS, Redis, CloudFront
- **GCP**: Cloud Run, Compute Engine
- See `deploy/` directory for Terraform and deployment scripts

### Terraform Secrets Setup

Terraform config is split into two files in `flutter_cms_be_server/deploy/aws/terraform/`:

- **`config.auto.tfvars`** — Committed. Contains non-secret infrastructure config (domain, region, instance type, bucket names).
- **`secrets.auto.tfvars`** — Gitignored. Contains database passwords.

To set up for the first time:
```bash
cd flutter_cms_be_server/deploy/aws/terraform
cp secrets.auto.tfvars.example secrets.auto.tfvars
# Edit secrets.auto.tfvars and fill in the database passwords
```

Both files are auto-loaded by Terraform. Never commit `secrets.auto.tfvars`.

**Note:** `terraform.tfstate` is local-only (no remote backend). Do not delete it — Terraform uses it to track managed AWS resources.

## Configuration Files

- `config/development.yaml` - Local development
- `config/production.yaml` - Production settings
- `config/staging.yaml` - Staging environment
- `config/test.yaml` - Testing configuration
- `config/generator.yaml` - Code generation settings

## Best Practices

1. **Always use the serverpod skill** for any Serverpod-specific work
2. **Never edit generated files** in `lib/src/generated/`
3. **Use sessions properly** - Session contains database, auth, and storage
4. **Follow model patterns** - Use `.spy.yaml` for all database models
5. **Handle errors gracefully** - Return appropriate error responses
6. **Validate input** - Check file types, sizes, and data formats
7. **Log appropriately** - Use `session.log()` for debugging
8. **Think about security** - Validate, sanitize, and authenticate

## Current Status

- ✅ Document CRUD operations
- ✅ Media upload/delete
- ✅ Pagination and search
- ✅ Database migrations
- ✅ File storage
- ⚠️ Authentication (not yet implemented)
- ⚠️ Authorization/permissions (planned)
- ⚠️ Rate limiting (planned)

## Related Documentation

- Serverpod docs: https://docs.serverpod.dev/
- Local skill files: `.claude/skills/serverpod/`
- Flutter CMS UI: `../flutter_cms/`

---

**Remember**: This project uses Serverpod framework extensively. Always activate and consult the `serverpod` skill when working on endpoints, models, database operations, or any Serverpod-specific functionality.