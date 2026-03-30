# Design: Replace `createProjectWithOwner` with `createClientWithOwner`

**Date:** 2026-03-31
**Status:** Approved

## Background

The previous model treated a `Project` as the top-level entity for first-time setup. `createProjectWithOwner` created a `CmsClient` + `Project` + admin `User` in one call and returned the `Project`.

Since the move to a model where one admin account (`CmsClient`) owns multiple `Project`s, the "owner creation" moment is registering the **CmsClient** (workspace/tenant), not a project. The current method name and return type are semantically wrong.

## Goal

- Replace `createProjectWithOwner` with `createClientWithOwner` that creates the tenant account and returns a `CmsClient`.
- Update the setup wizard to a two-step flow: workspace name first, project name second.
- Update all tests accordingly.

## Data Model (unchanged)

```
CmsClient  (one per admin account / workspace)
  └── Project  (many per CmsClient)
        └── ApiToken, User, etc.
```

## Changes

### 1. Backend — `ProjectEndpoint` (`dart_desk_be`)

**Add** `createClientWithOwner`:

```dart
Future<CmsClient> createClientWithOwner(Session session, {
  required String clientName,
  required String clientSlug,
})
```

- Requires authentication.
- Validates `clientSlug`: same format rules and reserved-word list as the current slug validation.
- Checks `CmsClient.slug` uniqueness — throws if slug already taken.
- Guards against duplicate client: throws if caller's `serverpodUserId` already maps to a `User` with a `clientId`.
- In a single DB transaction:
  - Inserts `CmsClient(name, slug, isActive: true)`
  - Inserts `User(clientId, email, role: 'admin', isActive: true, serverpodUserId)`
- Returns the inserted `CmsClient`.

**Delete** `createProjectWithOwner` from `ProjectEndpoint`.

The existing `createProject` endpoint is unchanged; it already resolves the caller's `clientId` via `resolveUser`.

### 2. Setup Wizard — `dart_desk_cloud`

`SetupWizardScreen` becomes a two-step stateful wizard (single screen, `_step` int field: 1 or 2).

**Step 1 — "Set up your workspace"**
- One text field: workspace name.
- Slug preview rendered below the field.
- Submit calls `createClientWithOwner(clientName, clientSlug)`.
- On success: stores the returned `CmsClient` in local state, advances `_step` to 2.
- On failure: shows inline error (slug taken, reserved word, duplicate client).

**Step 2 — "Create your first project"**
- One text field: project name.
- Slug preview rendered below the field.
- Submit calls existing `createProject(name, slug)`.
- On success: calls `appVM.userClients.reload()`, `appVM.initClientContext(project.slug)`, navigates to `ManageShellRoute`.
- On failure: shows inline error. The `CmsClient` already exists — user can retry project creation.

Back navigation between steps is not required.

### 3. Cloud test utilities — `test_app.dart`

- Add constant `testClientSlug` (e.g. `'e2e-test-workspace'`).
- Split `_ensureProjectExists` into:
  - `_ensureClientExists(appVM)` — calls `createClientWithOwner` if no `User` record yet.
  - `_ensureProjectExists(appVM)` — calls `createProject` if no projects yet.
- Call them in sequence from `pumpTestAppAuthenticated`.
- Update `_createProjectViaWizard` helper to drive the two-step wizard UI.

### 4. Backend tests — `dart_desk_be`

- Rename `project_endpoint_create_with_owner_test.dart` → `client_endpoint_create_with_owner_test.dart`.
- Rewrite tests to call `createClientWithOwner` and assert:
  - Returns a `CmsClient` with correct `name`, `slug`, `isActive: true`.
  - An admin `User` row exists linked to that `clientId`.
  - Email falls back to `userIdentifier` when profile is absent.
  - Throws when called a second time for the same `serverpodUserId` (duplicate client guard).
  - Throws on invalid slug / reserved slug / slug already taken.
- Remove all references to `createProjectWithOwner`.

## Out of Scope

- Changing the `CmsClient` model schema.
- Adding a dedicated `ClientEndpoint` (can be done later if the endpoint grows).
- Multi-step wizard with back navigation.
- Allowing an admin to belong to multiple `CmsClient`s.
