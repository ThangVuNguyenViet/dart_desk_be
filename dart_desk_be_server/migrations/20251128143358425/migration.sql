BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cms_client_users" (
    "id" bigserial PRIMARY KEY,
    "clientId" bigint NOT NULL,
    "cmsUserId" bigint NOT NULL,
    "role" text NOT NULL,
    "isActive" boolean NOT NULL DEFAULT true,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "cms_client_users_client_user_idx" ON "cms_client_users" USING btree ("clientId", "cmsUserId");
CREATE INDEX "cms_client_users_client_id_idx" ON "cms_client_users" USING btree ("clientId");
CREATE INDEX "cms_client_users_cms_user_id_idx" ON "cms_client_users" USING btree ("cmsUserId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cms_clients" (
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
CREATE UNIQUE INDEX "cms_clients_slug_idx" ON "cms_clients" USING btree ("slug");
CREATE INDEX "cms_clients_is_active_idx" ON "cms_clients" USING btree ("isActive");

--
-- ACTION DROP TABLE
--
DROP TABLE "cms_users" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cms_users" (
    "id" bigserial PRIMARY KEY,
    "clientId" bigint NOT NULL,
    "email" text NOT NULL,
    "name" text,
    "role" text NOT NULL DEFAULT 'viewer'::text,
    "isActive" boolean NOT NULL DEFAULT true,
    "serverpodUserId" bigint,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "cms_users_client_email_idx" ON "cms_users" USING btree ("clientId", "email");
CREATE INDEX "cms_users_client_id_idx" ON "cms_users" USING btree ("clientId");
CREATE INDEX "cms_users_serverpod_user_id_idx" ON "cms_users" USING btree ("serverpodUserId");
CREATE INDEX "cms_users_is_active_idx" ON "cms_users" USING btree ("isActive");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "document_versions" (
    "id" bigserial PRIMARY KEY,
    "documentId" bigint NOT NULL,
    "versionNumber" bigint NOT NULL,
    "status" text NOT NULL,
    "data" text NOT NULL,
    "changeLog" text,
    "publishedAt" timestamp without time zone,
    "scheduledAt" timestamp without time zone,
    "archivedAt" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint NOT NULL
);

-- Indexes
CREATE INDEX "document_versions_document_id_idx" ON "document_versions" USING btree ("documentId");
CREATE UNIQUE INDEX "document_versions_document_version_idx" ON "document_versions" USING btree ("documentId", "versionNumber");
CREATE INDEX "document_versions_status_idx" ON "document_versions" USING btree ("status");
CREATE INDEX "document_versions_published_at_idx" ON "document_versions" USING btree ("publishedAt");
CREATE INDEX "document_versions_scheduled_at_idx" ON "document_versions" USING btree ("scheduledAt");
CREATE INDEX "document_versions_created_at_idx" ON "document_versions" USING btree ("createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "documents" (
    "id" bigserial PRIMARY KEY,
    "clientId" bigint NOT NULL,
    "documentType" text NOT NULL,
    "title" text NOT NULL,
    "slug" text,
    "currentVersionId" bigint,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint NOT NULL,
    "updatedByUserId" bigint
);

-- Indexes
CREATE INDEX "documents_client_id_idx" ON "documents" USING btree ("clientId");
CREATE INDEX "documents_document_type_idx" ON "documents" USING btree ("documentType");
CREATE INDEX "documents_client_type_idx" ON "documents" USING btree ("clientId", "documentType");
CREATE INDEX "documents_current_version_idx" ON "documents" USING btree ("currentVersionId");
CREATE INDEX "documents_created_at_idx" ON "documents" USING btree ("createdAt");
CREATE INDEX "documents_updated_at_idx" ON "documents" USING btree ("updatedAt");

--
-- ACTION DROP TABLE
--
DROP TABLE "media_files" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "media_files" (
    "id" bigserial PRIMARY KEY,
    "clientId" bigint NOT NULL,
    "fileName" text NOT NULL,
    "fileType" text NOT NULL,
    "fileSize" bigint NOT NULL,
    "storagePath" text NOT NULL,
    "publicUrl" text NOT NULL,
    "altText" text,
    "metadata" text,
    "uploadedByUserId" bigint NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "media_files_client_id_idx" ON "media_files" USING btree ("clientId");
CREATE INDEX "media_files_uploaded_by_idx" ON "media_files" USING btree ("uploadedByUserId");
CREATE INDEX "media_files_created_at_idx" ON "media_files" USING btree ("createdAt");
CREATE INDEX "media_files_file_type_idx" ON "media_files" USING btree ("fileType");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "cms_client_users"
    ADD CONSTRAINT "cms_client_users_fk_0"
    FOREIGN KEY("clientId")
    REFERENCES "cms_clients"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cms_client_users"
    ADD CONSTRAINT "cms_client_users_fk_1"
    FOREIGN KEY("cmsUserId")
    REFERENCES "cms_users"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "cms_users"
    ADD CONSTRAINT "cms_users_fk_0"
    FOREIGN KEY("clientId")
    REFERENCES "cms_clients"("id")
    ON DELETE RESTRICT
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
    REFERENCES "cms_users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "documents"
    ADD CONSTRAINT "documents_fk_0"
    FOREIGN KEY("clientId")
    REFERENCES "cms_clients"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "documents"
    ADD CONSTRAINT "documents_fk_1"
    FOREIGN KEY("createdByUserId")
    REFERENCES "cms_users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "documents"
    ADD CONSTRAINT "documents_fk_2"
    FOREIGN KEY("updatedByUserId")
    REFERENCES "cms_users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "media_files"
    ADD CONSTRAINT "media_files_fk_0"
    FOREIGN KEY("clientId")
    REFERENCES "cms_clients"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "media_files"
    ADD CONSTRAINT "media_files_fk_1"
    FOREIGN KEY("uploadedByUserId")
    REFERENCES "cms_users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR flutter_cms_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('flutter_cms_be', '20251128143358425', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251128143358425', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
