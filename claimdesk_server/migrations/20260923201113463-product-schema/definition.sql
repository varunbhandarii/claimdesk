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
-- Class AuditEvent as table audit_event
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
-- Class CaptionRun as table caption_run
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
-- Class CustodyEvent as table custody_event
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
-- Class FoundItem as table found_item
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
-- Class ItemMatch as table item_match
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
-- Class LostReport as table lost_report
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
-- Class ReleaseRecord as table release_record
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
-- Class ReportAnswer as table report_answer
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
-- Class StaffMembership as table staff_membership
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
-- Class Venue as table venue
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
-- Class WorkItem as table work_item
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
-- Class Zone as table zone
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
-- Class CloudStorageEntry as table serverpod_cloud_storage
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "addedTime" timestamp without time zone NOT NULL,
    "expiration" timestamp without time zone,
    "byteData" bytea NOT NULL,
    "verified" boolean NOT NULL,
    "contentType" text,
    "cacheControl" text,
    "contentDisposition" text,
    "contentEncoding" text,
    "customMetadata" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" USING btree ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" USING btree ("expiration");

--
-- Class CloudStorageDirectDownloadEntry as table serverpod_cloud_storage_direct_download
--
CREATE TABLE "serverpod_cloud_storage_direct_download" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL,
    "downloadFileName" text,
    "contentType" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_download_auth_key" ON "serverpod_cloud_storage_direct_download" USING btree ("authKey");
CREATE INDEX "serverpod_cloud_storage_direct_download_expiration" ON "serverpod_cloud_storage_direct_download" USING btree ("expiration");

--
-- Class CloudStorageDirectUploadEntry as table serverpod_cloud_storage_direct_upload
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL,
    "maxFileSize" bigint NOT NULL DEFAULT 10485760,
    "contentLength" bigint,
    "preventOverwrite" boolean NOT NULL DEFAULT false,
    "contentType" text,
    "cacheControl" text,
    "contentDisposition" text,
    "contentEncoding" text,
    "customMetadata" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" USING btree ("storageId", "path");

--
-- Class FutureCallEntry as table serverpod_future_call
--
CREATE TABLE "serverpod_future_call" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "serializedObject" text,
    "serverId" text NOT NULL,
    "identifier" text,
    "scheduling" json
);

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" USING btree ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" USING btree ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" USING btree ("identifier");

