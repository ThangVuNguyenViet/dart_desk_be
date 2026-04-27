## 0.2.0

> **Breaking**: Primary keys migrated from `int` to `UuidValue` across all models and endpoints. Consumers must update any code that handled IDs as integers (e.g. cached IDs, route params, filter args).

### Features
- `ClientEndpoint.getClientsForUser` and `ClientWithRole` model
- `MemberEndpoint` and `ProjectMemberEndpoint` with full CRUD
- `ClientRole` and `ProjectRole` enums; `ProjectMember` model
- Restore endpoints for documents, projects, and users
- Soft delete + audit fields (`createdAt`, `updatedAt`, `deletedAt`) on models
- Typed paginated response models (replaces old list models)
- Health check endpoint
- `PublicContentEndpoint.getContentsByDataContains` for JSONB containment lookups (e.g. deviceId → deviceGroup)
- Single-pass server-side image upload with metadata extraction

### Breaking
- `User.role` migrated to `ClientRole` enum
- Old list response models removed in favor of typed paginated equivalents
- Auth layer uses `UuidValue` for client/project IDs

## 0.1.1

- feat: add ApiException for client-visible errors
- feat: add CompoundTokenParser support
- feat: add MigrationHistory model and migration endpoint types
- fix: api token parser
- chore: add melos workspace

## 0.1.0

- Initial release
- Typed client SDK for documents, media, collaboration, and versioning endpoints
- Pure Dart package (no Flutter dependency)
