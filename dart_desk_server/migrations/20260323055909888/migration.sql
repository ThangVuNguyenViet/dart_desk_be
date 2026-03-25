BEGIN;

--
-- ACTION ALTER TABLE
--
DROP INDEX "api_token_tenant_idx";
DROP INDEX "api_token_lookup_idx";
ALTER TABLE "api_tokens" RENAME COLUMN "tenantId" TO "clientId";
CREATE INDEX "api_token_client_idx" ON "api_tokens" USING btree ("clientId");
CREATE UNIQUE INDEX "api_token_lookup_idx" ON "api_tokens" USING btree ("clientId", "tokenPrefix", "tokenSuffix");
--
-- ACTION ALTER TABLE
--
DROP INDEX "documents_tenant_type_idx";
DROP INDEX "documents_tenant_type_slug_idx";
ALTER TABLE "documents" RENAME COLUMN "tenantId" TO "clientId";
CREATE INDEX "documents_client_type_idx" ON "documents" USING btree ("clientId", "documentType");
CREATE UNIQUE INDEX "documents_client_type_slug_idx" ON "documents" USING btree ("clientId", "documentType", "slug");
--
-- ACTION ALTER TABLE
--
DROP INDEX "media_asset_tenant_id_idx";
ALTER TABLE "media_assets" RENAME COLUMN "tenantId" TO "clientId";
CREATE INDEX "media_asset_client_id_idx" ON "media_assets" USING btree ("clientId");
--
-- ACTION ALTER TABLE
--
DROP INDEX "users_tenant_email_idx";
DROP INDEX "users_external_id_idx";
DROP INDEX "users_tenant_id_idx";
ALTER TABLE "users" RENAME COLUMN "tenantId" TO "clientId";
CREATE UNIQUE INDEX "users_client_email_idx" ON "users" USING btree ("clientId", "email");
CREATE UNIQUE INDEX "users_external_id_idx" ON "users" USING btree ("externalId", "externalProvider", "clientId");
CREATE INDEX "users_client_id_idx" ON "users" USING btree ("clientId");

--
-- MIGRATION VERSION FOR dart_desk_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk_be', '20260323055909888', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260323055909888', "timestamp" = now();

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
