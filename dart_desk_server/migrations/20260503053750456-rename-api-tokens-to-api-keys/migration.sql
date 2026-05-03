BEGIN;

--
-- ACTION RENAME TABLE (hand-edited: preserve data)
--
ALTER TABLE "api_tokens" RENAME TO "api_keys";

-- Rename foreign key constraints
ALTER TABLE "api_keys" RENAME CONSTRAINT "api_tokens_fk_0" TO "api_keys_fk_0";
ALTER TABLE "api_keys" RENAME CONSTRAINT "api_tokens_fk_1" TO "api_keys_fk_1";

-- Rename indexes
ALTER INDEX "api_token_project_idx" RENAME TO "api_key_project_idx";
ALTER INDEX "api_token_lookup_idx" RENAME TO "api_key_lookup_idx";
ALTER INDEX "api_token_prefix_suffix_idx" RENAME TO "api_key_prefix_suffix_idx";


--
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260503053750456-rename-api-tokens-to-api-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260503053750456-rename-api-tokens-to-api-keys', "timestamp" = now();

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
