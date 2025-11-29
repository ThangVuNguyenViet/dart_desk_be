BEGIN;

--
-- Class CmsClientUser as table cms_client_users
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
-- Class CmsClient as table cms_clients
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
-- Class CmsDocument as table cms_documents
--
CREATE TABLE "cms_documents" (
    "id" bigserial PRIMARY KEY,
    "clientId" bigint NOT NULL,
    "documentType" text NOT NULL,
    "title" text NOT NULL,
    "slug" text,
    "isDefault" boolean NOT NULL DEFAULT false,
    "data" text,
    "crdtNodeId" text,
    "crdtHlc" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" bigint NOT NULL,
    "updatedByUserId" bigint
);

-- Indexes
CREATE INDEX "cms_documents_client_id_idx" ON "cms_documents" USING btree ("clientId");
CREATE INDEX "cms_documents_document_type_idx" ON "cms_documents" USING btree ("documentType");
CREATE UNIQUE INDEX "cms_documents_client_type_idx" ON "cms_documents" USING btree ("clientId", "documentType");
CREATE INDEX "cms_documents_slug_idx" ON "cms_documents" USING btree ("slug");
CREATE INDEX "cms_documents_is_default_idx" ON "cms_documents" USING btree ("isDefault");
CREATE INDEX "cms_documents_type_default_idx" ON "cms_documents" USING btree ("documentType", "isDefault");
CREATE INDEX "cms_documents_data_idx" ON "cms_documents" USING btree ("data");
CREATE INDEX "cms_documents_crdt_node_idx" ON "cms_documents" USING btree ("crdtNodeId");
CREATE INDEX "cms_documents_created_at_idx" ON "cms_documents" USING btree ("createdAt");
CREATE INDEX "cms_documents_updated_at_idx" ON "cms_documents" USING btree ("updatedAt");

--
-- Class CmsDocumentData as table cms_documents_data
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
-- Class CmsUser as table cms_users
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
-- Class DocumentCrdtOperation as table document_crdt_operations
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
-- Class DocumentCrdtSnapshot as table document_crdt_snapshots
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
-- Class DocumentVersion as table document_versions
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
-- Class MediaFile as table media_files
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
-- Class CloudStorageEntry as table serverpod_cloud_storage
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "addedTime" timestamp without time zone NOT NULL,
    "expiration" timestamp without time zone,
    "byteData" bytea NOT NULL,
    "verified" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" USING btree ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" USING btree ("expiration");

--
-- Class CloudStorageDirectUploadEntry as table serverpod_cloud_storage_direct_upload
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" USING btree ("storageId", "path");

--
-- Class FutureCallEntry as table serverpod_future_call
--
CREATE TABLE "serverpod_future_call" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "serializedObject" text,
    "serverId" text NOT NULL,
    "identifier" text
);

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" USING btree ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" USING btree ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" USING btree ("identifier");

--
-- Class ServerHealthConnectionInfo as table serverpod_health_connection_info
--
CREATE TABLE "serverpod_health_connection_info" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "active" bigint NOT NULL,
    "closing" bigint NOT NULL,
    "idle" bigint NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_connection_info_timestamp_idx" ON "serverpod_health_connection_info" USING btree ("timestamp", "serverId", "granularity");

--
-- Class ServerHealthMetric as table serverpod_health_metric
--
CREATE TABLE "serverpod_health_metric" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "isHealthy" boolean NOT NULL,
    "value" double precision NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_metric_timestamp_idx" ON "serverpod_health_metric" USING btree ("timestamp", "serverId", "name", "granularity");

--
-- Class LogEntry as table serverpod_log
--
CREATE TABLE "serverpod_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "reference" text,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "logLevel" bigint NOT NULL,
    "message" text NOT NULL,
    "error" text,
    "stackTrace" text,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId");

--
-- Class MessageLogEntry as table serverpod_message_log
--
CREATE TABLE "serverpod_message_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "serverId" text NOT NULL,
    "messageId" bigint NOT NULL,
    "endpoint" text NOT NULL,
    "messageName" text NOT NULL,
    "duration" double precision NOT NULL,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

--
-- Class MethodInfo as table serverpod_method
--
CREATE TABLE "serverpod_method" (
    "id" bigserial PRIMARY KEY,
    "endpoint" text NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" USING btree ("endpoint", "method");

--
-- Class DatabaseMigrationVersion as table serverpod_migrations
--
CREATE TABLE "serverpod_migrations" (
    "id" bigserial PRIMARY KEY,
    "module" text NOT NULL,
    "version" text NOT NULL,
    "timestamp" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_migrations_ids" ON "serverpod_migrations" USING btree ("module");

--
-- Class QueryLogEntry as table serverpod_query_log
--
CREATE TABLE "serverpod_query_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "query" text NOT NULL,
    "duration" double precision NOT NULL,
    "numRows" bigint,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId");

--
-- Class ReadWriteTestEntry as table serverpod_readwrite_test
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" bigserial PRIMARY KEY,
    "number" bigint NOT NULL
);

--
-- Class RuntimeSettings as table serverpod_runtime_settings
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" bigserial PRIMARY KEY,
    "logSettings" json NOT NULL,
    "logSettingsOverrides" json NOT NULL,
    "logServiceCalls" boolean NOT NULL,
    "logMalformedCalls" boolean NOT NULL
);

