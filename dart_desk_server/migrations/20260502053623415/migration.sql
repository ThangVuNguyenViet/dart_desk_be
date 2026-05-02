BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "published_documents" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "documentId" uuid NOT NULL,
    "projectId" uuid NOT NULL,
    "documentType" text NOT NULL,
    "title" text NOT NULL,
    "slug" text NOT NULL,
    "isDefault" boolean NOT NULL DEFAULT false,
    "data" jsonb,
    "publishedAt" timestamp without time zone NOT NULL,
    "publishedVersionId" uuid NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "deletedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "published_docs_document_id_unique_idx" ON "published_documents" USING btree ("documentId");
CREATE INDEX "published_docs_project_type_idx" ON "published_documents" USING btree ("projectId", "documentType");
CREATE INDEX "published_docs_project_type_slug_idx" ON "published_documents" USING btree ("projectId", "documentType", "slug");
CREATE INDEX "published_docs_type_default_idx" ON "published_documents" USING btree ("documentType", "isDefault");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "serverpod_future_call" ADD COLUMN "scheduling" json;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_future_call_claim" (
    "id" bigserial PRIMARY KEY,
    "futureCallId" bigint,
    "lastHeartbeatTime" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "future_call_unique_idx" ON "serverpod_future_call_claim" USING btree ("futureCallId");

--
-- ACTION ALTER TABLE
--
DROP INDEX "serverpod_log_sessionLogId_idx";
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId", "order");
--
-- ACTION ALTER TABLE
--
CREATE INDEX "serverpod_message_log_sessionLogId_idx" ON "serverpod_message_log" USING btree ("sessionLogId", "order");
--
-- ACTION ALTER TABLE
--
DROP INDEX "serverpod_query_log_sessionLogId_idx";
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId", "order");
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "published_documents"
    ADD CONSTRAINT "published_documents_fk_0"
    FOREIGN KEY("documentId")
    REFERENCES "documents"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "published_documents"
    ADD CONSTRAINT "published_documents_fk_1"
    FOREIGN KEY("projectId")
    REFERENCES "projects"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "published_documents"
    ADD CONSTRAINT "published_documents_fk_2"
    FOREIGN KEY("publishedVersionId")
    REFERENCES "document_versions"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "serverpod_future_call_claim"
    ADD CONSTRAINT "serverpod_future_call_claim_fk_0"
    FOREIGN KEY("futureCallId")
    REFERENCES "serverpod_future_call"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260502053623415', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260502053623415', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260416151914983-insights-perf', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260416151914983-insights-perf', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260417182253191', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182253191', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260417182309198', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182309198', "timestamp" = now();


COMMIT;
