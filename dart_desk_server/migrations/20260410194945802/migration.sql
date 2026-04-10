BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "project_members" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "projectId" bigint NOT NULL,
    "role" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "project_member_unique" ON "project_members" USING btree ("userId", "projectId");
CREATE INDEX "project_member_project_idx" ON "project_members" USING btree ("projectId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "users" DROP COLUMN "role";
ALTER TABLE "users" ADD COLUMN "role" text NOT NULL DEFAULT 'viewer'::text;
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
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260410194945802', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260410194945802', "timestamp" = now();

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
