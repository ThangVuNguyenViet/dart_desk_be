BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "cms_deployments" (
    "id" bigserial PRIMARY KEY,
    "clientId" bigint NOT NULL,
    "version" bigint NOT NULL,
    "status" text NOT NULL,
    "filePath" text NOT NULL,
    "fileSize" bigint,
    "uploadedByUserId" bigint,
    "commitHash" text,
    "metadata" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "cms_deployment_client_idx" ON "cms_deployments" USING btree ("clientId");
CREATE UNIQUE INDEX "cms_deployment_client_version_idx" ON "cms_deployments" USING btree ("clientId", "version");
CREATE INDEX "cms_deployment_client_status_idx" ON "cms_deployments" USING btree ("clientId", "status");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "cms_deployments"
    ADD CONSTRAINT "cms_deployments_fk_0"
    FOREIGN KEY("clientId")
    REFERENCES "cms_clients"("id")
    ON DELETE RESTRICT
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "cms_deployments"
    ADD CONSTRAINT "cms_deployments_fk_1"
    FOREIGN KEY("uploadedByUserId")
    REFERENCES "cms_users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR flutter_cms_be
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('flutter_cms_be', '20260319165036977', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260319165036977', "timestamp" = now();

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
