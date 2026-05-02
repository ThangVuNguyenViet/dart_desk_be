BEGIN;

--
-- ACTION ALTER TABLE
--
-- Drop the old GIN index on the jsonb data column before dropping the column.
DROP INDEX IF EXISTS "published_docs_data_gin";
ALTER TABLE "published_documents" DROP COLUMN "data";
ALTER TABLE "published_documents" ADD COLUMN "data" text;
-- Add generated jsonb column for GIN-indexed containment lookups (@>).
-- Same pattern as documents.data_jsonb (see CLAUDE.md).
ALTER TABLE "published_documents"
  ADD COLUMN "data_jsonb" jsonb
  GENERATED ALWAYS AS ((data)::jsonb) STORED;
CREATE INDEX "published_docs_data_gin"
  ON "published_documents" USING GIN ("data_jsonb");

--
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260502055440875', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260502055440875', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260416151914983-insights-perf', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260416151914983-insights-perf', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260417182253191', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182253191', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260417182309198', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182309198', "timestamp" = now();


COMMIT;
