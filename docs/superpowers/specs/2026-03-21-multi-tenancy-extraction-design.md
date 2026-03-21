# Multi-Tenancy Extraction to Cloud Plugin

**Date:** 2026-03-21
**Status:** Draft
**Depends on:** None (Spec 1 of 2, must be done before External Auth Strategy)

## Goal

Extract multi-tenancy from the core Dart Desk backend into an optional cloud plugin. Core becomes single-tenant by default, matching how Payload CMS, Rails (acts_as_tenant), Laravel (stancl/tenancy), and Django (django-multitenant) treat tenancy as opt-in.

Self-hosted users get a clean single-tenant experience. Multi-tenancy is a cloud-only concern.

## Design

### Model Renames

All models drop the `Cms` prefix for cleaner naming (following Firebase/Supabase convention — plain names, import aliases for disambiguation):

**Core models (`dart_desk_be_server`):**

| Current | New | Table | Has tenantId? |
|---------|-----|-------|---------------|
| `CmsUser` | `User` | `users` | Yes (`tenantId: int?`) |
| `CmsDocument` | `Document` | `documents` | Yes (`tenantId: int?`) |
| `DocumentVersion` | `DocumentVersion` | `document_versions` | No (scoped via parent `Document`) |
| `DocumentCrdtOperation` | `DocumentCrdtOperation` | `document_crdt_operations` | No (scoped via parent `Document`) |
| `DocumentCrdtSnapshot` | `DocumentCrdtSnapshot` | `document_crdt_snapshots` | No (scoped via parent `Document`) |
| `CmsDocumentData` | `DocumentData` | `documents_data` | No (generic data storage, no FK) |
| `CmsApiToken` | `ApiToken` | `api_tokens` | Yes (`tenantId: int?`) |
| `MediaAsset` | `MediaAsset` | `media_assets` | Yes (`tenantId: int?`) |

**Cloud plugin models (`dart_desk_cloud`):**

| Current | New | Table |
|---------|-----|-------|
| `CmsClient` | `Tenant` | `tenants` |
| `CmsDeployment` | `Deployment` | `deployments` |

**Response DTOs (rename only, no tenantId — they wrap core models):**

| Current | New |
|---------|-----|
| `CmsClientList` | `TenantList` (cloud plugin) |
| `DocumentList` | `DocumentList` (unchanged) |
| `DocumentVersionList` | `DocumentVersionList` (unchanged) |
| `DocumentVersionWithOperations` | `DocumentVersionWithOperations` (unchanged) |
| `DocumentVersionListWithOperations` | `DocumentVersionListWithOperations` (unchanged) |
| `ClientWithToken` | `TenantWithToken` (cloud plugin) |
| `CmsApiTokenWithValue` | `ApiTokenWithValue` |

**Enums (unchanged):** `DeploymentStatus`, `DocumentVersionStatus`, `CrdtOperationType`, `MediaAssetMetadataStatus`

### tenantId Strategy

Models that directly reference `CmsClient.clientId` today get `tenantId: int?` (nullable):
- `User`, `Document`, `ApiToken`, `MediaAsset`

Child models that scope through a parent FK do **not** get `tenantId`:
- `DocumentVersion` → scoped via `documentId` FK to `Document`
- `DocumentCrdtOperation` → scoped via `documentId` FK to `Document`
- `DocumentCrdtSnapshot` → scoped via `documentId` FK to `Document`

**Single-tenant mode:** `tenantId` is always null.
**Multi-tenant mode:** `tenantId` is set on every record; cloud plugin adds FK constraint.

### Core Model Examples

```yaml
# document.spy.yaml
class: Document
table: documents
fields:
  tenantId: int?
  documentType: String
  title: String
  slug: String
  isDefault: bool, default=false
  data: String?
  crdtNodeId: String?
  crdtHlc: String?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now
  createdByUserId: int?, relation(parent=users, onDelete=SetNull)
  updatedByUserId: int?, relation(parent=users, onDelete=SetNull)
indexes:
  documents_tenant_type_idx:
    fields: tenantId, documentType
  documents_tenant_type_slug_idx:
    fields: tenantId, documentType, slug
    unique: true
  documents_type_default_idx:
    fields: documentType, isDefault
  documents_created_at_idx:
    fields: createdAt
```

