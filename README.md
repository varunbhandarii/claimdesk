# ClaimDesk

A lost-and-found desk app for venue staff. This workspace currently contains the
Serverpod server, generated typed client, and Flutter starter app.

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
flutter run -d <device-id> --dart-define=SERVER_URL=http://<computer-lan-ip>:8080/
```

Alternatively, use `adb reverse tcp:8080 tcp:8080` and
`--dart-define=SERVER_URL=http://127.0.0.1:8080/` over USB.

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
