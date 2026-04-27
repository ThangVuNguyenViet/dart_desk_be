BEGIN;

-- Add a generated jsonb column derived from data, plus a GIN index for
-- containment queries. Serverpod's spy.yaml does not declare data_jsonb;
-- it is invisible to the typed ORM. Containment lookups (e.g.,
-- getContentsByDataContains) must use unsafeQuery against data_jsonb.
-- See dart_desk_be/CLAUDE.md "Schema drift" section for context.
ALTER TABLE "documents"
  ADD COLUMN "data_jsonb" jsonb
  GENERATED ALWAYS AS (("data")::jsonb) STORED;

CREATE INDEX "documents_data_gin"
  ON "documents" USING gin ("data_jsonb" jsonb_ops);

--
-- MIGRATION VERSION FOR dart_desk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('dart_desk', '20260427100000000', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260427100000000', "timestamp" = now();

COMMIT;
