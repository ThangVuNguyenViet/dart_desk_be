BEGIN;

--
-- REPAIR MIGRATION: restore missing api_keys_fk_0 constraint
--
-- Context: The rename migration (20260503053750456-rename-api-tokens-to-api-keys)
-- tried RENAME CONSTRAINT api_tokens_fk_0 → api_keys_fk_0, but prod never had
-- api_tokens_fk_0 (the projectId FK was never created in the original hand-edited
-- migration). The whole BEGIN/COMMIT block rolled back, leaving the table renamed
-- but without the projectId FK. This repair idempotently adds it back.
--
-- Also: the primary key constraint is still named api_tokens_pkey on prod (the
-- RENAME TABLE preserved the old PK name). We leave that alone — renaming a PK
-- constraint requires DROP/ADD which would briefly remove the NOT NULL guarantee
-- and is low priority since Postgres enforces it correctly regardless of name.
--
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'api_keys_fk_0' AND conrelid = 'api_keys'::regclass
  ) THEN
    ALTER TABLE ONLY "api_keys"
      ADD CONSTRAINT "api_keys_fk_0"
      FOREIGN KEY ("projectId")
      REFERENCES "projects"("id")
      ON DELETE CASCADE
      ON UPDATE NO ACTION;
  END IF;
END $$;

--
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260503094803605-repair-api-keys-fk', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260503094803605-repair-api-keys-fk', "timestamp" = now();

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