```yaml
# user.spy.yaml
class: User
table: users
fields:
  tenantId: int?
  email: String
  name: String?
  role: String, default='viewer'
  isActive: bool, default=true
  serverpodUserId: String?
  createdAt: DateTime?, default=now
  updatedAt: DateTime?, default=now
indexes:
  users_tenant_email_idx:
    fields: tenantId, email
    unique: true
  users_tenant_id_idx:
    fields: tenantId
  users_serverpod_user_id_idx:
    fields: serverpodUserId
  users_is_active_idx:
    fields: isActive
```

**Note:** `createdByUserId` changed from `int` to `int?` to fix contradiction with `onDelete=SetNull` (cannot set a non-nullable column to null).

### PostgreSQL NULL Handling in Unique Indexes

PostgreSQL treats `NULL != NULL` in unique indexes, meaning `(NULL, 'blog', 'hello')` and `(NULL, 'blog', 'hello')` would NOT violate uniqueness. In single-tenant mode (all `tenantId = NULL`), this breaks slug uniqueness.

**Solution:** Use `COALESCE` expression indexes in the migration:

```sql
CREATE UNIQUE INDEX documents_tenant_type_slug_idx
  ON documents (COALESCE(tenant_id, 0), document_type, slug);

CREATE UNIQUE INDEX users_tenant_email_idx
  ON users (COALESCE(tenant_id, 0), email);
```

This ensures uniqueness works correctly when `tenantId` is null. The YAML model defines the logical index; the migration SQL uses `COALESCE`.

### Tenant Resolution (Callback-Based)

Instead of mixin-on-mixin inheritance (which creates compile-time coupling), use a globally registered callback:

```dart
/// Resolves tenant ID from the current request. Returns null for single-tenant.
typedef TenantResolver = Future<int?> Function(Session session);

/// Global tenant resolution configuration
class DartDeskTenancy {
  static TenantResolver _resolver = (_) async => null; // default: single-tenant

  static void configure({required TenantResolver resolver}) {
    _resolver = resolver;
  }

  static Future<int?> resolveTenantId(Session session) => _resolver(session);
}
```

**Endpoints use it directly:**

```dart
class DocumentEndpoint extends Endpoint {
  Future<List<Document>> getDocuments(Session session, ...) async {
    final user = await _requireUser(session);
    final tenantId = await DartDeskTenancy.resolveTenantId(session);
    return Document.db.find(session,
      where: (t) =>
        (tenantId != null ? t.tenantId.equals(tenantId) : t.tenantId.isNull()) &
        t.documentType.equals(type),
    );
  }
}
```

**Single-tenant (default):** `DartDeskTenancy` returns null. No configuration needed.

**Multi-tenant (cloud plugin configures it):**

```dart
// In cloud plugin registration
DartDeskTenancy.configure(
  resolver: (session) async {
    final slug = session.httpRequest.headers['x-tenant-slug']?.first;
    if (slug == null) return null;
    final tenant = await Tenant.db.findFirstRow(session,
      where: (t) => t.slug.equals(slug) & t.isActive.equals(true));
    return tenant?.id;
  },
);
```

### Admin Seeding (Single-Tenant)

Current `_seedAdminUser()` creates a Serverpod auth user but not a `CmsUser`. The `ensureUser` endpoint creates `CmsUser` on first login with `clientSlug` + `apiToken`.

**After refactor:** `_seedAdminUser()` creates both:
1. Serverpod auth user (email IDP, existing behavior)
2. `User` record with `tenantId: null`, `role: 'admin'`, linked via `serverpodUserId`

