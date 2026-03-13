BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "cms_clients" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cms_clients" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "secret" text NOT NULL,
    "description" text,
    "isActive" boolean NOT NULL DEFAULT true,
    "settings" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "cms_clients_slug_idx" ON "cms_clients" USING btree ("slug");
CREATE INDEX "cms_clients_is_active_idx" ON "cms_clients" USING btree ("isActive");


--
-- MIGRATION VERSION FOR flutter_cms_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('flutter_cms_be', '20260313082143188', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260313082143188', "timestamp" = now();

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
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
