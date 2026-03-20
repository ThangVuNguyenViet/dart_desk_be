BEGIN;

--
-- ACTION ALTER TABLE
--
DROP INDEX "cms_documents_client_id_idx";
DROP INDEX "cms_documents_document_type_idx";
DROP INDEX "cms_documents_slug_idx";
DROP INDEX "cms_documents_is_default_idx";
DROP INDEX "cms_documents_data_idx";
DROP INDEX "cms_documents_crdt_node_idx";
DROP INDEX "cms_documents_updated_at_idx";
DROP INDEX "cms_documents_client_type_idx";
ALTER TABLE "cms_documents" ALTER COLUMN "slug" SET NOT NULL;
CREATE UNIQUE INDEX "cms_documents_client_type_slug_idx" ON "cms_documents" USING btree ("clientId", "documentType", "slug");
CREATE INDEX "cms_documents_client_type_idx" ON "cms_documents" USING btree ("clientId", "documentType");

--
-- MIGRATION VERSION FOR flutter_cms_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('flutter_cms_be', '20260317113106142', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260317113106142', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_admin
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_admin', '20251229043006674', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251229043006674', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
