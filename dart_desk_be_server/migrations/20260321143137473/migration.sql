BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "cms_users" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "cms_documents_data" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "document_versions" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "document_crdt_snapshots" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "document_crdt_operations" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "cms_documents" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "cms_deployments" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "cms_clients" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "cms_api_tokens" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "api_tokens" (
    "id" bigserial PRIMARY KEY,
    "tenantId" bigint,
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
CREATE INDEX "api_token_tenant_idx" ON "api_tokens" USING btree ("tenantId");
CREATE UNIQUE INDEX "api_token_lookup_idx" ON "api_tokens" USING btree ("tenantId", "tokenPrefix", "tokenSuffix");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "document_crdt_operations" (
    "id" bigserial PRIMARY KEY,
    "documentId" bigint NOT NULL,
    "hlc" text NOT NULL,
    "nodeId" text NOT NULL,
    "operationType" text NOT NULL,
    "fieldPath" text NOT NULL,
    "fieldValue" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint
);

-- Indexes
CREATE INDEX "document_crdt_operations_document_hlc_idx" ON "document_crdt_operations" USING btree ("documentId", "hlc");
CREATE INDEX "document_crdt_operations_document_id_idx" ON "document_crdt_operations" USING btree ("documentId");
CREATE INDEX "document_crdt_operations_created_at_idx" ON "document_crdt_operations" USING btree ("createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "document_crdt_snapshots" (
    "id" bigserial PRIMARY KEY,
    "documentId" bigint NOT NULL,
    "snapshotHlc" text NOT NULL,
    "snapshotData" text NOT NULL,
    "operationCountAtSnapshot" bigint NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "document_crdt_snapshots_document_hlc_idx" ON "document_crdt_snapshots" USING btree ("documentId", "snapshotHlc");
CREATE INDEX "document_crdt_snapshots_document_id_idx" ON "document_crdt_snapshots" USING btree ("documentId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "document_versions" (
    "id" bigserial PRIMARY KEY,
    "documentId" bigint NOT NULL,
    "versionNumber" bigint NOT NULL,
    "status" text NOT NULL,
    "snapshotHlc" text,
    "operationCount" bigint NOT NULL DEFAULT 0,
    "changeLog" text,
    "publishedAt" timestamp without time zone,
    "scheduledAt" timestamp without time zone,
    "archivedAt" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint
);

-- Indexes
CREATE INDEX "document_versions_document_id_idx" ON "document_versions" USING btree ("documentId");
CREATE UNIQUE INDEX "document_versions_document_version_idx" ON "document_versions" USING btree ("documentId", "versionNumber");
CREATE INDEX "document_versions_snapshot_hlc_idx" ON "document_versions" USING btree ("documentId", "snapshotHlc");
CREATE INDEX "document_versions_status_idx" ON "document_versions" USING btree ("status");
CREATE INDEX "document_versions_published_at_idx" ON "document_versions" USING btree ("publishedAt");
CREATE INDEX "document_versions_scheduled_at_idx" ON "document_versions" USING btree ("scheduledAt");
CREATE INDEX "document_versions_created_at_idx" ON "document_versions" USING btree ("createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "documents" (
    "id" bigserial PRIMARY KEY,
    "tenantId" bigint,
    "documentType" text NOT NULL,
    "title" text NOT NULL,
    "slug" text NOT NULL,
    "isDefault" boolean NOT NULL DEFAULT false,
    "data" text,
    "crdtNodeId" text,
    "crdtHlc" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint,
    "updatedByUserId" bigint
);

-- Indexes
CREATE INDEX "documents_tenant_type_idx" ON "documents" USING btree ("tenantId", "documentType");
CREATE UNIQUE INDEX "documents_tenant_type_slug_idx" ON "documents" USING btree ("tenantId", "documentType", "slug");
CREATE INDEX "documents_type_default_idx" ON "documents" USING btree ("documentType", "isDefault");
CREATE INDEX "documents_created_at_idx" ON "documents" USING btree ("createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "documents_data" (
    "id" bigserial PRIMARY KEY,
    "documentType" text NOT NULL,
    "data" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint,
    "updatedByUserId" bigint
);

-- Indexes
CREATE INDEX "documents_data_document_type_idx" ON "documents_data" USING btree ("documentType");
CREATE INDEX "documents_data_created_at_idx" ON "documents_data" USING btree ("createdAt");
CREATE INDEX "documents_data_updated_at_idx" ON "documents_data" USING btree ("updatedAt");

--
-- ACTION ALTER TABLE
--
DROP INDEX "media_asset_client_id_idx";
ALTER TABLE "media_assets" DROP COLUMN "clientId";
ALTER TABLE "media_assets" ADD COLUMN "tenantId" bigint;
CREATE INDEX "media_asset_tenant_id_idx" ON "media_assets" USING btree ("tenantId");
--
-- ACTION CREATE TABLE
--
CREATE TABLE "users" (
    "id" bigserial PRIMARY KEY,
    "tenantId" bigint,
    "email" text NOT NULL,
    "name" text,
    "role" text NOT NULL DEFAULT 'viewer'::text,
    "isActive" boolean NOT NULL DEFAULT true,
    "serverpodUserId" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "users_tenant_email_idx" ON "users" USING btree ("tenantId", "email");
CREATE INDEX "users_tenant_id_idx" ON "users" USING btree ("tenantId");
CREATE INDEX "users_serverpod_user_id_idx" ON "users" USING btree ("serverpodUserId");
CREATE INDEX "users_is_active_idx" ON "users" USING btree ("isActive");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "api_tokens"
    ADD CONSTRAINT "api_tokens_fk_0"
    FOREIGN KEY("createdByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "document_crdt_operations"
    ADD CONSTRAINT "document_crdt_operations_fk_0"
    FOREIGN KEY("documentId")
    REFERENCES "documents"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "document_crdt_operations"
    ADD CONSTRAINT "document_crdt_operations_fk_1"
    FOREIGN KEY("createdByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "document_crdt_snapshots"
    ADD CONSTRAINT "document_crdt_snapshots_fk_0"
    FOREIGN KEY("documentId")
    REFERENCES "documents"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "document_versions"
    ADD CONSTRAINT "document_versions_fk_0"
    FOREIGN KEY("documentId")
    REFERENCES "documents"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "document_versions"
    ADD CONSTRAINT "document_versions_fk_1"
    FOREIGN KEY("createdByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "documents"
    ADD CONSTRAINT "documents_fk_0"
    FOREIGN KEY("createdByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "documents"
    ADD CONSTRAINT "documents_fk_1"
    FOREIGN KEY("updatedByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR dart_desk_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk_be', '20260321143137473', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260321143137473', "timestamp" = now();

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
