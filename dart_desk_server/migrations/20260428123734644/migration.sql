BEGIN;

-- Replace non-partial unique indexes with partial unique indexes that
-- only constrain live (non-soft-deleted) rows. Without WHERE deletedAt
-- IS NULL, soft-deleted rows would keep their slug/email occupied and
-- block recreating an entity with the same identifier. The non-unique
-- btree below each is what spy.yaml declares (Serverpod's expected
-- shape); the partial unique index is invisible to Serverpod tooling.
-- See CLAUDE.md "Schema drift" section for context.
--
-- ACTION ALTER TABLE clients
--
DROP INDEX "clients_slug_idx";
ALTER TABLE "clients" ADD COLUMN "deletedAt" timestamp without time zone;
CREATE INDEX "clients_slug_idx" ON "clients" USING btree ("slug");
CREATE UNIQUE INDEX "clients_slug_active_idx"
  ON "clients" USING btree ("slug")
  WHERE "deletedAt" IS NULL;
--
-- ACTION ALTER TABLE documents
--
DROP INDEX "documents_project_type_slug_idx";
CREATE INDEX "documents_project_type_slug_idx" ON "documents" USING btree ("projectId", "documentType", "slug");
CREATE UNIQUE INDEX "documents_project_type_slug_active_idx"
  ON "documents" USING btree ("projectId", "documentType", "slug")
  WHERE "deletedAt" IS NULL;
--
-- ACTION ALTER TABLE projects
--
DROP INDEX "projects_slug_idx";
CREATE INDEX "projects_slug_idx" ON "projects" USING btree ("slug");
CREATE UNIQUE INDEX "projects_slug_active_idx"
  ON "projects" USING btree ("slug")
  WHERE "deletedAt" IS NULL;
--
-- ACTION ALTER TABLE users
--
DROP INDEX "users_client_email_idx";
CREATE INDEX "users_client_email_idx" ON "users" USING btree ("clientId", "email");
CREATE UNIQUE INDEX "users_client_email_active_idx"
  ON "users" USING btree ("clientId", "email")
  WHERE "deletedAt" IS NULL;

--
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260428123734644', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260428123734644', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();


COMMIT;
