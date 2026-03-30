BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "api_tokens" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "api_tokens" (
    "id" bigserial PRIMARY KEY,
    "projectId" bigint NOT NULL,
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
CREATE INDEX "api_token_project_idx" ON "api_tokens" USING btree ("projectId");
CREATE UNIQUE INDEX "api_token_lookup_idx" ON "api_tokens" USING btree ("projectId", "tokenPrefix", "tokenSuffix");
CREATE INDEX "api_token_prefix_suffix_idx" ON "api_tokens" USING btree ("tokenPrefix", "tokenSuffix");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "clients" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "description" text,
    "isActive" boolean NOT NULL DEFAULT true,
    "settings" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "clients_slug_idx" ON "clients" USING btree ("slug");
CREATE INDEX "clients_is_active_idx" ON "clients" USING btree ("isActive");

--
-- ACTION DROP TABLE
--
DROP TABLE "documents" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "documents" (
    "id" bigserial PRIMARY KEY,
    "projectId" bigint NOT NULL,
    "documentType" text NOT NULL,
    "title" text NOT NULL,
    "slug" text NOT NULL,
    "isDefault" boolean NOT NULL DEFAULT false,
    "data" text,
    "crdtNodeId" text,
    "crdtHlc" text,
    "publishedAt" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint,
    "updatedByUserId" bigint
);

-- Indexes
CREATE INDEX "documents_project_type_idx" ON "documents" USING btree ("projectId", "documentType");
CREATE UNIQUE INDEX "documents_project_type_slug_idx" ON "documents" USING btree ("projectId", "documentType", "slug");
CREATE INDEX "documents_type_default_idx" ON "documents" USING btree ("documentType", "isDefault");
CREATE INDEX "documents_created_at_idx" ON "documents" USING btree ("createdAt");
CREATE INDEX "documents_project_published_idx" ON "documents" USING btree ("projectId", "publishedAt");

--
-- ACTION DROP TABLE
--
DROP TABLE "media_assets" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "media_assets" (
    "id" bigserial PRIMARY KEY,
    "projectId" bigint NOT NULL,
    "assetId" text NOT NULL,
    "fileName" text NOT NULL,
    "mimeType" text NOT NULL,
    "fileSize" bigint NOT NULL,
    "storagePath" text NOT NULL,
    "publicUrl" text NOT NULL,
    "width" bigint NOT NULL,
    "height" bigint NOT NULL,
    "hasAlpha" boolean NOT NULL,
    "blurHash" text NOT NULL,
    "lqip" text,
    "paletteJson" text,
    "exifJson" text,
    "locationLat" double precision,
    "locationLng" double precision,
    "uploadedByUserId" bigint,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "metadataStatus" text NOT NULL
);

-- Indexes
CREATE INDEX "media_asset_project_id_idx" ON "media_assets" USING btree ("projectId");
CREATE UNIQUE INDEX "media_asset_asset_id_idx" ON "media_assets" USING btree ("assetId");
CREATE INDEX "media_asset_file_name_idx" ON "media_assets" USING btree ("fileName");
CREATE INDEX "media_asset_mime_type_idx" ON "media_assets" USING btree ("mimeType");

--
-- ACTION DROP TABLE
--
DROP TABLE "projects" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "projects" (
    "id" bigserial PRIMARY KEY,
    "clientId" bigint NOT NULL,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "description" text,
    "isActive" boolean NOT NULL DEFAULT true,
    "settings" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "projects_client_idx" ON "projects" USING btree ("clientId");
CREATE UNIQUE INDEX "projects_slug_idx" ON "projects" USING btree ("slug");
CREATE INDEX "projects_is_active_idx" ON "projects" USING btree ("isActive");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "api_tokens"
    ADD CONSTRAINT "api_tokens_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "projects"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "api_tokens"
    ADD CONSTRAINT "api_tokens_fk_1"
    FOREIGN KEY("createdByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "documents"
    ADD CONSTRAINT "documents_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "projects"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "documents"
    ADD CONSTRAINT "documents_fk_1"
    FOREIGN KEY("createdByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "documents"
    ADD CONSTRAINT "documents_fk_2"
    FOREIGN KEY("updatedByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "media_assets"
    ADD CONSTRAINT "media_assets_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "projects"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "projects"
    ADD CONSTRAINT "projects_fk_0"
    FOREIGN KEY("clientId")
    REFERENCES "clients"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260330035609443', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260330035609443', "timestamp" = now();

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
