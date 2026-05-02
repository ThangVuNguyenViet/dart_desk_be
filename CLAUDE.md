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
