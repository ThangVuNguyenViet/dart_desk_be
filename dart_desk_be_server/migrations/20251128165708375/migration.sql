BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "cms_documents" ADD COLUMN "activeVersionData" text;
CREATE INDEX "cms_documents_active_data_idx" ON "cms_documents" USING btree ("activeVersionData");

--
-- MIGRATION VERSION FOR flutter_cms_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('flutter_cms_be', '20251128165708375', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251128165708375', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20240520102713718', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240520102713718', "timestamp" = now();


COMMIT;
