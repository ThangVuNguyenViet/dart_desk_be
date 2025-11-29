BEGIN;

--
-- ACTION ALTER TABLE
--
DROP INDEX "cms_documents_active_data_idx";
ALTER TABLE "cms_documents" DROP COLUMN "activeVersionData";
ALTER TABLE "cms_documents" ADD COLUMN "data" text;
ALTER TABLE "cms_documents" ADD COLUMN "crdtNodeId" text;
ALTER TABLE "cms_documents" ADD COLUMN "crdtHlc" text;
CREATE INDEX "cms_documents_data_idx" ON "cms_documents" USING btree ("data");
CREATE INDEX "cms_documents_crdt_node_idx" ON "cms_documents" USING btree ("crdtNodeId");
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
-- ACTION ALTER TABLE
--
ALTER TABLE "document_versions" DROP COLUMN "data";
ALTER TABLE "document_versions" ADD COLUMN "snapshotHlc" text;
ALTER TABLE "document_versions" ADD COLUMN "operationCount" bigint NOT NULL DEFAULT 0;
CREATE INDEX "document_versions_snapshot_hlc_idx" ON "document_versions" USING btree ("documentId", "snapshotHlc");
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
ALTER TABLE ONLY "document_crdt_snapshots"
    ADD CONSTRAINT "document_crdt_snapshots_fk_0"
    FOREIGN KEY("documentId")
    REFERENCES "cms_documents"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR flutter_cms_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('flutter_cms_be', '20251129094551438', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251129094551438', "timestamp" = now();

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
