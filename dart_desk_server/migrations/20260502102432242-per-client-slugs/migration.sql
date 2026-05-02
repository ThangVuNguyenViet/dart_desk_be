BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "projects" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "projects" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "clientId" uuid NOT NULL,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "deployHostname" text NOT NULL,
    "description" text,
    "isActive" boolean NOT NULL DEFAULT true,
    "settings" text,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "createdByUserId" uuid,
    "updatedByUserId" uuid,
    "deletedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "projects_client_idx" ON "projects" USING btree ("clientId");
CREATE INDEX "projects_is_active_idx" ON "projects" USING btree ("isActive");

-- Per-client slug uniqueness (partial: ignores soft-deleted rows).
CREATE UNIQUE INDEX "projects_client_slug_active_idx"
  ON "projects" ("clientId", "slug")
  WHERE "deletedAt" IS NULL;

-- Global uniqueness on the public hostname.
CREATE UNIQUE INDEX "projects_deploy_hostname_active_idx"
  ON "projects" ("deployHostname")
  WHERE "deletedAt" IS NULL;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "projects"
    ADD CONSTRAINT "projects_fk_0"
    FOREIGN KEY("clientId")
    REFERENCES "clients"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "projects"
    ADD CONSTRAINT "projects_fk_1"
    FOREIGN KEY("createdByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "projects"
    ADD CONSTRAINT "projects_fk_2"
    FOREIGN KEY("updatedByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260502102432242-per-client-slugs', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260502102432242-per-client-slugs', "timestamp" = now();

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
