# dart_desk_be — Backend Notes

## ⚠️ Schema drift: published_documents.data_jsonb generated column

`published_document.spy.yaml` declares `data: String?` (a normal text column),
but the actual Postgres `published_documents` table has an additional generated
column `data_jsonb jsonb` derived from `data` via
`GENERATED ALWAYS AS ((data)::jsonb) STORED`. There is a GIN index
`published_docs_data_gin` on `data_jsonb`.

**Why this layout**: We need GIN-indexed JSONB containment lookups (`@>`) for
`PublicContentEndpoint.getContentsByDataContains`. We can't change the `data`
column to jsonb directly: the Postgres driver decodes jsonb to
`Map<String, dynamic>`, but the Serverpod model expects `String?`, causing
TypeError on every PublishedDocument read.

**JSONB-specific queries**: must use `unsafeQuery` with `data_jsonb @> ...`
targeting `published_documents`. DO NOT reference `data_jsonb` from any
spy.yaml-driven code path.

**When the drift can bite**:
- If `serverpod create-migration` ever emits a DROP/ALTER for
  `published_documents`, it won't know about `data_jsonb` or the GIN index.
  Hand-edit the migration to preserve them.
- The GIN index `published_docs_data_gin` is invisible to Serverpod tooling.

**Do NOT** add `dependency_overrides` for Serverpod packages. Stay on stock
pub.dev `^3.5.0-beta.5` or later.

## ⚠️ Schema drift: `*_active_idx` partial unique indexes

Tables with soft-delete and a unique user-facing identifier carry a
hand-rolled **partial** unique index (`WHERE "deletedAt" IS NULL`) so
soft-deleted rows don't block recreation. Serverpod's index syntax has
no `where` clause, so the partial unique is invisible to Serverpod
tooling.

Indexes: `clients_slug_active_idx`,
`documents_project_type_slug_active_idx`,
`published_docs_project_type_slug_active_idx`,
`projects_slug_active_idx`, `users_client_email_active_idx`.

If `serverpod create-migration` ever needs to alter these tables,
hand-edit the migration to preserve the `*_active_idx`. If you add a
new table with the same shape, add a matching partial unique index via
hand-edited migration.

## ⚠️ Reverse schema drift: prod may be missing objects that local definition.sql has

Hand-edited migrations can reference constraints or indexes that were **never
created** in prod (because an earlier hand-edited migration omitted them).
Serverpod-generated `RENAME CONSTRAINT` / `DROP CONSTRAINT` will fail at
runtime if the target constraint doesn't exist, rolling back the whole
`BEGIN/COMMIT` block. With `applyMigrations: true` Serverpod logs the failure
but keeps serving — so the binary runs against a partially-migrated schema.

**Rule**: before merging any migration that uses `RENAME CONSTRAINT`,
`DROP CONSTRAINT`, `ALTER INDEX … RENAME`, or `DROP INDEX` on an existing
object, verify that object actually exists in prod. Wrap the operation in an
idempotent guard:

```sql
DO $$ BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'old_name' AND conrelid = 'table'::regclass) THEN
    ALTER TABLE "table" RENAME CONSTRAINT "old_name" TO "new_name";
  END IF;
END $$;
```

**Known instance**: `api_tokens_fk_0` (the `projectId → projects` FK on
`api_tokens`) was never created in prod. The rename migration assumed it
existed and failed. A repair migration
(`20260503094803605-repair-api-keys-fk`) adds back `api_keys_fk_0`
idempotently. Note: the prod PK is still named `api_tokens_pkey` (harmless —
Postgres enforces it correctly regardless of name).

## ⚠️ `definition.sql` also drifts — required for CI

`serverpod_test`'s `withServerpod(applyMigrations: true)` bootstraps a fresh
test DB from the **latest migration's `definition.sql`** (declarative schema),
not by running `migration.sql` files in sequence. This means hand-edited SQL
that lives only in `migration.sql` is invisible to CI.

After running `serverpod create-migration`, re-apply these to the new
migration's `definition.sql`:
- `published_documents.data_jsonb` generated column + `published_docs_data_gin` GIN index.
- The five `*_active_idx` partial unique indexes
  (`clients_slug_active_idx`, `documents_project_type_slug_active_idx`,
  `published_docs_project_type_slug_active_idx`,
  `projects_slug_active_idx`, `users_client_email_active_idx`).

## ⚠️ Serverpod maintenance-role migrations exit 0 on failure (in production/staging)

`dart bin/main.dill --role maintenance --apply-migrations` is the right tool
for a blocking pre-start migration step (it's a documented Serverpod role).
But Serverpod 3.5.0-beta.5 only converts a migration failure into a non-zero
exit when `runMode == development`:

```dart
// serverpod-3.5.0-beta.5/lib/src/server/serverpod.dart:_applyMigrations
} catch (e, stackTrace) {
  verified = false;
  _reportException(e, stackTrace, message: 'Failed to apply database migrations.');
}
if (!verified) {
  if (config.runMode == ServerpodRunMode.development) {
    throw ExitException(1);   // production/staging fall through silently
  }
}
```

In `production`/`staging` the failure is logged (`ERROR: Failed to apply
migration <name>.` / `ERROR: Failed to apply database migrations.`) but
the process exits 0, so any deploy gate that trusts the exit code lets the
new binary start against a half-migrated schema.

**Workaround in `dart_desk_cloud/deploy/aws/scripts/run_migrations`**: after
running maintenance role, grep `migrations.log` for those error markers and
exit 1 if found. See cloud PR #21 (2026-05-08).

**Real-world impact**: 2026-05-08 outage — the `api_keys_fk_0` repair
migration failed against orphan rows, Serverpod logged + exited 0, the new
binary started without `add-invites` applied, and `inviteMember` returned
500. Fixed by deleting orphans, re-running maintenance migrations manually,
restarting serverpod.

If a future Serverpod upgrade fixes this upstream (the lenient behavior is
intended for `dart run bin/main.dart` during dev, not for maintenance-role
deploys), the grep guard becomes redundant but harmless.
