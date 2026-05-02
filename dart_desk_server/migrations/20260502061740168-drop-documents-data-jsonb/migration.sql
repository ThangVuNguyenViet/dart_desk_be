BEGIN;

--
-- ACTION DROP INDEX
--
DROP INDEX IF EXISTS "documents_data_gin";

--
-- ACTION DROP COLUMN
--
ALTER TABLE "documents" DROP COLUMN IF EXISTS "data_jsonb";

--
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260502061740168-drop-documents-data-jsonb', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260502061740168-drop-documents-data-jsonb', "timestamp" = now();

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