--
-- Class FutureCallClaimEntry as table serverpod_future_call_claim
--
CREATE TABLE "serverpod_future_call_claim" (
    "id" bigserial PRIMARY KEY,
    "futureCallId" bigint,
    "lastHeartbeatTime" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "future_call_unique_idx" ON "serverpod_future_call_claim" USING btree ("futureCallId");

--
-- Class ServerHealthConnectionInfo as table serverpod_health_connection_info
--
CREATE TABLE "serverpod_health_connection_info" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "active" bigint NOT NULL,
    "closing" bigint NOT NULL,
    "idle" bigint NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_connection_info_timestamp_idx" ON "serverpod_health_connection_info" USING btree ("timestamp", "serverId", "granularity");

--
-- Class ServerHealthMetric as table serverpod_health_metric
--
CREATE TABLE "serverpod_health_metric" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "isHealthy" boolean NOT NULL,
    "value" double precision NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_metric_timestamp_idx" ON "serverpod_health_metric" USING btree ("timestamp", "serverId", "name", "granularity");

--
-- Class LogEntry as table serverpod_log
--
CREATE TABLE "serverpod_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "reference" text,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "logLevel" bigint NOT NULL,
    "message" text NOT NULL,
    "error" text,
    "stackTrace" text,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId", "order");

--
-- Class MessageLogEntry as table serverpod_message_log
--
CREATE TABLE "serverpod_message_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "serverId" text NOT NULL,
    "messageId" bigint NOT NULL,
    "endpoint" text NOT NULL,
    "messageName" text NOT NULL,
    "duration" double precision NOT NULL,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_message_log_sessionLogId_idx" ON "serverpod_message_log" USING btree ("sessionLogId", "order");

--
-- Class MethodInfo as table serverpod_method
--
CREATE TABLE "serverpod_method" (
    "id" bigserial PRIMARY KEY,
    "endpoint" text NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" USING btree ("endpoint", "method");

--
-- Class DatabaseMigrationVersion as table serverpod_migrations
--
CREATE TABLE "serverpod_migrations" (
    "id" bigserial PRIMARY KEY,
    "module" text NOT NULL,
    "version" text NOT NULL,
    "timestamp" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_migrations_ids" ON "serverpod_migrations" USING btree ("module");

--
-- Class QueryLogEntry as table serverpod_query_log
--
CREATE TABLE "serverpod_query_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "query" text NOT NULL,
    "duration" double precision NOT NULL,
    "numRows" bigint,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId", "order");

--
-- Class ReadWriteTestEntry as table serverpod_readwrite_test
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" bigserial PRIMARY KEY,
    "number" bigint NOT NULL
);

--
-- Class RuntimeSettings as table serverpod_runtime_settings
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" bigserial PRIMARY KEY,
    "logSettings" json NOT NULL,
    "logSettingsOverrides" json NOT NULL,
    "logServiceCalls" boolean NOT NULL,
    "logMalformedCalls" boolean NOT NULL
);

--
-- Class SessionLogEntry as table serverpod_session_log
--
CREATE TABLE "serverpod_session_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "module" text,
    "endpoint" text,
    "method" text,
    "duration" double precision,
    "numQueries" bigint,
    "slow" boolean,
    "error" text,
    "stackTrace" text,
    "authenticatedUserId" bigint,
    "userId" text,
    "isOpen" boolean,
    "touched" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_session_log_serverid_idx" ON "serverpod_session_log" USING btree ("serverId");
CREATE INDEX "serverpod_session_log_time_idx" ON "serverpod_session_log" USING btree ("time");
CREATE INDEX "serverpod_session_log_touched_idx" ON "serverpod_session_log" USING btree ("touched");
CREATE INDEX "serverpod_session_log_isopen_idx" ON "serverpod_session_log" USING btree ("isOpen");

--
-- Class AnonymousAccount as table serverpod_auth_idp_anonymous_account
--
CREATE TABLE "serverpod_auth_idp_anonymous_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- Class AppleAccount as table serverpod_auth_idp_apple_account
--
CREATE TABLE "serverpod_auth_idp_apple_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userIdentifier" text NOT NULL,
    "refreshToken" text NOT NULL,
    "refreshTokenRequestedWithBundleIdentifier" boolean NOT NULL,
    "lastRefreshedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "email" text,
    "isEmailVerified" boolean,
    "isPrivateEmail" boolean,
    "firstName" text,
    "lastName" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_apple_account_identifier" ON "serverpod_auth_idp_apple_account" USING btree ("userIdentifier");

--
-- Class EmailAccount as table serverpod_auth_idp_email_account
--
CREATE TABLE "serverpod_auth_idp_email_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "email" text NOT NULL,
    "passwordHash" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_email" ON "serverpod_auth_idp_email_account" USING btree ("email");

--
-- Class EmailAccountPasswordResetRequest as table serverpod_auth_idp_email_account_password_reset_request
--
CREATE TABLE "serverpod_auth_idp_email_account_password_reset_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "emailAccountId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "challengeId" uuid NOT NULL,
    "setPasswordChallengeId" uuid
);

--
-- Class EmailAccountRequest as table serverpod_auth_idp_email_account_request
--
CREATE TABLE "serverpod_auth_idp_email_account_request" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "email" text NOT NULL,
    "challengeId" uuid NOT NULL,
    "createAccountChallengeId" uuid
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_request_email" ON "serverpod_auth_idp_email_account_request" USING btree ("email");

--
-- Class FacebookAccount as table serverpod_auth_idp_facebook_account
--
CREATE TABLE "serverpod_auth_idp_facebook_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "fullName" text,
    "firstName" text,
    "lastName" text
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_facebook_account_user_identifier" ON "serverpod_auth_idp_facebook_account" USING btree ("userIdentifier");

--
-- Class FirebaseAccount as table serverpod_auth_idp_firebase_account
--
CREATE TABLE "serverpod_auth_idp_firebase_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "created" timestamp without time zone NOT NULL,
    "email" text,
    "phone" text,
    "userIdentifier" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_firebase_account_user_identifier" ON "serverpod_auth_idp_firebase_account" USING btree ("userIdentifier");

