BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "todo" ALTER COLUMN "description" DROP NOT NULL;
ALTER TABLE "todo" ALTER COLUMN "isDone" SET DEFAULT false;
ALTER TABLE "todo" ALTER COLUMN "dueDate" DROP NOT NULL;
ALTER TABLE "todo" ALTER COLUMN "createdAt" SET DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE "todo" ALTER COLUMN "updatedAt" SET DEFAULT CURRENT_TIMESTAMP;

--
-- MIGRATION VERSION FOR todo_serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('todo_serverpod', '20260222105347993', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260222105347993', "timestamp" = now();

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
    VALUES ('serverpod_auth_idp', '20260129181124635', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181124635', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
