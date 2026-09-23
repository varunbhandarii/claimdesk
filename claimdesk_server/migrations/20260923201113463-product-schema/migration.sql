BEGIN;

--
-- CREATE VECTOR EXTENSION IF AVAILABLE
--
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'vector') THEN
    EXECUTE 'CREATE EXTENSION IF NOT EXISTS vector';
  ELSE
    RAISE EXCEPTION 'Required extension "vector" is not available on this instance. Please install pgvector. For instructions, see https://docs.serverpod.dev/upgrading/upgrade-to-pgvector.';
  END IF;
END
$$;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "audit_event" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "venueId" uuid NOT NULL,
    "entityType" text NOT NULL,
    "entityId" uuid NOT NULL,
    "action" text NOT NULL,
    "actorAuthUserId" uuid,
    "payload" jsonb,
    "at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "audit_event_entity_idx" ON "audit_event" USING btree ("entityType", "entityId", "at");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "caption_run" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "venueId" uuid NOT NULL,
    "itemId" uuid NOT NULL,
    "provider" text NOT NULL,
    "modelId" text NOT NULL,
    "promptVersion" text NOT NULL,
    "outcome" text NOT NULL,
    "latencyMs" bigint NOT NULL,
    "inputTokens" bigint,
    "outputTokens" bigint,
    "errorMessage" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "caption_run_item_idx" ON "caption_run" USING btree ("itemId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "custody_event" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "venueId" uuid NOT NULL,
    "itemId" uuid NOT NULL,
    "fromLocation" text NOT NULL,
    "toLocation" text NOT NULL,
    "reference" text,
    "byAuthUserId" uuid NOT NULL,
    "at" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "custody_event_item_idx" ON "custody_event" USING btree ("itemId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "found_item" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "venueId" uuid NOT NULL,
    "zoneId" uuid,
    "status" text NOT NULL DEFAULT 'intake'::text,
    "refCode" text NOT NULL,
    "photoPath" text,
    "thumbPath" text,
    "restricted" boolean NOT NULL DEFAULT false,
    "attributes" jsonb,
    "captionText" text,
    "embedding" vector(1536),
    "embeddingModel" text,
    "valueBand" text NOT NULL DEFAULT 'under20'::text,
    "storageBin" text,
    "privateNotes" text,
    "finderName" text,
    "foundAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "loggedByAuthUserId" uuid NOT NULL,
    "holdUntil" timestamp without time zone,
    "handoffDueAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "found_item__venueId__refCode__unique_idx" ON "found_item" USING btree ("venueId", "refCode");
CREATE INDEX "found_item_venue_status_found_idx" ON "found_item" USING btree ("venueId", "status", "foundAt");
CREATE INDEX "found_item_attributes_gin_idx" ON "found_item" USING gin ("attributes" jsonb_path_ops);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "item_match" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "venueId" uuid NOT NULL,
    "reportId" uuid NOT NULL,
    "itemId" uuid NOT NULL,
    "state" text NOT NULL DEFAULT 'pending'::text,
    "score" double precision NOT NULL,
    "label" text NOT NULL,
    "rank" bigint NOT NULL,
    "explanation" jsonb NOT NULL,
    "algorithmVersion" text NOT NULL,
    "decidedByAuthUserId" uuid,
    "decidedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "item_match_report_item_idx" ON "item_match" USING btree ("reportId", "itemId");
CREATE INDEX "item_match_venue_state_idx" ON "item_match" USING btree ("venueId", "state", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "lost_report" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "venueId" uuid NOT NULL,
    "status" text NOT NULL DEFAULT 'received'::text,
    "refCode" text NOT NULL,
    "publicToken" text NOT NULL,
    "rawText" text NOT NULL,
    "categoryHint" text,
    "colourHints" json NOT NULL,
    "brandHint" text,
    "zoneId" uuid,
    "whereText" text,
    "lostAt" timestamp without time zone,
    "lostAtFuzzyDays" bigint NOT NULL DEFAULT 0,
    "ownerOnlyDetails" text,
    "contactEmail" text,
    "ownerName" text,
    "attributes" jsonb,
    "embedding" vector(1536),
    "embeddingModel" text,
    "duplicateOfReportId" uuid,
    "ipHash" text,
    "closedAt" timestamp without time zone,
    "contactPurgedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "lost_report__venueId__refCode__unique_idx" ON "lost_report" USING btree ("venueId", "refCode");
CREATE UNIQUE INDEX "lost_report__publicToken__unique_idx" ON "lost_report" USING btree ("publicToken");
CREATE INDEX "lost_report_venue_status_idx" ON "lost_report" USING btree ("venueId", "status", "createdAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "release_record" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "venueId" uuid NOT NULL,
    "itemId" uuid NOT NULL,
    "reportId" uuid,
    "claimantName" text NOT NULL,
    "idTypeSeen" text NOT NULL,
    "detailsMatched" bigint NOT NULL,
    "describedBeforeViewing" boolean NOT NULL,
    "thirdPartyAuthorisationNote" text,
    "signaturePath" text,
    "releasedByAuthUserId" uuid NOT NULL,
    "releasedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "release_record_item_idx" ON "release_record" USING btree ("itemId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "report_answer" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "venueId" uuid NOT NULL,
    "reportId" uuid NOT NULL,
    "matchId" uuid NOT NULL,
    "question" text NOT NULL,
    "answer" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "report_answer_report_idx" ON "report_answer" USING btree ("reportId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "staff_membership" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "venueId" uuid NOT NULL,
    "role" text NOT NULL DEFAULT 'staff'::text,
    "displayName" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "staff_membership_user_venue_idx" ON "staff_membership" USING btree ("authUserId", "venueId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "venue" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "timezone" text NOT NULL DEFAULT 'America/New_York'::text,
    "deskHours" text,
    "pickupInstructions" text,
    "retentionPolicy" jsonb,
    "policeHandoffThresholdCents" bigint NOT NULL DEFAULT 2000,
    "policeHandoffDays" bigint NOT NULL DEFAULT 10,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "venue__slug__unique_idx" ON "venue" USING btree ("slug");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "work_item" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "venueId" uuid,
    "kind" text NOT NULL,
    "payload" jsonb NOT NULL,
    "identifier" text,
    "runAt" timestamp without time zone NOT NULL,
    "state" text NOT NULL DEFAULT 'pending'::text,
    "leaseUntil" timestamp without time zone,
    "attempts" bigint NOT NULL DEFAULT 0,
    "maxAttempts" bigint NOT NULL DEFAULT 5,
    "lastError" text,
    "completedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "work_item__identifier__unique_idx" ON "work_item" USING btree ("identifier");
CREATE INDEX "work_item_state_run_idx" ON "work_item" USING btree ("state", "runAt");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "zone" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "venueId" uuid NOT NULL,
    "name" text NOT NULL,
    "sortOrder" bigint NOT NULL DEFAULT 0,
    "adjacentZoneIds" json NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "zone_venue_name_idx" ON "zone" USING btree ("venueId", "name");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "caption_run"
    ADD CONSTRAINT "caption_run_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "caption_run"
    ADD CONSTRAINT "caption_run_fk_1"
    FOREIGN KEY("itemId")
    REFERENCES "found_item"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "custody_event"
    ADD CONSTRAINT "custody_event_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "custody_event"
    ADD CONSTRAINT "custody_event_fk_1"
    FOREIGN KEY("itemId")
    REFERENCES "found_item"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "found_item"
    ADD CONSTRAINT "found_item_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "found_item"
    ADD CONSTRAINT "found_item_fk_1"
    FOREIGN KEY("zoneId")
    REFERENCES "zone"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "item_match"
    ADD CONSTRAINT "item_match_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "item_match"
    ADD CONSTRAINT "item_match_fk_1"
    FOREIGN KEY("reportId")
    REFERENCES "lost_report"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "item_match"
    ADD CONSTRAINT "item_match_fk_2"
    FOREIGN KEY("itemId")
    REFERENCES "found_item"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "lost_report"
    ADD CONSTRAINT "lost_report_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "lost_report"
    ADD CONSTRAINT "lost_report_fk_1"
    FOREIGN KEY("zoneId")
    REFERENCES "zone"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "release_record"
    ADD CONSTRAINT "release_record_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "release_record"
    ADD CONSTRAINT "release_record_fk_1"
    FOREIGN KEY("itemId")
    REFERENCES "found_item"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "release_record"
    ADD CONSTRAINT "release_record_fk_2"
    FOREIGN KEY("reportId")
    REFERENCES "lost_report"("id")
    ON DELETE SET NULL
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "report_answer"
    ADD CONSTRAINT "report_answer_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "report_answer"
    ADD CONSTRAINT "report_answer_fk_1"
    FOREIGN KEY("reportId")
    REFERENCES "lost_report"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "report_answer"
    ADD CONSTRAINT "report_answer_fk_2"
    FOREIGN KEY("matchId")
    REFERENCES "item_match"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "staff_membership"
    ADD CONSTRAINT "staff_membership_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "work_item"
    ADD CONSTRAINT "work_item_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "zone"
    ADD CONSTRAINT "zone_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR claimdesk
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('claimdesk', '20260923201113463-product-schema', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260923201113463-product-schema', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();


COMMIT;
