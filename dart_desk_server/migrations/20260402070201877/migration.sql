BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "migration_history" (
    "id" bigserial PRIMARY KEY,
    "projectId" bigint NOT NULL,
    "name" text NOT NULL,
    "documentType" text NOT NULL,
    "appliedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "operationsJson" text NOT NULL,
    "report" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "migration_history_project_name_idx" ON "migration_history" USING btree ("projectId", "name");

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
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260402070201877', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260402070201877', "timestamp" = now();

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
