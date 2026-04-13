BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "document_versions" ADD COLUMN "updatedByUserId" bigint;
ALTER TABLE "document_versions" ADD COLUMN "deletedAt" timestamp without time zone;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "documents" ADD COLUMN "deletedAt" timestamp without time zone;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "media_assets" ADD COLUMN "updatedByUserId" bigint;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "projects" ADD COLUMN "createdByUserId" bigint;
ALTER TABLE "projects" ADD COLUMN "updatedByUserId" bigint;
ALTER TABLE "projects" ADD COLUMN "deletedAt" timestamp without time zone;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "users" ADD COLUMN "deletedAt" timestamp without time zone;
--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "document_versions"
    ADD CONSTRAINT "document_versions_fk_2"
    FOREIGN KEY("updatedByUserId")
    REFERENCES "users"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;
--
-- ACTION CREATE FOREIGN KEY
--
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
    VALUES ('dart_desk', '20260413115846735', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260413115846735', "timestamp" = now();

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


-- Auto-update updated_at on row modification
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN
    SELECT table_name FROM information_schema.columns
    WHERE column_name = 'updated_at'
      AND table_schema = 'public'
      AND table_name NOT LIKE 'serverpod_%'
  LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_set_updated_at ON %I; CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION set_updated_at();',
      tbl, tbl
    );
  END LOOP;
END;
$$;

COMMIT;
