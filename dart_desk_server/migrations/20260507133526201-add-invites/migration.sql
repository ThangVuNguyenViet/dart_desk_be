BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "invites" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "clientId" uuid NOT NULL,
    "email" text NOT NULL,
    "role" text NOT NULL,
    "token" text NOT NULL,
    "invitedByUserId" uuid NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "acceptedAt" timestamp without time zone,
    "acceptedUserId" uuid,
    "revokedAt" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "invites_token_idx" ON "invites" USING btree ("token");
CREATE INDEX "invites_client_idx" ON "invites" USING btree ("clientId");


--
-- Partial unique index for pending invites (one per client+email). Not
-- expressible via Serverpod indexes block — see dart_desk_be/CLAUDE.md.
--
CREATE UNIQUE INDEX "invites_client_email_pending_idx"
  ON "invites" ("clientId", "email")
  WHERE "acceptedAt" IS NULL AND "revokedAt" IS NULL;

--
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260507133526201-add-invites', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260507133526201-add-invites', "timestamp" = now();

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
