BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cms_documents" (
    "id" bigserial PRIMARY KEY,
    "documentType" text NOT NULL,
    "data" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint,
    "updatedByUserId" bigint
);

-- Indexes
CREATE INDEX "cms_documents_document_type_idx" ON "cms_documents" USING btree ("documentType");
CREATE INDEX "cms_documents_created_at_idx" ON "cms_documents" USING btree ("createdAt");
CREATE INDEX "cms_documents_updated_at_idx" ON "cms_documents" USING btree ("updatedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cms_users" (
    "id" bigserial PRIMARY KEY,
    "email" text NOT NULL,
    "name" text,
    "role" text NOT NULL DEFAULT 'viewer'::text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "cms_users_email_idx" ON "cms_users" USING btree ("email");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "media_files" (
    "id" bigserial PRIMARY KEY,
    "fileName" text NOT NULL,
    "fileType" text NOT NULL,
    "fileSize" bigint NOT NULL,
    "storagePath" text NOT NULL,
    "publicUrl" text NOT NULL,
    "uploadedByUserId" bigint,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "media_files_uploaded_by_idx" ON "media_files" USING btree ("uploadedByUserId");
CREATE INDEX "media_files_created_at_idx" ON "media_files" USING btree ("createdAt");


--
-- MIGRATION VERSION FOR flutter_cms_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('flutter_cms_be', '20251128134306930', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251128134306930', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


COMMIT;
