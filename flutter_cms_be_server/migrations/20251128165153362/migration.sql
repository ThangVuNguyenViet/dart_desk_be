BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "document_versions" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "documents" CASCADE;

--
-- ACTION DROP TABLE
--
DROP TABLE "cms_documents" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cms_documents" (
    "id" bigserial PRIMARY KEY,
    "clientId" bigint NOT NULL,
    "documentType" text NOT NULL,
    "title" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint NOT NULL,
    "updatedByUserId" bigint
);

-- Indexes
CREATE INDEX "cms_documents_client_id_idx" ON "cms_documents" USING btree ("clientId");
CREATE INDEX "cms_documents_document_type_idx" ON "cms_documents" USING btree ("documentType");
CREATE INDEX "cms_documents_client_type_idx" ON "cms_documents" USING btree ("clientId", "documentType");
CREATE INDEX "cms_documents_created_at_idx" ON "cms_documents" USING btree ("createdAt");
CREATE INDEX "cms_documents_updated_at_idx" ON "cms_documents" USING btree ("updatedAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cms_documents_data" (
    "id" bigserial PRIMARY KEY,
    "documentType" text NOT NULL,
    "data" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint,
    "updatedByUserId" bigint
);

-- Indexes
CREATE INDEX "cms_documents_data_document_type_idx" ON "cms_documents_data" USING btree ("documentType");
CREATE INDEX "cms_documents_data_created_at_idx" ON "cms_documents_data" USING btree ("createdAt");
CREATE INDEX "cms_documents_data_updated_at_idx" ON "cms_documents_data" USING btree ("updatedAt");

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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "cms_documents"
    ADD CONSTRAINT "cms_documents_fk_0"
    FOREIGN KEY("clientId")
    REFERENCES "cms_clients"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cms_documents"
    ADD CONSTRAINT "cms_documents_fk_1"
    FOREIGN KEY("createdByUserId")
    REFERENCES "cms_users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cms_documents"
    ADD CONSTRAINT "cms_documents_fk_2"
    FOREIGN KEY("updatedByUserId")
    REFERENCES "cms_users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "document_versions"
    ADD CONSTRAINT "document_versions_fk_0"
    FOREIGN KEY("documentId")
    REFERENCES "cms_documents"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "document_versions"
    ADD CONSTRAINT "document_versions_fk_1"
    FOREIGN KEY("createdByUserId")
    REFERENCES "cms_users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR flutter_cms_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('flutter_cms_be', '20251128165153362', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251128165153362', "timestamp" = now();

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
