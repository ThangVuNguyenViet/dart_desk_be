# Tenant And Auth Refactor Design

## Summary

Refactor the backend from an implicit single-project tenant model into an explicit multi-tenant SaaS model similar to Sanity:

- `Client` is the real tenant.
- `Project` belongs to a `Client`.
- API keys belong to a `Project`.
- Runtime content belongs to a `Project`.
- Manage-app access is JWT-authenticated and client-scoped.
- Runtime access is API-key-authenticated and project-scoped.

This refactor is coupled with an upstream Serverpod migration:

- remove all `serverpod` fork `dependency_overrides`
- move onto upstream `3.4.0`
- stop using `x-api-key`
- stop using `preEndpointHandlers`
- use `authenticationHandler`
- accept the upstream limitation that dynamic map payloads cross RPC boundaries as JSON strings

## Goals

- Make tenancy explicit and support many projects per client.
- Keep runtime API keys scoped to exactly one project.
- Keep manage-app endpoints JWT-authenticated but exempt from API-key requirements.
- Remove custom request-context auth attachment and `ApiKeyContext`.
- Stay compatible with upstream Serverpod authentication and serialization behavior.

## Non-Goals

- No compatibility layer that preserves `clientId == project.id` as an intentional long-term model.
- No separate custom HTTP auth surface outside Serverpod endpoints.
- No attempt to preserve direct `Map<String, dynamic>` RPC transport if upstream does not support it.

## Current Problem

The current codebase mixes `projectId` and `clientId` as if they are the same tenant identifier:

- the manage app passes `project.id` into endpoint parameters named `clientId`
- runtime tables such as documents, media, and API tokens use `clientId`
- deployments already use `projectId`
- API key access is modeled as client access instead of project access

This ambiguity makes multi-project tenants hard to represent and bleeds into endpoint contracts, authorization checks, and tests.

## Target Domain Model

### Client

`Client` is the tenant.

Responsibilities:

- billing and plan ownership
- tenant-level membership
- tenant-level settings
- future tenant-wide usage and audit concerns

### Project

`Project` is a workspace under a client.

Responsibilities:

- owns runtime content and deployments
- owns project-scoped API keys
- is the unit selected in the manage app after authenticating as a tenant member

Each project belongs to exactly one client.

## Target Ownership Model

### Tenant-level entities

These should stay keyed by `clientId`:

- `Client`
- tenant membership records
- any future billing, plan, SSO, domain, or client-wide settings records

### Project-level entities

These should be keyed by `projectId`:

- `Project`
- `ApiToken`
- `Document`
- `MediaAsset`
- `Deployment`
- any other runtime content and runtime access records

### User table decision

The existing `User` table currently needs explicit interpretation during implementation.

If it represents tenant members for the manage app:

- keep it tenant-scoped with `clientId`

If it represents project-local content users:

- move it to `projectId`

Implementation must choose one meaning and remove the ambiguity rather than preserving both semantics in one table.

## Authentication Model

All requests use the standard `Authorization` header:

```text
Authorization: Bearer {authToken}:{apiKey}
```

Rules:

- `authToken` may be absent and represented as `null`
- `apiKey` may be absent and represented as `null`
- manage-app requests generally send a real auth token and no API key
- runtime requests can send `null:{apiKey}`
- mixed requests are allowed

Serverpod `authenticationHandler` becomes the single auth entry point.

### JWT path

If `authToken` is present and valid:

- authenticate with Serverpod auth
- preserve the user id
- preserve normal auth scopes

### API key path

If `apiKey` is present and valid:

- validate it by resolving the `ApiToken` row directly
- do not use `ApiKeyContext` or `requestContext`
- derive scopes from the token and its owning project

Scopes emitted from a valid project API key:

- `project:{projectId}`
- `project.read`
- `project.write` when the token role allows writes

Optional derived scope:

- `client:{clientId}` from `project.clientId`

### Combined auth result

If either path authenticates successfully:

- return one `AuthenticationInfo`
- merge scopes from both sources

If neither authenticates:

- return `null`

## Session Access Helpers

Remove `ApiKeyContext` completely.

Session helpers should be limited to derived auth state:

- `projectId`
- `clientId`
- `canRead`
- `canWrite`

These helpers must derive values from authentication scopes and standard auth state, not custom request context.

## Endpoint Access Policy

There are three access classes.

### Public endpoints

These require neither JWT nor API key:

- `emailIdp.*`
- `googleIdp.*`
- `project.createProjectWithOwner`
- `studioConfig.getStudioUrlTemplate`

### JWT-authenticated, API-key-exempt manage endpoints

These require a valid signed-in user session but must not require an API key:

- `project.getProjects`
- `project.updateProject`
- `project.deleteProject`
- `apiToken.*`
- `deployment.*`
- `user.getCurrentUser`
- `user.getUserCount`
- `document.getDocumentCount`