--
-- Class GitHubAccount as table serverpod_auth_idp_github_account
--
CREATE TABLE "serverpod_auth_idp_github_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "created" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_github_account_user_identifier" ON "serverpod_auth_idp_github_account" USING btree ("userIdentifier");

--
-- Class GoogleAccount as table serverpod_auth_idp_google_account
--
CREATE TABLE "serverpod_auth_idp_google_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "created" timestamp without time zone NOT NULL,
    "email" text NOT NULL,
    "userIdentifier" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_google_account_user_identifier" ON "serverpod_auth_idp_google_account" USING btree ("userIdentifier");

--
-- Class MicrosoftAccount as table serverpod_auth_idp_microsoft_account
--
CREATE TABLE "serverpod_auth_idp_microsoft_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userIdentifier" text NOT NULL,
    "email" text,
    "created" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_microsoft_account_user_identifier" ON "serverpod_auth_idp_microsoft_account" USING btree ("userIdentifier");

--
-- Class PasskeyAccount as table serverpod_auth_idp_passkey_account
--
CREATE TABLE "serverpod_auth_idp_passkey_account" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "keyId" bytea NOT NULL,
    "keyIdBase64" text NOT NULL,
    "clientDataJSON" bytea NOT NULL,
    "attestationObject" bytea NOT NULL,
    "originalChallenge" bytea NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_passkey_account_key_id_base64" ON "serverpod_auth_idp_passkey_account" USING btree ("keyIdBase64");

--
-- Class PasskeyChallenge as table serverpod_auth_idp_passkey_challenge
--
CREATE TABLE "serverpod_auth_idp_passkey_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL,
    "challenge" bytea NOT NULL
);

--
-- Class RateLimitedRequestAttempt as table serverpod_auth_idp_rate_limited_request_attempt
--
CREATE TABLE "serverpod_auth_idp_rate_limited_request_attempt" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "domain" text NOT NULL,
    "source" text NOT NULL,
    "key" text NOT NULL,
    "ipAddress" text,
    "attemptedAt" timestamp without time zone NOT NULL,
    "extraData" json
);

-- Indexes
CREATE INDEX "serverpod_auth_idp_rate_limited_request_attempt_composite" ON "serverpod_auth_idp_rate_limited_request_attempt" USING btree ("domain", "source", "key", "attemptedAt");

--
-- Class SecretChallenge as table serverpod_auth_idp_secret_challenge
--
CREATE TABLE "serverpod_auth_idp_secret_challenge" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "challengeCodeHash" text NOT NULL
);

--
-- Class RefreshToken as table serverpod_auth_core_jwt_refresh_token
--
CREATE TABLE "serverpod_auth_core_jwt_refresh_token" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "scopeNames" json NOT NULL,
    "extraClaims" text,
    "method" text NOT NULL,
    "fixedSecret" bytea NOT NULL,
    "rotatingSecretHash" text NOT NULL,
    "lastUpdatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "serverpod_auth_core_jwt_refresh_token_last_updated_at" ON "serverpod_auth_core_jwt_refresh_token" USING btree ("lastUpdatedAt");

--
-- Class UserProfile as table serverpod_auth_core_profile
--
CREATE TABLE "serverpod_auth_core_profile" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "userName" text,
    "fullName" text,
    "email" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "imageId" uuid
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_profile_user_profile_email_auth_user_id" ON "serverpod_auth_core_profile" USING btree ("authUserId");

--
-- Class UserProfileImage as table serverpod_auth_core_profile_image
--
CREATE TABLE "serverpod_auth_core_profile_image" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "userProfileId" uuid NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "url" text NOT NULL
);

--
-- Class ServerSideSession as table serverpod_auth_core_session
--
CREATE TABLE "serverpod_auth_core_session" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "authUserId" uuid NOT NULL,
    "scopeNames" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastUsedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" timestamp without time zone,
    "expireAfterUnusedFor" bigint,
    "sessionKeyHash" bytea NOT NULL,
    "sessionKeySalt" bytea NOT NULL,
    "method" text NOT NULL
);

--
-- Class AuthUser as table serverpod_auth_core_user
--
CREATE TABLE "serverpod_auth_core_user" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "createdAt" timestamp without time zone NOT NULL,
    "scopeNames" json NOT NULL,
    "blocked" boolean NOT NULL
);