--
-- Class SessionLogEntry as table serverpod_session_log
--
CREATE TABLE "serverpod_session_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "module" text,
    "endpoint" text,
    "method" text,
    "duration" double precision,
    "numQueries" bigint,
    "slow" boolean,
    "error" text,
    "stackTrace" text,
    "authenticatedUserId" bigint,
    "isOpen" boolean,
    "touched" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_session_log_serverid_idx" ON "serverpod_session_log" USING btree ("serverId");
CREATE INDEX "serverpod_session_log_touched_idx" ON "serverpod_session_log" USING btree ("touched");
CREATE INDEX "serverpod_session_log_isopen_idx" ON "serverpod_session_log" USING btree ("isOpen");

--
-- Class AuthKey as table serverpod_auth_key
--
CREATE TABLE "serverpod_auth_key" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "hash" text NOT NULL,
    "scopeNames" json NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_auth_key_userId_idx" ON "serverpod_auth_key" USING btree ("userId");

--
-- Class EmailAuth as table serverpod_email_auth
--
CREATE TABLE "serverpod_email_auth" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "email" text NOT NULL,
    "hash" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_email_auth_email" ON "serverpod_email_auth" USING btree ("email");

--
-- Class EmailCreateAccountRequest as table serverpod_email_create_request
--
CREATE TABLE "serverpod_email_create_request" (
    "id" bigserial PRIMARY KEY,
    "userName" text NOT NULL,
    "email" text NOT NULL,
    "hash" text NOT NULL,
    "verificationCode" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_email_auth_create_account_request_idx" ON "serverpod_email_create_request" USING btree ("email");

--
-- Class EmailFailedSignIn as table serverpod_email_failed_sign_in
--
CREATE TABLE "serverpod_email_failed_sign_in" (
    "id" bigserial PRIMARY KEY,
    "email" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "ipAddress" text NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_email_failed_sign_in_email_idx" ON "serverpod_email_failed_sign_in" USING btree ("email");
CREATE INDEX "serverpod_email_failed_sign_in_time_idx" ON "serverpod_email_failed_sign_in" USING btree ("time");

--
-- Class EmailReset as table serverpod_email_reset
--
CREATE TABLE "serverpod_email_reset" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "verificationCode" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_email_reset_verification_idx" ON "serverpod_email_reset" USING btree ("verificationCode");

--
-- Class GoogleRefreshToken as table serverpod_google_refresh_token
--
CREATE TABLE "serverpod_google_refresh_token" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "refreshToken" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_google_refresh_token_userId_idx" ON "serverpod_google_refresh_token" USING btree ("userId");

--
-- Class UserImage as table serverpod_user_image
--
CREATE TABLE "serverpod_user_image" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "version" bigint NOT NULL,
    "url" text NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_user_image_user_id" ON "serverpod_user_image" USING btree ("userId", "version");

--
-- Class UserInfo as table serverpod_user_info
--
CREATE TABLE "serverpod_user_info" (
    "id" bigserial PRIMARY KEY,
    "userIdentifier" text NOT NULL,
    "userName" text,
    "fullName" text,
    "email" text,
    "created" timestamp without time zone NOT NULL,
    "imageUrl" text,
    "scopeNames" json NOT NULL,
    "blocked" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_user_info_user_identifier" ON "serverpod_user_info" USING btree ("userIdentifier");
CREATE INDEX "serverpod_user_info_email" ON "serverpod_user_info" USING btree ("email");

--
-- Foreign relations for "cms_client_users" table
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
-- Foreign relations for "cms_documents" table
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
-- Foreign relations for "cms_users" table
--
ALTER TABLE ONLY "cms_users"
    ADD CONSTRAINT "cms_users_fk_0"
    FOREIGN KEY("clientId")
    REFERENCES "cms_clients"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;

--
-- Foreign relations for "document_crdt_operations" table
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
-- Foreign relations for "document_crdt_snapshots" table
--
ALTER TABLE ONLY "document_crdt_snapshots"
    ADD CONSTRAINT "document_crdt_snapshots_fk_0"
    FOREIGN KEY("documentId")
    REFERENCES "cms_documents"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "document_versions" table
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
-- Foreign relations for "media_files" table
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
-- Foreign relations for "serverpod_log" table
--
ALTER TABLE ONLY "serverpod_log"
    ADD CONSTRAINT "serverpod_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_message_log" table
--
ALTER TABLE ONLY "serverpod_message_log"
    ADD CONSTRAINT "serverpod_message_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_query_log" table
--
ALTER TABLE ONLY "serverpod_query_log"
    ADD CONSTRAINT "serverpod_query_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
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