These endpoints are used by `../dart_desk_cloud/dart_desk_manage`.

### Project API-key-scoped runtime endpoints

Every other non-public endpoint should require API-key-derived project access:

- minimum requirement: `project.read`
- mutating runtime endpoints require `project.write`

Mutating includes:

- create
- update
- delete
- upload
- publish or unpublish
- compact or rebuild
- any other runtime state change

Ownership checks must compare row `projectId` with the scoped `project:{id}` from authentication.

## Endpoint Contract Refactor

Manage endpoints should take explicit identifiers that match their real scope:

- use `clientId` for tenant-level manage operations
- use `projectId` for project-level manage operations

Runtime endpoints should stop accepting `clientId` as a substitute for project selection.

Project selection for runtime endpoints should come from the API key scope.

### Concrete changes

- `apiToken.*` becomes project-scoped and uses `projectId`
- `document.getDocumentCount` becomes project-scoped and uses `projectId`
- document, media, public content, and collaboration endpoints use scoped `projectId`
- `user.getCurrentUser` should remain aligned with the manage flow and tenant membership model

Where the manage app currently passes `project.id` into parameters named `clientId`, those parameters should be renamed to `projectId` when the underlying operation is actually project-scoped.

## Upstream Serverpod Compatibility

### Remove fork overrides

Remove all custom `serverpod` `dependency_overrides` and use upstream `3.4.0`.

### Remove unsupported auth hooks

Remove:

- `x-api-key`
- `preEndpointHandlers`

Replace with:

- `authenticationHandler`
- standard `Authorization` header

### Accept dynamic map serialization limitations

Upstream Serverpod cannot reliably send or receive `Map<String, dynamic>` across these RPC boundaries in this project.

For dynamic payloads:

- accept JSON strings at the protocol boundary
- decode at endpoint entry
- encode at endpoint return

Examples:

- `String dataJson`
- `String updatesJson`
- `String fieldUpdatesJson`
- `String` or `List<String>` return values where the payload is otherwise a dynamic map

Typed protocol objects should remain typed.

## Schema Refactor

### Additions

- add `clientId` to `Project`

### Renames or ownership moves

- `ApiToken.clientId` -> `projectId`
- `Document.clientId` -> `projectId`
- `MediaAsset.clientId` -> `projectId`
- other runtime tables using implicit tenant ownership should move to `projectId`

`Deployment.projectId` already matches the target model and should stay as-is.

## Migration Strategy

This should be implemented as a real schema and contract refactor, not as a long-lived compatibility shim.

Steps:

1. Add `clientId` to `Project`.
2. Backfill every existing project with the correct owning client.
3. Convert project-scoped runtime tables from `clientId` to `projectId`.
4. Convert `ApiToken` from `clientId` to `projectId`.
5. Update endpoint contracts and generated protocol code.
6. Update auth to resolve `ApiToken` directly in `authenticationHandler`.
7. Remove `ApiKeyContext` and request-context-based auth attachment.
8. Update the manage app integration points to use explicit `projectId` where appropriate.

### Data migration note

Current data effectively assumes `project.id == tenant id`.

Migration must preserve existing behavior while breaking that assumption in schema and code:

- either create or associate a real client for each existing project
- then attach runtime rows to the correct project

The result after migration must no longer rely on interchangeable naming.

## Verification

Required verification includes:

- public endpoints still work without JWT or API key
- manage endpoints require JWT and do not require API key
- runtime endpoints reject missing API keys
- runtime read tokens cannot perform write actions
- runtime write tokens can perform write actions
- project isolation holds across two projects under one client
- JSON-string dynamic payloads round-trip correctly
- tests no longer depend on injected `ApiKeyContext`

## Risks

### User-table semantics

The biggest modeling risk is the current `User` table.

Implementation must decide whether it is:

- a tenant-member table, or
- a project-local application-user table

That decision affects endpoint signatures, membership checks, and migration shape.

### Generated-code churn

This refactor will change protocol bindings and generated endpoints significantly.

Implementation should expect broad generated diffs and verify contract changes carefully.

### Test assumptions

Existing tests likely assume:

- `clientId == project.id`
- injected API-key context
- direct access patterns that bypass new auth flow

These tests should be updated to reflect scoped authentication rather than patched around.

## Recommended Implementation Order

1. move to upstream Serverpod `3.4.0` and remove fork overrides
2. remove `ApiKeyContext` and implement `authenticationHandler`
3. refactor schema ownership to explicit `clientId` and `projectId`
4. regenerate protocol and endpoints
5. update endpoint authorization helpers and access checks
6. update tests and manage-app integration assumptions
7. verify cross-project isolation and read/write scope enforcement
