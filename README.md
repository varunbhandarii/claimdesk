# ClaimDesk

A lost-and-found desk app for venue staff. This workspace currently contains the
Serverpod server, generated typed client, and Flutter staff app. Staff can sign
in, select their venue, log a found item with a photo, watch its caption arrive,
and review or edit its details. The backend
includes venue membership checks, item/report storage, audit and custody records,
and a durable background worker that prepares photos, captions items, and creates
search embeddings. Private uploads and item endpoints are available through the
generated client.

## Local setup

Use Flutter 3.47.5 (Dart 3.13.4), Serverpod CLI 4.0.2, Chrome, and an Android SDK.
Run commands in a normal, non-administrator PowerShell window.

```powershell
dart install serverpod_cli@4.0.2
flutter pub get
serverpod start
```

Add `%LOCALAPPDATA%\Dart\install\bin` to your user PATH if `serverpod` is not found.
The server starts its own PostgreSQL instance. Docker and Redis are unnecessary.
The API runs on port 8080; the web server runs on port 8082. The Flutter app opens
in Chrome. Press R to restart, M to create/apply a migration, and Q to stop.

Server tests run with their own embedded database:

```powershell
cd claimdesk_server
dart test
```

For an Android phone, enable USB debugging and accept the computer authorization.
Then run from a second terminal while the server is running:

```powershell
cd claimdesk_flutter
flutter devices
adb reverse tcp:8080 tcp:8080
flutter run -d <device-id> --dart-define=SERVER_URL=http://127.0.0.1:8080/
```

Keep the USB connection active while using the local server. Camera and gallery
intake are available on Android; the web app uses a file picker.

## Demo desk

Stop the development server before running the seed command, since it uses the
same API port. From `claimdesk_server`:

```powershell
serverpod run seed
serverpod start
```

Seeding creates Hawrys Rec Center (demo), six zones, and two accounts:
`supervisor@demo.claimdesk.local` and `staff@demo.claimdesk.local`. Set
`demoStaffPassword` in the ignored passwords file or as
`SERVERPOD_PASSWORD_demoStaffPassword`. Development and test modes have a local
fallback; production requires an explicitly configured password. Rerunning the
seed restores demo settings while preserving ids and existing account passwords.

Cloud seeding uses the `admin.seedDemo` endpoint and requires a separately
configured `seedSecret`. Its request body is `{"secret":"<configured value>"}`
at `POST /admin/seedDemo`. An unset or incorrect secret denies access. Keep both
credentials out of source control and shell history.

Signed-in clients can call `venue.myMemberships()`, `venue.getVenue(id)`, and
`venue.zones(id)`. Every venue lookup checks the caller's membership. The Flutter
app opens the only assigned desk automatically, or offers a venue picker. It
remembers the signed-in session and selected venue on this device.

## Photo intake

Set `ANTHROPIC_API_KEY` and `GEMINI_API_KEY` in your local process environment
before starting the server. Existing Windows user environment variables can be
loaded into a terminal without displaying them:

```powershell
$env:ANTHROPIC_API_KEY = [Environment]::GetEnvironmentVariable('ANTHROPIC_API_KEY', 'User')
$env:GEMINI_API_KEY = [Environment]::GetEnvironmentVariable('GEMINI_API_KEY', 'User')
cd claimdesk_server
serverpod start --no-flutter
```

The defaults are `claude-opus-5-5` and `gemini-embedding-2` with 1536 dimensions.
Startup reports the selected providers. Missing keys select deterministic fakes;
test mode always selects fakes. Cloud uses managed secrets named `anthropicApiKey`
and `geminiApiKey`. Provider keys must never be saved to local files or Git.

1. Sign in, select a venue membership, and call
   `item.requestPhotoUpload(venueId, 'image/jpeg')`.
2. Pass the ticket's `uploadDescription` to `FileUploader.uploadByteData`.
3. Call `item.createItem` with a `CreateItemInput` containing the ticket's
   `itemId`, `photoPath: ticket.path`, `uploadProof: ticket.proof`, and
   `uploadExpiresAt: ticket.expiresAt`, plus the staff's intake fields.
4. Subscribe to `deskStream.watchVenue(venueId)` and re-query `item.getItem`
   when an item event arrives. Call `item.photoUrl` for an
   original or thumbnail download URL, valid for ten minutes.

Tickets are tied to their staff member, venue, item, and ten-minute expiry.
JPEG, PNG, and WebP uploads up to 15 MiB are accepted; decoded images are limited
to 40 million pixels. Photos become JPEGs up to 1024 pixels on the longest edge,
with EXIF removed and a 320-pixel thumbnail. Restricted items keep category-only
caption text. Private staff notes and finder names are never sent to providers.

The worker checks PostgreSQL every three seconds, renews its two-minute lease,
and protects completed work from stale workers. Provider failures fall back to
staff descriptions. Embedding failures preserve usable items with a null vector.
The scheduled recovery sweep is not included yet; staff edits queue re-embedding,
and `item.recaption(itemId)` retries an unclaimed item. `item.captionRuns(itemId)`
returns provider outcomes, latency, and token usage. Invalid images remain
`captioning` after one retry and can be corrected through `item.updateItem`.

Ordinary tests never contact providers. To explicitly run the three local photo
checks with keys already loaded, from `claimdesk_server`:

```powershell
$env:CLAIMDESK_LIVE_PROVIDERS = '1'
try { dart test -t providers --concurrency=1 } finally {
  Remove-Item Env:CLAIMDESK_LIVE_PROVIDERS
}
```

Those checks also require local `umbrella.jpg`, `backpack.jpg`, and
`mock_id_card.jpg` files under `test/fixtures/photos/`. The first two remain
excluded from Git and deployment because their licenses are unknown.

## Workspace

- `claimdesk_server`: backend, configuration, migrations, and tests.
- `claimdesk_client`: generated client; edit models and endpoints to regenerate it.
- `claimdesk_flutter`: Android and web app.

Local passwords belong in the ignored `claimdesk_server/config/passwords.yaml`.
Provider keys belong in local environment variables or Cloud secrets. Never put
keys in source code. Some local photo assets are intentionally excluded from Git;
the included mock ID contains fictional specimen data.

Open this folder as the trusted Codex project to load its generated MCP settings.
The Serverpod bridge connects while `serverpod start` is running.

If Windows redirects the PostgreSQL cache and reports an executable-path
mismatch, set `SERVERPOD_PG_CACHE_DIR` to a stable local directory outside
AppData, then restart your terminal. This installation uses
`C:\dev\serverpod\pg-binaries`.

## Deployment

From `claimdesk_server`, run `serverpod cloud deploy`. The configured pre-deploy
steps regenerate the protocol and build Flutter web under `/app/`. On Windows,
`tool/build_web.ps1` verifies the build before replacing the served files.

To rebuild the locally served app, run `serverpod run flutter_build` from
`claimdesk_server`, then open `http://localhost:8082/app/`. The API URL comes from
the server's app configuration route. Web authentication requires HTTPS or
localhost; opening the app on a plain HTTP LAN address is unsupported.

Run `flutter analyze` and `flutter test` from `claimdesk_flutter` to check the
staff app. The app uses one event stream per venue, retries interrupted streams
with backoff, and refreshes item details after reconnecting. Photo download URLs
are held only in memory and refreshed before expiry. Sign-out clears that desk
session and its photo cache.
