# dart_desk_be — Backend Notes

## ⚠️ Schema drift: documents.data_jsonb generated column

`document.spy.yaml` declares `data: String?` (a normal text column), but the
actual Postgres `documents` table has an additional generated column
`data_jsonb jsonb` derived from `data` via `GENERATED ALWAYS AS ((data)::jsonb)
STORED`. There is a GIN index `documents_data_gin` on `data_jsonb`.

**Why this layout**: We need GIN-indexed JSONB containment lookups (`@>`) for
`PublicContentEndpoint.getContentsByDataContains` (resolving deviceId →
deviceGroup). We can't change the `data` column to jsonb directly: the
Postgres driver decodes jsonb to `Map<String, dynamic>`, but the Serverpod
model expects `String?`, causing TypeError on every Document read. We can't
make the Serverpod model `Map<String, dynamic>?` either — Serverpod CLI
blacklists `dynamic` types, and forking is rejected because `dart_desk` is
published to pub.dev (consumers cannot inherit dependency_overrides).

**The drift, concretely**:
- Serverpod sees: `documents` table with `data text` (matches spy.yaml).
- Postgres reality: `documents` table has `data text` AND `data_jsonb jsonb`
  (generated, read-only, auto-maintained by Postgres on every insert/update
  to `data`), plus the GIN index.
- The drift is **additive**: Postgres has *more* than Serverpod knows about,
  not different. Serverpod's writes to `data` work normally; Postgres
  computes `data_jsonb` for free.

**At runtime**: zero impact on existing endpoints. All Document reads/writes
go through `data` (text) as Serverpod always has. `data_jsonb` is only
touched by hand-written `unsafeQuery` calls that need containment.

**JSONB-specific queries**: must use `unsafeQuery` with `data_jsonb @> ...`.
DO NOT reference `data_jsonb` from any spy.yaml-driven code path.

**When the drift can bite**:
- If `serverpod create-migration` ever emits a DROP/ALTER for `documents`
  (e.g., you change a different column), it won't know about `data_jsonb`
  or the GIN index — it'll regenerate the table definition without them.
  In practice Serverpod's migrations are diff-based, not redefinition-based,
  so this is unlikely. If it ever happens, hand-edit the migration to
  preserve `data_jsonb`.
- If you ever change the `data` field declaration in spy.yaml itself
  (rename, retype, drop), the generated column expression `(data)::jsonb`
  may break. Fix the migration manually at that point.
- The GIN index `documents_data_gin` is invisible to Serverpod tooling.

**Constraint on `data` content**: Because `data_jsonb = (data)::jsonb` is
GENERATED ALWAYS, every value written to `data` must be valid JSON or
Postgres will reject the insert/update. Serverpod's write path stores
JSON-encoded strings (per the existing `jsonEncode(map)` convention at
callsites), so this is consistent with current usage. Empty/non-JSON
values would need to be `'null'` (the four-character string), `'{}'`,
`'[]'`, or NULL.

**Do NOT** add `dependency_overrides` for Serverpod packages. Stay on stock
pub.dev `^3.4.5`. Forking was tried (commits `fcce25d`, `8c55074`,
`1e9c5ea`, `56997a4` in reflog) and rejected for various reasons (pub.dev
incompatibility, runtime serialization failure, driver type mismatch).

## ⚠️ Schema drift: `*_active_idx` partial unique indexes

Tables with soft-delete and a unique user-facing identifier carry a
hand-rolled **partial** unique index (`WHERE "deletedAt" IS NULL`) so
soft-deleted rows don't block recreation. Serverpod's index syntax has
no `where` clause, so the partial unique is invisible to Serverpod
tooling.

Indexes: `clients_slug_active_idx`,
`documents_project_type_slug_active_idx`, `projects_slug_active_idx`,
`users_client_email_active_idx`.

If `serverpod create-migration` ever needs to alter these tables,
hand-edit the migration to preserve the `*_active_idx`. If you add a
new table with the same shape, add a matching partial unique index via
hand-edited migration.