--
-- Foreign relations for "caption_run" table
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
-- Foreign relations for "custody_event" table
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
-- Foreign relations for "found_item" table
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
-- Foreign relations for "item_match" table
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
-- Foreign relations for "lost_report" table
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
-- Foreign relations for "release_record" table
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
-- Foreign relations for "report_answer" table
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
-- Foreign relations for "staff_membership" table
--
ALTER TABLE ONLY "staff_membership"
    ADD CONSTRAINT "staff_membership_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "work_item" table
--
ALTER TABLE ONLY "work_item"
    ADD CONSTRAINT "work_item_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "zone" table
--
ALTER TABLE ONLY "zone"
    ADD CONSTRAINT "zone_fk_0"
    FOREIGN KEY("venueId")
    REFERENCES "venue"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_future_call_claim" table
--
ALTER TABLE ONLY "serverpod_future_call_claim"
    ADD CONSTRAINT "serverpod_future_call_claim_fk_0"
    FOREIGN KEY("futureCallId")
    REFERENCES "serverpod_future_call"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_log" table
--
ALTER TABLE ONLY "serverpod_log"
    ADD CONSTRAINT "serverpod_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_message_log" table
--
ALTER TABLE ONLY "serverpod_message_log"
    ADD CONSTRAINT "serverpod_message_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_query_log" table
--
ALTER TABLE ONLY "serverpod_query_log"
    ADD CONSTRAINT "serverpod_query_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_anonymous_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_anonymous_account"
    ADD CONSTRAINT "serverpod_auth_idp_anonymous_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_apple_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_apple_account"
    ADD CONSTRAINT "serverpod_auth_idp_apple_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account_password_reset_request" table
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_0"
    FOREIGN KEY("emailAccountId")
    REFERENCES "serverpod_auth_idp_email_account"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_1"
    FOREIGN KEY("challengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_password_reset_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_2"
    FOREIGN KEY("setPasswordChallengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_email_account_request" table
--
ALTER TABLE ONLY "serverpod_auth_idp_email_account_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_request_fk_0"
    FOREIGN KEY("challengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_idp_email_account_request"
    ADD CONSTRAINT "serverpod_auth_idp_email_account_request_fk_1"
    FOREIGN KEY("createAccountChallengeId")
    REFERENCES "serverpod_auth_idp_secret_challenge"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_facebook_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_facebook_account"
    ADD CONSTRAINT "serverpod_auth_idp_facebook_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_firebase_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_firebase_account"
    ADD CONSTRAINT "serverpod_auth_idp_firebase_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_github_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_github_account"
    ADD CONSTRAINT "serverpod_auth_idp_github_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_google_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_google_account"
    ADD CONSTRAINT "serverpod_auth_idp_google_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_microsoft_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_microsoft_account"
    ADD CONSTRAINT "serverpod_auth_idp_microsoft_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_idp_passkey_account" table
--
ALTER TABLE ONLY "serverpod_auth_idp_passkey_account"
    ADD CONSTRAINT "serverpod_auth_idp_passkey_account_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_jwt_refresh_token" table
--
ALTER TABLE ONLY "serverpod_auth_core_jwt_refresh_token"
    ADD CONSTRAINT "serverpod_auth_core_jwt_refresh_token_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_profile" table
--
ALTER TABLE ONLY "serverpod_auth_core_profile"
    ADD CONSTRAINT "serverpod_auth_core_profile_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "serverpod_auth_core_profile"
    ADD CONSTRAINT "serverpod_auth_core_profile_fk_1"
    FOREIGN KEY("imageId")
    REFERENCES "serverpod_auth_core_profile_image"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_profile_image" table
--
ALTER TABLE ONLY "serverpod_auth_core_profile_image"
    ADD CONSTRAINT "serverpod_auth_core_profile_image_fk_0"
    FOREIGN KEY("userProfileId")
    REFERENCES "serverpod_auth_core_profile"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_auth_core_session" table
--
ALTER TABLE ONLY "serverpod_auth_core_session"
    ADD CONSTRAINT "serverpod_auth_core_session_fk_0"
    FOREIGN KEY("authUserId")
    REFERENCES "serverpod_auth_core_user"("id")
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
