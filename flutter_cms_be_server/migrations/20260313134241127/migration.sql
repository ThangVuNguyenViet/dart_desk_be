BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cms_api_tokens" (
    "id" bigserial PRIMARY KEY,
    "clientId" bigint NOT NULL,
    "name" text NOT NULL,
    "tokenHash" text NOT NULL,
    "tokenPrefix" text NOT NULL,
    "tokenSuffix" text NOT NULL,
    "role" text NOT NULL,
    "createdByUserId" bigint,
    "lastUsedAt" timestamp without time zone,
    "expiresAt" timestamp without time zone,
    "isActive" boolean NOT NULL DEFAULT true,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "cms_api_token_client_idx" ON "cms_api_tokens" USING btree ("clientId");
CREATE UNIQUE INDEX "cms_api_token_lookup_idx" ON "cms_api_tokens" USING btree ("clientId", "tokenPrefix", "tokenSuffix");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "cms_api_tokens"
    ADD CONSTRAINT "cms_api_tokens_fk_0"
    FOREIGN KEY("clientId")
    REFERENCES "cms_clients"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cms_api_tokens"
    ADD CONSTRAINT "cms_api_tokens_fk_1"
    FOREIGN KEY("createdByUserId")
    REFERENCES "cms_users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR flutter_cms_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('flutter_cms_be', '20260313134241127', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260313134241127', "timestamp" = now();

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