No more `ensureUser` with `clientSlug`/`apiToken` — single-tenant users don't have these concepts. The `ensureUser` logic simplifies to: look up or create `User` by `serverpodUserId`.

### Package Structure

```
dart_desk_be/
├── dart_desk_be_server/       # Core (single-tenant)
│   ├── lib/src/
│   │   ├── endpoints/         # Single-tenant endpoints
│   │   ├── models/            # Core models (tenantId: int?)
│   │   └── tenancy.dart       # DartDeskTenancy + TenantResolver
│   └── migrations/
├── dart_desk_be_client/       # Generated client
└── dart_desk_cloud/           # Cloud plugin (new)
    ├── lib/src/
    │   ├── models/
    │   │   ├── tenant.spy.yaml
    │   │   └── deployment.spy.yaml
    │   ├── endpoints/          # Tenant CRUD, deployment management
    │   ├── cloud_tenant_resolver.dart
    │   └── dart_desk_cloud.dart  # DartDeskCloud.register()
    └── pubspec.yaml
```

### Cloud Plugin Registration

```dart
// Single-tenant (self-hosted) — nothing extra needed
final pod = Serverpod(args, Protocol(), Endpoints());
pod.initializeAuthServices(...);
// DartDeskTenancy defaults to single-tenant (returns null)

// Multi-tenant (cloud) — register the plugin
final pod = Serverpod(args, Protocol(), Endpoints());
pod.initializeAuthServices(...);
DartDeskCloud.register(pod); // Configures DartDeskTenancy with cloud resolver
```

### Database Migration

Breaking migration (acceptable per project status):

**Table renames:**
- `cms_clients` → `tenants` (managed by `dart_desk_cloud`)
- `cms_users` → `users`
- `cms_documents` → `documents`
- `cms_api_tokens` → `api_tokens`
- `cms_deployments` → `deployments` (managed by `dart_desk_cloud`)
- `media_assets` → `media_assets` (unchanged)
- `document_versions` → `document_versions` (unchanged)
- `document_crdt_operations` → `document_crdt_operations` (unchanged)
- `document_crdt_snapshots` → `document_crdt_snapshots` (unchanged)
- `cms_documents_data` → `documents_data`

**Column changes:**
- `client_id` → `tenant_id` (all tables that have it)
- `tenant_id` altered to nullable in core tables
- `created_by_user_id` altered to nullable where it was non-nullable (fixes SetNull contradiction)

**Index changes:**
- Updated to use new column/table names
- Unique indexes on nullable `tenantId` use `COALESCE(tenant_id, 0)` expression

### What Moves Where

**Core (`dart_desk_be_server`):**
- Models: `Document`, `DocumentVersion`, `DocumentCrdtOperation`, `DocumentCrdtSnapshot`, `DocumentData`, `User`, `ApiToken`, `MediaAsset`
- DTOs: `DocumentList`, `DocumentVersionList`, `DocumentVersionWithOperations`, `DocumentVersionListWithOperations`, `ApiTokenWithValue`
- Endpoints: `DocumentEndpoint`, `DocumentCollaborationEndpoint`, `UserEndpoint`, `ApiTokenEndpoint`, `MediaEndpoint`, `StudioConfigEndpoint`
- Auth endpoints: `EmailIdpEndpoint`, `GoogleIdpEndpoint`, `RefreshJwtTokensEndpoint`
- Tenancy: `DartDeskTenancy`, `TenantResolver` typedef

**Cloud plugin (`dart_desk_cloud`):**
- Models: `Tenant`, `Deployment`
- DTOs: `TenantList`, `TenantWithToken`
- Endpoints: Tenant CRUD, deployment management
- `CloudTenantResolver` implementation
- Admin seeding with tenant creation
- Migration: FK constraint `tenantId` → `tenants.id`

## Out of Scope

- External auth strategy system (Spec 2)
- Client-side `DartDeskApp` refactor (Spec 2)
- Data migration tooling for existing cloud deployments
- Schema-based or database-per-tenant isolation (row-level with nullable `tenantId` only)
