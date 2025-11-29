BEGIN;

--
-- ACTION ALTER TABLE
--
DROP INDEX "cms_documents_client_type_idx";
CREATE UNIQUE INDEX "cms_documents_client_type_idx" ON "cms_documents" USING btree ("clientId", "documentType");
--
-- ACTION DROP TABLE
--
DROP TABLE "document_crdt_operations" CASCADE;

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
-- ACTION DROP TABLE
--
DROP TABLE "document_versions" CASCADE;

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
    "createdByUserId" bigint NOT NULL
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "document_crdt_operations"
    ADD CONSTRAINT "document_crdt_operations_fk_0"
    FOREIGN KEY("documentId")
    REFERENCES "cms_documents"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "document_crdt_operations"
    ADD CONSTRAINT "document_crdt_operations_fk_1"
    FOREIGN KEY("createdByUserId")
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
    VALUES ('flutter_cms_be', '20251129100215200', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251129100215200', "timestamp" = now();

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
