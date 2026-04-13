BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "api_tokens" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "api_tokens" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "projectId" uuid NOT NULL,
    "name" text NOT NULL,
    "tokenHash" text NOT NULL,
    "tokenPrefix" text NOT NULL,
    "tokenSuffix" text NOT NULL,
    "role" text NOT NULL,
    "createdByUserId" uuid,
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
-- ACTION DROP TABLE
--
DROP TABLE "clients" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "clients" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
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
DROP TABLE "deployments" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "deployments" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "projectId" uuid NOT NULL,
    "version" bigint NOT NULL,
    "status" text NOT NULL,
    "filePath" text NOT NULL,
    "fileSize" bigint,
    "uploadedByUserId" uuid,
    "commitHash" text,
    "metadata" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "deployment_project_idx" ON "deployments" USING btree ("projectId");
CREATE UNIQUE INDEX "deployment_project_version_idx" ON "deployments" USING btree ("projectId", "version");
CREATE INDEX "deployment_project_status_idx" ON "deployments" USING btree ("projectId", "status");

--
-- ACTION DROP TABLE
--
DROP TABLE "document_crdt_operations" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "document_crdt_operations" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "documentId" uuid NOT NULL,
    "hlc" text NOT NULL,
    "nodeId" text NOT NULL,
    "operationType" text NOT NULL,
    "fieldPath" text NOT NULL,
    "fieldValue" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" uuid
);

-- Indexes
CREATE INDEX "document_crdt_operations_document_hlc_idx" ON "document_crdt_operations" USING btree ("documentId", "hlc");
CREATE INDEX "document_crdt_operations_document_id_idx" ON "document_crdt_operations" USING btree ("documentId");
CREATE INDEX "document_crdt_operations_created_at_idx" ON "document_crdt_operations" USING btree ("createdAt");

--
-- ACTION DROP TABLE
--
DROP TABLE "document_crdt_snapshots" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "document_crdt_snapshots" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "documentId" uuid NOT NULL,
    "snapshotHlc" text NOT NULL,
    "snapshotData" text NOT NULL,
    "operationCountAtSnapshot" bigint NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "document_crdt_snapshots_document_hlc_idx" ON "document_crdt_snapshots" USING btree ("documentId", "snapshotHlc");
CREATE INDEX "document_crdt_snapshots_document_id_idx" ON "document_crdt_snapshots" USING btree ("documentId");

--
-- ACTION DROP TABLE
--
DROP TABLE "document_versions" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "document_versions" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "documentId" uuid NOT NULL,
    "versionNumber" bigint NOT NULL,
    "status" text NOT NULL,
    "snapshotHlc" text,
    "operationCount" bigint NOT NULL DEFAULT 0,
    "changeLog" text,
    "publishedAt" timestamp without time zone,
    "scheduledAt" timestamp without time zone,
    "archivedAt" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" uuid
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
-- ACTION DROP TABLE
--
DROP TABLE "documents" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "documents" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "projectId" uuid NOT NULL,
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
    "createdByUserId" uuid,
    "updatedByUserId" uuid
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
DROP TABLE "documents_data" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "documents_data" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "documentType" text NOT NULL,
    "data" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" uuid,
    "updatedByUserId" uuid
);

-- Indexes
CREATE INDEX "documents_data_document_type_idx" ON "documents_data" USING btree ("documentType");
CREATE INDEX "documents_data_created_at_idx" ON "documents_data" USING btree ("createdAt");
CREATE INDEX "documents_data_updated_at_idx" ON "documents_data" USING btree ("updatedAt");

--
-- ACTION DROP TABLE
--
DROP TABLE "media_assets" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "media_assets" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "projectId" uuid NOT NULL,
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
    "uploadedByUserId" uuid,
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
DROP TABLE "migration_history" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "migration_history" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "projectId" uuid NOT NULL,
    "name" text NOT NULL,
    "documentType" text NOT NULL,
    "appliedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "operationsJson" text NOT NULL,
    "report" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "migration_history_project_name_idx" ON "migration_history" USING btree ("projectId", "name");

--
-- ACTION DROP TABLE
--
DROP TABLE "project_members" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "project_members" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "userId" uuid NOT NULL,
    "projectId" uuid NOT NULL,
    "role" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "project_member_unique" ON "project_members" USING btree ("userId", "projectId");
CREATE INDEX "project_member_project_idx" ON "project_members" USING btree ("projectId");

--
-- ACTION DROP TABLE
--
DROP TABLE "projects" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "projects" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "clientId" uuid NOT NULL,
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
-- ACTION DROP TABLE
--
DROP TABLE "users" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "users" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "clientId" uuid,
    "email" text NOT NULL,
    "name" text,
    "role" text NOT NULL DEFAULT 'viewer'::text,
    "isActive" boolean NOT NULL DEFAULT true,
    "serverpodUserId" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "users_client_email_idx" ON "users" USING btree ("clientId", "email");
CREATE INDEX "users_client_id_idx" ON "users" USING btree ("clientId");
CREATE INDEX "users_serverpod_user_id_idx" ON "users" USING btree ("serverpodUserId");
CREATE INDEX "users_is_active_idx" ON "users" USING btree ("isActive");

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
ALTER TABLE ONLY "deployments"
    ADD CONSTRAINT "deployments_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "projects"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "deployments"
    ADD CONSTRAINT "deployments_fk_1"
    FOREIGN KEY("uploadedByUserId")
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
ALTER TABLE ONLY "migration_history"
    ADD CONSTRAINT "migration_history_fk_0"
    FOREIGN KEY("projectId")
    REFERENCES "projects"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "project_members"
    ADD CONSTRAINT "project_members_fk_0"
    FOREIGN KEY("userId")
    REFERENCES "users"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "project_members"
    ADD CONSTRAINT "project_members_fk_1"
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
    VALUES ('dart_desk', '20260413185839788', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260413185839788', "timestamp" = now();

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
